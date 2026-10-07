# Twinsteel — run, body height and combo handoff correction

**Rejected gait history, superseded later on2026-10-05.** The owner rejects this generated body/stride style despite the checks below. Current carry copies existing axe/Greatsword body cels unchanged; see [fresh proof](../king_dual_existing_gait_2026_10_05/README.md). Existing contact, timing, blade and silver FX remain;55px standing/gait claims below describe this rejected version only.

2026-10-05. Native Godot4.7.2 Compatibility proof. Launcher `tools/launch_king_dual_twinsteel_review.ps1`, window **TWINSTEEL / RUN & COMBO POLISH**. WASD run/facing, SPACE/click cut, G five-hit chain, Tab visible controls, Esc pause. Dedicated rewardless practice only; no F5 equipment/save promotion.

| Evidence | Verified boundary |
| --- | --- |
| motion.gif / motion_frames / motion_timeline.json | 105 frames: four attack directions, normal-size front/back and gait |
| gait/motion.gif | 48 frames: four running directions at3× and actual size, no artificial end hold |
| gait_and_scale.png | Every stride and unchanged heavy-family comparison |
| scale_before.json / scale_after.json | Twinsteel standing55px; heavy side54–57, older Greatsword vertical44/45 |
| validation.json / motion_check.log | Native motion3693 checks,0 failures |
| review_validation.json / review_check.log | Actual review109 checks,0 failures; controls/queue/pause/reset/contacts/reach |
| greatsword_check.log / greatsword_regression | Shared-presenter regression2771 checks,0 failures |
| playable_review.png | Actual stage review |

Queued gaps[0,0,0,0] additional physics ticks. Every facing hits a1px-radius target68px from the contact pivot once and misses110px. Five front contacts and only the spin rear contact remain. Current contact72/58/80px, nominal2.20s and18px collision travel. Standing55logical/27.5world, fixed-density gait with real crouch/bob; grips stay on drawn gloves and tips clear the floor. Two old side forearm gaps are restored from source pixels.

New24 gait/20 silver FX source cels, exact prompts and provenance: `art_source/generated/characters/king/dual_polish_2026_10_05/`. Deterministic65/0;54 outputs intentionally changed, canonical blade unchanged and79 protected heavy files identical. Preserved archive is offline input, not a runtime branch.

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tests/king_dual_twinsteel_cardinal_smoke.gd -- --capture --output=res://art_source/review/combat/king_dual_polish_2026_10_05
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tests/king_dual_twinsteel_review_smoke.gd -- --output=res://art_source/review/combat/king_dual_polish_2026_10_05
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_king_axe_motion_gif.ps1 -ReviewFolder king_dual_polish_2026_10_05
```

For gait, use `tools/render_king_dual_polish_gait.gd` then the GIF helper with `-ReviewFolder king_dual_polish_2026_10_05/gait -FinalDelayMs 27`. A native renderer is required for capture. Headless is for offline builds/import/audits only.

Owner motion judgement, balance, older heavy vertical consistency, normal Player skills/dodge/reactions/equipment and phone profiling remain open. [Current rules and build order](../../../../docs/design/king-dual-sword-design.md).
