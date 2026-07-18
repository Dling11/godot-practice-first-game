# Audio Attribution

## Cathedral in the Forest (ambient loop)

- **Author:** congusbongus
- **License:** CC0 1.0 / Public Domain dedication
- **Source:** https://opengameart.org/content/cathedral-in-the-forest-ambient-loop
- **Runtime file:** `music/cathedral_in_the_forest.ogg`
- **Downloaded:** 2026-07-14

The track is used as low-volume ambient music through the dedicated `Music` bus. Attribution is retained for provenance even though CC0 does not require it.

## RPG Sound Pack

- **Author:** artisticdude
- **License:** CC0 1.0 / Public Domain dedication
- **Source:** https://opengameart.org/content/rpg-sound-pack
- **Runtime files:** selected and descriptively renamed clips under `sfx/`
- **Downloaded:** 2026-07-14

Only the ten clips used by the current combat prototype are retained. The original pack contains 95 WAV files; unused material is not committed.

## Piercing Rush CC0 SFX

- **Charge source:** `Swishes Sound Pack` by artisticdude
- **Thrust and impact source:** `20 Sword Sound Effects (Attacks and Clashes)` by StarNinjas
- **License:** CC0 1.0 / Public Domain dedication
- **Sources:** https://opengameart.org/content/swishes-sound-pack and https://opengameart.org/content/20-sword-sound-effects-attacks-and-clashes
- **Runtime files:** `sfx/opaw_piercing_rush_charge.wav`, `sfx/opaw_piercing_rush_thrust.ogg`, and `sfx/opaw_piercing_rush_impact.ogg`
- **Downloaded:** 2026-07-18

The selected clips are used as a quiet wind-up, distinct active thrust, and accepted-hit impact for Piercing Rush. The downloaded source packs are preserved outside runtime import under `art_source/archive/audio/opaw_piercing_rush_cc0_source_packs/`; only the three named runtime clips are loaded by Godot.

## Consecutive Thrust CC0 SFX

- **Charge source:** `Swishes Sound Pack` by artisticdude
- **Rapid flurry, final thrust, and contact sources:** `20 Sword Sound Effects (Attacks and Clashes)` by StarNinjas
- **License:** CC0 1.0 / Public Domain dedication
- **Sources:** https://opengameart.org/content/swishes-sound-pack and https://opengameart.org/content/20-sword-sound-effects-attacks-and-clashes
- **Runtime files:** `sfx/opaw_consecutive_thrust_charge.wav`, `sfx/opaw_consecutive_thrust_flurry_thrust.ogg`, `sfx/opaw_consecutive_thrust_final_thrust.ogg`, and `sfx/opaw_consecutive_thrust_final_hit.ogg`
- **Downloaded:** 2026-07-18; revised selection 2026-07-19

The quiet charge, three spaced steel-thrust beats, strong final sword thrust, and accepted-contact blade impact are deliberately separate streams. They replace normal-swing reuse during Skill 2 while still following the authored cast and strike signals. The replaced swish clips are archived outside Godot imports under `art_source/archive/skills/opaw/consecutive_thrust_v3_replaced/`; the selected source packs remain in the existing CC0 combat-source archive.
