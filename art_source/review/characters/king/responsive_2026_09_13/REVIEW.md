# King responsive core — September 13, 2026

Decision 147. `review.mp4` is a decoded 13.87-second 960x540 H.264/AAC presentation capture. The real Lab player and eight stationary, high-health Thralls demonstrate Mortal and Unbound forms, targeting and overlapping released Griefwake/Crosscut. It is a presentation review, not a difficulty measurement; Lab immunity/unlimited skills are enabled. Unbound is a future-milestone preview.

Open F7 → King · Technique Collection → Equip all four Oath skills → Close. In Sanctuary, Tab → Active Skills → Technique Collection → Equip core kit installs only learned core skills. Original defaults and saved choices are preserved until an explicit swap.

- 1: two-cut Crosscut, 0.48 s control commitment before hit pauses.
- 2: targeted Griefwake, 0.42 s commitment; release at 0.20 s and impact about 0.46 s. Aim shows both damage zones.
- 3: Breakstep, 0.32 s commitment; movement/aim direction, brief middle protection, no automatic landing attack. An actual eligible evaded hit earns the next basic return cut at +50% within two seconds. Completion links the next rupture.
- 4: Last Oath, one forward precision impact, 0.62 s commitment. Inner damage and weaker crowd-clearing rim are exclusive tiers.
- 5–9, 0: additional equipped positions. Eight techniques currently exist; unoccupied slots are honest empty states.

The four timings remain fixed through all forms. Approved C body textures, frame families, original raster sequences and audio are reused with revised phase timing. No new character generation or future divine reward is included. Core and rim sizes differ by role; old starfall_step/oathstorm save IDs deliberately remain stable.

Verified: 82 responsive checks, 174 Oath checks, 37 library checks, 385 mastery checks, HUD bounds, player presentation, assisted targeting, input buffer, auto-combat, accepted-hit feedback, debug cooldown cleanup, profile snapshot and isolated disk saves. Logs: `.godot/king_responsive_*.log`. Godot editor import and `git diff --check` pass.

Capture: create this output directory first, then run Godot with `--path . --rendering-method gl_compatibility --write-movie art_source/review/characters/king/responsive_2026_09_13/review.avi --fixed-fps 60 --script tools/capture_king_responsive_review.gd`. Convert to 960x540 H.264/AAC and verify decoding before removing the intermediate AVI. Use `-- --ui-only` without movie recording for only the collection/Character screenshots.

Next owner review: play with immunity and unlimited cooldowns off, judge animation and audio in moving encounters, test Last Oath positioning and Breakstep timing, then tune campaign damage. Earned domain spells, Forest Goddess production, Examiner's proposed passive and future stage reward gates remain roadmap work.
