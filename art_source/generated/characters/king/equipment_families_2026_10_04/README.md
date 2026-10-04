# King equipment studies — 2026-10-04

Status: generated concept studies, not installed equipment or production animation.

**Owner review, 2026-10-04:** Axe and scythe are rejected. Their originals remain for history; do not reuse their designs as production references. Next prepare weapon-only design choices before character posing, with stable proportions/grips and gameplay-size readability. Other studies remain concepts, not automatically accepted designs.

The owner authorized Sword, GreatSword, Dual sword, Axe, Scythe and visible armor/helmets. Pendants and other small accessories can remain stat-only. Generated with the built-in image_gen tool using the existing exact King reference; no command-line generator or external game assets were used.

## Studies

- [sword](sword/source.png): Agile single blade: quick opening cut, reverse cut, committed final slice. One weapon and one visible grip; the free hand balances the body.
- [greatsword](greatsword/source.png): Heavy two-handed blade: clear load-up, planted cleave, readable recovery. Preserve rigid blade length, both grips, and the corrected shoulder carry in the back view.
- [dual_swords](dual_swords/source.png): Two independently visible blades: alternating cuts and counter-rotation. Two visual contacts need deliberately authored hit windows and one attack damage budget.
- [axe](axe/source.png): Heavy crescent axe: loaded overhead/diagonal chop, strong contact, slower recovery. Maintain a rigid haft and blade head, grounded hips, and connected hands.
- [scythe](scythe/source.png): Long hooked blade: loaded reaping sweep with visible hand and shaft continuity. Consider an outer sweep and limited near-hilt contact only after gameplay testing.
- [armor](armor/source.png): Three outfit studies: Leather Scout, Steel Vanguard, Runic Guard, with front/back appearances and matching open helmets. These are not equipment layers or animation frames.

Each weapon source requests four carry directions in the first row and eight sequential right-facing attack poses across rows two and three. Armor requests three front outfits, three backs and three helmet closeups. These sources are appearance/pose studies, not proof that four-direction attacks or walking have been produced.

## Provenance

Each folder preserves the unchanged source.png and exact submitted prompt.txt. generation_manifest.json records mode, source location, reference, requested layout and actual output dimensions. source_audit.json measures raw alpha and nominal-grid bounds. Re-run with:

    D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe --headless --path . --script res://tools/audit_king_equipment_studies.gd

All five weapon outputs are 1448×1086 (nominal 4×3, 362px cells); armor is 1254×1254 (nominal 3×3, 418px cells). The requested sizes were different. Exact divisibility is not sufficient: visible drawings overlap some equal-cell boundaries, alpha is not binary, and apparent limb/weapon consistency requires manual review. No source has been sliced into runtime SpriteFrames.

## Next production proof

See [family/animation plan](../../../../../docs/design/king-weapon-family-and-basic-hit-redesign.md). Prepare one registered heavy attack at King's current gameplay body size; check hands, weapon construction, feet, timing and terrain contrast in Godot. Only then expand to four directions, real leg-exchange walking and equipment layers. Keep source artwork unchanged and retain registration manifests for derivatives.

## Inspiration

The owner suggested Pixel Slayer Saga after seeing an advertisement. Its [official listing](https://apps.apple.com/ph/app/pixel-slayer-saga/id6795060070) advertises weapon-dependent moves and appearance changes. That supports the equipment direction; the exact advertisement and actual frame timing have not been inspected. The generated studies were already underway before this reference arrived and use King, not Pixel Slayer imagery.
