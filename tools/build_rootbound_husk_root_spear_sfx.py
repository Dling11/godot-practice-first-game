"""Build the Rootbound Husk's original Root Spear impact cue."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100
DURATION_SECONDS = 0.42
OUTPUT = Path(__file__).resolve().parents[1] / "assets/audio/sfx/rootbound_husk_root_spear.wav"


def envelope(time: float, start: float, duration: float) -> float:
    local_time = (time - start) / duration
    if local_time < 0.0 or local_time >= 1.0:
        return 0.0
    return (1.0 - local_time) ** 2


def main() -> None:
    random_source = random.Random(53)
    samples: list[int] = []
    total_samples = round(SAMPLE_RATE * DURATION_SECONDS)
    for index in range(total_samples):
        time = index / SAMPLE_RATE
        rumble = math.sin(math.tau * (54.0 - time * 24.0) * time) * envelope(time, 0.0, 0.32) * 0.32
        crack = 0.0
        for start, frequency in [(0.07, 560.0), (0.12, 430.0), (0.18, 680.0)]:
            crack += math.sin(math.tau * frequency * (time - start)) * envelope(time, start, 0.06) * 0.16
        debris = (random_source.random() * 2.0 - 1.0) * envelope(time, 0.05, 0.24) * 0.15
        value = max(-1.0, min(1.0, rumble + crack + debris))
        samples.append(round(value * 32767.0))
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUTPUT), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        output.writeframes(struct.pack("<%dh" % len(samples), *samples))


if __name__ == "__main__":
    main()
