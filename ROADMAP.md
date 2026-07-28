# Roadmap

This roadmap records status, not promises or fixed dates. Move items only when their acceptance criteria are satisfied.

## Completed

- Completed Forest production Segment 1: one versioned JSON autosave under `user://`, validated temporary writes, rotating backup and corrupt-primary recovery, safe Sanctuary/stage-clear/service checkpoints, title-screen Continue, guarded New Journey replacement, isolated headless persistence tests, and Sanctuary-only resume without scene-tree serialization.
- **Design lock only:** approved the replayable Forest Stages 1-10 Fight -> Loot -> Craft -> Build -> Master -> Advance loop, ecology-linked drop direction, deterministic recipes, stage-clear chests, a separate Rootweaver/Grove Artificer service, Hunts, the Stage 4-10 enemy/material matrix, reusable cross-region material art grammar, and bounded regional Mastery. Loot/crafting runtime implementation has not started.
- Slowed early progression and economy pacing: cumulative Level 1-10 thresholds are now `0/150/400/750/1200/1750/2400/3150/4000/4950`, placing Stage I at Level 2, cumulative Stage II at Level 3, and the complete current forest arc at Level 4; Iron Sword now costs 90 coins instead of 18.
- Tightened the beginner-sword feel and reduced clustered-hit overhead: Balanced Slash is now a 58-reach by 96-wide data-owned fan with matching smaller trail, future weapon families retain independent shape/style ownership, the center-screen level banner is replaced by a small Opaw glow and overhead label, and normal cleaves share one 25-millisecond hitstop/camera/audio response per swing while keeping feedback on every enemy.
- Aligned combat footprints and run attrition: Balanced Slash covers its visible side edges/tip; Stage III bakes 20-pixel seal clearance for the 16-pixel-radius Husk; dash has a clear gap before Skill 1; current HP survives stage/Sanctuary transitions; Opaw uses `140 + 12/level` health plus delayed 1 HP/s regeneration; and Mireling/Rootling/Thrall/Spitter/Husk damage is balanced to 8/10/18/12/18.
- Rebuilt the combat/Skillkeeper presentation as compact bounded controls: one five-action `52x48` HUD tray, `MENU [ESC]`, four `128x68` Active Skills selectors, one full detail panel, and current vitality in the character header. Added level-up world/HUD effects plus an original chime, implemented Opaw's data-owned vitality foundation, moved Balanced Slash contact into weapon data with matching white-blue reach presentation, corrected/raised the sword grip, and widened active skills to 128x40/128x44 without raising skill damage.
- Completed the pre-Stage-IV progression/control pass: established increasing ten-level XP costs, added Eira's free session-persistent Consecutive Thrust awakening, made Skill 2 fully invulnerable and dash-cancelable, replaced implicit weapon-card equipping with explicit safe Equip actions, prevented HUD clicks from leaking into basic attack, added a visible clickable dash cooldown and top-right Options button, enlarged vitality readability, and split the Husk attack cue into woody telegraph plus root/earth eruption layers.
- Refactored The Rootbound Hollow from a fully wicked ground treatment into a readable dying-forest transition: 43.75% Rootbound corruption owns the arena and spreading tendrils, while 56.25% living grass, mossy dirt, and root-scarred blends preserve the forest identity around the approach.
- Replaced the shared four-tile seeded-random combat ground with an authored forest environment foundation: organized 16-tile shared and Rootbound Hollow TileSets, diffable per-stage layout resources, baked editable TileMap cells, deliberate Stage I/II paths and shrine landmarks, a corrupted Stage III ritual arena, blighted edge trees, and a colliding/navigation-aware Rootbound arena seal.
- Connected the implemented forest arc continuously: Stage 1 clears into Stage 2, Stage 2's clear portal advances into The Rootbound Hollow, and Stage 3's post-mini-boss portal returns to Sanctuary.
- Renamed Stage 3 to `The Rootbound Hollow`, clarified Sanctuary labels as Stage I-IV, and made Stage III's mini-boss identity explicit. Its approach now consists of ten Rootlings released through the unchanged four-enemy cap, followed by a pause-safe skippable Rootbound Husk portrait dialogue and gated solo mini-boss reveal.
- Added a reusable 96x96 transparent enemy portrait family for Rootling, Rootbound Husk, Mireling, Forsaken Thrall, and Bramble Spitter; `DialoguePanel` accepts portraits without requiring them for ordinary NPC conversations.
- Refactored Rootbound Husk's attacks into a dedicated data profile: a quick single Root Spear, a slower three-lane Root Fan whose center erupts before its sides, a telegraphed point-blank Root Burst that closes the former overlap safe zone, and a readable below-half-health cadence increase. Its current focused tune uses 280 health and 18 damage without changing the four-enemy cap; controller-owned hitboxes remain authoritative while attack events own VFX and layered root audio.
- Replaced Rootbound Husk's unstable original body with a broad stump-guardian redesign across fixed-scale `72x64` contact/passing walk, `64x64` reaction/defeat, and a final-model `96x64` v4 six-stage root-attack sheet. Side walking exchanges foreground/background leg positions with opposite arm swing, complete up-facing crowns and root-command poses are recovered from bounded connected source overlap, and the processor derives every right-facing walk/root-attack/reaction frame by exact mirroring. The editor exposes exactly 28 active body animations under `root_attack_*` names; every former cast-named asset, animation, import cache, and retired Husk package is permanently deleted. Existing six-beat ground crack/root-spear/collapse VFX and gameplay authority remain unchanged.
- Added Stage 3's direct Sanctuary route and first solo Rootbound Husk mini-boss. Its Boss-tier rooted spear/fan/burst foundation and CC0 mini-boss track are active, while the four-enemy cap remains unchanged.
- Rebuilt Mireling around one approved smaller model: 18-pixel-body directional idle/hop frames plus fixed-scale four-frame body-slam and collapse sequences in wider `48x32` action cells. Its external `SpriteFrames` now exposes exactly 16 coherent animations, while the legacy model sheets and sources are permanently removed without changing leap authority.
- Added a 0.85-second dash availability cooldown that starts with each evade and remains independent from the vulnerable recovery phase, preventing continuous invulnerable dash chaining while preserving attack-cancel responsiveness.
- Added Rootling as the compact Stage 1 forest mob: independent directional walk/reaction/root-jab art, a direction-locked narrow ground-jab controller, reward/health/audio integration, and focused regression coverage. Stage 1 now teaches it beside familiar Mirelings before mixing in Thralls.
- Tuned expedition reinforcements without raising the four-enemy active cap: Stage 1 retains six waves and 30 total melee/leap/root-jab enemies, while Stage 2 retains seven waves and 32 total enemies. Each queued replacement now gives a visible warning and arrives singly, preserving the payoff of clearing several enemies at once rather than refilling a horde.
- Cleaned the Opaw runtime asset boundary: the approved compact-armless action set and intentional Wayfarer rollback remain visible, while unused duplicate sheets and rejected Consecutive Thrust source boards are archived outside Godot imports.
- Added the shared in-stage pause menu with safe pause ownership, shared Music/SFX/UI toggles, Sanctuary return that preserves the current run, quit control, and focused smoke coverage.
- Locked Piercing Rush's visible and authoritative pivot to its snapshotted cast direction, so movement input cannot turn an in-flight thrust into a side/back hit; coalesced shared impact presentation for same-frame multi-target contacts.
- Documentation, Godot 4.7 project foundation, pixel-stable viewport, and automated smoke-test workflow.
- Composed player movement, aiming, sword combat, supernatural dash, health, defeat, and restart flow.
- Data-driven Thrall, Mireling, Rootling, and Bramble Spitter enemies with readable attacks, navigation, obstacle handling, and crowd separation.
- Bright modular terrain, layered tree/statue props, Y-sort occlusion, collision, and runtime-baked navigation.
- Expanded Stage 1 with three waves, navigation-safe spawning, summon effects, wave pacing, and direction indicators.
- Reusable portal interaction, fade transition service, Stage 2 structural placeholder, and return portal.
- Compact combat HUD plus reusable damage-triggered enemy health bars.
- Reusable ability/cooldown and knockback contracts with the grounded Q Sweeping Cut and compact HUD slot.
- Authored Stage 2 `Thorns of the Forgotten Grove`, including arrival lore, navigation, two introductory waves, delayed Bramble Spitter reveal, and clear-gated return portal.
- Session-only level-10 progression foundation: reusable XP/coin rewards, visible HUD progress, and data-driven enemy reward values without random upgrade interruptions.
- In-memory run continuity across portal transitions, defeat-reset semantics, a centered four-slot 1-4 skill bar, and a paused Tab character/skill information menu.
- Cross-scene ambient-music foundation with a dedicated Music bus, stage routing, attribution, and headless-safe regression coverage.
- Reusable combat-impact feedback: accepted-hit damage numbers, pixel bursts, restrained camera nudges, and automatic cleanup.
- Confirmed-hit feel pass with reusable white enemy flashes, short non-stacking hitstop, and light Ashwood Blade knockback while preserving stronger Sweeping Cut spacing.
- Event-driven combat SFX for sword, Sweeping Cut, dash, player damage, current enemy attacks, and Bramble projectile impacts, with Music/SFX/UI bus separation.
- Regression coverage for player combat, enemies, crowd behavior, navigation, encounters, portals, transitions, and defeat.
- Visual asset foundation: documented art direction, canonical asset catalog, naming/lifecycle rules, and replaceable-background contract.
- Controlled Awakened asset migration: canonical runtime names/folder plus preserved Godot-ignored source and intermediate art.
- Controlled Forsaken Thrall asset migration: canonical enemy runtime names/folder plus preserved source and intermediate art.
- Controlled Mireling asset migration: canonical 32x32 locomotion, 48x32 action cells, one external `SpriteFrames` resource, and only the approved remodeled generation material.
- Completed current character-art migration with canonical Bramble Spitter runtime art and preserved generation material.
- Added the reusable Godot base theme, ten named hard-pixel UI icons, themed HUD/menu presentation, and icon-bearing contextual portal and character-menu entry points.
- Added the layered Battle of Gods title screen, deterministic replaceable forest/Sanctuary background, focus-safe navigation, functional session-audio settings, and fade-driven new-journey entry.
- Rebuilt the playable Sanctuary around a generated-and-normalized eleven-asset runtime kit, dedicated grass/pavement tiles, a depth-correct split angel portal, separate fountain, Skillkeeper Eira, Armskeeper Orren, expedition selection, title arrival, and Stage 2 return flow.
- Corrected Sanctuary crop integrity through full NPC limb/held-prop silhouettes and neighbor-fragment isolation, connected side-building pavement, replaced the solid portal blocker with bilateral fountain routes and a walk-in doorway threshold, added mouse/Escape modal controls, and made ambient music pause-safe and continuously looping.
- Added reusable context-gated editor preview ground to isolated Sanctuary props and NPCs without affecting composed maps or runtime presentation.
- Converted Sanctuary house footprints from fixed rectangle resources to independently editable collision polygons while preserving their validated blocking bounds.
- Replaced the combined Sanctuary portal/fountain crop with independent runtime landmarks, a physically verified walk-around-to-staircase route, a complete standalone Orren sprite, and reusable collision-safe NPC breathing.
- Removed the superseded first-round code-drawn Sanctuary scenes, sprites, imports, and obsolete generator after confirming the generated runtime kit owns every active reference.
- Replaced duplicated skill-slot UI with one data-driven four-slot loadout plus reusable HUD/card scenes, and corrected the transparent transition overlay so mouse, arrow/Enter, Escape, and gamepad-ready menu controls coexist.
- Added the read-only equipment vertical slice: a two-page Gear/Armory and Active Skills character surface, five future equipment slots, animated Awakened preview, reusable item/slot/detail scenes, and four original A-to-Mythic weapon concepts with clearly inactive skill-synergy identities.
- Corrected the character-menu action from an accidental Backspace binding to physical Tab, moved its global open shortcut ahead of GUI focus consumption, and added a visible clickable HUD satchel button in Sanctuary and both expeditions.
- Named the active mortal player Opaw, replaced the active Awakened presentation with a reusable 32x32 modular four-direction body, and added a phase-driven visible Ashwood Blade without moving damage authority out of the existing hitbox.
- Reframed the armory's active beginning around the Wood-rank Ashwood Blade; the later two-sword implementation superseded the provisional Stonebound step while preserving former high-tier concepts as inactive legacy material.
- Activated the first owned-weapon slice: Ashwood is Opaw's permanent fallback, Orren sells an 18-coin Warrior-only Iron Sword, the character inventory equips owned compatible swords, and shared body/style animation remains reusable across both grades.
- Corrected Opaw's reversed side-facing source mapping, removed the shrinking attack pose, added data-driven weapon grip/scale/radius metadata, and rebuilt normal attacks around a hand pivot with a readable active swing trail and NPC-facing interaction pose.
- Replaced Opaw's single mixed-pose atlas with independently authored directional idle, four-frame walk, three-pose weaponless attack, three-frame dash, interaction, hurt, and four-stage defeat sheets; normalized every reference pose to one 18x27 scale and retained the external equipment rig.
- Replaced fixed source-grid trimming with connected-silhouette isolation, restoring complete up-facing heads and correcting the squashed right dash; lowered the Ashwood grip to Opaw's arm and rebuilt side attacks as mirrored hand-centered arcs with sharper strike feedback.
- Replaced the playable presentation with a complete compact armless Opaw action set inspired only by broad top-down readability cues, preserved Opaw's original identity and gameplay scale, widened the detached Ashwood Blade orbit, and archived the complete previous Wayfarer model as an independently loadable backup.
- Raised the down-facing Ashwood Blade beside Opaw's torso and replaced hard-coded sword motion with reusable Balanced Slash, Swift Slash, and Heavy Cleave presentation profiles; idle-only weapon-definition switching now preserves one shared body animation without activating inventory or additional items.
- Raised the front-view blade again and made each sword style carry a three-step normal-attack presentation sequence: outward sweep, reverse return, and farther-reaching visual finish, all without changing authoritative combat values.
- Rebuilt Sanctuary's skill/equipment service corner around compact Opaw-scale Eira and Orren sprites, a complete spirit-study lodge, arms workshop, and body-free weapon cart; archived superseded service art/scenes, Awakened legacy runtime files, and rejected Opaw experiments outside Godot while retaining the supported Wayfarer rollback.
- Recentered Sanctuary's portal/fountain pavement as a paired avenue, snapped both service doors to compact one-cell approaches, grounded Orren's cart on a bounded bay, and preserved garden breaks instead of expanding the route into a gray plaza.
- Established the isekai/uncaring-gods premise and future switchable character-versus-class boundary in a canonical story bible; added versioned in-memory story memory plus data-driven expedition definitions that combine level, story, boss, discovery, and key-item requirements without opening unbuilt routes.
- Replaced passive mouse-facing with movement-owned four-way combat facing, retained left mouse/right trigger for basic attack, added a safe dash-to-normal-attack buffer/recovery cancel, and added a debug-build-only F9 level-10/999-coin testing preset with HUD confirmation and run-state synchronization.
- Equipped Piercing Rush as Opaw's clickable immediate-direction Skill 1 with collision-limited cast movement, a narrow definition-owned path hitbox, 135% snapshotted weapon scaling across Ashwood/Iron, white-gold spectral thrust presentation, cooldown-safe HUD activation, and preserved unequipped Sweeping Cut content.
- Replaced Piercing Rush's provisional drawn beam with a generated six-frame effect-only atlas: charge, ignition, long lance, roughly 160-pixel peak plume, shock-ring impact, and decay now animate independently from Opaw and the equipped sword while the narrow gameplay hitbox remains unchanged.
- Aligned Piercing Rush combat and audio with its large presentation: widened the central hit lane from 44x12 to a 98x22 tapered lance, raised its multiplier to 180% and pushback to 112, and replaced the reused swing with dedicated CC0 charge, thrust, and accepted-impact streams.
- Rebuilt the debug-test Consecutive Thrust as a seven-window rapid flurry, then established reusable crowd-control tiers: Light enemies accept full push/stagger and have attacks interrupted, Elites receive 35%/45% control, and future Bosses reject it. F9 still grants every authored compatible Warrior weapon and equips every authored Warrior skill, while Skill 2 now has 18/19/20/21/22/25/100% weapon-scaled forward contacts, final-only 150 pushback, repeated stagger, approved-Opaw eight-beat body sheet, twelve-frame effect-only spirit-lance VFX, alternating thrust poses, steel-thrust/final-blade audio, and focused regression coverage. Its final effect now starts with the final sword cue and decays through three small fading frames rather than lingering as recovery slow motion; source-clip lead-ins are skipped so its sword and contact sounds begin with their actual impacts.

Detailed completion history remains in `CHANGELOG.md`.

## In Progress

- **Forest production Segment 2 - Content data:** author and validate immutable material, drop-profile, loot-table, and deterministic recipe definitions with stable IDs and reserved profile-extension ownership; do not add chest/Rootweaver presentation yet.
- **Milestone B progress:** Opaw now has a distinct generated damage-impact cue and a curated CC0 light dash swoosh. Enemy action SFX remain separate; directional threat and hit-effect work remain open.
- **Milestone A progress:** a latest-valid-input buffer carries normal attacks and immediate-directional skills across committed attacks/dashes. Consecutive Thrust now owns the approved defensive exception—full-cast invulnerability plus dash cancellation—while its damage, reach, and cooldown remain unchanged for feel testing.
- **Milestone C progress:** Rootbound Husk now uses fixed-scale generated body sheets, readable planted side steps, native named animations, a constant foot baseline, an above-head health bar, six-beat ground-root VFX, and a skippable portrait introduction behind a reusable encounter gate. Its profiled quick spear and slower staged Root Fan retain snapshotted hitbox authority and gain a faster, fan-heavier second phase. Human timing/readability review remains open.
- **Milestone A — Combat responsiveness:** feel-test the implemented attack/skill buffers, Skill 2 invulnerability and dash-cancel transition, dash cooldown visibility, and default/skill reach before further timing or range changes.
- **Milestone B — Combat feedback and audio:** distinguish incoming-player damage from each enemy attack, lower/replace the repetitive dash cue, add directional threat/near-hit readability, and tune hitstop/camera response by impact tier without obscuring telegraphs.
- **Milestone C — Rootbound Husk repair:** playtest the rebuilt walk/root-attack/hurt/defeat presentation and completed skippable introduction against its quick Root Spear, center-then-sides Root Fan, and Root Burst; tune timing only from observed evidence before adding more enemies.
- **Milestone D — Forest campaign sequence:** retain Stage 1 introduction, Stage 2 escalation, and Stage 3 mini-boss as the first forest arc. Add Save/Continue, content data, loot/chests, crafting, and Hunts before Stage 4; then build Stages 4-10 one content-contract enemy at a time against the approved role/material matrix rather than improvising isolated stages.
- Feel-test Piercing Rush's 128x40 central hit lane, roughly 50-pixel collision-limited movement, thrusting detached sword, oversized six-frame white/blue/gold plume and impact readability, 180% Ashwood/Iron scaling, dedicated charge/thrust/impact SFX, 3-second cooldown, and click/`1` activation at 960x540.
- Feel-test Consecutive Thrust's Level-3 Eira awakening, full-cast invulnerability, dash cancellation, snapshotted direction, 128x44 lane and longer guide versus oversized rapid-flurry effects, 225% total weapon damage, control resistance, final feedback, 5-second cooldown, and crowd performance at 960x540.
- Run a controller playtest of Stage 1 and Stage 2 with Ashwood and Iron; record clear time, damage taken, Piercing Rush/Consecutive Thrust use, late-wave readability, and frame stability after the one-at-a-time reinforcement pass.
- Feel-test the Ashwood Blade's wider anticipation-to-impact arc, faster committed sweep, forward extension, denser white-gold trail, 0.10-second enemy flash, and white-hot impact core.

- Decide the exact reveal of Opaw's former-life death, the first full story-act structure, and release platform priorities.
- Feel-test and tune the Ashwood Blade's timing, reach, phase-driven swing, and anchor placement.
- Feel-test dash distance, duration, recovery, and afterimage readability.
- Feel-test the Forsaken Thrall's spawn readability, obstacle approach, claw telegraph, range, damage, and recovery.
- Feel-test `140 + 12/level` vitality, cross-stage current HP, delayed 1 HP/s regeneration, and the 8/10/18/12/18 enemy damage curve through Stages I-III alongside the compact overhead glow/label/chime, current/max character header, defeat delay, and restart controls.
- Feel-test the 960x540 zoom, smaller HUD, Opaw's compact armless silhouette and stable action-owned body scale, serious eyes/scarf, tiny-foot grounding, four-frame walk, attack/dash timing, detached weapon orbit, corrected shadows/collision, canopy occlusion, and 16-pixel Thrall clearance.
- Feel-test Mireling pressure, stage counts, spawn pacing, camera travel, and landmark layout.
- Feel-test Rootling's compact silhouette, 0.58-second crack telegraph, lateral dodge window, 40x16 locked jab lane, sound level, and its expanded Stage 1/Stage 2 placement alongside the distinct Stage 3 Rootbound Husk escalation.
- Keep preserved Sweeping Cut's 20 damage, wide arc, 90 pushback, phases, and cooldown regression-safe while it remains unequipped.
- Feel-test Stage 1 and Stage 2 reinforcement pacing, clear time, recovery windows, Grove layout/navigation, Wave 1 warm-up, Wave 2 Spitter readability, clear-gated return portal, and restart behavior.
- Feel-test XP/coin pacing, HUD placement, and the forest ambient-music volume.
- Feel-test normal sword, Sweeping Cut, and incoming-damage feedback for readability and appropriate camera motion.
- Feel-test combat cue selection, positional balance, repetition, and SFX-versus-music volume.
- Feel-test the centered action tray's clear dash-to-Skill-1 gap, top-left character/satchel entry button, compact Active Skills/detail layout, and Tab character-menu readability at the 960x540 viewport.
- Design abilities and free-awakening rules for sealed slots 3-4; reserve a richer ritual treatment for later ultimate-tier awakenings.
- Feel-test Orren's 90-coin shop, explicit shop/detail Equip buttons, deferred idle-safe swapping, Ashwood/Iron portrait/world consistency, and insufficient-funds messaging.
- Decide armor bonus sources beyond the implemented flat vitality seam, mana/potion rules, selling policy, and enemy/elite/boss power bands before expanding beyond the active two-sword slice. Drop sources and the no-blind-grind crafting direction are approved by the Forest design lock; exact quantities remain future balance work.
- Feel-test the shared theme, named HUD icons, expanded skill-bar height, and portal-prompt placement at 960x540.
- Feel-test the title-screen composition, restrained background motion, focus loop, audio toggles, and title-to-Stage-1 fade.
- Feel-test Sanctuary navigation, the aligned paired avenue and compact service/cart approaches, separate fountain/portal scale and courtyard spacing, portal/water/NPC/building idle effects, both NPC interactions, expedition usability, and the transition loop on F5.
- Feel-test compact Eira/Orren readability, detached book/wisp/hammer/sword props, new service-building collision, and the skill-versus-weapons visual distinction at gameplay scale.
- Feel-test the generated expedition requirement copy, tooltip detail, disabled-state contrast, and mouse/keyboard/gamepad focus loop at 960x540.
- Decide the first disk-persistent profile/story boundary and migration policy; the current versioned story snapshot performs no file I/O.
- Reconcile the legacy Sanctuary-only Rootbound Hollow requirement preview with the implemented direct Stage 2 -> Stage 3 story route when save-backed route history and replay/Hunts are introduced; do not add a duplicate gate that blocks the continuous first-clear arc.
- Design a confirmed `Abandon Expedition / Return to Sanctuary` pause-menu action, including combat restrictions and explicit XP/coin/run consequences.
- After Opaw is visually accepted in motion, define reusable modular starter layers for future Warrior, Archer, and Mage presentations; migrate NPC bodies and environment/UI style only in separate reviewed passes.

## Planned

### Approved Forest Production Sequence

1. **Segment 1 - Save/Continue:** versioned profile, migrations, recovery, safe checkpoint writes, and Continue UX.
2. **Segment 2 - Content data:** immutable material, drop-profile, loot-table, and recipe definitions plus stable IDs and validation.
3. **Segment 3 - Loot and chests:** ecology-linked defeat rewards, guaranteed non-empty stage-clear chests, idempotent first-clear rewards, and readable reward presentation.
4. **Segment 4 - Sanctuary craft service:** introduce the separate Rootweaver/Grove Artificer, dialogue portrait, interaction scene, and craft-menu shell.
5. **Segment 5 - Forest crafting:** deterministic recipes, atomic material spending, crafted starter gear, equipment integration, and balance tests targeting two or three purposeful clears.
6. **Segment 6 - Hunts:** selectable completed-stage replays with previewed reward families, authored modifiers/objectives, and optional mastery goals.
7. **Segment 7 - Forest Stages 4-10:** build one content-contract enemy at a time against the approved role/material matrix, ending with the regional boss/signature core.
8. **Segment 8 - Stage 11 seam:** introduce the next region's real mechanics/materials and bounded regional Mastery without `Leather++`, palette-only enemies, or infinite raw-stat growth.

The detailed acceptance rules and intentionally open choices live in `docs/design/forest-loot-crafting-and-regional-material-plan.md`. Later segments do not start merely because their data type exists; each prior segment must pass focused automated validation and gameplay-scale review.

### Vertical Slice Completion

- Complete the Forest region through Stage 10 using the approved regional production sequence.
- A small but distinct crafted weapon/armor set with honest, documented stat seams.
- Divine and demonic abilities demonstrating build choice.
- Complementary enemy roles, one regional boss, and replayable Hunts.
- Audio, effects, accessibility settings, menus, Save/Continue, and checkpoint flow needed for the slice.

### Production Systems

- Scalable content authoring for weapons, abilities, enemies, bosses, and status effects.
- Material inventory, deterministic crafting, equipment aggregation, and bounded regional Mastery.
- Exploration, NPC, and quest foundations required by the authored regional structure.
- Save schema versioning and migration.
- Broader performance budgets and profiling scenes.

### Content and Polish

- Additional regions, enemies, bosses, weapons, skills, and narrative content.
- Balance, onboarding, accessibility, localization readiness, and controller polish.
- Export validation, compatibility testing, optimization, and release preparation.

## Future Ideas

- Multiplayer expansion
- Challenge modes and difficulty modifiers
- Branching routes or alternate realms
- Additional playable characters
- Community or mod-friendly data pipelines

## Technical Debt

None currently recorded.

## Next Decision Gate

The regional loop and material-reuse direction are approved. Before each implementation segment, settle only the choices that materially affect that segment:

1. Segment 2: final IDs/categories for the first Stages 1-3 materials and whether recipe discovery begins as story flags or its reserved dedicated profile extension.
2. Segment 4: the Rootweaver/Grove Artificer's final name, personality, visual contract, and Sanctuary location.
3. Segment 5: exact recipe quantities, first crafted equipment stats, selling/salvage policy, and armor aggregation.
4. Segment 6: the first Hunt modifiers, reward preview detail, and Mastery scoring.

Desktop/web/mobile priority and future Mage/Archer roster/class structure remain important broader product decisions, but they no longer block documenting or building the approved desktop-first Forest foundation.
