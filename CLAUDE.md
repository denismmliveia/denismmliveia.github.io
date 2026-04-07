# Rave Card — Guía técnica

Tarjeta de presentación digital de uso social. Un solo archivo HTML autocontenido, sin dependencias externas, publicable en GitHub Pages.

**Archivo de producción:** `index.html` (~400 KB con foto embebida)  
**URL publicada:** `https://denismmliveia.github.io/`  
**Foto fuente:** `img/IMG-20260221-WA0040.jpg`

---

## Arquitectura

**Un solo archivo** — HTML + CSS + JS inline. Sin build, sin npm, sin servidor.

**Foto:** Embebida como data URL base64 directamente en el atributo `src` del `<img>`. Hace el archivo grande (~400 KB) pero completamente autónomo.

**QR code:** Librería qrcodejs (~20 KB) minificada e incrustada inline en el `<script>`. Genera el QR a partir de `CARD.card_url` al cargar la página.

**Datos:** Objeto `CARD` al principio del script. Para cambiar contenido, solo tocar ese objeto.

---

## Design tokens

```css
:root {
  --bg:     #06000f;   /* fondo negro-púrpura profundo */
  --purple: #b300ff;   /* acento neón — bordes, labels, glow */
  --green:  #39ff14;   /* valores de campos, status dot */
  --white:  #ffffff;   /* nombre / texto principal */
}
```

Para cambiar la paleta, editar estos 4 valores en `:root`. Todo lo demás usa variables.

---

## Objeto CARD — datos configurables

```js
var CARD = {
  name:        "DENIS",
  tagline:     "Techno Enthusiast · 2026",
  genero_fav:  "Hard Techno",
  orientacion: "TODO",          // rellenar antes de publicar
  estado:      "TODO",          // rellenar antes de publicar
  card_url:    "https://denismmliveia.github.io/"
};
```

El HTML se rellena con `document.getElementById` al cargar. Para añadir un campo: añadir propiedad al objeto + `<span id="nuevo">` en el HTML + línea `document.getElementById('nuevo').textContent = CARD.nuevo`.

---

## Layout

```
.card (max-width: 420px, centrado)
├── .bg-grid          ← grid de líneas CSS (decorativo, pointer-events: none)
├── .bg-glow          ← radial-gradient púrpura (decorativo, pointer-events: none)
├── .top-bar          ← "RAVE CARD" + "● Online"
├── .photo-wrap > img ← 104×104px circular, border + glow púrpura
├── .name             ← nombre uppercase, text-shadow neón
├── .tagline          ← subtítulo pequeño
├── .fields           ← lista de campos
│   └── .field (×N)  ← label + value, barra izquierda púrpura (::before)
├── .divider          ← línea gradiente
└── .qr-section
    ├── .qr-label
    └── #qr-container ← QR generado por qrcodejs, o .qr-placeholder si URL es TODO
```

---

## Efectos visuales

### Status dot (pulso continuo)
```css
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } }
.status-dot { animation: pulse 2s infinite; }
```

### Boot sequence (aparición al cargar)
```css
@keyframes bootIn {
  from { opacity: 0; transform: translateY(8px); }
  to   { opacity: 1; transform: translateY(0); }
}
/* Cada elemento tiene animation-delay diferente */
.bg-grid    { opacity: 0; animation: bootIn 0.5s 0.1s  ease forwards; }
.top-bar    { opacity: 0; animation: bootIn 0.4s 0.3s  ease forwards; }
.photo-wrap { opacity: 0; animation: bootIn 0.5s 0.5s  ease forwards; }
.name       { opacity: 0; animation: bootIn 0.4s 0.7s  ease forwards; }
/* ... etc */
```

La clave es `animation-fill-mode: forwards` (via `ease forwards`) para que queden visibles al terminar.

### Glow en foto
```css
box-shadow: 0 0 20px rgba(179,0,255,0.5), 0 0 48px rgba(179,0,255,0.2);
```

### Grid de fondo
```css
background-image:
  linear-gradient(rgba(179,0,255,0.06) 1px, transparent 1px),
  linear-gradient(90deg, rgba(179,0,255,0.06) 1px, transparent 1px);
background-size: 28px 28px;
```

---

## Accesibilidad

```css
@media (prefers-reduced-motion: reduce) {
  .status-dot { animation: none; opacity: 1; }
  .bg-grid, .bg-glow, .top-bar, .photo-wrap, .name, .tagline,
  .fields .field, .divider, .qr-section {
    animation: none; opacity: 1;
  }
}
```

Siempre añadir `pointer-events: none` a `.bg-grid` y `.bg-glow` — sin esto bloquean los clics.

---

## Embeber la foto como base64

```python
import base64
with open('img/foto.jpg', 'rb') as f:
    data = base64.b64encode(f.read()).decode()
src = 'data:image/jpeg;base64,' + data
# Pegar src en el atributo src del <img id="photo">
```

O desde bash:
```bash
python -c "
import base64
with open('img/foto.jpg','rb') as f: d=base64.b64encode(f.read()).decode()
print('data:image/jpeg;base64,'+d)
" > foto_b64.txt
```

---

## QR code — qrcodejs

La librería qrcodejs (MIT, ~20 KB minificada) se pega inline en el `<script>`. Uso:

```js
// Guard: solo genera QR si la URL está definida
if (CARD.card_url.indexOf('TODO') === -1) {
  document.getElementById('qr-container').innerHTML = '';
  new QRCode(document.getElementById('qr-container'), {
    text:         CARD.card_url,
    width:        96,
    height:       96,
    colorDark:    '#ffffff',   // blanco sobre fondo oscuro — contraste 20.7:1
    colorLight:   '#06000f',
    correctLevel: QRCode.CorrectLevel.M
  });
}
```

Si `card_url` contiene "TODO", se muestra `.qr-placeholder` con texto "URL pendiente".

Fuente del minificado: `https://github.com/davidshimjs/qrcodejs` — pegar el contenido de `qrcode.min.js` inline antes del código de la tarjeta.

---

## Publicación en GitHub Pages

```bash
# 1. Crear repo público en GitHub (ej: usuario.github.io o rave-card)
git remote add origin https://github.com/USUARIO/REPO.git
git branch -m master main   # si la rama local es master
git push -u origin main

# Si el repo ya tiene commits (README creado por GitHub):
git pull origin main --allow-unrelated-histories --strategy-option=ours
git push origin main
```

En GitHub: **Settings → Pages → Branch: main → / (root) → Save**

URL resultante:
- Repo `usuario.github.io` → `https://usuario.github.io/`
- Repo `rave-card` → `https://usuario.github.io/rave-card/`

---

## Adaptar a otro tema/persona

Para hacer una tarjeta diferente (festival, gaming, networking):

1. **Paleta** — cambiar los 4 tokens en `:root`
2. **Foto** — embeber nueva imagen como base64
3. **Objeto CARD** — cambiar name, tagline, campos y sus labels
4. **card_url** — URL de la nueva publicación
5. **Campos extra** — añadir propiedades en CARD + `<div class="field">` en HTML + línea JS
6. **Eliminar campos** — borrar la fila `.field` del HTML (el JS es tolerante a IDs inexistentes)

Los efectos (boot sequence, glow, grid) son independientes del contenido — funcionan sin tocar CSS.

---

## Checklist antes de publicar

- [ ] `CARD.orientacion` con valor real (no "TODO")
- [ ] `CARD.estado` con valor real (no "TODO")
- [ ] `CARD.card_url` con URL definitiva
- [ ] QR visible y escaneable en móvil
- [ ] Boot sequence visible al recargar
- [ ] Sin scroll horizontal en 375px
- [ ] Funciona offline (sin conexión a internet)
