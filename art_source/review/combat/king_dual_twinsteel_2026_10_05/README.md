# Twinsteel native moving and playable proof

2026-10-05; Godot4.7.2 stable Compatibility/OpenGL, native AMD renderer, fixed60Hz for authoritative timing checks. Owner permits A as default and creative spin motion. This is a **side-facing prototype**, not an F5/catalog/crafting completion claim.

- `motion.gif`:105 decoded native frames, actual right/left combo clocks plus real-scale actor and travel-driven running pose preview.
- `motion_timeline.json`: frame/phase/step and both grip records; centisecond timing derives from absolute frame boundaries.
- `gallery.png`:50 assembled chronological body/blade slots; queued-only endpoint copies are not shown as separate new source drawings.
- `playable_review.png`: actual Stage IV review with live front/rear targets, connected King and visible controls.
- `validation.json`:1458 checks /0failures; all81 registered pose slots, two drawn glove anchors, complete queue boundaries, carry/run tip clearance, normal/left chain completion, released carry and optional blade clip swaps.
- `review_validation.json`:23 checks /0failures; five front contacts plus one rear fourth-cut contact, no duplicate target/step pair, Tab controls/Esc pause-resume, genuine movement/gait, real SPACE buffer and reset.
- `greatsword_regression/validation.json`:2771 checks /0failures with current accepted four-direction Greatsword/axe timing/registration. No new Greatsword animation is selected here.

Additional relevant native regressions: axe114/0 and confidence83/0. The axe fixture retains its existing57 ObjectDB exit warning. No warning is reported by the two Twinsteel tests.79 protected runtime file hashes are unchanged; the new23-file build is deterministic. Counts validate registration and behavior, not owner feel, final balance or phone performance.

Play from project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\launch_king_dual_twinsteel_review.ps1
```

A/D runs and faces; SPACE/click cuts (one buffered); G plays the five-cut chain; Tab toggles review controls; Esc pauses/resumes. Buttons test spin alone, place front/rear targets, spawn a rewardless moving Rootling, cancel and reset. The normal hidden Bag listener is disabled. Tab here is controls, not the F5 Bag. Normal saved gear and recipes remain unchanged; autosave is suppressed and review storage isolated.

Reproduce the proofs:

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tests/king_dual_twinsteel_smoke.gd -- --capture
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tests/king_dual_twinsteel_review_smoke.gd
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --script res://tools/render_king_dual_twinsteel_gallery.gd
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_king_axe_motion_gif.ps1 -ReviewFolder king_dual_twinsteel_2026_10_05
```

The GIF helper now completes timing/loop metadata in `.tmp` and replaces the final file once, avoiding the observed importer/preview memory-map race between two writes. Updated replacement/decode verifies all105 frames under Windows PowerShell5.1.

Next: owner visual/motion review, then full up/down motions and normal Player/F9/Bag/skills/dodge integration. Design/source exact prompts: `docs/design/king-dual-sword-design.md` and `art_source/generated/characters/king/dual_twinsteel_2026_10_05/`.
