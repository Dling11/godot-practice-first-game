"""Original charge rhythm and red barrage release, with no external samples."""
from pathlib import Path
import json,wave
import numpy as np
from generate_examiner_rework_sfx import sound,RATE
OUT=Path(__file__).resolve().parents[1]/'assets/audio/sfx/characters/disciples/examiner/firmament'
OUT.mkdir(parents=True,exist_ok=True)
report={}
for i,(name,duration,pitch) in enumerate([('sun_gather',5.5,.78),('crimson_gather',3.8,.58),('crimson_release',.95,.42)]):
    signal=sound('rise' if i<2 else 'rupture',duration,140+i,pitch)*.65
    t=np.arange(len(signal))/RATE
    if i<2:
        progress=t/duration
        # Tension rises continuously, with accelerating struck-metal pulses.
        signal += .12*np.sin(2*np.pi*(75*t+13*t*t)) * np.sin(np.pi*progress)**.5
        beat=.3
        while beat<duration-.12:
            s=np.maximum(t-beat,0);envelope=(t>=beat)*np.exp(-s*26)
            signal += envelope*(.16*np.sin(2*np.pi*440*pitch*s)+.09*np.sin(2*np.pi*711*pitch*s))
            beat += .48 - .3*(beat/duration)
        signal *= np.minimum(t/.01,1)*np.minimum((duration-t)/.025,1)
    signal *= .83/max(abs(signal).max(),.001)
    with wave.open(str(OUT/(name+'.wav')),'wb') as f:
        f.setnchannels(1);f.setsampwidth(2);f.setframerate(RATE);f.writeframes((signal*32767).astype('<i2').tobytes())
    report[name]={'seconds':duration,'peak_dbfs':float(20*np.log10(abs(signal).max()))}
(OUT/'provenance.json').write_text(json.dumps({'author':'Original procedural synthesis for Battle of Gods','generator':'tools/generate_examiner_firmament_sfx.py','cues':report},indent=2)+'\n',encoding='utf-8')
print('Three charge/release cues generated.')
