# RaveCards V1 — Design Spec

**Fecha:** 2026-04-07  
**Estado:** V1 COMPLETA (2026-04-09)

| Plan | Contenido | Estado |
|---|---|---|
| Plan 1 | Foundation + Auth + Card + QR dinámico | ✅ Completo (2026-04-07) |
| Plan 2 | Escaneo QR, validación mutua, ventana 60s, links PENDING/LINKED | ✅ Completo (2026-04-08) |
| Plan 3 | Chat texto + fotos visualización única (hold-to-view, FLAG_SECURE) | ✅ Completo (2026-04-09) |
| Plan 4 | Expiración, memoria mínima, block/report/revoke, anti-abuso, FCM, polish | ✅ Completo (2026-04-09) |

---

## Notas post-implementación

Este spec fue escrito antes de la implementación. Las siguientes diferencias existen entre el spec y lo que fue construido:

1. **Duration picker eliminado**: La duración es siempre 12h, configurada server-side en `initiateLink`. El picker de 4h/12h/24h/3d no se implementó. `confirmLink` Cloud Function existe pero no se usa en el flujo.
2. **`favoriteTheme` → `favoriteSong` + `favoriteSongUrl`**: El campo de la tarjeta fue renombrado para representar una canción favorita con link opcional a Spotify/YouTube.
3. **`fcmToken`**: Campo añadido a `users/{uid}` para notificaciones push FCM (no estaba en el spec original).
4. **Anti-abuso**: Implementado directamente en `initiateLink` (4 scans/5min por par de usuarios), no como sistema separado.

---

## 1. Resumen del producto

RaveCards es una app social efímera para fiestas, raves, clubs y festivales. Permite conectar con personas conocidas en persona mediante tarjetas temporales con QR, escaneo cruzado mutuo, chat temporal 1:1 con fotos de visualización única, y caducidad total del vínculo.

**No es** una red social, agenda de contactos, app de citas, feed, ni sistema de descubrimiento de usuarios.

---

## 2. Stack técnico

| Capa | Tecnología |
|---|---|
| App | Flutter (Android V1) |
| State management | BLoC |
| Auth | Firebase Auth — teléfono (SMS OTP) principal, Google como alternativa |
| Base de datos | Cloud Firestore |
| Storage | Firebase Storage |
| Backend logic | Cloud Functions (Node.js) |
| Push notifications | Firebase Cloud Messaging (FCM) |
| QR generation | Paquete Flutter (`qr_flutter`) |
| QR scanning | Cámara nativa Flutter (`mobile_scanner`) |

---

## 3. Arquitectura — Clean Architecture ligera

### Estructura de carpetas

```
lib/
  core/                  ← errores, constantes, router, theme
  features/
    auth/
      presentation/      ← widgets, páginas, BLoC
      domain/            ← entidades, casos de uso, interfaces de repo
      data/              ← repositorios Firebase, modelos JSON
    card/                ← tarjeta de usuario, QR dinámico
    scan/                ← cámara, lector QR, UI de escaneo
    link/                ← estados del vínculo, ventana 60s, expiración
    chat/                ← mensajes texto, fotos de visualización única
    memory/              ← recuerdos mínimos tras expirar
    moderation/          ← revocar, bloquear, reportar
```

### Principio de capas

- **Presentation:** widgets + BLoC. No importa Firebase directamente.
- **Domain:** entidades puras, interfaces de repositorio, casos de uso. Sin dependencias externas.
- **Data:** implementaciones de repositorio con Firebase SDK. Solo esta capa toca Firebase.

### División Flutter app / Cloud Functions

**Flutter app:**
- UI y navegación
- BLoC: estado de pantalla
- Mostrar QR dinámico (token recibido de Cloud Fn)
- Cámara y lectura QR
- Chat en tiempo real via Firestore stream
- Countdown 60s visual
- Reacción a cambios de estado del link via stream

**Cloud Functions:**
- Generar y verificar tokens QR firmados (JWT, TTL 5 min)
- Validar escaneo cruzado mutuo
- Abrir / cerrar ventana de 60s
- Crear vínculo activo
- Procesar fotos de visualización única (URL firmada 15s + borrado post-visualización)
- Expiración server-side (Cloud Scheduler)
- Moderación: revocar, bloquear, reportar

---

## 4. Modelo de datos Firestore

```
users/{uid}
  displayName: string
  photoUrl: string
  genre: string
  orientation: string
  relationshipStatus: string
  favoriteTheme: string
  activeQrToken: string        ← JWT generado por Cloud Fn, TTL 5 min
  qrTokenExpiresAt: timestamp
  createdAt: timestamp

links/{linkId}
  userA: uid
  userB: uid
  status: "pending" | "linked" | "expired" | "revoked"
  initiatedBy: uid
  pendingExpiresAt: timestamp  ← ventana de 60s
  linkedAt: timestamp
  expiresAt: timestamp         ← duración elegida por el usuario al confirmar
  duration: number             ← duración en horas (4, 12, 24, 72...)
  revokedBy: uid | null
  createdAt: timestamp

links/{linkId}/messages/{msgId}
  type: "text" | "photo_once"
  senderId: uid
  text: string | null
  photoRef: string | null      ← ruta en Firebase Storage (solo accesible via URL firmada)
  viewedBy: string[]           ← UIDs que ya vieron la foto
  deletedFromStorage: bool
  createdAt: timestamp

memories/{uid}/cards/{memoryId}
  otherUserName: string
  otherUserAvatarThumb: string ← miniatura reducida
  linkedAt: timestamp
  expiredAt: timestamp
  status: "expired" | "revoked"

blocks/{uid}/blocked/{blockedUid}
  blockedAt: timestamp

reports/{reportId}
  reporterId: uid
  reportedId: uid
  category: "inappropriate" | "content" | "harassment" | "other"
  note: string | null
  createdAt: timestamp
```

---

## 5. Ciclo de vida del vínculo

### Estados

| Estado | Descripción |
|---|---|
| `pending` | A escaneó a B. Ventana de 60s abierta. Esperando escaneo de vuelta. |
| `linked` | Ambos escaneos completados. Chat activo. Duración corriendo. |
| `expired` | Tiempo de duración agotado. Chat cerrado. Solo queda recuerdo mínimo. |
| `revoked` | Un usuario cortó el vínculo manualmente o bloqueó al otro. |

### Reglas

- Solo un vínculo PENDING activo por par de usuarios a la vez.
- Si A reescanea a B mientras el PENDING sigue activo → no ocurre nada.
- Si A reescanea a B tras timeout → nueva ventana de 60s.
- El timeout PENDING se gestiona server-side (Cloud Fn) — no depende de que la app esté abierta.
- El usuario elige la duración al **confirmar el link activo**, no durante el escaneo. Las opciones son **4 valores fijos en un picker**: 4h / 12h / 24h / 3 días. Sin entrada libre de tiempo.
- Al expirar: Cloud Scheduler escribe `status: expired` → app reacciona vía stream.
- Al revocar: Cloud Fn inmediata → ambos usuarios ven el cierre en tiempo real.

---

## 6. Flujo de pantallas

### Onboarding (primera vez)
1. **Splash / Boot** — animación de entrada (hereda del prototipo visual existente)
2. **Login** — teléfono con SMS OTP (principal) o Google (alternativa)
3. **Crear tarjeta** — foto, nombre visible, género favorito, orientación, estado civil, tema favorito

### Navegación principal — Bottom Nav (3 tabs)

**Tab 1 — Mi Tarjeta**
- Tarjeta propia con estética rave
- QR dinámico visible (token refrescado automáticamente cada ~4 min)
- Indicador de estado activo (dot verde pulsante)
- Botón "Escanear" → cámara

**Tab 2 — Vínculos**
- Lista de links activos con countdown de expiración visible
- Tap en vínculo → Chat
- Acciones: revocar / bloquear accesibles desde el item

**Tab 3 — Recuerdos**
- Cards expiradas ordenadas por fecha
- Solo lectura — sin acción posible en V1 (no se pueden borrar ni reabrir)
- Muestra: nombre, avatar reducido, fecha, estado "expirado"

### Flujo de escaneo cruzado
1. **Cámara QR** — A escanea QR de B
2. **Vista previa** — tarjeta de B aparece. Botón "Iniciar enlace"
3. **Pending** — countdown 60s visible. Copy juguetón: "Esperando que te escanee de vuelta…"
4. **¡Linked!** — picker con 4 opciones fijas (4h / 12h / 24h / 3 días) → confirmar → Chat abierto

### Chat
- Header: mini tarjeta del otro + countdown del vínculo
- Burbujas de texto estándar
- Burbuja especial "foto única": "Toca para ver" → hold-to-view (5s máx) → descartada
- Botón revocar / reportar accesible
- Al expirar: overlay "Este vínculo ha expirado" → transición a Recuerdos

---

## 7. Chat y fotos de visualización única

### Modelo de mensaje `photo_once`

1. Usuario sube foto → cifrada en Firebase Storage en ruta privada.
2. Se escribe mensaje con `type: "photo_once"`, `viewedBy: []`.
3. Destinatario ve burbuja "Toca para ver".
4. Al tocar: Cloud Fn genera URL firmada (TTL 15s) + añade uid a `viewedBy`.
5. App muestra foto con hold-to-view (dedo pulsado). Máximo 5s. Sin soltar → descarta.
6. Cloud Fn detecta `viewedBy` completo → borra archivo de Storage → marca `deletedFromStorage: true`.
7. Si el vínculo expira antes de la visualización → Cloud Fn borra el archivo en la limpieza de expiración.

### Seguridad del contenido

- URLs firmadas con TTL 15s — no cacheables ni compartibles.
- Firebase Storage rules: solo Cloud Fn puede leer refs directas. El cliente solo recibe URLs firmadas.
- `FLAG_SECURE` activo en la pantalla de visualización → bloquea capturas nativas de Android.
- No hay protección técnica anti-screenshot perfecta (imposible sin UX severa). `FLAG_SECURE` es la medida razonable.
- Texto: solo texto plano en V1. Sin link previews (evita data leaks).

---

## 8. QR dinámico

- El QR contiene un **JWT firmado** por Cloud Fn con `uid` + `issuedAt` + firma.
- TTL del token: **5 minutos**. Capturas viejas no funcionan.
- La app del escaneador valida el token contra Cloud Fn antes de mostrar la tarjeta.
- Si el escaneador está bloqueado por el objetivo → Cloud Fn rechaza con respuesta neutra.
- El QR se regenera automáticamente en background antes de expirar (~1 min antes del TTL).

---

## 9. Seguridad y moderación

### Acciones del usuario

| Acción | Efecto |
|---|---|
| Revocar vínculo | Vínculo pasa a REVOKED. Chat cierra en tiempo real. No bloquea. |
| Bloquear usuario | Revoca vínculo activo + impide escaneos futuros. Silencioso para el bloqueado. |
| Reportar usuario | Bloquea + escribe en `reports/` para revisión de admin. Selección de categoría + nota opcional. |

### Anti-abuso — escaneos repetidos

- **1–3 intentos fallidos seguidos**: normal, sin acción.
- **4–6 intentos en menos de 5 min al mismo usuario**: cooldown silencioso de 2 min (QR devuelve "no disponible").
- **Patrón sostenido**: señal interna de abuso en Firestore; revisión de admin posible.
- El usuario abusador no ve mensajes de castigo — solo un estado neutro. Reduce confrontación en fiesta.

### Panel de admin en V1

Solo Firebase Console + acceso directo a colección `reports/`. No hay panel custom en V1.

---

## 10. Identidad visual

La estética del prototipo `index.html` existente es la referencia fundacional:

- Fondo oscuro negro-púrpura (`#06000f`)
- Acentos neón púrpura (`#b300ff`) y verde (`#39ff14`)
- Grid sutil de fondo
- Glow contenido
- Foto circular con glow púrpura
- Animación de entrada tipo boot sequence
- Tipografía uppercase con letter-spacing

Esta estética se traslada a Flutter manteniendo la identidad. **Una sola estética fija en V1** — sin temas por usuario ni por evento.

---

## 11. Fuera de alcance en V1

- Feed, exploración de perfiles, "gente cerca", perfiles sugeridos
- Matching algorítmico
- Grupos o chats colectivos
- Personalización por evento / geofencing
- Panel de admin custom
- Múltiples skins o temas visuales
- Reactivar vínculos expirados
- Link previews en el chat
- iOS

---

## 12. Preguntas cerradas

| Pregunta | Decisión |
|---|---|
| Plataforma V1 | Android nativo (Flutter) |
| Framework | Flutter + BLoC |
| Backend | Firebase (Firestore, Auth, Storage, Cloud Functions, FCM) |
| Auth | Teléfono SMS OTP (principal) + Google (alternativa) |
| Duración del vínculo | Configurable por el usuario al confirmar el link (4h / 12h / 24h / 3 días) |
| Chat V1 | Texto + fotos de visualización única (hold-to-view) |
| Foto perfil | Obligatoria (necesaria para la identidad de la tarjeta) |
| Nombre visible | No requiere unicidad en V1 |
| Chat expirado | No se puede reabrir. Transición a Recuerdos. |
| Admin en V1 | Firebase Console solamente |

---

## 13. Próximo paso

Crear el plan de implementación detallado con fases, orden de desarrollo, dependencias entre features y criterios de done para cada módulo.
