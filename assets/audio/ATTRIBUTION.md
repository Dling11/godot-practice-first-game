# Audio Attribution

## Varkuun, Lord of the Withered Grove

- **Boss loop:** `music/boss/varkuun_battle_rpg_theme_loop.ogg`
- **Track:** `Boss Battle Theme` (`CleytonRX - Battle RPG Theme Var.ogg`)
- **Author:** Cleyton Kauffman
- **License:** CC0 / public domain
- **Source:** https://opengameart.org/content/boss-battle-theme
- **Downloaded:** 2026-08-15
- **Air descent/travel:** `Air whoosh` by pyranostudios, CC0 — https://opengameart.org/content/air-whoosh
- **Landing/slap/jump impacts:** `Jump Landing` by Dan Knoflicek, CC0 — https://opengameart.org/content/jump-landing
- **Root prison:** `Earth Element Magic Spell` by qubodup, CC0 — https://opengameart.org/content/earth-element-magic-spell
- **Footstep:** `Footsteps` by GboxMikeFozzy, CC0 — https://opengameart.org/content/footsteps-0
- **Lunge/jump launch:** `Swishes Sound Pack` by artisticdude, CC0 — https://opengameart.org/content/swishes-sound-pack
- **Hurt/defeat vocals:** `Monster Sound Effects Pack` by Ogrebane, CC0 — https://opengameart.org/content/monster-sound-effects-pack
- **Phase cue:** `Magic Spell SFX` by JaggedStone, CC0 — https://opengameart.org/content/magic-spell-sfx

The louder fantasy/JRPG orchestral loop begins only after Varkuun's entrance dialogue closes. The previously evaluated `Determined Pursuit` WAV is inactive and preserved under `art_source/archive/audio/varkuun_cc0_sources/`. Combat jump audio is three-part: a short recorded launch, the longer air-rush throughout travel, and a separate recorded ground impact on landing. The complete downloaded monster pack is preserved in the same archive; only selected runtime files are imported.

## Original Opaw Level-Up Chime

- **Runtime file:** `sfx/ui/opaw_level_up_chime.wav`
- **Source:** Original deterministic in-project synthesis via `tools/build_level_up_sfx.py`
- **Created:** 2026-07-26

The restrained rising spirit chime accompanies the compact level-up banner. It is routed through the UI bus and requires no external attribution.

## Original Opaw Action Cues

- **Runtime file:** `sfx/opaw_hurt_impact.wav`
- **Source:** Original deterministic in-project synthesis via `tools/build_opaw_hurt_impact_sfx.py`
- **Created:** 2026-07-19

The hurt cue is a restrained cloth/body impact reserved for accepted player damage. It does not reuse enemy attack audio.

## Opaw Dash CC0 SFX

- **Author:** artisticdude
- **License:** CC0 1.0 / Public Domain dedication
- **Source:** https://opengameart.org/content/swishes-sound-pack
- **Runtime file:** `sfx/opaw_dash_light_swoosh.wav`
- **Selected source clip:** `swish-4.wav`
- **Source pack downloaded:** 2026-07-18; curated for dash: 2026-07-19

The short light swish is reserved for Opaw's dash at a restrained volume. The full source pack remains outside runtime imports under `art_source/archive/audio/opaw_piercing_rush_cc0_source_packs/`.

## Cathedral in the Forest (ambient loop)

- **Author:** congusbongus
- **License:** CC0 1.0 / Public Domain dedication
- **Source:** https://opengameart.org/content/cathedral-in-the-forest-ambient-loop
- **Runtime file:** `music/cathedral_in_the_forest.ogg`
- **Downloaded:** 2026-07-14

The track is used as low-volume ambient music through the dedicated `Music` bus. Attribution is retained for provenance even though CC0 does not require it.

## Rootbound Husk Mini-Boss Loop

- **Author:** beardalaxy
- **License:** CC0 1.0 / Public Domain dedication
- **Source:** https://opengameart.org/content/basilisk-boss-battle-loop
- **Runtime file:** `music/miniboss/rootbound_husk_basilisk_miniboss_loop.ogg`
- **Downloaded:** 2026-07-19

This loop is used only by Stage 3 when the solo Rootbound Husk mini-boss wave begins. Its SHA-256 at download is `3CA99A4FDC962BBB7A2EF314F0EAAFD153CAE2FF2220AADD32071348BAE5D6B2`.

## Rootbound Husk Root Impact

- **Runtime file:** `sfx/enemies/rootbound_husk/rootbound_husk_root_spear.wav`
- **Runtime treatment:** The authored root impact is layered once at normal pitch and once quietly at `0.68` pitch for additional ground weight.

This cue belongs only to Rootbound Husk root attacks and is organized under the enemy-specific SFX directory rather than the reusable combat folder.

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

The quiet charge, three spaced steel-thrust beats, strong final sword thrust, and accepted-contact blade impact are deliberately separate streams. They replace normal-swing reuse during Skill 2 while still following the authored cast and strike signals. The selected final source recordings retain their original data, but runtime playback starts at 0.50 seconds for the sword burst and 0.125 seconds for the contact burst to skip their recorded lead-ins. The replaced swish clips are archived outside Godot imports under `art_source/archive/skills/opaw/consecutive_thrust_v3_replaced/`; the selected source packs remain in the existing CC0 combat-source archive.

## Rootling Root Jab

- **Runtime file:** `sfx/rootling_root_jab.wav`
- **Source:** Original deterministic in-project synthesis via `tools/build_rootling_root_jab_sfx.py`
- **Created:** 2026-07-19

This 0.31-second mono cue layers a low wooden ground push with three filtered crack bursts and a short snap. It is used only by Rootling's authoritative eruption signal and does not reuse sword, Mireling, or Bramble attack audio.

## Rootweaver Living Rootforge Strike

- **Runtime file:** `sfx/npcs/rootweaver/rootweaver_rootforge_strike.wav`
- **Source:** Original deterministic in-project synthesis via `tools/build_rootweaver_forge_sfx.py`
- **Created:** 2026-07-29

This 0.34-second mono presentation cue combines a restrained wooden knock, stone body, root creak, and short transient. Nema's timer-driven work animation plays it once at the hammer-contact frame; it has no crafting or gameplay authority.

## Armored Hog Action Suite

- **Hoof, brace, and crash runtime files:** `sfx/enemies/armored_hog/armored_hog_hoof.wav`, `armored_hog_brace.wav`, and `armored_hog_crash.wav`
- **Source:** Original deterministic in-project synthesis via `tools/generate_armored_hog_sfx.py`
- **Created:** 2026-08-13
- **Vocal runtime file:** `sfx/enemies/armored_hog/armored_hog_snort.ogg`
- **Vocal source:** `Boar` by fvcalderan
- **License:** CC0 1.0 / Public Domain dedication
- **Source page:** https://opengameart.org/content/boar-0
- **Downloaded:** 2026-08-13

The pitch-lowered vocal layers only on the authoritative brace warning. Original short hoof transients accelerate during the committed charge, and the original crash cue marks entry into the punishable daze. The source OGG and one evaluated CC0 horse-trot candidate are preserved under `art_source/archive/audio/stage_4_armored_hog_cc0_sources/`; the horse recording is not used at runtime.
