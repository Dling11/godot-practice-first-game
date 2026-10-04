# Sanctuary Pursuit and circle recovery — 2026-10-04

Reproduction: the real Sanctuary scene registers its disabled offscreen Orren workshop region. The old landing guard treated registered regions as active ground, rejected1255 physically clear sampled outdoor positions and resolved four requested jumps back to King's origin. The strengthened pre-fix regression fails nine checks (pursuit_regression_before.log); this is a runtime navigation bug, not missing jump art.

Correction: only enabled server regions establish navigation ground. Outdoor physical feet and movement bounds remain authoritative; active stage/workshop ground restrictions remain. Existing Pursuit animation, travel, landing effects, charges and range are unchanged.

Circle: one2px silver/slate boundary at62% opacity,6% violet fill and small existing marks. Actual hit radii, lane previews, quiet range arcs and24px cursors stay unchanged. Six960x540 native Stage IV captures cover Skills1/3/5 on grass/dark ground; Skill3 grass/dark screenshots were visually inspected.

Native Godot4.7.2 Compatibility/OpenGL verification:

- pursuit_stage_landing_smoke.gd:45 checks,0 failures. Actual Stage IV and Sanctuary outdoor jumps, workshop floor/furniture/absent ground, restored collision and return outdoors; pursuit_native_after.log.
- king_skill_terrain_smoke.gd:33 checks,0 failures. Actual attacks across obstacles, full leap reach, blocked landing, active navigation, pause/cancel/restoration; terrain_native_after.log.
- king_targeting_art_smoke.gd:39 checks,0 failures. Six captures, aim state/origin, cursor transparency/no gold, hidden processing and isolated-save checks; art_native_after.log.

All three native runs exit cleanly. Tests suppress autosave and use test storage. Owner feel review and representative campaign/phone performance measurements remain open. Restart F5; press3, aim at clear outdoor Sanctuary ground and left click to confirm.
