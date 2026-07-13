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
char_awakened_locomotion
char_forsaken_thrall_claw_attack
icon_skill_sweeping_cut
ui_panel_dark
tile_forest_ground_bright
prop_sanctuary_fountain
audio_sfx_sword_hit
```

Do not introduce `final`, `new`, `fixed`, `better`, unexplained numbers, or personal names into runtime filenames. Git owns history; descriptive variants such as `mossy`, `winter`, or `corrupted` are allowed when both variants intentionally coexist.

## Active Character Art

| Canonical ID | Current runtime path | Target path/name | Size and grid | Runtime owner |
|---|---|---|---|---|
| `char_awakened_locomotion` | `assets/characters/awakened/awakened_locomotion_sheet_24x32.png` | Migrated | 96x128; 4x4 of 24x32 | `awakened_sprite_frames.tres` |
| `char_awakened_sword_attack` | `assets/characters/awakened/awakened_sword_attack_sheet_64x48.png` | Migrated | 384x192; 6x4 of 64x48 | `awakened_sprite_frames.tres` |
| `char_awakened_frames` | `assets/characters/awakened/awakened_sprite_frames.tres` | Migrated | Godot `SpriteFrames` | `player.tscn` |
| `char_forsaken_thrall_locomotion` | `assets/characters/enemies/forsaken_thrall/forsaken_thrall_locomotion_sheet_24x32.png` | Migrated | 96x128; 4x4 of 24x32 | `forsaken_thrall_sprite_frames.tres` |
| `char_forsaken_thrall_claw_attack` | `assets/characters/enemies/forsaken_thrall/forsaken_thrall_claw_attack_sheet_64x48.png` | Migrated | 384x192; 6x4 of 64x48 | `forsaken_thrall_sprite_frames.tres` |
| `char_forsaken_thrall_frames` | `assets/characters/enemies/forsaken_thrall/forsaken_thrall_sprite_frames.tres` | Migrated | Godot `SpriteFrames` | `forsaken_thrall.tscn` |
| `char_mireling_actions` | `assets/characters/enemies/mireling/mireling_action_sheet_32x32.png` | Migrated | 128x128; 4x4 of 32x32 | `mireling_sprite_frames.tres` |
| `char_mireling_frames` | `assets/characters/enemies/mireling/mireling_sprite_frames.tres` | Migrated | Godot `SpriteFrames` | `mireling.tscn` |
| `char_bramble_spitter_actions` | `assets/characters/enemies/bramble_spitter/bramble_spitter_action_sheet_32x32.png` | Migrated | 128x128; 4x4 of 32x32 | `bramble_spitter_sprite_frames.tres` |
| `char_bramble_spitter_frames` | `assets/characters/enemies/bramble_spitter/bramble_spitter_sprite_frames.tres` | Migrated | Godot `SpriteFrames` | `bramble_spitter.tscn` |

Character columns use `down`, `left`, `right`, `up`. Humanoid extended attack sheets use those directions as rows and six action phases as columns.

### Preserved Awakened Pipeline Material

These files are intentionally outside runtime imports under Godot-ignored `art_source/`:

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
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

The prop scenes remain under `environment/props/` because they combine presentation with collision, navigation, occlusion, and behavior. Raster art stays under `assets/`.

## Active UI and Effects

Current UI visuals combine the approved reusable base theme and named pixel icons with scene-local `StyleBoxFlat`, labels, polygons, and lines for semantic states and effects.

| Canonical ID | Current path | Status | Purpose |
|---|---|---|---|
| `ui_combat_hud` | `ui/combat_hud.tscn` | `active_resource` | Vitality, progression, interaction prompt, and skills 1-4. |
| `ui_character_menu` | `ui/character_menu.tscn` | `active_resource` | Paused The Awakened progression and skill information. |
| `ui_title_screen` | `ui/screens/title/title_screen.tscn` | `active_resource` | Main navigation, session-audio settings, and new-journey entry. |
| `ui_title_background` | `ui/screens/title/title_background.tscn` | `active_resource` | Replaceable title presentation layers and restrained atmosphere. |
| `ui_enemy_health_bar` | `ui/world/enemy_health_bar.tscn` | `active_resource` | Damage-triggered world-space enemy health. |
| `ui_damage_number` | `ui/world/damage_number.tscn` | `active_resource` | Short-lived accepted-hit values. |
| `fx_summon` | `gameplay/encounters/summon_effect.tscn` | `active_resource` | Enemy materialization presentation. |
| `fx_hit_burst` | `gameplay/presentation/hit_burst.tscn` | `active_resource` | Accepted-hit pixel burst. |
| `fx_bramble_seed_impact` | `gameplay/projectiles/bramble_seed_impact.tscn` | `active_resource` | Seed collision presentation. |

### Reusable Theme and Icon Kit

| Canonical ID | Runtime path | Status | Purpose |
|---|---|---|---|
| `theme_battle_of_gods` | `assets/ui/themes/battle_of_gods_theme.tres` | `active_resource` | Shared panels, labels, buttons, progress bars, focus, disabled, separators, and tooltips. |
| `icon_action_primary_attack` | `assets/ui/icons/actions/icon_action_primary_attack_24x24.png` | `active_runtime` | Plain-sword action symbol. |
| `icon_action_dash` | `assets/ui/icons/actions/icon_action_dash_24x24.png` | `active_runtime` | Supernatural dash symbol. |
| `icon_skill_sweeping_cut` | `assets/ui/icons/skills/icon_skill_sweeping_cut_24x24.png` | `active_runtime` | Wide sword-arc skill symbol. |
| `icon_currency_coin` | `assets/ui/icons/economy/icon_currency_coin_16x16.png` | `active_runtime` | Run coin readout and future shop currency. |
| `icon_status_health` | `assets/ui/icons/status/icon_status_health_16x16.png` | `active_runtime` | Player vitality symbol. |
| `icon_status_experience` | `assets/ui/icons/status/icon_status_experience_16x16.png` | `active_runtime` | XP and level-progress symbol. |
| `icon_interaction_portal` | `assets/ui/icons/interactions/icon_interaction_portal_16x16.png` | `active_runtime` | Contextual stage-travel prompt. |
| `icon_interaction_talk` | `assets/ui/icons/interactions/icon_interaction_talk_16x16.png` | `active_runtime` | Reserved presentation for the first NPC interaction. |
| `icon_slot_locked` | `assets/ui/icons/states/icon_slot_locked_16x16.png` | `active_runtime` | Sealed skill or unavailable-feature state. |

The icons are reproducibly built by `tools/build_ui_icon_kit.gd` from the approved palette. They use binary alpha and remain independently replaceable at their stable paths.

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

## Catalog Update Rule

Every asset change must answer:

1. What is its canonical ID?
2. Is it source, intermediate, runtime, legacy, or planned?
3. What exact file or resource uses it?
4. What dimensions, grid, origin, and palette constraints apply?
5. Where did it come from, and what license or generation process applies?
6. Does it replace an entry, add a variant, or create a new gameplay concept?
