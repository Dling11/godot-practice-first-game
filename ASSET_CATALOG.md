# Asset Catalog

This catalog records active asset families and lifecycle boundaries. Exact runtime truth is the reference graph under `assets/`, `data/`, scenes, and scripts. Generated provenance lives under `art_source/`; retired material lives only below `art_source/archive/`.

## Player - King

- Production locomotion/action art: `assets/characters/playable/king/simple_reboot/`.
- Skill body/VFX families: `assets/characters/playable/king/skills/` and the King ability resources under `data/abilities/`.
- Signature weapon data: `data/weapons/king_signature_sword.tres`; weapon catalog: `data/items/king_weapon_catalog.tres`.
- Production skill loadout: `data/skills/king_starting_loadout.tres`.
- Portrait: `assets/characters/playable/king/portrait/`.

## Combat UI

- Shared six-cell runtime atlas: `assets/ui/icons/combat/combat_action_atlas_bc_6x1_24.png`.
- Fixed cells: Echoing Sever, Riftbreak, Sovereign Pursuit, Worldsplitter, Basic Attack, Dodge/Dash.
- Each action is exposed through a reusable `AtlasTexture` resource in `assets/ui/icons/combat/`.
- Generated source images remain in `art_source/generated/ui/combat_action_atlas_bc/`; runtime must never reference those sources.
- The small movement destination indicator and themed cursors remain active presentation assets under `assets/ui/`; their visual approval remains a feel-test item.

## Enemies

- Active enemy art is organized by actor under `assets/characters/enemies/`.
- Production roster: Mireling, Rootling, Forsaken Thrall, Bramble Spitter, Rootbound Husk, Armored Hog, Crag Bear, and Varkuun.
- Crag Bear runtime sheets and SpriteFrames currently live under the legacy `assets/characters/enemies/stage_6_crag_bear/`; its 96x96 portrait is under `assets/characters/enemies/portraits/`. The active action families are an eight-frame `96x64` claw assembled from separate anticipation/execution boards and an eight-frame `96x80` body slam with a real upright pose. Approved/generated boards, prompt provenance, deterministic processor, body-only reviews, and the procedural slam-effect review currently live under `art_source/generated/characters/enemies/stage_6_armored_bear/`, `tools/process_stage_6_crag_bear.py`, and `art_source/review/characters/enemies/stage_6_crag_bear/`. The reusable slam impact itself is correctly identity-owned under `entities/enemies/crag_bear/`. Decision 131 targets the remaining active/source/tool paths for a later controlled migration to identity-owned `crag_bear/` paths; this documentation pass does not move them. Rejected static/awkward attack sources and superseded runtime derivatives are archived under `art_source/archive/characters/enemies/crag_bear_rejected_attacks_2026-08-24/`.
- Bramble Spitter runtime body sheets, seven-cell thorn-seed sheet, and named SpriteFrames live under `assets/characters/enemies/bramble_spitter/`. Accepted generated action/locomotion/projectile sources live under `art_source/generated/characters/enemies/bramble_spitter_rework/`; `tools/process_bramble_spitter_rework.py` derives binary-alpha fixed-cell sheets, preserves idle-to-attack actor mass, and deliberately omits the rejected eighth spent-seed pose. `tools/build_bramble_spitter_sprite_frames.gd` owns reproducible four-frame flight and three-frame impact resources. Runtime review is under `art_source/review/characters/enemies/bramble_spitter_rework/`; the superseded three-frame body sheet/source is archive-only under `art_source/archive/characters/enemies/bramble_spitter_replaced_2026-08-24/`.
- Enemy definitions own tier and movement-footprint radius. Foot auras are procedural/runtime presentation and are not replacement hurtboxes.
- Portraits used by dialogue live under `assets/characters/enemies/portraits/`.

## Planned Disciples of The One Above

- Decision 136 (2026-09-12) rebuilds the rewardless F7 Examiner proof with ten eight-column `192x160` sheets, 116 named clips, disjoint anticipation/contact spans, original action/footstep audio, an engraved-slate Court, exact traversable cyan wards, compact review controls, and actual phase/technique text. Grounded charge now stops at physical collision. Body baseline is 128 and visual origin is -48; final owner feel approval and production Stage VII integration remain pending. New immutable sources, full built-in ImageGen prompts, and import measurements are under `art_source/generated/characters/disciples/examiner/rework_2026_09_12/`. `FRAME_MANIFEST.md` owns animation spans. The previous 192x128 sheets/imports and edited builder/visual/test snapshots are preserved in `art_source/archive/characters/disciples/examiner_before_rework_2026_09_12/`; earlier source boards remain historical provenance. `court_slate_floor.png` is the 650x390 flat floor; the original Descent seal remains live. `generate_examiner_rework_sfx.py` creates sixteen original 44.1kHz PCM cues and peak/RMS provenance. Runtime stills and the scripted showcase are under the corresponding `art_source/review/characters/disciples/examiner/rework_2026_09_12/` folder.
- Future promoted Disciple ownership remains `assets/characters/disciples/examiner/`, shared portraits under `assets/characters/disciples/portraits/`, Split Glaive under `assets/weapons/divine_order/split_glaive/`, and related reusable divine-order VFX/audio under their purpose folders. The current `assets/characters/enemies/examiner/` location is debug-prototype debt; no path may include `stage_7`.
- Executioner target ownership is reserved conceptually under `assets/characters/disciples/executioner/` and `assets/weapons/divine_order/execution_wheel/`, but no empty/runtime asset tree should be created until her production contract is approved.
- The reattached two-character concept is preserved unchanged at `art_source/references/characters/disciples/the_one_above_disciples_concept_reference.png`; adjacent metadata records its provenance, dimensions, and checksum. The approved compact-pixel V3 style lock remains in `art_source/review/characters/disciples/examiner/`. Earlier height/static reviews, realistic source/runtime sheets, and V1 gameplay captures are recoverable under `art_source/archive/characters/disciples/examiner_realistic_prototype_2026-08-24/`; none belongs in runtime `assets/`.
- Decision 133's two external special-arena references and metadata live under `art_source/references/environment/divine_order/`; the original empty-arena preview V1 lives under `art_source/review/environment/divine_order/court_of_first_measure/`. Planned runtime ownership is `assets/environment/divine_order/court_of_first_measure/`, `assets/vfx/divine_order/axiom_divide/`, and `environment/arenas/divine_order/court_of_first_measure/`. None exists yet.

## Sanctuary - Umi

- Approved concept anchor: `art_source/generated/characters/npcs/blue_witch_transmuter/blue_witch_transmuter_source_v1.png`.
- Final side-facing production source: `art_source/generated/characters/npcs/umi/umi_side_service_source_v1.png`; deterministic processor: `tools/process_umi_transmuter_assets.py`.
- Runtime world sheet and dedicated close dialogue portrait: `assets/characters/npcs/umi/`; actor scene: `entities/npcs/umi/umi.tscn`.
- Generated Echo Crucible source: `art_source/generated/environment/sanctuary/services/umi/`; processed 72x64 side-facing workbench: `assets/environment/sanctuary/services/umi/`; deterministic portrait/workbench processor: `tools/process_umi_service_assets.py`; narrow collision and right-bowl pulse scene: `environment/props/sanctuary/echo_crucible/`.
- All eight 48x48 frames face left toward the workstation. The top row is idle and the bottom row is the service gesture; runtime never references the generated source boards.

## Environment and Stages

- Shared Forest terrain: `assets/environment/forest/`.
- Authored layouts: `data/environment/layouts/`.
- Sanctuary structures/NPC presentation: `assets/environment/sanctuary/` and `assets/characters/npcs/`.
- Stage V decay terrain and props: `assets/environment/forest/stage_5/`.
- Stage VI production environment: approved muted ground under `assets/environment/forest/stage_6/tiles/`; six reusable transparent cliff/rock pieces under `assets/environment/forest/stage_6/props/modular_cliffs/`; stable four-frame waterfall sheet under `assets/environment/forest/stage_6/waterfall/` with fixed banks and downward-only curtain motion, plus reusable static lip, `4x1` water-only flow, and static basin parts under `waterfall/modules/`; reusable scene under `environment/props/stage_6_waterfall/`; generated source boards/prompt provenance under `art_source/generated/environment/forest/stage_6/modular_topdown/`; deterministic processing in `tools/process_stage_6_environment.py`; runtime captures under `art_source/review/environment/forest/stage_6/runtime/`. Rejected canyon/threshold sources and derivatives are recoverable only under `art_source/archive/environment/stage_6_rejected_perspective_2026-08-24/`.
- Generated Sanctuary gate: fixed `assets/environment/sanctuary/landmarks/generated/angel_expedition_portal_static_192x256.png` plus isolated `sanctuary_portal_energy_4x_44x112.png` (`4x1`, 44x112 cells).
- Generated abyssal stage-exit base: `assets/environment/portals/generated/stage_abyssal_veil_base_16x_160x192.png` (`16x1`, 160x192 cells), with authored motion across upper/middle/lower interior, a nonempty moving center, and changing rim silhouette. Generated dense lightning/particle overlay: `assets/environment/portals/generated/stage_abyssal_veil_lightning_fx_16x_256x224.png` (`16x1`, 256x224 cells). Runtime tier data supplies tint, reduced display scale, independent base/FX speeds, and FX intensity; generated 4x4 boards and corrected review outputs live under `art_source/generated/environment/portals/abyssal_veil_portal/`. Ground-vortex, portal-ring, and localized-eye passes are archived.
- Environment scenes must pair presentation with authored collision, navigation, depth, and occlusion where applicable.

## Items and Loot

- Forest material icons: `assets/items/materials/forest/`.
- Stage VI Crag Iron and Echo Claw use distinct 24x24 binary-alpha icons in the Forest material folder and canonical definitions under `data/items/materials/forest/`.
- Stage V equipment icons: `assets/items/equipment/forest/stage_5_core/`. Varkuun Edge, Old Bark Helm, Heartwood Plate, and Rootfiber Gloves use generated V2 sources in `art_source/generated/items/equipment/forest/stage_5_core/`, processed into 64x64 binary-alpha runtime silhouettes; the combined review sheet lives beside the other item reviews.
- Immutable item/material/recipe definitions: `data/items/`, `data/materials/`, and `data/crafting/`.
- Loot/chest presentation: `assets/gameplay/loot/`.
- Runtime item identity comes from stable resource IDs, never filenames or palette alone.

## Audio

- Music: `assets/audio/music/`.
- SFX: `assets/audio/sfx/`.
- Crag Bear's dedicated action suite lives under `assets/audio/sfx/enemies/crag_bear/`: two original deterministic contact cues plus two short CC0 bear-growl variants. The source pack remains recoverable under `art_source/archive/audio/stage_6_crag_bear_cc0_sources/`.
- Licensing/provenance: `assets/audio/ATTRIBUTION.md`.
- Audio observes authoritative events; it never decides damage, cooldown, movement, or reward outcomes.

## Lifecycle Boundary

- `assets/` contains only runtime-referenced images after the 2026-08-16 reachability cleanup.
- Retired Opaw runtime/data/tests/tools and related sources: `art_source/archive/retired_opaw_2026-08-16/`.
- Proven-unreferenced images and the unused equipment showcase: `art_source/archive/retired_unused_assets_2026-08-16/`.
- Obsolete active-design proposals: `art_source/archive/retired_docs_2026-08-16/`.
- Archive moves are recoverable, but archive content is not imported or supported by the current Godot runtime.

## Acceptance Rules

- Runtime textures use exact documented grids, nearest filtering, stable origins/foot baselines, binary alpha when required, and native 960x540 review.
- One atlas is preferred for closely related small controls when it reduces imports without harming replacement or ownership boundaries.
- Before archiving an active image, prove it has no reference from active scripts, scenes, resources, or project configuration. Re-run the full smoke suite and editor import after any cleanup.

### Examiner follow-up (Decision 137)

- `assets/characters/enemies/examiner/examiner_walk_sheet_192x160.png`: 4x4 alternating gait; existing action sheets re-extracted with full weapons.
- `assets/vfx/divine_order/examiner/`: energy and dedicated Axiom beam (256x128 cells), sweep (192x192), impact (256x256), each 4x2 chronological frames; crimson circle/arrow decals and Court danger shader.
- `art_source/generated/characters/disciples/examiner/polish_2026_09_12/`: built-in ImageGen source PNGs, exact prompt history, and import report. The main rework importer also builds gait/effects; reimport before rebuilding SpriteFrames.
- Existing Examiner audio `rework/` folder: slab breaks/rubble for slam/Descent and a beam cut for Axiom. Original deterministic generator and provenance retained.
- `art_source/review/characters/disciples/examiner/polish_2026_09_12/`: GPU preview with sound, gait/contact boards, full cell audit, and validation notes.
