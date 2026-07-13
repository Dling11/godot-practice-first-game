# Project Context

This is the compact entry point for routine work. It records current runtime truth and routes deeper reading without duplicating full design history.

## Current Playable State

- Godot 4.7 stable, 2D top-down pixel action prototype.
- Main scene: `res://levels/test_arena/test_arena.tscn`.
- Logical viewport: 960x540 with exact 2x development scaling and pixel snapping.
- Player: smooth movement, directional sword attack, supernatural dash with invulnerability, grounded Q Sweeping Cut, health, defeat, and restart.
- Enemies: durable Forsaken Thrall melee pursuer, dodgeable Mireling snapshot leap, and telegraphed Bramble Spitter ranged pressure.
- Stage 1: three data-driven beginner waves of Mirelings and Thralls, summon effects, crowd separation, navigation around props, and portal exit.
- Stage 2: authored `Thorns of the Forgotten Grove` introduction with arrival lore, navigation, two waves, the first Bramble Spitter, and a clear-gated return portal.
- Progression: session-only level 1-10 path with XP and coins from defeated enemies; no random level-up choices, persistence, or skill setup menu yet.
- UI: compact player vitality, level/XP/coin readout, visible Q/E skill bar, contextual portal prompt, wave messages, spawn direction, and reusable damage-triggered enemy health bars.
- Audio: a cross-scene `AudioDirector` routes the CC0 forest ambient loop through a dedicated Music bus; each stage requests its own track through `StageMusic`.
- Combat feedback: accepted hits produce short-lived world-space damage numbers and pixel bursts; player-facing impacts add a restrained camera nudge without changing gameplay time.

## Current Priority

Feel-test sword/Sweeping Cut impact readability, the restrained camera nudge, red incoming-damage feedback, reward pace, HUD readability, Stage 2's arrival pacing, grove navigation, and ambient-music volume. Next, design the authored skill-information/setup menu and the first unlocks. Do not implement supernatural powers, inventory, equipment, or save data until their design decisions are approved.

## Durable Boundaries

- `HealthComponent`, hitboxes, hurtboxes, actor controllers, and encounter services own gameplay authority.
- Animation, HUD, effects, and audio observe gameplay; they do not calculate authoritative damage or state.
- Prefer composition and data-driven resources over deep inheritance.
- Environment props must align presentation, collision, navigation, depth, and occlusion.
- Use signals, timers, and state transitions instead of avoidable per-frame polling.
- Preserve the existing 24x32 humanoid, 32x32 creature, and 64x48 six-frame humanoid action-art conventions.

## Read Next by Task

- Player-facing rules, lore, enemies, weapons, or abilities: `GAME_DESIGN.md`
- System ownership, data flow, scenes, or dependencies: `ARCHITECTURE.md`
- Naming, GDScript, scene, signal, and pixel-art conventions: `STYLE_GUIDE.md`
- Active priorities and debt: `ROADMAP.md`
- Confirmed limitations: `KNOWN_ISSUES.md`
- Relevant durable choice: `DECISIONS.md`, then the linked ADR text
- Previous completed changes: current `CHANGELOG.md` section first; older entries only when investigating history
