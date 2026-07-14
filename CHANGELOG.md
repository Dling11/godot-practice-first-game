# Changelog

## 2026-07-15 - Portal Front/Behind Occlusion

- Split the existing portal image into an always-behind center-stair layer and a normally Y-sorted arch/guardian structure without changing its combined appearance.
- Added a separate front-approach depth area spanning the doorway and both guardians that moves the portal structure behind the character before their head overlaps it, while the smaller expedition prompt trigger keeps its independently authored close range.
- Players now remain visible throughout the southern approach and interaction, then return to normal front/behind Y-sorting after leaving; the user's small front stop, trigger, placement, and rear-backstop edits remain unchanged.
- Documented that `PortalBackstopCollision` prevents physical traversal through the rear monument but does not control render order.

## 2026-07-14 - Walk-In Portal and NPC Idle Refinement

- Replaced the combined portal/fountain runtime crop with a standalone 192x192 angel expedition portal and independent 112x96 divine fountain generated for the approved Sanctuary style.
- Reauthored the north courtyard so the player walks around the fountain, crosses visible open space, and ascends an unobstructed center staircase before the expedition prompt appears at the doorway.
- Split fountain collision and water presentation into a reusable `DivineFountain` scene; the expedition altar now owns only portal interaction, guardian footprints, rear backstop, glow, and runes.
- Replaced Armskeeper Orren's board crop with a standalone full-body source whose hands and silhouette remain intact in all four runtime frames.
- Added reusable timer-driven, one-pixel NPC breathing to Eira and Orren without moving their collision, interaction, shadows, or gameplay authority.
- Added deterministic standalone-asset processing, archived the superseded combined landmark outside runtime imports, and extended Sanctuary traversal, asset, scene, and editor-preview regression coverage.

## 2026-07-14 - Generated Sanctuary Visual and Interaction Rebuild

- Converted the current Mushroom Dwelling and Merchant Hall from rectangle collision resources to editable `CollisionPolygon2D` footprints without changing their existing bounds; visual shadows remain independent `Polygon2D` nodes.
- Added a reusable editor-only green checker backdrop to isolated Sanctuary prop/NPC scenes so transparent art and dark shadows remain readable against Godot's black 2D canvas; it performs no runtime drawing or processing.
- Corrected the Sanctuary crop pipeline so dark faces, arms, building interiors, and sign connectors survive while board background is removed; restored Eira's complete staff/book silhouette and Orren's complete arms while filtering the adjacent weapon-stall pole fragment.
- Moved both houses to connected side routes and rebuilt the angel landmark with a fountain polygon, small statue footprints, separate doorway pillars, a rear backstop, and a compact portal-threshold trigger; both fountain-side approaches remain continuously walkable for the player's footprint.
- Removed the unused first-round code-drawn house, fountain, altar, mushroom decoration, Veilkeeper presentation, their import metadata, and their obsolete sprite-kit generator after confirming no active runtime references remained.
- Added a mouse-operable top-right close button to The Awakened menu, clickable dialogue advance/close behavior, and Escape cancellation without accidental Eira menu chaining.
- Kept ambient music processing through paused modals and enabled continuous OGG looping so NPC conversations no longer interrupt the track.
- Preserved an approved 1536x1024 generated Sanctuary direction board and added a reproducible processor for reviewed crops, dark-background removal, hard alpha, exact canvases, idle accents, and dedicated terrain.
- Replaced borrowed Stage 1 ground with a Sanctuary-only 64x64 grass/cobblestone atlas and an authored one-cell route network.
- Replaced the first-round hub visuals with the angel portal/fountain, mushroom dwelling, merchant hall, weapon stall, two Sanctuary tree silhouettes, Skillkeeper Eira, and Armskeeper Orren.
- Kept the angel landmark as the existing expedition interaction while adding independent rune, portal, and water idle presentation plus traversal collision.
- Added a reusable `DialogueNpc` contract; Eira now opens the existing skill-information menu after restrained dialogue, while Orren honestly previews the future weapon service without purchases or equipment logic.
- Extended Sanctuary regression coverage across nine normalized assets, dedicated tiles, both NPC interactions, idle animation, pause restoration, collision, prompts, and Stage 1 selection.

## 2026-07-14 - Sanctuary Expedition Hub

- Added the safe `Sanctuary of the Remembered Veil` as the new-journey destination and Stage 2 return destination.
- Added a compact 18x12 hub layout with four mushroom homes, border trees, animated divine fountain, glowing mushroom clusters, central paths, and expedition altar.
- Added Veilkeeper Eira with a four-frame lantern idle, contextual talk icon, three-line restrained introduction, and reusable paused dialogue panel.
- Added a reusable expedition menu with Stage 1 available and two clearly sealed future-route previews.
- Added five reproducible exact-grid hard-alpha runtime sprites and kept shadows/glows separate from raster art.
- Added automated Sanctuary asset, animation, dialogue, prompt, pause, altar, and destination coverage.

## 2026-07-14 - Battle of Gods Title Screen

- Changed the F5 main scene from Stage 1 to a dedicated Battle of Gods title screen using the shared UI theme.
- Added a deterministic 960x540 luminous dark-fantasy grove background with a distant divine fountain, separate tree silhouettes, mist/fireflies, and vignette layers.
- Added keyboard, mouse, and gamepad-ready focus loops for Begin the Awakening, Settings, and Quit to Desktop.
- Added functional session-only Music, Combat Sound, and Menu Sound toggles using the existing audio buses.
- Routed new journeys through `RunSession.reset_run()` and the existing fade/loading transition into Stage 1.
- Added automated coverage for background contracts, initial/restored focus, settings behavior, audio toggles, run reset, and title-to-Stage-1 transition.

## 2026-07-14 - Shared UI Theme and Named Icon Kit

- Added a reusable dark-fantasy Godot `Theme` covering common panels, labels, buttons, progress bars, separators, focus, disabled, and tooltip states.
- Added nine reproducible binary-alpha pixel icons for health, XP, coins, attack, dash, Sweeping Cut, sealed slots, portal interaction, and future NPC dialogue.
- Applied the theme and semantic icons to the combat HUD and character menu while retaining local styles only for meaningful health/cooldown/skill states.
- Extended the portal proximity event with presentation metadata so the existing HUD prompt displays a portal icon and can later serve other interactables.
- Added automated theme, icon-size, hard-alpha, scene-wiring, and portal-icon coverage.

## 2026-07-14 - Bramble Spitter Asset Migration

- Migrated the Bramble Spitter's active 32x32 action sheet and `SpriteFrames` into its canonical `assets/characters/enemies/bramble_spitter/` runtime domain.
- Updated the Spitter scene, shared frame builder, architecture, README, roadmap, art-source mapping, and asset catalog.
- Extended exact-grid and binary-alpha regression validation to both 32x32 creature sheets.
- Preserved original and cleaned Bramble generation images under Godot-ignored `art_source/generated/`, completing migration for all current playable character art.

## 2026-07-14 - Mireling Asset Migration

- Migrated the Mireling's active 32x32 action sheet and `SpriteFrames` into its canonical `assets/characters/enemies/mireling/` runtime domain.
- Updated the Mireling scene, shared frame builder, animation test, architecture, README, roadmap, art-source mapping, and asset catalog.
- Preserved original and cleaned generation images under `art_source/generated/` and moved the superseded 24x24 runtime experiment into `art_source/archive/` rather than deleting it.

## 2026-07-14 - Forsaken Thrall Asset Migration

- Migrated the Forsaken Thrall's locomotion sheet, six-frame claw sheet, and `SpriteFrames` into its canonical `assets/characters/enemies/forsaken_thrall/` runtime domain.
- Updated the Thrall scene, shared reproducible frame builder, animation regression test, architecture, README, roadmap, and asset catalog to the canonical identity and paths.
- Preserved four original/cleaned Thrall generation images under Godot-ignored `art_source/` and removed obsolete import sidecars from their former locations.

## 2026-07-14 - The Awakened Asset Migration

- Migrated The Awakened's locomotion sheet, six-frame sword sheet, and `SpriteFrames` into the canonical `assets/characters/awakened/` runtime domain.
- Updated the player scene, reproducible frame builder, animation regression test, architecture, README, and asset catalog to the canonical identity and paths.
- Added the Godot-ignored `art_source/` workspace and preserved four original/cleaned Awakened generation images there without loading them at runtime.
- Removed obsolete Godot import sidecars for the moved files so the editor can regenerate correct metadata at their new paths.

## 2026-07-14 - Visual Asset Documentation Foundation

- Added `ART_DIRECTION.md` as the source of truth for the luminous dark-fantasy theme, palette roles, lighting, pixel baselines, UI language, and replaceable-background contract.
- Added `ASSET_CATALOG.md` with canonical IDs, verified dimensions, current runtime paths, controlled migration targets, runtime owners, planned UI assets, and lifecycle status.
- Defined non-destructive source/intermediate/runtime/archive handling and semantic asset naming before any physical file migration.
- Recorded the asset identity and replaceable-presentation decision as ADR 033.

## 2026-07-14 - Portal Prompt Layout Correction

- Removed the portal's duplicate world-space instruction and retained one reusable HUD-owned interaction prompt.
- Moved the prompt above the centered four-slot skill bar so contextual interaction text no longer overlaps combat controls.

## 2026-07-14 - Four-Slot Skills and Run Continuity

- Moved Sweeping Cut to numbered skill slot 1 while retaining Q as a temporary compatibility binding, and reserved inputs 2-4 for authored future abilities.
- Replaced the corner Q/E display with a centered four-slot combat bar.
- Added a paused Tab character/skill information menu for The Awakened with level, XP, coins, core actions, and sealed skill paths.
- Added a narrow in-memory `RunSession` so XP and coins survive portal transitions while defeat restart begins a fresh run; no disk save behavior was added.
- Added progression-continuity and character-menu regression coverage.
- Replaced the encounter's fixed startup delay with navigation-map readiness checks, preventing first-spawn queries before Godot synchronizes the map.

## 2026-07-14 - Event-Driven Combat Audio

- Added distinct CC0 cues for sword swing/impact, Sweeping Cut, dash, player damage, Thrall claw, Mireling leap/landing, Spitter fire, and seed impact.
- Added dedicated SFX and reserved UI buses beside the existing Music bus.
- Added actor-local positional audio observers synchronized to existing authoritative phase/state signals.
- Retained only ten used clips from the 95-file RPG Sound Pack and recorded their CC0 provenance.
- Added clean headless configuration/state synchronization regression coverage.
- Clarified that `Player` is the technical role while `The Awakened` is only the current prototype archetype/title; no personal name is approved.

## 2026-07-14 - Combat Impact Feedback

- Added reusable world-space damage numbers and three-pixel hit bursts for accepted player hits and accepted incoming player damage.
- Added a restrained 0.11-second camera-offset nudge that preserves gameplay time, dodge windows, telegraphs, and combat authority.
- Added cleanup and accepted-hit regression coverage for combat feedback.

## 2026-07-14 - Session Progression and Ambient Audio Foundation

- Added reusable session-only level-10 XP/coin progression with cumulative thresholds, capped leveling, and a compact level/XP/coin HUD readout.
- Added data-driven death rewards: Mirelings grant 8 XP/1 coin, Thralls 15 XP/3 coins, and Bramble Spitters 20 XP/5 coins.
- Kept levels non-interruptive and free of random upgrade choices; persistence, unlocks, and skill setup remain intentionally deferred.
- Added `AudioDirector`, its dedicated Music bus, stage-local music requests, and headless-safe music-routing coverage.
- Added the CC0 `Cathedral in the Forest (ambient loop)` by congusbongus as the first forest/grove background track, with local attribution.
- Added progression and audio smoke coverage.

## 2026-07-14 - Authored Stage 2 Grove Encounter

- Restored Stage 1 Wave 3 to its beginner 2 Mireling + 2 Thrall composition; the Bramble Spitter no longer appears there.
- Replaced the Stage 2 placeholder with `Thorns of the Forgotten Grove`: a 24x14 grove layout with deliberate tree, statue, navigation, spawn, projectile, and effect ownership.
- Added an arrival-lore delay, a two-Mireling warm-up wave, then one Mireling plus the first Bramble Spitter.
- Added a clear-gated portal back to Stage 1, Stage 2 defeat/restart ownership, and reusable explicit encounter start support.
- Added Stage 2 layout/encounter regression coverage and expanded transition coverage for the delayed return portal.

## 2026-07-13 - Bramble Spitter Ranged Enemy

- Added a 40-health forest-corrupted Bramble Spitter with navigation-aware range positioning and local crowd separation.
- Added a readable 0.75-second committed line telegraph, slow 8-damage seed projectile, world collision, finite lifetime, and 1.25-second recovery.
- Added one Spitter to Wave 3 by replacing one Mireling, preserving the four-enemy encounter cap.
- Increased Forsaken Thrall prototype health from 75 to 100 while preserving its attack damage and timings.
- Added generated 4x4 source art, cleaned provenance, a reproducible strict-pixel atlas processor, and runtime SpriteFrames.
- Added ranged-dodge, wave-composition, Thrall-durability, crowd-separation, and obstacle-navigation regression coverage.
- Removed a stale Mireling SpriteFrames UID reference that caused a harmless load warning after reproducible frame rebuilding.

### Fixed

- Rebuilt the Bramble Spitter SpriteFrames after texture import so every frame references its atlas instead of rendering an invisible body.
- Made the frame builder fail explicitly when the Spitter atlas is unavailable and added runtime coverage for a non-null body frame texture.

### Polished

- Made the Spitter swell and brighten during wind-up, added a dark-outlined warning line, firing recoil, muzzle flash, leaf sparks, a brighter seed trail, and a thorny impact burst.
- Extended the ranged regression test to verify visible telegraph, muzzle-flash, and impact presentation without moving damage authority into effects.
- Recorded the provisional compact-game progression direction: roughly ten levels, XP and coins, an authored skill menu, and three recommended active skill slots rather than random run-based choices.
- Expanded every directional Spitter attack from one pose to a three-frame charge, compression, and spit sequence.
- Replaced the laser-like warning line with a pulsing red ground target marker and made seeds terminate at the committed marked position.
- Separated kiting steering from sprite facing, preventing the Spitter from turning away immediately before attacking, and corrected zero-length navigation fallback steering.

## 2026-07-13 - Grounded Sweeping Cut Ability

- Added reusable immutable `AbilityDefinition` data and instance-owned cast/cooldown runtime state.
- Added Q Sweeping Cut with a broad frontal arc, multi-target 20 damage, light pushback, vulnerable recovery, and 3-second cooldown.
- Added optional pushback metadata to the existing damage contract and reusable signal-driven enemy knockback response.
- Preserved enemy movement authority and ignored pushback movement during committed Mireling leaps.
- Added a compact lower-right Q skill slot driven only by cooldown signals.
- Reused the full-body sword attack animation while adding a separate presentation-only sweep arc.
- Added end-to-end coverage for damage, multi-target behavior, displacement, action exclusion, cooldown, and HUD feedback.
- Clarified its crowd-control role with a wider arc, more visible spacing push, shorter recovery, and 2.5-second cooldown while retaining lower single-target damage than the normal sword.
- Rebuilt the unreliable overlapping skill-panel children as a visible container-based Q/E bar with `READY`, numeric cooldown, and explicit `E LOCKED` states.

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
