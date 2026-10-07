# Greatsword V2 — actual Player evidence

Godot4.7.2 Compatibility, native rendering, Dummy audio for automation. tests/king_greatsword_v2_gameplay_smoke.gd passes181 checks with0 failures through real Sanctuary F9/F7, Combat Lab, Player, catalog, Bag and Stage I.

[Actual enlarged-camera combo GIF](motion.gif), [Weapons](weapons_tab.png), [Bag](bag_v2.png), [airborne](jump_airborne.png), [contact](jump_landing.png), [Stage I](stage_1_v2.png), [validation](validation.json), [timeline](motion_timeline.json).

Footage has72 actual rendered frames on the real physics/combat clock, camera zoom3 and hidden UI for anatomy review. Timestamps include PNG capture overhead; this is not a frame-rate benchmark or a deterministic60fps sample. UI images use native scale. tools/build_king_axe_motion_gif.ps1 -ReviewFolder king_greatsword_v2_gameplay_2026_10_07 verifies GIF decoding/count/timing.

Checks cover every catalog equip, V1/V2 comparison, Bag, four-facing buffered chains, front/rear/outside targets, physical typing/knockback, one grounded burst across recovery, collision-blocked steps, busy-action equips, cancellation/evade/skills and Stage I carry. Original Greatsword146/0, native sword/axe/dual closure217/0, sidebar26/0 and6-item catalog regressions also pass.

UP/DOWN are explicitly labelled V1 fallback bodies pending new V2 vertical art. Owner feel, encounter balance and phone profiling are unverified. The fixture retains teardown warnings: verbose.log names expedition_dark_forest MP3 playback and zero-reference allocations (55 ObjectDB/1 resource in that run), not V2 art. Passing assertions are not a clean exit claim.

[Rules, sources and limits](../../../../docs/design/king-greatsword-front-combo.md).
