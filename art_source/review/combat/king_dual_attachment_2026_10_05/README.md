# Twinsteel — native front idle and wrist registration

**Partially accepted historical baseline:** The owner rates this pass about89% and requests planted front idle and steadier, uncrossed running carry. [Current polish and proof](../king_dual_steady_carry_2026_10_05/README.md).

2026-10-05. Owner rejects the previous pass's broad front body, displaced head and side-running grips. Current window: **TWINSTEEL / NATIVE IDLE & WRIST SYNC**. This remains a rewardless practice prototype, not normal F5 equipment.

Front idle copies the complete native `greatsword_cardinal/down/run.tres` cel0, with only a whole-cel translation to sole Y94. Its bounding silhouette is35×53 logical pixels versus the rejected48×54. No head graft, torso enlargement, quantization or frame scaling is applied to this idle. All released recoveries and standalone front entry copy that same pose.

Side run copies the original eight axe gait bodies exactly. Explicit closed-fist landmarks replace brown-pixel component centres that could select a forearm or belt. Body, both grips and finger overlays advance on the same pose key. Blade pitch follows each fist's vertical travel. Source head, legs, clothing and palette remain intact. Left mirrors the complete rig.

| Evidence | Boundary |
| --- | --- |
| before.png / after.png | Native-size-relative comparison of original gait, actual sword placement and front idle anatomy |
| motion.gif / motion_frames |105 native frames, full combo in four facings |
| gait/motion.gif |48 native frames, running at3× and actual game size |
| validation.json / motion_check.log |4333 checks, zero failures; includes exact native body comparisons |
| review_validation.json / review_check.log |113 actual controls, contacts, queue, pause and range checks; zero failures |
| before.json / after.json / scope_validation.json |15 files change,50 unchanged;92 protected heavy/source files unchanged |
| rebuild_validation.json | Current deterministic rebuild comparison |

Current builder remains `tools/build_king_dual_unified.gd`. `builder_before.txt` preserves the rejected version for investigation. Source sheet, original prompt and deterministic archived input remain under `art_source/generated/characters/king/dual_unified_2026_10_05/` and its documented input archive.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/launch_king_dual_twinsteel_review.ps1
```

WASD moves/faces, SPACE/click attacks, G plays five, Tab controls, Esc pause. Thrust/alternating cuts/hop spin/X,2.20s timing, damage, contact shapes, collision travel and physical back-stow depth remain unchanged. Owner motion acceptance and normal equipment integration remain pending. [Current design and rebuild](../../../../docs/design/king-dual-sword-design.md).
