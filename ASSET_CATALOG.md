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
| `char_mireling_actions` | `assets/characters/enemies/mireling/mireling_action_sheet_48x32.png` | Active | 384x128; four slam plus four collapse frames x direction rows `down/left/right/up`; 48x32 cells preserve fixed body scale | `mireling_sprite_frames.tres` |
| `char_mireling_walk` | `assets/characters/enemies/mireling/mireling_walk_sheet_32x32.png` | Active | 128x128; four hop frames x direction rows `down/left/right/up`; 18-pixel body height | `mireling_sprite_frames.tres` |
| `char_mireling_frames` | `assets/characters/enemies/mireling/mireling_sprite_frames.tres` | Active | External Godot `SpriteFrames`; exactly 16 directional idle/hop/slam/collapse animations | `mireling.tscn` |
| `char_bramble_spitter_actions` | `assets/characters/enemies/bramble_spitter/bramble_spitter_action_sheet_32x32.png` | Migrated | 128x128; 4x4 of 32x32 | `bramble_spitter_sprite_frames.tres` |
| `char_bramble_spitter_frames` | `assets/characters/enemies/bramble_spitter/bramble_spitter_sprite_frames.tres` | Migrated | Godot `SpriteFrames` | `bramble_spitter.tscn` |
| `char_rootling_walk` | `assets/characters/enemies/rootling/rootling_walk_sheet_32x32.png` | Active | 128x128; 4x4 of 32x32, direction rows `down/left/right/up` | `rootling.tscn` / `RootlingVisual` |
| `char_rootling_reactions` | `assets/characters/enemies/rootling/rootling_reaction_sheet_32x32.png` | Active | 128x128; ready/hurt/wither/defeat across 4 direction rows | `rootling.tscn` / `RootlingVisual` |
| `fx_rootling_root_jab` | `assets/characters/enemies/rootling/rootling_root_jab_vfx_sheet_48x48.png` | Active | 192x192; crack/branch/eruption/retract across 4 direction rows | `rootling.tscn` / `RootlingVisual` |
| `sfx_rootling_root_jab` | `assets/audio/sfx/rootling_root_jab.wav` | Active | 0.31-second mono 44.1 kHz WAV | `rootling.tscn` / `ActionSfx` |
| `char_rootbound_husk_walk` | `assets/characters/enemies/rootbound_husk/rootbound_husk_walk_sheet_72x64.png` | Active | 288x256; stump-guardian contact A/pass A/contact B/pass B; opposite side is an exact mirror | `rootbound_husk_sprite_frames.tres` |
| `char_rootbound_husk_root_attack` | `assets/characters/enemies/rootbound_husk/rootbound_husk_root_attack_body_sheet_96x64.png` | Active | 576x256; 6 root-command poses x 4 direction rows; wider cells preserve body scale | `rootbound_husk_sprite_frames.tres` |
| `char_rootbound_husk_reactions` | `assets/characters/enemies/rootbound_husk/rootbound_husk_reaction_sheet_64x64.png` | Active | 256x256; neutral/hurt/wounded/defeat x 4 direction rows | `rootbound_husk_sprite_frames.tres` |
| `char_rootbound_husk_frames` | `assets/characters/enemies/rootbound_husk/rootbound_husk_sprite_frames.tres` | Active | Godot `SpriteFrames`; exactly 28 directional idle/walk/root-attack/hurt/defeat animations | `rootbound_husk.tscn` / `RootboundHuskVisual` |
| `fx_rootbound_husk_root_spear` | `assets/characters/enemies/rootbound_husk/rootbound_husk_root_spear_vfx_sheet_128x64.png` | Active | 768x64; six telegraph-to-eruption ground cells | `rootbound_husk_root_spear_vfx_sprite_frames.tres` |
| `fx_rootbound_husk_root_spear_frames` | `assets/characters/enemies/rootbound_husk/rootbound_husk_root_spear_vfx_sprite_frames.tres` | Active | Godot `SpriteFrames`; telegraph and eruption animations | `rootbound_husk.tscn` / `RootboundHuskVisual` |
| `portrait_enemy_rootling` | `assets/characters/enemies/portraits/rootling_portrait_96x96.png` | Active | 96x96 transparent pixel portrait | Dialogue, bestiary, and preview presentation |
| `portrait_enemy_rootbound_husk` | `assets/characters/enemies/portraits/rootbound_husk_portrait_96x96.png` | Active | 96x96 transparent pixel portrait | Stage 3 pre-fight dialogue and future previews |
| `portrait_enemy_mireling` | `assets/characters/enemies/portraits/mireling_portrait_96x96.png` | Active | 96x96 transparent pixel portrait | Dialogue, bestiary, and preview presentation |
| `portrait_enemy_forsaken_thrall` | `assets/characters/enemies/portraits/forsaken_thrall_portrait_96x96.png` | Active | 96x96 transparent pixel portrait | Dialogue, bestiary, and preview presentation |
| `portrait_enemy_bramble_spitter` | `assets/characters/enemies/portraits/bramble_spitter_portrait_96x96.png` | Active | 96x96 transparent pixel portrait | Dialogue, bestiary, and preview presentation |

The five portrait sources and chroma-clean intermediates live under `art_source/generated/characters/enemies/portraits/`. They were generated from each approved runtime model as an identity reference, cleaned from a blue chroma backdrop, and nearest-neighbor normalized to the shared 96x96 transparent runtime contract. Portraits are presentation-only and may be reused by dialogue, expedition descriptions, and future bestiary surfaces.

All active Opaw sheets use direction rows in canonical `down`, `left`, `right`, `up` order and animation frames as columns. `tools/process_opaw_compact_armless_assets.gd` isolates each padded generated cell, removes chroma, normalizes every direction reference to 18x27 on the shared foot baseline, and emits binary-alpha runtime sheets. Normal attack body columns map directly to wind-up, active, and recovery while the detached external weapon owns the visible blade arc. The complete previous Wayfarer model and former single 4x8 atlas have no active `SpriteFrames` references. Existing humanoid extended enemy attack sheets use directions as rows and six action phases as columns.

Rootbound Husk runtime sheets are reproducibly emitted by `tools/assemble_rootbound_husk_redesign.gd`, `tools/process_rootbound_husk_assets.gd`, and `tools/build_rootbound_husk_sprite_frames.gd`. The assembler composes exact-grid v4 walk and root-attack sources from reviewed redesign components, uses a dedicated two-frame front-facing down-active strip, recovers complete up-facing crowns and boundary-crossing root-command poses through bounded connected-component overlap, and applies one scale per direction row. The processor chroma-cleans active boards, retains separated readable body components, removes sheet-specific debris, applies one standing-reference scale unchanged across each direction row, and byte-verifies exact mirrored side rows for walk and root attack. Active body sources are `rootbound_husk_walk_board_source_v4.png` and `rootbound_husk_root_attack_body_board_source_v4.png`; the manually reviewed four-frame directional collapse sequence remains in `rootbound_husk_reaction_sheet_64x64.png`, and ground roots retain `rootbound_husk_root_ground_attack_board_source_v2.png`. The active runtime folder contains the walk, root-attack, reaction, and ground-VFX sheets plus their two `SpriteFrames` resources. Retired Husk body packages were permanently deleted and have no rollback path.

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

The active runtime folder now exposes only the approved compact-armless set and the supported Wayfarer rollback. The former root-level duplicate sheets are preserved outside runtime at `art_source/archive/characters/playable/opaw/legacy_runtime_root/`; the rejected, unreferenced Consecutive Thrust board is at `art_source/archive/skills/opaw/consecutive_thrust_rejected_v1/`.

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
| `char_mireling_actions` | `art_source/generated/characters/enemies/mireling/final/mireling_action_board_source_v2.png` | `source` | Approved 8x4 remodeled slam/collapse board |
| `char_mireling_actions` | `art_source/generated/characters/enemies/mireling/final/mireling_action_board_clean_v2.png` | `intermediate` | Chroma-cleaned action board with cross-cell fragments isolated |
| `char_mireling_walk` | `art_source/generated/characters/enemies/mireling/final/mireling_walk_board_source_v2.png` | `source` | Approved generated four-direction walk board |
| `char_mireling_walk` | `art_source/generated/characters/enemies/mireling/final/mireling_walk_board_clean_v2.png` | `intermediate` | Chroma-cleaned source used by the Godot walk processor |

### Preserved Bramble Spitter Pipeline Material

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
| `char_bramble_spitter_actions` | `art_source/generated/characters/enemies/bramble_spitter/bramble_spitter_action_source.png` | `source` | 1254x1254 |
| `char_bramble_spitter_actions` | `art_source/generated/characters/enemies/bramble_spitter/bramble_spitter_action_clean.png` | `intermediate` | 1254x1254 |

### Preserved Rootling Pipeline Material

| Related canonical ID | Preserved path | Status | Source dimensions |
|---|---|---|---|
| `char_rootling_walk` | `art_source/generated/characters/enemies/rootling/final/rootling_walk_board_clean.png` | `intermediate` | 1254x1254; sole approved 4x4 board for down/left/right/up walking |
| `char_rootling_reactions` | `art_source/generated/characters/enemies/rootling/final/rootling_reaction_board_clean.png` | `intermediate` | 1254x1254; sole approved four-direction reaction board |
| `fx_rootling_root_jab` | `art_source/generated/characters/enemies/rootling/final/rootling_root_jab_vfx_board_clean.png` | `intermediate` | 1254x1254; sole approved four-direction root-jab VFX board |
| `char_rootling_walk`, `char_rootling_reactions`, `fx_rootling_root_jab` | `art_source/archive/characters/enemies/rootling/superseded_generation/*` | `legacy` | Original generation sources, the rejected separate down-walk strip, and unused root-jab action board; no runtime or build references |
| `char_rootbound_husk_action_package` | `art_source/generated/characters/enemies/rootbound_husk/rootbound_husk_walk_board_source_v4.png`, `rootbound_husk_root_attack_body_board_source_v4.png`, ground-root v2 source, and matching clean boards | `source` / `intermediate` | Active redesigned Stage 3 Husk locomotion, v4 six-stage root attack, and preserved six-beat ground roots; the approved runtime reaction sheet retains the manually reviewed directional collapse frames |

## Active Environment Art

| Canonical ID | Current runtime path | Target path/name | Size and grid | Runtime owner |
|---|---|---|---|---|
| `tile_forest_ground_verdant` | `assets/environment/forest/shared/tiles/verdant_forest_ground_atlas_4x4.png` | Active | 256x256; 4x4 of 64x64 | `verdant_forest_ground_tileset.tres`; Stage I-II |
| `tile_forest_ground_verdant_resource` | `assets/environment/forest/shared/tiles/verdant_forest_ground_tileset.tres` | Active | Godot `TileSet`; 16 cells | Stage I-II authored ground layers |
| `tile_rootbound_hollow_ground` | `assets/environment/forest/rootbound_hollow/tiles/rootbound_ground_atlas_4x4.png` | Active | 256x256; 4x4 of 64x64 | `rootbound_ground_tileset.tres`; Stage III |
| `tile_rootbound_hollow_ground_resource` | `assets/environment/forest/rootbound_hollow/tiles/rootbound_ground_tileset.tres` | Active | Godot `TileSet`; 16 cells | Stage III authored ground layer |
| `prop_forest_ancient_tree_base` | `assets/environment/forest/shared/props/ancient_tree_base.png` | Active | 94x112 | `ancient_tree.tscn` |
| `prop_forest_ancient_tree_canopy` | `assets/environment/forest/shared/props/ancient_tree_canopy.png` | Active | 94x112 | `ancient_tree.tscn` |
| `prop_forest_ruined_statue` | `assets/environment/forest/shared/props/ruined_shrine_statue.png` | Active | 81x104 | `ruined_statue.tscn` |
| `landmark_rootbound_arena_seal` | `assets/environment/forest/rootbound_hollow/props/rootbound_arena_seal_384x224.png` | Active | 384x224 transparent fixed canvas | `rootbound_arena_seal.tscn`; Stage III |
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

The generated forest source boards and cleaned arena seal are preserved under `art_source/generated/environment/forest/`; `tools/normalize_environment_art.py` reproduces both exact 4x4 runtime atlases and the fixed-canvas seal. Authored layout resources live under `data/environment/layouts/`, and `tools/bake_authored_ground.gd` writes their cells into stage scenes. The Sanctuary source board is preserved at `art_source/generated/environment/sanctuary/sanctuary_direction_board_source.png`; only its terrain and tree crops remain active through `tools/process_sanctuary_direction_board.gd`. The standalone portal, fountain, compact Eira/Orren, skillkeeper lodge, armskeeper workshop, and cart are reproducible through `tools/process_sanctuary_individual_assets.gd`. Detached NPC props remain intentional within padded 48x48 cells. Prop scenes remain under `environment/props/` because they combine presentation with editable collision and idle effects. Superseded service crops/scenes/runtime files are archived and cannot be regenerated by the direction-board processor.

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
| `char_opaw_consecutive_thrust_rapid_body` | `assets/characters/playable/opaw/compact_armless/opaw_consecutive_thrust_rapid_body_sheet_48x32.png` | `active_runtime` | 8x4 action-owned directional sheet deterministically built from approved compact-armless Opaw frames; no generated replacement character. |
| `fx_opaw_consecutive_thrust_rapid` | `assets/skills/opaw/warrior/consecutive_thrust/opaw_consecutive_thrust_rapid_vfx_sheet_192x192.png` | `active_runtime` | Twelve 192x192 cells in a 6x2 right-facing effect-only atlas, rotated by presentation. |
| `fx_opaw_consecutive_thrust_rapid_source` | `art_source/generated/skills/opaw/consecutive_thrust/rapid_v3/opaw_consecutive_thrust_rapid_vfx_source_v3.png` | `source` | Generated VFX-only 6x2 source board preserved outside runtime loading. |
| `fx_opaw_consecutive_thrust_rapid_clean` | `art_source/generated/skills/opaw/consecutive_thrust/rapid_v3/opaw_consecutive_thrust_rapid_vfx_clean_v3.png` | `intermediate` | Alpha-clean source consumed by `tools/process_consecutive_thrust_rapid_vfx.gd`. |
| `skill_opaw_consecutive_thrust_v2` | `art_source/archive/skills/opaw/consecutive_thrust_v2_replaced/` | `archived` | Superseded three-hit runtime sheets, source boards, audio, and builders retained for rollback/provenance only. |

### Reusable Theme and Icon Kit

| Canonical ID | Runtime path | Status | Purpose |
|---|---|---|---|
| `theme_battle_of_gods` | `assets/ui/themes/battle_of_gods_theme.tres` | `active_resource` | Shared panels, labels, buttons, progress bars, focus, disabled, separators, and tooltips. |
| `icon_action_primary_attack` | `assets/ui/icons/actions/icon_action_primary_attack_24x24.png` | `active_runtime` | Primary melee/Ashwood Blade action symbol. |
| `icon_action_dash` | `assets/ui/icons/actions/icon_action_dash_24x24.png` | `active_runtime` | Supernatural dash symbol. |
| `icon_skill_sweeping_cut` | `assets/ui/icons/skills/icon_skill_sweeping_cut_24x24.png` | `active_runtime` | Wide sword-arc skill symbol. |
| `icon_skill_piercing_rush` | `assets/ui/icons/skills/icon_skill_piercing_rush_24x24.png` | `active_runtime` | White spirit-thrust symbol for Opaw's equipped Skill 1. |
| `icon_skill_consecutive_thrust` | `assets/ui/icons/skills/icon_skill_consecutive_thrust_24x24.png` | `active_runtime` | Rapid spirit-lance symbol for debug-test Skill 2. |
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
| `audio_sfx_opaw_dash_light_swoosh` | `assets/audio/sfx/opaw_dash_light_swoosh.wav` | `active_runtime` |
| `audio_sfx_opaw_piercing_rush_charge` | `assets/audio/sfx/opaw_piercing_rush_charge.wav` | `active_runtime` |
| `audio_sfx_opaw_piercing_rush_thrust` | `assets/audio/sfx/opaw_piercing_rush_thrust.ogg` | `active_runtime` |
| `audio_sfx_opaw_piercing_rush_impact` | `assets/audio/sfx/opaw_piercing_rush_impact.ogg` | `active_runtime` |
| `audio_sfx_opaw_consecutive_thrust_charge` | `assets/audio/sfx/opaw_consecutive_thrust_charge.wav` | `active_runtime` |
| `audio_sfx_opaw_consecutive_thrust_flurry_thrust` | `assets/audio/sfx/opaw_consecutive_thrust_flurry_thrust.ogg` | `active_runtime` |
| `audio_sfx_opaw_consecutive_thrust_final_thrust` | `assets/audio/sfx/opaw_consecutive_thrust_final_thrust.ogg` | `active_runtime` |
| `audio_sfx_opaw_consecutive_thrust_final_hit` | `assets/audio/sfx/opaw_consecutive_thrust_final_hit.ogg` | `active_runtime` |
| `audio_sfx_opaw_consecutive_thrust_v3` | `art_source/archive/skills/opaw/consecutive_thrust_v3_replaced/audio/` | `archived` | Replaced three-voice swish and final-whoosh runtime audio retained for provenance only. |
| `audio_sfx_opaw_hurt_impact` | `assets/audio/sfx/opaw_hurt_impact.wav` | `active_runtime` |
| `audio_sfx_thrall_claw` | `assets/audio/sfx/thrall_claw.wav` | `active_runtime` |
| `audio_sfx_mireling_leap` | `assets/audio/sfx/mireling_leap.wav` | `active_runtime` |
| `audio_sfx_mireling_land` | `assets/audio/sfx/mireling_land.wav` | `active_runtime` |
| `audio_sfx_bramble_spit` | `assets/audio/sfx/bramble_spit.wav` | `active_runtime` |
| `audio_sfx_bramble_impact` | `assets/audio/sfx/bramble_impact.wav` | `active_runtime` |

Audio provenance remains in `assets/audio/ATTRIBUTION.md`.

The superseded generic dash, player-hurt, and synthetic dash-burst clips are preserved outside runtime imports under `art_source/archive/audio/replaced_player_action_sfx/`; they must not be rebound to Opaw because their character is too close to enemy cues or did not pass playtest review.

## Transitional and Legacy Material

These patterns are not approved runtime naming. Preserve them during migration, then move them into `art_source/` with recorded provenance:

| Current pattern/path | Status | Rule |
|---|---|---|
| `assets/characters/prototype/` | `legacy` | Do not add new runtime references. |
| `*_source.png` | `source` | Preserve original generation/download/handmade input. |
| `*_clean.png` | `intermediate` | Preserve when required by a reproducible build script. |
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
