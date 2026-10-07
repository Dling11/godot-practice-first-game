# Twinsteel — unified body and hop combo

**Rejected visual history:** The owner reports a broad/misaligned front idle and side-running hand/sword mismatch despite the technical checks below. Current native-body and wrist correction: [new proof](../king_dual_attachment_2026_10_05/README.md). Do not use this folder as current acceptance evidence.

2026-10-05. Native Godot4.7.2 Compatibility proof. Common54px standing calibration, installed head/palette references, new double thrust/relaxed idle, forward running swords and physical back stow. Five inputs: thrust → crosscut → return → small hop spin → X, same2.20s chain.

Launcher `tools/launch_king_dual_twinsteel_review.ps1`; window **TWINSTEEL / UNIFIED BODY & HOP COMBO**. WASD runs/faces, SPACE/click attacks, G plays five, Tab controls, Esc pause. Dedicated rewardless review; normal F5/equipment promotion remains pending.

| Evidence | Verified boundary |
| --- | --- |
| motion.gif / motion_frames / motion_timeline.json | 105 native frames, four attack directions and carry returns |
| gait/motion.gif | 48 native frames, four runs at3× and actual size |
| gait_and_scale.png | Every run key and heavy side/vertical comparison |
| playable_review.png | Actual review stage |
| validation.json / motion_check.log | 4325 checks,0 failures: common standing/head envelope, anatomy/grips, physical stow, forward thrust/carry, hop landing, queue/interpolation |
| review_validation.json / review_check.log | 113 checks,0 failures: movement/blocked gait, buffering/contact dedup, Tab/Esc, pause/cancel/reset, thrust range/flank |
| generated source/rebuild_validation.json | 65 identical outputs,63 changed,92 protected files unchanged |

Every standing view54logical/27worldpx; installed head regions23–25×22–24px. Current recorded full-body maxima57 side /56 back /59 front include raised arms; crouch/bob is actual pose anatomy, not frame zoom. All grounded attack soles register at Y94 before the explicit6worldpx spin/4worldpx X lift. UP idle paints blades over King's visible back; DOWN paints them behind his chest. Idle hand masks are empty.

First thrust hits a tiny68px-forward target, misses110px and misses45px-forward/26px-side in every facing. Remaining contact72/58/80px, damage and18px collision travel remain. Both blades share one hit per input; only spin hits behind King. Four automatic queue gaps[0,0,0,0] extra physics ticks.

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tests/king_dual_twinsteel_cardinal_smoke.gd -- --capture
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tests/king_dual_twinsteel_review_smoke.gd
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_king_axe_motion_gif.ps1 -ReviewFolder king_dual_unified_2026_10_05
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tools/render_king_dual_polish_gait.gd
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_king_axe_motion_gif.ps1 -ReviewFolder king_dual_unified_2026_10_05/gait -FinalDelayMs 27
```

Source/prompts/hashes in `art_source/generated/characters/king/dual_unified_2026_10_05/`. Heavy source assets remain unchanged; their legacy44/45px vertical carry is separate debt. Previous proof folders are rejected/superseded visual history. Passing tests is not owner art/feel approval, comparative balance or phone profiling. [Current scope/rebuild](../../../../docs/design/king-dual-sword-design.md).
