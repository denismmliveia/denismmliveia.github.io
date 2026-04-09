# CLAUDE.md — RaveCards

## Propósito de este archivo

Este archivo define cómo debe comportarse un agente que trabaje sobre el proyecto **RaveCards**.

RaveCards **no** es una tarjeta HTML aislada ni una red social generalista. Es un producto social efímero para entornos de fiesta, centrado en facilitar el intercambio de contacto entre personas que se han conocido físicamente, mediante **escaneo cruzado de QR**, con **chat temporal** y **caducidad total del vínculo**.

Este documento debe usarse para:

- mantener alineado cualquier trabajo técnico o de diseño con la definición real del producto,
- evitar que el proyecto derive hacia una app de citas genérica o una red social persistente,
- conservar la identidad visual y experiencial nacida del prototipo original,
- y delimitar claramente qué es el prototipo actual y qué es el producto completo objetivo.

---

## Regla madre del proyecto

Si una decisión mejora la tecnología pero debilita el ritual social principal, es una mala decisión.

El ritual social principal de RaveCards es este:

1. dos personas se conocen en persona,
2. muestran sus tarjetas,
3. escanean ambos QR,
4. el sistema valida reciprocidad dentro de una ventana breve,
5. se activa un vínculo temporal,
6. el chat existe solo durante el tiempo de vida del enlace,
7. si quieren seguir en contacto, deben salir de RaveCards y darse WhatsApp, Instagram u otro contacto permanente.

Todo lo que se construya debe reforzar ese flujo.

---

## Qué es RaveCards

RaveCards es:

- una herramienta social efímera para fiestas, raves, clubes y festivales,
- una forma suave, rápida y juguetona de compartir contacto,
- una interfaz pensada para música alta, poca luz y atención fragmentada,
- un sistema de **encuentro verificado presencialmente**,
- y un producto que termina casi por completo cuando termina el momento.

RaveCards **no** es:

- una red social de uso diario,
- una agenda de contactos permanente,
- una app de mensajería general,
- un feed,
- un directorio de gente cercana,
- ni un clon de Tinder, Instagram o WhatsApp.

La gente puede usarlo para ligar. Eso se asume. Pero el producto no debe diseñarse ni posicionarse como una app de citas clásica.

---

## Estado actual del proyecto

**V1 MVP completa** (2026-04-09).

El producto está construido y funcional:

- **App Flutter** (Android) con Clean Architecture, BLoC, 7 features completas.
- **10 Cloud Functions** desplegadas en Firebase (europe-west1).
- **4 planes de implementación** ejecutados y merged a `main`.
- **~90 tests Flutter** + **48 tests TypeScript/Jest** pasando.
- Firebase project: `ravecards-dev` (Auth, Firestore, Storage, Cloud Functions, FCM).

El prototipo visual original (`index.html`) sigue existiendo como referencia estética histórica. No es el producto activo.

---

## Principios no negociables

### 1. Solo encuentros en persona
No debe existir conexión si no ha habido encuentro presencial.

### 2. Reciprocidad obligatoria
No basta con un escaneo unilateral. Debe haber escaneo cruzado.

### 3. Ventana breve y explícita
La reciprocidad ocurre dentro de una ventana corta de tiempo.

**En la definición actual del producto la ventana es de 60 segundos.**

### 4. Ephemeral by design
Todo vínculo activo debe caducar:

- acceso a tarjeta,
- chat,
- enlace,
- visibilidad activa.

### 5. Persistencia mínima
Tras la caducidad solo puede quedar un recuerdo mínimo. Nunca un sustituto de agenda de contactos.

### 6. Sin descubrimiento artificial
No debe haber en V1:

- feed,
- explorar usuarios,
- perfiles sugeridos,
- sistema de “gente cerca”,
- ranking,
- matching algorítmico.

### 7. Tono juguetón
La experiencia debe sentirse ligera, casi coleccionable, no solemne ni corporativa.

### 8. Foco extremo
Si una funcionalidad amplía el alcance pero debilita la claridad del producto, se rechaza.

---

## Experiencia núcleo que hay que proteger

La app debe resolver mejor que los métodos actuales este momento:

> conocer a alguien en una fiesta y querer mantener un canal breve de contacto sin tener que deletrear un nick entre altavoces.

Eso significa que toda pantalla, animación, copy y decisión técnica debe favorecer:

- rapidez,
- claridad,
- baja presión social,
- y sensación de ritual compartido.

No diseñar para “retención por retención”.
No diseñar para “más tiempo de uso”.
No diseñar para “adictividad”.

Diseñar para **que el momento salga bien**.

---

## Relación entre el prototipo de tarjeta y el producto

El `index.html` fue el punto de partida visual que definió la estética rave del proyecto. El producto real está construido en `ravecards/` (Flutter) y `functions/` (Cloud Functions). El prototipo sigue siendo útil como referencia estética, pero no representa la arquitectura, los datos ni la lógica del sistema.

---

## Identidad de usuario

RaveCards no usa un perfil social tradicional. Usa una **persona-evento** o alter ego fiestero.

### Campos base definidos actualmente
La tarjeta debe contemplar al menos estos campos:

- imagen de perfil,
- nombre visible elegido por el usuario,
- género favorito,
- orientación,
- estado civil,
- canción favorita (con link opcional a Spotify/YouTube).

### Regla de naming
El nombre visible puede ser:

- nombre real,
- alias,
- nickname,
- o cualquier identificador elegido por el usuario.

No imponer real-name policy en V1.

### Filosofía de identidad
La tarjeta no pretende describir toda la persona.
La tarjeta solo debe comunicar:

- reconocimiento,
- vibra,
- contexto,
- y un mínimo de información útil para el momento.

---

## QR y vinculación

### Regla funcional
Un vínculo solo nace si:

1. A escanea a B,
2. se abre una ventana de 60 segundos,
3. B escanea a A dentro de esa ventana,
4. el sistema valida ambos eventos,
5. se activa el enlace.

### Reescaneo
- Si se reescanea dentro de la misma ventana, no debe ocurrir nada raro ni romperse el flujo.
- Si se escanea fuera de ventana, se abre una nueva ventana de 60 segundos.

### Estado pendiente
Durante la espera debe mostrarse un mensaje juguetón indicando que la otra persona debe escanear también.

### Recomendación técnica
El QR del producto debe ser **dinámico** o basado en token temporal.

No por paranoia de película, sino porque encaja mejor con:

- presencia física,
- seguridad mínima razonable,
- prevención de reutilización torpe de capturas,
- y coherencia con la naturaleza efímera del sistema.

### Prohibición importante
Nunca implementar un sistema en el que un solo usuario pueda adquirir el contacto funcional de otro sin reciprocidad real.

---

## Chat

### Regla actual del producto
El chat es:

- 1 a 1,
- temporal,
- dependiente del enlace,
- y no se puede reabrir una vez caducado.

### Intención del chat
El chat no es el destino principal del producto.
El chat es la prolongación breve del encuentro.

### Restricción de diseño
No diseñar el chat como si fuera el centro de la aplicación.
Debe sentirse claramente subordinado al vínculo temporal.

### Futuro posible
Fotos de visualización única pueden ser una ampliación razonable, pero no deben alterar la simplicidad de V1.

---

## Caducidad

### Regla
Cuando caduca el enlace, caduca todo lo activo:

- acceso a la tarjeta viva,
- chat,
- estado del vínculo,
- posibilidad de seguir interactuando dentro de la app.

### Filosofía
La caducidad no es una limitación artificial de negocio.
La caducidad es parte del producto.

### No hacer
- no reabrir chats caducados,
- no restaurar enlaces,
- no convertir automáticamente un encuentro temporal en contacto permanente,
- no construir “backdoors” que traicionen la efimeridad.

---

## Memoria mínima

Después de expirar, puede quedar un recuerdo mínimo.

Ese recuerdo existe para preservar la sensación de noche vivida, no para reemplazar una agenda.

### Debe ser mínimo
Puede incluir cosas como:

- nombre visible,
- miniatura o rastro visual,
- fecha,
- estado caducado,
- y en el futuro quizá referencia al evento.

### No debe permitir
- reabrir contacto,
- seguir chateando,
- reconstruir una red social estable,
- ni convertir RaveCards en archivo histórico de personas.

---

## Seguridad y moderación

Aunque el tono sea divertido, el control debe ser serio.

### Debe existir desde V1
- cortar vínculo,
- bloquear,
- reportar.

### Principio
La seguridad no debe depender del buen comportamiento idealizado del usuario.

### Antiabuso
Si hay patrones de escaneos unilaterales repetidos, el sistema puede aplicar:

- límites de frecuencia,
- fricción adicional,
- señales internas de abuso,
- o restricciones temporales.

No hacer castigos teatrales de cara al usuario salvo que aporten valor real.

---

## Descubrimiento y alcance

### V1 no incluye
- feed,
- exploración de perfiles,
- cercanía por geolocalización,
- recomendaciones,
- matching automático,
- ni browsing de personas.

### Alcance contextual
La V1 está pensada 100% para ambiente de fiesta.

No hace falta geofencing obligatorio en la primera versión.
La cultura de uso puede preceder a la restricción técnica.

---

## Línea visual del proyecto

La estética visual original del prototipo debe considerarse **referencia fundacional**.

### Rasgos que deben preservarse
- fondo oscuro negro-púrpura,
- acentos neón,
- sensación techno / rave,
- grid sutil,
- glow contenido,
- identidad nocturna,
- tono visual entre credencial, collectible y objeto digital de club.

### Tono visual a evitar
- corporativo,
- lifestyle genérico,
- dating app de catálogo,
- neón chillón sin criterio,
- sci-fi militar,
- ni tarjeta de visita seria disfrazada.

### Estado de theming
En V1 hay **una estética fija**.

No introducir un sistema de skins, temas por usuario o temas por evento salvo que se pida explícitamente en una fase posterior.

---

## Prototipo HTML original

El archivo `index.html` es una referencia visual histórica. No es el producto activo. Se conserva para consulta estética.

---

## Guía técnica para replicación

Esta sección permite a un agente sin contexto entender, construir y continuar el proyecto.

### Estructura del repositorio

```
ravecards/                  App Flutter (Android V1)
  lib/
    core/                   DI (injectable+get_it), router (GoRouter), theme, errors, services
    features/
      auth/                 Firebase Auth (teléfono SMS OTP + Google)
      card/                 Tarjeta de usuario, QR dinámico
      scan/                 Cámara QR, escaneo, previsualización
      link/                 Vínculos activos, countdown, lista
      chat/                 Mensajes texto + fotos visualización única
      memories/             Recuerdos mínimos post-expiración
      moderation/           Revocar, bloquear, reportar (solo domain+data, sin UI propia)
  test/                     ~90 tests (mockito + mocktail + bloc_test)

functions/                  Cloud Functions (Node.js 20, TypeScript)
  src/
    qr/                     generateQrToken, validateQrToken
    link/                   initiateLink, confirmLink, expireLinks, revokeLink
    chat/                   requestPhotoUploadUrl, getPhotoViewUrl
    moderation/             blockUser, reportUser
    lib/                    helpers compartidos (createMemories, cleanupPhotos)
  test/                     48 tests (Jest + ts-jest)

firestore.rules             Reglas de seguridad Firestore
storage.rules               Reglas de seguridad Storage
firestore.indexes.json      Índices compuestos (anti-abuso)
firebase.json               Config Firebase (emuladores, deploys)
docs/superpowers/
  specs/                    Spec de diseño V1
  plans/                    4 planes de implementación (históricos)
index.html                  Prototipo visual original (referencia estética)
```

### Arquitectura

- **Clean Architecture ligera**: cada feature tiene `presentation/` (BLoC/Cubit, pages, widgets), `domain/` (entidades, use cases, interfaces), `data/` (implementaciones Firebase).
- **State management**: BLoC + Cubit. Estados usan `Equatable`.
- **DI**: `injectable` + `get_it`. Generar con `dart run build_runner build --delete-conflicting-outputs`.
- **Router**: GoRouter con redirect basado en auth state y `hasCard`.
- **La capa data** es la única que importa Firebase SDK directamente.
- **Cloud Functions** usan v2 API (`firebase-functions/v2/https`, no el top-level).
- **Región**: `europe-west1` (set via `setGlobalOptions` en cada archivo).

### Modelo de datos Firestore (implementado)

```
users/{uid}
  displayName, photoUrl, genre, orientation, relationshipStatus
  favoriteSong, favoriteSongUrl       ← canción favorita + link opcional
  activeQrToken, qrTokenExpiresAt     ← gestionados por Cloud Function
  fcmToken                            ← token FCM para push notifications
  hasCard: boolean

links/{linkId}
  userA, userB, status                ← pending | linked | expired | revoked
  initiatedBy, pendingExpiresAt
  linkedAt, expiresAt
  duration: 12                        ← siempre 12h, set server-side
  revokedBy, createdAt

links/{linkId}/messages/{msgId}
  type                                ← text | photo_once
  senderId, text, photoRef
  viewedBy: []                        ← array de uids que han visto la foto
  deletedFromStorage: boolean
  createdAt

memories/{uid}/cards/{memoryId}
  otherUserName, otherUserAvatarThumb
  linkedAt, expiredAt, status

blocks/{uid}/blocked/{blockedUid}
  blockedAt

reports/{reportId}
  reporterId, reportedId, category, note, createdAt
```

### Cloud Functions (10 desplegadas)

| Función | Descripción |
|---|---|
| `generateQrToken` | Genera JWT firmado con uid del usuario, TTL 5 min |
| `validateQrToken` | Verifica JWT, devuelve tarjeta del usuario escaneado |
| `initiateLink` | Crea link PENDING o completa a LINKED si escaneo mutuo (12h fijo). Anti-abuso: 4 scans/5min por par |
| `confirmLink` | **Existe pero NO se usa en el flujo actual** (el enlace mutuo es automático en `initiateLink`) |
| `expireLinks` | Scheduler cada 5 min: expira links LINKED + PENDING, crea memorias, limpia fotos en Storage |
| `revokeLink` | Participante revoca su propio vínculo |
| `requestPhotoUploadUrl` | Genera URL firmada para subir foto al chat |
| `getPhotoViewUrl` | Genera URL firmada (15s TTL), marca `viewedBy`, elimina de Storage si ambos han visto |
| `blockUser` | Bloquea usuario + revoca link opcionalmente |
| `reportUser` | Reporta + auto-bloquea |

### Entorno de desarrollo

```bash
# Flutter (NO está en PATH del sistema)
"C:/Users/denis/develop/flutter/bin/flutter.bat" <comando>

# Firebase project
ravecards-dev

# Tests Flutter
cd ravecards/ && flutter test

# Tests Cloud Functions
cd functions/ && npm test

# Build Cloud Functions
cd functions/ && npm run build

# Deploy Cloud Functions
firebase deploy --only functions

# Deploy reglas
firebase deploy --only firestore:rules,storage

# Regenerar DI
cd ravecards/ && dart run build_runner build --delete-conflicting-outputs
```

### Desviaciones respecto al spec original

El spec técnico (`docs/superpowers/specs/2026-04-07-ravecards-v1-design.md`) fue escrito antes de la implementación. Diferencias:

1. **Duration picker eliminado** — la duración es siempre 12h, configurada server-side en `initiateLink`. El picker de 4h/12h/24h/3d no se implementó.
2. **`confirmLink` no se usa** — el flujo mutuo es automático dentro de `initiateLink`. La Cloud Function existe desplegada pero ninguna pantalla la invoca.
3. **`favoriteTheme` → `favoriteSong` + `favoriteSongUrl`** — el campo de la tarjeta se renombró para representar una canción favorita con link opcional a Spotify/YouTube. `CardModel` tiene fallback para leer el campo antiguo.
4. **`fcmToken` añadido** — campo en `users/{uid}` para notificaciones push FCM. No estaba en el spec original.

---

## Qué no debe hacer un agente en este proyecto

Un agente no debe:

- convertir el producto en una red social persistente,
- añadir feeds o exploración de usuarios por iniciativa propia,
- inventar features de retención que traicionen la idea,
- meter monetización en la mecánica central,
- sustituir el escaneo cruzado por aceptación unilateral,
- cambiar la filosofía de caducidad sin instrucción explícita,
- ni banalizar la seguridad porque “es solo una app para fiestas”.

Tampoco debe:

- rehacer el tono como si esto fuera una startup SaaS,
- meter lenguaje corporativo,
- ni suavizar tanto el concepto que pierda su personalidad.

---

## Qué sí debe hacer un agente

Un agente debe:

- proteger el foco del producto,
- mantener coherencia entre diseño, UX y reglas del sistema,
- distinguir demo de producto,
- proponer simplificaciones inteligentes,
- detectar scope creep,
- señalar contradicciones con la definición de RaveCards,
- y favorecer soluciones rápidas, claras y jugables.

Cuando haya duda, priorizar:

1. claridad,
2. reciprocidad,
3. efimeridad,
4. seguridad,
5. identidad visual,
6. simplicidad de uso.

---

## Checklist de validación antes de aceptar cambios

Antes de aceptar una propuesta, cambio o implementación, comprobar:

- [ ] ¿Refuerza el encuentro en persona?
- [ ] ¿Respeta el escaneo cruzado?
- [ ] ¿Mantiene la ventana breve de reciprocidad?
- [ ] ¿Preserva la naturaleza efímera del vínculo?
- [ ] ¿Evita crear una red persistente disfrazada?
- [ ] ¿Mantiene el tono juguetón y fiestero?
- [ ] ¿No convierte el producto en una app de citas genérica?
- [ ] ¿No añade complejidad gratuita?
- [ ] ¿Es coherente con una V1 enfocada en fiesta?
- [ ] ¿Distingue correctamente demo visual de sistema real?

Si varias respuestas son “no”, el cambio probablemente va en mala dirección.

---

## Prototipo original: referencia concreta a conservar

El prototipo original aporta varias decisiones útiles que deben conservarse como referencia base:

- tarjeta centrada y compacta,
- top bar con identidad de tarjeta activa,
- foto circular con glow,
- campos expresivos y cortos,
- QR visible como pieza central de acción,
- animación de entrada tipo boot sequence,
- y estética oscura con neón púrpura y verde.

Esas decisiones siguen siendo valiosas aunque la arquitectura final del producto ya no sea un HTML único publicado en GitHub Pages.

---

## Resumen operativo

Si trabajas en este proyecto, actúa como si RaveCards fuera una mezcla entre:

- un ritual social efímero,
- una credencial digital de noche,
- y una herramienta ligera de continuidad tras el encuentro.

No actúes como si estuvieras construyendo:

- una red social clásica,
- una app de citas pura,
- o una plataforma de mensajería general.

La calidad del proyecto depende menos de cuántas funciones tenga y más de que el núcleo salga fino.

Y el núcleo es simple:

**conocerse, escanearse, enlazarse, hablar un rato, y desaparecer a tiempo.**
