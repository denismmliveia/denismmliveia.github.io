# RaveCards

**RaveCards** es una app social efímera para fiestas, raves, clubs y festivales.

Su objetivo es facilitar el intercambio de contacto entre personas que **se han conocido físicamente**, usando **tarjetas temporales con QR** y una mecánica de **escaneo cruzado**. Si ambas personas se escanean mutuamente dentro de una ventana breve, se activa un **chat temporal 1 a 1**. Cuando el tiempo expira, el vínculo desaparece y solo queda un **recuerdo mínimo** del encuentro.

RaveCards **no** intenta sustituir WhatsApp, Instagram ni una red social tradicional. Está pensada para resolver bien un momento muy concreto: **conectar con alguien que acabas de conocer en un entorno de fiesta, de forma rápida, ligera y poco invasiva**.

---

## Estado actual del repositorio

Este repositorio **no contiene todavía la aplicación completa**.

Hoy contiene principalmente:

- un **prototipo visual fundacional** en `index.html`,
- documentación de producto y dirección del proyecto,
- y material de referencia para mantener la identidad visual y conceptual de RaveCards.

El `index.html` actual representa la **Rave Card** como pieza visual base: una tarjeta animada con estética rave, foto, campos de identidad expresivos y un QR visible. Esa pieza sirve como referencia de tono, atmósfera e interacción, pero **no representa aún el sistema completo de producto**.

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

### Funcionalidades núcleo previstas

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

## El prototipo visual actual

El archivo `index.html` contiene el **prototipo visual fundacional** del proyecto.

Su papel es:

- fijar la atmósfera visual,
- consolidar la estética rave / techno,
- establecer el tono de la tarjeta,
- y servir como artefacto de referencia para el diseño futuro.

### Qué muestra hoy el prototipo

- una tarjeta con fondo oscuro,
- acentos neón,
- animaciones de entrada,
- foto circular,
- nombre,
- tagline,
- campos de identidad social,
- y un QR visible generado a partir de `card_url`.

### Qué no representa todavía

El HTML actual **no implementa todavía**:

- escaneo cruzado real,
- validación backend,
- estados de vínculo,
- chat temporal funcional,
- caducidad sistémica,
- seguridad real,
- ni comportamiento multiusuario.

Es una referencia visual, no la aplicación terminada.

---

## Estructura esperada del proyecto

La estructura irá evolucionando, pero conceptualmente este repositorio se apoya en tres capas:

### 1. Identidad visual
La tarjeta, el tono visual, la atmósfera y la experiencia sensorial.

### 2. Reglas de producto
La lógica del sistema:

- quién puede conectar,
- cuándo,
- bajo qué condiciones,
- durante cuánto tiempo,
- y qué sobrevive tras expirar.

### 3. Implementación técnica
La futura app real con:

- backend,
- tokens/QR dinámicos,
- validación temporal,
- chat,
- moderación,
- y gestión de estados.

---

## Documentos importantes del repositorio

### `README.md`
Puerta de entrada al proyecto.
Explica qué es RaveCards, qué contiene hoy el repo y hacia dónde va.

### `CLAUDE.md`
Guía para agentes o asistentes que trabajen sobre el proyecto.
Debe proteger la identidad del producto y evitar que el desarrollo derive hacia una red social genérica o una reinterpretación incorrecta del prototipo.

### `index.html`
Prototipo visual fundacional.
No debe confundirse con la arquitectura definitiva del producto.

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

## Riesgos principales a validar

Antes de entrar fuerte en desarrollo, hay que validar sobre todo esto:

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

## Siguientes pasos recomendados

Antes de construir a lo loco, el orden correcto es:

1. cerrar la **definición funcional del MVP**,
2. definir el **flujo de experiencia pantalla por pantalla**,
3. fijar reglas exactas de estados, expiración y moderación,
4. preparar un **plan de validación en contexto real**,
5. y solo después planificar arquitectura y desarrollo.

---

## Resumen corto

**RaveCards** es una app social efímera para fiestas que permite conectar con personas conocidas en persona mediante tarjetas temporales con QR, escaneo cruzado mutuo, chat temporal y caducidad total del vínculo.

El repositorio actual contiene el **prototipo visual fundacional** y la base documental del producto, no la aplicación final.
