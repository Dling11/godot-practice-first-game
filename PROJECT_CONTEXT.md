# Project Context

This is the compact entry point for routine work. It records current runtime truth and routes deeper reading without duplicating full design history.

## Current Playable State

- Godot 4.7 stable, 2D top-down pixel action prototype.
- Main scene: `res://levels/test_arena/test_arena.tscn`.
- Logical viewport: 960x540 with exact 2x development scaling and pixel snapping.
- Player: smooth movement, directional sword attack, supernatural dash with invulnerability, health, defeat, and restart.
- Enemies: Forsaken Thrall melee pursuer and dodgeable Mireling snapshot leap.
- Stage 1: three data-driven waves, summon effects, crowd separation, navigation around props, and portal exit.
- Stage 2: structural placeholder with return portal; no authored encounter or story yet.
- UI: compact player vitality, contextual portal prompt, wave messages, spawn direction, and reusable damage-triggered enemy health bars.

## Current Priority

Build the reusable player ability framework and the first Q ability, then add its compact HUD slot. Do not implement progression, inventory, economy, or save data until their design decisions are approved.

## Durable Boundaries

- `HealthComponent`, hitboxes, hurtboxes, actor controllers, and encounter services own gameplay authority.
- Animation, HUD, effects, and audio observe gameplay; they do not calculate authoritative damage or state.
- Prefer composition and data-driven resources over deep inheritance.
- Environment props must align presentation, collision, navigation, depth, and occlusion.
- Use signals, timers, and state transitions instead of avoidable per-frame polling.
- Preserve the existing 24x32 locomotion and 64x48 six-frame action-art conventions.

## Read Next by Task

- Player-facing rules, lore, enemies, weapons, or abilities: `GAME_DESIGN.md`
- System ownership, data flow, scenes, or dependencies: `ARCHITECTURE.md`
- Naming, GDScript, scene, signal, and pixel-art conventions: `STYLE_GUIDE.md`
- Active priorities and debt: `ROADMAP.md`
- Confirmed limitations: `KNOWN_ISSUES.md`
- Relevant durable choice: `DECISIONS.md`, then the linked ADR text
- Previous completed changes: current `CHANGELOG.md` section first; older entries only when investigating history
