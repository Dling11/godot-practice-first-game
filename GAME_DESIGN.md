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

**Implemented journey entry:** the game opens at the Battle of Gods title screen. `Begin the Awakening` starts a fresh in-memory run and fades into Sanctuary. Settings currently provide immediate session-only Music, Combat Sound, and Menu Sound toggles. Continue/profile selection does not exist yet.

**Implemented Sanctuary loop:** Sanctuary is a safe expedition hub centered on two separate landmarks: a walk-around divine fountain in the courtyard and an animated angel portal farther north. Dedicated grass and cobblestone paths connect the side-positioned mushroom dwelling and merchant hall to the central route. The player walks around either side of the fountain, crosses a visible open gap, ascends the portal's broad center staircase, and reaches the contextual expedition prompt immediately before the portal surface; the authored threshold and rear footprints prevent walking through the monument. The hub also contains a weapon stall, generated trees, Skillkeeper Eira, and Armskeeper Orren. Both NPCs use restrained pixel-stepped breathing while their collision and interaction footprints remain fixed. Opaw turns toward either speaker and holds the matching directional interaction pose while dialogue is active. Eira's dialogue hands off to the current character surface. Orren previews the future weapon service, but purchasing, prices, item ownership, equip commands, combat bonuses, and coin sinks are not implemented. The portal currently offers the beginner Forgotten Grove route and previews two sealed future regions. Stage 1 continues directly to Stage 2; clearing Stage 2 returns to Sanctuary.

Future destination access should combine level, story flags, boss victories, discovered locations, and required key items. Level alone must not unlock every road, and completed early expeditions should remain replayable.

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

**Implemented combat feedback:** an accepted outgoing hit turns the enemy silhouette white for 0.10 seconds and applies one non-stacking 0.045-second impact freeze, alongside a short gold damage number, white-hot burst core with three colored pixel sparks, positional sound, and restrained camera nudge. The normal Ashwood strike delivers light 48 px/s knockback while Sweeping Cut retains its stronger 90 px/s spacing push. Accepted incoming player damage displays red numbers and bursts with sound and camera response, but does not freeze gameplay. Misses, blocked hits, and telegraphed attacks produce none of this confirmed-hit feedback.

**Implemented combat audio:** sword activation, accepted sword impacts, Sweeping Cut, dash, incoming player damage, Thrall claws, Mireling leaps/landings, Spitter firing, and seed impacts have distinct positional cues. Sounds follow authoritative attack signals and accepted hits; they never determine whether damage occurs.

## Player Character

The active mortal player is **Opaw**, presented as a **Mortal Wayfarer** and **Novice Warrior**. `Player` remains the technical gameplay role so Opaw, future classes, and possible additional playable characters can reuse the same contracts. Opaw's origin, base attributes, and relationship to The One Above remain undecided; naming him does not resolve those lore questions. **The Awakened** is now a preserved legacy prototype title rather than the active character identity.

Opaw establishes a modular playable-character direction: one compact armless four-direction body carries locomotion, interaction, hurt, and staged defeat poses, while the Ashwood Blade is a detached presentation layer. His oversized boxy head, serious eyes, rust scarf, narrow green tunic, and tiny boots keep his identity readable without arm or sleeve silhouettes. Future Ranger and Mage candidates may reuse the action/foot-baseline contract, but their limb treatment and equipment motion require their own review instead of inheriting Opaw's orbit automatically. Class rules, selection, and progression are not implemented.

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

- **Opaw:** implemented mortal player identity; currently a Novice Warrior. His deeper history and divine significance remain open.
- **Skillkeeper Eira:** implemented Sanctuary NPC who introduces the current skill-information surface.
- **Armskeeper Orren:** implemented Sanctuary merchant NPC who previews the future equipment service without selling items yet.
- **The One Above:** approved primordial creator and strongest known being; exact present state remains mysterious.

No additional named gods, demons, or factions are approved. Eira and Orren retain their current bespoke sprites until a later, separately reviewed modular-NPC migration.

## Enemies and Bosses

**Planned enemy roles:** pursuer, flanker, ranged pressure, area denial, support, summoner, elite, and boss. Actual enemies should combine a small number of readable behaviors.

**Planned boss principles:**

- Multiple phases or behavioral states.
- Clear telegraphs and punish windows.
- Escalation through pattern interaction rather than unavoidable damage.
- Theme, arena, mechanics, and lore that reinforce each other.

**Implemented enemy prototype - Forsaken Thrall:** a corrupted humanoid pursuer that materializes before becoming hostile, follows obstacle paths to the player's actual footprint, and uses a six-pose directional claw scratch with anticipation, raised arm, slash, impact, follow-through, and vulnerable recovery. It has 100 prototype health and deals 15 prototype damage; values remain provisional.

No specific boss roster is approved.

**Implemented Stage 1 encounter:** three sequential beginner waves introduce Mirelings and Thralls only. Wave 3 remains capped at four enemies. Clearing it opens the stage-exit portal. Entering its range shows `F - Enter Portal`; leaving removes the prompt. Interaction fades through a loading veil into Stage 2.

**Implemented Stage 2 encounter — Thorns of the Forgotten Grove:** the player arrives at a small grove with a central broken shrine, flanking trees, and clear paths to the north exit. The arrival message reads `THE THORNS REMEMBER YOUR FOOTSTEPS`. Wave 1 uses two Mirelings as a warm-up. Wave 2 introduces one Bramble Spitter alongside one Mireling. Clearing both waves opens a return portal to Sanctuary; no exit portal exists before the clear.

Every encounter spawn is announced by a short violet ground rune, inward sparks, and restrained lightning strike aligned with the enemy's non-hostile materialization. Clearing a wave provides a 2.25-second recovery window before the next wave begins.

**Mireling:** a small corrupted divine slime with 30 health and a larger 32x32 presentation. Within 105 pixels and clear line-of-sight it snapshots the player's position, shows a 0.65-second landing marker, leaps there over 0.42 seconds, deals 5 damage only on landing, then remains vulnerable for 1 second. Moving or dashing away from the snapshot avoids the hit.

**Bramble Spitter:** a weak forest-corrupted ranged creature with 40 health. It seeks a 95-190 pixel firing band, faces the player while backing away, and uses a three-frame charge/compression/spit sequence. A pulsing red ground marker snapshots the player's position for 0.75 seconds instead of presenting the attack as a laser. It then recoils while firing one bright, trailed 8-damage seed that terminates at the marked position. Seeds burst visibly on impact and the Spitter recovers for 1.25 seconds. Leaving the marker avoids the hit. It is officially introduced in Stage 2 Wave 2 alongside one Mireling.

Standard enemies keep their health bars hidden at full health. Taking damage reveals a compact world-space bar for 2.2 seconds; further hits refresh that window, and death hides it immediately. This preserves exploration readability while still communicating combat progress.

## Weapons

**Planned:** data-driven weapon definitions with composable attack behaviors. Weapons should differ in reach, timing, mobility, risk, resource use, and synergy—not only damage.

**Implemented starter weapon - Ashwood Blade:** Opaw carries a small wooden sword as a separate world presentation sprite. Its `WeaponDefinition` supplies the texture's grip offset, visual scale, and swing radius so the weapon rotates around its authored grip rather than its image center. The presentation node follows a small bounded orbit beside Opaw's armless body and observes authoritative wind-up, active, and recovery phases, while the weaponless body supplies a deep coil, explosive lunge, and overshoot at fixed scale. The normal attack uses a 0.11-second anticipation, fast 0.08-second committed sweep, nearly half-turn mirrored presentation arc, forward extension, dense white-gold trail, and 0.21-second recovery. The existing directional hitbox still owns contacts, reach, and 25 damage.

**Implemented sword-style foundation:** the Ashwood Blade selects the Balanced Slash presentation profile. Swift Slash and Heavy Cleave profiles provide alternate orbit, extension, trail, and strike-accent tuning for future sword families, but they are not obtainable weapons. A higher-grade sword may reuse Balanced Slash and Opaw's same weaponless body animation while changing its own texture, grip, scale, damage, knockback, and authoritative timing. A genuinely different weapon family may select another reviewed style; visual arc or trail changes never change hitbox reach or damage by themselves.

**Implemented equipment design preview:** the paused character surface presents only the Ashwood Blade at **Wood** rank and uses the same stable weapon ID, world texture, and equipped presentation as the player scene. The early intended material vocabulary is **Wood -> Stonebound -> Iron -> Rare**, with spirit blue reserved for the first Rare tier. Only Wood is active; Stonebound, Iron, Rare, ownership, drops, purchases, saving, and stat aggregation are not implemented. The former A Grade, S Grade, Legendary, and Mythic weapon concepts are preserved as legacy exploration material and are no longer player-facing beginner equipment.

Equipment must reinforce decisions across normal attack, dash, and active skills rather than replace skills with larger numbers. Armor, gloves, boots, and one accessory may begin as icon-and-stat equipment without changing the world sprite. Activating higher ranks also requires stronger authored enemies, elites, and bosses; Legendary or Mythic gear must not trivialize the beginner expeditions.

Future weapon families may include spears, dual swords, greatswords, axes, ranged weapons, and supernatural weapons. They should reuse combat contracts while providing genuinely different attack behavior rather than reskinning the sword.

## Skills and Powers

**Planned categories:** divine powers, demonic powers, weapon skills, mobility tools, defensive tools, and passive modifiers.

**Implemented prototype weapon skill - Sweeping Cut:** skill slot 1 (`1`, with Q retained temporarily as a legacy fallback; left shoulder on gamepad) performs a broad frontal sword technique with 0.16-second wind-up, 0.12-second active window, 0.22-second recovery, 20 damage, visible spacing pushback, and a 2.5-second cooldown. Casting prevents normal attack and dash until recovery ends. It is intentionally weaker than the 25-damage focused sword attack per target and exists to create space against small groups.

The starting character has no divine or demonic ability. Supernatural powers should arrive through later story or progression so the early player remains weak and their eventual growth remains meaningful.

The relationship between divine and demonic power may involve affinity, corruption, mutual exclusivity, or build synergy. This requires an explicit design decision before implementation.

## Progression and Economy

**Implemented introductory foundation:** this project uses a small authored progression arc rather than an endless run-based or advertisement-style upgrade loop. A run starts at level 1 and caps at level 10. XP thresholds are cumulative: 0, 20, 50, 90, 140, 200, 270, 350, 440, and 540. Mirelings award 8 XP and 1 coin; Forsaken Thralls award 15 XP and 3 coins; Bramble Spitters award 20 XP and 5 coins. The HUD displays level, current XP progress, and coins.

This is in-memory run state: it survives portal scene transitions, resets when the player restarts after defeat, and is not written to disk. Reaching a level does not pause combat, randomly offer upgrades, alter combat stats, or grant an ability yet.

The approved control budget is four equipable active skill slots on keys 1-4, in addition to normal attack and dash. The centered combat bar exposes all four slots; only Sweeping Cut is currently equipped. Physical Tab or the visible top-left satchel/Character button opens the paused two-page character surface. `Gear & Armory` shows level, XP, coins, animated Opaw with the Ashwood Blade, five eventual equipment slots, the single Wood starter, lore, and skill-synergy intent. `Active Skills` presents core actions and four selectable cards sourced from the same loadout as the HUD. Mouse click or directional focus plus Enter selects cards and tabs; Escape or the visible top-right button closes the menu. Slots 2-4 remain sealed; their displayed level 3/6/9 milestones are presentation scaffolding until authored abilities and unlock rules are approved. Leveling unlocks authored options or requirements rather than interrupting every level with random choices.

Open decisions include how coins are spent, whether skills are unlocked by level or purchased after reaching a level, which abilities occupy slots 2-4, what persists through a profile save, how owned inventory/equipment is represented, where items are acquired, and how bonuses scale without erasing combat mastery.

Progression must preserve skill-based combat. Numerical growth should not erase the need to dodge, read attacks, and position well.

## Exploration

Exploration should reveal lore, resources, optional challenges, shortcuts, secrets, and alternative encounters. Map topology and procedural-versus-authored content are undecided.

## Visual and Environment Direction

The world uses simple, clean retro pixel art with strong silhouettes, limited palettes, and consistent pixel density. Gameplay readability takes priority over decorative detail or realism.

Environment art is part of gameplay design. Trees, bushes, rocks, buildings, walls, statues, and other large props should clarify navigation and combat space while supporting collision, cover/occlusion, interaction, or navigation behavior where appropriate.

Large props must communicate depth correctly. A player walking behind a tree canopy may become partially or fully obscured while remaining visually in front of the lower trunk when spatially appropriate. Shadows, foreground pieces, and occluding pieces should reinforce spatial relationships without hiding hazards unfairly.

Tile-based environments should support reusable terrain transitions, ground variation, decorative overlays, collision, and navigation instead of being authored for only one location.

**Implemented prototype revision:** four bright grass variants, a layered limited-palette ancient tree, and a broken forgotten-god shrine establish a simple colorful fantasy palette. The tree canopy uses subtle intermittent sway. Opaw uses strict action-owned directional sheets with a compact armless silhouette; the Forsaken Thrall retains its validated 24x32 locomotion and 64x48 claw-action contracts. Existing Mireling and Bramble Spitter art remains unchanged.

Opaw's separate direction-row sheets provide two-frame idle, four-frame walk, three-pose weaponless attack, three-frame dash, two-frame interaction, two-frame hurt, and four-stage defeat. Every direction begins from the same 18x27 reference silhouette and y=32 foot baseline; wider action cells preserve scale during lunges, leans, and collapse. Normal attacks map wind-up, active, and recovery to exaggerated whole-body poses while the separately rendered Ashwood Blade supplies detached integer-pixel placement, phase-driven orbit/trail, and a visual drop during defeat. Runtime fading follows the authored collapse rather than replacing it. The complete previous Wayfarer sheet set remains an independent visual backup. The Thrall scratch still uses anticipation, raised arm, slash, impact, follow-through, and recovery on its six-frame 64x48 canvas.

Tree depth is intentionally split into base and canopy while the prop participates in actor Y-sorting. The player can appear behind the tree when north of its footprint and in front when south of it; canopy motion never changes collision or navigation.

The active level spans 30x18 ground cells, four times the original arena area. A pixel-stable camera follows the player through open combat clearings and landmark corridors. Trees and statues are positioned as navigation/combat structure rather than uniform decoration; deterministic weighted ground variation avoids a visible checker pattern.

Animation must remain readable at gameplay speed. Strong anticipation, action, and recovery poses matter more than additional frames or surface detail.

## Replayability

Potential sources include build variety, encounter variation, optional bosses, difficulty modifiers, branching routes, and mastery-based challenges. No roguelite structure should be assumed until formally selected.

## Accessibility and UX

Planned considerations include input remapping, keyboard/gamepad parity, readable text, scalable UI, screen-shake controls, flash reduction, color-independent combat cues, and pause behavior.

**Implemented title UX:** mouse, keyboard, and gamepad UI actions share an explicit focus loop. Opening Settings moves focus into the modal; Back or UI Cancel restores the invoking Settings button. Title presentation uses separate replaceable background layers and never bakes controls into art.

**Implemented gameplay modal UX:** dialogue exposes a clickable Continue/Close action, the character menu exposes a top-right close button, and Escape immediately cancels the active dialogue or menu. Canceling Eira's dialogue does not silently open the skill-information menu. A future in-expedition return must be a confirmed `Abandon Expedition / Return to Sanctuary` action with explicit run consequences, not an unguarded teleport hotkey.

## Future Ideas

- NPCs and quests
- Multiple maps or realms
- Additional weapons and ability schools
- Challenge modes
- Multiplayer expansion

These are not commitments and should not distort the first playable prototype.
