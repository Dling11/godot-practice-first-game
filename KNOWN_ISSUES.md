# Known Issues

- Sovereign Pursuit's jump motion is owner-approved. Owner playtesting found and resolved a moving Riftbreak crater, inconsistent Pursuit ground anchoring, and a visually weak travel phase. Both residues are world-locked; Pursuit's ground frames share one foot-contact baseline; a separate open-center power sheath follows King during the hop; and landing adds a brief shockwave before the debris/crater. The revised scale and feel still await owner approval; authority values remain unchanged.

This file tracks confirmed limitations, unresolved risks, and decisions blocking implementation. Remove resolved entries and record their resolution in `CHANGELOG.md` or `DECISIONS.md` as appropriate.

## Current Limitations

### KI-017 - Stage 5 milestone reward and post-boss handoff remain incomplete

- **Status:** Open.
- **Progress:** Decisions 094-095 move the approved boss/environment into a real Stage 4-connected 24x18 route and finalize Varkuun's production presentation: aerial entrance, crater landing, portrait dialogue, top-screen named HUD, dedicated looping battle music, and real CC0 action recordings. Four actions, repeatable health-scaled jumps, positional root execution, grounded props, bounded collapse, corpse fade, completion persistence, and return portal retain focused coverage.
- **Impact:** Stage V completion still grants no new boss-specific material, core-gear crafting seal, or authored post-boss anonymous-power event.
- **Planned resolution:** Owner-playtest the completed encounter package, then author the milestone reward before deciding the later narrative handoff.

### KI-016 - Armored Hog crowd feel needs owner playtesting

- **Status:** Open.
- **Progress:** Structural tests validate the committed charge lane, frontal guard, rear full damage, daze, all animation families, audio resources, protected drops, and one/two-Hog Stage 4 composition.
- **Impact:** Headless verification cannot judge final warning visibility, boar-vocal volume, hoof rhythm, collision feel, or whether two simultaneous lanes remain comfortable in a full eight-enemy field.
- **Planned resolution:** Play Stage 4 with sound enabled and tune presentation volumes/timings or Hog count only from observed gameplay; keep the approved anatomy and dodge/punish authority intact unless the mechanic itself fails.

### KI-015 - Ultimate and Reality Breaking are reserved presentation tiers only

- **Status:** Planned.
- **Progress:** The Character menu names and visibly locks both tiers after the four active skills.
- **Impact:** Neither tier currently has gameplay authority, input, animation, balance, unlock, or persistence. Reality Breaking is reserved as a stronger finisher tier beyond Ultimate, not a synonym.
- **Planned resolution:** Design each tier separately after Stage 4 direction and King's core four-skill feel are stable.

### KI-014 - King is the temporary active proof; roster combat is incomplete

- **Status:** Open
- **Progress:** Decisions 077-082 temporarily make King the live player with tested locomotion, basic slash, and four playable skills. Skill 4 now proves separate eight-frame generated sword and ground sequences, two authoritative radii/damage windows, original audio, corrected shared impact anchoring, and world-locked residue. The live and isolated preview structures each use one body `AnimatedSprite2D`; Opaw remains a complete explicitly tested bench package.
- **Impact:** King still lacks real tap/hold combo authority, dedicated dash/hurt/interact/defeat sheets, essence equipment, roster selection, and per-character save/progression. A unique Skill 1/4 body sheet and heavier camera/hitstop treatment remain optional polish rather than active blockers.
- **Planned resolution:** Feel-test Skill 4 against normal waves and the Rootbound Husk, then tune its commitment, damage, and cooldown before expanding King's combo/roster systems.
- **Workaround:** Use the current exact-grid eight-frame sword and eight-frame ground sequences while judging mechanics; Opaw remains recoverable through preserved resources and explicit regression setup.

### KI-013 - Forest crafting transactions and replay Hunts are not implemented

- **Status:** Open
- **Progress:** Segments 1-4 now provide safe-point Save/Continue, ten illustrated materials, five live sparse/protected enemy drop profiles, collectible world pickups, direct Stage I-II banking, the guaranteed Stage III Rootbound Reliquary payout, expedition rollback/commit behavior, Character & Bag inspection, and the implemented Rootweaver Nema/Living Rootforge service. Nema's corrected side-facing west-mid presentation and paused menu safely preview the four data recipes, discovery state, required Stage V/Stage VIII seals, and live owned/required material quantities without mutating anything.
- **Impact:** Players can earn, retain, and inspect Forest materials and recipe costs, but cannot spend them or discover/produce/equip the four data-only outputs through normal play. No `CraftingService`, output equipment, Hunt selector, Stage V core-gear seal, Stage VIII standard-accessory seal, Stage X relic/signature seal, or regional Mastery exists. Ordinary stage replay is possible only through the existing route/debug seams, not the approved Hunt presentation.
- **Planned resolution:** Complete the Decision 071 essence/relic output contract first, then follow `docs/design/forest-loot-crafting-and-regional-material-plan.md`: Segment 5 atomic crafting/equipment transactions, Hunts, Stages 4-10, and the Stage 11 regional seam.
- **Workaround:** Play Stages I-III normally to collect materials, then inspect them in Character & Bag or Nema's Living Rootforge. Treat them as saved preparation inventory until crafting transactions and milestone blueprint/seal unlocks are implemented; F9 samples remain debug-only and non-saving.

### KI-011 - Combat responsiveness, audio distinction, and Husk presentation need a playtest repair pass

- **Status:** Open
- **Audio progress:** Opaw's accepted-damage cue is now a distinct original cloth/body impact, and the dash uses a curated light CC0 swish; confirm their volume and clarity against every enemy attack in controller playtests.
- **Progress:** Decision 081 generalizes the focused smoke-tested input buffer: one latest valid attack, dash, or equipped skill survives for at most 0.8 seconds and executes only at a recovery/ability-finished boundary. It resolves attack-to-skill and `Sovereign Pursuit -> Riftbreak` follow-ups without interrupting live damage or dash invulnerability, rejects cooldown waiting, and reopens targeted-skill previews. Repeated primary attacks now wait for the complete attack and no longer cancel the authored 0.21-second recovery; dash/skill recovery seams remain responsive. Dash retains a separate 0.85-second reuse cooldown plus a clear HUD gap before Skill 1. Basic attack direction and `SwordPivot` remain locked for the accepted attack. Balanced Slash uses a data-owned 58-reach by 96-wide beginner-sword fan whose center and visible side edge both pass contact tests; future weapon families retain independent shapes/styles, and clustered normal hits share one 25-millisecond light hitstop/camera/audio response per swing. Piercing Rush/Consecutive Thrust use 128x40/128x44 lanes. Opaw now scales from 140 to 248 maximum health across Levels 1-10, carries current HP across scenes, and regenerates 1 HP/s after five damage-free seconds; enemy damage is 8/10/18/12/18 by current archetype. Rootbound Husk retains its finalized art/attack/audio package, uses 280 health and 18 damage, and Stage III now bakes 20-pixel seal clearance around its 16-pixel body. Automated coverage protects these contracts; human balance of buffer feel, cleave feel, run attrition/regen, audio, Husk time-to-kill, burst readability, dash feel, and controller playtesting remain open.
- **Impact:** Earlier playtesting reported rejected attack-to-skill follow-ups, repetitive dash/incoming-hit audio, unclear threat direction, and Rootbound Husk scale popping. The structural input and Husk animation causes are repaired, but only a controller playtest can approve their final feel.
- **Planned resolution:** Complete the roadmap's responsiveness, feedback/audio, and Husk-repair milestones in that order; measure each change with focused smoke coverage and a controller playtest before changing encounter counts or adding Stage 4 content.
- **Workaround:** Use F9 to test the completed skills and implemented routes; treat only Husk timing/readability and exact combat reach tuning as provisional, not its animation or attack-authority architecture.

### KI-010 - Expedition pacing still needs human controller playtesting

- **Status:** Open
- **Impact:** Automated coverage verifies the Stage 1-3 four-enemy caps, Stage 4's eight-enemy ceiling and 6/8/10/12/14 totals, reinforcement order, crowd spacing, authored terrain population, and individual attack behavior, but cannot judge whether eight simultaneous threats remain readable, whether AOE now feels worthwhile, frame-time stability, clear-time satisfaction, or controller feel at 960x540.
- **Planned resolution:** Record timed Stage 1-4 controller runs using normal and F9 test loadouts, then profile Stage 4's peak eight-enemy field before authoring the larger Stage 6 horde ceiling.
- **Workaround:** Keep Stages 1-3 at four and Stage 4 at eight; adjust authored cadence before health inflation or any further cap increase.

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

## Current Bugs

None currently. The project and main scene pass headless editor import and runtime loading under Godot 4.7 stable.

## Technical Limitations

Stage 4's eight-active-enemy field passes structural smoke coverage but still requires gameplay-scale frame-time, navigation, separation, and threat-readability profiling. Do not choose the Stage 6 horde ceiling until that evidence exists.
