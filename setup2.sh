cat > index.html <<'WAVES_DONE'
<!doctype html>
<html lang="en"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>…waves</title>
<meta name="theme-color" content="#f4f2ec">
<link rel="manifest" href="./manifest.webmanifest">
<link rel="icon" href="./icons/icon-192.png">
<link rel="apple-touch-icon" href="./icons/icon-192.png">
<style>
@font-face{font-family:Jost;src:url('./fonts/Jost-400.woff') format('woff');font-weight:400;font-display:swap}
@font-face{font-family:'JetBrains Mono';src:url('./fonts/JetBrainsMono-400.woff2') format('woff2');font-weight:400;font-display:swap}
@font-face{font-family:'JetBrains Mono';src:url('./fonts/JetBrainsMono-700.woff2') format('woff2');font-weight:700;font-display:swap}
</style>
<style>
/* ── skins (the Seeds set); Minimal is the default, like Thunder ───────────── */
:root{
  --w-bg:#f4f2ec; --w-panel:#fffdf7; --w-line:#dcd7c8; --w-text:#2b2a26; --w-dim:#7c7768;
  --w-audio:#2f6fed; --w-cv:#a78bfa; --w-gate:#d99b1f;
  --w-font:Jost,system-ui,sans-serif; --w-mono:'JetBrains Mono',ui-monospace,monospace;
}
body[data-skin="pastel"]{--w-bg:#eef1f7;--w-panel:#fff;--w-line:#d3dae8;--w-text:#232838;--w-dim:#6b7590}
body[data-skin="minimal-colors"]{--w-bg:#f4f2ec;--w-panel:#fffdf7;--w-line:#dcd7c8;--w-text:#2b2a26;--w-dim:#7c7768}
body[data-skin="monotone"]{--w-bg:#e8e8e8;--w-panel:#f5f5f5;--w-line:#cfcfcf;--w-text:#1c1c1c;--w-dim:#666;--w-audio:#4a4a4a;--w-cv:#7a7a7a;--w-gate:#8f8f8f}
body[data-skin="minimal-black"]{--w-bg:#111214;--w-panel:#181a1e;--w-line:#2b2f36;--w-text:#e9eaec;--w-dim:#8b93a1;--w-audio:#5b9bff;--w-cv:#b79bff;--w-gate:#e0ad3c}
body[data-skin="minimal-colors-black"]{--w-bg:#111214;--w-panel:#181a1e;--w-line:#2b2f36;--w-text:#e9eaec;--w-dim:#8b93a1;--w-audio:#ff6b6b;--w-cv:#60e0a0;--w-gate:#ffd23f}
body[data-skin="neon"]{--w-bg:#0d0f14;--w-panel:#141821;--w-line:#232a38;--w-text:#d7e0ff;--w-dim:#6f7ea3;--w-audio:#31e0ff;--w-cv:#c08bff;--w-gate:#ffd23f}

*{box-sizing:border-box}
html,body{height:100%}
body{margin:0;background:var(--w-bg);color:var(--w-text);font-family:var(--w-font);
  display:flex;flex-direction:column;overscroll-behavior:none;touch-action:manipulation}
.mono,kbd{font-family:var(--w-mono)}
.spacer{flex:1}

/* ── top bar + menus ──────────────────────────────────────────────────────── */
.bar{display:flex;align-items:center;gap:4px;padding:5px 8px;border-bottom:1px solid var(--w-line);position:relative;z-index:20}
.bar button{font:400 12px var(--w-font);color:var(--w-text);background:transparent;border:0;padding:5px 9px;border-radius:7px;cursor:pointer}
.bar button:hover{background:color-mix(in srgb,var(--w-line) 50%,transparent)}
.menu-pop{position:absolute;top:100%;left:8px;z-index:30;background:var(--w-panel);border:1px solid var(--w-line);
  border-radius:10px;box-shadow:0 8px 24px rgba(0,0,0,.12);padding:5px;min-width:232px;max-height:70vh;overflow:auto}
.menu-pop button{display:block;width:100%;text-align:left}
.menu-pop .mg{font:600 10px var(--w-font);text-transform:uppercase;letter-spacing:.08em;color:var(--w-dim);padding:8px 9px 3px}
.menu-pop .mi{display:flex;align-items:center;gap:8px;padding:6px 9px;font-size:12px}
.menu-pop hr{border:0;border-top:1px solid var(--w-line);margin:5px 0}

/* ── module cards ─────────────────────────────────────────────────────────── */
.mod{position:absolute;width:172px;background:var(--w-panel);border:1px solid var(--w-line);
  border-radius:10px;box-shadow:0 1px 2px rgba(0,0,0,.05);pointer-events:auto}
.mod-t{display:flex;align-items:center;gap:6px;padding:6px 8px;border-bottom:1px solid var(--w-line);cursor:grab}
.mod-caret{width:6px;height:6px;border-right:1.5px solid var(--w-line);border-bottom:1.5px solid var(--w-line);transform:rotate(45deg)}
.mod-name{font-size:12px;flex:1}
.mod-note{font-family:var(--w-mono);font-size:9px;color:var(--w-dim)}
.mod.collapsed .mod-b{display:none}
.row{display:flex;align-items:center;gap:6px;padding:4px 8px}
.row-out{justify-content:flex-end;min-height:14px}
.jack{width:11px;height:11px;padding:0;border-radius:50%;border:2px solid currentColor;background:var(--w-panel);cursor:crosshair}
.jack--audio{color:var(--w-audio)} .jack--cv{color:var(--w-cv)} .jack--gate{color:var(--w-gate)}
.jack--mod{width:7px;height:7px;border-width:1.5px;opacity:.85}
.ctl{display:grid;grid-template-columns:8px 1fr 52px 30px;align-items:center;gap:5px;padding:2px 8px;font-size:10px}
.ctl-n{color:var(--w-dim);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.ctl-n.cc{color:var(--w-cv)}
.ctl-s{-webkit-appearance:none;appearance:none;height:2px;background:var(--w-line);outline:none}
.ctl-s::-webkit-slider-thumb{-webkit-appearance:none;width:11px;height:11px;border-radius:50%;background:var(--w-text);cursor:pointer}
.ctl-v{font-family:var(--w-mono);font-size:9px;text-align:right;color:var(--w-dim)}
.mod.selected{outline:2px solid var(--w-audio);outline-offset:1px}
.mod-meter{display:block;width:100%;height:5px;border-radius:3px;background:var(--w-line);overflow:hidden}
.mod-meter i{display:block;height:100%;background:var(--w-audio);transform-origin:left;transform:scaleX(0)}

/* ── canvas ───────────────────────────────────────────────────────────────── */
.patch{position:relative;flex:1;overflow:hidden;background:var(--w-bg);touch-action:none;user-select:none;-webkit-user-select:none}
.patch .cables,.patch .groups,.patch .mods{position:absolute;inset:0;transform-origin:0 0}
.patch .cables{overflow:visible;pointer-events:none}
.cable{fill:none;stroke-width:2.5;stroke-linecap:round}
.cable--temp{stroke-dasharray:5 4;opacity:.85}
.cable-hit{fill:none;stroke:transparent;stroke-width:16;pointer-events:stroke}
.patch .mods{pointer-events:none}
.group{position:absolute;border:1.5px dashed;border-radius:16px;pointer-events:none}
.group .group-n{position:absolute;top:-9px;left:12px;font:600 10px var(--w-font);background:var(--w-bg);padding:0 6px;text-transform:uppercase;letter-spacing:.08em}

/* ── status bar ───────────────────────────────────────────────────────────── */
.status{display:flex;align-items:center;gap:12px;padding:4px 10px;border-top:1px solid var(--w-line);
  font-size:10px;color:var(--w-dim);min-height:26px}
.cpu.gold{color:#b8860b}.cpu.red{color:#b3261e}
.meters{display:flex;gap:4px}
.meters .b{width:14px;height:8px;border-radius:2px;background:var(--w-line);position:relative;overflow:hidden}
.meters .b i{position:absolute;inset:0;transform-origin:left;background:var(--w-audio);transform:scaleX(0)}
.toast{position:fixed;left:50%;bottom:44px;transform:translateX(-50%);background:var(--w-panel);
  border:1px solid var(--w-line);border-radius:9px;padding:8px 13px;font-size:12px;
  box-shadow:0 6px 20px rgba(0,0,0,.14);z-index:60;max-width:88vw}
.touchkeys{display:flex;gap:3px}
.touchkeys button{font:600 11px var(--w-mono);padding:7px 0;width:30px;border:1px solid var(--w-line);
  background:var(--w-panel);color:var(--w-text);border-radius:6px}
@media (pointer:coarse){
  .jack{width:16px;height:16px}.jack--mod{width:11px;height:11px}
  .row{padding:7px 10px}.ctl{padding:4px 10px}.mod{width:196px}.bar button{padding:8px 12px}
}
</style>
</head><body>

<header id="bar" class="bar"></header>
<main id="patch" class="patch" tabindex="0"></main>
<div id="status" class="status">
  <span id="cpu" class="cpu">CPU –</span>
  <span id="vcount" class="mono">0 voices</span>
  <span class="spacer"></span>
  <span id="meters" class="meters"></span>
  <span id="touchkeys" class="touchkeys" hidden></span>
</div>
<div id="toast" class="toast" hidden></div>

<template id="t-module">
  <section class="mod" tabindex="0">
    <header class="mod-t"><span class="mod-caret"></span><span class="mod-name"></span><span class="mod-note"></span></header>
    <div class="mod-b"><div class="row row-out"></div><div class="row row-in"></div><div class="row row-ctl"></div></div>
  </section>
</template>

<script type="module">
/* ═══════════════════════════════════════════════════════════════════════════
   …waves — the app. The audio engine lives in waves-worklet.js; this file is
   the patching UI, the patch document, persistence and MIDI.
   NOTE: the declarative MODULES table below mirrors waves-worklet.js. Add a
   module to both when you add one.
   ═══════════════════════════════════════════════════════════════════════════ */

const PROTOCOL = 1, TARGET = 'waves', BUS_COUNT = 8;
const OP = { patch:'patch', add:'add', remove:'remove', connect:'connect', disconnect:'disconnect',
  params:'params', quality:'quality', transport:'transport', telemetry:'telemetry',
  noteOn:'noteOn', noteOff:'noteOff', panic:'panic',
  ready:'ready', meter:'meter', shed:'shed', error:'error' };

/* Declarative mirror of the engine's modules (inputs/outputs/params only). */
const MODULES = {
  hostIn:{ type:'hostIn', label:'Host In', scope:'poly',
    inputs:{}, outputs:{ pitch:'cv', gate:'gate', vel:'cv' },
    params:{ transpose:[0,-48,48,1] } },
  vco:{ type:'vco', label:'VCO', scope:'poly',
    inputs:{ pitch:'cv', fm:'cv' }, outputs:{ out:'audio' },
    params:{ wave:[1,0,3,1], tune:[0,-24,24,1], fine:[0,-100,100,1] } },
  lfo:{ type:'lfo', label:'LFO', scope:'mono',
    inputs:{ reset:'gate' }, outputs:{ out:'cv' },
    params:{ rate:[1,.02,40,.01], sync:[0,0,1,1], shape:[0,0,2,1] } },
  adsr:{ type:'adsr', label:'ADSR', scope:'poly',
    inputs:{ gate:'gate' }, outputs:{ out:'cv' },
    params:{ a:[.01,0,4,.001], d:[.2,0,4,.001], s:[.7,0,1,.001], r:[.3,0,8,.001] } },
  vca:{ type:'vca', label:'VCA', scope:'poly',
    inputs:{ in:'audio', cv:'cv' }, outputs:{ out:'audio' },
    params:{ gain:[1,0,4,.01] } },
  vcf:{ type:'vcf', label:'VCF', scope:'poly',
    inputs:{ in:'audio', cutoff:'cv' }, outputs:{ out:'audio' },
    params:{ cutoff:[.5,0,1,.001], res:[.3,0,1,.001], mode:[0,0,2,1] } },
  plaits:{ type:'plaits', label:'Plaits', scope:'poly',
    inputs:{ pitch:'cv', gate:'gate', timbre:'cv', morph:'cv' },
    outputs:{ out:'audio', aux:'audio' },
    params:{ engine:[8,0,23,1], harmonics:[.5,0,1,.01], timbre:[.5,0,1,.01], morph:[.5,0,1,.01], decay:[.5,0,1,.01] } },
  out:{ type:'out', label:'Out', scope:'mono',
    inputs:{ in:'audio' }, outputs:{},
    params:{ slot:[1,1,BUS_COUNT,1], level:[1,0,2,.01] } }
};

/* ── UI helpers ──────────────────────────────────────────────────────────── */
let _toastTimer = 0;
function toast(msg, ms = 2800) {
  const t = document.getElementById('toast');
  t.textContent = msg; t.hidden = false;
  clearTimeout(_toastTimer);
  _toastTimer = setTimeout(() => { t.hidden = true; }, ms);
}
function setCpu(load, quality) {
  const el = document.getElementById('cpu');
  el.textContent = `CPU ${Math.round(load * 100)}%${quality === 'draft' ? ' · draft' : ''}`;
  el.classList.toggle('gold', load > .5 && load <= .8);
  el.classList.toggle('red', load > .8);
}
function setVoices(n, quality) {
  document.getElementById('vcount').textContent =
    `${n} voice${n === 1 ? '' : 's'}${quality === 'draft' ? ' · draft' : ''}`;
}
let _meters = null;
function initMeters(count = BUS_COUNT) {
  const host = document.getElementById('meters'); host.innerHTML = ''; _meters = [];
  for (let k = 0; k < count; k++) {
    const b = document.createElement('div'); b.className = 'b';
    b.title = `Out ${k + 1} / Waves In ${k + 1}`;
    b.innerHTML = '<i></i>'; host.append(b); _meters.push(b.querySelector('i'));
  }
}
function setBus(k, peak) {
  const m = _meters?.[k - 1]; if (m) m.style.transform = `scaleX(${Math.min(1, peak)})`;
}
const KEYS_LOWER = ['z','s','x','d','c','v','g','b','h','n','j','m',',','l','.',';','/'];
const KEYS_UPPER = ['q','2','w','3','e','r','5','t','6','y','7','u','i','9','o','0','p'];
function wireKeyboard(bridge) {
  let octave = 0; const held = new Map();
  const pitchOf = k => { const i = KEYS_LOWER.indexOf(k), j = KEYS_UPPER.indexOf(k);
                         return i >= 0 ? i : j >= 0 ? 12 + j : -1; };
  addEventListener('keydown', e => {
    if (e.repeat || e.metaKey || e.ctrlKey) return;
    if (e.key === '-' || e.key === '=') { octave += e.key === '=' ? 1 : -1; toast(`Octave ${octave + 4}`); return; }
    const p = pitchOf(e.key); if (p < 0 || held.has(e.key)) return;
    const pitch = p + octave * 12; held.set(e.key, pitch); bridge.noteOn(pitch, 1);
  });
  addEventListener('keyup', e => {
    const pitch = held.get(e.key); if (pitch == null) return;
    held.delete(e.key); bridge.noteOff(pitch);
  });
  addEventListener('blur', () => { for (const p of held.values()) bridge.noteOff(p); held.clear(); });
}
function showTouchKeyboard(bridge) {
  const host = document.getElementById('touchkeys'); host.hidden = false; host.innerHTML = '';
  const names = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B','C'];
  for (let i = 0; i < 13; i++) {
    const b = document.createElement('button'); b.textContent = names[i]; b.dataset.pitch = i;
    const on = e => { e.preventDefault(); b.dataset.on = '1'; bridge.noteOn(i, 1); };
    const off = () => { if (b.dataset.on) { delete b.dataset.on; bridge.noteOff(i); } };
    b.addEventListener('pointerdown', on);
    addEventListener('pointerup', off); b.addEventListener('pointerleave', off);
    host.append(b);
  }
}
function showHelp() {
  toast('Drag an output jack to an input jack to patch. Every slider has a purple jack for '
      + 'modulation. Option-drag a cable to bend it; double-click a cable to remove it, or a '
      + 'module title to collapse. Shift-click to select, right-click to group. Drag the '
      + 'background to pan, pinch or Cmd-wheel to zoom.');
}

/* ── skins ───────────────────────────────────────────────────────────────── */
const SKINS = ['minimal','pastel','minimal-colors','monotone','minimal-black','minimal-colors-black','neon'];
const SKIN_KEY = 'waves.skin';
function applySkin(name) {
  if (!SKINS.includes(name)) name = 'minimal';
  document.body.dataset.skin = name;
  try { localStorage.setItem(SKIN_KEY, name); } catch {}
  return name;
}
function currentSkin() { try { return localStorage.getItem(SKIN_KEY) || 'minimal'; } catch { return 'minimal'; } }
function cycleSkin() { return applySkin(SKINS[(SKINS.indexOf(currentSkin()) + 1) % SKINS.length]); }

/* ── module cards ────────────────────────────────────────────────────────── */
const CardHooks = { onParam: () => {}, onGestureStart: () => {}, learn: null };

function renderCard(doc, def, mod) {
  const el = document.getElementById('t-module').content.firstElementChild.cloneNode(true);
  el.dataset.id = mod.id;
  el.querySelector('.mod-name').textContent = mod.label || def.label;
  if (def.type === 'hostIn') el.querySelector('.mod-note').textContent = 'Keyboard / MIDI';
  if (def.type === 'out') {
    el.querySelector('.mod-note').textContent = `Waves In ${mod.params.slot}`;
    el.querySelector('.mod-b').insertAdjacentHTML('beforeend',
      '<div class="row"><span class="mod-meter"><i></i></span></div>');
  }
  const rout = el.querySelector('.row-out');
  for (const [name, kind] of Object.entries(def.outputs)) rout.append(makeJack(mod.id, name, kind, 'out'));
  const rin = el.querySelector('.row-in');
  for (const [name, kind] of Object.entries(def.inputs)) rin.append(makeJack(mod.id, name, kind, 'in'));
  const rctl = el.querySelector('.row-ctl');
  for (const [name, spec] of Object.entries(def.params)) rctl.append(makeSlider(mod, name, spec));
  return el;
}
function makeJack(id, port, kind, dir) {
  const j = document.createElement('button');
  j.className = `jack jack--${kind} jack--${dir}`;
  Object.assign(j.dataset, { id, port, kind });
  j.title = port;
  return j;
}
function makeSlider(mod, name, spec) {
  const [def, min, max, step] = spec;
  const v = mod.params[name] ?? def;
  const wrap = document.createElement('label');
  wrap.className = 'ctl'; wrap.dataset.id = mod.id; wrap.dataset.port = name;
  wrap.innerHTML =
    `<button class="jack jack--cv jack--in jack--mod" data-id="${mod.id}" data-port="${name}"
             data-kind="cv" title="${name} modulation"></button>
     <span class="ctl-n">${name}</span>
     <input class="ctl-s" type="range" min="${min}" max="${max}" step="${step}" value="${v}">
     <output class="ctl-v">${(+v).toFixed(2)}</output>`;
  const input = wrap.querySelector('.ctl-s'), out = wrap.querySelector('.ctl-v');
  input.addEventListener('pointerdown', () => {
    CardHooks.onGestureStart();
    CardHooks.learn?.arm({ id: mod.id, name });
  });
  input.addEventListener('input', () => {
    const n = parseFloat(input.value);
    mod.params[name] = n; out.textContent = n.toFixed(2);
    CardHooks.onParam(mod.id, name, n);
  });
  return wrap;
}
function paintCc(el, learn) {
  const name = el.dataset.port, cc = learn?.ccFor(el.dataset.id, name);
  const label = el.querySelector('.ctl-n');
  label.textContent = cc == null ? name : `${name} · CC${cc}`;
  label.classList.toggle('cc', cc != null);
}
function paintAllCc(learn) { for (const el of document.querySelectorAll('.ctl')) paintCc(el, learn); }

/* ── patch store: autosave, backups, undo, files ─────────────────────────── */
const STORE_KEY = 'waves.patch', BAK_KEY = 'waves.backups', MAX_BAK = 10;
class PatchStore {
  constructor(doc, onRestore) {
    this.doc = doc; this.onRestore = onRestore || (() => {});
    this.undo = []; this.redo = []; this._timer = 0; this.dirty = false;
  }
  snapshot() {
    this.undo.push(JSON.stringify(this.doc));
    if (this.undo.length > 100) this.undo.shift();
    this.redo.length = 0; this._schedule();
  }
  back() { if (!this.undo.length) return false;
    this.redo.push(JSON.stringify(this.doc)); this._restore(this.undo.pop()); return true; }
  forward() { if (!this.redo.length) return false;
    this.undo.push(JSON.stringify(this.doc)); this._restore(this.redo.pop()); return true; }
  _restore(json) { Object.assign(this.doc, JSON.parse(json)); this.onRestore(this.doc); this._schedule(); }
  touch() { this._schedule(); }
  _schedule() { this.dirty = true; clearTimeout(this._timer);
    this._timer = setTimeout(() => this.save(), 1200); }
  save() {
    if (!this.dirty) return;
    try {
      const baks = JSON.parse(localStorage.getItem(BAK_KEY) || '[]');
      baks.push({ t: Date.now(), p: localStorage.getItem(STORE_KEY) || 'null' });
      while (baks.length > MAX_BAK) baks.shift();
      localStorage.setItem(BAK_KEY, JSON.stringify(baks));
      this.doc.meta.modified = Math.floor(Date.now() / 1000);
      localStorage.setItem(STORE_KEY, JSON.stringify(this.doc));
      this.dirty = false;
    } catch {}
  }
  static open() { try { return JSON.parse(localStorage.getItem(STORE_KEY) || 'null'); } catch { return null; } }
  static backups() { try { return JSON.parse(localStorage.getItem(BAK_KEY) || '[]'); } catch { return []; } }
  export(name) {
    const blob = new Blob([JSON.stringify(this.doc, null, 2)], { type: 'application/json' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = (name || this.doc.meta.name || 'patch') + '.waves.json';
    a.click(); URL.revokeObjectURL(a.href); this.dirty = false;
  }
  async import(file) {
    const d = JSON.parse(await file.text());
    if (d.format !== 'waves.patch') throw new Error('Not a …waves patch');
    Object.assign(this.doc, d); this.onRestore(this.doc); this._schedule();
  }
  exportCustom() {
    const blob = new Blob([JSON.stringify({ format:'waves.custom', custom:this.doc.custom }, null, 2)],
      { type:'application/json' });
    const a = document.createElement('a'); a.href = URL.createObjectURL(blob);
    a.download = 'custom-modules.json'; a.click(); URL.revokeObjectURL(a.href);
  }
  async importCustom(file) {
    const d = JSON.parse(await file.text());
    if (d.format !== 'waves.custom') throw new Error('Not a …waves custom-module file');
    this.doc.custom.push(...d.custom); this._schedule();
  }
  /* The one Thunder-facing line — deferred until integration. */
  embedInto(project) { project.waves = JSON.parse(JSON.stringify(this.doc)); }
  static fromThunder(project) { return project.waves || null; }
}

/* ── MIDI learn ──────────────────────────────────────────────────────────── */
const LEARN_KEY = 'waves.midi';
class MidiLearn {
  constructor(getRange) {
    try { this.map = JSON.parse(localStorage.getItem(LEARN_KEY)) || {}; } catch { this.map = {}; }
    this.armed = null;
    this.getRange = getRange || (() => ({ min: 0, max: 1 }));
    this.onChange = () => {};
  }
  _save() { try { localStorage.setItem(LEARN_KEY, JSON.stringify(this.map)); } catch {} }
  arm(ref) { this.armed = ref; this.onChange(); }
  cancel() { this.armed = null; this.onChange(); }
  handle({ cc, value }, bridge) {
    if (this.armed) {
      this.map[cc] = { id: this.armed.id, name: this.armed.name };
      this.armed = null; this._save(); this.onChange();
      return { learned: cc };
    }
    const t = this.map[cc]; if (!t) return {};
    const r = this.getRange(t.id, t.name);
    bridge.setParam(t.id, t.name, r.min + (value / 127) * (r.max - r.min));
    return { applied: true };
  }
  ccFor(id, name) {
    for (const [cc, t] of Object.entries(this.map))
      if (t.id === id &&