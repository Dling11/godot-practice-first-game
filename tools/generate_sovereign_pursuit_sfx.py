"""Generate King's original short Sovereign Pursuit landing cue."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets/audio/sfx/abilities/king/sovereign_pursuit_landing.wav"
RATE = 44100
DURATION = 0.42


def main() -> None:
    random.seed(7413)
    samples: list[float] = []
    for index in range(round(RATE * DURATION)):
        time = index / RATE
        blade_envelope = math.exp(-time * 17.0)
        blade = math.sin(2.0 * math.pi * (720.0 - time * 850.0) * time) * blade_envelope * 0.30
        impact_time = max(0.0, time - 0.075)
        impact_envelope = math.exp(-impact_time * 13.0) if time >= 0.075 else 0.0
        impact = math.sin(2.0 * math.pi * 78.0 * impact_time) * impact_envelope * 0.55
        stone = (random.random() * 2.0 - 1.0) * impact_envelope * 0.22
        royal = math.sin(2.0 * math.pi * 310.0 * impact_time) * math.exp(-impact_time * 8.0) * 0.12 if time >= 0.075 else 0.0
        samples.append(max(-1.0, min(1.0, blade + impact + stone + royal)))

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUTPUT), "wb") as target:
        target.setnchannels(1)
        target.setsampwidth(2)
        target.setframerate(RATE)
        target.writeframes(b"".join(struct.pack("<h", round(sample * 32767.0)) for sample in samples))
    print(f"Wrote {OUTPUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
