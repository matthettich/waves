cat > waves-worklet.js <<'WAVES_DONE'
/* ═══ …waves audio engine + worklet ═══
   Self-contained, no imports. Standalone, this file is both engine and worklet.
   In Thunder, the WavesEngine class is instantiated inside Thunder's processor
   instead and this wrapper is dropped — that's the whole integration seam.

   Two AudioWorklets cannot share buffers without SharedArrayBuffer (needs
   COOP/COEP, which GitHub Pages can't send), so engine-as-a-class is mandatory. */

const BLOCK = 128, BUS_COUNT = 8, PROTOCOL = 1, TARGET = 'waves';

/* ── module definitions ─────────────────────────────────────────────────────
   create(sr) → state.  process(state, io, ctx) renders one BLOCK.
   io.in[name]/io.out[name] are Float32Array(BLOCK); io.p = live params.
   scope 'poly' → one state per voice · scope 'mono' → one state total.        */

const HostIn = {
  type:'hostIn', label:'Host In', scope:'poly',
  inputs:{}, outputs:{ pitch:'cv', gate:'gate', vel:'cv' },
  params:{ transpose:[0,-48,48,1] },
  create:()=>({}),
  process(st,io,ctx){
    const n=ctx.notes[ctx.voice], tr=io.p.transpose, on=n&&n.gate>0;
    for(let i=0;i<ctx.block;i++){
      io.out.pitch[i]=on?n.pitch+tr:0; io.out.gate[i]=on?1:0; io.out.vel[i]=on?n.vel:0;
    }
  }
};

const VCO = {
  type:'vco', label:'VCO', scope:'poly', cost:1,
  inputs:{ pitch:'cv', fm:'cv' }, outputs:{ out:'audio' },
  params:{ wave:[1,0,3,1], tune:[0,-24,24,1], fine:[0,-100,100,1] },
  create:()=>({ phase:Math.random() }),
  process(st,io,ctx){
    const v=Math.pow(2,(io.p.tune+io.p.fine/100)/12), w=io.p.wave|0;
    for(let i=0;i<ctx.block;i++){
      const hz=261.6256*v*Math.pow(2,(io.in.pitch[i]+io.in.fm[i])/12);
      st.phase+=hz/ctx.sr; st.phase-=Math.floor(st.phase);
      const t=st.phase;
      io.out.out[i]= w===0?2*t-1 : w===1?(t<.5?1:-1) : w===2?4*Math.abs(t-.5)-1 : Math.sin(2*Math.PI*t);
    }
  }
};

const LFO = {
  type:'lfo', label:'LFO', scope:'mono', cost:.3,
  inputs:{ reset:'gate' }, outputs:{ out:'cv' },
  params:{ rate:[1,.02,40,.01], sync:[0,0,1,1], shape:[0,0,2,1] },
  create:()=>({ phase:0 }),
  process(st,io,ctx){
    const hz=io.p.sync?(ctx.transport.tempo/60)*io.p.rate*.25:io.p.rate;
    for(let i=0;i<ctx.block;i++){
      if(io.in.reset[i]>.5) st.phase=0;
      st.phase+=hz/ctx.sr; st.phase-=Math.floor(st.phase);
      const t=st.phase;
      io.out.out[i]= io.p.shape===1?(t<.5?1:-1) : io.p.shape===2?t : Math.sin(2*Math.PI*t);
    }
  }
};

const ADSR = {
  type:'adsr', label:'ADSR', scope:'poly', cost:.2,
  inputs:{ gate:'gate' }, outputs:{ out:'cv' },
  params:{ a:[.01,0,4,.001], d:[.2,0,4,.001], s:[.7,0,1,.001], r:[.3,0,8,.001] },
  create:()=>({ stage:0, level:0 }),
  process(st,io,ctx){
    const {a,d,s,r}=io.p, dt=1/ctx.sr;
    for(let i=0;i<ctx.block;i++){
      const g=io.in.gate[i]>.5;
      if(g&&st.stage===0) st.stage=1;
      if(!g&&st.stage!==0&&st.stage!==4) st.stage=4;
      if(st.stage===1){ st.level+=dt/Math.max(a,1e-4); if(st.level>=1){st.level=1;st.stage=2;} }
      else if(st.stage===2) st.level+=(s-st.level)*dt/Math.max(d,1e-4)*6;
      else if(st.stage===4){ st.level-=dt/Math.max(r,1e-4)*6; if(st.level<=0){st.level=0;st.stage=0;} }
      io.out.out[i]=st.level;
    }
  }
};

const VCA = {
  type:'vca', label:'VCA', scope:'poly', cost:.2,
  inputs:{ in:'audio', cv:'cv' }, outputs:{ out:'audio' },
  params:{ gain:[1,0,4,.01] },
  create:()=>({}),
  process(st,io,ctx){ const g=io.p.gain;
    for(let i=0;i<ctx.block;i++) io.out.out[i]=io.in.in[i]*io.in.cv[i]*g; }
};

const VCF = {
  type:'vcf', label:'VCF', scope:'poly', cost:1,
  inputs:{ in:'audio', cutoff:'cv' }, outputs:{ out:'audio' },
  params:{ cutoff:[.5,0,1,.001], res:[.3,0,1,.001], mode:[0,0,2,1] },
  create:()=>({ ic1:0, ic2:0 }),
  process(st,io,ctx){
    const mode=io.p.mode|0, q=1-io.p.res*.95;
    for(let i=0;i<ctx.block;i++){
      const fc=Math.min(.45,(.01+Math.pow(10,io.p.cutoff*3)*.004)*Math.pow(2,io.in.cutoff[i]*3));
      const f=2*Math.sin(Math.PI*fc);
      const hp=io.in.in[i]-st.ic2-q*st.ic1;
      const bp=f*hp+st.ic1; st.ic1=f*hp+bp;
      const lp=f*bp+st.ic2; st.ic2=f*bp+lp;
      io.out.out[i]= mode===0?lp : mode===1?bp : hp;
    }
  }
};

/* Heavy WASM voice — silent until dsp/waves.wasm exists. */
const Plaits = {
  type:'plaits', label:'Plaits', scope:'poly', cost:4, draftSkip:true,
  inputs:{ pitch:'cv', gate:'gate', timbre:'cv', morph:'cv' },
  outputs:{ out:'audio', aux:'audio' },
  params:{ engine:[8,0,23,1], harmonics:[.5,0,1,.01], timbre:[.5,0,1,.01], morph:[.5,0,1,.01], decay:[.5,0,1,.01] },
  create:()=>({ h: globalThis.WAVES_WASM ? globalThis.WAVES_WASM.new(0) : -1 }),
  process(st,io,ctx){
    const w=globalThis.WAVES_WASM;
    if(!w||st.h<0||ctx.quality==='draft'){ io.out.out.fill(0); io.out.aux.fill(0); return; }
    w.render(st.h,io,io.p,ctx.block);
  }
};

const Out = {
  type:'out', label:'Out', scope:'mono', cost:.05,
  inputs:{ in:'audio' }, outputs:{},
  params:{ slot:[1,1,BUS_COUNT,1], level:[1,0,2,.01] },
  create:()=>({}),
  process(st,io,ctx){
    const k=(io.p.slot|0)-1, g=io.p.level;
    const bus=ctx.buses.subarray(k*BLOCK,(k+1)*BLOCK);
    for(let i=0;i<ctx.block;i++) bus[i]+=io.in.in[i]*g;
  }
};

const MODULES={ hostIn:HostIn, vco:VCO, lfo:LFO, adsr:ADSR, vca:VCA, vcf:VCF, plaits:Plaits, out:Out };

/* ── voices ───────────────────────────────────────────────────────────────── */
class VoicePool{
  constructor(max){ this.max=max; this.clock=0; this.rows=[];
    for(let i=0;i<max;i++) this.rows.push({pitch:0,gate:0,vel:0,age:0}); }
  on(pitch,vel){
    let i=this.rows.findIndex(r=>r.gate===0);
    if(i<0) i=this.rows.reduce((a,r,j)=>r.age<this.rows[a].age?j:a,0);
    const r=this.rows[i]; r.pitch=pitch; r.gate=1; r.vel=vel; r.age=++this.clock; return i;
  }
  off(pitch){ for(const r of this.rows) if(r.gate&&r.pitch===pitch) r.gate=0; }
  allOff(){ for(const r of this.rows) r.gate=0; }
}

class Graph{
  constructor(){ this.mods=new Map(); this.cables=[]; this.order=[]; }
  add(id,def,inst){ this.mods.set(id,{id,def,inst}); this.compile(); }
  remove(id){ this.mods.delete(id);
    this.cables=this.cables.filter(c=>c.a[0]!==id&&c.b[0]!==id); this.compile(); }
  connect(a,b){ this.cables.push({a,b}); this.compile(); }
  disconnect(a,b){ this.cables=this.cables.filter(c=>
    !(c.a[0]===a[0]&&c.a[1]===a[1]&&c.b[0]===b[0]&&c.b[1]===b[1])); this.compile(); }
  compile(){
    const indeg=new Map([...this.mods.keys()].map(k=>[k,0]));
    const adj=new Map([...this.mods.keys()].map(k=>[k,[]]));
    for(const c of this.cables){ adj.get(c.a[0]).push(c.b[0]); indeg.set(c.b[0],indeg.get(c.b[0])+1); }
    const q=[...indeg].filter(([,d])=>d===0).map(([k])=>k), order=[];
    while(q.length){ const k=q.shift(); order.push(k);
      for(const n of adj.get(k)){ indeg.set(n,indeg.get(n)-1); if(indeg.get(n)===0) q.push(n); } }
    for(const k of this.mods.keys()) if(!order.includes(k)) order.push(k);
    this.order=order;
  }
}

/* ── the engine ───────────────────────────────────────────────────────────── */
class WavesEngine{
  constructor(sampleRate,opts={}){
    this.sr=sampleRate; this.hosted=!!opts.hosted;
    this.transport=Object.assign({tempo:120,lpb:4,ticks:6,ppq:0,playing:false},opts.transport||{});
    this.quality=opts.quality||'full';
    this.costCeiling=opts.costCeiling??.85;
    this.voices=new VoicePool(opts.maxVoices??8);
    this.graph=new Graph();
    this.buses=new Float32Array(BUS_COUNT*BLOCK);
    this.load=0; this.telemetryOn=false;
    this._ios=new Map(); this._states=new Map();
    this._ctx={sr:sampleRate,block:BLOCK,quality:this.quality,transport:this.transport,
               buses:this.buses,notes:this.voices.rows,voice:0};
  }
  addModule(id,type,o={}){
    const def=MODULES[type]; if(!def) return;
    const inst={ scope:def.scope, pos:o.pos||[0,0],
      params:Object.fromEntries(Object.entries(def.params).map(([k,v])=>[k,o.params?.[k]??v[0]])) };
    this.graph.add(id,def,inst); this._reset();
  }
  removeModule(id){ this.graph.remove(id); this._reset(); }
  connect(a,b){ this.graph.connect(a,b); this._reset(); }
  disconnect(a,b){ this.graph.disconnect(a,b); this._reset(); }
  setParam(id,name,v){ const m=this.graph.mods.get(id); if(m) m.inst.params[name]=v; }
  setParams(list){ for(const [id,name,v] of list) this.setParam(id,name,v); }
  setTransport(t){ Object.assign(this.transport,t); }
  _reset(){ this._ios.clear(); this._states.clear(); }
  loadPatch(doc){
    this.graph=new Graph(); this._reset();
    for(const m of doc.modules) this.addModule(m.id,m.type,m);
    for(const c of doc.cables) this.connect(c.from,c.to);
    if(doc.transport) this.setTransport(doc.transport);
    return {modules:doc.modules.length,cables:doc.cables.length};
  }
  noteOn(p,vel=1){ this.voices.on(p,vel); }
  noteOff(p){ this.voices.off(p); }
  allNotesOff(){ this.voices.allOff(); }
  process(frames=BLOCK){
    const t0=typeof performance!=='undefined'?performance.now():0;
    this.buses.fill(0); this._render(frames);
    if(t0) this._tickLoad(performance.now()-t0,frames);
  }
  processHost(frames=BLOCK){ this.process(frames); }
  bus(slot){ return this.buses.subarray((slot-1)*BLOCK,slot*BLOCK); }

  _bufs(m,v){
    const key=m.id+(v>=0?'#'+v:'');
    let io=this._ios.get(key);
    if(!io){
      io={in:{},out:{},p:m.inst.params};
      for(const n in m.def.inputs) io.in[n]=new Float32Array(BLOCK);
      for(const n in m.def.outputs) io.out[n]=new Float32Array(BLOCK);
      this._ios.set(key,io);
    }
    return io;
  }
  _state(m,v){
    const key=m.id+(m.inst.scope==='poly'?'#'+v:'');
    let s=this._states.get(key);
    if(!s){ s=m.def.create(this.sr); this._states.set(key,s); }
    return s;
  }
  _sumInputs(m,io,v,frames){
    for(const k in io.in) io.in[k].fill(0);
    for(const c of this.graph.cables){
      if(c.b[0]!==m.id) continue;
      const src=this.graph.mods.get(c.a[0]); if(!src) continue;
      const dst=io.in[c.b[1]]; if(!dst) continue;
      if(v>=0){
        const b=this._bufs(src,src.inst.scope==='poly'?v:-1).out[c.a[1]];
        if(b) for(let i=0;i<frames;i++) dst[i]+=b[i];
      } else if(src.inst.scope==='poly'){
        for(let vv=0;vv<this.voices.max;vv++){
          const b=this._bufs(src,vv).out[c.a[1]];
          if(b) for(let i=0;i<frames;i++) dst[i]+=b[i];
        }
      } else {
        const b=this._bufs(src,-1).out[c.a[1]];
        if(b) for(let i=0;i<frames;i++) dst[i]+=b[i];
      }
    }
  }
  /* Poly modules run per voice; mono modules run once and read the SUM of the
     voices feeding them (that's how Out sums a poly patch). Mono → poly arrives
     one block (~2.7 ms) late — inaudible for modulation. */
  _render(frames){
    const ctx=this._ctx;
    ctx.block=frames; ctx.quality=this.quality; ctx.buses=this.buses;
    ctx.notes=this.voices.rows; ctx.transport=this.transport;
    for(let v=0;v<this.voices.max;v++){
      ctx.voice=v;
      for(const id of this.graph.order){
        const m=this.graph.mods.get(id);
        if(m.inst.scope!=='poly') continue;
        const io=this._bufs(m,v);
        this._sumInputs(m,io,v,frames);
        m.def.process(this._state(m,v),io,ctx);
      }
    }
    ctx.voice=0;
    for(const id of this.graph.order){
      const m=this.graph.mods.get(id);
      if(m.inst.scope!=='mono') continue;
      const io=this._bufs(m,-1);
      this._sumInputs(m,io,-1,frames);
      m.def.process(this._state(m,0),io,ctx);
    }
  }
  _tickLoad(ms,frames){
    const blockMs=(frames/this.sr)*1000;
    this.load=this.load*.9+(ms/blockMs)*.1;
    if(this.load>this.costCeiling) this._shed();
  }
  _shed(){
    let step=0;
    if(this.voices.max>4){ this.voices.max--; this._reset(); step=1; }
    else if(this.quality==='full'){ this.quality='draft'; step=2; }
    else { this.allNotesOff(); step=3; }
    if(this.onShed) this.onShed({step,voices:this.voices.max,quality:this.quality});
  }
  telemetry(){
    let active=0; for(const r of this.voices.rows) if(r.gate) active++;
    let cost=0;
    for(const m of this.graph.mods.values()) cost+=(m.inst.scope==='poly'?this.voices.max:1)*(m.def.cost||1);
    const buses=[];
    for(let k=1;k<=BUS_COUNT;k++){
      const b=this.bus(k); let peak=0;
      for(let i=0;i<BLOCK;i++){ const a=b[i]<0?-b[i]:b[i]; if(a>peak) peak=a; }
      buses.push(peak);
    }
    return {load:this.load,active,cost,quality:this.quality,buses};
  }
  handleMessage(m){
    switch(m.op){
      case 'patch': return this.loadPatch(m.value);
      case 'add': return this.addModule(m.id,m.type,m);
      case 'remove': return this.removeModule(m.id);
      case 'connect': return this.connect(m.a,m.b);
      case 'disconnect': return this.disconnect(m.a,m.b);
      case 'param': return this.setParam(m.id,m.name,m.value);
      case 'params': return this.setParams(m.list);
      case 'quality': this.quality=m.value; return;
      case 'transport': return this.setTransport(m.value);
      case 'telemetry': this.telemetryOn=!!m.value; return;
      case 'noteOn': return this.noteOn(m.pitch,m.vel);
      case 'noteOff': return this.noteOff(m.pitch);
      case 'panic': return this.allNotesOff();
    }
  }
}

/* ── protocol ─────────────────────────────────────────────────────────────── */
const OP={ patch:'patch', add:'add', remove:'remove', connect:'connect', disconnect:'disconnect',
  params:'params', quality:'quality', transport:'transport', telemetry:'telemetry',
  noteOn:'noteOn', noteOff:'noteOff', panic:'panic',
  ready:'ready', meter:'meter', shed:'shed', error:'error' };

/* ── optional WASM voices ─────────────────────────────────────────────────── */
const WavesWasm={
  async load(url='./dsp/waves.wasm'){
    const bytes=await (await fetch(url)).arrayBuffer();
    const {instance}=await WebAssembly.instantiate(bytes,{});
    return new WavesWasm(instance.exports);
  },
  new(type){ return this.ex.w_new(type); },
  init(sr){ this.ex.w_init(sr); },
  render(h,io,p,n){
    const b=this.ex.memory.buffer, f32=ptr=>new Float32Array(b,ptr,n);
    if(io.in.pitch) f32(this.ex.w_pitch()).set(io.in.pitch);
    if(io.in.gate) f32(this.ex.w_gate()).set(io.in.gate);
    this.ex.w_set(h,0,p.harmonics); this.ex.w_set(h,1,p.timbre);
    this.ex.w_set(h,2,p.morph); this.ex.w_set(h,3,p.decay); this.ex.w_set(h,4,p.engine);
    this.ex.w_render(h,n);
    io.out.out.set(f32(this.ex.w_out()));
    if(io.out.aux) io.out.aux.set(f32(this.ex.w_aux()));
  }
};

/* ── the worklet wrapper ──────────────────────────────────────────────────── */
class WavesProcessor extends AudioWorkletProcessor{
  constructor(options){
    super();
    const o=options.processorOptions||{};
    this.engine=new WavesEngine(sampleRate,{
      hosted:false, maxVoices:o.maxVoices??8, quality:o.quality??'full',
      transport:{tempo:120,lpb:4,ticks:6,playing:false}
    });
    this.engine.onShed=info=>this.port.postMessage({target:TARGET,op:OP.shed,value:info});
    this._blocks=0;
    this.port.onmessage=e=>this._recv(e.data);
    this.port.postMessage({target:TARGET,op:OP.ready,
      value:{protocol:PROTOCOL,sr:sampleRate,block:BLOCK,wasm:false}});
    this._loadWasm(o.wasmUrl||'./dsp/waves.wasm');
  }
  async _loadWasm(url){
    try{
      const w=await WavesWasm.load(url);
      w.init(sampleRate); globalThis.WAVES_WASM=w;
      this.port.postMessage({target:TARGET,op:OP.ready,
        value:{protocol:PROTOCOL,sr:sampleRate,block:BLOCK,wasm:true}});
    }catch{ /* no wasm yet — the JS modules still work */ }
  }
  _recv(m){
    if(!m||(m.target&&m.target!==TARGET)) return;
    try{ this.engine.handleMessage(m); }
    catch(err){ this.port.postMessage({target:TARGET,op:OP.error,
      value:{op:m.op,message:String(err?.message||err)}}); }
  }
  process(_ins,outs){
    this.engine.process(BLOCK);
    const out=outs[0], bus=this.engine.bus(1);
    if(out[0]) out[0].set(bus);
    if(out[1]) out[1].set(bus);
    if(this.engine.telemetryOn&&(++this._blocks%24)===0)
      this.port.postMessage({target:TARGET,op:OP.meter,value:this.engine.telemetry()});
    return true;
  }
}
registerProcessor('waves',WavesProcessor);
WAVES_DONE
echo "waves-worklet.js created"