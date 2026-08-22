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
- Production roster: Mireling, Rootling, Forsaken Thrall, Bramble Spitter, Rootbound Husk, Armored Hog, and Varkuun.
- Enemy definitions own tier and movement-footprint radius. Foot auras are procedural/runtime presentation and are not replacement hurtboxes.
- Portraits used by dialogue live under `assets/characters/enemies/portraits/`.

## Sanctuary - Umi

- Approved concept anchor: `art_source/generated/characters/npcs/blue_witch_transmuter/blue_witch_transmuter_source_v1.png`.
- Final side-facing production source: `art_source/generated/characters/npcs/umi/umi_side_service_source_v1.png`; deterministic processor: `tools/process_umi_transmuter_assets.py`.
- Runtime sheet/portrait: `assets/characters/npcs/umi/`; actor scene: `entities/npcs/umi/umi.tscn`; compact procedural workstation: `environment/props/sanctuary/echo_crucible/`.
- All eight 48x48 frames face left toward the workstation. The top row is idle and the bottom row is the service gesture; runtime never references the generated source boards.

## Environment and Stages

- Shared Forest terrain: `assets/environment/forest/`.
- Authored layouts: `data/environment/layouts/`.
- Sanctuary structures/NPC presentation: `assets/environment/sanctuary/` and `assets/characters/npcs/`.
- Stage V decay terrain and props: `assets/environment/forest/stage_5/`.
- Generated Sanctuary gate: fixed `assets/environment/sanctuary/landmarks/generated/angel_expedition_portal_static_192x256.png` plus isolated `sanctuary_portal_energy_4x_44x112.png` (`4x1`, 44x112 cells).
- Generated abyssal stage-exit base: `assets/environment/portals/generated/stage_abyssal_veil_base_16x_160x192.png` (`16x1`, 160x192 cells), with authored motion across upper/middle/lower interior, a nonempty moving center, and changing rim silhouette. Generated dense lightning/particle overlay: `assets/environment/portals/generated/stage_abyssal_veil_lightning_fx_16x_256x224.png` (`16x1`, 256x224 cells). Runtime tier data supplies tint, reduced display scale, independent base/FX speeds, and FX intensity; generated 4x4 boards and corrected review outputs live under `art_source/generated/environment/portals/abyssal_veil_portal/`. Ground-vortex, portal-ring, and localized-eye passes are archived.
- Environment scenes must pair presentation with authored collision, navigation, depth, and occlusion where applicable.

## Items and Loot

- Forest material icons: `assets/items/materials/forest/`.
- Stage V equipment icons: `assets/items/equipment/forest/stage_5_core/`. Varkuun Edge, Old Bark Helm, Heartwood Plate, and Rootfiber Gloves use generated V2 sources in `art_source/generated/items/equipment/forest/stage_5_core/`, processed into 64x64 binary-alpha runtime silhouettes; the combined review sheet lives beside the other item reviews.
- Immutable item/material/recipe definitions: `data/items/`, `data/materials/`, and `data/crafting/`.
- Loot/chest presentation: `assets/gameplay/loot/`.
- Runtime item identity comes from stable resource IDs, never filenames or palette alone.

## Audio

- Music: `assets/audio/music/`.
- SFX: `assets/audio/sfx/`.
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
