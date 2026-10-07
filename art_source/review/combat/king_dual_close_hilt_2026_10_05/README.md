# Twinsteel — closer side hilts

2026-10-05. Owner accepts compact carry overall but requests closer swords during left/right running. Current window: **TWINSTEEL / CLOSER SIDE HILTS**.

Side `run.tres` now grips each blade at **(8,44)**, on upper leather just below the guard, instead of (8,50). Each sword sits **6 logical pixels / 3 world pixels** closer to its unchanged hip fist. The left view mirrors the same complete pose. No additional sprite offset, hand movement or weapon resize.

- `before.png` / `after.png`: same native side-running comparison, before/after this grip correction.
- `gait/motion.gif`: 48 native gait frames; four directions at 3× and actual game size.
- `motion.gif`: 105 native full-combo frames; accepted attack motion remains.
- `validation.json` / `cardinal.log`: 4455 checks, zero failures; grips, native anatomy/legs, compact blade, cardinal tilt and full combo.
- `review_validation.json` / `review.log`: 113 actual practice checks, zero failures; controls, buffering, contacts, blocked gait and reset/pause.
- `scope_validation.json` / `rebuild_validation.json`: 65 identical repeat-build outputs; only side `run.tres` changes, 64 runtime files and 92 protected files unchanged.

Blade texture, every body/mask PNG, accepted up/down views, planted idle, silver FX, combo timing/damage/range/travel remain identical to the compact baseline. The existing review restores idle carry before starting an attack. This remains dedicated rewardless practice, pending owner final side review and normal F5/equipment promotion.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/launch_king_dual_twinsteel_review.ps1
```

WASD runs/faces; SPACE/click attacks; G plays five; Tab controls; Esc pause. [Current rules/rebuild](../../../../docs/design/king-dual-sword-design.md).
