# Game Design

## Design Status

This is the initial vision baseline. Items marked **Planned** are direction, not implemented behavior. Numeric balance values remain intentionally unspecified until a playable combat prototype exists.

## High Concept

Battle of Gods is a fast, skill-based 2D top-down pixel action game. Relentless enemies pressure the player into making deliberate movement, dodge, positioning, weapon, and ability decisions. The world is a dark-fantasy cosmology shaped by divine conflict and lost civilizations.

## Design Pillars

1. **Responsive mastery** - inputs, movement, attacks, and dodges must feel immediate and predictable.
2. **Readable danger** - enemy intent, hit areas, invulnerability, and damage feedback must be understandable despite high pressure.
3. **Meaningful builds** - weapons and powers should create distinct play styles rather than simple numerical upgrades.
4. **Ancient mystery** - lore is discovered through places, enemies, artifacts, and restrained storytelling.
5. **Replayable challenge** - encounters reward learning, positioning, and adaptation.

## Core Gameplay Loop

**Planned:**

1. Enter and explore a hostile region.
2. Fight pursuing enemies and survive escalating encounters.
3. Earn resources, weapons, powers, or progression choices.
4. Refine a build and overcome elite enemies or a multi-phase boss.
5. Unlock new paths, knowledge, and challenges.
6. Return with greater mastery or begin another run/expedition.

The exact run structure, death penalty, checkpoint rules, and permanent progression model are undecided.

## Combat

Combat must prioritize control and clarity:

- Smooth, acceleration-aware movement without unwanted input lag.
- Attacks with explicit wind-up, active, recovery, and cancel rules.
- Dodge/roll with deliberately timed invincibility frames.
- **Implemented prototype:** the player uses a short supernatural directional dash with invulnerability during movement and a non-invulnerable recovery window. The dash uses movement direction, then facing direction when stationary.
- Enemies that pursue, predict, reposition, and attack without relying only on direct beelines.
- Telegraphs that remain legible with many enemies on screen.
- Hit pause, camera response, sound, particles, and animation used selectively for impact.
- Bosses with phase changes that introduce new decisions, not merely more health.

Damage formulas, stagger, poise, stamina, mana, cooldowns, and targeting rules are not yet decided.

**Implemented prototype defeat loop:** the player's vitality is visible. At zero health, movement and combat stop, the player enters a fallen presentation, and the player may press R or the gamepad north button to reload the proving ground. The prototype has no progression loss or automatic restart.

## Player Character

The player character's identity, origin, base attributes, and relationship to The One Above are undecided.

Required capability areas:

- Locomotion
- Aiming/facing
- Weapon attacks
- Dodge/roll
- Divine and demonic abilities
- Health and damage response
- Progression and equipment
- Interaction and exploration

## World and Story

Reality was shaped by **The One Above**, an ancient primordial creator and the strongest known being. Gods, demons, and forgotten civilizations exist within the consequences of that creation.

The following remain open design questions:

- Is The One Above absent, sleeping, imprisoned, dead, or observing?
- What event placed the world in its current crisis?
- Who is the player, and why can they wield divine and demonic power?
- Are gods bosses, allies, factions, or all three?
- Is the story linear, region-based, or run-based?

Future lore should preserve mystery and avoid turning The One Above into an ordinary quest-giver or conventional villain without a recorded design decision.

## Characters and Factions

No named playable characters, NPCs, gods, demons, or factions have been approved beyond The One Above.

## Enemies and Bosses

**Planned enemy roles:** pursuer, flanker, ranged pressure, area denial, support, summoner, elite, and boss. Actual enemies should combine a small number of readable behaviors.

**Planned boss principles:**

- Multiple phases or behavioral states.
- Clear telegraphs and punish windows.
- Escalation through pattern interaction rather than unavoidable damage.
- Theme, arena, mechanics, and lore that reinforce each other.

**Implemented enemy prototype - Forsaken Thrall:** a corrupted humanoid pursuer that materializes before becoming hostile, follows obstacle paths to the player's actual footprint, and uses a six-pose directional claw scratch with anticipation, raised arm, slash, impact, follow-through, and vulnerable recovery. It has 100 prototype health and deals 15 prototype damage; values remain provisional.

No specific boss roster is approved.

**Implemented Stage 1 encounter:** three sequential waves introduce Mirelings, Thralls, then one Bramble Spitter. Wave 3 remains capped at four enemies. Clearing it opens the stage-exit portal. Entering its range shows `F - Enter Portal`; leaving removes the prompt. Interaction fades through a loading veil into a quiet Stage 2 placeholder with a reliable player spawn and return portal. Stage 2 encounters and story remain unauthored.

Every encounter spawn is announced by a short violet ground rune, inward sparks, and restrained lightning strike aligned with the enemy's non-hostile materialization. Clearing a wave provides a 2.25-second recovery window before the next wave begins.

**Mireling:** a small corrupted divine slime with 30 health and a larger 32x32 presentation. Within 105 pixels and clear line-of-sight it snapshots the player's position, shows a 0.65-second landing marker, leaps there over 0.42 seconds, deals 5 damage only on landing, then remains vulnerable for 1 second. Moving or dashing away from the snapshot avoids the hit.

**Bramble Spitter:** a weak forest-corrupted ranged creature with 40 health. It seeks a 95-190 pixel firing band, faces the player while backing away, and uses a three-frame charge/compression/spit sequence. A pulsing red ground marker snapshots the player's position for 0.75 seconds instead of presenting the attack as a laser. It then recoils while firing one bright, trailed 8-damage seed that terminates at the marked position. Seeds burst visibly on impact and the Spitter recovers for 1.25 seconds. Leaving the marker avoids the hit. It temporarily appears in Wave 3 for testing but is intended to become a Stage 2 introduction once that stage has authored encounters.

Standard enemies keep their health bars hidden at full health. Taking damage reveals a compact world-space bar for 2.2 seconds; further hits refresh that window, and death hides it immediately. This preserves exploration readability while still communicating combat progress.

## Weapons

**Planned:** data-driven weapon definitions with composable attack behaviors. Weapons should differ in reach, timing, mobility, risk, resource use, and synergy—not only damage.

**Implemented prototype:** a plain one-handed sword establishes directional melee timing through wind-up, active, and recovery phases. Its current 25 damage and timings are feel-test values, not final balance.

Future weapon families may include spears, dual swords, greatswords, axes, ranged weapons, and supernatural weapons. They should reuse combat contracts while providing genuinely different attack behavior rather than reskinning the sword.

## Skills and Powers

**Planned categories:** divine powers, demonic powers, weapon skills, mobility tools, defensive tools, and passive modifiers.

**Implemented prototype weapon skill - Sweeping Cut:** Q/left shoulder performs a broad frontal sword technique with 0.16-second wind-up, 0.12-second active window, 0.22-second recovery, 20 damage, visible spacing pushback, and a 2.5-second cooldown. Casting prevents normal attack and dash until recovery ends. It is intentionally weaker than the 25-damage focused sword attack per target and exists to create space against small groups.

The starting character has no divine or demonic ability. Supernatural powers should arrive through later story or progression so the early player remains weak and their eventual growth remains meaningful.

The relationship between divine and demonic power may involve affinity, corruption, mutual exclusivity, or build synergy. This requires an explicit design decision before implementation.

## Progression and Economy

**Provisional introductory-game direction:** this project is intended to demonstrate a small authored progression arc rather than an endless run-based or advertisement-style upgrade loop. The first playable character may have approximately ten levels, a simple XP bar, coins, and a deliberately small authored skill set. Exact values remain open until the Stage 1-to-Stage 2 loop is playable.

Recommended current control budget is three equipable active skills in addition to normal attack and dash. Skills should have stable names, icons, descriptions, unlock requirements, and coin costs or upgrades. A pause/menu skill panel should let the player inspect and configure them outside immediate combat. Leveling should unlock authored options or requirements rather than interrupting every level with three random choices.

Open decisions include whether the final cap is exactly level 10, whether the character owns three or four active skills, how coins are earned and spent, whether skills are unlocked by level or purchased after reaching a level, and what progression persists after defeat.

Progression must preserve skill-based combat. Numerical growth should not erase the need to dodge, read attacks, and position well.

## Exploration

Exploration should reveal lore, resources, optional challenges, shortcuts, secrets, and alternative encounters. Map topology and procedural-versus-authored content are undecided.

## Visual and Environment Direction

The world uses simple, clean retro pixel art with strong silhouettes, limited palettes, and consistent pixel density. Gameplay readability takes priority over decorative detail or realism.

Environment art is part of gameplay design. Trees, bushes, rocks, buildings, walls, statues, and other large props should clarify navigation and combat space while supporting collision, cover/occlusion, interaction, or navigation behavior where appropriate.

Large props must communicate depth correctly. A player walking behind a tree canopy may become partially or fully obscured while remaining visually in front of the lower trunk when spatially appropriate. Shadows, foreground pieces, and occluding pieces should reinforce spatial relationships without hiding hazards unfairly.

Tile-based environments should support reusable terrain transitions, ground variation, decorative overlays, collision, and navigation instead of being authored for only one location.

**Implemented prototype revision:** four bright grass variants, a layered limited-palette ancient tree, and a broken forgotten-god shrine establish a simple colorful fantasy palette. The tree canopy uses subtle intermittent sway. The player and Forsaken Thrall use strict 24x32 directional sprites with 14 and 11 opaque colors respectively.

The player locomotion sheet provides idle, two-frame walk, and dash poses in four directions. Sword and Thrall claw attacks use separate 64x48 action canvases with six authored frames per direction. The Thrall scratch uses anticipation, raised arm, slash, impact, follow-through, and recovery; its locomotion sheet retains idle, two-frame chase, and defeated poses.

Tree depth is intentionally split into base and canopy while the prop participates in actor Y-sorting. The player can appear behind the tree when north of its footprint and in front when south of it; canopy motion never changes collision or navigation.

The active level spans 30x18 ground cells, four times the original arena area. A pixel-stable camera follows the player through open combat clearings and landmark corridors. Trees and statues are positioned as navigation/combat structure rather than uniform decoration; deterministic weighted ground variation avoids a visible checker pattern.

Animation must remain readable at gameplay speed. Strong anticipation, action, and recovery poses matter more than additional frames or surface detail.

## Replayability

Potential sources include build variety, encounter variation, optional bosses, difficulty modifiers, branching routes, and mastery-based challenges. No roguelite structure should be assumed until formally selected.

## Accessibility and UX

Planned considerations include input remapping, keyboard/gamepad parity, readable text, scalable UI, screen-shake controls, flash reduction, color-independent combat cues, and pause behavior.

## Future Ideas

- NPCs and quests
- Multiple maps or realms
- Additional weapons and ability schools
- Challenge modes
- Multiplayer expansion

These are not commitments and should not distort the first playable prototype.
