"""Original Sun/guard cues; deterministic synthesis, no external samples."""
from pathlib import Path
import json
import wave
import numpy as np
from generate_examiner_rework_sfx import sound, RATE

OUT=Path(__file__).resolve().parents[1]/'assets/audio/sfx/characters/disciples/examiner/ascendant'
OUT.mkdir(parents=True,exist_ok=True)
report={}
for index,(name,kind,duration,pitch) in enumerate([
    ('sun_charge','rise',5.5,.64),('seal_charge','rise',7.0,.74),
    ('sun_release','beam',.7,.46),('sun_impact','rupture',.85,.56),
    ('guard_break','chime',.75,1.35),('awakening','rupture',1.5,.42)]):
    samples=sound(kind,duration,20260912+index,pitch)
    if name=='guard_break':
        samples=.65*samples+.35*sound('impact',duration,90,1.8)
    with wave.open(str(OUT/(name+'.wav')),'wb') as f:
        f.setnchannels(1);f.setsampwidth(2);f.setframerate(RATE)
        f.writeframes((samples*32767).astype('<i2').tobytes())
    report[name]={'duration':duration,'peak_dbfs':float(20*np.log10(abs(samples).max()))}
(OUT/'provenance.json').write_text(json.dumps({'author':'Original procedural synthesis for Battle of Gods','generator':'tools/generate_examiner_ascendant_sfx.py','sample_rate':RATE,'cues':report},indent=2)+'\n',encoding='utf-8')
print('Generated six original Sun, seal and awakening cues.')
