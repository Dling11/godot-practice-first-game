# Twinsteel — existing gait and back stow

**Superseded/rejected later on2026-10-05:** The owner reports growing spin/vertical attacks, rejects outward carry and identifies wrong physical UP back stow/front holding idle. Current [unified body/thrust/hop proof](../king_dual_unified_2026_10_05/README.md) replaces this version. Counts below are historical, not owner visual approval.

2026-10-05. Native Godot4.7.2 Compatibility proof. Existing axe side and Greatsword front/back body cels are copied unchanged. Idle crosses both swords behind the back; running holds one sword in each actual moving hand on opposite sides with small stride tilt. Previous generated gait is rejected history.

Launcher `tools/launch_king_dual_twinsteel_review.ps1`, window **TWINSTEEL / EXISTING GAIT & BACK STOW**. WASD run/facing, SPACE/click cut, G five-hit chain, Tab controls, Esc pause. Dedicated rewardless practice; normal F5/equipment promotion remains pending.

| Evidence | Verified boundary |
| --- | --- |
| gait/motion.gif | 48 native frames, four running directions at3× and actual size |
| gait_and_scale.png | All stride keys, unchanged heavy-family comparison and crossed idle |
| motion.gif / motion_timeline.json | 105 native frames, four attack directions and carry returns |
| validation.json / motion_check.log | 3672 checks,0 failures: exact source bodies, real grips, back-stow depth/empty masks, anatomy, floor, queue and blade interpolation |
| review_validation.json / review_check.log | 109 checks,0 failures: real review movement/blocked gait, input/buffering, contacts/reach, Tab/Esc, pause/cancel/reset |
| playable_review.png | Actual review stage |

Queued gaps[0,0,0,0] additional physics ticks; each facing hits a1px-radius target68px from the contact pivot once and misses110px. Five front contacts and one rear spin contact remain. The same72/58/80px contact,2.20s chain,18px collision travel, canonical blade and silver FX are retained. Source idle heights57/44/45px preserve known vertical-size debt; equal direction height is not claimed.

Registration/hashes: `art_source/registration/characters/king/dual_existing_gait_2026_10_05/`.65 runtime outputs reproduce identically;63 intentional carry/endpoint changes,92 protected heavy/source files unchanged. Both GIFs decode-check. No new body generation or runtime image processing.

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tests/king_dual_twinsteel_cardinal_smoke.gd -- --capture --output=res://art_source/review/combat/king_dual_existing_gait_2026_10_05
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tests/king_dual_twinsteel_review_smoke.gd -- --output=res://art_source/review/combat/king_dual_existing_gait_2026_10_05
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_king_axe_motion_gif.ps1 -ReviewFolder king_dual_existing_gait_2026_10_05
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tools/render_king_dual_polish_gait.gd -- --output=res://art_source/review/combat/king_dual_existing_gait_2026_10_05/gait
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_king_axe_motion_gif.ps1 -ReviewFolder king_dual_existing_gait_2026_10_05/gait -FinalDelayMs 27
```

Passing technical checks is not owner motion acceptance, comparative balance or phone profiling. Normal Player skills/dodge/reactions/equipment remain separate work. [Current rules and build order](../../../../docs/design/king-dual-sword-design.md).
