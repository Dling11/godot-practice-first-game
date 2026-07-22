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

**Implemented Sanctuary loop:** Sanctuary is a safe expedition hub centered on two separate landmarks: a walk-around divine fountain in the courtyard and an animated angel portal farther north. A paired central cobblestone avenue aligns both landmarks on the hub's even-width grid; one-cell door approaches align Eira's violet spirit-study lodge and Orren's warm arms workshop to a restrained east-west connector, while a compact paved bay grounds Orren's cart without consuming the surrounding garden. The player walks around either side of the fountain, crosses a visible open gap, ascends the portal's broad center staircase, and reaches the contextual expedition prompt immediately before the portal surface; the authored threshold and rear footprints prevent walking through the monument. Orren's separate weapon cart has a complete prop-only silhouette with no merchant body baked into it. Eira and Orren use compact oversized-head/tiny-body proportions aligned with Opaw, plus two intentional detached role props each and restrained pixel-stepped breathing while collision and interaction footprints remain fixed. Opaw turns toward either speaker and holds the matching directional interaction pose while dialogue is active. Eira's dialogue hands off to the current character surface. Completing Orren's dialogue opens his real weapon shop: Iron Sword costs 18 run coins, enters owned inventory, and is equipped later from the character menu. The portal currently offers implemented stages and sealed future routes according to their authored requirements. The active forest expedition flows Stage 1 to Stage 2 to Stage 3, then returns to Sanctuary after the Rootbound Husk.

Future destination access should combine level, story flags, boss victories, discovered locations, and required key items. Level alone must not unlock every road, and completed early expeditions should remain replayable.

**Implemented expedition access foundation:** immutable destination definitions now combine those five requirement categories. The portal creates its route buttons from data and explains missing requirements. Forgotten Grove opens after Sanctuary records Opaw's awakening. The Rootbound Hollow has an implemented destination and F9 developer access but remains sealed in normal progression until its authored requirements exist; The Drowned Bells remains an unbuilt sealed preview. Story memory survives scene changes only for the current application session; disk saves remain unimplemented.

## Combat

- **Implemented combat audio identity:** Opaw's accepted damage uses a distinct short cloth/body impact, while every enemy keeps its own attack signal. Dash uses a quiet curated light swish so it does not compete with danger or hit confirmation.
- **Implemented input commitment:** One latest valid normal attack or immediate-directional skill may buffer through a committed normal attack or active dash and starts at the first vulnerable recovery boundary. A living hit window is never interrupted, inputs do not stack, and dash cannot cancel an already-casting skill.
Combat must prioritize control and clarity:

- Smooth, acceleration-aware movement without unwanted input lag.
- **Implemented controls:** WASD/left-stick movement owns Opaw's four-way combat facing and standing preserves the last movement direction. Passive mouse movement does not rotate attacks. Left mouse/right trigger activates the basic sword chain; right mouse remains unassigned and the pointer remains available for menus and future explicit targeted-skill confirmation.
- Attacks with explicit wind-up, active, recovery, and cancel rules.
- Dodge/roll with deliberately timed invincibility frames.
- **Implemented prototype:** the player uses a short supernatural directional dash with invulnerability during movement and a non-invulnerable recovery window. The dash uses movement direction, then facing direction when stationary.
- **Implemented dash attack chain:** pressing basic attack during active dash movement buffers one normal equipped-weapon attack. It begins when the authored dash distance and invulnerability end, replacing the vulnerable recovery with the sword's normal wind-up. Pressing attack after recovery has begun cancels that recovery immediately. The chain adds no separate damage, hitbox, invulnerability, or attack animation; it reuses the normal three-swing sequence and remains vulnerable throughout the sword attack.
- **Implemented dash availability:** each dash starts an independent 0.85-second reuse cooldown. Recovery may still cancel into an attack, but another dash cannot begin until the cooldown expires, preventing continuous invulnerability chaining.
- Enemies that pursue, predict, reposition, and attack without relying only on direct beelines.
- Telegraphs that remain legible with many enemies on screen.
- Hit pause, camera response, sound, particles, and animation used selectively for impact.
- Bosses with phase changes that introduce new decisions, not merely more health.

The final damage curve, poise, stamina, mana, and later targeting rules are not yet decided. The current prototype does define simple crowd-control resistance: Light enemies accept full knockback/stagger, Elite enemies accept reduced control, and Boss enemies accept neither.

**Implemented prototype defeat loop:** the player's vitality is visible. At zero health, movement and combat stop, the player enters a fallen presentation, and the player may press R or the gamepad north button to reload the proving ground. The prototype has no progression loss or automatic restart.

**Implemented combat feedback:** an accepted outgoing hit turns the enemy silhouette white for 0.10 seconds and applies one non-stacking 0.045-second impact freeze, alongside a short gold damage number, white-hot burst core with three colored pixel sparks, positional sound, and restrained camera nudge. The normal Ashwood strike delivers light 48 px/s knockback while Sweeping Cut retains its stronger 90 px/s spacing push. Accepted incoming player damage displays red numbers and bursts with sound and camera response, but does not freeze gameplay. Misses, blocked hits, and telegraphed attacks produce none of this confirmed-hit feedback.

**Implemented crowd-control baseline:** every enemy definition declares a `Light`, `Elite`, or `Boss` control tier. Light enemies receive full movement knockback and any authored stagger; Elite enemies receive 35% knockback and 45% stagger duration; Bosses receive no knockback or stagger. Stagger cancels a current enemy attack and temporarily blocks a new one, but only damage data that explicitly carries stagger can cause it. The starter Thrall, Mireling, and Bramble Spitter are explicitly Light; a future boss becomes control-immune through its data rather than per-skill exceptions.

**Implemented combat audio:** sword activation, accepted sword impacts, the current weapon-technique cast, dash, incoming player damage, Thrall claws, Mireling leaps/landings, Spitter firing, and seed impacts have positional cues. Piercing Rush now has three dedicated CC0 positional cues: a restrained wind-up, a loud forward thrust at the active phase, and a separate metal/spirit impact only after an accepted hit. Sounds follow authoritative attack signals and accepted hits; they never determine whether damage occurs.

## Player Character

## Provisional Forest Arc

The first forest arc is staged deliberately: Stage 1 introduces small forest threats, Stage 2 mixes established roles, and Stage 3 culminates in the Rootbound Husk mini-boss with a skippable arrival line. Stage 4 should introduce one new player-facing system or item before it raises enemy complexity. Stage 5 is reserved for a separately designed medium forest boss with its own readable movement, attack, dialogue, and reward loop. These later stages are planned, not implemented.

The active mortal player is **Opaw**, presented as a **Mortal Wayfarer** and **Novice Warrior**. He was killed in a former world and awakened through the Remembered Veil with the final moments of his previous life fractured. `Player` remains the technical gameplay role so Opaw and a future switchable roster can reuse the same contracts. Character identity is distinct from class: Opaw begins the Warrior foundation, while Mage and Archer remain planned combat archetypes that may belong to later characters or class paths. **The Awakened** is now a preserved legacy prototype title rather than the active character identity.

Opaw establishes a modular playable-character direction: one compact armless four-direction body carries locomotion, interaction, hurt, and staged defeat poses, while his equipped sword is a detached presentation layer. His oversized boxy head, serious eyes, rust scarf, narrow green tunic, and tiny boots keep his identity readable without arm or sleeve silhouettes. Future Archer and Mage characters may reuse the action/foot-baseline contract, but their limb treatment, equipment motion, resources, and skills require their own review instead of inheriting Opaw's sword orbit. Weapon data now enforces compatible class IDs and Warrior Opaw cannot equip another class's weapon; roster switching itself is not implemented and should occur in Sanctuary or another safe preparation space.

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

Opaw's death and isekai awakening establish the mortal viewpoint. Most known gods treat mortal worlds, wars, chosen heroes, and catastrophes as trials, wagers, or entertainment rather than lives with equal value. Individual gods may still be cruel, indifferent, constrained, sympathetic, or rebellious; the story should not flatten the pantheon into identical villains.

Reality was shaped by **The One Above**, an ancient primordial creator and the strongest known being. The One Above predates the known gods and remains a mystery rather than an ordinary quest-giver or automatically confirmed final villain. The lesser gods' behavior does not yet prove whether The One Above is absent, observing, imprisoned, or acting under unknown rules.

Sanctuary preserves soul-memory beyond death. Opaw's first mystery is why the Veil remembered him at all. The story escalates from mortal corruption and divine servants to gods, beyond-god beings, boundless law-distorters, and a provisional far-future author-class tier while keeping every attack readable and dodgeable. `STORY_BIBLE.md` is the canonical source for this premise, planned opening arc, roster direction, and unresolved questions.

## Characters and Factions

- **Opaw:** implemented isekai mortal player identity; currently a Novice Warrior whose former-life death memory is fractured.
- **Skillkeeper Eira:** implemented Sanctuary NPC who introduces the current skill-information surface.
- **Armskeeper Orren:** implemented Sanctuary merchant NPC who sells the Warrior-only Iron Sword for 18 coins and never sells skills.
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

The **Thornbound Warden** is the first planned named boss and a future normal-progression requirement for The Rootbound Hollow. Its arena, mechanics, art, rewards, and exact place after the current two Forgotten Grove stages remain unimplemented and require a dedicated design pass.

**Implemented Stage 1 encounter:** six sequential beginner waves introduce Mirelings, Rootlings, and then Thralls while never exceeding four live enemies. The later five-to-seven-enemy waves issue a `REINFORCEMENTS APPROACH` warning, then release one replacement at a time rather than refilling every opening after a burst kill. Clearing the finale opens the stage-exit portal. Entering its range shows `F - Enter Portal`; leaving removes the prompt. Interaction fades through a loading veil into Stage 2.

**Implemented Stage 2 encounter — Thorns of the Forgotten Grove:** the player arrives at a small grove with a central broken shrine, flanking trees, and clear paths to the north exit. The arrival message reads `THE THORNS REMEMBER YOUR FOOTSTEPS`. Seven waves build from a three-Mireling warm-up through the first Bramble Spitter, Rootling/ranged pressure, and five-to-seven-enemy mixed endurance waves. Reinforcements warn before arriving and enter singly, keeping both the live crowd at four or fewer and a burst-kill reward window open. Clearing all seven waves opens the forward portal into Stage 3; no exit portal exists before the clear.

**Implemented Stage 3 encounter — The Rootbound Hollow:** Stage 3 is selectable from Sanctuary once its requirements are met, or immediately through the debug F9 preset. Opaw cuts through ten Rootlings, released at no more than four live enemies, establishing them as the Rootbound Husk's corrupted brood. After the last Rootling falls, a skippable portrait dialogue lets the angered Husk name the trespass; gameplay remains paused and the solo mini-boss wave cannot begin until the dialogue closes. The Husk opens with a quick single Root Spear, tests wider movement with a slower three-lane Root Fan whose center erupts before its warned side lanes, and uses a circular point-blank Root Burst when Opaw crowds its body. The lane attacks lock direction at telegraph time, and the mini-boss track starts only when the gated Husk wave begins.

Every encounter spawn is announced by a short violet ground rune, inward sparks, and restrained lightning strike aligned with the enemy's non-hostile materialization. Clearing a wave provides a 2.25-second recovery window before the next wave begins.

**Encounter pacing update:** Stage 1 uses six deliberate waves totaling 30 enemies: 3 Mirelings; 3 Mirelings plus 1 Rootling; 2 Mirelings, 1 Rootling, and 2 Thralls; 2 Mirelings, 2 Rootlings, and 1 Thrall; then 6- and 7-enemy mixed endurance waves. Stage 2 uses seven waves totaling 32 enemies: it teaches the three-Mireling warm-up, Spitter pressure, and Rootling/ranged pressure before escalating through four mixed groups and a seven-enemy finale. Any wave above four enemies releases its next group after a short roughly 0.8-second gap, with every arrival announced by the existing summon effect; no more than four enemies may be live. Difficulty comes from duration and learned-role combinations, never health inflation or an uncontrolled horde.

**Mireling:** a small corrupted divine slime with 30 health and one compact remodeled presentation. Its 18-pixel-tall body uses directional idle, four-frame hopping, four-frame body-slam, and four-frame collapse animations through `AnimatedSprite2D`; wider `48x32` action cells preserve spread poses without changing body scale. Within 105 pixels and clear line-of-sight it snapshots the player's position, shows a 0.65-second landing marker, leaps there over 0.42 seconds, deals 5 damage only on landing, then remains vulnerable for 1 second. Moving or dashing away from the snapshot avoids the hit.

**Rootling:** the implemented cute Stage 1 forest mob has 35 health, moves at 52 px/s, and deals 6 damage. It chases normally, then anchors for 0.58 seconds while a small crack grows in its locked forward direction. A narrow 40x16 root jab erupts for 0.12 seconds before 0.82 seconds of recovery. Stepping or dashing sideways after the crack avoids it; moving around it cannot rotate its lane. Its four-direction walk, anchor/hurt/defeat responses, and separate crack/eruption VFX make its threat legible without making it boss-sized.

**Rootbound Husk:** implemented as Stage 3's solo 280-health Boss-tier mini-boss. Its active form is a broad corrupted stump guardian with a compact broken-branch crown, bark-plated shoulders, moss-draped torso, bright lime core, heavy separated root legs, and long vine claws. It anchors itself for either a quick single 112x20 Root Spear or a slower three-lane Root Fan. The fan telegraphs all three locked directions, erupts the center first, then its violet side lanes 0.11 seconds later; below half health, wind-up/recovery shorten modestly and fans appear more often. If Opaw crowds its body within 34 pixels, the Husk instead braces for a 0.48-second circular Root Burst, making overlap unsafe while leaving time to dash or step out. Each root pattern reads from the ground plane as a lime soil crack, spreading warning, root bulge, compact thorn spear, peak, and collapse instead of a tree appearing near the boss's hands. Its 12 damage and Boss control resistance keep the fight threatening, while 280 health is intended to expose multiple patterns without becoming a health sponge. Its fixed-scale side walk follows contact A, passing A, opposite contact B, and passing B: foreground/background legs exchange forward/back positions while the arms counter-swing, and the opposite direction is an exact mirror. Its six-stage root-command body reads ready, brace, gather, release, hold, and recover while separate ground VFX own the eruption. Hurt uses approved final-model root-command frames; each directional defeat uses the four manually reviewed collapse frames fitted to the 0.6-second cleanup window. The damage-revealed bar remains above its crown. Its future Rootbound Elder boss may extend this language with living-arena pressure without replacing the readable base attack.

**Bramble Spitter:** a weak forest-corrupted ranged creature with 40 health. It seeks a 95-190 pixel firing band, faces the player while backing away, and uses a three-frame charge/compression/spit sequence. A pulsing red ground marker snapshots the player's position for 0.75 seconds instead of presenting the attack as a laser. It then recoils while firing one bright, trailed 8-damage seed that terminates at the marked position. Seeds burst visibly on impact and the Spitter recovers for 1.25 seconds. Leaving the marker avoids the hit. It is officially introduced in Stage 2 Wave 2 alongside one Mireling.

Standard enemies keep their health bars hidden at full health. Taking damage reveals a compact world-space bar for 2.2 seconds; further hits refresh that window, and death hides it immediately. This preserves exploration readability while still communicating combat progress.

## Weapons

**Planned:** data-driven weapon definitions with composable attack behaviors. Weapons should differ in reach, timing, mobility, risk, resource use, and synergy—not only damage.

**Implemented starter weapon - Ashwood Blade:** Opaw carries a small wooden sword as a separate world presentation sprite. Its `WeaponDefinition` supplies the texture's grip offset, visual scale, and swing radius so the weapon rotates around its authored grip rather than its image center. The presentation node follows a small bounded orbit beside Opaw's armless body and observes authoritative wind-up, active, and recovery phases, while the weaponless body supplies a deep coil, explosive lunge, and overshoot at fixed scale. The normal attack uses a 0.11-second anticipation, fast 0.08-second committed sweep, nearly half-turn mirrored presentation arc, forward extension, dense white-gold trail, and 0.21-second recovery. The existing directional hitbox still owns contacts, reach, and 25 damage.

**Implemented sword-style foundation:** the Ashwood Blade selects the Balanced Slash presentation profile. Consecutive normal attacks cycle through a broad outward sweep, a reverse return sweep, and a farther-reaching visual finishing sweep, then repeat. This is visual variety rather than a damage combo: all three still use the weapon's same authoritative timing, hitbox, damage, and knockback. Swift Slash and Heavy Cleave profiles provide alternate orbit, extension, trail, strike-accent, and three-swing sequence tuning for future sword families, but they are not obtainable weapons. A higher-grade sword may reuse Balanced Slash and Opaw's same weaponless body animation while changing its own texture, grip, scale, damage, knockback, and authoritative timing. A genuinely different weapon family may select another reviewed style; visual arc or trail changes never change hitbox reach or damage by themselves.

**Implemented early weapon inventory:** Ashwood Blade is the always-owned, unsellable **Wood** fallback. Orren's **Iron Sword** costs 18 coins, deals 32 damage with 56 knockback, and reuses Balanced Slash plus Opaw's existing weaponless body animation. Purchasing stores Iron without auto-equipping it; clicking an owned compatible sword in Gear & Armory switches the authoritative `WeaponDefinition`, world sprite, menu portrait, damage, and knockback together. Opaw's Warrior class rejects weapons whose `compatible_classes` omit `warrior`. The current beginner set deliberately stops at Wood and Iron; spirit-blue higher grades remain deferred. Drops, armor stats, selling, and disk saving are not implemented. Former A/S/Legendary/Mythic concepts remain legacy exploration material.

Equipment must reinforce decisions across normal attack, dash, and active skills rather than replace skills with larger numbers. Armor, gloves, boots, and one accessory may begin as icon-and-stat equipment without changing the world sprite. Activating higher ranks also requires stronger authored enemies, elites, and bosses; Legendary or Mythic gear must not trivialize the beginner expeditions.

Future weapon families may include spears, dual swords, greatswords, axes, ranged weapons, and supernatural weapons. They should reuse combat contracts while providing genuinely different attack behavior rather than reskinning the sword.

## Skills and Powers

**Planned categories:** divine powers, demonic powers, weapon skills, mobility tools, defensive tools, and passive modifiers.

**Implemented Skill 1 - Piercing Rush:** `1`, legacy Q, left shoulder, or clicking the ready HUD slot commits Opaw along his movement-owned facing. A 0.14-second brace becomes 0.18 seconds of collision-limited movement at 280 px/s (roughly 50 pixels), followed by 0.24 seconds of vulnerable recovery and a 3-second cooldown. Its 128-pixel forward lance is 30 pixels thick and deals 180% of the equipped sword's snapshotted damage—45 with Ashwood and 57.6 with Iron—with 112 pushback once per target. Piercing Rush grants no invulnerability. The detached sword changes to a thrust pose while a real six-frame white/blue/gold animation advances through compressed charge, ignition, long lance, oversized roughly 160-pixel peak plume, shock-ring impact, and fading ribbons. A dedicated CC0 charge, thrust, and accepted-impact sequence makes the cast distinct from a normal swing. The bright central spear reads the full contact lane; the much larger outer wings, sparks, and afterimages remain deliberate cosmetic exaggeration and never own collision or damage.

**Implemented debug Skill 2 - Consecutive Thrust:** in the F9 test loadout, `2` or its ready HUD button braces for 0.16 seconds, then fires seven stationary forward spirit-lance strikes over 0.88 seconds before 0.30 seconds of vulnerable recovery (1.34 seconds total). Its 128-pixel tapered contact lane is 26 pixels wide and always uses the snapshotted movement-facing direction, even while the presentation flicks through shallow alternating angles. The strike sequence deals 18%, 19%, 20%, 21%, 22%, 25%, then 100% of equipped weapon damage (225% total): Ashwood deals 4.5, 4.75, 5, 5.25, 5.5, 6.25, then 25; Iron deals 5.76, 6.08, 6.4, 6.72, 7.04, 8, then 32. Each early lance applies a refreshed 0.21-second stagger and no push, continuously interrupting Light enemies through the flurry; the final lance applies a 0.42-second stagger, 150 knockback, enlarged VFX, camera emphasis, and hitstop. Elite/Boss tiers reduce or ignore those control values as defined above. The technique combines an eight-beat approved-Opaw body sheet, a twelve-cell effect-only white/gold/blue VFX atlas, alternating detached-sword thrusts, a quiet charge, three spaced steel-thrust beats, a strong final sword thrust, and a blade contact cue only when the last hit connects. The largest final VFX cell and final sword burst now start on the same final-strike signal; the blade-contact burst starts immediately only when that strike connects. The VFX then rapidly contracts through three smaller faded cells over about 0.18 seconds, and recovery never holds a delayed giant flash. VFX exaggeration never changes the definition-owned lane or damage authority. It is deliberately test-only until Eira's free awakening has rules and presentation.

**Preserved technique - Sweeping Cut:** the prior broad frontal ability remains as data, its old slot resource, arc presentation code, and regression coverage. It still resolves fixed 20 damage, 90 pushback, 0.16/0.12/0.22 cast phases, and a 2.5-second cooldown when configured, but it is not currently equipped. Future skill loadouts or awakening may restore it without rebuilding its combat contract.

The starting character has no divine or demonic ability. Supernatural powers should arrive through later story or progression so the early player remains weak and their eventual growth remains meaningful.

The relationship between divine and demonic power may involve affinity, corruption, mutual exclusivity, or build synergy. This requires an explicit design decision before implementation.

## Progression and Economy

**Implemented introductory foundation:** this project uses a small authored progression arc rather than an endless run-based or advertisement-style upgrade loop. A run starts at level 1 and caps at level 10. XP thresholds are cumulative: 0, 20, 50, 90, 140, 200, 270, 350, 440, and 540. Mirelings award 8 XP and 1 coin; Forsaken Thralls award 15 XP and 3 coins; Bramble Spitters award 20 XP and 5 coins. The HUD displays level, current XP progress, and coins.

This is in-memory run state: it survives portal scene transitions, resets when the player restarts after defeat, and is not written to disk. Reaching a level does not pause combat, randomly offer upgrades, alter combat stats, or grant an ability yet.

Debug builds provide F9 to set the current run to level 10 and 999 coins, then swap in a separate loadout containing every currently authored Warrior skill: Piercing Rush and Consecutive Thrust. It also grants each authored Warrior-compatible weapon to the test inventory, so Ashwood/Iron scaling can be compared through normal menu equip controls. This exists only to shorten testing, does not mark a normal awakening or Orren purchase as complete, does not expose unfinished slots 3-4, does not alter normal balance rules, and does not save progress to disk.

The approved control budget is four equipable active skill slots on keys 1-4, in addition to normal attack and dash. The centered combat bar exposes all four slots. Normal play equips Piercing Rush only, while debug F9 also equips Consecutive Thrust in slot 2; ready slots are directly clickable while cooldown disables repeat clicks. Physical Tab or the visible top-left satchel/Character button opens the paused two-page character surface. `Gear & Armory` shows level, XP, coins, animated Opaw, five eventual equipment slots, and every owned catalog weapon; selecting a class-compatible weapon equips it. `Active Skills` presents core actions and four selectable cards sourced from the same loadout as the HUD. Mouse click or directional focus plus Enter selects cards and tabs; Escape or the visible top-right button closes the menu. Slots 3-4 remain sealed; their displayed level 6/9 milestones are presentation scaffolding until authored abilities and unlock rules are approved. Leveling creates eligibility for authored skills; skills are never purchased. Future eligible skills must be awakened for free through Eira's service before they become usable.

Open decisions include which abilities occupy slots 2-4, their exact level requirements and Eira ritual presentation, what persists through a profile save, future weapon/drop acquisition, armor/stat aggregation, selling policy beyond the current no-selling slice, and how bonuses scale without erasing combat mastery.

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
