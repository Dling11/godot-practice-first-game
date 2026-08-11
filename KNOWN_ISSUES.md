# Known Issues

- Sovereign Pursuit's jump motion is owner-approved. Owner playtesting found and resolved a moving Riftbreak crater, inconsistent Pursuit ground anchoring, and a visually weak travel phase. Both residues are world-locked; Pursuit's ground frames share one foot-contact baseline; a separate open-center power sheath follows King during the hop; and landing adds a brief shockwave before the debris/crater. The revised scale and feel still await owner approval; authority values remain unchanged.

This file tracks confirmed limitations, unresolved risks, and decisions blocking implementation. Remove resolved entries and record their resolution in `CHANGELOG.md` or `DECISIONS.md` as appropriate.

## Current Limitations

### KI-014 - King is the temporary active proof; roster combat is incomplete

- **Status:** Open
- **Progress:** Decisions 077-080 temporarily make King the live player with tested locomotion, basic slash, Echoing Sever, Riftbreak, and the owner-approved Sovereign Pursuit jump. Skill 3 now has dedicated body/VFX/audio and correct launch-to-landing sequencing. The live and isolated preview structures each use one body `AnimatedSprite2D`; Opaw remains a complete explicitly tested bench package.
- **Impact:** King still lacks real tap/hold combo authority, dedicated dash/hurt/interact/defeat sheets, Skill 4, essence equipment, roster selection, and per-character save/progression. A unique Skill 1 body sheet and heavier camera/hitstop treatment remain optional polish rather than active blockers.
- **Planned resolution:** Feel-test the revised Skill 2/3 debris, crater persistence, and non-tonal audio, then brainstorm Skill 4 before implementation.
- **Workaround:** Use the current generated six-frame ground rupture while judging mechanics; Opaw remains recoverable through preserved resources and explicit regression setup.

### KI-013 - Forest crafting transactions and replay Hunts are not implemented

- **Status:** Open
- **Progress:** Segments 1-4 now provide safe-point Save/Continue, ten illustrated materials, five live sparse/protected enemy drop profiles, collectible world pickups, direct Stage I-II banking, the guaranteed Stage III Rootbound Reliquary payout, expedition rollback/commit behavior, Character & Bag inspection, and the implemented Rootweaver Nema/Living Rootforge service. Nema's corrected side-facing west-mid presentation and paused menu safely preview the four data recipes, discovery state, required Stage V/Stage VIII seals, and live owned/required material quantities without mutating anything.
- **Impact:** Players can earn, retain, and inspect Forest materials and recipe costs, but cannot spend them or discover/produce/equip the four data-only outputs through normal play. No `CraftingService`, output equipment, Hunt selector, Stage V core-gear seal, Stage VIII standard-accessory seal, Stage X relic/signature seal, or regional Mastery exists. Ordinary stage replay is possible only through the existing route/debug seams, not the approved Hunt presentation.
- **Planned resolution:** Complete the Decision 071 essence/relic output contract first, then follow `docs/design/forest-loot-crafting-and-regional-material-plan.md`: Segment 5 atomic crafting/equipment transactions, Hunts, Stages 4-10, and the Stage 11 regional seam.
- **Workaround:** Play Stages I-III normally to collect materials, then inspect them in Character & Bag or Nema's Living Rootforge. Treat them as saved preparation inventory until crafting transactions and milestone blueprint/seal unlocks are implemented; F9 samples remain debug-only and non-saving.

### KI-011 - Combat responsiveness, audio distinction, and Husk presentation need a playtest repair pass

- **Status:** Open
- **Audio progress:** Opaw's accepted-damage cue is now a distinct original cloth/body impact, and the dash uses a curated light CC0 swish; confirm their volume and clarity against every enemy attack in controller playtests.
- **Progress:** Decision 081 generalizes the focused smoke-tested input buffer: one latest valid attack, dash, or equipped skill survives for at most 0.8 seconds and executes only at a recovery/ability-finished boundary. It resolves attack-to-skill and `Sovereign Pursuit -> Riftbreak` follow-ups without interrupting live damage or dash invulnerability, rejects cooldown waiting, and reopens targeted-skill previews. Dash retains a separate 0.85-second reuse cooldown plus a clear HUD gap before Skill 1. Basic attack direction and `SwordPivot` remain locked for the accepted attack. Balanced Slash uses a data-owned 58-reach by 96-wide beginner-sword fan whose center and visible side edge both pass contact tests; future weapon families retain independent shapes/styles, and clustered normal hits share one 25-millisecond light hitstop/camera/audio response per swing. Piercing Rush/Consecutive Thrust use 128x40/128x44 lanes. Opaw now scales from 140 to 248 maximum health across Levels 1-10, carries current HP across scenes, and regenerates 1 HP/s after five damage-free seconds; enemy damage is 8/10/18/12/18 by current archetype. Rootbound Husk retains its finalized art/attack/audio package, uses 280 health and 18 damage, and Stage III now bakes 20-pixel seal clearance around its 16-pixel body. Automated coverage protects these contracts; human balance of buffer feel, cleave feel, run attrition/regen, audio, Husk time-to-kill, burst readability, dash feel, and controller playtesting remain open.
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
- **Impact:** The 960x540 baseline mechanically validates Opaw and now has exact-grid King idle/walk plus side-combo body/VFX assets, but the new processed motion has not received owner approval in the running game. Front/back attacks, dash, hurt, interaction, defeat, skills, and portrait remain absent.
- **Planned resolution:** Approve the processed King core preview at 1x/960x540, then bind it to temporary-shape combat for contact-alignment review. Author front/back attacks and later action families only after the current side motion passes; keep gameplay authority independent from animation frames.
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

### KI-009 - Later skill awakenings and Skill 4 are not implemented

- **Status:** Open
- **Impact:** King now proves reusable directional-wedge and ground-point targeting through Skills 1 and 3, but Skill 4 and later normal-play awakening/progression rules are not authored. Encounter sizes above four active enemies remain unprofiled.
- **Planned resolution:** Feel-test King's first three skills and encounter clear times, then design Skill 4 and later awakening rules before exposing them through normal progression.
- **Workaround:** Use King's implemented Skills 1-3 normally and Eira at Level 3 for Opaw's normal Skill 2. Treat Skill 4 and higher encounter caps as unimplemented.

## Current Bugs

None currently. The project and main scene pass headless editor import and runtime loading under Godot 4.7 stable.

## Technical Limitations

No active crowd-separation limitation at the current four-enemy wave scale. Larger hordes still require profiling before increasing encounter caps.
