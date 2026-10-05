# Installed greatsword motion check — 2026-10-05

motion.gif shows four actual Player scenes with Royal Greatsword equipped: right/left preserve the accepted side art; up/down use the newly generated front/back bodies. All play fourth → buffered fifth → carry. This is the installed adapter and combat phase clock, not a storyboard.

Fourth/fifth each take 0.70s with 0.22s contact. Side fifth retains its original 16 keys, with weighted 0.128s low return followed by 0.272s carry settle. The registered blade angle interpolates while its grip stays attached to the drawn cel. Vertical queued endpoints do not interpolate into unqueued recovery before holding.

## Reproduce the native preview

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --path . --fixed-fps 60 --script res://tests/king_greatsword_motion_smoke.gd -- --capture-fixed-60
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_king_axe_motion_gif.ps1 -FinalMotion
```

Fixed engine time is 60Hz; capture samples at 30fps. GPU readback stalls do not stretch the exported combo. motion_timeline.json records authored elapsed_ms, wall_ms, phase, step, pose and blade angle. GIF encoding rounds absolute centisecond boundaries, then verifies all 100 decoded frames/delays. The encoder's legacy AXE_MOTION_GIF output label names a shared utility, not the equipped weapon.

## Checks and limits

validation.json contains current passed counts and timings. motion_test.log checks all eight vertical endpoint→opening body/rig pairs, linked contact hold, grip attachment, both equal phase budgets, four Player directions and final carry. gameplay_test.log separately checks real-time Sanctuary/F9/Bag gameplay, five cuts in all directions, travel-driven run/carry, buffering, pause, planted retrieval, skill/evade fallback, snapshot restoration, real contacts and Stage I carry. practice_input_test.log checks physical Tab → actual Lab, visible Bag, Esc resume and real controls. These gameplay/input fixtures do not use the fixed capture clock.

Earlier this-turn logs retain the preserved side-chain, planted idle and axe regressions. Unproven exit-only transition-fixture ObjectDB diagnostics remain recorded; desktop checks do not establish phone performance or owner approval of feel. Source sheets/prompts/provenance are under art_source/generated/characters/king/greatsword_cardinal_2026_10_05/. Canonical current rules: docs/design/king-greatsword-gameplay.md.
