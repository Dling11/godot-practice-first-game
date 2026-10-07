**Superseded on2026-10-06:** The owner clarified that the axe-head thrust must be third, before jump/spin. Current five-hit source/proof lives in axe_head_thrust_2026_10_06. This retained four-cut evidence is historical.

# Iron Beard rising-cut correction: retained assembly

2026-10-06. This correction generates no new source cels. tools/build_king_axe_flow.gd assembles the accepted native chop, rising cut, hop slam and whirlwind into connected thirteen-key clips for SIDE, UP and DOWN. Left mirrors SIDE. registration.json records all twelve source paths and the 156 delivered pose slots, including repeated and inherited cels.

The second side move reuses axe_proof/return.tres. Cardinal rising cuts reuse axe_cardinal/{up,down}/rise.tres. The unchanged original body/hand atlases remain the source of truth. Queued endpoint 12 becomes the next opening; released key 9 returns to accepted held guard. Weapon transforms retain reflected bases, real glove grips and the canonical axe.

The effect atlas copies entire accepted axe_proof_v3/swing.png rows 2,1,3,4 into rows 0,1,2,3 without cropping or repainting. Each of the sixteen source cels retains alpha padding. The current profile renders the complete cels at 1.1 world pixels per texel instead of clipping them to a fan. Melee data independently owns contact reach, direction and damage.

Runtime output: assets/characters/playable/king/axe_flow/ — 36 body/mask/resource files and one effect PNG. Current cut names are chop, rise, slam and spin. The rejected jab files and old builder are retained in [the archive](../../../../archive/king_axe_rejected_handle_jab_2026_10_06/README.md); the older axe_flow source sheet is rejected history.

Rebuild:

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_axe_flow.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import
```

Nearest filtering, lossless imports, no mipmaps and process/fix_alpha_border=false preserve native edges. protected_before.json snapshots 328 original axe/Greatsword/Twinsteel art files and sidecars. protection_result.json and generation_manifest.json record the final verification. Owner acceptance and effective combat balance cannot be established by hashes or automated checks. [Rules](../../../../../docs/design/king-axe-cardinal-motion.md), [native evidence](../../../../review/combat/king_axe_rise_2026_10_06/README.md).
