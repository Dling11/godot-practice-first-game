# Asset Catalog

## Stage 5 Boss Basin Environment

- Generated terrain source: `art_source/generated/environment/stage_5/stage_5_decay_ground_source_v1.png`; deterministic `tools/process_stage_5_environment.py` extracts its exact 4x4 board into `assets/environment/forest/stage_5/tiles/stage_5_decay_ground_atlas_4x4.png` with 64x64 cells and the reusable `stage_5_decay_ground_tileset.tres` resource.
- The atlas owns quiet charcoal soil, stone-lane, root-band, boundary, and sparse lime-fissure families for fully decayed Stage 5 ground. It is not a recolor or runtime-random fill.
- The expanded dead-forest board is preserved as `art_source/generated/environment/stage_5/stage_5_dead_forest_props_source_v1.png` plus its cleaned alpha counterpart. The processor extracts four distinct runtime props: `stage_5_tall_dead_tree_144x192.png`, `stage_5_dead_tree_snag_128x160.png`, `stage_5_fallen_log_192x96.png`, and `stage_5_uprooted_log_192x128.png`. Matching prop scenes give every standing or fallen silhouette an authored collision footprint and navigation cutout; the tall tree also owns occlusion.
- The rejected former standalone root-stump family is permanently deleted: no `stage_5_dead_tree_source_v1.png`, cleaned counterpart, 112x144 runtime, review, scene, or processor reference remains.
- Production Stage 5 adds `stage_5_edge_thicket_source_v1.png` with a matching cleaned alpha intermediate and runtime `stage_5_edge_thicket_256x192.png`. Its scene combines three trees into one edge-wall obstacle with collision/navigation/occlusion. `tools/build_stage_5_tiny_carrion_remains.py` builds the handmade, transparent 48x32 pixel source at `art_source/handmade/environment/stage_5/stage_5_tiny_carrion_remains_source_v1.png`; the shared processor emits runtime `stage_5_tiny_carrion_remains_48x32.png`. The small carrion scene owns a bounded footprint and four separately tweened fly dots, with no flies baked into the texture. The older 160x96 generated animal source is retained only as unused provenance and must not be restored to runtime.
- Broken-shrine source, cleaned alpha, runtime, and prop scene are `art_source/generated/environment/stage_5/stage_5_broken_shrine_source_v1.png`, `art_source/cleaned/environment/stage_5/stage_5_broken_shrine_clean_v1.png`, `assets/environment/forest/stage_5/props/stage_5_broken_shrine_320x192.png`, and `environment/props/stage_5_broken_shrine/stage_5_broken_shrine.tscn`. Its two collision masses preserve an open center. It is deliberately dormant, is not a portal, and contains no interaction authority.
- `data/environment/layouts/stage_5_dead_forest_ground.tres` authors the 24x18 production route; the smaller `stage_5_boss_basin_ground.tres` remains debug-review data only. Eighteen edge-thicket instances sit partly beyond the four production-map edges with deliberate scale/mirroring. Individual accepted trees/logs, the tiny animated carrion detail, southern arrival gateway, and northern boss basin compose the interior; review exports live under `art_source/review/environment/stage_5/`.

## Stage 5 Boss - Approved Identity and Locomotion

- Approved identity source: `art_source/generated/characters/enemies/stage_5_boss/stage_5_boss_identity_approved.png`.
- Status: `production_runtime`; identity, idle, walk, reactions, attacks, health-tier phase behavior, and production Stage 5 encounter are active. Canonical runtime copies live under `assets/characters/enemies/stage_5_boss/`; F8 remains an isolated fallback arena. The final display name is Varkuun, Lord of the Withered Grove. His active CC0 fantasy/JRPG loop is `assets/audio/music/boss/varkuun_battle_rpg_theme_loop.ogg`, and his complete real-recording action suite lives under `assets/audio/sfx/enemies/varkuun/`. The superseded `Determined Pursuit` WAV is archive-only; only the milestone reward remains open.
- Locked identity: massive hunched humanoid guardian, asymmetric root arms, split dead-bark chest shell, hollow luminous core, heavy planted legs, and removable/broken armor language.
- Scale contract: clearly larger than the Rootbound Husk at roughly 1.35-1.5x its standing height, but fully visible and mobile. Stage 10 reserves colossal scale.
- The generated crowned scale figure is not King and is explicitly excluded from all runtime use. A future normalized proof must use the real King and Husk sprites.
- Phase 1 review candidate: the generated/clean standing sources and deterministic processor produce `art_source/review/characters/enemies/stage_5_boss/stage_5_boss_idle_sheet_112x96_candidate.png`, an exact 4x4 `down/left/right/up` board with 112x96 cells, shared y=90 foot contact, binary alpha, and all sixteen poses retained. `stage_5_boss_real_scale_comparison_4x.png` uses the actual King/Husk textures and places the boss at the approved approximately 1.4x Husk height. This remains review-only until owner approval.
- Phase 2 walking candidate: `stage_5_boss_walk_sheet_112x96_candidate.png` retains six meaningful gait poses for all four directions—24 non-empty, unique frames—with the same 112x96/y=90 contract and fixed approved stature per view. The generated/clean sources, `tools/process_stage_5_boss_walk.py`, static 2x review, and animated all-direction GIF remain review artifacts until owner approval.
- The owner approved both idle and walking source checkpoints on 2026-08-14.
- Phase 2 runtime correction supersedes the earlier review-only processing note: `stage_5_boss_walk_sheet_112x96_candidate.png` and its active runtime copy retain six meaningful gait poses for all four directions. All six up actors cross 22-24 pixels above their nominal generated row, so `tools/process_stage_5_boss_walk.py` recovers the 24 largest complete actors from the full board and orders them by real centers before normalization. Cell-first extraction is forbidden because it flattens the back-facing crowns; the 112x96 cells, y=90 baseline, fixed direction scale, binary alpha, and 24 unique-frame contract remain unchanged.
- Phase 3 reaction runtime proof: two exact 4x4 parent sheets assemble into both the review candidate and active `stage_5_boss_reaction_sheet_144x112.png`, retaining 32 non-empty, unique frames across hurt, recovery, buckle, collapse, and settle. The wider cell and y=98 baseline preserve the same world-space foot offset. Direction-specific 88/68/72/90-pixel hurt envelopes prevent generated roots from changing apparent scale. Every five-frame directional collapse now also owns a bounded width sequence and preserves aspect ratio when fitted, preventing the body from inflating as it falls. Runtime holds the settled corpse briefly, then fades body and shadow together.
- Phase 4 quick-lunge candidate: two exact 4x4 parent sheets assemble into `stage_5_boss_basic_attack_sheet_144x112_candidate.png`, retaining 32 non-empty, unique forward root-arm extension frames. Runtime correctly names it lunge rather than sweep. It uses the 144x112/y=98 action contract and contains no baked VFX or hitbox authority; global component extraction prevents root-arm clipping.
- Phase 4b heavy-slap runtime: built-in generation produced one strict 8x4 magenta-key board. `tools/process_stage_5_boss_slap.py` globally extracts all 32 unique actors into `stage_5_boss_slap_sheet_144x112.png` with binary alpha and y=101 ground contact. Every direction preserves lift, high cock, held apex, downward release, planted hand, compression, and recovery; no impact VFX or damage authority is baked into the body.
- Phase 5 jump candidate: two 4x4 body parents assemble into `stage_5_boss_jump_body_sheet_144x112_candidate.png`, preserving 32 unique compression/launch/airborne/descent/landing/rebound frames. A corrected eight-frame `stage_5_boss_jump_impact_sheet_192x112_candidate.png` owns the centered pressure mark, debris burst, shockwave, fracture, and persistent crater without adjacent-frame leakage. The generated `stage_5_boss_jump_spikes_source_v1.png` and deterministic processor add a separate six-frame `stage_5_boss_jump_spikes_sheet_192x112.png` open-center eruption. Runtime aligns both layers to one boss-foot anchor, moves the actor root, resolves one landing contact, and world-locks the residual effect.
- Phase 6 root-execution VFX: `stage_5_boss_root_prison_sheet_128x112.png` owns eight warning/capture/crack/break frames on y=99, with content constrained to 64x44 so its open center and height match King's 48x32 gameplay body. Its intact two-frame capture range loops as living root motion. `stage_5_boss_root_execution_sheet_192x192.png` owns eight charge/eruption/retraction/residue frames on y=178. `tools/process_stage_5_boss_root_prison.py` removes the baked checker, finds the eight largest real execution anchors, assigns every loose root/rock/spark component to its nearest anchor before normalization, and prevents neighboring-frame edge leakage. All sixteen frames retain binary alpha and stable world centers/baselines.
- Display name is `Varkuun, Lord of the Withered Grove`; the stable production identifier remains `stage_5_boss` so the lore choice does not churn asset paths.
- Reusable portrait: `assets/characters/enemies/portraits/stage_5_boss_portrait_96x96.png` preserves the approved crown, broken shoulder armor, plum heartwood, luminous eyes, and exposed core for the implemented Varkuun entrance dialogue plus future monster-info/bestiary presentation. The generated chroma source, cleaned alpha intermediate, deterministic `tools/process_stage_5_boss_portrait.py`, and 4x review image remain preserved; no gameplay authority is baked into the portrait.

## Stage 4 Armored Hog

- Approved identity source: `art_source/generated/characters/enemies/stage_4_armored_hog/armored_hog_identity_approved.png`.
- Active runtime sheets: `res://assets/characters/enemies/stage_4_armored_hog/armored_hog_locomotion_sheet_64x48.png`, `armored_hog_charge_sheet_64x48.png`, and `armored_hog_reaction_sheet_64x48.png`; the `armored_hog_sprite_frames.tres` resource consumes every approved cell across 32 named directional animations.
- Each sheet uses 64x48 cells, shared body scale/baseline, nearest filtering, and binary alpha. Direction rows are `down/left/right/up`; locomotion uses four columns and charge/reaction use six.
- Active item icons: `res://assets/items/materials/forest/armored_hog_hide_24x24.png` and `living_bark_plate_24x24.png`.
- Active action audio: original deterministic `armored_hog_hoof.wav`, `armored_hog_brace.wav`, and `armored_hog_crash.wav`, plus the CC0 `armored_hog_snort.ogg` layer.
- Generated, clean, and review boards remain under matching `art_source/.../stage_4_armored_hog/` paths. The rejected realistic package is archive-only under `art_source/archive/stage_4_rejected_realistic_hog_2026-08-13/`.

## Stage 3 West-Decay Transition

- Active runtime atlas: `res://assets/environment/forest/rootbound_hollow/tiles/stage_3_west_decay_transition_atlas_3x4.png` — twelve generated 64x64 west-Rootbound/east-verdant transition variations used as a single ragged boundary column across the fourteen map rows.
- Stage 4 runtime derivative: `res://assets/environment/forest/rootbound_hollow/tiles/stage_4_east_decay_transition_atlas_3x4.png` — deterministic horizontal mirror of the approved mixed atlas, used as source 3 for the eastern/right-side decay boundary.
- Generated source: `art_source/generated/environment/stage_3/stage_3_west_decay_transition_source_v1.png`; deterministic normalization: `tools/process_stage_3_transition_tiles.py`; review outputs live under `art_source/review/environment/stage_3/`.
- The existing Rootbound and verdant 4x4 atlases remain active sources 0 and 1. This transition atlas is source 2 and does not replace either baseline family.

## King Skill 4

- Active sword VFX atlas/resource: `res://assets/vfx/abilities/king/king_skill_4_spirit_sword_sheet_144x192.png` plus `king_skill_4_spirit_sword_frames.tres` own one generated 4x2 sequence: three formation poses, four embedded resistance/second-drive poses, and one dissolve pose. All eight normalized cells keep the point fixed at local y=188; Godot owns physical descent/rebound while the sink shader clips the accelerated 20-pixel burial against the fixed ground plane.
- Active ground VFX atlas/resource: `res://assets/vfx/abilities/king/king_skill_4_ground_vfx_sheet_256.png` plus `king_skill_4_ground_vfx_frames.tres` own one generated 4x2 sequence: compact contact, spreading cracks, split plates, resistance ring, compression, deep drive, explosion, and crater. All eight frames use one reviewed contact anchor and play in order.
- Active icon/audio: `res://assets/ui/icons/skills/icon_skill_4.svg`, `res://assets/audio/sfx/abilities/king/king_skill_4_formation.wav`, `king_skill_4_first_impact.wav`, and `king_skill_4_explosion.wav`.
- Active generated/clean/review sources live under `art_source/.../simple_reboot/skill_4/`; deterministic rebuild tools are `tools/process_king_skill_4_vfx.py` and `tools/generate_king_skill_4_sfx.py`. The rejected former 6-frame ground source, 4-frame overlay, retired static sword, obsolete runtime resources, and stale captures are recoverably isolated under `art_source/archive/skill_4_rejected_ground_vfx_2026-08-12/` and receive no Godot imports.

## King Skill 3 — Sovereign Pursuit

- Active body atlas: `res://assets/characters/playable/king/simple_reboot/king_sovereign_pursuit_body_sheet_64x32.png` — 6x4, down/left/right/up rows, y=30 baseline, binary alpha.
- Active ground VFX atlas/resource: `res://assets/vfx/abilities/king/sovereign_pursuit_vfx_sheet_192.png` and `sovereign_pursuit_vfx_frames.tres` — v2 generated 3x2 launch, landing shatter, debris, and crater sequence.
- Active travel VFX atlas/resource: `res://assets/vfx/abilities/king/sovereign_pursuit_travel_vfx_sheet_128.png` and `sovereign_pursuit_travel_vfx_frames.tres` — generated 3x1 open-center white/cold-blue power sheath that follows King only during traversal.
- Active icon/audio: `res://assets/ui/icons/skills/icon_skill_sovereign_pursuit.svg`, `res://assets/audio/sfx/abilities/king/sovereign_pursuit_launch.wav`, and `res://assets/audio/sfx/abilities/king/sovereign_pursuit_landing.wav`.
- Preserved generated/clean/review sources live under `art_source/.../simple_reboot/sovereign_pursuit/`; deterministic processors are `tools/process_king_simple_locomotion.py`, `tools/process_sovereign_pursuit_vfx.py`, `tools/process_sovereign_pursuit_travel_vfx.py`, and `tools/generate_sovereign_pursuit_sfx.py`.

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
| `portrait_enemy_stage_5_boss` | `assets/characters/enemies/portraits/stage_5_boss_portrait_96x96.png` | Active | 96x96 transparent pixel portrait | Varkuun entrance dialogue, future monster info/bestiary, and preview presentation |

### Approved King Simple-Reboot Sources

Decision 076 supersedes the detailed Decision 073-074 visual package. Decision 075 still governs action-owned exact-grid production. Decision 077 temporarily makes the simple package the live playable proof while preserving Opaw:

| Canonical ID | Current path | Target path/name | Provisional contract | Status |
|---|---|---|---|---|
| `char_king_simple_identity_v1` | `art_source/generated/characters/playable/king/simple_reboot/king_simple_identity_reference_v1.png` | Same until exact-cell extraction | Owner-approved plain-face black-haired swordsman with crimson scarf, compact body, mitten hands, tiny feet, and short broad straight signature sword | `approved_reference` |
| `char_king_simple_walk_v1` | `art_source/generated/characters/playable/king/simple_reboot/king_simple_walk_source_v1.png` | `assets/characters/playable/king/simple_reboot/king_simple_locomotion_sheet_48x32.png` | Approved 4x4 `down/left/right/up` contact/passing board; deterministic processor emits exact binary-alpha cells with one scale and foot anchor | `active_review_runtime` |
| `char_king_detailed_package_rejected` | `art_source/archive/characters/playable/king/rejected_detailed_package_2026-08-11/` | None | Former detailed greatsword runtime sheets, previews, processors, tests, generated/cleaned sources, and reviews; never restore to active imports | `rejected_archive` |
| `char_king_frames` | `assets/characters/playable/king/simple_reboot/king_simple_sprite_frames.tres` | Same | Directional idle/walk/basic slash plus required dash/interact/hurt/defeat compatibility animations; every family is requested by `PlayerAnimation` and covered by the active player/preview tests | `active_runtime_proof` |
| `fx_king_echoing_sever_primary_v1` | `art_source/generated/characters/playable/king/simple_reboot/echoing_sever/echoing_sever_primary_vfx_{source,clean}_v1.png` | `assets/vfx/abilities/king/echoing_sever_primary_vfx_sheet_160.png` | Six chronological 160x160 binary-alpha cells; white/cold-blue ignition, contact crescent, fracture, and fade | `active_runtime` |
| `fx_king_echoing_sever_echo_v1` | `art_source/generated/characters/playable/king/simple_reboot/echoing_sever/echoing_sever_echo_vfx_{source,clean}_v1.png` | `assets/vfx/abilities/king/echoing_sever_echo_vfx_sheet_160.png` | Six chronological 160x160 binary-alpha cells; dormant rift, seam glow, one eruption, shards, and residual crack | `active_runtime` |
| `fx_king_echoing_sever_frames` | `assets/vfx/abilities/king/echoing_sever_vfx_frames.tres` | Same | `wind_up`, `primary`, `rift_hold`, and `echo`; presentation-only observer of authoritative strike signals | `active_runtime` |
| `sfx_king_echoing_sever_echo_fracture` | `tools/generate_echoing_sever_sfx.py` | `assets/audio/sfx/abilities/king/echoing_sever_echo_fracture.wav` | Original deterministic 0.42-second mono 44.1kHz low crack, icy fall, and crystalline shards; no external license | `active_runtime` |
| `icon_king_riftbreak` | Code-native SVG | `assets/ui/icons/skills/icon_skill_riftbreak.svg` | Dark-field grounded sword, crater, and radial-crack Skill 2 icon | `active_runtime` |
| `fx_king_riftbreak_v1` | `art_source/generated/characters/playable/king/simple_reboot/riftbreak/riftbreak_vfx_source_v1.png` + cleaned derivative | `assets/vfx/abilities/king/riftbreak_vfx_sheet_192.png` + `riftbreak_vfx_frames.tres` | Generated effect-only 3x2 board normalized into six binary-alpha 192x192 cells: contact spark, spreading cracks, shock ring, peak rupture, debris decay, residual fissures | `active_runtime` |
| `char_king_riftbreak_body_v1` | `art_source/generated/characters/playable/king/simple_reboot/riftbreak/king_riftbreak_body_source_v1.png` + cleaned derivative | `assets/characters/playable/king/simple_reboot/king_riftbreak_body_sheet_64x32.png` | Six chronological grounded slam poses x four cardinal rows; rows inherit 27/26/26/28-pixel locomotion height, frames 0/5 exactly reuse idle pixels, and all cells retain binary alpha plus the y=30 baseline | `active_runtime` |
| `sfx_king_riftbreak_ground_slam` | `tools/generate_riftbreak_sfx.py` | `assets/audio/sfx/abilities/king/riftbreak_ground_slam.wav` | Original deterministic 0.38-second mono 44.1kHz steel bite, stone crack, ground thump, and rubble tail; no external license | `active_runtime` |
| `char_king_simple_basic_slash_v2` | `art_source/generated/characters/playable/king/simple_reboot/king_simple_attack_{down,right,up}_source_v2.png` | `assets/characters/playable/king/simple_reboot/king_simple_basic_slash_sheet_64x32.png` | Six chronological poses x canonical four direction rows; left is an exact right mirror; per-direction 28-pixel scale and y=30 baseline | `active_runtime_proof` |
| `char_king_simple_basic_slash_v1_rejected` | `art_source/archive/characters/playable/king/rejected_simple_basic_slash_v1_2026-08-11/` | None | Owner-rejected weak four-pose/all-direction source and cleaned derivative; excluded from active imports | `rejected_archive` |
| `portrait_king` | None | `assets/characters/playable/king/king_portrait_96x96.png` | 96x96 transparent portrait derived after gameplay identity approval | `planned` |
| `weapon_king_signature_sword` | `king_simple_identity_reference_v1.png` | Character-owned rigid sword presentation | Short broad straight silver sword; equipment essences modify stats/traits rather than swapping its visible sprite | `approved_reference` |
| `fx_king_crescent_sever` | None | `assets/skills/king/crescent_sever/king_crescent_sever_vfx_sheet.png` | Large white/cold-blue crescent whose opaque edge/tip remains inside contact authority | `planned` |

Opaw remains `active_runtime` permanently as a separate supported roster character. Do not change the Opaw rows to legacy or move their files merely because King is added.

Decision 075 makes action-owned exact-grid sheets the runtime production unit. Small horizontal single-direction strips are permitted as review sources, not runtime atlases. Approve each integrated direction/action source before normalization or multiplication. Deterministic processing must reject per-frame scale/center/baseline/grip drift and source-matte residue before catalog status may become `active_runtime`.

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
| `tile_rootbound_hollow_ground_resource` | `assets/environment/forest/rootbound_hollow/tiles/rootbound_ground_tileset.tres` | Active | Godot `TileSet`; 56 cells across Rootbound, verdant, west-transition, and east-transition sources | Stage III-IV mixed-decay ground layers |
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
| `char_npc_rootweaver_nema_service` | `assets/characters/npcs/rootweaver/rootweaver_nema_service_sheet_48x48.png` | Active | 192x96; 4x2 compact screen-left three-quarter Nema idle/work board with approved integrated arms/tools, complete boots, and safe frame margins | `rootweaver_nema.tscn` |
| `portrait_npc_rootweaver_nema` | `assets/characters/npcs/rootweaver/rootweaver_nema_portrait_96x96.png` | Active | 96x96; reusable dialogue and service portrait | `rootweaver_nema.tscn` / `DialoguePanel` |
| `service_sanctuary_living_rootforge` | `assets/environment/sanctuary/services/rootweaver/rootweaver_living_rootforge_176x144.png` | Active | 176x144; open grove forge with bottom-center origin | `rootweaver_living_rootforge.tscn` |

The generated forest source boards and cleaned arena seal are preserved under `art_source/generated/environment/forest/`; `tools/normalize_environment_art.py` reproduces both exact 4x4 runtime atlases and the fixed-canvas seal. Authored layout resources live under `data/environment/layouts/`, and `tools/bake_authored_ground.gd` writes their cells into stage scenes. The Sanctuary source board is preserved at `art_source/generated/environment/sanctuary/sanctuary_direction_board_source.png`; only its terrain and tree crops remain active through `tools/process_sanctuary_direction_board.gd`. The standalone portal, fountain, compact Eira/Orren, skillkeeper lodge, armskeeper workshop, and cart are reproducible through `tools/process_sanctuary_individual_assets.gd`; Nema's actor, portrait, and Living Rootforge use `tools/process_rootweaver_service_assets.gd`. Detached Eira/Orren props remain intentional, while Nema's integrated arms/tools are an approved work-animation exception. Prop scenes remain under `environment/props/` because they combine presentation with editable collision and idle effects. Superseded service crops/scenes/runtime files are archived and cannot be regenerated by the direction-board processor.

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
| `concept_npc_rootweaver_nema_service_v1` | `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_service_concept_source.png` | `archived` | 1672x941; rejected first pass with overly realistic anatomy and excessive workshop detail; generation history only |
| `concept_npc_rootweaver_nema_service_v2` | `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_service_concept_v2_source.png` | `archived` | 1672x941; compact elderly revision superseded by owner-directed female grove-smith identity; generation history only |
| `concept_npc_rootweaver_nema_grove_smith_v3` | `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_grove_smith_concept_v3_source.png` | `approved_source` | 1672x941; accepted female grove-smith identity, portrait, and Living Rootforge source |
| `char_npc_rootweaver_nema_service_front` | `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_service_source.png` | `superseded_source` | 1672x941; former front-facing 4x2 idle/work source board on cyan; retained for provenance |
| `char_npc_rootweaver_nema_service` | `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_service_side_source.png` | `source` | 1744x902; current generated screen-left three-quarter 4x2 idle/work source board on flat magenta |
| `char_npc_rootweaver_nema_service` | `art_source/cleaned/characters/npcs/rootweaver/rootweaver_nema_service_side_transparent.png` | `intermediate` | 1744x902; chroma-removed alpha source consumed by the deterministic processor |
| `char_npc_rootweaver_nema_service` | `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_service_clean.png` | `intermediate` | 1744x902; binary-alpha component board emitted before native normalization |
| `portrait_npc_rootweaver_nema` | `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_portrait_source.png` | `source_crop` | 312x332; approved concept portrait crop |
| `portrait_npc_rootweaver_nema` | `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_portrait_clean.png` | `intermediate` | 312x332; border-cleaned portrait |
| `service_sanctuary_living_rootforge` | `art_source/generated/environment/sanctuary/services/rootweaver/rootweaver_living_rootforge_source.png` | `source_crop` | 654x664; approved concept Rootforge crop |
| `service_sanctuary_living_rootforge` | `art_source/generated/environment/sanctuary/services/rootweaver/rootweaver_living_rootforge_clean.png` | `intermediate` | 654x664; border-cleaned Rootforge |
| `building_sanctuary_skillkeeper_lodge` | `art_source/generated/environment/sanctuary/services/skillkeeper_lodge_source.png` | `source` | 1254x1254 |
| `building_sanctuary_armskeeper_workshop` | `art_source/generated/environment/sanctuary/services/armskeeper_workshop_source.png` | `source` | 1254x1254 |
| `shop_sanctuary_armskeeper_cart` | `art_source/generated/environment/sanctuary/services/armskeeper_cart_source.png` | `source` | 1254x1254 |
| `sanctuary_service_legacy_pass` | `art_source/archive/environment/sanctuary/legacy_service_pass/` | `archived` | Replaced scenes, runtime files, and reviewed legacy PNGs |
| `landmark_sanctuary_angel_portal_fountain` | `art_source/archive/environment/sanctuary/angel_portal_fountain_256x240_legacy.png` | `legacy` | 256x240; superseded combined runtime crop |

## Active UI and Effects

Current UI visuals combine the approved reusable base theme and named pixel icons with scene-local `StyleBoxFlat`, labels, polygons, and lines for semantic states and effects.

| Canonical ID | Current path | Status | Purpose |
|---|---|---|---|
| `ui_combat_hud` | `ui/combat_hud.tscn` | `active_resource` | Vitality, progression, Menu entry, interaction prompt, compact action tray, and upper-right material/chest reward toast. |
| `ui_character_menu` | `ui/character_menu.tscn` | `active_resource` | Paused Character & Bag and Active Skills surface for Opaw. |
| `ui_player_level_up_feedback` | `entities/player/presentation/player_level_up_visual.gd` | `active_resource` | Small actor glow and rising overhead level label; no center-screen panel. |
| `ui_weapon_shop_menu` | `ui/shops/weapon_shop_menu.tscn` | `active_resource` | Orren's paused class-aware weapon purchase surface. |
| `ui_rootforge_menu` | `ui/crafting/rootforge_menu.tscn` | `active_resource` | Nema's paused read-only recipe, discovery, seal, and material-readiness preview; no crafting mutations. |
| `ui_inventory_slot_button` | `ui/inventory/inventory_slot_button.tscn` | `active_resource` | Compact focusable equipment/material/empty bag slot. |
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
| `fx_opaw_sword_cleave_smoke` | `entities/player/player.tscn` | `active_resource` | Code-native pale cleave band sized from the equipped weapon's authoritative melee shape. |
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

### Active Forest Loot and Material Art

| Canonical ID | Runtime path | Status | Contract and owner |
|---|---|---|---|
| `material_forest_mire_resin` | `assets/items/materials/forest/mire_resin_24x24.png` | `active_runtime` | Distinct 24x24 Mireling resin icon referenced by `mire_resin.tres`. |
| `material_forest_mire_membrane` | `assets/items/materials/forest/mire_membrane_24x24.png` | `active_runtime` | Distinct 24x24 Mireling membrane icon referenced by `mire_membrane.tres`. |
| `material_forest_root_fiber` | `assets/items/materials/forest/root_fiber_24x24.png` | `active_runtime` | Distinct 24x24 Rootling fiber bundle referenced by `root_fiber.tres`. |
| `material_forest_young_heartwood` | `assets/items/materials/forest/young_heartwood_24x24.png` | `active_runtime` | Distinct 24x24 young heartwood icon referenced by `young_heartwood.tres`. |
| `material_forest_forsaken_cloth` | `assets/items/materials/forest/forsaken_cloth_24x24.png` | `active_runtime` | Distinct 24x24 Thrall cloth icon referenced by `forsaken_cloth.tres`. |
| `material_forest_weathered_fittings` | `assets/items/materials/forest/weathered_fittings_24x24.png` | `active_runtime` | Distinct 24x24 fittings icon referenced by `weathered_fittings.tres`. |
| `material_forest_barbed_seed` | `assets/items/materials/forest/barbed_seed_24x24.png` | `active_runtime` | Distinct 24x24 Bramble seed icon referenced by `barbed_seed.tres`. |
| `material_forest_thorn_sap` | `assets/items/materials/forest/thorn_sap_24x24.png` | `active_runtime` | Distinct 24x24 thorn-sap vial icon referenced by `thorn_sap.tres`. |
| `material_forest_husk_heartwood` | `assets/items/materials/forest/husk_heartwood_24x24.png` | `active_runtime` | Distinct 24x24 Husk heartwood icon referenced by `husk_heartwood.tres`. |
| `material_forest_rootbound_core` | `assets/items/materials/forest/rootbound_core_24x24.png` | `active_runtime` | Original-signature 24x24 boss core icon referenced by `rootbound_core.tres`. |
| `prop_forest_stage_clear_chest_closed` | `assets/gameplay/loot/stage_clear_chest/forest_stage_clear_chest_closed_64x48.png` | `active_runtime` | Closed 64x48 Forest reward chest used by `StageRewardChest` and its HUD prompt. |
| `prop_forest_stage_clear_chest_open` | `assets/gameplay/loot/stage_clear_chest/forest_stage_clear_chest_open_64x48.png` | `active_runtime` | Open 64x48 claim-success state used by `StageRewardChest`. |
| `prop_rootbound_reliquary_closed` | `assets/gameplay/loot/stage_clear_chest/rootbound_reliquary_closed_72x64.png` | `active_runtime` | Closed 72x64 dark-heartwood/violet/lime Stage III mini-boss chest tier. |
| `prop_rootbound_reliquary_open` | `assets/gameplay/loot/stage_clear_chest/rootbound_reliquary_open_72x64.png` | `active_runtime` | Open 72x64 Rootbound Reliquary claim-success state. |
| `gameplay_material_pickup` | `gameplay/loot/material_pickup.tscn` | `active_resource` | World-space hop/hover/magnetic/contact presentation for an already-resolved stack. |
| `gameplay_chest_spawn_effect` | `gameplay/loot/chest_spawn_effect.tscn` | `active_resource` | Presentation-only tier-colored rune, core, and pixel-spark reveal. |
| `gameplay_stage_reward_chest` | `gameplay/loot/stage_reward_chest.tscn` | `active_resource` | Y-sorted solid footprint, explicit interaction, tier selection, and closed/open presentation for one authoritative stage-table claim. |

The ten icons originate from the built-in image generation source board at `art_source/generated/items/materials/forest/forest_material_icon_board_chroma_source.png`. The chroma-clean intermediate is retained at `art_source/cleaned/items/materials/forest/forest_material_icon_board_transparent.png`, and the accepted 5x2 native-scale review sheet is `art_source/review/items/materials/forest/forest_material_icons_5x2_24x24.png`. The Forest chest follows the same preserved pipeline under `art_source/generated/gameplay/loot/stage_clear_chest/` and `art_source/cleaned/gameplay/loot/stage_clear_chest/`.

The Rootbound Reliquary was generated with the built-in image tool as one strict 2x1 closed/open pixel-art source board, using the ordinary Forest chest pair only as scale/style references. Its prompt specified a squat dark-heartwood/root-band reliquary, relic-gold lock, restrained violet seams, lime Rootbound core, hard pixel edges, flat magenta chroma, no text, and no background shadow. The original source is `art_source/generated/gameplay/loot/stage_clear_chest/rootbound_reliquary_chroma_source.png`; the chroma-clean intermediate is `art_source/cleaned/gameplay/loot/stage_clear_chest/rootbound_reliquary_transparent.png`; and the accepted 4x closed/open review is `art_source/review/gameplay/loot/stage_clear_chest/rootbound_reliquary_closed_open_4x.png`.

All runtime textures use nearest-neighbor normalization and binary alpha; labels, quantities, rarity colors, and reward rules remain data/UI responsibilities.

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
| `audio_ui_opaw_level_up_chime` | `assets/audio/sfx/ui/opaw_level_up_chime.wav` | `active_runtime` |
| `audio_sfx_rootweaver_rootforge_strike` | `assets/audio/sfx/npcs/rootweaver/rootweaver_rootforge_strike.wav` | `active_runtime` |
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
| `art_source/archive/characters/legacy_runtime_cleanup_2026-08-11/` | `archived` | Former zero-reference character prototypes plus the broken legacy `sprites_24x32` Thrall resource; Godot-ignored and recoverable. |
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
