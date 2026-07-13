# Decisions Index

Architecture decisions are stored as durable ADR history. Read this compact index first, then open only the decision relevant to the current task.

The complete text of Decisions 001-025 is preserved in [`docs/decisions/001-025-archive.md`](docs/decisions/001-025-archive.md).

## Active Decision Map

| ID | Decision | Read when working on |
|---|---|---|
| 001 | Repository documentation is persistent project memory | Documentation workflow or project handoff |
| 002 | Prefer composition and data-driven content | New gameplay systems, resources, or actor capabilities |
| 003 | Preserve authority boundaries without premature networking | Gameplay authority, state ownership, or multiplayer readiness |
| 004 | Optimize from budgets and profiles | Performance, pooling, or large enemy counts |
| 005 | Pin the prototype to Godot 4.7 stable | Engine upgrades or compatibility |
| 006 | Use a pixel-oriented viewport baseline | Resolution, cameras, scaling, or pixel stability |
| 007 | Separate player intent from movement authority | Input, movement, control sources, or replay/network boundaries |
| 008 | Treat environment art as layered gameplay assets | Props, collision, navigation, depth, and occlusion |
| 009 | Establish combat with a data-driven plain sword | Weapons, attack phases, hitboxes, or damage data |
| 010 | Present the reusable evade as a supernatural dash | Dodge behavior, invulnerability, or mobility |
| 011 | Begin enemy combat with an open-arena Forsaken Thrall | Enemy state machines, pursuit, or melee behavior |
| 012 | Keep defeat authority outside the HUD | Death, restart, HUD ownership, or game flow |
| 013 | Validate environment assets and navigation together | Tilemaps, props, navigation baking, or path tests |
| 014 | Favor a wider, simpler, brighter gameplay presentation | Viewport, palette, visual density, or HUD scale |
| 015 | Enforce strict 24x32 sprite cells and integrated weapon poses | Character sprite production and import rules |
| 016 | Preserve body scale and separate the hand-anchored swing | Attack sprite alignment, shadows, or collision placement |
| 017 | Author full-body six-frame sword attacks | Player attack animation and phase mapping |
| 018 | Polish enemy arrival, footprint navigation, and combat-space presentation | Spawning, navigation footprints, or combat readability |
| 019 | Author the Thrall claw scratch as full-body directional animation | Thrall animation and attack telegraphs |
| 020 | Turn the proving ground into a small staged playable level | Map layout, waves, camera, and encounter structure |
| 021 | Make enemy pressure dodgeable and obstacle-correct | Mireling leaps, Thrall pursuit, and obstacle behavior |
| 022 | Define waves within a stage and exit through a portal | Wave lifecycle, stage completion, or portals |
| 023 | Use local proximity separation for prototype crowds | Enemy crowd spacing and movement blending |
| 024 | Announce spawns with a reusable summon effect | Spawn presentation and effects ownership |
| 025 | Make portals explicit reusable scene boundaries | Portal interaction and scene transitions |
| 026 | Begin with a grounded weapon skill | Ability framework, early-game power, or Sweeping Cut |
| 027 | Introduce ranged pressure through committed projectiles | Ranged enemies, projectile authority, or early enemy balance |
| 028 | Teach ranged pressure in an authored second stage | Stage pacing, enemy introduction, or stage-owned encounters |
| 029 | Use a session-only authored level-10 progression foundation | XP, coins, levels, skill unlocks, or save design |
| 030 | Keep combat impact feedback presentation-only and time-scale-free | Damage numbers, screen shake, hit stop, or effects |
| 031 | Drive positional combat SFX from authoritative events | Audio buses, player/enemy cues, or combat sound ownership |
| 032 | Use four numbered skills and a narrow in-memory run session | Skill controls, character menu, portal progression, or run reset |
| 033 | Give assets canonical identities and replaceable presentation contracts | Art generation, asset naming, folders, UI themes, or backgrounds |
| 034 | Use one shared theme and semantic UI icons | HUD/menu styling, interaction prompts, icon replacement, or new UI screens |
| 035 | Make the title screen the explicit journey entry | Main scene, menu navigation, new journeys, settings, or title backgrounds |
| 036 | Use Sanctuary as the expedition hub | Hub flow, NPCs, destination choice, route unlocks, or stage return behavior |
| 037 | Generate and normalize a dedicated Sanctuary art kit | Sanctuary tiles, generated props, NPC presentation, hub collisions, or visual replacement |

## New Decisions

Record future decisions as individual files under `docs/decisions/` using `NNN-short-title.md`, then add one row to this index. New ADRs should contain status, context, alternatives, decision, and consequences.
