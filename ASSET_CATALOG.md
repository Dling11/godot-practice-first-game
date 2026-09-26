# Asset Catalog

**Unbroken Vow Lab assets (2026-09-27):** `tools/prepare_unbroken_vow_test_assets.gd` packs approved review body/pressure/barrier into three lossless, non-mipmapped atlases plus the original contact WAV under `assets/vfx/abilities/king/unbroken_vow_test/`. Consumer: F7 `unbroken_vow_test.gd`, with clipped Sprite2D regions and nearest sampling. These are Lab visual-test assets, not a production buff.

**Unbroken Vow activation study (2026-09-27):** `art_source/generated/characters/king/unbroken_vow_activation_2026_09_27/` holds exact King templates, final body/pressure sources and prompts. Matching review folder has a 4x2 down-pose atlas, measurements, normal/slow/native GIFs, click-to-play HTML and original pressure WAV. Built with `tools/build_unbroken_vow_activation_review.gd`; existing GIF builder supports `-Activation`, `-Slow`, `-Native`. Art-only assets; no runtime consumer.

**Unbroken Vow V2 (2026-09-27):** Source/prompts: `art_source/generated/characters/king/unbroken_vow_v2_2026_09_27/`. Review: matching path below `art_source/review/`. Six 112x112 binary-alpha effect drawings, unchanged King C composites and twelve-frame GIF (repeated sustain). Existing review builders accept `--shield-v2` and `-ShieldV2` respectively. No runtime consumer.

## Unbroken Vow generated Skill 4 review - 2026-09-27

- `art_source/generated/characters/king/unbroken_vow_2026_09_27/activation_source.png` is a built-in ImageGen six-cell concept with provenance beside it. `tools/build_unbroken_vow_review.gd` extracts six 112x112 eleven-color binary-alpha effect frames and composites the exact approved King C idle cell into `art_source/review/characters/king/unbroken_vow_2026_09_27/`; `tools/build_unbroken_vow_review_gif.ps1` produces the looping 192x128 GIF. These are review-only assets: no runtime scene, animation or slot references them. Worldsplitter remains live in slot 4 until the owner-reviewed buff is playable; Decision 159 moves it to 5 with ownership preserved afterward.

## Sovereign Pursuit production presentation - 2026-09-26

- Production `assets/vfx/abilities/king/sovereign_pursuit_review/landing.png` is a 4x4 padded binary-alpha atlas with fifteen visible blade-cut/pressure drawings and one transparent cleanup cell; `travel.png` has eight padded travel drawings. Decision 157 selects these existing review-named resources in `player.tscn`; old Pursuit sheets are in the recovery archive. The directory name is kept to avoid regenerating approved art while Skill 4 work remains open.
- Selected source and prompts: `art_source/generated/vfx/king/sovereign_pursuit_2026_09_26/`; the rejected stone source stays there for provenance. `tools/build_sovereign_pursuit_review.gd` still packs the approved atlas. Historical playback lives under `art_source/review/characters/king/sovereign_pursuit_2026_09_26/`; its old capture script is archived. Existing launch/landing audio is reused.

## Molten Crash VFX - 2026-09-26

- Runtime: `assets/vfx/abilities/king/molten_crash/sword.png`, `burst.png`, `aftershock.png` and `caldera_core.png`, sixteen padded 512px cells each, 2048px atlases; nearest/clipped regions, no mipmaps. Foundation recolors the same registered sword/burst to blue stone and white-cyan light; Advanced and above retain the approved molten orange. `aftershock.png` now shows a moving outward heat wave. The separate compact core appears only in Mature.
- Built-in generated source and exact prompts: `art_source/generated/vfx/king/molten_crash_2026_09_26/`. References are the accepted Molten Crash V2 concept and Earthsplitter sword identity; no King body regeneration.
- `tools/build_molten_crash.gd` packs registered art. Historical four-form playback is under `art_source/review/characters/king/molten_crash_upgrades_2026_09_26/`; its obsolete toggle-based capture scripts are archived. The selected aftershock and core sources remain in the generated source folder. The campaign starts at blue Foundation; higher forms are Lab-only until unlock rules exist.

This catalog records active asset families and lifecycle boundaries. Exact runtime truth is the reference graph under `assets/`, `data/`, scenes, and scripts. Generated provenance lives under `art_source/`; retired material lives only below `art_source/archive/`.

## Player - King

- Earthsplitter production Foundation uses `assets/vfx/abilities/king/earthsplitter/sword.png`, `pressure_v2.png` and `rupture.png` with the approved fixed lane, clipped summoned sword and upright eruptions. Fan and Cascade share these assets as Lab-only form comparisons. `tools/build_earthsplitter_pressure.gd` and `tools/build_earthsplitter_review.gd` are still the art builders; historical toggle-based capture scripts are archived. Existing cleave/ground impact audio is reused.

- The rejected targeted Riftbreak VFX, its packer and comparison were moved to `art_source/archive/king_retired_2026_09_26/`. They are not imported or playable.

- Latest side-leg source parts: `leg_parts.png` and locked `side_upper_approved.png` in `art_source/generated/characters/king/spellward_locomotion_2026_09_14/`. `tools/build_king_side_leg_cycle.gd` renders the final walk_side.png without regenerating accepted hands. Foot trajectories, prompts and normal/slow review: `art_source/review/characters/king/spellward_legcycle_2026_09_14/`.

- Latest Spellward side gait: `assets/characters/playable/king/spellward/walk_side.png`, eight 192x128 cells in two rows (left/right), 14 FPS before equipment scaling. Front/back still use original walk.png at four frames/7 FPS. Source `side_body.png` in the Spellward locomotion source folder; review and generation provenance in `art_source/review/characters/king/spellward_bodywalk_2026_09_14/`. The foot-only side_pass study is superseded for live side clips.

- The former `greatsword/` action sheets are archived. King C under `spellward/` is the production body; `simple_reboot/` remains the earlier rollback baseline.
- Production King C body: `assets/characters/playable/king/spellward/`, ten 192x128-cell atlases and `spellward_frames.tres` with the accepted locomotion/attacks and provisional skill-body aliases. Both player and character menu use these frames. `tools/build_king_spellward.gd` retains reproducible generation; source/review material stays under the identity-owned `art_source/` folders.
- Skill body/VFX families: `assets/characters/playable/king/skills/` and the King ability resources under `data/abilities/`.
- Spellward side-walk follow-up: `side_pass.png` beside the locomotion source adds two forward-foot poses used only in left/right walk rows. Prompt, packed measurements, preserved prior walk, normalized frame board and actual Lab recording live under `art_source/review/characters/king/spellward_sidewalk_2026_09_14/`.
- The accepted locomotion source and historical comparisons remain under `art_source/generated/characters/king/spellward_locomotion_2026_09_14/` and matching review folders. Production `entities/player/presentation/king_spellward_outline.gdshader` applies the one-source-texel contour. Accepted attack atlases remain unchanged.
- Signature weapon data: `data/weapons/king_signature_sword.tres`; weapon catalog: `data/items/king_weapon_catalog.tres`.
- Production skill loadout: `data/skills/king_starting_loadout.tres`.
- Portrait: `assets/characters/playable/king/portrait/`.

## Combat UI

- Owner-selected Eclipse Bind action bar: `art_source/generated/ui/eclipse_bind_hotbar/` holds the generated empty-frame and matching shadow-step Dash sources plus prompts. `tools/build_eclipse_bind_hud_art.gd` creates fixed-palette binary-alpha `assets/ui/hud/eclipse_bind/eclipse_frame_compact_720x104.png`, the earlier `eclipse_frame_760x120.png` comparison, and `eclipse_dash_24.png`. The active border has a transparent center over a separate mouse-ignored 78%-opacity Godot veil. Dash slot and character menu share the glyph; all twelve controls remain real Godot nodes. Native current review: `art_source/review/ui/eclipse_bind_tuned_2026_09_27/`; lighter compact comparison: `art_source/review/ui/eclipse_bind_compact_2026_09_27/`; first opaque comparison: `art_source/review/ui/eclipse_bind_runtime_2026_09_27/`. This is a HUD motif, not a confirmed divine-order insignia.
- Historical provisional dragon action-bar source and derivatives remain under `art_source/generated/ui/divine_dragon_hotbar/` and `assets/ui/hud/divine_dragon/`; active scenes do not reference them. The unselected Shadow Crown concept remains in `art_source/review/ui/shadow_action_bar_concepts_2026_09_27/`.
- Shared six-cell runtime atlas: `assets/ui/icons/combat/combat_action_atlas_bc_6x1_24.png`.
- Fixed cells: Earthsplitter, Molten Crash, Sovereign Pursuit, Worldsplitter, Basic Attack, legacy Dodge/Dash. The HUD and character menu now display the Eclipse Bind shadow-step Dash glyph; the atlas cell remains for compatible older uses. The first two atlas cells retain their legacy image indices for save/UI compatibility.
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
