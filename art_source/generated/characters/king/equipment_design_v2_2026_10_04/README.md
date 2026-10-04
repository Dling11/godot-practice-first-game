# King equipment design V2 — 2026-10-04

Status: the owner approves this compact art style. Specific armor/weapon variant choices remain open; none is promoted to F5.

The owner authorizes simplifying or recreating armor and weapons to fit King's compact body. These three built-in image_gen calls use the existing exact King reference for identity/pixel style. Axe/scythe are designed separately from character poses, following the owner's explicit correction.

## View

- [Compact armor designs](armor/source.png): left Light Leather, middle Heartwood, right Forged Guard; front/back views.
- [Armor beside current King](armor/native_readability.png): actual960x540 Godot render, 1x and4x nearest views. Current King holds his existing sword; new outfits are unarmed.
- [Axe choices](axe/source.png): left Iron Beard, middle Split Crown, right Rootforged.
- [Scythe choices](scythe/source.png): left Iron Reaper, middle Ash Hook, right Rootspine.
- [Weapon size comparison](native_weapons.png): same original large weapon drawings rendered at one uniform1/16 scale beside current King;4x row enlarges those SAME crops, not the generator's independently drawn miniature duplicates.

My recommended armor candidate is Heartwood: one compact bark plate, small shoulder patches/cuffs, visible teal sleeves/legs and red scarf. This recommendation is not owner selection. Weapon choice remains open.

## Provenance and verification

Each family preserves source.png and exact prompt.txt. generation_manifest.json records built-in mode, reference, actual1536x1024 source dimensions and source checksums. source_audit.json records alpha samples/counts. Raw visible pixels have fractional alpha; backgrounds contain transparent pixels despite atmospheric RGB visible in some raw previews. The Godot render uses actual alpha on a flat backdrop, without background painting or artistic edits.

Offline review scripts are local to this source folder and are not campaign dependencies:
- audit_sources.gd: image metadata/alpha, no source changes.
- render_armor_readability.gd: one uniform1/16 new-armor scale versus current Body0.5; authored source windows/feet, no per-outfit fitting.
- render_weapon_readability.gd: one uniform1/16 across all six weapon candidates; alpha>=0.65 only measures occupied bounds for placement, while drawn alpha remains unchanged. weapon_readability.json retains measured sizes/crops.

Run from the project root:

    D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe --headless --path . --script res://art_source/generated/characters/king/equipment_design_v2_2026_10_04/audit_sources.gd
    D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe --path . --resolution 960x540 --script res://art_source/generated/characters/king/equipment_design_v2_2026_10_04/render_armor_readability.gd
    D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe --path . --resolution 960x540 --script res://art_source/generated/characters/king/equipment_design_v2_2026_10_04/render_weapon_readability.gd

These offline tools load original images directly and are not exportable gameplay scripts. Native Godot4.7.2/OpenGL comparison renders and the source audit completed successfully. No player was instantiated/equipped, no damage/save/recipe authority changed, and no animation was claimed.

## Production boundaries

These are designs, not runtime SpriteFrames or interchangeable armor masks. Recheck shape/grip rigidity, perspective, cardinal views and hand placement against the selected design. Raw alpha needs binary cleanup for production. The board's small weapon duplicates are additional generated sketches, not exact registered native sprites.

The original axe/scythe studies remain rejected under equipment_families_2026_10_04/. The previous detailed armor study remains an earlier candidate, not the compact-body production reference. Existing gear IDs, stats, Nema recipes and Varkuun progression remain unchanged.

Next: select weapon-only silhouettes; create canonical fixed-size/grip references; prove one actual King carry/swing plus corresponding armor action masks at native scale before bulk animation.
