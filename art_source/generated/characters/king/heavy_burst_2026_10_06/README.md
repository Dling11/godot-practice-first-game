# Original heavy-burst source — 2026-10-06

Historical source retained for comparison. The owner defers scythe and chooses a Greatsword-only four-move preview. These original generated images remain, but their builder/resources are archived under art_source/archive/heavy_burst_first_study_2026_10_06/. Current [source/rebuild](../greatsword_front_combo_2026_10_06/README.md). Original commands below require restoring historical paths and are not the active workflow.

Built-in imagegen generated `body_source.png`, `slash_source.png`, and `scythe_source.png` with transparent backgrounds. `prompts.md` retains the submitted prompts and reference paths. The original generated images remain in the Codex generated_images directory; these are project copies. No Otherworld Legends pixels are used.

Body sheet:1536×1024, five rows/seven full bodies each. FX sheet:1536×1024, three rows/four keys. Scythe image:887×1774 (generator output differs from requested canvas). The builder uses its actual alpha bounds and records grip/density instead of assuming requested dimensions.

Rebuild from the project root:

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_heavy_burst_preview.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import
```

Outputs stay under `assets/characters/playable/king/heavy_burst_preview/`: five twelve-key side clips, five scythe resource variants borrowing those bodies, original FX and one scythe texture. Fixed density, native head/neck registration, drawn glove anchors and exact queued boundaries are recorded in `registration.json`; the new scythe's crop/grip is in `scythe_registration.json`. All22 PNG/TRES outputs reproduced identically. Existing accepted builders and runtime families remain unchanged.

[Design/research/limitations](../../../../../docs/design/king-heavy-burst-study.md).
