# Project Context

This is the compact entry point for routine work. It records current runtime truth and routes deeper reading without duplicating full design history.

## Current Playable State

- Godot 4.7 stable, 2D top-down pixel action prototype.
- Main scene: `res://ui/screens/title/title_screen.tscn`; Begin the Awakening resets the run and fades into Sanctuary.
- Logical viewport: 960x540 with exact 2x development scaling and pixel snapping.
- Player: smooth movement, directional sword attack, supernatural dash with invulnerability, grounded slot-1 Sweeping Cut, health, defeat, and restart.
- Enemies: durable Forsaken Thrall melee pursuer, dodgeable Mireling snapshot leap, and telegraphed Bramble Spitter ranged pressure.
- Stage 1: three data-driven beginner waves of Mirelings and Thralls, summon effects, crowd separation, navigation around props, and portal exit.
- Stage 2: authored `Thorns of the Forgotten Grove` introduction with arrival lore, navigation, two waves, the first Bramble Spitter, and a clear-gated return portal.
- Sanctuary: safe 18x12 expedition hub with connected side-building paths, bilateral fountain walkways into a physically enterable angel-portal threshold, generated buildings/trees/NPCs with corrected crop integrity, Skillkeeper Eira, Armskeeper Orren, and Stage 1 expedition selection with sealed future-route previews.
- Progression: in-memory level 1-10 run path with XP and coins from defeated enemies; state survives portal transitions and resets on defeat restart, but is not saved to disk.
- UI: layered title screen with keyboard/gamepad focus and session-audio settings, plus the shared dark-fantasy theme and named pixel icons across combat HUD, character menu, contextual portal prompt, wave messages, and enemy health bars. Gameplay modals expose mouse controls and close with Escape; Tab opens the character menu.
- Audio: `AudioDirector` owns Music, SFX, and reserved UI buses. Its music player continues through paused dialogue/menus and normalizes the active OGG to loop. Stages request the CC0 forest track, while player actions, accepted hits, enemy attacks, and Bramble impacts use event-driven CC0 combat sounds.
- Combat feedback: accepted hits produce short-lived world-space damage numbers and pixel bursts; player-facing impacts add a restrained camera nudge without changing gameplay time.

## Current Priority

Feel-test the title-to-Sanctuary flow, generated landmark/building/NPC scale, pavement layout, idle readability, Eira skill-information handoff, Orren preview dialogue, portal menu, Stage 2 return, combat feedback, reward pace, and music balance. Next, define authored expedition unlock data and the first persistent story-completion boundary before enabling purchases or equipment. Do not implement supernatural powers, inventory, equipment, coin sinks, or disk save data until their design decisions are approved.

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
- Visual theme, palette, pixel baselines, and replacement rules: `ART_DIRECTION.md`
- Canonical asset IDs, current paths, planned paths, and lifecycle status: `ASSET_CATALOG.md`
- Active priorities and debt: `ROADMAP.md`
- Confirmed limitations: `KNOWN_ISSUES.md`
- Relevant durable choice: `DECISIONS.md`, then the linked ADR text
- Previous completed changes: current `CHANGELOG.md` section first; older entries only when investigating history
