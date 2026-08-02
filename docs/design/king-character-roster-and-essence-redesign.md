# King, Character Roster, and Essence Redesign

## Status

Owner-directed design lock amended by Decision 072. The current Opaw build remains playable permanently while King is added as a separate roster character. This document approves the shared direction; it does not claim that King, roster switching, true combo damage, cinematic ultimates, or essence equipment are implemented. `king-sword-combat-and-skill-kit.md` owns King's current detailed combat proposal.

## Direction

Battle of Gods becomes a character-led action RPG. Every playable character owns a recognizable body, visible signature weapon or fighting style, basic-attack chain, four active skills, ultimate presentation, portrait, story, and animation set. Equipment strengthens or modifies that identity but does not replace it with an unrelated world weapon.

King is the planned narrative lead and a new playable character, not Opaw's replacement. Opaw, his current skills, presentation, progression resources, audio, and tests remain supported roster content. Only rejected or genuinely superseded experiments belong in the archive. Reusable player, combat, input, progression, loot, crafting, UI, enemy, map, and Sanctuary systems support both characters.

## King Story Foundation

- **Display name:** King. Whether this was his birth name, a title, or a name given by the Veil remains deliberately open.
- **Origin:** modern Earth or an Earth-like former world.
- **Wound:** King remembers dying with his family, including his daughter. The exact killer, sequence, and fate of each soul are fractured memories, not opening exposition.
- **Inciting mystery:** the Remembered Veil preserved him when death should have ended his story. He finds evidence that divine powers can preserve, imitate, consume, or weaponize mortal memories.
- **Goal:** climb the portal sequence to learn whether his family's souls survived and confront the beings responsible. The Sanctuary may call the route the **Hundredfold Ascent**, but “one hundred stages” is a mythic destination and production frame, not a promise that one hundred separate levels already exist.
- **Gods' motive:** many known gods crave emotional resonance. Grief, rage, fear, hope, defiance, and despair are nourishment, wagers, spectacle, or proof of power. They construct trials because a mortal who can still choose creates stronger emotion than a helpless victim.
- **Moral range:** the divine order is exploitative, but individual gods may be cruel, indifferent, constrained, sympathetic, rebellious, or victims of a greater law. The One Above remains unresolved and is not automatically the final villain.
- **Core tension:** King must use his grief without letting the gods turn him into the wrathful performance they designed.

Other playable characters are displaced souls with their own reasons to climb. They are not cosmetic skins or class mannequins.

## Character-Owned Combat Contract

A future immutable `PlayableCharacterDefinition` should own identity and authored defaults:

- stable `character_id`, display name, title, biography, portrait, and class/family tags;
- base vitality and progression definition;
- character presentation scene or `SpriteFrames` set;
- signature weapon/fighting-style presentation;
- basic attack-chain definition;
- default skill loadout and ultimate definition;
- compatible essence families and safe fallback essence.

Runtime state remains outside the resource. `Player` stays the reusable technical actor, while a future roster authority owns the selected/unlocked character IDs and character-specific snapshots.

Character identity and combat vocabulary are now intentionally close: King owns his signature weapon and attack language. Reusable systems may still share dash, damage, status, targeting, and ability components, but another playable character must not inherit King's body frames, hand anchors, combo poses, or cinematic beats by accident.

## Basic Attack and Combo Direction

Opaw's current three visual sword sweeps are not a damage combo and remain valid for Opaw. King's first combat proof adds an authoritative, data-driven tap/hold chain without changing Opaw:

1. a fast opening cut that establishes range;
2. a committed crossing cut that rapid `click-click` can buffer reliably;
3. a readable finisher with stronger impact and recovery;
4. a hold branch that converts pre-attack anticipation into one charged cleave rather than repeated light attacks.

The chain definition should own each step's wind-up, active time, recovery, buffer window, reset timeout, damage multiplier, knockback/stagger metadata, movement allowance, contact shape, and animation name. Input buffering selects the next valid step; animation never decides damage. Direction is captured when a step is accepted and remains locked through that step. A later movement input may prepare locomotion after recovery but cannot rotate a living hitbox.

Optional or “hidden” combo branches may be added later, but the game should teach their input grammar through animation, a practice surface, or skill descriptions. Secrets may reward discovery; core competence should not depend on undocumented timing.

## Signature Skills and Cinematic Ultimates

Every character may eventually own spectacular abilities, including screen cracks, black-frame cuts, letterboxing, altered color, camera choreography, freeze silhouettes, and apparent reality distortion. They follow three boundaries:

- authoritative cast state, damage windows, target snapshots, invulnerability, movement, and cancellation remain in gameplay components/resources;
- body animation, VFX, audio, camera, screen overlays, and transitions observe those events through a character presentation director;
- presentation must end deterministically on completion, cancellation, defeat, scene transition, or pause so no black overlay or camera lock survives the ability.

Use Godot-native `AnimatedSprite2D`, `AnimationPlayer`, CanvasLayer overlays, camera events, shaders, and effect atlases before considering pre-rendered video. The first proof should be a short in-engine ultimate vignette, not a long non-interactive clip. Enemy telegraphs must remain readable unless the ability has already committed both sides to an authored cinematic resolution.

## Essence and Relic Equipment

The current visible Ashwood and Iron swords are a migration-era system. The approved destination is character-owned visible weaponry plus equippable power objects:

| Loadout slot | Presentation | Primary design space |
|---|---|---|
| Weapon Essence | blade-shaped stone, soul edge, or weapon-memory relic | attack power, basic-chain trait, skill scaling |
| Body Relic | ward plate, seal, mantle token | health, defense, resistance |
| Hand Relic | bracer, gauntlet seal, grip rune | attack speed, stagger, cooldown or status interaction |
| Foot Relic | greave rune, stride charm | movement, dash, recovery, hazard resistance |
| Accessory I-II | pendant, earring, charm, ring, or divine fragment | conditional build effects and utility |

Equipping an essence changes stats and authored modifiers; it does not replace King's signature weapon sprite. A modifier may deliberately change aura, trail color, runes, or a named technique when the character definition supports it, but there must be one clear presentation owner.

Existing items should migrate rather than silently disappear. Provisional mappings are `Ashwood Blade` -> `Ashwood Edge Essence` and `Iron Sword` -> `Iron Edge Essence`, retaining stable ownership through explicit save migration or aliasing. Final names, values, and icons require an equipment-content pass before crafting is enabled.

The Forest milestone cadence remains useful:

- Stage V: core relic families (Weapon Essence, Body, Hand, Foot);
- Stages VI-VII: accessory components and blueprint preparation;
- Stage VIII: standard Accessory I-II crafting;
- Stage X: signature/relic-tier crafting and the regional catalyst.

Nema remains the organic relic/essence crafter. Orren can sell or temper simple mortal essences. Neither NPC needs to disappear because the visible weapon is character-owned.

## Progression and Save Ownership

Recommended ownership for the first roster implementation:

- **Shared profile:** story memory, boss victories, discoveries, key items, material inventory, recipe discovery, stage claims, coins, and unlocked character IDs.
- **Per character:** level/XP, current health, skill awakenings, equipped essence IDs, and character-specific mastery.
- **Session:** current selected character, active expedition baseline, cooldowns, wave state, and other non-checkpoint combat state.

Do not reinterpret a version-1 Opaw save in place without validation. Add a profile migration that maps Opaw's current XP/HP/skill/weapon state to King's initial character record or intentionally starts a new King journey after an explicit user-facing choice. The exact old-save policy must be approved before changing the schema.

## King Pixel and Animation Proof

Do not generate the production sheet as one giant board. First approve one four-direction turnaround and one short side attack strip at gameplay scale. King's style should remain deliberately chibi and hard-pixel:

- oversized head, compact torso, short legs, simple visible arms or rounded forearms;
- readable hand-to-hilt contact without realistic anatomy or excessive finger detail;
- one signature-weapon silhouette and one stable costume/palette;
- upper-left lighting, binary alpha, nearest-neighbor import, fixed foot baseline;
- no frame-by-frame body resizing, changing face, disappearing arms, changing weapon length, or disconnected hands;
- 96x96 reusable portrait derived only after the gameplay identity is approved.

The provisional runtime cell contract is 48x48 for idle/walk/hurt/interact and 64x48 for committed attacks/dash when the weapon or arms need width. Exact visible height and baseline are approved from the turnaround proof, then frozen across every action. A wider cell is always preferred over shrinking King to fit a pose.

Minimum first-pass animation coverage:

| Action | Initial frame target | Review purpose |
|---|---:|---|
| Idle | 4 per direction | identity, breathing, stable anatomy |
| Walk | 6 per direction | true contacts/passing poses and arm counter-motion |
| Basic combo | 4 per step/direction | anticipation, contact, follow-through, recovery |
| Dash | 4 per direction | readable lean and recovery without scale change |
| Hurt | 3 per direction | impact and return readability |
| Interact | 3 per direction | NPC-facing body language |
| Defeat | 6 per direction | authored collapse before runtime fade |

These are targets, not a license to invent duplicate filler frames. If a direction cannot pass a 1x gameplay review, regenerate or repair that action before producing later skills.

## Additive Roster Sequence

1. Keep Opaw playable and regression-safe with his current skills and visual identity.
2. Approve King's young-prime story summary, turnaround, signature sword silhouette, and two-hit side attack proof.
3. Add `PlayableCharacterDefinition`, roster state, attack-chain data, and presentation injection without renaming generic `Player` systems to either character.
4. Build King's idle/walk/tap-hold combo/dash/hurt/defeat and Skill 1 proof with focused tests.
5. Add per-character save ownership and migrate the character menu toward roster plus essence/relic presentation while retaining Opaw's valid inventory data.
6. Validate Sanctuary, Stages I-III, save/load, equipment, skills, defeat, and every input method with both Opaw and King.
7. Archive only rejected experiments, duplicate processors, or assets made genuinely obsolete by a reviewed implementation; active Opaw content remains under runtime ownership.
8. Resume crafting transactions against the approved essence output contract, then continue Hunts and Stage IV.

Opaw's compact-armless body sheets, skill body/VFX/audio, loadouts, progression, catalog compatibility, story IDs, and focused tests are explicitly preserved. Generic input, movement, attack, evade, ability, damage, hitbox, health, progression, save, inventory, loot, stage, and UI composition systems are shared seams. King receives separate presentation and content definitions.

## Acceptance Gates

- Changing movement direction during an accepted attack never redirects its hitbox, VFX, damage, or pushback.
- King reads as the same person in every direction and action at 1x and 960x540 gameplay scale.
- Visible arms remain connected and the signature weapon grip is coherent in every contact frame.
- The real combo's contact shapes match the emphasized slash edges/tips and have center/edge regression tests.
- At least one normal enemy, one group, and Rootbound Husk remain readable during King's effects.
- The character menu shows character identity and essence/relic equipment honestly; no card implies a visible weapon swap that does not occur.
- Existing Opaw saves stay valid and a tested versioned extension adds roster/King records without erasing Opaw ownership or progression.
- Both Opaw and King pass the same runtime/archive boundary checks; active files for either character remain referenced only from valid runtime owners.

## Deliberately Open

- King's exact former-life death, family names, and whether his daughter is alive, copied, imprisoned, or used as divine bait.
- King's signature weapon silhouette and named combat archetype.
- Exact four skills, ultimate, resource system, and combo branch inputs.
- Whether new characters share profile level or keep completely independent levels after the first roster proof.
- Final essence rarity names, stat formulas, set bonuses, and old-save conversion values.
