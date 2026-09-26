// Original deterministic layered SFX, no downloaded/licensed source material.
const fs = require('fs');
const path = require('path');
const dest = path.join(__dirname, '../assets/audio/sfx/abilities/king');
fs.mkdirSync(dest, {recursive: true});
const sr = 44100;
let seed = 729271;
function noise() { seed = (Math.imul(seed, 1664525)+1013904223)>>>0; return seed/2147483648-1; }
function render(name, length, synth) {
  let low=0, last=0, high=0;
  const data=new Float64Array(Math.ceil(sr*length)); let peak=0, sum=0;
  for(let i=0;i<data.length;i++) {
    const t=i/sr, n=noise(); low+=(n-low)*.065; high+=(n-high)*.4;
    // Gentle DC removal, short cosine edge fades and bounded amplitude.
    let v=synth(t,n,low,high)*Math.min(1,t/.006)*Math.min(1,(length-t)/.045);
    last+=.002*(v-last); v-=last; data[i]=v; peak=Math.max(peak,Math.abs(v));
  }
  const out=Buffer.alloc(44+data.length*2); out.write('RIFF');out.writeUInt32LE(out.length-8,4);out.write('WAVEfmt ',8);
  out.writeUInt32LE(16,16);out.writeUInt16LE(1,20);out.writeUInt16LE(1,22);out.writeUInt32LE(sr,24);out.writeUInt32LE(sr*2,28);
  out.writeUInt16LE(2,32);out.writeUInt16LE(16,34);out.write('data',36);out.writeUInt32LE(data.length*2,40);
  for(let i=0;i<data.length;i++){const v=data[i]/peak*.78; sum+=v*v;out.writeInt16LE(Math.round(v*32767),44+i*2);}
  fs.writeFileSync(path.join(dest,`worldsplitter_${name}.wav`),out);
  console.log(`${name}: ${length}s, peak -2.16dBFS, RMS ${(20*Math.log10(Math.sqrt(sum/data.length))).toFixed(1)}dBFS`);
}
const tau=2*Math.PI;
render('gather',.46,(t,n,l,h)=> {
  const e=Math.sin(Math.PI*Math.min(1,t/.46))**1.6;
  return e*(l*.32 + Math.sin(tau*(240*t+110*t*t))*.04 + Math.sin(tau*361*t)*.022);
});
render('descent',.43,(t,n,l,h)=>{
  const e=Math.sin(Math.PI*Math.min(1,t/.43))**1.3;
  return e*(h*.6+l*.55+Math.sin(tau*(180*t-100*t*t))*.06);
});
render('contact',.68,(t,n,l,h)=>{
  const body=Math.sin(tau*(76*t+1.7*(1-Math.exp(-25*t))))*Math.exp(-9*t)*.7;
  const crack=(h-l)*Math.exp(-43*t)*.43;
  const stone=l*Math.exp(-7*t)*.65;
  return body+crack+stone;
});
render('rupture',.94,(t,n,l,h)=>{
  let chips=0;
  for(const onset of [.028,.081,.143,.231,.342]) { const a=t-onset; if(a>0)chips+=(h-l)*Math.exp(-55*a)*.12; }
  return Math.sin(tau*(56*t+1.0*(1-Math.exp(-19*t))))*Math.exp(-6*t)*.45+l*Math.exp(-4.8*t)*.7+chips;
});

// Soft spectral fragments, deliberately quieter than the grounded contact.
render('light_shards',.48,(t,n,l,h)=>{
 let glass=0;
 for(const [f,a,d] of [[1240,.09,18],[1860,.055,24],[2790,.025,31],[930,.05,14]]) {glass+=Math.sin(tau*f*t)*a*Math.exp(-d*t);}
 return glass+(h-l)*.045*Math.exp(-20*t);
});
