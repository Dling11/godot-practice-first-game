# Project Context

This is the compact entry point for routine work. It records current runtime truth and routes deeper reading without duplicating full design history.

## Current Playable State

- Godot 4.7 stable, 2D top-down pixel action prototype.
- Main scene: `res://ui/screens/title/title_screen.tscn`; Begin the Awakening resets the run and fades into Sanctuary.
- Logical viewport: 960x540 with exact 2x development scaling and pixel snapping.
- Player: Alden, a mortal wayfarer and Novice Warrior, uses action-owned four-direction sheets with one stable 18x27 upright body scale plus a grip-anchored Ashwood Blade. Serious pure-black eyes, a rust scarf, four-frame walking, three-pose weaponless attack and dash bodies, interaction, hurt, four-stage defeat, visible swing trail, smooth movement, directional melee, supernatural dash with invulnerability, grounded slot-1 Sweeping Cut, health, and restart are implemented.
- Enemies: durable Forsaken Thrall melee pursuer, dodgeable Mireling snapshot leap, and telegraphed Bramble Spitter ranged pressure.
- Stage 1: three data-driven beginner waves of Mirelings and Thralls, summon effects, crowd separation, navigation around props, and portal exit.
- Stage 2: authored `Thorns of the Forgotten Grove` introduction with arrival lore, navigation, two waves, the first Bramble Spitter, and a clear-gated return portal.
- Sanctuary: safe 18x12 expedition hub with connected side-building paths, a standalone walk-around divine fountain, a visibly separated angel portal with an open staircase and front interaction threshold, generated buildings/trees, pixel-stepped NPC idles, intact full-body Skillkeeper Eira and Armskeeper Orren sprites, and Stage 1 expedition selection with sealed future-route previews.
- Progression: in-memory level 1-10 run path with XP and coins from defeated enemies; state survives portal transitions and resets on defeat restart, but is not saved to disk.
- UI: layered title screen with mouse plus keyboard/gamepad focus and session-audio settings, plus the shared dark-fantasy theme and named pixel icons across combat HUD, character menu, contextual portal prompt, wave messages, and enemy health bars. Tab or the visible HUD satchel button opens a polished Gear/Armory surface with animated Alden and his Ashwood Blade, five eventual equipment slots, one honest Wood starter item, and an Active Skills page. The HUD and character menu build their four skill slots from one reusable loadout definition. Gameplay modals expose pointer controls, directional/Enter navigation, and Escape cancellation.
- Audio: `AudioDirector` owns Music, SFX, and reserved UI buses. Its music player continues through paused dialogue/menus and normalizes the active OGG to loop. Stages request the CC0 forest track, while player actions, accepted hits, enemy attacks, and Bramble impacts use event-driven CC0 combat sounds.
- Combat feedback: accepted hits produce short-lived world-space damage numbers and pixel bursts; player-facing impacts add a restrained camera nudge without changing gameplay time.

## Current Priority

Feel-test Alden's new action-owned walk, attack-body, dash, interaction, hurt, and defeat timing in all four directions; confirm pure-black eye/scarf readability, fixed body scale, Ashwood grip/swing alignment, and the character-menu preview at 960x540. Also feel-test the title-to-Sanctuary flow, Eira handoff, Orren preview dialogue, portal menu, Stage 2 return, combat feedback, reward pace, and music balance. Next, define authored expedition unlock data and the first persistent story-completion boundary. The armory is explicitly a read-only design preview: do not enable item ownership, equip commands, combat modifiers, purchases, drops, coin sinks, or disk saving until persistence, economy, stat, and death rules are approved. NPC modularization and broader environment/UI restyling remain later migrations, not part of the current player pass.

## Durable Boundaries

- `HealthComponent`, hitboxes, hurtboxes, actor controllers, and encounter services own gameplay authority.
- Animation, HUD, effects, and audio observe gameplay; they do not calculate authoritative damage or state.
- Prefer composition and data-driven resources over deep inheritance.
- Environment props must align presentation, collision, navigation, depth, and occlusion.
- Use signals, timers, and state transitions instead of avoidable per-frame polling.
- Preserve Alden's stable 18x27 upright scale and 32-pixel foot-baseline contract across action-owned sheets. Wider 48x32 action and 64x32 defeat cells provide pose room without resizing the body. Preserve the existing 24x32 enemy-humanoid and 32x32 creature contracts and legacy 64x48 enemy action-art conventions. Visible player weapons remain separate presentation sprites; gameplay hitboxes remain authoritative.

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
