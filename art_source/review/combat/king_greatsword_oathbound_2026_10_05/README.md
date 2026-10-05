# Installed Oathbound proof — 2026-10-05

**Historical initial proof:** Owner accepts hitting motion partially but rejects clipped/floating heads. The1601 checks below did not prove connected anatomy. Current2381 proof and enlarged before/after samples are in `art_source/review/combat/king_oathbound_neck_2026_10_05/`; current implementation remains [Oathbound motion](../../../../docs/design/king-greatsword-oathbound-motion.md).

`motion.gif` is the installed Player's five-hit basic sequence in right/left/up/down alongside the unchanged axe. It is native Godot 4.7.2 Compatibility rendering, not an image-generation animation. Simulation60Hz, readback30fps,130 frames; timeline records actual step/phase/pose/steel state. GIF delays and decoded frame count are verified.

`validation.json` and `motion_test.log`: **1601 checks / 0 failures**. Exact installed head RGBA, all registered gloves/rigid steel, full queued handoffs, actual standalone entry, carry return, physical travel, four directional slam tips/dust and broad ordinary FX are covered. Source-image inspection and native frame inspection supplement the checks; an extra back head was discovered visually and fixed before final capture.

Actual gameplay151/0, contact60/0, practice/Bag17/0, axe114/0, preserved idle/run101/0 and planted stance21/0 pass; generic melee and sword-style smoke pass. `regressions.json` links results to logs. Existing transition-exit57-instance warnings remain in practice/axe logs; they are not new claims of solved cleanup.

`preserved/` contains current idle/run/slam captures. Previous evidence remains at its original paths. Raw sources/exact prompts are in `art_source/generated/characters/king/greatsword_oathbound_2026_10_05/`.

Technical checks do not establish owner acceptance, full-session difficulty, GPU timing or phone performance. Current authority, source registration and test access: [Oathbound motion](../../../../docs/design/king-greatsword-oathbound-motion.md).
