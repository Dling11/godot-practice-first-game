# Art Source Workspace

Godot ignores this directory. It preserves concepts, original generated/downloaded/handmade images, cleaned intermediates, and superseded experiments without treating them as runtime assets.

Only approved, optimized files under `res://assets/` may be referenced by scenes and resources. Moving a file from here into runtime requires an `ASSET_CATALOG.md` entry, provenance, art-direction review, updated references, and verification.

## Character and Equipment Source Mapping

| Canonical asset | Preserved source/intermediate |
|---|---|
| `char_alden_action_set` | `generated/characters/playable/alden/v2/alden_idle_*`, `alden_walk_*`, `alden_attack_body_*`, `alden_dash_*`, `alden_interact_*`, `alden_hurt_*`, `alden_defeat_*` |
| `char_alden_modular_actions_legacy` | `generated/characters/playable/alden/alden_modular_action_source.png`, `alden_modular_action_clean.png` |
| `item_weapon_ashwood_blade` | `generated/items/weapons/ashwood_blade/ashwood_blade_source.png`, `ashwood_blade_clean.png` |
| `char_awakened_locomotion` | `generated/characters/awakened/awakened_locomotion_source.png`, `awakened_locomotion_clean.png` |
| `char_awakened_sword_attack` | `generated/characters/awakened/awakened_sword_attack_source.png`, `awakened_sword_attack_clean.png` |
| `char_forsaken_thrall_locomotion` | `generated/characters/enemies/forsaken_thrall/forsaken_thrall_locomotion_source.png`, `forsaken_thrall_locomotion_clean.png` |
| `char_forsaken_thrall_claw_attack` | `generated/characters/enemies/forsaken_thrall/forsaken_thrall_claw_attack_source.png`, `forsaken_thrall_claw_attack_clean.png` |
| `char_mireling_actions` | `generated/characters/enemies/mireling/mireling_action_source.png`, `mireling_action_clean.png` |
| `char_bramble_spitter_actions` | `generated/characters/enemies/bramble_spitter/bramble_spitter_action_source.png`, `bramble_spitter_action_clean.png` |

The single-board Alden files and Awakened rows are legacy source provenance after the action-owned migration. Superseded but preserved runtime experiments live under `archive/`. The Mireling's former 24x24 sheet is `archive/characters/enemies/mireling/mireling_action_sheet_24x24_legacy.png`.
