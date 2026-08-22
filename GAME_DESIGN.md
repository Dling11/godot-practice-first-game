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

**Approved regional loop (Stages I-V loot and Stage V crafting/exchange implemented; Hunts planned):**

1. Enter or replay an authored stage in the current region.
2. Fight enemies whose ecology and combat role explain their material drops.
3. Bank an ordinary clear or claim a non-empty milestone chest, then return with materials.
4. Use deterministic recipes at a Sanctuary craftsperson to build region equipment.
5. Refine a build, complete optional Hunt conditions, and master the region.
6. Defeat the regional boss and advance without making earlier stages disposable.

Forest Stages I-X form the first planned regional arc. First clears advance story and unlocks; replays become chosen Hunts with known reward families rather than random daily chores. The complete accepted rules, provisional Stage VI-X role progression, and implementation order live in `docs/design/forest-loot-crafting-and-regional-material-plan.md`. Stage XI begins the next region after its own identity is approved.

**Umi and material exchange:** Umi is an unrelated Sanctuary blue witch whose Echo Crucible gives surplus materials two deliberate uses. Ordinary materials may be sold for modest gold or consumed as meld fuel to reconstruct a known material. The target's own definition supplies value, costs, source enemy, and required victories, so later regional catalogs update the service without NPC-code branches. Common/Uncommon/Rare reconstruction scales from 25/100/400 meld and 10/75/200 gold with 1/10/20 source defeats. Boss materials cannot be sold or used as fuel; reconstructing one costs 1500 meld, 1000 gold, four Rare materials from its region, the authored victory threshold, and one boss-memory charge earned every ten victories. This is a long-tail anti-drought/replay tool, not a shortcut from trash drops to immediate boss gear.

**Gold-backed core crafting:** the six Stage V formulas spend both authored materials and gold. Gloves cost 150, Boots 200, Helm 250, Leggings 300, Plate 400, and Varkuun Edge 500 gold. Stage entry remains equipment-optional; the economy encourages preparation through encounter difficulty and clear time rather than a hard ownership gate.

**Regional naming boundary:** root, tree, bark, wood, grove, thorn, mire, and similar vocabulary may describe Stages I-X content that genuinely belongs to the Forest ecology. It is not a mandatory prefix for every enemy, material, item, character, or service inside that region, and it is not the identity of Battle of Gods. Unrelated Sanctuary characters and global services must use personal, simple, or lore-meaningful names instead of automatically becoming `Root-something`; generic systems should use neutral terms such as craft, exchange, transmute, memory, essence, or crucible. Stage XI+ regions establish their own language.

**Implemented journey entry:** the game opens at the Battle of Gods title screen. `Continue` appears only for a valid primary or backup autosave and restores the last safe profile into Sanctuary. `Begin New Journey` confirms before replacing an existing profile, resets the current progression authorities, and fades into Sanctuary. Settings currently provide immediate session-only Music, Combat Sound, and Menu Sound toggles.

**Implemented Sanctuary loop:** Sanctuary is a safe expedition hub centered on a walk-around divine fountain and a fixed angel-gate structure whose doorway energy animates independently. King faces nearby speakers during interaction. Eira opens King's four-skill information surface without an awakening transaction; Orren is dialogue-only after retirement of the weapon shop; Nema opens the active Living Rootforge for validated gold-backed Stage V crafting; Umi faces her narrow east-side Echo Crucible and opens the compact Sell/Reconstruct surface. The portal offers implemented stages and sealed future routes from immutable destination data. The active Forest expedition reaches Stage V and Varkuun.

Future destination access should combine level, story flags, boss victories, discovered locations, and required key items. Level alone must not unlock every road, and completed early expeditions should remain replayable.

**Implemented expedition access foundation:** immutable destination definitions combine the five requirement categories. The portal creates route buttons from data and explains missing requirements. Forgotten Grove is the starting route; the implemented Forest chain continues through Stage V. The Drowned Bells remains an unbuilt sealed preview. Story flags, victories, discoveries, and key items persist in the safe-point profile.

**Implemented stage-exit presentation:** expedition exits appear as compact upright tears made only from energy, never ground holes, arches, monuments, or other physical structures. Sixteen generated frames move layered currents across the entire translucent inner surface—including the exact middle—while different bands change phase independently and the outer rim ripples and deforms rather than rotating as one flat wheel. A separately generated dense sixteen-frame field supplies lightning, sparks, and particles, but Decision 119 reserves its magnitude by threat: Normal is blue and lightning-free; Mini Boss is purple with restrained close discharge; Boss is red with stronger reach; God is searing white-gold with intense viewport-scale discharge; Transcendent is near-black with the widest violent field. The tiers reuse the same neutral sheets and preserve their color/reach through the loading veil. These differences communicate destination superiority but do not alter interaction range or transition rules.

## Combat

- **Implemented combat audio identity:** King's accepted damage uses a distinct short cloth/body impact, while every enemy keeps its own attack signal. Dash uses a quiet curated light swish so it does not compete with danger or hit confirmation.
- **Implemented input commitment:** One latest valid normal attack, dash, or equipped skill may buffer for at most 0.8 seconds through a committed combat action and starts only at the first legal recovery or ability-finished boundary. New valid input replaces the old intent; cooldown-blocked input is rejected; targeted skills reopen their preview; and inputs never stack. A living hit window is never interrupted. Once a normal attack is accepted, its direction and sword-hitbox pivot remain locked even if the player immediately presses the opposite movement direction; the newest movement facing applies only after recovery. Skills retain their authored commitment and cancellation rules.
Combat must prioritize control and clarity:

- Smooth, acceleration-aware movement without unwanted input lag.
- **Implemented controls:** WASD/left-stick movement owns King's four-way combat facing and standing preserves the last movement direction. Right click always moves to ground and, like WASD, clears selection, pursuit, and automation. Left click outside enemy selection geometry performs a cardinal directional basic attack; one enemy click selects, while a repeated click on that same actor engages navigation-aware repeated attacks. Skills use `1`-`4`; Basic Attack has no number key and retains an icon-backed far-right HUD/right-trigger fallback. Targeted skills are modal: left click/right trigger confirms, while right click or `Esc` cancels without leaking a world command. `AUTO ALL` optionally cycles through living enemies; `AUTO SKILL` additionally uses ready authored skills at safe in-range boundaries. The roster reveals visible nearby actors rather than spoiling dormant/offscreen threats.
- Attacks with explicit wind-up, active, recovery, and cancel rules.
- Dodge/roll with deliberately timed invincibility frames.
- **Implemented prototype:** the player uses a short supernatural directional dash with invulnerability during movement and a non-invulnerable recovery window. The dash uses movement direction, then a stationary defensive backstep opposite facing.
- **Implemented dash attack chain:** pressing basic attack during active dash movement buffers one normal equipped-weapon attack. It begins when the authored dash distance and invulnerability end, replacing the vulnerable recovery with the sword's normal wind-up. Pressing attack after recovery has begun cancels that recovery immediately. The chain adds no separate damage, hitbox, invulnerability, or attack animation; it reuses the normal three-swing sequence and remains vulnerable throughout the sword attack.
- **Implemented dash availability:** each dash starts an independent 0.85-second reuse cooldown. Recovery may still cancel into an attack, but another dash cannot begin until the cooldown expires, preventing continuous invulnerability chaining.
- Enemies that pursue, predict, reposition, and attack without relying only on direct beelines.
- Telegraphs that remain legible with many enemies on screen.
- Hit pause, camera response, sound, particles, and animation used selectively for impact.
- **Implemented bounded impact:** accepted basic damage scales its presentation-only hitstop from 0.024 to a hard 0.034-second cap and applies a 0.11-second Light-enemy flinch. This remains too brief for basic attacks to permanently disable an enemy; Elites reduce it and bosses reject it, while Skills 1-3 own the longer authored interruptions.
- Bosses with phase changes that introduce new decisions, not merely more health.

The final damage curve, poise, stamina, mana, and later targeting rules are not yet decided. The current prototype does define simple crowd-control resistance: Light enemies accept full knockback/stagger, Elite enemies accept reduced control, and Boss enemies accept neither.

**Approved future combo direction:** King may add an authoritative tap/hold sword chain: rapid `click-click` buffers Opening Cut then Reversal Cut, a third press queues Horizon Break, and holding the initial pre-attack beyond the proposed 0.16-second threshold converts it into one charged Falling Divide. This is not implemented. `docs/design/king-sword-combat-and-skill-kit.md` owns the proposed values.

**King animation/targeting direction:** King is the sole production player. Four-direction idle/walk and one four-phase basic slash are implemented. His integrated signature sword uses a dedicated 48-pixel-forward, 56-pixel-wide form, rolls 10-12 normal damage, and retains 25 skill power. The tap/hold chain remains future work. Locomotion-derived dash/reaction aliases are safe placeholders, not final action art. All four active skill slots are implemented; Ultimate and Reality Breaking remain visibly sealed future tiers.

**Implemented prototype vitality/defeat loop:** the player begins with 140 maximum health and gains 12 maximum health per level, reaching 248 at Level 10 before equipment. A level increase grants the new capacity while preserving existing missing damage, then gives the actor a brief low-opacity gold/spirit glow, a small rising `LEVEL N` label above the head, and a short chime. It never pauses play or places a panel over combat. Current HP survives stage-to-stage expedition travel; entering Sanctuary or using Continue restores King to his current maximum before the safe-point save. Confirming after expedition defeat returns to Sanctuary and rolls back uncommitted loot without resetting XP or coins. After five damage-free seconds, baseline regeneration restores only 1 HP per second through `HealthComponent`; incoming damage restarts the delay, and full health or defeat stops it. Healing potions, buffs, and a possible rare revive are deferred utility-item concepts. `PlayerVitalityComponent` aggregates character, level, and equipment maximums, `PlayerHealthRegenerationComponent` schedules recovery, and `HealthComponent` remains heal/damage/death/armor authority. Armor uses diminishing returns (`raw * 100 / (100 + armor)`).

**Implemented combat feedback:** an accepted outgoing hit turns each enemy silhouette white for 0.10 seconds and adds a short gold damage number plus a white-hot burst core with three colored pixel sparks. The flash is hurt readability; strength-scaled hitstop is a distinct real-time pause. A normal swing scales from 0.024 to a capped 0.034-second freeze by accepted damage, while abilities declare light/medium/heavy/devastating impact tiers of 0.024/0.030/0.045/0.065 seconds. King Skill 4's final explosion uses devastating; clustered contacts never stack pauses. Accepted incoming player damage keeps its red number, burst, hurt sound, and camera response and applies the same non-stacking tier durations according to accepted damage amount. Misses, invulnerable contacts, and telegraphed attacks produce none of this confirmed-hit feedback.

**Implemented crowd-control baseline:** every enemy definition declares a `Light`, `Elite`, or `Boss` control tier. Light enemies receive full movement knockback and any authored stagger; Elite enemies receive 35% knockback and 45% stagger duration; Bosses receive no knockback or stagger. Stagger cancels a current enemy attack and temporarily blocks a new one, but only damage data that explicitly carries stagger can cause it. The starter Thrall, Mireling, and Bramble Spitter are explicitly Light; a future boss becomes control-immune through its data rather than per-skill exceptions.

**Implemented combat audio:** sword activation, accepted sword impacts, King's active skills, dash, incoming player damage, Thrall claws, Mireling leaps/landings, Spitter firing, and seed impacts have positional cues. Rootbound Husk separates a woody tension/creak during its telegraph from a snapping-root eruption layered with low earth impact. Sounds follow authoritative attack signals and accepted hits; they never determine whether damage occurs.

## Player Character

## Provisional Forest Arc

Varkuun's Stage V chase follows navigable routes and detours around solid scenery. A committed jump target that overlaps a prop relocates to a nearby boss-sized safe point before its marker appears, rather than embedding him or moving the announced landing afterward.

Decision 097 supersedes this section's older provisional ending: the Stage V milestone chest and Sanctuary return are implemented. The current defeat order is final quote -> collapse/hold/fade -> chest claim. Varkuun's prison warning, lock, execution rumble, and 300-damage impact are separate audible beats; only the later narrative handoff remains open.

The forest climb is staged deliberately: Stage 1 introduces small forest threats, Stage 2 mixes established roles, and Stage 3 culminates in the Rootbound Husk mini-boss. Implemented Stage 4 pushes rot along the eastern edge, raises that stage's live ceiling to eight, and ends at a damaged gateway that opens directly into Stage 5. Implemented Stage 5 is the most sinister forest presentation and first major Forest boss route: a scrolling 24x18 fully decayed approach bordered by dense three-tree thicket groups, with individual bare trees, snags, fallen trunks, uprooted remains, and one fly-covered corrupted animal landmark breaking the journey into readable scenes. Its southern arrival gateway and northern entrance basin are spatially separate. Crossing the basin threshold starts Varkuun, Lord of the Withered Grove's long aerial descent, heavy crater landing, and portrait dialogue before combat authority and a louder fantasy/JRPG orchestral loop begin. He cannot pursue King before awakening; afterward his movement and jump target bounds cover the full traversable map, so retreating down the approach does not create a safe leash. Varkuun has a lunge, overhead slap, target-marked jump, and buried-hand root execution. Jump pressure grows with current health loss: 80-100% uses one normal jump, below 80% alternates two then three, and 30% or lower cycles three, four, then five rapid jumps. Every marker commits before takeoff, so prediction and lateral cutoff pressure change dodge decisions without silently tracking afterward. The final landing returns to King's current position; mid-health chains finish at 120% ordinary jump damage, while low-health chains finish at 150% with faster root warning/tracking. Prison follows only after the last jump and its recovery starts the tier cooldown. A centered named boss HUD exposes exact health, delayed damage, threshold marks, and Phase I/II/III at the same 80/30 boundaries. Execution still requires Dash avoidance or five struggle presses followed by leaving the 34-pixel core before delayed 300 damage. At 30% health or lower, remaining at least 190 pixels away for 0.55 seconds lets a ready jump cooldown bypass the prior-melee requirement, so permanent long-range kiting cannot switch off Phase III. Varkuun's 30 armor reduces incoming damage by about 23%. Defeat now leads through the final quote, collapse, milestone chest, and return route; only the later narrative handoff remains open.

Two post-kit power tiers are now reserved but mechanically unauthored. **Ultimate** is a future high-power ability tier. **Reality Breaking** is a separate, stronger finisher tier beyond Ultimate; it is not another name for Ultimate and should own a distinctly climactic final animation when eventually designed. The character menu shows both as locked previews only. Neither tier currently has an input, ability definition, cooldown, damage rule, animation, unlock condition, or save state.

The production runtime player is **King**, presented as a **Mortal Riftsword**. `Player` remains the technical gameplay role so future characters can reuse movement, health, encounter, and input boundaries without duplicating authority. No roster selector is currently implemented or promised.

King establishes the character-owned combat direction with a compact simple hard-pixel body and one fixed short broad signature sword. His locomotion, first slash, and Echoing Sever Skill 1 combat proof are active; the real tap/hold chain, final Skill 1 body/VFX sheets, Skills 2-4, cinematic presentation, dedicated reactions, and per-character save record remain planned. Equipment currently reuses weapon stats while hiding the detached weapon art; the intended essence/relic migration will modify stats/traits without replacing King's visible signature sword. Roster switching remains unimplemented and belongs in Sanctuary or another safe preparation space.

The owner rejected the former detailed King motion package despite individual frame quality because identity, weapon, and pose continuity became unreliable. It is archive-only. Decision 075 still uses purposeful action-owned exact-grid sheets, while Decision 076 constrains the replacement body to simple repeatable shapes and moves spectacle into rigid weapon/VFX layers.

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

King's death with his family and isekai awakening establish the planned mortal viewpoint. Many known gods consume or prize the emotional resonance created by mortal grief, wrath, fear, hope, and defiance; their worlds and trials are both spectacle and harvest. Individual gods may still be cruel, indifferent, constrained, sympathetic, or rebellious, so the pantheon must not flatten into identical villains.

Reality was shaped by **The One Above**, an ancient primordial creator and the strongest known being. The One Above predates the known gods and remains a mystery rather than an ordinary quest-giver or automatically confirmed final villain. The lesser gods' behavior does not yet prove whether The One Above is absent, observing, imprisoned, or acting under unknown rules.

Sanctuary preserves soul-memory beyond death. King's first mysteries are why the Veil remembered him and what happened to his daughter and the rest of his family. The provisional **Hundredfold Ascent** frames a journey toward a rumored hundredth threshold without claiming one hundred implemented stages or revealing whether the gods are telling the truth. The story escalates from mortal corruption and divine servants to gods, beyond-god beings, boundless law-distorters, and a provisional far-future author-class tier while keeping every attack readable and dodgeable. `STORY_BIBLE.md` is canonical.

## Characters and Factions

- **King:** accepted future-canon protagonist; an isekai father seeking his family's souls and the divine authors of the Hundredfold Ascent. Art, gameplay, and save migration are not yet implemented.
- **Skillkeeper Eira:** implemented Sanctuary NPC who introduces the current skill-information surface.
- **Armskeeper Orren:** implemented Sanctuary lore NPC whose former ordinary weapon shop is retired; any future tempering role requires a new approved system and never sells skills.
- **Rootweaver Nema:** implemented Sanctuary grove smith whose Living Rootforge atomically binds Stage V materials into the six authored core-gear outputs.
- **The One Above:** approved primordial creator and strongest known being; exact present state remains mysterious.

No additional named gods, demons, or factions are approved. Eira and Orren retain their current bespoke sprites until a later, separately reviewed modular-NPC migration.

## Enemies and Bosses

**Planned enemy roles:** pursuer, flanker, ranged pressure, area denial, support, summoner, elite, and boss. Actual enemies should combine a small number of readable behaviors.

**Planned boss principles:**

- Multiple phases or behavioral states.
- Clear telegraphs and punish windows.
- Escalation through pattern interaction rather than unavoidable damage.
- Theme, arena, mechanics, and lore that reinforce each other.

**Implemented enemy prototype - Forsaken Thrall:** a corrupted humanoid pursuer that materializes before becoming hostile, follows obstacle paths to the player's actual footprint, and uses a six-pose directional claw scratch with anticipation, raised arm, slash, impact, follow-through, and vulnerable recovery. It has 100 prototype health and deals 18 prototype damage; values remain provisional.

The **Thornbound Warden** is the first planned named boss and a future normal-progression requirement for The Rootbound Hollow. Its arena, mechanics, art, rewards, and exact place after the current two Forgotten Grove stages remain unimplemented and require a dedicated design pass.

**Implemented Stage 1 encounter:** six sequential beginner waves introduce Mirelings, Rootlings, and then Thralls while never exceeding four live enemies. The later five-to-seven-enemy waves issue a `REINFORCEMENTS APPROACH` warning, then release one replacement at a time rather than refilling every opening after a burst kill. Clearing the finale opens the stage-exit portal. Entering its range shows `F - Enter Portal`; leaving removes the prompt. Interaction fades through a loading veil into Stage 2.

**Implemented Stage 2 encounter — Thorns of the Forgotten Grove:** the player arrives at a small grove with a central broken shrine, flanking trees, and clear paths to the north exit. The arrival message reads `THE THORNS REMEMBER YOUR FOOTSTEPS`. Seven waves build from a three-Mireling warm-up through the first Bramble Spitter, Rootling/ranged pressure, and five-to-seven-enemy mixed endurance waves. Reinforcements warn before arriving and enter singly; Decision 098 raises this stage's live crowd ceiling to six while retaining a brief opening after burst kills. Clearing all seven waves opens the forward portal into Stage 3; no exit portal exists before the clear.

**Implemented Stage 3 encounter — The Rootbound Hollow:** Stage 3 is selectable from Sanctuary once its requirements are met, or immediately through the debug F9 preset. King cuts through ten Rootlings, released at no more than four live enemies, establishing them as the Rootbound Husk's corrupted brood. After the last Rootling falls, a skippable portrait dialogue lets the angered Husk name the trespass; gameplay remains paused and the solo mini-boss wave cannot begin until the dialogue closes. The Husk opens with a quick single Root Spear, tests wider movement with a slower three-lane Root Fan whose center erupts before its warned side lanes, and uses a circular point-blank Root Burst when King crowds its body. The lane attacks lock direction at telegraph time, and the mini-boss track starts only when the gated Husk wave begins.

Every encounter spawn is announced by a short violet ground rune, inward sparks, and restrained lightning strike aligned with the enemy's non-hostile materialization. Clearing a wave provides a 2.25-second recovery window before the next wave begins.

**Encounter pacing update:** Stage 1 uses six deliberate waves totaling 30 enemies: 3 Mirelings; 3 Mirelings plus 1 Rootling; 2 Mirelings, 1 Rootling, and 2 Thralls; 2 Mirelings, 2 Rootlings, and 1 Thrall; then 6- and 7-enemy mixed endurance waves. Stage 2 uses seven waves totaling 32 enemies: it teaches the three-Mireling warm-up, Spitter pressure, and Rootling/ranged pressure before escalating through four mixed groups and a seven-enemy finale. Stage I and III retain a four-enemy live ceiling. Stage II now permits six, so its later groups produce controlled horde pressure; its seven-enemy finale still queues the final replacement after a short roughly 0.8-second gap. Every arrival uses the existing summon effect. Difficulty comes from learned-role combinations and bounded crowd pressure rather than health inflation or an uncontrolled opening horde.

**Mireling:** a small corrupted divine slime with 30 health and one compact remodeled presentation. Its 18-pixel-tall body uses directional idle, four-frame hopping, four-frame body-slam, and four-frame collapse animations through `AnimatedSprite2D`; wider `48x32` action cells preserve spread poses without changing body scale. Within 105 pixels and clear line-of-sight it snapshots the player's position, shows a 0.65-second landing marker, leaps there over 0.42 seconds, deals 8 damage only on landing, then remains vulnerable for 1 second. Moving or dashing away from the snapshot avoids the hit.

**Rootling:** the implemented cute Stage 1 forest mob has 35 health, moves at 52 px/s, and deals 10 damage. It chases normally, then anchors for 0.58 seconds while a small crack grows in its locked forward direction. A narrow 40x16 root jab erupts for 0.12 seconds before 0.82 seconds of recovery. Stepping or dashing sideways after the crack avoids it; moving around it cannot rotate its lane. Its four-direction walk, anchor/hurt/defeat responses, and separate crack/eruption VFX make its threat legible without making it boss-sized.

**Rootbound Husk:** implemented as Stage 3's solo 280-health Boss-tier mini-boss. Its active form is a broad corrupted stump guardian with a compact broken-branch crown, bark-plated shoulders, moss-draped torso, bright lime core, heavy separated root legs, and long vine claws. It anchors itself for either a quick Root Spear or a slower three-lane Root Fan. The fan locks all directions at telegraph time, erupts the center first, then its warned side lanes. If King crowds its body within 34 pixels, the Husk uses a circular Root Burst, making overlap unsafe while leaving time to dash or step out. Its Boss control resistance rejects player knockback/stun, and Stage III navigation gives its 16-pixel body 20-pixel clearance around the central seal. Separate body animation and ground VFX observe the attack phases; the damage-revealed bar remains above its crown.

**Bramble Spitter:** a weak forest-corrupted ranged creature with 40 health. It seeks a 95-190 pixel firing band, faces the player while backing away, and uses a three-frame charge/compression/spit sequence. A pulsing red ground marker snapshots the player's position for 0.75 seconds instead of presenting the attack as a laser. It then recoils while firing one bright, trailed 12-damage seed that terminates at the marked position. Seeds burst visibly on impact and the Spitter recovers for 1.25 seconds. Leaving the marker avoids the hit. It is officially introduced in Stage 2 Wave 2 alongside one Mireling.

Standard enemies keep their health bars hidden at full health. Taking damage reveals a compact world-space bar for 2.2 seconds; further hits refresh that window, and death hides it immediately. This preserves exploration readability while still communicating combat progress.

## Weapons

**Approved destination:** visible weapons and fighting styles belong to playable characters. Equippable Weapon Essences and other relic slots alter stats, traits, and supported presentation accents without replacing a character's signature world weapon. Stable data must still distinguish reach, timing, mobility, risk, resource use, and synergy—not only damage.

**Migration status:** old version-1 weapon records restore safely to King's default signature sword. Retired physical weapon/shop content is archive-only and must not return to active catalogs without a new approved migration.

**Planned:** data-driven weapon definitions with composable attack behaviors. Weapons should differ in reach, timing, mobility, risk, resource use, and synergy—not only damage.

**Implemented active weapon - King's Sword:** King now loads a character-owned `King's Sword` definition and one-item signature catalog instead of Opaw's inventory. The sword is drawn inside King's body/action frames, so its data explicitly uses integrated presentation without requiring fake detached world art. It retains 25 skill power, 48 knockback, and 0.11/0.08/0.21 phase timing while each normal swing rolls 10, 11, or 12 damage. Its authoritative contact is 48 pixels forward and 56 pixels wide.

**Implemented weapon-family foundation:** King's signature sword selects his dedicated presentation. Player-facing equipment copy calls `basic_damage_minimum/maximum` a **Basic Hit** range and calls `WeaponDefinition.damage` **Skill Power**: the latter is inserted into all four equipped skill formulas and is not itself final skill damage. Varkuun Edge raises Basic Hit from 10-12 to 16-20, Skill Power from 25 to 38, and adds 8% critical chance at 150% critical damage while preserving King's 0.59-second attack cycle, reach, art, and knockback. A critical roll is shared by every target accepted by one basic swing or skill strike; gold `CRIT` feedback identifies the result. A character-authored integrated weapon may omit detached world art explicitly. A genuinely different family supplies its own reviewed contact shape and style through `WeaponDefinition`; visual arc or trail changes never change hitbox reach or damage by themselves.

**Implemented weapon inventory:** King owns and equips his signature sword. Version-1 saves gain King's missing default during restore. Stage V gear ownership, equipping, aggregation, and persistence are implemented; selling remains unimplemented.

Equipment must reinforce decisions across normal attack, dash, and active skills rather than replace skills with larger numbers. Decision 121 fixes the first slot identities: Weapon owns Basic Hit, Skill Power, critical chance, and later unique effects; Head favors regeneration plus moderate health; Plate is the main armor slot; Gloves own basic-attack speed; Leggings are the main health slot; Boots own movement speed. Higher-grade items may mix secondary stats without erasing those primary identities. The implemented Stage V set is Old Bark Helm +50 health/+2 health per second, Heartwood Plate +30 armor, Rootfiber Gloves +15% basic-attack speed, Mirebound Leggings +90 health, and Mirehide Boots +15% movement speed. Attack speed, movement speed, and critical chance are capped at 50%, 35%, and 50% respectively. Stages VI-VII introduce accessory components/blueprints, Stage VIII opens standard accessories, and Stage X opens relic/signature crafting. A possible Stage XV lifesteal weapon remains a future unique effect; lifesteal, mana, magic resistance, status, and loot bonuses are not implemented. Higher ranks require stronger authored enemies, elites, and bosses rather than a stage-entry gear lock.

**Approved Stage VI progression boundary:** Stage VI must not check for Varkuun Edge or any armor before entry. Players may attempt it with starter equipment, but the new campaign roster should retire Mirelings and Rootlings from forward progression and use substantially tougher, harder-hitting authored enemies so starter-gear clears take longer and carry more danger. Mirelings and Rootlings remain valid in Stages I-V and future replay content. Varkuun Edge is intended to remain useful through roughly Stage XV, where a genuinely stronger replacement may begin; exact Stage VI encounters and health/damage targets still require their own content contract and playtest.

Future characters may own spears, dual swords, greatswords, axes, scythes, ranged weapons, supernatural weapons, or unarmed styles. Each character/family must author an appropriate attack chain, contact shapes, grips, timing, and presentation rather than inheriting Balanced Slash or merely reskinning King. Pets remain a separate future companion-system decision.

## Skills and Powers

**Planned categories:** divine powers, demonic powers, weapon skills, mobility tools, defensive tools, and passive modifiers.


The starting character has no divine or demonic ability. Supernatural powers should arrive through later story or progression so the early player remains weak and their eventual growth remains meaningful.

The relationship between divine and demonic power may involve affinity, corruption, mutual exclusivity, or build synergy. This requires an explicit design decision before implementation.

**Approved cinematic direction:** every character may eventually own a spectacular ultimate with in-engine screen cracks, black-frame cuts, letterboxing, camera choreography, color changes, and reality-distortion effects. Gameplay resources/components still own cast state, damage, targets, invulnerability, movement, and cancellation; `AnimatedSprite2D`, effect atlases, `AnimationPlayer`, camera, audio, and CanvasLayer overlays observe those events and must cleanly release on finish, cancel, defeat, pause, or transition.

**King kit:** `Echoing Sever` is the implemented smooth directional-wedge Skill 1 on key `1`, and `Riftbreak` is the immediate 84-pixel 150% self-AOE Skill 2 on key `2`. `Sovereign Pursuit` is the implemented Skill 3: pressing `3` opens a ground-point reticle up to 220 pixels; pointer/right stick aims, left-click/right-trigger confirms, and right-click/`Esc` cancels. King is invulnerable only during the 0.28-second collision-safe traversal; launch and recovery remain vulnerable. Landing resolves one 52-pixel radial contact for 125% weapon damage and outward knockback. Its approved jump body passes through a separate open-center white-blue power sheath during travel, while muted takeoff dust, centered landing contact plus a brief shockwave, thrown earth chunks, and the fading crater remain world-grounded. Both Pursuit's crater and Riftbreak's residual fracture stay fixed in world space when King moves. Separate non-tonal launch/landing audio completes the sequence. The shared 0.8-second latest-intent buffer permits an immediate `3 -> 2` input sequence, but grants no character-specific combo bonus, timer, or cooldown reset. Skill 4 is the implemented long-cooldown culmination: `4` opens a 260-pixel ground reticle, then a giant spiritual sword forms and crashes for 220% weapon damage inside 58 pixels. The embedded blade resists, drives deeper automatically after 0.4 seconds, and detonates a 104-pixel 300% AOE; center targets can receive both hits. King remains committed and vulnerable, the first hit does not knock targets out of the second, and the final explosion owns the heavy outward knockback. No transformation, second button press, cinematic overlay, or ordinary lava is part of this proof.

## Progression and Economy

**Implemented introductory foundation:** this project uses a small authored progression arc rather than an endless run-based or advertisement-style upgrade loop. A run starts at level 1 and caps at level 10. XP thresholds are cumulative: 0, 150, 400, 750, 1200, 1750, 2400, 3150, 4000, and 4950. Each new level costs 100 XP more than the previous step. Stage I's authored 304 XP ends at Level 2; cumulative Stage II completion reaches 692 XP and Level 3; Stage III raises the complete implemented forest arc to 872 XP and Level 4. Mirelings award 8 XP and 1 coin; Rootlings award 9 XP and 1 coin; Forsaken Thralls award 15 XP and 3 coins; Bramble Spitters award 20 XP and 5 coins; Rootbound Husk awards 90 XP and 16 coins. The HUD displays level, current XP progress, and coins.

This run state survives scene transitions and is captured at authored safe points: Sanctuary entry, equipment changes, and stage clears. Continue restores the last safe snapshot in Sanctuary and then applies Sanctuary's full-health recovery; it does not resume an unfinished encounter. Reaching a level increases King's maximum health by 12 and produces the brief overhead level-up presentation. Story, materials, recipes, coins, level, XP, current health, and equipped gear persist through the versioned profile.

Debug builds provide F9 to set the current run to level 10 and 999 coins, enable session-only unlimited skill cooldowns, expose King's complete authored test loadout, grant authored gear, and raise every authored material to the supported maximum. The Bag abbreviates these debug quantities as `MAX` while its tooltip retains the exact value. F9 clears cooldowns but never skips targeting or active/recovery commitment. It does not mark a stage claim or earned material reward complete, does not alter normal balance resources, and suppresses disk saving for that debug session.

Debug builds also expose a session-only Admin Mode on F10. While enabled, Sanctuary shows a Combat Lab entrance and F7 opens it. The lab is development tooling rather than a player progression mode: it uses real current enemy actors and King combat, but supports controlled x1/x4/x8 spawning, AI pause, invincibility, test skills, clearing, and resetting. Lab enemies have reward authority removed before activation, so they cannot grant XP, coins, materials, story progress, stage claims, or saves.

The approved control budget is contextual left-click selection/attack, contextual right-click movement/engagement, four active skill slots on keys `1`-`4`, an unnumbered HUD/controller Attack fallback, and dash. Any world left click stops right-click movement and optional automation; single-clicking an enemy hurtbox/foot circle selects, double-clicking engages, and empty-ground clicks perform directional air swings. One centered lower tray exposes dash, four fixed `52x48` icon-first Skill controls, then compact Attack at the far right; native GUI consumption prevents HUD clicks from becoming world commands. Eira presents King's four equipped skills without an awakening transaction. The larger top-left vitality panel is prioritized over decoration, and a top-right `MENU [ESC]` button mirrors Escape. Physical Tab or the visible satchel opens Character & Bag with King equipment, sortable inventory, materials, and Active Skills. Stage V armor has live equip/stat/persistence authority; accessory positions remain future placeholders. Skills are never purchased.

**Future divine-weapon direction:** a formally declared God may eventually reject damage from ordinary mortal weapons, including ordinary crafted weapons. A weapon must carry an authoritative Divine category to harm that target. Divine does not imply non-craftable—a later design may allow divine recipes—but god classification, immunity feedback, acquisition timing, anti-softlock guarantees, balance, and save migration must be designed before this rule receives runtime authority. Current enemies and Varkuun do not use it.

**Implemented Forest reward acquisition:** the stable current material set is Mire Resin/Mire Membrane from Mirelings, Root Fiber/Young Heartwood from Rootlings, Forsaken Cloth/Weathered Fittings from Thralls, Barbed Seed/Thorn Sap from Bramble Spitters, and Husk Heartwood/Rootbound Core from the Rootbound Husk. Each has a distinct 24x24 icon. Ordinary common materials are sparse rewards with sixth-attempt protection; secondary materials use twelfth-attempt protection. Enemy deaths resolve entries through one reward authority. A resolved stack hops and hovers at the death point before flying automatically to King; early contact also collects it and a compact HUD toast confirms the grant. The Rootbound Husk always supplies both Husk Heartwood and Rootbound Core.

Stages I-II have no clear chest: completing their final wave commits the collected expedition materials, opens the portal, and then records the stage-clear autosave. Stage III's mini-boss Rootbound Reliquary grants guaranteed ordinary pooled materials but no recipe or crafting-category unlock. Stage V's major-boss Varkuun's Chest uses a larger dead-root/iron silhouette and spawns where he falls. First clear grants two Varkuun Cores plus the permanent Forest core-gear seal/discovery; replay grants one Varkuun Core and never repeats the seal. Claiming commits the expedition delta, releases the footprint, records completion, and opens the Sanctuary portal. Death, restart, or Return to Sanctuary before ordinary-stage clear or milestone-chest claim restores the expedition's starting material/recipe/claim state.

**Implemented Rootweaver crafting service:** Rootweaver Nema is the Sanctuary's grove smith; Orren remains dialogue-only. Her Living Rootforge crafts six finalized Stage V recipes—Varkuun Edge, Old Bark Helm, Heartwood Plate, Rootfiber Gloves, Mirebound Leggings, and Mirehide Boots—after the category discovery, permanent seal, and every exact ingredient are present. One transaction reserves the unique output, spends the complete material batch, grants through the existing weapon/gear authority, and commits the Sanctuary safe point; failure restores the prior snapshots. Two planned Stage VIII accessory recipes remain sealed previews. F9 remains a non-saving ownership/material test preset.

Forest recipes should create useful but bounded hide, fiber, cloth, plate, spirit, fungal, and core equipment within purposeful clears, with boss-specific guarantees for signature crafts. Progress must not depend on blind low-chance farming or a hard stat wall. Later regions reuse only the technical material grammar and selected universal components; their names, ecology, mechanics, and visuals must be genuinely new rather than copied Forest terminology or `Leather+`/`Leather++`. Regional level bands and a bounded Mastery layer may preserve replay value after a region's ordinary level curve, but infinite raw-stat scaling is rejected.

Open decisions include Riftbreak's optional heavy feedback tuning, first crafted essence/relic stats and final recipe balance, Hunt modifiers, selling policy beyond the current no-selling slice, and how defensive relics scale without erasing combat mastery.

Progression must preserve skill-based combat. Numerical growth should not erase the need to dodge, read attacks, and position well.

## Exploration

Exploration should reveal lore, resources, optional challenges, shortcuts, secrets, and alternative encounters. Map topology and procedural-versus-authored content are undecided.

## Visual and Environment Direction

The world uses simple, clean retro pixel art with strong silhouettes, limited palettes, and consistent pixel density. Gameplay readability takes priority over decorative detail or realism.

Environment art is part of gameplay design. Trees, bushes, rocks, buildings, walls, statues, and other large props should clarify navigation and combat space while supporting collision, cover/occlusion, interaction, or navigation behavior where appropriate.

Large props must communicate depth correctly. A player walking behind a tree canopy may become partially or fully obscured while remaining visually in front of the lower trunk when spatially appropriate. Shadows, foreground pieces, and occluding pieces should reinforce spatial relationships without hiding hazards unfairly.

Tile-based environments should support reusable terrain transitions, ground variation, decorative overlays, collision, and navigation instead of being authored for only one location. Trees may retain organic asymmetry, but shrines, statues, gates, and other landmarks must explain a route, threshold, plaza, arena, or encounter beat rather than read as random decoration.

**Implemented forest environment revision:** Stage I and II share an organized sixteen-tile bright-forest atlas covering grass variation, paths, clearing blends, and shrine stone. Stage I authors a processional route into a paired shrine court; Stage II authors a split route around one Broken Heart landmark. Stage III combines that living forest source with a sixteen-tile Rootbound palette for bruised grass, root-stained approaches, ritual stone, violet veins, restrained lime fissures, and a quiet arena center. Corruption occupies 43.75% of the complete map, concentrated around the dedicated Rootbound seal and boss arena, while mossy dirt and root-scarred forest tiles soften its spread into the greener approach. The layered limited-palette ancient tree remains reusable and uses subtle intermittent sway.

King's production direction-row sheets provide compact locomotion and authored sword actions with a stable y=30 foot baseline. Larger action cells preserve body scale while providing reach and VFX space; authoritative wind-up, contact, and recovery remain data/component-owned. The Thrall scratch uses anticipation, raised arm, slash, impact, follow-through, and recovery on its six-frame 64x48 canvas.

Tree depth is intentionally split into base and canopy while the prop participates in actor Y-sorting. The player can appear behind the tree when north of its footprint and in front when south of it; canopy motion never changes collision or navigation.

The active Stage I level spans 30x18 baked ground cells, while Stages II and III use 24x14 baked layouts. A pixel-stable camera follows the player through open combat clearings and landmark corridors. Ground cells are authored and saved in their scenes from reusable layout resources; runtime no longer rolls weighted random variants. Trees can remain organic edge structure, while statues and seals are deliberately paired, centered, or used as arena boundaries.

Animation must remain readable at gameplay speed. Strong anticipation, action, and recovery poses matter more than additional frames or surface detail.

## Replayability

Completed Forest stages remain selectable. Their replays are planned as authored Hunts with a named stage, one clear objective/modifier, previewed reward families, and optional mastery goals. First clears own story/tutorial beats; Hunts own repeatable material acquisition and advanced tests. Build variety, elite variants, optional bosses, branching routes, and regional Mastery may expand this structure, but no daily loot-box treadmill, infinite raw-stat curve, or fully procedural roguelite loop is approved.

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
