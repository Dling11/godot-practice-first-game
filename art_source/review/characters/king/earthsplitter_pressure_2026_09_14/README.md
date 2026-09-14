# Earthsplitter pressure review - September 14, 2026

Actual Godot Lab capture at 60 simulated FPS, encoded at real speed. The capture uses deterministic input, a fixed review camera and inactive enemy AI for readable inspection; the real skill controller, VFX, damage, feedback and existing audio run normally. Hit pauses remain visible. This is not a boss difficulty test.

- `earthsplitter_pressure.mp4`: eight facings plus a 17-degree cast, close/far pointer lane comparison, real three-target damage and a terrain stop.
- `earthsplitter_pressure.gif`: opening excerpt, silent.
- `aim_near_*` / `aim_far_*`: identical reach for near/far pointer positions.
- `summon_*` / `impact_*` / `pressure_*` / `rupture_*`: timed in-engine stills. The approved sword is unmodified.
- `wall_aim.png` / `wall_pressure.png`: full-width terrain clipping; gray slab is a temporary capture fixture.

Play F7 > KING REVIEW > SKILL 1: EARTHSPLITTER. Press 1, aim the fixed lane, left-click to confirm; right-click/Esc cancels. Reach is 164px unless blocked by terrain. Circle targeting remains for other skills. Control returns after .36s base commitment before accepted-hit pauses; released travel lasts .25s. One 165% weapon hit per target, flinch/push, no stun.

Generated with built-in imagegen: source and exact prompt at `art_source/generated/vfx/king/earthsplitter/pressure_source_v2.png` and `PROMPTS_V2.md`. Runtime art: `assets/vfx/abilities/king/earthsplitter/pressure_v2.png`. Forty drawings in five views, horizontally mirrored for eight facings. Flat cracks follow exact aim; lifted art stays upright. The old rupture atlas and prior review remain available as history. Audio reuses existing cleave and Riftbreak impact cues.

Validation: Earthsplitter 116 assertions, targeted Riftbreak 28, King Spellward preview 232, original Echoing Sever smoke all passed. Sword atlas/source SHA256 match Decision 151. Visual acceptance of the new ground effect remains with the owner. Skill 2, progression upgrades and campaign replacement remain separate work.

Reproduce: run `tools/capture_earthsplitter_pressure.gd` with Godot Movie Maker at fixed 60 FPS; record to `.godot/earthsplitter_pressure.avi`, then encode the review MP4. The capture suppresses session autosave and cleans its fixture.
