# Playable King Skills 4 and 5 — 2026-09-27

Launch tools/launch_king_skills.ps1, or F7 -> Skills. Use4 to buff; use5 then aim/left-click for Worldsplitter. Skills tab offers Vow Foundation/Advanced/Mature. The launcher supplies four paused Mirelings and turns invincibility off so enabling AI tests the real shield. All five skills are equipped; debug reuse is unlimited. Campaign cooldowns are20s. No saved training/loadout changes come from Lab.

Five actual 960x540 Godot GPU captures show shield HUD/activation, Mature third cut, summoned blade contact, compact four-way faults and final pressure. No new image generation was used in this pass: approved generated body_down/barrier/pressure, Molten sword/burst/heat-ring and Earthsplitter rupture/pressure assets are reused. Other Vow facings reuse approved directional heavy-cleave frames, preserving anatomy and scale.

Run tests/king_vow_worldsplitter_smoke.gd headlessly for49 behavior assertions; GPU mode adds five image-write checks. tests/unbroken_vow_training_smoke.gd has14 Eira/level/disk-save/migration checks with an isolated temporary test profile. Kit, Lab/sidebar, Pursuit charge, snapshot, armor and CC regressions passed. GPU exits still report the known two5460-byte texture leaks / RenderingServer teardown warnings. Armor smoke passes its assertions but also reports test-shutdown ObjectDB/resource leaks. Owner combat-feel and phone profiling remain unverified.

The stable Worldsplitter ability ID remains king_skill_4 despite moving to slot5; slot numbers are input bindings. Its old heavy sword/sink assets remain unused provenance for later requested code/asset cleanup.
