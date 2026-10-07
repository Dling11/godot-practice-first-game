# Iron Beard axe: front and back source

2026-10-06. Owner requests the missing upward/downward axe walking and basic attacks. Generated using the built-in imagegen tool, with the exact approved King side/front/back body board. Original transparent sheets and exact prompts are retained here; original tool outputs remain in the Codex generated-images folder.

- `approved_reference.png`: unmodified current side-axe body, approved native back/front walking cel0 and canonical Iron Beard axe, enlarged with nearest sampling for the reference board.
- `up_body_source.png` / `down_body_source.png`: five rows of eight complete body-only cels each. Connected scarf/head, sleeves/gloves and boots; no weapon or slash baked into them.
- `prompts.json`: complete generation prompts.
- `registration.json`: shared density, per-source bounds and final head, sole and grip registration.
- `protected_before.json` / `protection_result.json`: hashes of the preexisting families, canonical weapons and shared presentation code. The only intended existing-family change is Iron Beard's profile binding six cardinal clips.
- `runtime_hashes.json` / `generation_manifest.json`: delivered outputs and reproducibility evidence.

`tools/build_king_axe_cardinal.gd` registers both sheets to the approved native head/palette at one fixed density, on a94-texel sole plane. It uses the existing offline anatomy helpers without invoking their Greatsword builder. Source gloves determine rigid axe grips; final connected silhouettes are grounded after speck removal. Front heads follow the drawn crown and connected pale-face/chin component; asymmetric scarf pixels and unrelated glove highlights cannot shift the face or leave the old chin behind. Above-head poses keep the axe head above the crown in either view. Only the fourth attack has explicit authored hop lift. Each released attack returns to the same held guard.

The held/rest clip includes eight keys: held guard, overhead back-stow preparation, then the complete approved native arms-down idle. The eight gait cels copy the accepted native King anatomy unchanged. One canonical axe texture is back-mounted; UP draws it over the actual back, DOWN behind the chest. Walking advances from actual travel through the existing Player adapter. All files live separately under `assets/characters/playable/king/axe_cardinal/up/` and `/down/`. Side axe, Greatsword, Twinsteel, contact geometry, timing and damage remain the existing baseline.

Rebuild from the project root:

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_axe_cardinal.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import
```

Keep nearest filtering, uncompressed raster imports and `process/fix_alpha_border=false`. The native proof and playing instructions are in `art_source/review/combat/king_axe_cardinal_2026_10_06/README.md`. Technical verification does not replace owner motion/art judgement.
