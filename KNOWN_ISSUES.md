# Known Issues

This file tracks confirmed limitations, unresolved risks, and decisions blocking implementation. Remove resolved entries and record their resolution in `CHANGELOG.md` or `DECISIONS.md` as appropriate.

## Current Limitations

### KI-012 - Application restart still erases progression

- **Status:** Open
- **Impact:** XP, coins, current HP, weapon ownership/equip choice, awakened skills, and story memory survive scene replacement but not closing the game. This makes longer progression and the 90-coin Iron milestone unsuitable for normal multi-session play.
- **Planned resolution:** Add a versioned Save/Continue service using explicit dictionaries from the existing state authorities, stored beneath `user://`; autosave only at safe milestones such as Sanctuary, purchase/equip, awakening, and stage completion.
- **Workaround:** Use F9 for rapid testing. Normal balance tests must currently remain in one application session.

### KI-011 - Combat responsiveness, audio distinction, and Husk presentation need a playtest repair pass

- **Status:** Open
- **Audio progress:** Opaw's accepted-damage cue is now a distinct original cloth/body impact, and the dash uses a curated light CC0 swish; confirm their volume and clarity against every enemy attack in controller playtests.
- **Progress:** A focused smoke-tested input buffer resolves the reported rejected attack-to-skill follow-up without interrupting live damage or dash invulnerability, and the dash now has a separate 0.85-second reuse cooldown plus a clear HUD gap before Skill 1. Balanced Slash uses a data-owned 58-reach by 96-wide beginner-sword fan whose center and visible side edge both pass contact tests; future weapon families retain independent shapes/styles, and clustered normal hits share one 25-millisecond light hitstop/camera/audio response per swing. Piercing Rush/Consecutive Thrust use 128x40/128x44 lanes. Opaw now scales from 140 to 248 maximum health across Levels 1-10, carries current HP across scenes, and regenerates 1 HP/s after five damage-free seconds; enemy damage is 8/10/18/12/18 by current archetype. Rootbound Husk retains its finalized art/attack/audio package, uses 280 health and 18 damage, and Stage III now bakes 20-pixel seal clearance around its 16-pixel body. Automated coverage protects these contracts; human balance of cleave feel, run attrition/regen, audio, Husk time-to-kill, burst readability, dash feel, and controller playtesting remain open.
- **Impact:** Earlier playtesting reported rejected attack-to-skill follow-ups, repetitive dash/incoming-hit audio, unclear threat direction, and Rootbound Husk scale popping. The structural input and Husk animation causes are repaired, but only a controller playtest can approve their final feel.
- **Planned resolution:** Complete the roadmap's responsiveness, feedback/audio, and Husk-repair milestones in that order; measure each change with focused smoke coverage and a controller playtest before changing encounter counts or adding Stage 4 content.
- **Workaround:** Use F9 to test the completed skills and implemented routes; treat only Husk timing/readability and exact combat reach tuning as provisional, not its animation or attack-authority architecture.

### KI-010 - Expedition pacing still needs human controller playtesting

- **Status:** Open
- **Impact:** Automated coverage verifies the four-enemy cap, reinforcement warning/release order, queue completion, crowd spacing, Stage 3's ten-Rootling gated brood, its 43.75% Rootbound/56.25% living-forest terrain contract, authored TileMap population, landmark navigation cutouts, and individual attack behavior, but cannot judge clear-time satisfaction, whether ten Rootlings overstay their narrative purpose, portrait readability, decay-transition repetition, landmark scale, damage pressure, camera readability, or skill feel at 960x540.
- **Planned resolution:** Record timed Stage 1, Stage 2, and Rootbound Hollow controller runs using normal and F9 test loadouts, reviewing the new authored routes and corruption contrast alongside combat pacing; adjust authored cadence or environment composition only from observed evidence.
- **Workaround:** Keep the current one-at-a-time warned reinforcements, existing low-health starter enemies, and four-enemy ceiling; do not compensate with health inflation or a larger crowd.

### KI-003 - Target platforms are undecided

- **Status:** Open
- **Impact:** Input, rendering, performance budgets, UI, and export decisions lack firm constraints.
- **Planned resolution:** Prioritize desktop, web, and/or mobile targets before the vertical slice.
- **Workaround:** Keep early designs platform-neutral where inexpensive.

### KI-004 - Pixel rendering baseline is not art-validated

- **Status:** Open
- **Impact:** The 960x540 baseline mechanically validates Opaw's active compact armless action set and the new compact Eira/Orren service corner, but their oversized-head/tiny-foot silhouettes, detached props, widened sword orbit, and new building/cart density still need human in-motion judgment in Sanctuary and both combat stages. The complete previous Wayfarer model is available as a safe player rollback if Opaw fails that review.
- **Planned resolution:** Feel-test Opaw's gameplay scale, serious black-eye/scarf readability, four-frame locomotion, three-pose body/weapon synchronization in all directions, dash lean, hurt recovery, defeat fade, Eira/Orren scale and role props, service-building collision, and representative effects in Sanctuary and both stages.
- **Workaround:** Treat 960x540 and the compact armless sheets as the active prototype baseline, not irreversible final assets; restore the archived Wayfarer `SpriteFrames` resource if a rollback is required.

### KI-005 - Skill awakening, expanded equipment balance, and disk persistence remain incomplete

- **Status:** Open
- **Impact:** Ashwood/Iron ownership, explicit equip, Level-3 Eira awakening, and Opaw's base/level/flat-equipment vitality aggregation work across scene replacement in memory, but closing the application loses them. No armor item currently supplies the prepared flat bonus; slots 3-4, drops, selling, higher tiers, potions, mana, and disk persistence remain incomplete.
- **Planned resolution:** Approve a versioned disk profile and authored armor/mana/potion rules before expanding acquisition/balance, then author slots 3-4 only alongside content that supports their power.
- **Workaround:** Treat Ashwood/Iron, 140+12/level vitality, delayed baseline regeneration, and Eira's Skill 2 awakening as the complete session-only beginner slice. Do not expose legacy/high-tier previews, sell skills, or claim armor, lifesteal, critical, potion, or mana systems are implemented content.

### KI-006 - Title audio settings are session-only

- **Status:** Open
- **Impact:** Music, combat-sound, and menu-sound mute states return to defaults after closing the game.
- **Planned resolution:** Store audio preferences in the future versioned settings/profile system.
- **Workaround:** The title screen applies all three toggles immediately for the current session.

### KI-007 - Story memory is not persisted to disk and future expeditions have no content

- **Status:** Open
- **Impact:** The Sanctuary portal now evaluates data-driven level, story, boss, discovery, and narrative key-item requirements, but `StoryState` survives only for the current application session. The Rootbound Hollow is implemented and reachable through F9, yet its normal Thornbound Warden/Cinder Sigil requirements remain unobtainable; The Drowned Bells has no destination scene or obtainable requirements.
- **Planned resolution:** Approve the first versioned disk-profile boundary, then author the Thornbound Warden and Cinder Sigil to open The Rootbound Hollow through normal progression before advancing to Stage IV.
- **Workaround:** The implemented forest sequence remains playable continuously from Stage 1 through Stage 3; Sanctuary replay buttons still enforce their authored requirements, and unbuilt future routes remain sealed.

### KI-009 - Ground targeting and later skill awakenings are not implemented

- **Status:** Open
- **Impact:** Piercing Rush and normally awakenable Consecutive Thrust prove immediate-direction keyboard/controller/click activation, weapon scaling, cast direction locking, dedicated combat audio, effect-only presentation, and control resistance. No ground-target cursor/preview exists, and slots 3-4 remain unimplemented.
- **Planned resolution:** Feel-test both techniques and encounter clear times before any higher enemy cap. Build reusable target confirmation only before the first skill that actually requires it, then author later Eira awakenings.
- **Workaround:** Use Eira at Level 3 for normal Skill 2 or F9 for rapid debug comparison. Treat ground targeting, later skills, and encounter sizes above four active enemies as unimplemented.

## Current Bugs

None currently. The project and main scene pass headless editor import and runtime loading under Godot 4.7 stable.

## Technical Limitations

No active crowd-separation limitation at the current four-enemy wave scale. Larger hordes still require profiling before increasing encounter caps.
