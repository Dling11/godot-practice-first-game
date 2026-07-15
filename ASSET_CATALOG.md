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
char_alden_walk
char_forsaken_thrall_claw_attack
icon_skill_sweeping_cut
ui_panel_dark
tile_forest_ground_bright
prop_sanctuary_fountain
audio_sfx_sword_hit
```

Do not introduce `final`, `new`, `fixed`, `better`, unexplained numbers, or contributor/user names into runtime filenames. Approved in-world character names such as `alden`, `eira`, or `orren` are useful identities and should be used consistently. Git owns history; descriptive variants such as `mossy`, `winter`, or `corrupted` are allowed when both variants intentionally coexist.

## Active Character Art

| Canonical ID | Current runtime path | Target path/name | Size and grid | Runtime owner |
|---|---|---|---|---|
| `char_alden_idle` | `assets/characters/playable/alden/alden_idle_sheet_32x32.png` | Active | 64x128; 2 frames x 4 direction rows; 32x32 cells | `alden_sprite_frames.tres` |
| `char_alden_walk` | `assets/characters/playable/alden/alden_walk_sheet_32x32.png` | Active | 128x128; 4 frames x 4 direction rows; 32x32 cells | `alden_sprite_frames.tres` |
| `char_alden_attack_body` | `assets/characters/playable/alden/alden_attack_body_sheet_48x32.png` | Active | 144x128; 3 phases x 4 direction rows; 48x32 cells | `alden_sprite_frames.tres` |
| `char_alden_dash` | `assets/characters/playable/alden/alden_dash_sheet_48x32.png` | Active | 144x128; 3 frames x 4 direction rows; 48x32 cells | `alden_sprite_frames.tres` |
| `char_alden_interact` | `assets/characters/playable/alden/alden_interact_sheet_48x32.png` | Active | 96x128; 2 frames x 4 direction rows; 48x32 cells | `alden_sprite_frames.tres` |
| `char_alden_hurt` | `assets/characters/playable/alden/alden_hurt_sheet_32x32.png` | Active | 64x128; 2 frames x 4 direction rows; 32x32 cells | `alden_sprite_frames.tres` |
| `char_alden_defeat` | `assets/characters/playable/alden/alden_defeat_sheet_64x32.png` | Active | 256x128; 4 frames x 4 direction rows; 64x32 cells | `alden_sprite_frames.tres` |
| `char_alden_frames` | `assets/characters/playable/alden/alden_sprite_frames.tres` | Active | Godot `SpriteFrames` | `player.tscn` |
| `char_forsaken_thrall_locomotion` | `assets/characters/enemies/forsaken_thrall/forsaken_thrall_locomotion_sheet_24x32.png` | Migrated | 96x128; 4x4 of 24x32 | `forsaken_thrall_sprite_frames.tres` |
| `char_forsaken_thrall_claw_attack` | `assets/characters/enemies/forsaken_thrall/forsaken_thrall_claw_attack_sheet_64x48.png` | Migrated | 384x192; 6x4 of 64x48 | `forsaken_thrall_sprite_frames.tres` |
| `char_forsaken_thrall_frames` | `assets/characters/enemies/forsaken_thrall/forsaken_thrall_sprite_frames.tres` | Migrated | Godot `SpriteFrames` | `forsaken_thrall.tscn` |
| `char_mireling_actions` | `assets/characters/enemies/mireling/mireling_action_sheet_32x32.png` | Migrated | 128x128; 4x4 of 32x32 | `mireling_sprite_frames.tres` |
| `char_mireling_frames` | `assets/characters/enemies/mireling/mireling_sprite_frames.tres` | Migrated | Godot `SpriteFrames` | `mireling.tscn` |
| `char_bramble_spitter_actions` | `assets/characters/enemies/bramble_spitter/bramble_spitter_action_sheet_32x32.png` | Migrated | 128x128; 4x4 of 32x32 | `bramble_spitter_sprite_frames.tres` |
| `char_bramble_spitter_frames` | `assets/characters/enemies/bramble_spitter/bramble_spitter_sprite_frames.tres` | Migrated | Godot `SpriteFrames` | `bramble_spitter.tscn` |

All active Alden sheets use direction rows in canonical `down`, `left`, `right`, `up` order and animation frames as columns. `tools/process_alden_modular_assets.gd` isolates each padded generated cell, removes chroma, normalizes every direction reference to 18x27 on the shared foot baseline, and emits binary-alpha runtime sheets. Normal attack body columns map directly to wind-up, active, and recovery while the external weapon owns the visible blade arc. The former single 4x8 Alden atlas is preserved as superseded runtime material and has no active `SpriteFrames` reference. Existing humanoid extended enemy attack sheets use directions as rows and six action phases as columns.

### Preserved Alden Pipeline Material

These files are intentionally outside runtime imports under Godot-ignored `art_source/`:

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
| `char_alden_action_set` | `art_source/generated/characters/playable/alden/v2/alden_idle_source.png` through `alden_defeat_source.png` | `source` | Seven independently generated action boards |
| `char_alden_action_set` | `art_source/generated/characters/playable/alden/v2/alden_idle_clean.png` through `alden_defeat_clean.png` | `intermediate` | Chroma-cleaned source boards |
| `char_alden_modular_actions_legacy` | `art_source/generated/characters/playable/alden/alden_modular_action_source.png` | `legacy_source` | 1024x1536; superseded single board |
| `char_alden_modular_actions_legacy` | `art_source/generated/characters/playable/alden/alden_modular_action_clean.png` | `legacy_intermediate` | 1024x1536; superseded single board |

### Preserved Legacy Awakened Material

These files are intentionally outside runtime imports under Godot-ignored `art_source/`:

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
| `char_awakened_locomotion` | `assets/characters/awakened/awakened_locomotion_sheet_24x32.png` | `legacy` | 96x128; superseded active player sheet |
| `char_awakened_sword_attack` | `assets/characters/awakened/awakened_sword_attack_sheet_64x48.png` | `legacy` | 384x192; superseded active player attack sheet |
| `char_awakened_frames` | `assets/characters/awakened/awakened_sprite_frames.tres` | `legacy` | Superseded Godot `SpriteFrames` |
| `char_awakened_locomotion` | `art_source/generated/characters/awakened/awakened_locomotion_source.png` | `source` | 1254x1254 |
| `char_awakened_locomotion` | `art_source/generated/characters/awakened/awakened_locomotion_clean.png` | `intermediate` | 1254x1254 |
| `char_awakened_sword_attack` | `art_source/generated/characters/awakened/awakened_sword_attack_source.png` | `source` | 1536x1024 |
| `char_awakened_sword_attack` | `art_source/generated/characters/awakened/awakened_sword_attack_clean.png` | `intermediate` | 1536x1024 |

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
| `building_sanctuary_mushroom_dwelling` | `assets/environment/sanctuary/buildings/mushroom_dwelling_128x192.png` | Active | 128x192; base origin at bottom center | `mushroom_dwelling.tscn` |
| `building_sanctuary_merchant_hall` | `assets/environment/sanctuary/buildings/merchant_hall_176x192.png` | Active | 176x192; base origin at bottom center | `merchant_hall.tscn` |
| `shop_sanctuary_weapon_stall` | `assets/environment/sanctuary/shops/weapon_stall_128x96.png` | Active | 128x96; base origin at bottom center | `weapon_stall.tscn` |
| `prop_sanctuary_tree_broad` | `assets/environment/sanctuary/props/sanctuary_tree_broad_96x120.png` | Active | 96x120; footprint origin at bottom center | `sanctuary_tree_broad.tscn` |
| `prop_sanctuary_tree_tall` | `assets/environment/sanctuary/props/sanctuary_tree_tall_96x120.png` | Active | 96x120; footprint origin at bottom center | `sanctuary_tree_tall.tscn` |
| `char_npc_skillkeeper_idle` | `assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x80.png` | Active | 192x80; 4x1 of 48x80; full staff and book silhouette | `skillkeeper.tscn` |
| `char_npc_weapon_merchant_idle` | `assets/characters/npcs/weapon_merchant/weapon_merchant_idle_sheet_48x72.png` | Active | 192x72; 4x1 of 48x72; standalone full-body silhouette with both hands inside every cell | `weapon_merchant.tscn` |

The Sanctuary source board is preserved at `art_source/generated/environment/sanctuary/sanctuary_direction_board_source.png`; its exact terrain/building/stall/tree/Eira crops, per-asset border cleanup, outline, scale, idle-frame, and tile-atlas build are reproducible through `tools/process_sanctuary_direction_board.gd`. The standalone portal, fountain, and Orren assets are reproducible through `tools/process_sanctuary_individual_assets.gd`. Character crop bounds must include transparent source-space breathing room around limbs and held props. The prop scenes remain under `environment/props/` because they combine presentation with collision, navigation, occlusion, and behavior. Raster art stays under `assets/`.

### Preserved Sanctuary Standalone Pipeline Material

These source and intermediate images remain outside Godot runtime imports:

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
| `landmark_sanctuary_angel_expedition_portal_structure` | `art_source/generated/environment/sanctuary/portal/angel_expedition_portal_source.png` | `source` | 1254x1254 |
| `landmark_sanctuary_angel_expedition_portal_structure` | `art_source/generated/environment/sanctuary/portal/angel_expedition_portal_clean.png` | `intermediate` | 1254x1254 |
| `prop_sanctuary_divine_fountain` | `art_source/generated/environment/sanctuary/fountain/divine_fountain_source.png` | `source` | 1254x1254 |
| `prop_sanctuary_divine_fountain` | `art_source/generated/environment/sanctuary/fountain/divine_fountain_clean.png` | `intermediate` | 1254x1254 |
| `char_npc_weapon_merchant_idle` | `art_source/generated/characters/npcs/weapon_merchant/weapon_merchant_idle_source.png` | `source` | 1254x1254 |
| `char_npc_weapon_merchant_idle` | `art_source/generated/characters/npcs/weapon_merchant/weapon_merchant_idle_clean.png` | `intermediate` | 1254x1254 |
| `landmark_sanctuary_angel_portal_fountain` | `art_source/archive/environment/sanctuary/angel_portal_fountain_256x240_legacy.png` | `legacy` | 256x240; superseded combined runtime crop |

## Active UI and Effects

Current UI visuals combine the approved reusable base theme and named pixel icons with scene-local `StyleBoxFlat`, labels, polygons, and lines for semantic states and effects.

| Canonical ID | Current path | Status | Purpose |
|---|---|---|---|
| `ui_combat_hud` | `ui/combat_hud.tscn` | `active_resource` | Vitality, progression, character/satchel entry, interaction prompt, and skills 1-4. |
| `ui_character_menu` | `ui/character_menu.tscn` | `active_resource` | Paused Gear/Armory and Active Skills surface for Alden. |
| `ui_equipment_item_card` | `ui/equipment/equipment_item_card.tscn` | `active_resource` | Focusable rarity/item preview card. |
| `ui_equipment_slot_card` | `ui/equipment/equipment_slot_card.tscn` | `active_resource` | Reusable equipped or empty slot presentation. |
| `ui_equipment_detail_panel` | `ui/equipment/equipment_detail_panel.tscn` | `active_resource` | Lore, preview power, inactive synergy, and restrained aura presentation. |
| `ui_title_screen` | `ui/screens/title/title_screen.tscn` | `active_resource` | Main navigation, session-audio settings, and new-journey entry. |
| `ui_title_background` | `ui/screens/title/title_background.tscn` | `active_resource` | Replaceable title presentation layers and restrained atmosphere. |
| `ui_dialogue_panel` | `ui/dialogue/dialogue_panel.tscn` | `active_resource` | Paused multi-line NPC dialogue presentation. |
| `ui_expedition_menu` | `ui/expeditions/expedition_menu.tscn` | `active_resource` | Sanctuary route selection and sealed-route previews. |
| `ui_enemy_health_bar` | `ui/world/enemy_health_bar.tscn` | `active_resource` | Damage-triggered world-space enemy health. |
| `ui_damage_number` | `ui/world/damage_number.tscn` | `active_resource` | Short-lived accepted-hit values. |
| `fx_summon` | `gameplay/encounters/summon_effect.tscn` | `active_resource` | Enemy materialization presentation. |
| `fx_hit_burst` | `gameplay/presentation/hit_burst.tscn` | `active_resource` | Accepted-hit pixel burst. |
| `fx_bramble_seed_impact` | `gameplay/projectiles/bramble_seed_impact.tscn` | `active_resource` | Seed collision presentation. |

### Reusable Theme and Icon Kit

| Canonical ID | Runtime path | Status | Purpose |
|---|---|---|---|
| `theme_battle_of_gods` | `assets/ui/themes/battle_of_gods_theme.tres` | `active_resource` | Shared panels, labels, buttons, progress bars, focus, disabled, separators, and tooltips. |
| `icon_action_primary_attack` | `assets/ui/icons/actions/icon_action_primary_attack_24x24.png` | `active_runtime` | Primary melee/Ashwood Blade action symbol. |
| `icon_action_dash` | `assets/ui/icons/actions/icon_action_dash_24x24.png` | `active_runtime` | Supernatural dash symbol. |
| `icon_skill_sweeping_cut` | `assets/ui/icons/skills/icon_skill_sweeping_cut_24x24.png` | `active_runtime` | Wide sword-arc skill symbol. |
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
| `item_weapon_ashwood_blade_world` | `assets/items/weapons/world/ashwood_blade_16x24.png` | `active_runtime` | Binary-alpha visible weapon shared by `WeaponDefinition`, grip-anchored `PlayerWeaponVisual`, and grip-aligned character preview. |
| `item_weapon_ashwood_blade_icon` | `assets/items/weapons/icons/ashwood_blade_64x64.png` | `active_runtime` | Compact-palette Wood-rank portrait used by `ashwood_blade.tres`. |
| `item_weapon_wayfarers_iron` | `assets/items/weapons/icons/wayfarers_iron_64x64.png` | `legacy` | Former A-grade preview; no active showcase reference. |
| `item_weapon_gloamfang` | `assets/items/weapons/icons/gloamfang_64x64.png` | `legacy` | Former S-grade preview; no active showcase reference. |
| `item_weapon_sunroot_oath` | `assets/items/weapons/icons/sunroot_oath_64x64.png` | `legacy` | Former Legendary preview; no active showcase reference. |
| `item_weapon_veilrender` | `assets/items/weapons/icons/veilrender_64x64.png` | `legacy` | Former Mythic preview; no active showcase reference. |

The Ashwood Blade originates at `art_source/generated/items/weapons/ashwood_blade/ashwood_blade_source.png`; its cleaned intermediate is preserved beside it. `tools/process_alden_modular_assets.gd` produces both the 16x24 world texture and the 64x64 inventory icon with binary alpha and compact palettes. Rarity borders, labels, and aura animation are not baked into item art.

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
