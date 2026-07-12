# Roadmap

This roadmap records status, not promises or fixed dates. Move items only when their acceptance criteria are satisfied.

## Completed

- Established the documentation-based project memory and agent workflow.
- Recorded the initial game vision, architecture direction, conventions, risks, and decisions.
- Pinned Godot 4.7 stable for the initial prototype.
- Bootstrapped a runnable project with pixel-oriented rendering defaults.
- Added the input map, named collision layers, and combat proving-ground scene hierarchy.
- Initialized local Git version control and Godot-aware ignore rules.
- Implemented reusable player movement with acceleration, deceleration, diagonal speed limiting, and arena bounds.
- Implemented mouse/right-stick facing through a replaceable input-source boundary.
- Added a signal-driven placeholder aim presentation and headless movement smoke test.
- Implemented the data-driven plain-sword attack with wind-up, active, and recovery phases.
- Added reusable hitbox, hurtbox, damage-message, and health contracts.
- Added a resettable training target and deterministic melee combat smoke test.
- Implemented a data-driven supernatural dash with locked direction, invulnerability, recovery, and afterimages.
- Added player health/hurtbox state and deterministic evade integration tests.
- Implemented the Forsaken Thrall with data-driven stats, direct pursuit, telegraphed melee phases, damage, and death.
- Added an enemy encounter integration test covering incoming damage, sword damage, and death state.
- Implemented player vitality HUD, damage/immunity feedback, defeated state, and arena restart flow.
- Added deterministic defeat-flow integration coverage.
- Added real prototype pixel-art ground, tree, canopy, and statue raster assets.
- Added reusable layered prop scenes with collision, shadows, Y-sorting, occlusion data, and navigation cutouts.
- Added a modular prototype TileSet/TileMapLayer pipeline and runtime-baked arena navigation.
- Upgraded the Forsaken Thrall from direct steering to scheduled NavigationAgent2D pathfinding.
- Added deterministic environment and path-routing integration coverage.
- Added a non-hostile Thrall materialization sequence, footprint-matched navigation tolerances, and a recoil/lunge claw swipe.
- Replaced the tree and statue presentation with limited-palette layered props and added event-driven canopy sway.
- Reduced the vitality HUD and removed persistent control/build overlays from combat space.
- Converted the editor-authored multi-shape tree coverage into one seam-free convex physics/navigation footprint.
- Replaced the Thrall's temporary reach/lunge with a 24-cell directional six-frame claw-scratch sheet and gameplay-aligned phase playback.
- Expanded the playable ground from 15x9 to 30x18 cells and added a pixel-stable following camera.
- Replaced checker-like ground ordering with deterministic weighted variation and arranged trees/statues as landmarks and combat lanes.
- Removed the training target from normal play while retaining its reusable scene and combat tests.
- Added three data-driven waves within Stage 1, transient wave UI, lifecycle-based progression, and a stage-clear portal with a future scene-transition boundary.
- Fixed the Thrall's statue-opposite deadlock by advancing NavigationAgent2D every chase frame and using corridor-funnel postprocessing.
- Added reusable local-neighbor separation for Thralls and Mirelings without player blocking or attack-phase drift.
- Added a mixed four-enemy crowd regression proving 20.19 pixels of observed minimum spacing while advancing.
- Added reusable violet summon runes, inward sparks, and restrained lightning for every encounter spawn.
- Added wave-clear announcements and a 2.25-second recovery window between waves.
- Added contextual F-to-enter portal prompts that disappear on proximity exit.
- Added the reusable paused fade/loading `SceneTransition` autoload.
- Added a minimal Stage 2 destination with authored spawn, camera bounds, reused HUD, landmarks, and return portal.
- Added reusable signal-driven enemy health bars for Thralls and Mirelings, hidden until damage and automatically cleared after combat inactivity or death.
- Added the weak Mireling enemy with directional idle, hop, body-slam, and defeated sprites plus combat coverage.
- Enlarged the Mireling to 32x32 cells and replaced contact-like attacks with telegraphed snapshot leaps, landing-only damage, and long recovery.
- Corrected Thrall back-walking, prop line-of-sight attacks, player pinning, and statue physics/navigation mismatch.
- Moved spawning to a closer navigation-safe ring and added transient edge-direction indicators.
- Revised the prototype to a 960x540 logical viewport at exact 2x display scale.
- Replaced dark detailed terrain/props with a simpler bright grass, green tree, and mossy shrine set.
- Replaced player and Thrall body polygons with strict 24x32, four-direction SpriteFrames.
- Corrected tree depth by separating ground roots from Y-sorted canopy occlusion.
- Tightened tree routing to a measured 16-pixel center clearance and added a regression guard.

## In Progress

- Decide the first playable structure, player fantasy, and release platform priorities.
- Feel-test and tune the plain sword's timing, reach, and presentation.
- Feel-test dash distance, duration, recovery, and afterimage readability.
- Feel-test the Forsaken Thrall's spawn readability, obstacle approach, claw telegraph, range, damage, and recovery.
- Feel-test vitality readability, defeat delay, and restart controls.
- Feel-test the 960x540 zoom, smaller HUD, stable sprite scale, six-frame directional sword attacks, corrected shadows/collision, canopy occlusion, and 16-pixel Thrall clearance.
- Expand the approved two-frame prototype movement into production-quality animation timing only after the visual language is accepted.
- Feel-test Mireling pressure, stage counts, spawn pacing, camera travel, and landmark layout.
- Design the next enemy role, recommended as ranged positioning pressure.
- Design the second enemy role, recommended as ranged positioning pressure.

## Planned

### Phase 0 - Foundation

- Review release target priorities; desktop is the current development baseline.
- Validate the 640x360 pixel rendering and camera policy with the first animated character.
- Extend the validated prototype into terrain-transition and editor-authored map conventions before producing final environment assets.
- Decide initial game/run structure and player fantasy.
- Select automated test tooling when the first testable domain component is introduced.

### Phase 1 - Combat Prototype

- Reusable health, hitbox, hurtbox, and damage components.
- Combat feel pass and baseline performance measurements.

### Phase 2 - Vertical Slice

- One polished playable region/arena.
- A small but distinct weapon set.
- Divine and demonic abilities demonstrating build choice.
- Multiple complementary enemy roles.
- One multi-phase boss.
- Audio, effects, accessibility settings, menus, and save/checkpoint flow needed for the slice.

### Phase 3 - Production Systems

- Scalable content authoring for weapons, abilities, enemies, bosses, and status effects.
- Character progression, inventory, and equipment after design approval.
- Exploration, NPC, and quest foundations if required by the approved game structure.
- Save schema versioning and migration.
- Broader performance budgets and profiling scenes.

### Phase 4 - Content and Polish

- Additional regions, enemies, bosses, weapons, skills, and narrative content.
- Balance, onboarding, accessibility, localization readiness, and controller polish.
- Export validation, compatibility testing, optimization, and release preparation.

## Future Ideas

- Multiplayer expansion
- Challenge modes and difficulty modifiers
- Branching routes or alternate realms
- Additional playable characters
- Community or mod-friendly data pipelines

## Technical Debt

None currently recorded.

## Next Decision Gate

Before creating gameplay code, approve:

1. Desktop/web/mobile release priorities.
2. First playable scope: arena survival, authored action-adventure slice, or another structure.
3. Player identity/fantasy for the prototype.
4. Initial weapon/attack fantasy for the prototype.
