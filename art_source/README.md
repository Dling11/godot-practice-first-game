# Art Source Workspace

Godot ignores this directory. It preserves concepts, original generated/downloaded/handmade images, cleaned intermediates, and superseded experiments without treating them as runtime assets.

Only approved, optimized files under `res://assets/` may be referenced by scenes and resources. Moving a file from here into runtime requires an `ASSET_CATALOG.md` entry, provenance, art-direction review, updated references, and verification.

## Character and Equipment Source Mapping

| Canonical asset | Preserved source/intermediate |
|---|---|
| `char_opaw_compact_armless_action_set` | `generated/characters/playable/opaw/compact_armless/opaw_compact_armless_idle_*`, `walk_*`, `attack_body_*`, `dash_*`, `interact_*`, `hurt_*`, `defeat_*` |
| `char_opaw_consecutive_thrust_rapid_body` | Runtime-only deterministic eight-beat sheet built from the approved `compact_armless` attack frames by `tools/build_opaw_consecutive_thrust_rapid_body.gd` |
| `fx_opaw_consecutive_thrust_rapid` | `generated/skills/opaw/consecutive_thrust/rapid_v3/opaw_consecutive_thrust_rapid_vfx_source_v3.png`, `opaw_consecutive_thrust_rapid_vfx_clean_v3.png` |
| `char_opaw_wayfarer_original_action_set` | `generated/characters/playable/opaw/v2/opaw_idle_*`, `opaw_walk_*`, `opaw_attack_body_*`, `opaw_dash_*`, `opaw_interact_*`, `opaw_hurt_*`, `opaw_defeat_*` |
| `char_opaw_modular_actions_legacy` | `generated/characters/playable/opaw/opaw_modular_action_source.png`, `opaw_modular_action_clean.png` |
| `item_weapon_ashwood_blade` | `generated/items/weapons/ashwood_blade/ashwood_blade_source.png`, `ashwood_blade_clean.png` |
| `item_weapon_iron_sword` | `generated/items/weapons/iron_sword/iron_sword_source.png`, `iron_sword_clean.png` |
| `char_awakened_legacy` | `archive/characters/playable/awakened_legacy/` |
| `char_forsaken_thrall_locomotion` | `generated/characters/enemies/forsaken_thrall/forsaken_thrall_locomotion_source.png`, `forsaken_thrall_locomotion_clean.png` |
| `char_forsaken_thrall_claw_attack` | `generated/characters/enemies/forsaken_thrall/forsaken_thrall_claw_attack_source.png`, `forsaken_thrall_claw_attack_clean.png` |
| `char_mireling_actions` | `generated/characters/enemies/mireling/mireling_action_source.png`, `mireling_action_clean.png` |
| `char_bramble_spitter_actions` | `generated/characters/enemies/bramble_spitter/bramble_spitter_action_source.png`, `bramble_spitter_action_clean.png` |

The compact armless Opaw boards are the active source set. `opaw_compact_armless_attack_vertical_revision.png` preserves the corrected centered down/up poses and is composed into the canonical attack board without replacing its approved side rows. The earlier `v2` boards are preserved provenance for the complete Wayfarer rollback under runtime `variants/wayfarer_original/`. The external game screenshot used during the compact pass was a broad proportion/readability reference only and is not copied or redistributed in the repository. Rejected Opaw variants, their retired builders/tests, the superseded Awakened presentation, and replaced Sanctuary service content live under `archive/` and are ignored by Godot. The Mireling's former 24x24 sheet is `archive/characters/enemies/mireling/mireling_action_sheet_24x24_legacy.png`.

Current Sanctuary service sources live under `generated/characters/npcs/skillkeeper/`, `generated/characters/npcs/armskeeper/`, and `generated/environment/sanctuary/services/`. `tools/process_sanctuary_individual_assets.gd` is their only active normalizer. The older direction-board service crops and standalone weapon-merchant material are preserved under `archive/` and must not regain runtime references.

The unreferenced root-level Opaw sheets once left beside the active compact set are archived at `archive/characters/playable/opaw/legacy_runtime_root/`. The incomplete Consecutive Thrust body/VFX board that did not match approved Opaw is archived at `archive/skills/opaw/consecutive_thrust_rejected_v1/`. Neither asset group may be promoted to runtime without a new reviewed design pass.

The active Consecutive Thrust effect source is explicitly effect-only: it contains no player body, hand, or sword-grade art. `tools/process_consecutive_thrust_rapid_vfx.gd` converts its reviewed white/gold/blue source into the runtime 6x2 192x192 atlas, while `tools/build_opaw_consecutive_thrust_rapid_body.gd` derives eight fast action beats from the already-approved compact-armless Opaw sheet. This keeps the skill compatible with future Warrior swords and avoids reintroducing the rejected mismatched character board. The superseded V2 source, runtime sheets, and builders are preserved under `archive/skills/opaw/consecutive_thrust_v2_replaced/`; replaced V3 swish audio is preserved under `archive/skills/opaw/consecutive_thrust_v3_replaced/`.
