# Changelog

## 2026-07-13 - Tiered Project Documentation

- Added `PROJECT_CONTEXT.md` as the compact runtime-state and task-routing entry point.
- Replaced the 721-line active decision log with a compact ADR index while preserving Decisions 001-025 under `docs/decisions/`.
- Condensed duplicated completed-roadmap history into milestone summaries; detailed completion records remain in this changelog.
- Changed documentation guidance to load deep design/history files only when relevant to the task.

## 2026-07-13 - Reusable Enemy Health Bars

- Added a compact world-space enemy health-bar component driven by existing health/death signals.
- Kept full-health enemies visually clean while revealing damage progress for 2.2 seconds after each hit.
- Integrated the same component into Forsaken Thralls and Mirelings without duplicating enemy logic.
- Added a dark, gold-edged frame so enemy health remains distinct over bright grass.
- Added regression coverage for initial visibility, damage updates, timed hiding, and death cleanup.

### Fixed

- Deferred melee hitbox monitoring changes during physics callbacks, preventing Godot's `Function blocked during in/out signal` error when a hit kills an attacking enemy.
- Added an immediate logical enabled-state guard so deferred collision changes cannot allow an extra hit.

## 2026-07-13 - Portal Prompt Proximity Correction

- Increased the reusable portal interaction radius from 18 to 52 pixels so the prompt appears before the player overlaps the portal center.
- Clarified the contextual prompt wording to explicitly say `PRESS F`.
- Added a portal-owned world-space interaction label so prompt visibility does not depend solely on an external HUD connection.

All notable completed project changes are recorded here. This project follows a lightweight changelog format until release/versioning policy is selected.

## Unreleased

### Added - 2026-07-12

- Added a timed non-hostile materialization state for the Forsaken Thrall.
- Added a recoil-and-lunge claw presentation aligned with its existing authoritative attack phases.
- Added limited-palette layered ancient-tree and forgotten-god statue assets.
- Added intermittent event-driven canopy sway without per-frame processing.
- Matched Thrall navigation completion distance and agent radius to its 6-pixel foot footprint.
- Reduced the corner vitality HUD and hid persistent controls/build labels during combat.
- Converted the editor-authored five-shape tree coverage into one smooth convex footprint, removing internal seams that could trap the player.
- Made navigation derive one clean convex obstruction from supported rectangle, circle, or convex collision shapes.
- Added a 384x192 Thrall claw sheet with six full-body attack poses in four directions.
- Synchronized Thrall wind-up, active damage, and recovery with animation frame pairs 0-1, 2-3, and 4-5.
- Reduced the detached red marker to a faint curved wind-up cue; authored scratch trails now communicate impact.
- Added the Mireling enemy with 30 health, hop pursuit, telegraphed body slam, materialization, and directional sprites.
- Expanded the map to 30x18 ground cells and added a non-smoothed pixel-stable player camera.
- Added seven fallback spawn points and three data-driven Stage 1 wave resources.
- Added lifecycle-driven Mireling/Thrall wave progression, transient wave HUD presentation, and a stage-clear portal.
- Removed the training target and manually placed Thrall from normal play.
- Added deterministic weighted terrain variation and purposeful tree/statue landmark placement.
- Added a Mireling combat smoke test and expanded environment/navigation regression coverage to 540 cells.
- Enlarged Mireling presentation to 32x32 cells and reworked attacks into a marked snapshot leap with landing-only damage.
- Fixed Thrall back-walking by facing path steering and prevented attacks through props with world line-of-sight checks.
- Prevented enemy bodies from pinning players and unified statue physics/navigation into one convex footprint.
- Replaced distant random-edge spawning with a 250-340 pixel navigation-safe ring and transient HUD arrows.
- Added leap-dodge and obstacle-chase regression tests.
- Fixed the infinite Thrall stop when the player waited directly opposite a statue.
- Replaced edge-centered Thrall paths with corridor-funnel routing and added exact endpoint regression coverage.
- Added reusable local-neighbor separation for Thralls and Mirelings.
- Preserved committed attacks and leaps while spreading chase-state enemies without player collision.
- Added a four-enemy crowd regression; the validated cluster reached 20.19 pixels minimum spacing.
- Added a reusable self-cleaning summon effect with ground runes, inward sparks, and segmented violet lightning.
- Integrated summon presentation with all encounter-spawned enemy types without changing gameplay authority.
- Added wave-clear announcements and a 2.25-second inter-wave recovery pause.
- Added summon-effect integration and cleanup regression coverage.
- Added explicit F/gamepad-west portal interaction and contextual prompt lifecycle.
- Added a reusable paused fade-to-black/loading/fade-in scene transition autoload.
- Added the minimal Stage 2 Forgotten Grove destination and return portal.
- Added portal interaction and full scene-transition regression coverage.

### Added - 2026-07-11

- Added repository-level contribution and maintenance instructions.
- Added the initial game design source of truth.
- Added the proposed Godot architecture and dependency rules.
- Added coding, scene, signal, performance, and pixel-art conventions.
- Added the project roadmap, known-issues register, decision log, and AI handoff notes.
- Added the initial README with honest pre-production setup status.
- Pinned the initial project to Godot 4.7 stable.
- Added a runnable Godot project using a 640x360 logical viewport and GL Compatibility renderer.
- Added pixel-oriented texture filtering and transform/vertex snapping defaults.
- Added keyboard, mouse, and gamepad-ready prototype input actions.
- Added named 2D physics layers for the world, actors, hitboxes, and interactions.
- Added the initial combat proving-ground scene and runtime ownership hierarchy.
- Added Godot-aware version-control ignore rules and initialized the local Git repository.
- Added a reusable player scene with a readable temporary pixel silhouette.
- Added replaceable local input and movement components.
- Added smooth acceleration, deceleration, normalized diagonal movement, and arena containment.
- Added mouse/right-stick aiming with movement-facing fallback.
- Added a typed `facing_changed` signal and presentation-only aim indicator.
- Added a headless movement smoke test covering maximum speed, diagonal speed, and stopping.
- Added gameplay-first pixel-art, environment-scene, occlusion, tilemap, palette, and asset-review requirements.
- Documented the provisional Godot 4.7 workflow for split environment visuals and controlled Y-sorting.
- Added a data-driven plain sword and reusable weapon definition resource.
- Added explicit wind-up, active, and recovery attack phases.
- Added reusable melee hitbox, hurtbox, damage information, and health components.
- Added per-swing target deduplication and active-overlap detection for close melee targets.
- Added a resettable training target with temporary health presentation and damage feedback.
- Added a deterministic end-to-end melee combat smoke test.
- Added a reusable evade definition and phase-driven evade component.
- Added a short supernatural dash with movement/facing direction fallback.
- Added invulnerability during dash movement and a vulnerable recovery lockout.
- Added player health and hurtbox state for real damage-immunity validation.
- Added temporary dash afterimages as replaceable presentation.
- Added public player attack/evade request boundaries enforcing mutual exclusion.
- Added a deterministic evade smoke test covering distance, immunity, recovery, and attack exclusion.
- Added the data-driven Forsaken Thrall enemy archetype.
- Added direct open-arena pursuit with acceleration and collision-aware movement.
- Added explicit chase, wind-up, active, recovery, and death states.
- Added a visible directional melee telegraph and vulnerable recovery window.
- Reused common hitbox, hurtbox, damage, and health contracts for enemy combat.
- Added an enemy encounter smoke test covering player damage, sword damage, and death.
- Added a signal-driven player vitality HUD with numeric and bar presentation.
- Added damage and dash-immunity visual feedback.
- Added an explicit player defeated state that cancels active attacks/evades and rejects new combat requests.
- Added a delayed fallen panel and arena-scene restart through R/gamepad north button.
- Added arena flow ownership separate from player and HUD logic.
- Added a defeat-flow smoke test covering immunity feedback, lethal damage, combat lockout, HUD state, and defeat presentation.
- Added a dark-fantasy prototype atlas and game-scale raster assets for four ground tiles, tree base, tree canopy, and ruined statue.
- Added a reproducible Godot TileSet builder and deterministic TileMapLayer ground sample.
- Added reusable ancient-tree and ruined-statue scenes with visual, collision, shadow, occlusion, and navigation responsibilities.
- Added shared Y-sort ownership for actors and environment props.
- Added runtime Godot 4.7 navigation baking from traversable geometry and carved prop cutouts.
- Upgraded the Forsaken Thrall to NavigationAgent2D path following with scheduled repaths and isolated-test fallback.
- Added an environment/navigation smoke test proving tile population and routing around the tree.
- Increased the logical viewport from 640x360 to 800x450 and the development window from 1280x720 to 1600x900, retaining exact 2x scaling.
- Added a simpler bright-fantasy raster atlas with grass tiles, green canopy, stump, and mossy shrine.
- Added static player and Forsaken Thrall sprite assets with matching pixel density.
- Replaced placeholder body polygons with sprite presentation without changing gameplay authority.
- Moved tree stump/roots permanently to the ground plane while preserving canopy Y-sort occlusion.
- Reduced prop collision/navigation footprints and changed navigation expansion to use a 6-pixel agent radius.
- Added a navigation regression assertion requiring 14-20 pixels of tree-route clearance.
- Simplified gameplay HUD text and removed the large in-arena title.
- Increased the active logical viewport from 800x450 to 960x540 and the display window to 1920x1080, retaining exact 2x scaling.
- Added exact 96x128 player and Thrall sheets composed of sixteen 24x32 direction/action cells.
- Quantized the player sheet to 10 colors and Thrall sheet to 9 colors without dithering.
- Added reproducible SpriteFrames generation for directional idle, walk, attack, dash, and defeated states.
- Integrated the sword into player attack cells and removed the visible floating polygon sword and permanent aim arrow.
- Kept the directional melee pivot solely for invisible hitbox authority.
- Added event-driven player and Thrall animation presenters.
- Reduced HUD and instruction-panel dimensions for the wider gameplay view.
- Expanded the deterministic ground map from 13x8 to 15x9 tiles.
- Added character animation state regression coverage.
- Rebuilt character sheets with binary alpha and removed semi-transparent extraction fragments.
- Increased retained palette detail to 14 player and 11 Thrall opaque colors to preserve facial pixels.
- Removed enclosed transparent holes from every 24x32 character cell.
- Replaced shrinking player attack cells with stable-bound character poses.
- Added a hand-centered three-frame pixel sword swing for wind-up, active, and recovery.
- Reduced and re-centered the sword hitbox around the visible swing.
- Replaced tall movement capsules with 6-pixel circular foot footprints.
- Added separate 24-pixel full-body hurtbox capsules for player and Thrall.
- Moved actor shadows from `y = 7` to the foot plane at `y = -2` and reduced their opacity/size.
- Expanded animation regression tests to enforce binary alpha, stable attack bounds, swing phases, and shadow/collision placement.
- Added a 384x192 directional sword-attack sheet containing twenty-four 64x48 authored action cells.
- Added six player attack frames per direction: anticipation, coil, swing, impact, follow-through, and recovery.
- Replaced the temporary three-frame weapon overlay with unified character-and-sword poses.
- Mapped wind-up to frames 0-1, active damage to frames 2-3, and recovery to frames 4-5.
- Added shared-scale and common-baseline validation for all authored attack cells.

### Breaking Changes

- None currently recorded.

### Bug Fixes

- Made player component dependencies deterministic on a clean Godot class-cache import by explicitly preloading their scripts.
- Removed a fragile child-ready signal emission that ran before the training target's presentation references were ready.
- Removed empty chase-state tweens that produced runtime warnings without animating a property.
- Replaced deprecated outline triangulation with the Godot 4.7 NavigationServer2D source-geometry baking workflow.

### Performance Improvements

- None.
