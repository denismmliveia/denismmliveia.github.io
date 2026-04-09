# RaveCards

**RaveCards** es una app social efímera para fiestas, raves, clubs y festivales.

Su objetivo es facilitar el intercambio de contacto entre personas que **se han conocido físicamente**, usando **tarjetas temporales con QR** y una mecánica de **escaneo cruzado**. Si ambas personas se escanean mutuamente dentro de una ventana breve, se activa un **chat temporal 1 a 1**. Cuando el tiempo expira, el vínculo desaparece y solo queda un **recuerdo mínimo** del encuentro.

RaveCards **no** intenta sustituir WhatsApp, Instagram ni una red social tradicional. Está pensada para resolver bien un momento muy concreto: **conectar con alguien que acabas de conocer en un entorno de fiesta, de forma rápida, ligera y poco invasiva**.

---

## Estado actual del repositorio

**V1 MVP completa** (2026-04-09).

Este repositorio contiene el producto funcional:

- **App Flutter** (Android) — 7 features con Clean Architecture + BLoC.
- **10 Cloud Functions** (TypeScript, Node.js 20) desplegadas en Firebase.
- **~90 tests Flutter** + **48 tests TypeScript/Jest**.
- Auth (teléfono + Google), tarjeta con QR dinámico, escaneo cruzado mutuo, chat temporal con fotos de visualización única, caducidad automática, memorias mínimas, moderación completa.
- Firebase project: `ravecards-dev` (Firestore, Auth, Storage, Cloud Functions, FCM).

---

## Qué es RaveCards

RaveCards es una herramienta social de contexto.

No es:

- una red social permanente,
- una agenda de contactos,
- un “people nearby”,
- una app de descubrimiento,
- ni una app de citas clásica.

Sí es:

- una herramienta de contacto efímero para ambiente de fiesta,
- una forma lúdica de intercambiar contacto en persona,
- un ritual social rápido y visual,
- y una capa temporal de conversación después del encuentro.

La lógica del producto es simple:

> si el encuentro importa, la app lo facilita; si la relación debe continuar, debe salir fuera de la app antes de que caduque.

---

## Mecánica central del producto

La mecánica base de RaveCards es el **escaneo cruzado mutuo**.

### Regla principal

1. Una persona escanea el QR de otra.
2. Se abre una **ventana de 60 segundos**.
3. La otra persona debe escanear de vuelta dentro de esos 60 segundos.
4. Si ambos escaneos ocurren a tiempo, se crea el vínculo.
5. Ese vínculo habilita una tarjeta compartida y un **chat temporal 1 a 1**.
6. Tras la expiración, todo el acceso activo desaparece.

### Principios no negociables de V1

- Solo conexiones nacidas **en persona**.
- El vínculo solo existe por **acción mutua**.
- El chat es **temporal**.
- La conexión **caduca por completo**.
- No hay feed, búsqueda, perfiles sugeridos ni descubrimiento digital.
- Si dos personas quieren seguir en contacto, deben pasarse sus redes antes de la caducidad.

---

## Propuesta de valor

RaveCards existe porque el intercambio de contacto en una fiesta suele ser torpe:

- no se oye bien un nick,
- buscar perfiles da pereza,
- deletrear nombres corta el rollo,
- pedir contacto a veces se siente demasiado directo,
- y el momento pierde naturalidad.

RaveCards lo convierte en una interacción más:

- rápida,
- juguetona,
- suave,
- contextual,
- y más adecuada al entorno de música alta y atención fragmentada.

---

## Público inicial

La primera versión está enfocada **100% al entorno fiesta**, especialmente:

- raves,
- eventos de música electrónica,
- clubs,
- y festivales.

No se está diseñando inicialmente para:

- networking profesional,
- eventos corporativos,
- campus,
- convenciones,
- ni contextos sociales genéricos fuera de la noche.

---

## Alcance de V1 / MVP

El MVP debe demostrar una sola cosa:

> que en un entorno de fiesta la gente prefiere usar RaveCards antes que intercambiar Instagram manualmente.

### Funcionalidades núcleo implementadas

- registro e inicio de sesión,
- creación de tarjeta de usuario,
- nombre visible elegido por el usuario,
- foto de perfil,
- campos expresivos de tarjeta,
- QR activo,
- escaneo de QR,
- validación de escaneo cruzado,
- ventana de 60 segundos,
- creación de vínculo,
- chat temporal 1 a 1,
- revocar vínculo,
- bloquear usuario,
- reportar usuario,
- caducidad automática,
- y recuerdo mínimo tras expirar.

### Fuera de alcance en V1

Quedan fuera por ahora:

- feeds,
- grupos,
- “usuarios cerca”,
- perfiles sugeridos,
- matching algorítmico,
- paneles para organizadores,
- personalización por evento,
- red social persistente,
- reactivar enlaces caducados,
- y convertir la app en una agenda de contactos permanente.

---

## Filosofía del producto

RaveCards debe sentirse como:

- un juego social ligero,
- un pequeño coleccionable de la noche,
- una herramienta con identidad propia,
- y una experiencia claramente temporal.

No debe sentirse como:

- una app corporativa,
- una red social genérica,
- ni un clon de plataformas existentes con estética neón.

La restricción es parte del valor.

---

## Prototipo visual original

El archivo `index.html` es el prototipo visual que estableció la estética rave del proyecto (tarjeta animada, fondo oscuro, neón, foto circular, QR). Se conserva como referencia estética histórica. El producto real está en `ravecards/` y `functions/`.

---

## Estructura del repositorio

```
ravecards/                  App Flutter (Android) — Clean Architecture + BLoC
functions/                  Cloud Functions (TypeScript, Node.js 20) — 10 funciones
firestore.rules             Reglas de seguridad Firestore
storage.rules               Reglas de seguridad Storage
firestore.indexes.json      Índices compuestos
docs/superpowers/
  specs/                    Spec de diseño V1
  plans/                    4 planes de implementación (históricos)
index.html                  Prototipo visual original (referencia estética)
CLAUDE.md                   Guía de producto + guía técnica para agentes
```

---

## Documentos importantes

- **`CLAUDE.md`** — Guía completa para agentes: filosofía de producto + guía técnica de replicación. Leer primero.
- **`docs/superpowers/specs/2026-04-07-ravecards-v1-design.md`** — Spec técnico de V1 (con notas post-implementación).
- **`docs/superpowers/plans/`** — 4 planes de implementación detallados (históricos, no modificar).

---

## Reglas de interpretación para agentes y colaboradores

Cualquier agente, diseñador o desarrollador que trabaje sobre este repositorio debe respetar estas ideas:

1. **RaveCards no es una red social clásica.**
2. **El encuentro físico es obligatorio en la lógica del producto.**
3. **El escaneo cruzado es una mecánica central, no opcional.**
4. **La caducidad forma parte de la identidad del producto.**
5. **El objetivo no es maximizar retención, sino resolver muy bien un momento específico.**
6. **El prototipo visual actual es referencia estética, no limitación tecnológica absoluta.**
7. **No se debe añadir descubrimiento de usuarios, feed o persistencia social sin una decisión explícita de producto.**

---

## Riesgos a validar en campo

Con la V1 construida, estos son los riesgos a validar en pruebas reales:

### 1. Fluidez del escaneo cruzado
¿Funciona de verdad en condiciones reales de fiesta?

### 2. Comprensión del modelo efímero
¿La gente entiende y acepta bien que el vínculo desaparezca?

### 3. Valor real frente a Instagram
¿Se siente realmente más fácil y natural que pedir una red social?

### 4. Seguridad mínima usable
¿Revocar, bloquear y reportar se sienten accesibles y suficientes?

---

## Señal cultural de éxito

La señal más fuerte de encaje no será una vanity metric vacía.

La señal potente será que la gente empiece a decir algo como:

> “Pásame tu RaveCard.”

Si el nombre entra en lenguaje cotidiano dentro del contexto de uso, hay identidad de producto real.

---

## Resumen corto

**RaveCards** es una app social efímera para fiestas que permite conectar con personas conocidas en persona mediante tarjetas temporales con QR, escaneo cruzado mutuo, chat temporal y caducidad total del vínculo.

La V1 MVP está completa y lista para validación en campo.
