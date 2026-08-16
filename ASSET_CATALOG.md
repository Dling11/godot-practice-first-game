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

## Environment and Stages

- Shared Forest terrain: `assets/environment/forest/`.
- Authored layouts: `data/environment/layouts/`.
- Sanctuary structures/NPC presentation: `assets/environment/sanctuary/` and `assets/characters/npcs/`.
- Stage V decay terrain and props: `assets/environment/forest/stage_5/`.
- Environment scenes must pair presentation with authored collision, navigation, depth, and occlusion where applicable.

## Items and Loot

- Forest material icons: `assets/items/materials/forest/`.
- Stage V equipment icons: `assets/items/equipment/forest/stage_5_core/`.
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
