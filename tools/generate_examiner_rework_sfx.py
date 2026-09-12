"""Original, deterministic physical/divine Foley for the Examiner rework.

Filtered air, struck inharmonic metal, stone transients and bounded room tails.
No downloaded samples, speech, or independently composed music layers.
"""
from pathlib import Path
import json
import wave
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/audio/sfx/characters/disciples/examiner/rework"
RATE = 44100


def lowpass(signal, samples):
    return np.convolve(signal, np.ones(samples) / samples, mode="same")


def sound(kind, duration, seed, pitch=1.0):
    rng = np.random.default_rng(seed)
    t = np.arange(round(duration * RATE)) / RATE
    noise = rng.normal(0, 1, len(t))
    air = lowpass(noise, 9) - lowpass(noise, 65)
    rumble = lowpass(noise, 180)
    if kind == "rupture":
        # Heavy contact, then separate slab breaks and falling rubble.
        signal = .72*np.sin(2*np.pi*(52*pitch*t + 55*(1-np.exp(-t*35))/35))*np.exp(-t*7)
        signal += .24*np.sin(2*np.pi*117*t)*np.exp(-t*11)
        signal += noise*.29*np.exp(-t*70) + rumble*1.6*np.exp(-t*2.8)
        for j, beat in enumerate((.04,.10,.18,.29,.43,.62,.85,1.08)):
            s=np.maximum(t-beat,0)
            env=np.exp(-s*(20+j*3))*(t>=beat)
            signal += (air*.55 + .11*np.sin(2*np.pi*(175+j*47)*s))*env/(1+j*.20)
        signal += air*.14*np.exp(-t*2.5)
    elif kind == "beam":
        env=np.sin(np.pi*np.clip(t/.20,0,1))**.5
        phase=2*np.pi*(1250*t-820*t*t)
        signal=(.20*np.sin(phase)+.07*np.sin(phase*1.618)+air*.85)*env
        signal += .15*np.sin(2*np.pi*170*t)*np.exp(-t*15)
        signal += air*.12*np.exp(-t*8)
    elif kind == "swing":
        gust = np.sin(np.pi * np.clip(t / min(duration, .22), 0, 1)) ** 1.8
        signal = air * gust * 1.6
        for frequency, amp in [(690, .13), (1137, .06), (1831, .025)]:
            signal += amp * np.sin(2*np.pi*frequency*pitch*t) * np.exp(-t*19)
        signal += .20 * np.sin(2*np.pi*88*pitch*t) * np.exp(-t*25)
    elif kind == "impact":
        signal = .62*np.sin(2*np.pi*(66*pitch*t + 24*pitch*(1-np.exp(-t*32))/32))*np.exp(-t*12)
        signal += noise*.17*np.exp(-t*85) + air*.45*np.exp(-t*19) + rumble*.95*np.exp(-t*5)
        for frequency, amp in [(310,.12),(827,.065),(1469,.025)]:
            signal += amp*np.sin(2*np.pi*frequency*pitch*t)*np.exp(-t*8)
        # A separate delayed stone fracture supplies weight after the attack.
        offset = np.maximum(t-.048,0)
        signal += air*.26*np.exp(-offset*24)*(t>=.048)
    elif kind == "chime":
        signal = np.zeros_like(t)
        for frequency, amp, decay in [(440,.20,3),(659,.12,4),(1174,.06,7),(1837,.025,10)]:
            signal += amp*np.sin(2*np.pi*frequency*pitch*t)*np.exp(-t*decay)
        signal += air*.13*np.exp(-t*35)
    elif kind == "rise":
        p = t/duration
        swell = np.sin(np.pi*p)**.8
        signal = air*(.15+.7*p)*swell + rumble*.6*swell
        for frequency, amp in [(147,.14),(294,.045),(587,.035)]:
            signal += amp*np.sin(2*np.pi*frequency*pitch*t)*swell
    elif kind == "cover":
        p = t/duration
        signal = rumble*(.4+p*.7)
        signal += .12*np.sin(2*np.pi*49*t)*np.sin(np.pi*p)**.5
        for beat in (.0,.95,1.90,2.85,3.30,3.55):
            s=np.maximum(t-beat,0)
            signal += .14*np.sin(2*np.pi*659*s)*np.exp(-s*14)*(t>=beat)
    else: # Low, short armored footfall; never competes with attack cues.
        signal = .35*np.sin(2*np.pi*105*t)*np.exp(-t*60)+air*.35*np.exp(-t*42)
        signal += .035*np.sin(2*np.pi*1240*t)*np.exp(-t*75)
    attack = np.minimum(t/.003,1)
    release = np.minimum(np.maximum(duration-t,0)/.065,1)
    signal *= attack*release
    # Small room early reflections, not a huge wash over consecutive attacks.
    dry=signal.copy()
    for delay, gain in ((.031,.15),(.057,.095),(.091,.05)):
        n=round(delay*RATE)
        if n<len(signal):
            signal[n:] += dry[:-n]*gain
    signal -= signal.mean()
    signal = np.tanh(signal*1.15)
    signal *= .82/max(float(np.abs(signal).max()),.001)
    signal *= np.minimum(t/.002,1)*np.minimum((duration-t)/.02,1)
    return signal


def main():
    OUT.mkdir(parents=True,exist_ok=True)
    specs = {
        "thrust":("swing",.28,1.12), "sweep":("swing",.42,.72),
        "charge_prepare":("rise",.72,.9), "charge_dash":("swing",.31,.58),
        "charge_impact":("impact",.55,1.15), "slam_prepare":("rise",.82,.68),
        "slam_impact":("rupture",1.10,.90), "refutation":("chime",.42,1.42),
        "axiom_prepare":("rise",.9,1.5), "axiom_cut":("beam",.42,1.7),
        "descent_chime":("chime",1.25,.75), "descent_launch":("swing",.43,.85),
        "descent_charge":("cover",3.8,1), "descent_fall":("rise",.15,.42),
        "descent_impact":("rupture",1.75,.70), "step":("step",.14,1),
    }
    report={}
    for i,(name,(kind,duration,pitch)) in enumerate(specs.items()):
        signal=sound(kind,duration,912+i,pitch)
        with wave.open(str(OUT/("examiner_"+name+".wav")),"wb") as wav:
            wav.setnchannels(1); wav.setsampwidth(2); wav.setframerate(RATE)
            wav.writeframes((signal*32767).astype("<i2").tobytes())
        report[name]={"seconds":duration,"peak_dbfs":round(20*np.log10(np.abs(signal).max()),2),"rms_dbfs":round(20*np.log10(np.sqrt(np.mean(signal**2))),2)}
    (OUT/"provenance.json").write_text(json.dumps({"author":"Original procedural synthesis for Battle of Gods", "generator":"tools/generate_examiner_rework_sfx.py", "sample_rate":RATE,"cues":report},indent=2)+"\n")
    print("Wrote 16 original Examiner cues",OUT)


if __name__=="__main__":
    main()
