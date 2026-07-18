# Roadmap

This roadmap records status, not promises or fixed dates. Move items only when their acceptance criteria are satisfied.

## Completed

- Documentation, Godot 4.7 project foundation, pixel-stable viewport, and automated smoke-test workflow.
- Composed player movement, aiming, sword combat, supernatural dash, health, defeat, and restart flow.
- Data-driven Thrall, Mireling, and Bramble Spitter enemies with readable attacks, navigation, obstacle handling, and crowd separation.
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
- Controlled Mireling asset migration: canonical 32x32 runtime art, preserved generation material, and archived superseded 24x24 sheet.
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
- Reframed the armory's active beginning around one Wood-rank Ashwood Blade and an early Wood-to-Stonebound-to-Iron-to-Rare material ladder, while preserving the former A-to-Mythic concepts as inactive legacy material.
- Corrected Opaw's reversed side-facing source mapping, removed the shrinking attack pose, added data-driven weapon grip/scale/radius metadata, and rebuilt normal attacks around a hand pivot with a readable active swing trail and NPC-facing interaction pose.
- Replaced Opaw's single mixed-pose atlas with independently authored directional idle, four-frame walk, three-pose weaponless attack, three-frame dash, interaction, hurt, and four-stage defeat sheets; normalized every reference pose to one 18x27 scale and retained the external equipment rig.
- Replaced fixed source-grid trimming with connected-silhouette isolation, restoring complete up-facing heads and correcting the squashed right dash; lowered the Ashwood grip to Opaw's arm and rebuilt side attacks as mirrored hand-centered arcs with sharper strike feedback.
- Replaced the playable presentation with a complete compact armless Opaw action set inspired only by broad top-down readability cues, preserved Opaw's original identity and gameplay scale, widened the detached Ashwood Blade orbit, and archived the complete previous Wayfarer model as an independently loadable backup.
- Raised the down-facing Ashwood Blade beside Opaw's torso and replaced hard-coded sword motion with reusable Balanced Slash, Swift Slash, and Heavy Cleave presentation profiles; idle-only weapon-definition switching now preserves one shared body animation without activating inventory or additional items.
- Raised the front-view blade again and made each sword style carry a three-step normal-attack presentation sequence: outward sweep, reverse return, and farther-reaching visual finish, all without changing authoritative combat values.
- Rebuilt Sanctuary's skill/equipment service corner around compact Opaw-scale Eira and Orren sprites, a complete spirit-study lodge, arms workshop, and body-free weapon cart; archived superseded service art/scenes, Awakened legacy runtime files, and rejected Opaw experiments outside Godot while retaining the supported Wayfarer rollback.
- Recentered Sanctuary's portal/fountain pavement as a paired avenue, snapped both service doors to compact one-cell approaches, grounded Orren's cart on a bounded bay, and preserved garden breaks instead of expanding the route into a gray plaza.
- Established the isekai/uncaring-gods premise and future switchable character-versus-class boundary in a canonical story bible; added versioned in-memory story memory plus data-driven expedition definitions that combine level, story, boss, discovery, and key-item requirements without opening unbuilt routes.

Detailed completion history remains in `CHANGELOG.md`.

## In Progress

- Feel-test the Ashwood Blade's wider anticipation-to-impact arc, faster committed sweep, forward extension, denser white-gold trail, 0.10-second enemy flash, and white-hot impact core.

- Decide the exact reveal of Opaw's former-life death, the first full story-act structure, and release platform priorities.
- Feel-test and tune the Ashwood Blade's timing, reach, phase-driven swing, and anchor placement.
- Feel-test dash distance, duration, recovery, and afterimage readability.
- Feel-test the Forsaken Thrall's spawn readability, obstacle approach, claw telegraph, range, damage, and recovery.
- Feel-test vitality readability, defeat delay, and restart controls.
- Feel-test the 960x540 zoom, smaller HUD, Opaw's compact armless silhouette and stable action-owned body scale, serious eyes/scarf, tiny-foot grounding, four-frame walk, attack/dash timing, detached weapon orbit, corrected shadows/collision, canopy occlusion, and 16-pixel Thrall clearance.
- Feel-test Mireling pressure, stage counts, spawn pacing, camera travel, and landmark layout.
- Feel-test Sweeping Cut wind-up, wider arc, 20 damage, spacing pushback, recovery risk, 2.5-second cooldown, arc readability, and centered slot-1 HUD placement.
- Feel-test Stage 2 arrival pacing, grove layout/navigation, Wave 1 warm-up, Wave 2 Spitter readability, clear-gated return portal, and restart behavior.
- Feel-test XP/coin pacing, HUD placement, and the forest ambient-music volume.
- Feel-test normal sword, Sweeping Cut, and incoming-damage feedback for readability and appropriate camera motion.
- Feel-test combat cue selection, positional balance, repetition, and SFX-versus-music volume.
- Feel-test the centered four-slot skill bar, top-left character/satchel entry button, and Tab character-menu readability at the 960x540 viewport.
- Design authored skill unlock rules, coin sinks, and the first abilities for sealed slots 2-4.
- Upgrade Eira's skill service and Orren's weapon service from dialogue/read-only previews into functional menus only after skill ownership, inventory, prices, equip commands, and persistence rules are approved.
- Feel-test the 960x540 equipment layout, Opaw portrait, Ashwood world/icon consistency, Wood-rank readability, and the clarity of preview-only versus equipped states.
- Decide persistent ownership, death retention, equip commands, stat formulas, acquisition sources, and enemy/elite/boss power bands before activating equipment.
- Feel-test the shared theme, named HUD icons, expanded skill-bar height, and portal-prompt placement at 960x540.
- Feel-test the title-screen composition, restrained background motion, focus loop, audio toggles, and title-to-Stage-1 fade.
- Feel-test Sanctuary navigation, the aligned paired avenue and compact service/cart approaches, separate fountain/portal scale and courtyard spacing, portal/water/NPC/building idle effects, both NPC interactions, expedition usability, and the transition loop on F5.
- Feel-test compact Eira/Orren readability, detached book/wisp/hammer/sword props, new service-building collision, and the skill-versus-weapons visual distinction at gameplay scale.
- Feel-test the generated expedition requirement copy, tooltip detail, disabled-state contrast, and mouse/keyboard/gamepad focus loop at 960x540.
- Decide the first disk-persistent profile/story boundary and migration policy; the current versioned story snapshot performs no file I/O.
- Design the Thornbound Warden encounter and Cinder Sigil acquisition before building or enabling Ashen Pilgrimage.
- Design a confirmed `Abandon Expedition / Return to Sanctuary` pause-menu action, including combat restrictions and explicit XP/coin/run consequences.
- After Opaw is visually accepted in motion, define reusable modular starter layers for future Warrior, Archer, and Mage presentations; migrate NPC bodies and environment/UI style only in separate reviewed passes.

## Planned

### Phase 0 - Foundation

- Review release target priorities; desktop is the current development baseline.
- Validate the 640x360 pixel rendering and camera policy with the first animated character.
- Extend the validated prototype into terrain-transition and editor-authored map conventions before producing final environment assets.
- Decide initial game/run structure and player fantasy.
- Select automated test tooling when the first testable domain component is introduced.

### Phase 1 - Combat Prototype

- Reusable health, hitbox, hurtbox, and damage components.
- Combat feel pass and baseline performance measurements.

### Phase 2 - Vertical Slice

- One polished playable region/arena.
- A small but distinct weapon set.
- Divine and demonic abilities demonstrating build choice.
- Multiple complementary enemy roles.
- One multi-phase boss.
- Audio, effects, accessibility settings, menus, and save/checkpoint flow needed for the slice.

### Phase 3 - Production Systems

- Scalable content authoring for weapons, abilities, enemies, bosses, and status effects.
- Character progression, inventory, and equipment after design approval.
- Exploration, NPC, and quest foundations if required by the approved game structure.
- Save schema versioning and migration.
- Broader performance budgets and profiling scenes.

### Phase 4 - Content and Polish

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

Before creating gameplay code, approve:

1. Desktop/web/mobile release priorities.
2. First playable scope: arena survival, authored action-adventure slice, or another structure.
3. Whether Mage and Archer first arrive as distinct playable souls, Opaw class paths, or both through a later roster/class system.
4. Persistent ownership, shop/acquisition rules, and the first Stonebound equipment step after Ashwood is visually accepted.
