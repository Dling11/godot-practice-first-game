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
- Cross-scene ambient-music foundation with a dedicated Music bus, stage routing, attribution, and headless-safe regression coverage.
- Reusable combat-impact feedback: accepted-hit damage numbers, pixel bursts, restrained camera nudges, and automatic cleanup.
- Event-driven combat SFX for sword, Sweeping Cut, dash, player damage, current enemy attacks, and Bramble projectile impacts, with Music/SFX/UI bus separation.
- Regression coverage for player combat, enemies, crowd behavior, navigation, encounters, portals, transitions, and defeat.

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
- Feel-test Sweeping Cut wind-up, wider arc, 20 damage, spacing pushback, recovery risk, 2.5-second cooldown, arc readability, and two-slot HUD placement.
- Feel-test Stage 2 arrival pacing, grove layout/navigation, Wave 1 warm-up, Wave 2 Spitter readability, clear-gated return portal, and restart behavior.
- Feel-test XP/coin pacing, HUD placement, and the forest ambient-music volume.
- Feel-test normal sword, Sweeping Cut, and incoming-damage feedback for readability and appropriate camera motion.
- Feel-test combat cue selection, positional balance, repetition, and SFX-versus-music volume.
- Design authored skill unlock rules, coin sinks, the three-versus-four active skill budget, and a skill-information/setup menu.

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
