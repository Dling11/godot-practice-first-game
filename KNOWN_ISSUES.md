# Known Issues

This file tracks confirmed limitations, unresolved risks, and decisions blocking implementation. Remove resolved entries and record their resolution in `CHANGELOG.md` or `DECISIONS.md` as appropriate.

## Current Limitations

### KI-014 - King and additive character-roster combat are designed but not implemented

- **Status:** Open
- **Progress:** Decisions 071-072 plus the King redesign/skill-kit documents define King's story foundation, young-prime visible-arm proof, tap/hold real combo, four distinct skills, impact tiers, cinematic boundary, essence/relic equipment, and additive roster/save ownership. Opaw and his current skills are now explicitly preserved. The opposite-movement attack bug remains repaired.
- **Impact:** The live game still instantiates only Opaw. King art/gameplay, roster selection, press/release attack intent, real combo damage, cinematic ultimate presentation, essence equipment, and per-character save records do not exist yet.
- **Planned resolution:** Pass the additive gates in order: turnaround/two-hit side proof, character/roster/attack-chain data, King's temporary-shape tap/hold combat, core art and Crescent Sever, remaining skills, roster UI/save extension, then full two-character Stages I-III validation.
- **Workaround:** Continue using Opaw normally. Preserve his active assets, skills, catalog compatibility, progression, story IDs, audio, and tests; archive only rejected or genuinely superseded experiments.

### KI-013 - Forest crafting transactions and replay Hunts are not implemented

- **Status:** Open
- **Progress:** Segments 1-4 now provide safe-point Save/Continue, ten illustrated materials, five live sparse/protected enemy drop profiles, collectible world pickups, direct Stage I-II banking, the guaranteed Stage III Rootbound Reliquary payout, expedition rollback/commit behavior, Character & Bag inspection, and the implemented Rootweaver Nema/Living Rootforge service. Nema's corrected side-facing west-mid presentation and paused menu safely preview the four data recipes, discovery state, required Stage V/Stage VIII seals, and live owned/required material quantities without mutating anything.
- **Impact:** Players can earn, retain, and inspect Forest materials and recipe costs, but cannot spend them or discover/produce/equip the four data-only outputs through normal play. No `CraftingService`, output equipment, Hunt selector, Stage V core-gear seal, Stage VIII standard-accessory seal, Stage X relic/signature seal, or regional Mastery exists. Ordinary stage replay is possible only through the existing route/debug seams, not the approved Hunt presentation.
- **Planned resolution:** Complete the Decision 071 essence/relic output contract first, then follow `docs/design/forest-loot-crafting-and-regional-material-plan.md`: Segment 5 atomic crafting/equipment transactions, Hunts, Stages 4-10, and the Stage 11 regional seam.
- **Workaround:** Play Stages I-III normally to collect materials, then inspect them in Character & Bag or Nema's Living Rootforge. Treat them as saved preparation inventory until crafting transactions and milestone blueprint/seal unlocks are implemented; F9 samples remain debug-only and non-saving.

### KI-011 - Combat responsiveness, audio distinction, and Husk presentation need a playtest repair pass

- **Status:** Open
- **Audio progress:** Opaw's accepted-damage cue is now a distinct original cloth/body impact, and the dash uses a curated light CC0 swish; confirm their volume and clarity against every enemy attack in controller playtests.
- **Progress:** A focused smoke-tested input buffer resolves the reported rejected attack-to-skill follow-up without interrupting live damage or dash invulnerability, and the dash now has a separate 0.85-second reuse cooldown plus a clear HUD gap before Skill 1. Basic attack direction and `SwordPivot` are locked for the accepted attack, so pressing the opposite movement direction during the swing no longer redirects the authoritative contact. Balanced Slash uses a data-owned 58-reach by 96-wide beginner-sword fan whose center and visible side edge both pass contact tests; future weapon families retain independent shapes/styles, and clustered normal hits share one 25-millisecond light hitstop/camera/audio response per swing. Piercing Rush/Consecutive Thrust use 128x40/128x44 lanes. Opaw now scales from 140 to 248 maximum health across Levels 1-10, carries current HP across scenes, and regenerates 1 HP/s after five damage-free seconds; enemy damage is 8/10/18/12/18 by current archetype. Rootbound Husk retains its finalized art/attack/audio package, uses 280 health and 18 damage, and Stage III now bakes 20-pixel seal clearance around its 16-pixel body. Automated coverage protects these contracts; human balance of cleave feel, run attrition/regen, audio, Husk time-to-kill, burst readability, dash feel, and controller playtesting remain open.
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
- **Impact:** The 960x540 baseline mechanically validates Opaw's compact armless runtime and Sanctuary service corner, but the owner has rejected that limb/animation direction for future playable characters. King's visible-arm chibi scale, anatomy, signature grip, frame continuity, and effects have no approved gameplay proof yet.
- **Planned resolution:** Approve King's four-direction turnaround and one side-attack strip at 1x/960x540 before generating full idle, walk, combo, dash, hurt, interaction, defeat, skill, or portrait assets. Then feel-test all directions and contacts in Sanctuary and Stages I-III.
- **Workaround:** Treat Opaw as a complete supported character whose compact style does not dictate King's body. The Wayfarer resource remains Opaw's additional visual rollback, not King's destination art style.

### KI-005 - Expanded equipment and later skill balance remain incomplete

- **Status:** Open
- **Impact:** Ashwood/Iron ownership, explicit equip, Level-3 Eira awakening, Opaw's base/level/flat-equipment vitality aggregation, earned material quantities, first-clear claims, and recipe discoveries now persist through the safe-point profile. No armor item currently supplies the prepared flat bonus; authored recipe outputs are data-only, while crafting, selling, higher tiers, potions, and mana remain incomplete.
- **Planned resolution:** Complete the approved loot/chest and crafting/equipment sequence plus authored armor/mana/potion rules before expanding acquisition/balance, then author slots 3-4 only alongside content that supports their power.
- **Workaround:** Treat Ashwood/Iron, 140+12/level vitality, delayed baseline regeneration, and Eira's Skill 2 awakening as the complete persisted beginner slice. Do not expose legacy/high-tier previews, sell skills, or claim armor, lifesteal, critical, potion, or mana systems are implemented content.

### KI-006 - Title audio settings are session-only

- **Status:** Open
- **Impact:** Music, combat-sound, and menu-sound mute states return to defaults after closing the game.
- **Planned resolution:** Store audio preferences in the future versioned settings/profile system.
- **Workaround:** The title screen applies all three toggles immediately for the current session.

### KI-007 - Future expeditions have no content

- **Status:** Open
- **Impact:** The Sanctuary portal evaluates data-driven level, story, boss, discovery, and narrative key-item requirements, and those memories now persist. The Rootbound Hollow is implemented and reachable through the continuous Stage 2 route or F9, but its legacy Sanctuary-only Thornbound Warden/Cinder Sigil requirements remain unobtainable; The Drowned Bells has no destination scene or obtainable requirements.
- **Planned resolution:** Reconcile the legacy Sanctuary-only Rootbound Hollow replay gate during the Hunt/route-history segment, and keep The Drowned Bells sealed until its region is authored.
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
