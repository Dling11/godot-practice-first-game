// Original deterministic ground-seam rustle and soft earth/wood release.
// No third-party samples; mono PCM, 44100 Hz, short edge fades, no runtime synth.
const fs = require('fs');
const path = require('path');
const rate = 44100, seconds = 0.5;
const samples = new Float64Array(Math.ceil(rate * seconds));
let seed = 17503, low = 0, dc = 0, peak = 0;
for (let i = 0; i < samples.length; i++) {
  const t = i / rate;
  seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
  const noise = seed / 2147483648 - 1;
  low += (noise - low) * 0.065;
  const rise = Math.sin(Math.PI * Math.min(1, t / 0.3)) ** 1.5;
  const hit = Math.max(0, t - 0.3);
  let v = low * rise * 0.38;
  if (t >= 0.3) v += Math.exp(-hit * 22) * (Math.sin(2 * Math.PI * (130 * hit - 90 * hit * hit)) * 0.24 + low * 0.5);
  v *= Math.min(1, t / 0.008) * Math.min(1, (seconds - t) / 0.045);
  dc += (v - dc) * 0.002;
  samples[i] = v - dc;
  peak = Math.max(peak, Math.abs(samples[i]));
}
const wav = Buffer.alloc(44 + samples.length * 2);
wav.write('RIFF'); wav.writeUInt32LE(wav.length - 8, 4); wav.write('WAVEfmt ', 8);
wav.writeUInt32LE(16, 16); wav.writeUInt16LE(1, 20); wav.writeUInt16LE(1, 22);
wav.writeUInt32LE(rate, 24); wav.writeUInt32LE(rate * 2, 28);
wav.writeUInt16LE(2, 32); wav.writeUInt16LE(16, 34);
wav.write('data', 36); wav.writeUInt32LE(samples.length * 2, 40);
let energy = 0;
for (let i = 0; i < samples.length; i++) {
  const v = samples[i] / peak * 0.65;
  energy += v * v;
  wav.writeInt16LE(Math.round(v * 32767), 44 + i * 2);
}
fs.writeFileSync(path.join(__dirname, '../assets/audio/sfx/enemy_arrival.wav'), wav);
console.log(`enemy_arrival.wav: 0.5s mono, peak -3.74dBFS, RMS ${(20 * Math.log10(Math.sqrt(energy / samples.length))).toFixed(2)}dBFS`);
