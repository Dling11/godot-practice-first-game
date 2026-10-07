# King vertical proportions — Twinsteel and Greatsword

2026-10-07, Decision191. Owner asks to match UP/DOWN body proportions to the accepted LEFT/RIGHT baseline, including Greatsword. Existing source artwork is rebuilt with offline anatomical registration; no new conceptual image generation or combat changes.

## Result

Twinsteel vertical non-spin torsos contract horizontally82% UP/86% DOWN; Greatsword uses96%. Shared complete-turn body density stays. Heads retain native colors/outlines at25×24 rear/side and27×29 frontal provenance (including front neck/scarf detail). Per-lane anatomical density matches side ready/run scale, retaining natural crouch/stride/turn differences. Original coverage/palm texels and connected leather sleeves/collar survive the head crop; occluded rear palms stay hidden. Body/hand anchors register together, released blades stay on ground attachments.

Ready heights after registration are55 logical pixels for both vertical views/families, against54px side bodies. Twinsteel first-cut body area changes1597→1443 UP and1652→1412 DOWN; accepted side remains1333. UP first-cut torso pixels change332→271, DOWN263→230, against side223. These measurements explain the direction of correction; pose silhouette equality is not required for different facings.

Greatsword vertical ready before was44/45px against54 side, exaggerating growth at attack start. New sibling vertical carry/run definitions preserve original rest/stow/plant fields and canonical steel; legacy identity/carry source assets remain unchanged. Four-direction attack clocks, effects, contact/damage/range, player collider/controller scale and save identities stay.

## Evidence

- `dual_before.png` / `dual_after.png`, `greatsword_before.png` / `greatsword_after.png`: native body-only sheets at identical pixel scale, with ready/run and load/contact cuts. Steel/slashes are intentionally omitted to expose silhouette. `measurements_before.json` / `measurements_after.json`:528 cells each.
- `proportion_checks.json`:1592/0 checks across installed vertical layout, head density, ready/run size, complete body, connected head/palms. `proportions_complete_console.log` exits cleanly.
- `greatsword_native_final/cardinal_checks.json`:1529/0 real palms/rear occlusion/head connectivity/queue boundaries/FX/native gallery. Current final log exits cleanly.
- `dual_native/motion_checks.json`:953/0,300 native frames at30fps; `dual_motion.gif` encodes the same timeline. The art gallery samples presentation; actual combat/idle are checked independently.
- `dual_gameplay_final/validation.json`:244/0 actual Player/Bag/cardinal queue/contact/skills/dash/swaps/Stage I. `greatsword_gameplay/`:197/0 actual Player directional combo/real targets/blocked steps/cancels/equipment/Stage I. Assertion passes are separate from their exit warnings below.
- `dual_idle/idle_checks.json`:100/0 actual Player uncrossed ready, calm center entry, slow first look, blade floor alignment, retrieval, delayed movement cancellation and swap. First head turns2.516–2.529s after idle entry. Current idle log exits cleanly.
- `preservation.json`:410 original King PNG/TRES files protected,344 unchanged,66 modifications confined to existing UP/DOWN body/hand/pose outputs,12 new Greatsword carry outputs. Side art, canonical steel, FX and other families remain identical. `before_manifest.json` / `before/`:416 backed-up files; copies verified against hashes.
- `connection_comparison.png` / `.json` and `connection_final_console.log`: original/current problematic turn/finish cels, all actual near/far palms connected. Earlier candidate renders and failure logs retain their work-in-progress scope.

Intermediate checks exposed transparent crown padding, source head rectangles that included sleeves, warm leather incorrectly treated as crimson, and native nearest-sampling palm/coverage loss. Fix these in the shared ingestion helper rather than hiding them with runtime offsets or relaxed assertions. One intermediate compiler failure returned process0 while logging script errors; final compile/build/import logs are checked explicitly. Current assertion/gallery/build/import/idle runs pass.

## Remaining limits and play

Owner approved the installed visual result on 2026-10-07 as "100% spot on"; corrected Twinsteel and Greatsword proportions are now the accepted baseline.

Actual-player fixture shutdown warns6 ObjectDB instances/2 resources for Twinsteel and58/1 for Greatsword. Greatsword debt predates this pass; current Twinsteel warning is undiagnosed. This is not clean test teardown and does not establish normal-game leakage or performance. Encounter balance, device profiling and selected Iron Reaper work remain separate.

F5 → F9 → F7 → Weapons → Twinsteel or Royal Greatsword. WASD, held world LMB, Space dodge, Tab Bag; four seconds still triggers proud rest. Direct `tools/launch_king_twinsteel_training.ps1` opens actual Combat Lab with non-saving storage and both weapons available in its Weapons tab. `owner_launch.log` / `owner_ready.json` record the refreshed owner window.

[Current guide](../../../../docs/design/king-cardinal-proportions.md) · [Decision191](../../../../docs/decisions/191-match-vertical-king-body-proportions.md).
