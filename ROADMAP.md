# Roadmap

This roadmap records status, not promises or fixed dates. Move items only when their acceptance criteria are satisfied.

## Completed

- Documentation, Godot 4.7 project foundation, pixel-stable viewport, and automated smoke-test workflow.
- Composed player movement, aiming, sword combat, supernatural dash, health, defeat, and restart flow.
- Data-driven Thrall, Mireling, and Bramble Spitter enemies with readable attacks, navigation, obstacle handling, and crowd separation.
- Bright modular terrain, layered tree/statue props, Y-sort occlusion, collision, and runtime-baked navigation.
- Expanded Stage 1 with three waves, navigation-safe spawning, summon effects, wave pacing, and direction indicators.
- Reusable portal interaction, fade transition service, Stage 2 structural placeholder, and return portal.
- Compact combat HUD plus reusable damage-triggered enemy health bars.
- Reusable ability/cooldown and knockback contracts with the grounded Q Sweeping Cut and compact HUD slot.
- Authored Stage 2 `Thorns of the Forgotten Grove`, including arrival lore, navigation, two introductory waves, delayed Bramble Spitter reveal, and clear-gated return portal.
- Session-only level-10 progression foundation: reusable XP/coin rewards, visible HUD progress, and data-driven enemy reward values without random upgrade interruptions.
- In-memory run continuity across portal transitions, defeat-reset semantics, a centered four-slot 1-4 skill bar, and a paused Tab character/skill information menu for The Awakened.
- Cross-scene ambient-music foundation with a dedicated Music bus, stage routing, attribution, and headless-safe regression coverage.
- Reusable combat-impact feedback: accepted-hit damage numbers, pixel bursts, restrained camera nudges, and automatic cleanup.
- Event-driven combat SFX for sword, Sweeping Cut, dash, player damage, current enemy attacks, and Bramble projectile impacts, with Music/SFX/UI bus separation.
- Regression coverage for player combat, enemies, crowd behavior, navigation, encounters, portals, transitions, and defeat.
- Visual asset foundation: documented art direction, canonical asset catalog, naming/lifecycle rules, and replaceable-background contract.
- Controlled Awakened asset migration: canonical runtime names/folder plus preserved Godot-ignored source and intermediate art.
- Controlled Forsaken Thrall asset migration: canonical enemy runtime names/folder plus preserved source and intermediate art.
- Controlled Mireling asset migration: canonical 32x32 runtime art, preserved generation material, and archived superseded 24x24 sheet.
- Completed current character-art migration with canonical Bramble Spitter runtime art and preserved generation material.
- Added the reusable Godot base theme, nine named hard-pixel UI icons, themed HUD/menu presentation, and icon-bearing contextual portal prompt.
- Added the layered Battle of Gods title screen, deterministic replaceable forest/Sanctuary background, focus-safe navigation, functional session-audio settings, and fade-driven new-journey entry.
- Rebuilt the playable Sanctuary around a generated-and-normalized eleven-asset runtime kit, dedicated grass/pavement tiles, a depth-correct split angel portal, separate fountain, Skillkeeper Eira, Armskeeper Orren, expedition selection, title arrival, and Stage 2 return flow.
- Corrected Sanctuary crop integrity through full NPC limb/held-prop silhouettes and neighbor-fragment isolation, connected side-building pavement, replaced the solid portal blocker with bilateral fountain routes and a walk-in doorway threshold, added mouse/Escape modal controls, and made ambient music pause-safe and continuously looping.
- Added reusable context-gated editor preview ground to isolated Sanctuary props and NPCs without affecting composed maps or runtime presentation.
- Converted Sanctuary house footprints from fixed rectangle resources to independently editable collision polygons while preserving their validated blocking bounds.
- Replaced the combined Sanctuary portal/fountain crop with independent runtime landmarks, a physically verified walk-around-to-staircase route, a complete standalone Orren sprite, and reusable collision-safe NPC breathing.
- Removed the superseded first-round code-drawn Sanctuary scenes, sprites, imports, and obsolete generator after confirming the generated runtime kit owns every active reference.

Detailed completion history remains in `CHANGELOG.md`.

## In Progress

- Decide the first playable structure, player fantasy, and release platform priorities.
- Feel-test and tune the plain sword's timing, reach, and presentation.
- Feel-test dash distance, duration, recovery, and afterimage readability.
- Feel-test the Forsaken Thrall's spawn readability, obstacle approach, claw telegraph, range, damage, and recovery.
- Feel-test vitality readability, defeat delay, and restart controls.
- Feel-test the 960x540 zoom, smaller HUD, stable sprite scale, six-frame directional sword attacks, corrected shadows/collision, canopy occlusion, and 16-pixel Thrall clearance.
- Expand the approved two-frame prototype movement into production-quality animation timing only after the visual language is accepted.
- Feel-test Mireling pressure, stage counts, spawn pacing, camera travel, and landmark layout.
- Feel-test Sweeping Cut wind-up, wider arc, 20 damage, spacing pushback, recovery risk, 2.5-second cooldown, arc readability, and centered slot-1 HUD placement.
- Feel-test Stage 2 arrival pacing, grove layout/navigation, Wave 1 warm-up, Wave 2 Spitter readability, clear-gated return portal, and restart behavior.
- Feel-test XP/coin pacing, HUD placement, and the forest ambient-music volume.
- Feel-test normal sword, Sweeping Cut, and incoming-damage feedback for readability and appropriate camera motion.
- Feel-test combat cue selection, positional balance, repetition, and SFX-versus-music volume.
- Feel-test the centered four-slot skill bar and Tab character-menu readability at the 960x540 viewport.
- Design authored skill unlock rules, coin sinks, and the first abilities for sealed slots 2-4.
- Feel-test the shared theme, named HUD icons, expanded skill-bar height, and portal-prompt placement at 960x540.
- Feel-test the title-screen composition, restrained background motion, focus loop, audio toggles, and title-to-Stage-1 fade.
- Feel-test Sanctuary navigation, dedicated pavement, separate fountain/portal scale and courtyard spacing, portal/water/NPC/building idle effects, both NPC interactions, expedition usability, and the transition loop on F5.
- Design authored expedition definitions and profile/story unlock authority without making level the only gate.
- Design a confirmed `Abandon Expedition / Return to Sanctuary` pause-menu action, including combat restrictions and explicit XP/coin/run consequences.

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
