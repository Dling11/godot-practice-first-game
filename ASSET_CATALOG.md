# Asset Catalog

This catalog is the canonical registry for approved and transitional Battle of Gods assets. Runtime code and scenes remain the final truth; correct this file whenever a path, status, or usage changes.

## Status Vocabulary

| Status | Meaning |
|---|---|
| `active_runtime` | Directly loaded by a current game scene or runtime resource. |
| `active_resource` | Godot scene/resource that assembles or presents runtime assets. |
| `source` | Original material retained for provenance or rebuilding. |
| `intermediate` | Cleaned or processed input used to produce runtime content. |
| `legacy` | Superseded experiment retained temporarily; must not be newly referenced. |
| `planned` | Stable identity reserved for an approved upcoming asset. |

Paths marked as migrated are current runtime truth. Remaining `Target path` entries describe later controlled destinations and do not claim that those migrations have already happened.

## Naming Contract

Canonical IDs use `<domain>_<identity>_<action-or-purpose>`. Runtime filenames use descriptive `snake_case` and add sheet/cell dimensions where useful.

```text
char_opaw_walk
char_forsaken_thrall_claw_attack
icon_skill_sweeping_cut
icon_skill_piercing_rush
ui_panel_dark
tile_forest_ground_bright
prop_sanctuary_fountain
audio_sfx_sword_hit
```

Do not introduce `final`, `new`, `fixed`, `better`, unexplained numbers, or contributor/user names into runtime filenames. Approved in-world character names such as `opaw`, `eira`, or `orren` are useful identities and should be used consistently. Git owns history; descriptive variants such as `mossy`, `winter`, or `corrupted` are allowed when both variants intentionally coexist.

## Active Character Art

| Canonical ID | Current runtime path | Target path/name | Size and grid | Runtime owner |
|---|---|---|---|---|
| `char_opaw_idle` | `assets/characters/playable/opaw/compact_armless/opaw_compact_armless_idle_sheet_32x32.png` | Active | 64x128; 2 frames x 4 direction rows; 32x32 cells | `opaw_compact_armless_sprite_frames.tres` |
| `char_opaw_walk` | `assets/characters/playable/opaw/compact_armless/opaw_compact_armless_walk_sheet_32x32.png` | Active | 128x128; 4 frames x 4 direction rows; 32x32 cells | `opaw_compact_armless_sprite_frames.tres` |
| `char_opaw_attack_body` | `assets/characters/playable/opaw/compact_armless/opaw_compact_armless_attack_body_sheet_48x32.png` | Active | 144x128; 3 phases x 4 direction rows; 48x32 cells | `opaw_compact_armless_sprite_frames.tres` |
| `char_opaw_dash` | `assets/characters/playable/opaw/compact_armless/opaw_compact_armless_dash_sheet_48x32.png` | Active | 144x128; 3 frames x 4 direction rows; 48x32 cells | `opaw_compact_armless_sprite_frames.tres` |
| `char_opaw_interact` | `assets/characters/playable/opaw/compact_armless/opaw_compact_armless_interact_sheet_48x32.png` | Active | 96x128; 2 frames x 4 direction rows; 48x32 cells | `opaw_compact_armless_sprite_frames.tres` |
| `char_opaw_hurt` | `assets/characters/playable/opaw/compact_armless/opaw_compact_armless_hurt_sheet_32x32.png` | Active | 64x128; 2 frames x 4 direction rows; 32x32 cells | `opaw_compact_armless_sprite_frames.tres` |
| `char_opaw_defeat` | `assets/characters/playable/opaw/compact_armless/opaw_compact_armless_defeat_sheet_64x32.png` | Active | 256x128; 4 frames x 4 direction rows; 64x32 cells | `opaw_compact_armless_sprite_frames.tres` |
| `char_opaw_frames` | `assets/characters/playable/opaw/compact_armless/opaw_compact_armless_sprite_frames.tres` | Active | Godot `SpriteFrames` | `player.tscn` |
| `char_forsaken_thrall_locomotion` | `assets/characters/enemies/forsaken_thrall/forsaken_thrall_locomotion_sheet_24x32.png` | Migrated | 96x128; 4x4 of 24x32 | `forsaken_thrall_sprite_frames.tres` |
| `char_forsaken_thrall_claw_attack` | `assets/characters/enemies/forsaken_thrall/forsaken_thrall_claw_attack_sheet_64x48.png` | Migrated | 384x192; 6x4 of 64x48 | `forsaken_thrall_sprite_frames.tres` |
| `char_forsaken_thrall_frames` | `assets/characters/enemies/forsaken_thrall/forsaken_thrall_sprite_frames.tres` | Migrated | Godot `SpriteFrames` | `forsaken_thrall.tscn` |
| `char_mireling_actions` | `assets/characters/enemies/mireling/mireling_action_sheet_32x32.png` | Migrated | 128x128; 4x4 of 32x32 | `mireling_sprite_frames.tres` |
| `char_mireling_frames` | `assets/characters/enemies/mireling/mireling_sprite_frames.tres` | Migrated | Godot `SpriteFrames` | `mireling.tscn` |
| `char_bramble_spitter_actions` | `assets/characters/enemies/bramble_spitter/bramble_spitter_action_sheet_32x32.png` | Migrated | 128x128; 4x4 of 32x32 | `bramble_spitter_sprite_frames.tres` |
| `char_bramble_spitter_frames` | `assets/characters/enemies/bramble_spitter/bramble_spitter_sprite_frames.tres` | Migrated | Godot `SpriteFrames` | `bramble_spitter.tscn` |

All active Opaw sheets use direction rows in canonical `down`, `left`, `right`, `up` order and animation frames as columns. `tools/process_opaw_compact_armless_assets.gd` isolates each padded generated cell, removes chroma, normalizes every direction reference to 18x27 on the shared foot baseline, and emits binary-alpha runtime sheets. Normal attack body columns map directly to wind-up, active, and recovery while the detached external weapon owns the visible blade arc. The complete previous Wayfarer model and former single 4x8 atlas have no active `SpriteFrames` references. Existing humanoid extended enemy attack sheets use directions as rows and six action phases as columns.

### Preserved Opaw Pipeline Material

These files are intentionally outside runtime imports under Godot-ignored `art_source/`:

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
| `char_opaw_wayfarer_original_action_set` | `art_source/generated/characters/playable/opaw/v2/opaw_idle_source.png` through `opaw_defeat_source.png` | `legacy_source` | Seven independently generated boards for the complete visual rollback |
| `char_opaw_wayfarer_original_action_set` | `art_source/generated/characters/playable/opaw/v2/opaw_idle_clean.png` through `opaw_defeat_clean.png` | `legacy_intermediate` | Chroma-cleaned boards for the complete visual rollback |
| `char_opaw_compact_armless_action_set` | `art_source/generated/characters/playable/opaw/compact_armless/opaw_compact_armless_*_source.png` | `source` | Seven original action boards; external screenshot used only for broad compact top-down readability/proportion reference |
| `char_opaw_compact_armless_action_set` | `art_source/generated/characters/playable/opaw/compact_armless/opaw_compact_armless_*_clean.png` | `intermediate` | Chroma-cleaned, palette-normalized source boards |
| `char_opaw_compact_armless_attack_vertical_revision` | `art_source/generated/characters/playable/opaw/compact_armless/opaw_compact_armless_attack_vertical_revision.png` | `source` | Corrected centered down/up rows; composed into the attack source without changing approved left/right rows |
| `char_opaw_modular_actions_legacy` | `art_source/generated/characters/playable/opaw/opaw_modular_action_source.png` | `legacy_source` | 1024x1536; superseded single board |
| `char_opaw_modular_actions_legacy` | `art_source/generated/characters/playable/opaw/opaw_modular_action_clean.png` | `legacy_intermediate` | 1024x1536; superseded single board |
| `char_opaw_handless_candidate` | `art_source/archive/characters/playable/opaw/review_variants/source/handless/opaw_attack_body_handless_imagegen_source.png` | `archived` | Rejected handless attack-pose exploration; outside Godot imports |

### Archived Opaw Experiments and Supported Rollback

| Canonical ID | Preserved path | Status | Contract |
|---|---|---|---|
| `char_opaw_handless_action_set` | `art_source/archive/characters/playable/opaw/review_variants/runtime/handless/` | `archived` | Rejected sleeve-ended seven-action comparison; no active build/test hooks |
| `char_opaw_armless_attack_prototype` | `art_source/archive/characters/playable/opaw/review_variants/runtime/armless/` | `archived` | Rejected attack-only no-arm experiment |
| `char_opaw_armless_small_feet_prototype` | `art_source/archive/characters/playable/opaw/review_variants/runtime/armless_small_feet/` | `archived` | Rejected attack-only compact-foot experiment |
| `char_opaw_review_variant_sources` | `art_source/archive/characters/playable/opaw/review_variants/source/` | `archived` | Source and cleaned material for the three rejected experiments |
| `char_opaw_review_variant_code` | `art_source/archive/characters/playable/opaw/review_variants/code/` | `archived` | Retired builders, smoke tests, and UID files; ignored by Godot |
| `char_opaw_wayfarer_original_backup` | `assets/characters/playable/opaw/variants/wayfarer_original/opaw_wayfarer_original_*_sheet_*.png` | `legacy` | Complete seven-sheet backup of the model active before the compact armless swap |
| `char_opaw_wayfarer_original_frames` | `assets/characters/playable/opaw/variants/wayfarer_original/opaw_wayfarer_original_sprite_frames.tres` | `legacy_resource` | Independently loadable rollback resource with animation parity |

### Preserved Legacy Awakened Material

These files are intentionally outside runtime imports under Godot-ignored `art_source/`:

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
| `char_awakened_runtime_legacy` | `art_source/archive/characters/playable/awakened_legacy/runtime/` | `archived` | Superseded locomotion, attack, imports, and `SpriteFrames`; outside Godot |
| `char_awakened_source_legacy` | `art_source/archive/characters/playable/awakened_legacy/source/` | `archived` | Original and cleaned Awakened generation material |

### Preserved Forsaken Thrall Pipeline Material

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
| `char_forsaken_thrall_locomotion` | `art_source/generated/characters/enemies/forsaken_thrall/forsaken_thrall_locomotion_source.png` | `source` | 1254x1254 |
| `char_forsaken_thrall_locomotion` | `art_source/generated/characters/enemies/forsaken_thrall/forsaken_thrall_locomotion_clean.png` | `intermediate` | 1254x1254 |
| `char_forsaken_thrall_claw_attack` | `art_source/generated/characters/enemies/forsaken_thrall/forsaken_thrall_claw_attack_source.png` | `source` | 1536x1024 |
| `char_forsaken_thrall_claw_attack` | `art_source/generated/characters/enemies/forsaken_thrall/forsaken_thrall_claw_attack_clean.png` | `intermediate` | 1536x1024 |

### Preserved Mireling Pipeline Material

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
| `char_mireling_actions` | `art_source/generated/characters/enemies/mireling/mireling_action_source.png` | `source` | 1254x1254 |
| `char_mireling_actions` | `art_source/generated/characters/enemies/mireling/mireling_action_clean.png` | `intermediate` | 1254x1254 |
| `char_mireling_actions` | `art_source/archive/characters/enemies/mireling/mireling_action_sheet_24x24_legacy.png` | `legacy` | 96x96; superseded 4x4 of 24x24 |

### Preserved Bramble Spitter Pipeline Material

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
| `char_bramble_spitter_actions` | `art_source/generated/characters/enemies/bramble_spitter/bramble_spitter_action_source.png` | `source` | 1254x1254 |
| `char_bramble_spitter_actions` | `art_source/generated/characters/enemies/bramble_spitter/bramble_spitter_action_clean.png` | `intermediate` | 1254x1254 |

## Active Environment Art

| Canonical ID | Current runtime path | Target path/name | Size and grid | Runtime owner |
|---|---|---|---|---|
| `tile_forest_ground_bright` | `assets/environment/prototype/bright_ground_atlas.png` | `assets/environment/forest/tiles/forest_ground_bright_atlas_64x64.png` | 128x128; 2x2 of 64x64 | `bright_ground_tileset.tres` |
| `tile_forest_ground_resource` | `assets/environment/prototype/bright_ground_tileset.tres` | `assets/environment/forest/tiles/forest_ground_tileset.tres` | Godot `TileSet` | Stage 1 and Stage 2 ground layers |
| `prop_forest_ancient_tree_base` | `assets/environment/prototype/polished_tree_base.png` | `assets/environment/forest/props/ancient_tree/ancient_tree_base.png` | 94x112 | `ancient_tree.tscn` |
| `prop_forest_ancient_tree_canopy` | `assets/environment/prototype/polished_tree_canopy.png` | `assets/environment/forest/props/ancient_tree/ancient_tree_canopy.png` | 94x112 | `ancient_tree.tscn` |
| `prop_forest_ruined_statue` | `assets/environment/prototype/polished_statue.png` | `assets/environment/forest/props/ruined_statue/ruined_statue.png` | 81x104 | `ruined_statue.tscn` |
| `tile_sanctuary_ground_atlas` | `assets/environment/sanctuary/tiles/sanctuary_ground_atlas_64x64.png` | Active | 256x320; 4x5 of 64x64 | `sanctuary_ground_tileset.tres` |
| `tile_sanctuary_ground_resource` | `assets/environment/sanctuary/tiles/sanctuary_ground_tileset.tres` | Active | Godot `TileSet` | `sanctuary.tscn` |
| `landmark_sanctuary_angel_expedition_portal_structure` | `assets/environment/sanctuary/landmarks/angel_expedition_portal_192x192.png` | Active | 192x192; Y-sorted arch, guardians, and doorway | `expedition_altar.tscn` |
| `landmark_sanctuary_angel_expedition_portal_ground` | `assets/environment/sanctuary/landmarks/angel_expedition_portal_ground_192x192.png` | Active | 192x192; center stairs and threshold ground layer | `expedition_altar.tscn` |
| `prop_sanctuary_divine_fountain` | `assets/environment/sanctuary/landmarks/divine_fountain_112x96.png` | Active | 112x96; basin origin at bottom center; standalone walk-around footprint | `divine_fountain.tscn` |
| `building_sanctuary_skillkeeper_lodge` | `assets/environment/sanctuary/buildings/skillkeeper_lodge_128x192.png` | Active | 128x192; compact violet study, complete bottom-center origin | `skillkeeper_lodge.tscn` |
| `building_sanctuary_armskeeper_workshop` | `assets/environment/sanctuary/buildings/armskeeper_workshop_176x192.png` | Active | 176x192; warm smith/weapon workshop, complete bottom-center origin | `armskeeper_workshop.tscn` |
| `shop_sanctuary_armskeeper_cart` | `assets/environment/sanctuary/shops/armskeeper_cart_128x96.png` | Active | 128x96; complete prop-only cart with no baked character | `armskeeper_cart.tscn` |
| `prop_sanctuary_tree_broad` | `assets/environment/sanctuary/props/sanctuary_tree_broad_96x120.png` | Active | 96x120; footprint origin at bottom center | `sanctuary_tree_broad.tscn` |
| `prop_sanctuary_tree_tall` | `assets/environment/sanctuary/props/sanctuary_tree_tall_96x120.png` | Active | 96x120; footprint origin at bottom center | `sanctuary_tree_tall.tscn` |
| `char_npc_skillkeeper_idle` | `assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x48.png` | Active | 192x48; 4x1 compact Eira with detached book/wisp | `skillkeeper.tscn` |
| `char_npc_armskeeper_idle` | `assets/characters/npcs/armskeeper/armskeeper_idle_sheet_48x48.png` | Active | 192x48; 4x1 compact Orren with detached hammer/sword | `armskeeper.tscn` |

The Sanctuary source board is preserved at `art_source/generated/environment/sanctuary/sanctuary_direction_board_source.png`; only its terrain and tree crops remain active through `tools/process_sanctuary_direction_board.gd`. The standalone portal, fountain, compact Eira/Orren, skillkeeper lodge, armskeeper workshop, and cart are reproducible through `tools/process_sanctuary_individual_assets.gd`. Detached NPC props remain intentional within padded 48x48 cells. Prop scenes remain under `environment/props/` because they combine presentation with editable collision and idle effects. Superseded service crops/scenes/runtime files are archived and cannot be regenerated by the direction-board processor.

### Preserved Sanctuary Standalone Pipeline Material

These source and intermediate images remain outside Godot runtime imports:

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
| `landmark_sanctuary_angel_expedition_portal_structure` | `art_source/generated/environment/sanctuary/portal/angel_expedition_portal_source.png` | `source` | 1254x1254 |
| `landmark_sanctuary_angel_expedition_portal_structure` | `art_source/generated/environment/sanctuary/portal/angel_expedition_portal_clean.png` | `intermediate` | 1254x1254 |
| `prop_sanctuary_divine_fountain` | `art_source/generated/environment/sanctuary/fountain/divine_fountain_source.png` | `source` | 1254x1254 |
| `prop_sanctuary_divine_fountain` | `art_source/generated/environment/sanctuary/fountain/divine_fountain_clean.png` | `intermediate` | 1254x1254 |
| `char_npc_skillkeeper_idle` | `art_source/generated/characters/npcs/skillkeeper/skillkeeper_compact_source.png` | `source` | 1254x1254 |
| `char_npc_skillkeeper_idle` | `art_source/generated/characters/npcs/skillkeeper/skillkeeper_compact_clean.png` | `intermediate` | 1254x1254 |
| `char_npc_armskeeper_idle` | `art_source/generated/characters/npcs/armskeeper/armskeeper_compact_source.png` | `source` | 1254x1254 |
| `char_npc_armskeeper_idle` | `art_source/generated/characters/npcs/armskeeper/armskeeper_compact_clean.png` | `intermediate` | 1254x1254 |
| `building_sanctuary_skillkeeper_lodge` | `art_source/generated/environment/sanctuary/services/skillkeeper_lodge_source.png` | `source` | 1254x1254 |
| `building_sanctuary_armskeeper_workshop` | `art_source/generated/environment/sanctuary/services/armskeeper_workshop_source.png` | `source` | 1254x1254 |
| `shop_sanctuary_armskeeper_cart` | `art_source/generated/environment/sanctuary/services/armskeeper_cart_source.png` | `source` | 1254x1254 |
| `sanctuary_service_legacy_pass` | `art_source/archive/environment/sanctuary/legacy_service_pass/` | `archived` | Replaced scenes, runtime files, and reviewed legacy PNGs |
| `landmark_sanctuary_angel_portal_fountain` | `art_source/archive/environment/sanctuary/angel_portal_fountain_256x240_legacy.png` | `legacy` | 256x240; superseded combined runtime crop |

## Active UI and Effects

Current UI visuals combine the approved reusable base theme and named pixel icons with scene-local `StyleBoxFlat`, labels, polygons, and lines for semantic states and effects.

| Canonical ID | Current path | Status | Purpose |
|---|---|---|---|
| `ui_combat_hud` | `ui/combat_hud.tscn` | `active_resource` | Vitality, progression, character/satchel entry, interaction prompt, and skills 1-4. |
| `ui_character_menu` | `ui/character_menu.tscn` | `active_resource` | Paused owned Gear/Armory and Active Skills surface for Opaw. |
| `ui_weapon_shop_menu` | `ui/shops/weapon_shop_menu.tscn` | `active_resource` | Orren's paused class-aware weapon purchase surface. |
| `ui_equipment_item_card` | `ui/equipment/equipment_item_card.tscn` | `active_resource` | Focusable owned-item equip card. |
| `ui_equipment_slot_card` | `ui/equipment/equipment_slot_card.tscn` | `active_resource` | Reusable equipped or empty slot presentation. |
| `ui_equipment_detail_panel` | `ui/equipment/equipment_detail_panel.tscn` | `active_resource` | Lore, authoritative weapon power, ownership/equip state, and restrained aura presentation. |
| `ui_title_screen` | `ui/screens/title/title_screen.tscn` | `active_resource` | Main navigation, session-audio settings, and new-journey entry. |
| `ui_title_background` | `ui/screens/title/title_background.tscn` | `active_resource` | Replaceable title presentation layers and restrained atmosphere. |
| `ui_dialogue_panel` | `ui/dialogue/dialogue_panel.tscn` | `active_resource` | Paused multi-line NPC dialogue presentation. |
| `ui_expedition_menu` | `ui/expeditions/expedition_menu.tscn` | `active_resource` | Sanctuary route selection and sealed-route previews. |
| `ui_enemy_health_bar` | `ui/world/enemy_health_bar.tscn` | `active_resource` | Damage-triggered world-space enemy health. |
| `ui_damage_number` | `ui/world/damage_number.tscn` | `active_resource` | Short-lived accepted-hit values. |
| `fx_summon` | `gameplay/encounters/summon_effect.tscn` | `active_resource` | Enemy materialization presentation. |
| `fx_hit_burst` | `gameplay/presentation/hit_burst.tscn` | `active_resource` | Accepted-hit pixel burst. |
| `fx_bramble_seed_impact` | `gameplay/projectiles/bramble_seed_impact.tscn` | `active_resource` | Seed collision presentation. |
| `fx_opaw_piercing_rush` | `assets/skills/opaw/warrior/piercing_rush/opaw_piercing_rush_vfx_sheet_192x192.png` | `active_runtime` | Six 192x192 cells in a 3x2 atlas; right-facing charge, ignition, lance, peak plume, shock ring, and decay frames rotated by presentation. |
| `fx_opaw_piercing_rush_source` | `art_source/generated/skills/opaw/piercing_rush/opaw_piercing_rush_vfx_source_v1.png` | `source` | 1536x1024 generated 3x2 chroma board preserved outside runtime loading. |
| `fx_opaw_piercing_rush_clean` | `art_source/generated/skills/opaw/piercing_rush/opaw_piercing_rush_vfx_clean_v1.png` | `intermediate` | 1536x1024 alpha-clean source consumed by `tools/process_piercing_rush_vfx.gd`. |

### Reusable Theme and Icon Kit

| Canonical ID | Runtime path | Status | Purpose |
|---|---|---|---|
| `theme_battle_of_gods` | `assets/ui/themes/battle_of_gods_theme.tres` | `active_resource` | Shared panels, labels, buttons, progress bars, focus, disabled, separators, and tooltips. |
| `icon_action_primary_attack` | `assets/ui/icons/actions/icon_action_primary_attack_24x24.png` | `active_runtime` | Primary melee/Ashwood Blade action symbol. |
| `icon_action_dash` | `assets/ui/icons/actions/icon_action_dash_24x24.png` | `active_runtime` | Supernatural dash symbol. |
| `icon_skill_sweeping_cut` | `assets/ui/icons/skills/icon_skill_sweeping_cut_24x24.png` | `active_runtime` | Wide sword-arc skill symbol. |
| `icon_skill_piercing_rush` | `assets/ui/icons/skills/icon_skill_piercing_rush_24x24.png` | `active_runtime` | White spirit-thrust symbol for Opaw's equipped Skill 1. |
| `icon_currency_coin` | `assets/ui/icons/economy/icon_currency_coin_16x16.png` | `active_runtime` | Run coin readout and future shop currency. |
| `icon_status_health` | `assets/ui/icons/status/icon_status_health_16x16.png` | `active_runtime` | Player vitality symbol. |
| `icon_status_experience` | `assets/ui/icons/status/icon_status_experience_16x16.png` | `active_runtime` | XP and level-progress symbol. |
| `icon_interaction_portal` | `assets/ui/icons/interactions/icon_interaction_portal_16x16.png` | `active_runtime` | Contextual stage-travel prompt. |
| `icon_interaction_talk` | `assets/ui/icons/interactions/icon_interaction_talk_16x16.png` | `active_runtime` | Reserved presentation for the first NPC interaction. |
| `icon_slot_locked` | `assets/ui/icons/states/icon_slot_locked_16x16.png` | `active_runtime` | Sealed skill or unavailable-feature state. |
| `icon_inventory_bag` | `assets/ui/icons/inventory/icon_inventory_bag_24x24.png` | `active_runtime` | Visible Character/Gear menu entry on the combat HUD. |

The icons are reproducibly built by `tools/build_ui_icon_kit.gd` from the approved palette. They use binary alpha and remain independently replaceable at their stable paths.

### Active Equipment Presentation

| Canonical ID | Runtime path | Status | Contract and owner |
|---|---|---|---|
| `item_weapon_ashwood_blade_world` | `assets/items/weapons/world/ashwood_blade_16x24.png` | `active_runtime` | Binary-alpha visible weapon shared by `WeaponDefinition`, detached-orbit `PlayerWeaponVisual`, and grip-aligned character preview. |
| `item_weapon_ashwood_blade_icon` | `assets/items/weapons/icons/ashwood_blade_64x64.png` | `active_runtime` | Compact-palette Wood-rank portrait used by `ashwood_blade.tres`. |
| `item_weapon_iron_sword_world` | `assets/items/weapons/world/iron_sword_16x24.png` | `active_runtime` | Binary-alpha Warrior sword bought from Orren and consumed by `iron_sword.tres` plus detached presentation. |
| `item_weapon_iron_sword_icon` | `assets/items/weapons/icons/iron_sword_64x64.png` | `active_runtime` | Pale-steel Iron-rank inventory and shop portrait. |
| `item_weapon_wayfarers_iron` | `assets/items/weapons/icons/wayfarers_iron_64x64.png` | `legacy` | Former A-grade preview; no active showcase reference. |
| `item_weapon_gloamfang` | `assets/items/weapons/icons/gloamfang_64x64.png` | `legacy` | Former S-grade preview; no active showcase reference. |
| `item_weapon_sunroot_oath` | `assets/items/weapons/icons/sunroot_oath_64x64.png` | `legacy` | Former Legendary preview; no active showcase reference. |
| `item_weapon_veilrender` | `assets/items/weapons/icons/veilrender_64x64.png` | `legacy` | Former Mythic preview; no active showcase reference. |

The Ashwood Blade originates at `art_source/generated/items/weapons/ashwood_blade/ashwood_blade_source.png`; its cleaned intermediate is preserved beside it. `tools/process_opaw_modular_assets.gd` produces both the 16x24 world texture and the 64x64 inventory icon with binary alpha and compact palettes. Iron Sword follows the same runtime contract: its generated chroma-key source and cleaned intermediate live under `art_source/generated/items/weapons/iron_sword/`, and `tools/process_iron_sword.gd` deterministically emits both active textures. Rarity borders, labels, and aura animation are not baked into item art.

The four legacy portraits originate from `art_source/generated/items/weapons/equipment_weapon_atlas_source.png`; the chroma-cleaned board and `tools/process_equipment_weapon_atlas.gd` remain preserved for provenance but must not restore active player-facing references without a new equipment decision.

## Planned Reusable UI Kit

| Canonical ID | Target path | Specification |
|---|---|---|
| `ui_panel_dark` | `assets/ui/panels/ui_panel_dark_9slice.png` | Replaceable dark panel surface with pixel-safe borders. |
| `ui_button_primary` | `assets/ui/buttons/` | Normal, hover, pressed, focus, and disabled states. |

Icons identify presentation concepts only. Gameplay logic refers to skill/item definitions and stable IDs, never to texture filenames.

## Screen Backgrounds

| Canonical ID | Target path | Status | Replacement contract |
|---|---|---|---|
| `bg_title_forest_sanctuary` | `assets/ui/backgrounds/title/title_forest_sanctuary.png` | `active_runtime` | 960x540 deterministic base image; no logo, buttons, or text baked in; built by `tools/build_title_background.gd`. |
| `bg_loading_forest` | `assets/ui/backgrounds/loading/loading_forest.png` | `planned` | Decorative-only; loading logic remains scene-owned. |
| `bg_dialogue_dark` | `assets/ui/backgrounds/dialogue/dialogue_dark_9slice.png` | `planned` | Reusable dialogue panel, not NPC-specific. |

Backgrounds are replaceable presentation dependencies. Screen scripts and focus/navigation paths must remain stable when the texture changes.

## Active Audio

| Canonical ID | Path | Status |
|---|---|---|
| `audio_music_forest_cathedral` | `assets/audio/music/cathedral_in_the_forest.ogg` | `active_runtime` |
| `audio_sfx_sword_swing` | `assets/audio/sfx/sword_swing.wav` | `active_runtime` |
| `audio_sfx_sword_hit` | `assets/audio/sfx/sword_hit.wav` | `active_runtime` |
| `audio_sfx_sweeping_cut` | `assets/audio/sfx/sweeping_cut.wav` | `active_runtime` |
| `audio_sfx_dash` | `assets/audio/sfx/dash.wav` | `active_runtime` |
| `audio_sfx_player_hurt` | `assets/audio/sfx/player_hurt.wav` | `active_runtime` |
| `audio_sfx_thrall_claw` | `assets/audio/sfx/thrall_claw.wav` | `active_runtime` |
| `audio_sfx_mireling_leap` | `assets/audio/sfx/mireling_leap.wav` | `active_runtime` |
| `audio_sfx_mireling_land` | `assets/audio/sfx/mireling_land.wav` | `active_runtime` |
| `audio_sfx_bramble_spit` | `assets/audio/sfx/bramble_spit.wav` | `active_runtime` |
| `audio_sfx_bramble_impact` | `assets/audio/sfx/bramble_impact.wav` | `active_runtime` |

Audio provenance remains in `assets/audio/ATTRIBUTION.md`.

## Transitional and Legacy Material

These patterns are not approved runtime naming. Preserve them during migration, then move them into `art_source/` with recorded provenance:

| Current pattern/path | Status | Rule |
|---|---|---|
| `assets/characters/prototype/` | `legacy` | Do not add new runtime references. |
| `*_source.png` | `source` | Preserve original generation/download/handmade input. |
| `*_clean.png` | `intermediate` | Preserve when required by a reproducible build script. |
| `art_source/archive/characters/enemies/mireling/mireling_action_sheet_24x24_legacy.png` | `legacy` | Preserved superseded 24x24 sheet; never load at runtime. |
| `assets/environment/prototype/dark_*` and unpolished ground/prop variants | `legacy` or `source` | Classify individually before moving; do not delete blindly. |
| `assets/environment/prototype/bright_*_source.png` | `source` | Retain for provenance, outside runtime assets after migration. |
| `art_source/generated/characters/awakened/` | `source` / `intermediate` | Preserved Awakened generation inputs; ignored by Godot and never loaded at runtime. |
| `art_source/generated/characters/enemies/forsaken_thrall/` | `source` / `intermediate` | Preserved Thrall generation inputs; ignored by Godot and never loaded at runtime. |
| `art_source/generated/characters/enemies/mireling/` | `source` / `intermediate` | Preserved Mireling generation inputs; ignored by Godot and never loaded at runtime. |
| `art_source/generated/characters/enemies/bramble_spitter/` | `source` / `intermediate` | Preserved Spitter generation inputs; ignored by Godot and never loaded at runtime. |
| `art_source/generated/environment/sanctuary/sanctuary_direction_board_source.png` | `source` | Approved generated direction board; never loaded by runtime scenes. |

The superseded first-round code-drawn Sanctuary sprites, scenes, import metadata, and generator were removed on 2026-07-14 after the generated kit passed replacement verification. Their design history remains in Decision 037 and `CHANGELOG.md`; they are not cataloged as available assets and must not be restored as runtime dependencies.

## Catalog Update Rule

Every asset change must answer:

1. What is its canonical ID?
2. Is it source, intermediate, runtime, legacy, or planned?
3. What exact file or resource uses it?
4. What dimensions, grid, origin, and palette constraints apply?
5. Where did it come from, and what license or generation process applies?
6. Does it replace an entry, add a variant, or create a new gameplay concept?
