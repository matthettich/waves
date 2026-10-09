cat > manifest.webmanifest <<'WAVES_DONE'
{
  "name": "...waves",
  "short_name": "waves",
  "description": "A modular synthesizer: patch modules together to build your own voices.",
  "start_url": "./",
  "scope": "./",
  "display": "standalone",
  "orientation": "any",
  "background_color": "#f4f2ec",
  "theme_color": "#f4f2ec",
  "icons": [
    { "src": "icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "icons/icon-512.png", "sizes": "512x512", "type": "image/png" },
    { "src": "icons/icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ]
}
WAVES_DONE

cat > sw.js <<'WAVES_DONE'
/* …waves offline support. The page is fetched fresh when online (so updates
   show up) and served from cache when offline. Bump CACHE whenever you change
   waves-worklet.js, or installed clients keep the old engine. */
const CACHE = 'waves-v11';
const FILES = ['./', './index.html', './manifest.webmanifest', './waves-worklet.js', './dsp/thunder-dsp.wasm', './dsp/tfx.wasm',
  './icons/icon-192.png', './icons/icon-512.png', './icons/icon-maskable-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)));
  self.skipWaiting();
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks =>
    Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))));
  self.clients.claim();
});
self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  const isPage = req.mode === 'navigate' || url.pathname.endsWith('/index.html');
  if (isPage) {
    e.respondWith(fetch(req).then(res => {
      const copy = res.clone(); caches.open(CACHE).then(c => c.put('./index.html', copy));
      return res;
    }).catch(() => caches.match('./index.html')));
    return;
  }
  e.respondWith(caches.match(req).then(hit => hit || fetch(req).then(res => {
    if (res.ok && url.origin === location.origin) {
      const copy = res.clone(); caches.open(CACHE).then(c => c.put(req, copy));
    }
    return res;
  })));
});
WAVES_DONE

mkdir -p icons
cat > icons/icon.svg <<'WAVES_DONE'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <rect width="512" height="512" rx="112" fill="#f4f2ec"/>
  <g fill="none" stroke="#7FD1C6" stroke-width="20"
     stroke-linecap="round" stroke-linejoin="miter" stroke-miterlimit="4">
    <path d="M72 300 L136 136 L200 300 L264 136 L328 300 L392 136 L456 300"/>
    <path d="M72 372 l64-22 l64 22 l64-22 l64 22 l64-22 l64 22"/>
    <path d="M112 420 l64-22 l64 22 l64-22 l64 22 l64-22"/>
  </g>
</svg>
WAVES_DONE

cat > icons/make-icons.html <<'WAVES_DONE'
<!doctype html><html><head><meta charset="utf-8"><title>…waves icons</title>
<style>body{font:14px system-ui;padding:24px}canvas{border:1px solid #ddd;margin:8px;vertical-align:top}
a{display:block;margin:6px 0}</style></head><body>
<h1>…waves icons</h1><p>Click each, then put the files in <code>icons/</code>.</p><div id="out"></div>
<script>
const ART = `<g fill="none" stroke="#7FD1C6" stroke-width="20" stroke-linecap="round"
   stroke-linejoin="miter" stroke-miterlimit="4">
   <path d="M72 300 L136 136 L200 300 L264 136 L328 300 L392 136 L456 300"/>
   <path d="M72 372 l64-22 l64 22 l64-22 l64 22 l64-22 l64 22"/>
   <path d="M112 420 l64-22 l64 22 l64-22 l64 22 l64-22"/></g>`;
function svg(maskable){
  const frame = maskable ? '' : '<rect width="512" height="512" rx="112" fill="#f4f2ec"/>';
  const pad = maskable ? .12 : 0;
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
    <rect width="512" height="512" fill="#f4f2ec"/>${frame}
    <g transform="translate(${256*pad} ${256*pad}) scale(${1-pad*2})">${ART}</g></svg>`;
}
function make(size,name,maskable){
  const img=new Image();
  img.onload=()=>{ const c=document.createElement('canvas'); c.width=c.height=size;
    c.getContext('2d').drawImage(img,0,0,size,size);
    const a=document.createElement('a'); a.href=c.toDataURL('image/png'); a.download=name;
    a.textContent=`Download ${name} (${size}×${size})`;
    const box=document.createElement('div'); box.append(a,c); document.getElementById('out').append(box); };
  img.src='data:image/svg+xml;charset=utf-8,'+encodeURIComponent(svg(maskable));
}
make(192,'icon-192.png',false); make(512,'icon-512.png',false); make(512,'icon-maskable-512.png',true);
</script></body></html>
WAVES_DONE

cat > .gitignore <<'WAVES_DONE'
.DS_Store
electron/node_modules/
electron/dist/
electron/app/
WAVES_DONE

echo "support files created"