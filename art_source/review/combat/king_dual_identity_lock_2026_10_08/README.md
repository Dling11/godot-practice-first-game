# Twinsteel gait, front cuts and proud idle correction

Completed2026-10-08. Installed on the existing Twinsteel item for owner visual review. The owner reports incorrect side gait, a wobbling front walking head, front cut fragments and a front rest that differs from the accepted sides.

[Animated four-camera native capture](motion.gif) · [actual front idle](idle_live_down.png) · [registered source metadata](registration.json) · [frozen King tracing reference](../../../reference/characters/king/native_identity_v1/README.md) · [original built-in source sheets/prompts](../../../generated/characters/king/dual_v2_cardinal_2026_10_07/README.md) · [current guide](../../../../docs/design/king-dual-v2-cardinal.md).

LEFT/RIGHT gait copies the accepted Greatsword side body atlas pixels exactly; both existing canonical swords follow its actual palms, with the far handle hidden behind the torso. Front gait uses the accepted Greatsword front body with the fixed native crown. Front idle and all five cuts ingest complete existing body-only source actors before frozen-head/collar/sole registration. Nominal source row crops were rejected because these boards overlap their grid bands; complete scarf-labelled components retain the intended drawing. The native source spin is a whole-body turn. Front rest plants swords beside the feet and folds arms, retaining the1.10s entry,1.40s neutral hold,4.20s slow glance and normal cancellation/retrieval.

This correction reuses existing generated dual sources; it does not claim fresh dual generation. Side/upper cuts, upper gait/idle, canonical steel, effects,2.20s phases, damage/reach/knockback/audio/controls/save IDs and all Greatsword resources remain. Front cuts use13 keys; other dual cuts retain16. The viewer reads each resource's own phase/queue windows. Ready/released and next-cut/queued endpoints match exactly.

## Verification

- `anatomy.log` / `anatomy_checks.json`:1068 checks,0 failures over251 corrected axe/dual poses; complete connected body, native crown, genuine glove grips, cell margins, no leaked guides and exact accepted side gait pixels.
- `native.log` / `motion_checks.json`:938 checks,0 failures;300 native presenter frames covering ready/gait/five cuts/planted idle in four facings. GIF samples every second frame at15fps; `motion_frames/` and `timeline.json` retain all poses. This gallery samples presentation; actual gameplay effects are separately checked below.
- `gameplay.log`:244 checks,0 failures in the actual Player/Lab/Bag, F9 ownership, equip/swap, held/queued combos, genuine contact targets, Skill/dodge/reactions, Stage I, complete opening/final white effects in all four facings. Existing6 ObjectDB/2-resource shutdown diagnostics remain.
- `idle.log` / `idle_checks.json`:100 checks,0 failures; actual four-facing ready/entry/neutral/slow glance, planted retrieval, resolved-travel cancellation, delayed callback cancellation and Greatsword swap. First glance occurs around2.52s rather than an abrupt entry turn. This fixture exits cleanly.
- [Combined rebuild/import/preservation evidence](../king_axe_identity_lock_2026_10_07/README.md):69 identical outputs,44 correct imports;472 pre-work files backed up with469 unchanged. The selected axe/dual profiles and axe verification script are the only changes in that protected set.

These passes do not establish owner feel approval, final encounter balance or an FPS benchmark. Cold campaign/Skill1/phone/export profiling and campaign acquisition remain open. Iron Reaper is deferred until owner review.

## Rebuild and play

Use Godot4.7.2: `--headless --path . --script res://tools/build_king_dual_identity_lock.gd`, then `--headless --editor --path . --import --quit`. `tools/king_native_identity.gd` owns offline registration. Outputs are sibling `dual_identity_lock/run` and `dual_identity_lock/down/` body/hand/resources plus candidate presentation. The stock Twinsteel profile already selects them. Existing source folders and native references are retained unchanged.

Restart F5 → F9 → F7 → Weapons → Twinsteel. WASD moves, held LMB repeats the combo, Space dodges, Tab opens Bag, Escape closes it. Direct actual non-saving Lab: `tools/launch_king_twinsteel_training.ps1`; the Weapons page also selects Iron Beard Axe. No commits/pushes/branches.
