"""Generate deterministic original SFX for The Examiner.

The sounds are deliberately compact, synthetic, and license-clean. They use
layered noise, metallic partials, and short divine chimes so the boss reads
without depending on external sample packs.
"""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets/audio/sfx/characters/disciples/examiner"
RATE = 44_100


def envelope(time: float, duration: float, attack: float = 0.015, release: float = 0.18) -> float:
    return min(time / max(attack, 0.001), 1.0) * min((duration - time) / max(release, 0.001), 1.0)


def save(name: str, duration: float, synth, seed: int) -> None:
    rng = random.Random(seed)
    frames = []
    for index in range(round(duration * RATE)):
        time = index / RATE
        value = max(-1.0, min(1.0, synth(time, duration, rng)))
        frames.append(struct.pack("<h", round(value * 32767)))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUTPUT / name), "wb") as target:
        target.setnchannels(1)
        target.setsampwidth(2)
        target.setframerate(RATE)
        target.writeframes(b"".join(frames))


def metallic_swipe(time: float, duration: float, rng: random.Random, low: float, high: float) -> float:
    progress = time / duration
    frequency = low + (high - low) * progress
    shimmer = math.sin(math.tau * frequency * time) + 0.42 * math.sin(math.tau * frequency * 2.71 * time)
    air = rng.uniform(-1.0, 1.0) * (1.0 - progress) * 0.32
    return (shimmer * 0.28 + air) * envelope(time, duration, 0.008, duration * 0.48)


def impact(time: float, duration: float, rng: random.Random, pitch: float) -> float:
    progress = time / duration
    thump = math.sin(math.tau * pitch * time) * math.exp(-progress * 9.0)
    crack = rng.uniform(-1.0, 1.0) * math.exp(-progress * 18.0)
    bell = math.sin(math.tau * pitch * 5.1 * time) * math.exp(-progress * 5.0)
    return (thump * 0.58 + crack * 0.35 + bell * 0.18) * envelope(time, duration, 0.002, duration * 0.32)


def divine_charge(time: float, duration: float, rng: random.Random) -> float:
    progress = time / duration
    tone = math.sin(math.tau * (170.0 + 520.0 * progress * progress) * time)
    harmonic = math.sin(math.tau * (510.0 + 760.0 * progress) * time)
    sparks = rng.uniform(-1.0, 1.0) * progress * 0.16
    return (tone * 0.28 + harmonic * 0.16 + sparks) * envelope(time, duration, 0.04, 0.10)


def descent_rumble(time: float, duration: float, rng: random.Random) -> float:
    progress = time / duration
    low = math.sin(math.tau * (42.0 + 16.0 * progress) * time) * 0.42
    choir = math.sin(math.tau * 220.0 * time) * 0.12 + math.sin(math.tau * 330.0 * time) * 0.08
    grit = rng.uniform(-1.0, 1.0) * (0.05 + 0.18 * progress)
    return (low + choir * progress + grit) * envelope(time, duration, 0.08, 0.18)


def main() -> None:
    save("examiner_thrust.wav", 0.22, lambda t, d, r: metallic_swipe(t, d, r, 170.0, 980.0), 701)
    save("examiner_sweep.wav", 0.38, lambda t, d, r: metallic_swipe(t, d, r, 120.0, 670.0), 702)
    save("examiner_charge_prepare.wav", 0.70, divine_charge, 703)
    save("examiner_charge_dash.wav", 0.32, lambda t, d, r: metallic_swipe(t, d, r, 90.0, 1240.0), 704)
    save("examiner_charge_impact.wav", 0.48, lambda t, d, r: impact(t, d, r, 68.0), 705)
    save("examiner_slam_prepare.wav", 0.78, lambda t, d, r: divine_charge(t, d, r) * (0.75 + 0.25 * math.sin(math.tau * 6.0 * t)), 706)
    save("examiner_slam_impact.wav", 0.78, lambda t, d, r: impact(t, d, r, 43.0), 707)
    save("examiner_refutation.wav", 0.36, lambda t, d, r: metallic_swipe(t, d, r, 880.0, 240.0), 708)
    save("examiner_axiom_prepare.wav", 0.90, divine_charge, 709)
    save("examiner_axiom_cut.wav", 0.40, lambda t, d, r: metallic_swipe(t, d, r, 260.0, 1380.0), 710)
    save("examiner_descent_chime.wav", 0.84, divine_charge, 711)
    save("examiner_descent_launch.wav", 0.58, lambda t, d, r: metallic_swipe(t, d, r, 110.0, 1680.0), 712)
    save("examiner_descent_charge.wav", 3.80, descent_rumble, 713)
    save("examiner_descent_fall.wav", 0.48, lambda t, d, r: metallic_swipe(t, d, r, 1320.0, 72.0), 714)
    save("examiner_descent_impact.wav", 1.15, lambda t, d, r: impact(t, d, r, 34.0), 715)


if __name__ == "__main__":
    main()
