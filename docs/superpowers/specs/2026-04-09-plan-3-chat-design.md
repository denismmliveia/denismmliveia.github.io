# Plan 3 — Chat Texto + Fotos de Visualización Única

**Fecha:** 2026-04-09  
**Estado:** Aprobado — pendiente de implementación  
**Depende de:** Plan 2 (`feat/plan-2-scan-link`) — links LINKED activos en Firestore

---

## 1. Alcance

Plan 3 añade el chat 1:1 temporal entre usuarios con un vínculo activo (`status: linked`). Incluye:

- Mensajes de texto en tiempo real vía Firestore stream
- Fotos de visualización única: hold-to-view (5s máx), URL firmada 15s TTL, borrado de Storage tras doble visualización
- `FLAG_SECURE` en Android durante la sesión de chat
- Overlay de expiración cuando el vínculo caduca mientras el chat está abierto
- Acceso a revocar / reportar desde el chat

**No incluye en Plan 3:**
- FCM / notificaciones push (Plan 4)
- Expiración automática del vínculo (Plan 4)
- Pantalla de Recuerdos funcional (Plan 4, solo stub)

---

## 2. Arquitectura

### Enfoque elegido: Híbrido (Firestore directo para texto, Cloud Functions para fotos)

- **Texto:** el cliente escribe directamente en la subcolección `links/{linkId}/messages/`. Las reglas de Firestore validan que el escritor es participante del link.
- **Fotos:** dos Cloud Functions callables gestionan subida y descarga. El cliente nunca accede a Storage directamente.
- **Borrado de fotos:** la propia `getPhotoViewUrl` comprueba si `viewedBy` está completo y borra de Storage en la misma llamada. Sin trigger adicional.

### Nueva feature Flutter: `chat/`

Sigue el mismo patrón de Clean Architecture que `scan/` y `link/`:

```
lib/features/chat/
  domain/
    entities/message_entity.dart
    repositories/chat_repository.dart
    usecases/watch_messages.dart
    usecases/send_text_message.dart
    usecases/send_photo_message.dart
    usecases/request_photo_view.dart
  data/
    models/message_model.dart
    repositories/chat_repository_impl.dart
  presentation/
    cubit/chat_cubit.dart
    cubit/chat_state.dart
    pages/chat_page.dart
    widgets/text_bubble_widget.dart
    widgets/photo_bubble_widget.dart
    widgets/chat_input_bar.dart
```

### Nuevas Cloud Functions

```
functions/src/chat/requestPhotoUploadUrl.ts
functions/src/chat/getPhotoViewUrl.ts
functions/src/index.ts   ← exportar las dos nuevas
```

---

## 3. Modelo de datos

Subcolección ya definida en el spec de producto:

```
links/{linkId}/messages/{msgId}
  type: "text" | "photo_once"
  senderId: uid
  text: string | null
  photoRef: string | null       ← ruta privada en Firebase Storage
  viewedBy: string[]            ← UIDs que ya vieron la foto
  deletedFromStorage: bool
  createdAt: timestamp
```

Reglas de Firestore para mensajes:
- Crear: solo si `request.auth.uid == resource.data.userA || userB` del link padre y `status == "linked"`
- Leer: solo participantes del link
- Actualizar `viewedBy` y `deletedFromStorage`: solo Cloud Functions (via Admin SDK)

---

## 4. Flujos de datos

### Texto

1. Usuario escribe y pulsa enviar → `ChatCubit.sendText(text)`
2. `ChatRepositoryImpl` escribe en Firestore: `{type: text, senderId, text, createdAt: serverTimestamp()}`
3. Stream Firestore actualiza la lista en tiempo real en ambos dispositivos

### Foto (envío)

1. Usuario pulsa botón cámara → `image_picker` con `ImageSource.camera` (sin galería)
2. Imagen comprimida a máx. 800px en el lado largo, calidad 80% antes de subir
3. `ChatCubit.sendPhoto(imageBytes)` → `ChatRepositoryImpl.sendPhoto()`
4. Llama callable `requestPhotoUploadUrl(linkId, msgId)` → recibe `{uploadUrl, photoRef}`
5. HTTP PUT de los bytes al `uploadUrl` (URL firmada de subida a Storage)
6. Escribe mensaje en Firestore: `{type: photo_once, photoRef, viewedBy: [], deletedFromStorage: false, senderId, createdAt}`
7. Ambos ven burbuja "Mantén para ver 📸"

### Foto (visualización)

1. Destinatario hace long-press en la burbuja `photo_once`
2. `ChatCubit.requestPhotoView(msgId)` → llama callable `getPhotoViewUrl(linkId, msgId)`
3. CF valida que:
   - El uid no está ya en `viewedBy`
   - `deletedFromStorage == false`
   - El vínculo sigue `linked`
4. CF genera URL firmada de descarga (TTL 15s) → añade uid a `viewedBy` (Admin SDK)
5. Si `viewedBy.length == 2` (ambos participantes): CF borra el archivo de Storage y marca `deletedFromStorage: true`
6. App recibe la URL → muestra imagen mientras el dedo está pulsado (máx. 5s)
7. Al soltar o al timeout de 5s → imagen se oculta
8. Stream Firestore actualiza la burbuja: si `deletedFromStorage: true` → muestra "Foto eliminada"

### Carga de mensajes

- Stream Firestore: `links/{linkId}/messages` ordenado por `createdAt` ASC, límite 100
- Scroll automático al fondo al llegar mensajes nuevos

---

## 5. UI

### `ChatPage`

- **Header fijo:** mini avatar circular + nombre del otro usuario + `CountdownWidget` del vínculo (reutiliza widget de Plan 2) + icono de menú (revocar / reportar)
- **Lista de mensajes:** `ListView.builder` con burbujas según tipo
- **Overlay de expiración:** cuando el stream del link cambia a `status != linked` → overlay "Este vínculo ha expirado" con botón a Recuerdos (stub)
- **`FLAG_SECURE`:** activado en `initState`, desactivado en `dispose` (plugin `flutter_windowmanager`)

### `TextBubbleWidget`

- Burbuja alineada a derecha (propio) o izquierda (otro)
- Estética rave: fondo oscuro, texto blanco, acento neón en la burbuja propia
- Muestra hora (`createdAt`)

### `PhotoBubbleWidget`

Estado según los datos del mensaje:

| Condición | Texto mostrado |
|---|---|
| `viewedBy` no contiene uid del usuario actual y `deletedFromStorage: false` | "Mantén para ver 📸" |
| `viewedBy` contiene uid del usuario actual | "Ya vista" |
| `deletedFromStorage: true` | "Foto eliminada" |
| Durante hold-to-view | Imagen a pantalla completa con overlay oscuro |

Interacción: `GestureDetector` con `onLongPressStart` → solicita URL → muestra imagen. `onLongPressEnd` o Timer 5s → oculta imagen.

### `ChatInputBar`

- Campo de texto expandible + botón enviar
- Botón cámara (izquierda del campo)
- Deshabilitado si `link.status != linked`

---

## 6. Cloud Functions

### `requestPhotoUploadUrl`

```
Input:  { linkId: string, msgId: string }
Output: { uploadUrl: string, photoRef: string }
```

- Valida que el caller es participante del link y `status == linked`
- Genera ruta privada: `chat/{linkId}/{msgId}/{uid}_{timestamp}.jpg`
- Genera URL firmada de subida (método PUT, TTL 5 min, content-type `image/jpeg`)
- Devuelve `{uploadUrl, photoRef}`

### `getPhotoViewUrl`

```
Input:  { linkId: string, msgId: string }
Output: { viewUrl: string }
```

- Valida que el caller es participante del link
- Lee el documento del mensaje
- Si uid ya está en `viewedBy` → devuelve error `already-viewed`
- Si `deletedFromStorage: true` → devuelve error `already-deleted`
- Genera URL firmada de descarga (TTL 15s)
- Añade uid a `viewedBy` (Admin SDK, `arrayUnion`)
- Si `viewedBy` completo → borra archivo de Storage → marca `deletedFromStorage: true`
- Devuelve `{viewUrl}`

---

## 7. Nuevas dependencias Flutter

```yaml
image_picker: ^1.1.2          # cámara nativa (solo ImageSource.camera)
flutter_windowmanager: ^0.3.0 # FLAG_SECURE en Android
```

`image_picker` requiere permisos de cámara en `AndroidManifest.xml` (ya añadidos en Plan 2 para `mobile_scanner`).

---

## 8. Tests

### Flutter (unit)

**`ChatCubit`:**
- Texto: `Initial → Sending → Idle` (mensaje aparece en stream)
- Foto: `Initial → UploadingPhoto → Idle`
- Visualización: `requestPhotoView → Viewing → Viewed`
- Error en CF: estado de error propagado correctamente
- Vínculo expirado: cubit emite `LinkExpired`

**`ChatRepositoryImpl`:**
- Mock de Firestore: verifica escritura correcta del mensaje texto
- Mock de Functions: verifica llamada a `requestPhotoUploadUrl` con parámetros correctos
- Mock de Functions: verifica llamada a `getPhotoViewUrl` y retorno de URL

### Cloud Functions (Jest)

**`requestPhotoUploadUrl`:**
- Rechaza si uid no es participante del link
- Rechaza si `status != linked`
- Genera ruta de Storage con formato correcto
- Devuelve `uploadUrl` y `photoRef`

**`getPhotoViewUrl`:**
- Rechaza si uid ya está en `viewedBy`
- Rechaza si `deletedFromStorage: true`
- Añade uid a `viewedBy`
- Borra Storage y marca `deletedFromStorage: true` cuando `viewedBy` tiene los dos participantes
- Devuelve URL firmada con TTL 15s

---

## 9. Criterios de done

- [ ] Chat texto funciona en tiempo real entre dos usuarios con vínculo `linked`
- [ ] Fotos se suben por URL firmada y la burbuja aparece en ambos dispositivos
- [ ] Hold-to-view funciona: imagen visible mientras se pulsa, máx. 5s, se oculta al soltar
- [ ] Foto borrada de Storage tras ser vista por ambos participantes; burbuja muestra "Foto eliminada"
- [ ] `FLAG_SECURE` bloquea capturas nativas mientras `ChatPage` está activa
- [ ] Overlay de expiración aparece si el vínculo caduca con el chat abierto
- [ ] Input deshabilitado si el vínculo no está `linked`
- [ ] Todos los tests Flutter y Jest pasan
- [ ] APK debug buildea limpio
