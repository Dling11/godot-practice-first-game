"""Original deterministic layered SFX. No samples or external licenses required."""
from pathlib import Path
import wave
import numpy as np

OUT = Path(__file__).resolve().parents[1] / "assets/audio/sfx/player/oath"
RATE = 44100
OUT.mkdir(parents=True, exist_ok=True)
rng = np.random.default_rng(20260913)

def render(name, duration, weight, rising=False):
    t = np.arange(int(duration * RATE)) / RATE
    p = t / duration
    noise = rng.normal(0, 1, len(t))
    low = np.convolve(noise, np.ones(65) / 65, mode="same")
    air = noise - np.convolve(noise, np.ones(7) / 7, mode="same")
    attack = np.minimum(t / .008, 1)
    env = attack * np.exp(-t * (6 if weight < 1 else 3.8))
    if rising:
        env = np.sin(np.pi * p) ** .7
        body = np.sin(2*np.pi*(90*t+160*t*t))
        y = .20*body + .17*low + .028*air
    else:
        phase = 2*np.pi*(44*t+weight*48*(1-np.exp(-t*18))/18)
        body = np.sin(phase)
        steel = sum(np.sin(2*np.pi*f*t)*np.exp(-t*d) for f,d in
                    [(391,9),(783,12),(1177,16),(2053,25)])
        y = weight*.34*body + .27*low + .09*air*np.exp(-t*22) + .065*steel
    y *= env
    # Small, decaying reflections make a wide space without masking attack timing.
    left = y.copy()
    right = y.copy()
    for seconds, amount in [(.047,.15),(.089,.09),(.137,.055)]:
        n = int(seconds*RATE)
        left[n:] += y[:-n]*amount
        n += 211
        right[n:] += y[:-n]*amount
    stereo = np.stack([left,right], axis=1)
    stereo *= np.minimum((duration-t)/.04,1)[:,None]
    stereo = np.clip(stereo,-.92,.92)
    with wave.open(str(OUT / (name+".wav")), "wb") as out:
        out.setnchannels(2); out.setsampwidth(2); out.setframerate(RATE)
        out.writeframes((stereo*32767).astype("<i2").tobytes())
    print(name, len(t), "peak", round(float(abs(stereo).max()),3))

for args in [("charge",.42,.2,True),("crosscut",.38,.32),
             ("griefwake",.55,1.0),("starfall",.62,.85),
             ("storm",.45,.55),("finale",.85,1.35)]:
    render(*args)
