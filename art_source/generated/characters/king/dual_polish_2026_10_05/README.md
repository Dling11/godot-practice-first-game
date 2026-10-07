# Twinsteel gait, scale and combo correction

**Historical generated gait — rejected by owner later on2026-10-05.** The current carry reuses unchanged existing axe/Greatsword bodies through `tools/build_king_dual_existing_gait.gd`; see [current guide](../../../../../docs/design/king-dual-sword-design.md). The silver FX source and attack forearm/angle polish below remain inputs, but the24-cel gait and55px standing fit are superseded. Append the existing-gait builder and an intervening import to the rebuild below. This folder's3693/109 checks do not establish owner visual acceptance.

2026-10-05. Owner reports short vertical bodies, broken side/front/back running and a pause between cuts. Current correction is playable only in the dedicated rewardless review. Original built-in imagegen outputs remain under `C:/Users/Administrator/.codex/generated_images/01a0eed4-5878-7032-a315-e493f92ce97a/`.

| Source | Exact prompt | Original generated output |
| --- | --- | --- |
| gait_source.png | gait_prompt.txt | exec-bbc9facc-8e30-4193-9bd5-6d53fcec2562.png |
| fx_clean_source.png, selected | fx_clean_prompt.txt | exec-353de2ac-ceb4-44d8-b6b2-3f7e63b47479.png |
| fx_source.png, retained first source | fx_prompt.txt | exec-1587625e-67c9-4932-a77c-45b82c2aaefb.png |

Gait has8 columns ×3 rows: right/front/back complete bodies,24 cels. References are the installed identity board and accepted side attack body sheet. Left mirrors the complete right body. FX has4 columns ×5 rows,20 silver slashes; the alpha edit retains their layout. Transparent RGB can look smoky in an alpha-unaware viewer; native compositing/alpha audit establish the actual background.

`tools/build_king_dual_polish.gd` reads original pose metadata/body/mask images from `art_source/archive/dual_cardinal_before_polish_2026_10_05/dual_twinsteel/`. It scales standing front/back to55 logical pixels and re-registers hilts. Each new gait row has one fixed density solved after complete directional head attachment. Boot Y stays grounded while head/torso X stays stable through alternating strides. Actual crouch/bob gives visible heights51–57px without cel zoom. Two erased side forearms are restored from original generated source pixels at the recorded54px source density. Linked copies inherit those repairs.

Attack resources opt into fixed-grip blade-angle interpolation and weights0=.05,11=.5,12=.05. The review uses generation-guarded deferred continuation; authority timing remains2.20s. Provisional contact is72px fan /58px spin /80px finish. `tools/build_king_dual_polish_fx.gd` reads only the selected alpha-clean source, packing20 frames into192px cells at fixed row density. Canonical Twinsteel blade pixels remain unchanged.

Historical rebuild; the current guide adds an import and existing-gait correction:

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_dual_polish.gd
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_dual_polish_fx.gd
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import --quit
```

Retain the archived metadata/images: deterministic offline inputs, ignored by exports and never referenced by runtime resources. Older initial builders alone would overwrite this correction.

`before.json`/`after.json` cover65 runtime PNG/TRES files. `rebuild_validation.json`:65 identical rebuilds,54 intentionally changed,79 protected heavy-family files unchanged. `generation_manifest.json` records source/prompt hashes. Registration files record original bounds, fixed density, root shift, head, both glove landmarks and FX placement. Native proof: `art_source/review/combat/king_dual_polish_2026_10_05/`.

Greatsword vertical44/45px against side54px remains follow-up debt. Passing current tests is not owner acceptance or final balance. [Current scope and next work](../../../../../docs/design/king-dual-sword-design.md).
