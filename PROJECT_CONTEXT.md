# Project Context

This is the compact entry point for routine work. It records current runtime truth and routes deeper reading without duplicating full design history.

## Current Playable State

- Godot 4.7 stable, 2D top-down pixel action prototype.
- Main scene: `res://ui/screens/title/title_screen.tscn`; Begin the Awakening resets the run and fades into Sanctuary.
- Logical viewport: 960x540 with exact 2x development scaling and pixel snapping.
- Player: Opaw, a mortal wayfarer and Novice Warrior, now uses an active compact armless four-direction model with an oversized boxy head, narrow tunic, tiny boots, serious pure-black eyes, rust scarf, and a detached equippable sword. Seven action-owned sheets preserve one 18x27 upright scale across four-frame walking, three-frame dash, three-pose weaponless attack, interaction, hurt, and four-stage defeat. Whole-body lean and scarf momentum support a data-driven three-swing Balanced Slash sequence—outward slash, reverse return, extended visual finish—with a bright strike trail; Ashwood Blade and Iron Sword reuse it without duplicating Opaw's body animation. Smooth movement, directional melee, supernatural dash with invulnerability, grounded slot-1 Sweeping Cut, health, and restart remain implemented. The complete previous Wayfarer model is archived as an independently loadable backup, while the older sleeve-ended and attack-only prototypes remain review material.
- Enemies: durable Forsaken Thrall melee pursuer, dodgeable Mireling snapshot leap, and telegraphed Bramble Spitter ranged pressure.
- Stage 1: three data-driven beginner waves of Mirelings and Thralls, summon effects, crowd separation, navigation around props, and portal exit.
- Stage 2: authored `Thorns of the Forgotten Grove` introduction with arrival lore, navigation, two waves, the first Bramble Spitter, and a clear-gated return portal.
- Sanctuary: safe 18x12 expedition hub with a centered two-cell portal/fountain avenue, exact door-aligned service approaches, a compact cart bay, preserved garden breaks, a standalone walk-around divine fountain, a visibly separated angel portal with an open staircase and front interaction threshold, generated buildings/trees, compact Opaw-scale Skillkeeper Eira and Armskeeper Orren sprites, a complete skill lodge, arms workshop and body-free weapon cart, pixel-stepped NPC idles, and a data-driven expedition menu that explains combined level/story/boss/discovery/key-item requirements while unbuilt routes remain sealed.
- Story: Opaw was killed in a former world and awakened through the Remembered Veil as the first weak Warrior in a planned switchable roster. Most known gods treat mortal struggle as trials, wagers, or entertainment; The One Above remains a greater unresolved mystery. `StoryState` now retains versioned in-memory story flags, boss victories, discoveries, and narrative key items across scenes, while `STORY_BIBLE.md` preserves canon and planned escalation from mortal threats through gods, beyond-god, boundless, and provisional author-class danger.
- Progression: in-memory level 1-10 run path with XP and coins from defeated enemies; run currency survives portal transitions and resets on defeat restart, but is not saved to disk. `WeaponInventory` separately retains owned/equipped weapons across scene and defeat replacement for the current journey, resets on Begin the Awakening, and has no disk persistence.
- UI: layered title screen with mouse plus keyboard/gamepad focus and session-audio settings, plus the shared dark-fantasy theme and named pixel icons across combat HUD, character menu, contextual portal prompt, wave messages, and enemy health bars. Tab or the visible HUD satchel button opens a polished Gear/Armory surface with animated Opaw, five eventual equipment slots, owned Ashwood/Iron weapons, click-to-equip behavior, and an Active Skills page. Orren's paused shop spends real run coins and adds Iron to inventory without auto-equipping it. The HUD and character menu build their four skill slots from one reusable loadout definition. Gameplay modals expose pointer controls, directional/Enter navigation, and Escape cancellation.
- Audio: `AudioDirector` owns Music, SFX, and reserved UI buses. Its music player continues through paused dialogue/menus and normalizes the active OGG to loop. Stages request the CC0 forest track, while player actions, accepted hits, enemy attacks, and Bramble impacts use event-driven CC0 combat sounds.
- Combat feedback: accepted outgoing hits produce a reusable 0.10-second white enemy flash, white-hot burst core, and non-stacking 0.045-second hitstop alongside world-space damage numbers, pixel sparks, sound, and a restrained camera nudge. The Ashwood Blade applies light knockback; Sweeping Cut remains the stronger spacing tool. Incoming player hits retain numbers, bursts, sound, and camera response without hitstop.
- Active design discussion: `docs/design/opaw-combat-controls-and-skills-proposal.md` records the requested move from passive mouse-facing to movement-facing combat, right-click basic attack, clickable/ground-targetable skills, weapon-damage multipliers, a proposed thrust-focused Warrior kit, debug max-level/coin testing, and asset/audio organization. It is a proposal, not implemented runtime truth.

## Current Priority

Feel-test Opaw's compact armless walk, attack-body, dash, interaction, hurt, and defeat timing in all four directions; confirm pure-black eye/scarf readability, tiny-foot grounding, fixed body scale, both sword silhouettes, Orren's 18-coin purchase flow, and character-inventory swapping at 960x540. Next, implement Eira's free level-gated skill-awakening ritual without turning skills into shop items, decide the first disk-persistent profile boundary, and author the Thornbound Warden/Cinder Sigil content needed before Ashen Pilgrimage can honestly open. Character switching, Mage/Archer kits, skills 2-4 content, drops, and god-tier content remain staged future work rather than partially implemented promises.

## Durable Boundaries

- `HealthComponent`, hitboxes, hurtboxes, actor controllers, and encounter services own gameplay authority.
- Animation, HUD, effects, and audio observe gameplay; they do not calculate authoritative damage or state.
- Prefer composition and data-driven resources over deep inheritance.
- Environment props must align presentation, collision, navigation, depth, and occlusion.
- Use signals, timers, and state transitions instead of avoidable per-frame polling.
- Preserve Opaw's stable 18x27 upright scale and 32-pixel foot-baseline contract across action-owned sheets. Wider 48x32 action and 64x32 defeat cells provide pose room without resizing the body. Preserve the existing 24x32 enemy-humanoid and 32x32 creature contracts and legacy 64x48 enemy action-art conventions. Visible player weapons remain separate presentation sprites; gameplay hitboxes remain authoritative.

## Read Next by Task

- Player-facing rules, lore, enemies, weapons, or abilities: `GAME_DESIGN.md`
- Canonical story premise, character-roster direction, arcs, power escalation, and open lore questions: `STORY_BIBLE.md`
- Current provisional Opaw control/skill redesign: `docs/design/opaw-combat-controls-and-skills-proposal.md`
- System ownership, data flow, scenes, or dependencies: `ARCHITECTURE.md`
- Naming, GDScript, scene, signal, and pixel-art conventions: `STYLE_GUIDE.md`
- Visual theme, palette, pixel baselines, and replacement rules: `ART_DIRECTION.md`
- Canonical asset IDs, current paths, planned paths, and lifecycle status: `ASSET_CATALOG.md`
- Active priorities and debt: `ROADMAP.md`
- Confirmed limitations: `KNOWN_ISSUES.md`
- Relevant durable choice: `DECISIONS.md`, then the linked ADR text
- Previous completed changes: current `CHANGELOG.md` section first; older entries only when investigating history
