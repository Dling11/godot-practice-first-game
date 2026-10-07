# Twinsteel — existing-body carry registration

**Historical pass rejected/superseded later on2026-10-05.** Current complete body/thrust/hop builder is `tools/build_king_dual_unified.gd`; see [current guide](../../../../../docs/design/king-dual-sword-design.md). Do not run the older carry-only command below over the current set.

2026-10-05. The owner rejects the newly generated gait and requests the existing axe/Greatsword movement, two-sided running carry and crossed back stow. No images are generated or repainted in this correction.

`tools/build_king_dual_existing_gait.gd` copies whole192×128 cels unchanged:

| Facing | Running, keys0–7 | Idle |
| --- | --- | --- |
| Side | greatsword_confidence_v2/axe_run.tres | axe_proof_v3/carry.tres, key6 |
| Up/back | greatsword_cardinal/up/run.tres | greatsword_readability/up/idle.tres, key0 |
| Down/front | greatsword_cardinal/down/run.tres | greatsword_readability/down/idle.tres, key0 |

Paths are under `assets/characters/playable/king/`. Left mirrors the whole side body. No head graft, body resizing, palette processing or root shifting. Real idle heights57/44/45px preserve the source's existing vertical-size debt.

Running registers both actual outer-arm gloves, headings170°/10° with small stride tilt. Brown belt/boot pixels are excluded from vertical searches. Idle crosses35°/145° blades behind the body at shoulder attachments(85,54)/(107,54), with `stowed_poses=1` and transparent hand masks. Existing attack cels remain except standalone/released/final carry and coherent queued opening copies.

`registration.json` records48 source keys, body heights, both grips/headings and unchanged-body status. `before.json`/`after.json` cover65 runtime PNG/TRES files; `rebuild_validation.json` verifies65 identical carry-only rebuilds,63 intentional changes, unchanged blade/silver FX and92 unchanged protected heavy/source files. `full_rebuild_validation.json` also verifies65 identical outputs from the documented full attack/import/carry/FX/import pipeline. `heavy_before.json` preserves that source baseline.

Carry-only rebuild:

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_dual_existing_gait.gd
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import --quit
```

The full attack/FX build order is in the [current guide](../../../../../docs/design/king-dual-sword-design.md). Runtime uses only `assets/characters/playable/king/dual_twinsteel/`; no archive/source images are runtime dependencies. [Fresh native proof](../../../../review/combat/king_dual_existing_gait_2026_10_05/README.md). Owner visual approval remains open.
