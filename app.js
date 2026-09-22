const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
const motionButton = document.querySelector('#motion');
let motionPaused = reducedMotion.matches;
function updateMotion() {
  document.documentElement.classList.toggle('motion-paused', motionPaused);
  motionButton.setAttribute('aria-pressed', String(motionPaused));
  motionButton.textContent = motionPaused ? 'Activar movimiento' : 'Pausar movimiento';
}
updateMotion();
if (!reducedMotion.matches) document.body.classList.add('js-motion');
const observer = new IntersectionObserver(entries => entries.forEach(entry => {
  if (entry.isIntersecting) { entry.target.classList.add('visible'); observer.unobserve(entry.target); }
}), { threshold: 0.08 });
document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
motionButton.addEventListener('click', () => { motionPaused = !motionPaused; updateMotion(); });
reducedMotion.addEventListener('change', event => { motionPaused = event.matches; updateMotion(); });

// A quiet original generative ambient score. Audio only starts on user interaction.
const soundButton = document.querySelector('#sound');
const soundLabel = document.querySelector('#sound-label');
let audioContext, master, audioTimer, playing = false, chordIndex = 0;
const chords = [[130.81,164.81,196,246.94],[110,130.81,164.81,196],[87.31,130.81,174.61,220],[98,146.83,196,246.94]];
function playChord() {
  if (!playing) return;
  const now = audioContext.currentTime;
  const notes = chords[chordIndex++ % chords.length];
  notes.forEach((frequency, index) => {
    const voice = audioContext.createOscillator();
    const envelope = audioContext.createGain();
    voice.type = 'sine'; voice.frequency.value = frequency;
    envelope.gain.setValueAtTime(0, now);
    envelope.gain.linearRampToValueAtTime(0.085, now + 2.8);
    envelope.gain.exponentialRampToValueAtTime(0.0001, now + 9);
    voice.connect(envelope); envelope.connect(master);
    voice.start(now + index * 0.12); voice.stop(now + 9.1);
    voice.onended = () => { voice.disconnect(); envelope.disconnect(); };
  });
  audioTimer = window.setTimeout(playChord, 6500);
}
async function stopAudio() {
  playing = false; clearTimeout(audioTimer);
  soundButton.setAttribute('aria-pressed', 'false'); soundLabel.textContent = 'Activar ambiente';
  if (audioContext) { const old = audioContext; audioContext = null; await old.close(); }
}
soundButton.addEventListener('click', async () => {
  soundButton.disabled = true;
  try {
    if (playing) { await stopAudio(); return; }
    const AudioEngine = window.AudioContext || window.webkitAudioContext;
    if (!AudioEngine) throw new Error('Audio unavailable');
    audioContext = new AudioEngine(); master = audioContext.createGain();
    master.gain.value = 0.22; master.connect(audioContext.destination);
    await audioContext.resume(); playing = true; chordIndex = 0; playChord();
    soundButton.setAttribute('aria-pressed', 'true'); soundLabel.textContent = 'Pausar ambiente';
  } catch { await stopAudio(); soundLabel.textContent = 'Audio no disponible'; }
  finally { soundButton.disabled = false; }
});

// The collection becomes an accessible, manually controlled colour specimen book.
// Without JavaScript the complete photographic gallery remains available.
const atelier = document.querySelector('#coleccion');
const specimens = [...atelier.querySelectorAll('.piece')];
const swatchNav = atelier.querySelector('.swatch-navigation');
const swatchList = atelier.querySelector('.swatch-tabs');
const specimenTones = [
  ['#f5d4dd', '#851b39'], ['#c3e5e6', '#104b54'],
  ['#e7b1a9', '#44242b'], ['#f1c5a3', '#183965'],
  ['#f1ecb9', '#55501d'], ['#d6e1d6', '#214c40']
];
let selectedSpecimen = 0;
const swatches = specimens.map((piece, index) => {
  const name = piece.querySelector('h3').textContent;
  const image = piece.querySelector('img');
  const tab = document.createElement('button');
  tab.type = 'button'; tab.className = 'swatch-tab';
  tab.id = `colour-${index}`; tab.setAttribute('role', 'tab');
  tab.setAttribute('aria-label', name); tab.setAttribute('title', name);
  tab.setAttribute('aria-controls', `specimen-${index}`);
  const thumbnail = document.createElement('img');
  thumbnail.src = image.getAttribute('src'); thumbnail.alt = '';
  thumbnail.width = 32; thumbnail.height = 40;
  const number = document.createElement('span');
  number.textContent = String(index + 1).padStart(2, '0');
  number.setAttribute('aria-hidden', 'true'); tab.append(thumbnail, number);
  piece.id = `specimen-${index}`; piece.setAttribute('role', 'tabpanel');
  piece.setAttribute('aria-labelledby', tab.id);
  piece.classList.remove('reveal');
  piece.querySelector('.piece-info').dataset.number = number.textContent;
  tab.addEventListener('click', () => selectSpecimen(index));
  tab.addEventListener('keydown', event => {
    const keys = ['ArrowRight', 'ArrowLeft', 'Home', 'End'];
    if (!keys.includes(event.key)) return;
    event.preventDefault();
    const next = event.key === 'Home' ? 0 : event.key === 'End' ? specimens.length - 1 : (index + (event.key === 'ArrowRight' ? 1 : -1) + specimens.length) % specimens.length;
    selectSpecimen(next); swatches[next].focus();
  });
  swatchList.append(tab); return tab;
});
function selectSpecimen(index) {
  selectedSpecimen = index;
  specimens.forEach((piece, position) => {
    piece.hidden = position !== index;
    piece.classList.toggle('arriving', position === index && !motionPaused && !reducedMotion.matches);
    swatches[position].setAttribute('aria-selected', String(position === index));
    swatches[position].tabIndex = position === index ? 0 : -1;
  });
  atelier.style.setProperty('--atelier-bg', specimenTones[index][0]);
  atelier.style.setProperty('--atelier-ink', specimenTones[index][1]);
  document.querySelector('#swatch-current').textContent = String(index + 1).padStart(2, '0');
}
swatchNav.hidden = false;
atelier.classList.add('atelier-ready');
selectSpecimen(0);

// Touch, mouse and keyboard share the same explicit detail-view control.
document.querySelectorAll('.craft-details figure').forEach(figure => {
  const img = figure.querySelector('img');
  const control = document.createElement('button');
  control.type = 'button'; control.className = 'texture-window';
  control.setAttribute('aria-pressed', 'false');
  control.setAttribute('aria-label', 'Ampliar: ' + img.alt);
  img.before(control); control.append(img);
  const caption = document.createElement('span'); caption.textContent = 'Explorar el punto +';
  caption.setAttribute('aria-hidden', 'true'); control.append(caption);
  control.addEventListener('click', () => {
    const zoomed = control.getAttribute('aria-pressed') !== 'true';
    control.setAttribute('aria-pressed', String(zoomed));
    control.setAttribute('aria-label', (zoomed ? 'Reducir: ' : 'Ampliar: ') + img.alt);
    caption.textContent = zoomed ? 'Volver a la pieza −' : 'Explorar el punto +';
    control.style.setProperty('--zoom-x', '50%'); control.style.setProperty('--zoom-y', '50%');
  });
  control.addEventListener('pointermove', event => {
    if (motionPaused || reducedMotion.matches || event.pointerType !== 'mouse' || control.getAttribute('aria-pressed') !== 'true') return;
    const rect = control.getBoundingClientRect();
    control.style.setProperty('--zoom-x', `${(event.clientX - rect.left) / rect.width * 100}%`);
    control.style.setProperty('--zoom-y', `${(event.clientY - rect.top) / rect.height * 100}%`);
  });
});

// One continuous line, drawn by normal page scrolling; no scroll interception.
const mainSurface = document.querySelector('main');
const threadSvg = document.querySelector('.signature-thread');
const threadInk = threadSvg.querySelector('.thread-ink');
const interlude = document.querySelector('.thread-interlude');
let threadHeight = 1, mainTop = 0, interludeTop = 0, queuedThreadFrame = false;
function measureThread() {
  const width = mainSurface.clientWidth;
  threadHeight = mainSurface.offsetHeight;
  mainTop = mainSurface.getBoundingClientRect().top + window.scrollY;
  interludeTop = interlude.offsetTop;
  const left = width * .025, right = width * .975;
  const crossing = interlude.offsetTop + interlude.offsetHeight - 10;
  const universeTop = document.querySelector('#universo').offsetTop;
  const path = `M ${left} 30 C ${left+18} 100 ${left-14} 190 ${left} 260 L ${left} ${crossing-45} C ${left} ${crossing+10} ${width*.22} ${crossing} ${width*.40} ${crossing} C ${width*.67} ${crossing} ${right} ${crossing-40} ${right} ${crossing+55} L ${right} ${universeTop-40} C ${right} ${universeTop+15} ${width*.92} ${universeTop+24} ${width*.93} ${universeTop-5} C ${width*.94} ${universeTop-40} ${right} ${universeTop-5} ${right} ${universeTop+55} L ${right} ${threadHeight-65}`;
  threadSvg.setAttribute('viewBox', `0 0 ${width} ${threadHeight}`);
  threadSvg.querySelectorAll('path').forEach(line => line.setAttribute('d', path));
  updateThread();
}
function updateThread() {
  queuedThreadFrame = false;
  if (motionPaused || reducedMotion.matches) {
    threadInk.style.strokeDashoffset = '0'; interlude.style.removeProperty('--interlude-shift'); return;
  }
  const progress = Math.max(0, Math.min(1, (window.scrollY + window.innerHeight * .9 - mainTop) / threadHeight));
  threadInk.style.strokeDashoffset = String(1 - progress);
  const shift = Math.max(-18, Math.min(18, (window.scrollY - mainTop - interludeTop + window.innerHeight * .5) * .04));
  interlude.style.setProperty('--interlude-shift', `${shift}px`);
}
function queueThread() { if (!queuedThreadFrame) { queuedThreadFrame = true; requestAnimationFrame(updateThread); } }
window.addEventListener('scroll', queueThread, {passive:true});
window.addEventListener('resize', measureThread);
window.addEventListener('load', measureThread);
motionButton.addEventListener('click', updateThread);
reducedMotion.addEventListener('change', updateThread);
new ResizeObserver(measureThread).observe(mainSurface);
measureThread();
document.addEventListener('visibilitychange', () => { if (document.hidden && playing) stopAudio(); });

const dialog = document.querySelector('#order-dialog');
const orderForm = document.querySelector('#order-form');
let chosenPiece = '', previousFocus;
document.querySelectorAll('[data-piece]').forEach(button => button.addEventListener('click', () => {
  previousFocus = button; chosenPiece = button.dataset.piece;
  document.querySelector('#selected-piece').textContent = chosenPiece;
  document.querySelector('#order-status').textContent = '';
  orderForm.reset(); dialog.showModal();
}));
document.querySelector('.close').addEventListener('click', () => dialog.close());
dialog.addEventListener('click', event => {
  const box = dialog.getBoundingClientRect();
  if (event.target === dialog && (event.clientX < box.left || event.clientX > box.right || event.clientY < box.top || event.clientY > box.bottom)) dialog.close();
});
dialog.addEventListener('close', () => previousFocus?.focus());
orderForm.addEventListener('submit', async event => {
  event.preventDefault();
  const data = new FormData(orderForm);
  const summary = `MI IDEA PARA MONEG\n\nPieza: ${chosenPiece}\nColores: ${String(data.get('color')).trim() || 'Por decidir'}\nDetalles: ${String(data.get('idea')).trim() || 'Por definir con la artesana'}\n\nBorrador personal: no es un pedido confirmado. El precio, la disponibilidad, las medidas y el plazo deben acordarse con la artesana.\n`;
  try {
    await navigator.clipboard.writeText(summary);
    document.querySelector('#order-status').textContent = 'Idea copiada. Abre Instagram y pégala en un mensaje a @moneg_crochet.';
  } catch {
  const url = URL.createObjectURL(new Blob([summary], { type: 'text/plain;charset=utf-8' }));
  const link = document.createElement('a'); link.href = url; link.download = 'mi-idea-moneg.txt';
  document.body.append(link); link.click(); link.remove(); setTimeout(() => URL.revokeObjectURL(url), 1000);
  document.querySelector('#order-status').textContent = 'No se pudo copiar. Hemos preparado un archivo con tu idea para que puedas enviarla por Instagram.';
  }
});
