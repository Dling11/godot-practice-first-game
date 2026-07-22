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
| 017 | Author full-body six-frame sword attacks (superseded for the active player by 039) | Legacy attack art or integrated non-modular actions |
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
| 038 | Preview skill-synergy equipment before persistence | Equipment ranks, inventory UI, weapon synergies, shops, drops, or stat authority |
| 039 | Use modular mortal character presentation | Opaw, playable classes, layered equipment, visible weapons, or NPC scale migration |
| 040 | Split playable animation by action while locking body scale | Opaw animation sheets, directional scale, attack-body phases, dash, hurt, or defeat |
| 041 | Activate compact armless Opaw with an explicit visual rollback | Opaw's active silhouette, detached weapon orbit, model replacement, or art backup |
| 042 | Share body animation across data-driven sword styles and grades | Sword grades, attack presentation profiles, visible weapon swapping, or animation reuse |
| 043 | Align Sanctuary services with compact characters and archive superseded runtime material | Eira/Orren art, service buildings, asset cleanup, supported rollbacks, or archive policy |
| 044 | Use story memory for data-driven expedition access | Story flags, bosses, discoveries, key items, route requirements, lore memory, or future profile saves |
| 045 | Use a class-gated session weapon inventory | Weapon ownership, shops, equip switching, class restrictions, default weapons, or session retention |
| 046 | Buffer basic attack through dash recovery | Dash attacks, evade recovery, input buffering, cancel windows, or invulnerability overlap |
| 047 | Equip weapon-scaled Piercing Rush and preserve Sweeping Cut | Skill 1, ability movement, weapon scaling, clickable skills, spectral thrusts, or alternate techniques |
| 048 | Use an effect-only animation atlas for exaggerated Piercing Rush presentation | Piercing Rush VFX, oversized skill art, visual-versus-hitbox bounds, directional effect reuse, or sword-independent technique animation |
| 049 | Align Piercing Rush's central lance and audio with its presentation | Piercing Rush reach, first-skill balance, damage multiplier, pushback, accepted-hit audio, or CC0 sound sourcing |
| 050 | Use authored multi-strike data and a debug-only test loadout for Consecutive Thrust | Repeated hits, Skill 2, debug testing, effect-only VFX, weapon scaling, or future free awakening |
| 051 | Use data-driven crowd-control tiers for enemy resistance | Knockback, stagger, enemy interruption, elites, bosses, control immunity, or future poise |
| 052 | Extend expedition pacing within the readable four-enemy cap | Stage wave counts, mixed enemy pacing, encounter length, or crowd-performance budgets |
| 053 | Use Rootbound Husk as an authored forest melee archetype | Forest enemy art, Root Spear attack, Stage 1 roster, or future Rootbound Elder boss |
| 054 | Make Rootling the compact Stage 1 rooted melee enemy | Rootling art, locked ground-jab authority, Stage 1 wave composition, or Rootbound escalation |
| 055 | Gate authored reveals and give recurring characters reusable portraits | Pre-fight dialogue, encounter gates, character portraits, bestiary art, or expedition previews |

## New Decisions

Record future decisions as individual files under `docs/decisions/` using `NNN-short-title.md`, then add one row to this index. New ADRs should contain status, context, alternatives, decision, and consequences.
