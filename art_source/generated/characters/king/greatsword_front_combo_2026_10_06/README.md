# Greatsword four-move source

2026-10-06. Original built-in imagegen transparent source: `body_source.png` (four rows/eight complete bodies) and `slash_source.png` (four rows/four FX keys). `prompts.json` records submitted prompts, references and original generated filenames. Generator dimensions are not assumed; the builder reads actual image sizes. No Otherworld Legends artwork is copied.

`tools/build_king_front_combo_preview.gd` uses fixed density, actual foot/glove/neck registration and native accepted head pixels. The spin includes front, left and back identities. `registration.json` records both initial source metadata and final copied endpoint/head/grip/view metadata. Outputs stay in `assets/characters/playable/king/greatsword_front_combo_preview/`;13 PNG/TRES files reproduce identically. Native imports use lossless nearest sampling, no mipmaps and disabled alpha-border fixing.

Rebuild:

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_front_combo_preview.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import
```

[Current motion/scope](../../../../../docs/design/king-greatsword-front-combo.md). Existing Greatsword body/design/gait/idle remain installed; this source is for attack preview work only. Scythe is deferred.
