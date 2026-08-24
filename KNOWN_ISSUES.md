# Known Issues

This file tracks current limitations only. Resolved and retired systems belong in `CHANGELOG.md` and the decision records.

## Current Limitations

### KI-022 - Reusable Crag Bear art still has stage-numbered ownership

- **Status:** Open documentation/asset migration debt.
- **Verified:** The reusable runtime enemy scene is correctly owned by `entities/enemies/crag_bear/`, but its active body art remains under `assets/characters/enemies/stage_6_crag_bear/` and some provenance paths still include `stage_6`.
- **Risk:** Future work may incorrectly treat a recurring enemy as Stage-VI-only or repeat stage-numbered folders for Mage, Stone Warden, Disciples, projectiles, VFX, audio, or materials.
- **Next:** Do not rename live paths during the story-roadmap pass. Before the next Crag Bear art edit, perform one controlled reference/provenance/catalog/tool/test migration to identity-owned paths such as `assets/characters/enemies/crag_bear/`. All newly created reusable content must use identity-owned folders immediately.

### KI-021 - Stage VI production balance needs owner validation

- **Status:** Implemented; balance/feel pending.
- **Verified:** `The Elder Ascent` has production navigation and five 4/4/5/6/9 waves under a five-live cap: eight Bears, fourteen Thralls, five rebuilt Spitters, one finale Hog, and no Mirelings. Crag Bear retains approved body-authored attacks/audio/impact and now uses Heavy 30% stagger duration plus a fourth-hit/1.05-second breakout. Hog uses a third-hit/0.8-second breakout, and its charge sends data-owned 175 knockback/0.24-second recovery to Player. Spitter body motion, stable idle-to-attack actor mass, three-frame clean impact, bounded retreat, destructible seeds, cleanup cases, loot data, Stage V/VI route order, and encounter composition pass focused checks.
- **Risk:** Headless checks cannot judge final five-enemy priority readability, whether Bear resistance feels forceful rather than arbitrary, Hog charge recovery comfort, corrected Spitter on-screen scale, waterfall-path movement feel, or whether full-skill/no-armor and starter-gear clears are demanding without becoming noisy or tedious.
- **Next:** Compare the current composition against a Wave 4-5 candidate containing approximately two late-section Hogs while preserving eight Bears and the five-live cap. Use no armor/full skills, starter gear, and the Stage V set; record clear time, damage taken, charge overlap, target choices, seed-counter success, slam failures, audio/camera mix, and Crag Iron/Echo Claw yield before accepting exact counts or changing stats.

### KI-020 - Umi exchange economy needs campaign-scale tuning

- **Status:** Implemented, needs owner playtest and balance data.
- **Verified:** Umi, her native-density close dialogue portrait, compact side-facing Echo Crucible workbench, compact UI, metadata-driven future-material discovery, Common-target exclusion, sell/reconstruct transactions, enemy-memory persistence, boss safeguards, and Stage V gold fees pass focused structural checks.
- **Risk:** Current prices are deliberate first-pass values. Real Stage I-V play has not yet measured whether ordinary sales fund crafting too quickly, whether 1800 gold for the full set is too high, or whether Rare/Boss reconstruction feels appropriately long-term.
- **Next:** Owner-check the corrected portrait, Umi-to-right-bowl hand alignment, workbench scale, and collision at 960x540, then complete one fresh Stage I-V campaign without debug grants; record earned/spent gold, sold stacks, and first craft timing. Add the intended Stage VIII unlock only after that stage exposes canonical completion state. Tune resource metadata rather than branching Umi's code.

### KI-019 - Stage VI-XV gear pacing has its first encounter but lacks measurements

- **Status:** Partially implemented.
- **Implemented:** Varkuun Edge and the five Stage V armor pieces now have their Decision 121 stats, critical-hit behavior, caps, comparison copy, compact UI, and distinct icons.
- **Risk:** Decision 127 now provides a composition-heavy measurement target, but no no-armor/starter/crafted clear-time, incoming-damage, target-priority, or material-yield data exists yet. Stages VII-XV remain unimplemented. Lifesteal is a future unique-effect idea, not current authority.
- **Next:** Play complete Stage VI with all three loadouts and record the metrics before tuning Bear stats, the five-live cap, Spitter cadence, Crag drop protection, or projecting the band into Stage VII.

### KI-018 - Portal presentation needs final owner-scale approval

- **Status:** Open.
- **Verified:** Sanctuary architecture is one fixed raster with an isolated energy animation and restored authored guardian/backstop/threshold collision that retains both walk-around approaches. Stage exits structurally pass a centered moving 16-frame vortex/rim plus Decision 119's blue lightning-free Normal, restrained purple Mini Boss, red Boss, searing-light God, and near-black Transcendent ladder. FX opacity and independent reach rise strictly, Transcendent exceeds half the viewport, and the loading veil preserves the selected tier. The current full suite still fails the Sanctuary front-depth assertion because that zone does not begin early enough to protect King's head while crossing in front.
- **Risk:** Sanctuary crossing can expose incorrect head/architecture occlusion. Headless checks also cannot judge final Mini Boss/Boss restraint, God/Transcendent screen dominance, dark-field readability, dual-loop cadence, or pointer comfort during a complete moving-camera playthrough.
- **Next:** Correct and visually verify the Sanctuary front-depth boundary as a separate portal-depth task. Then review Normal/Mini Boss/Boss exits at 960x540 and temporarily preview God/Transcendent; tune only tier presentation data unless collision or transition behavior actually fails.

### KI-017 - Repeated-click combat and footprint approach need owner feel approval

- **Status:** Open.
- **Verified:** Automated coverage proves right-click/WASD combat cancellation, single-click enemy selection, repeated same-target engagement, physical foot-circle picking, size-aware approach, a real landed melee hit, target cleanup, and optional auto-skill/target cycling.
- **Risk:** Headless tests cannot judge the 520-millisecond repeat window, dense-crowd selection, obstacle pursuit, moving-target jitter, discovery-gated roster timing, marquee comfort, aura prominence, or whether the eight-pixel combat gap feels too close for every enemy tier.
- **Next:** Play Stages IV/V at 960x540 against normal, Elite, and Boss targets. Tune the one approach-padding/navigation contract from observed failures; do not add another movement authority.

### KI-016 - Armored Hog and eight-enemy crowd feel need owner playtesting

- **Status:** Open.
- **Verified:** Charge lane, frontal guard, rear damage, daze, animation/audio resources, protected drops, and Stage IV composition pass structural tests. Once BRACE begins, repeated normal-hit stagger no longer cancels the committed charge.
- **Risk:** Warning visibility, simultaneous charge readability, collision feel, and peak frame time remain human/performance questions.

### KI-015 - Ultimate and Reality Breaking are reserved UI tiers only

- **Status:** Planned.
- **Impact:** Neither tier has an input, ability, cooldown, animation, balance, unlock, or save authority. Reality Breaking is a distinct future finisher tier, not Skill 4.

### KI-014 - King still has presentation and combat-feel gaps

- **Status:** Open.
- **Implemented:** King is the sole production player with locomotion, basic attack, dash/backstep aliases, hurt/defeat presentation, signature sword, four active skills, equipment, progression, and persistence.
- **Remaining:** Owner approval of the generated cursor/action atlas, optional dedicated action families where aliases read weakly, normal-attack timing/variety, and full-kit balance against late crowds and bosses.

### KI-013 - Hunts are not implemented

- **Status:** Open.
- **Implemented:** Decision 120 enables Nema's six Stage V recipes through an atomic spend-once/grant-once/save-once service with duplicate rejection and rollback. Crafted equipment enters the existing live inventory/equip paths.
- **Impact:** Players still cannot select structured replay Hunts with explicit modifiers and reward families.
- **Next:** Define and implement the first completed-stage Hunt without expanding the crafting catalog.

### KI-011 - Combat/audio feel still needs a full-session pass

- **Status:** Open.
- **Verified:** Buffered inputs, cooldown denial, distinct player hurt/dash audio, King weapon reach/damage, crowd-control tiers, and boss armor/anti-kite behavior have automated coverage.
- **Risk:** Repetition, threat direction, volume mix, hitstop strength, and long-session responsiveness require controller/mouse playtesting with sound enabled.

### KI-010 - Expedition pacing and performance need human measurement

- **Status:** Open.
- **Verified:** Stage-specific live caps, wave totals, reinforcements, navigation, terrain population, and individual enemy behavior.
- **Next:** Record clear time, damage taken, skill usage, and peak frame time for normal Stage I-V runs before increasing health or live-enemy ceilings.

### KI-007 - Sealed future expeditions have no production content

- **Status:** Open.
- **Impact:** Data-driven previews can describe future routes, but destinations and requirements beyond the implemented Forest sequence are intentionally unavailable.
- **Planned direction:** Decision 131 assigns Stage VII to the first Disciple choice/test, Stage IX to modular reclaimed magical ruins with provisional Mage/Warden roles, and Stage XX to the first direct One Above confrontation. These are documentation anchors, not runtime destinations.
- **Disciple preparation:** Decision 132 defines the Examiner/Executioner high-level visual contract. The reattached original remains outside runtime assets, and the owner-approved compact-pixel V3 Examiner board is the active style lock. Decision 133 assigns the optional Challenge portal a separate circular divine arena and accepts Axiom Divide: First Measure as the restrained signature direction. A debug-only F7 implementation now proves the court, six stable `192x128` action sheets, compact kit, three-lane warning authority, final dash, and dodge recognition. The malformed signature boards and prior realistic runtime prototype are excluded from live assets; Axiom composes the approved sweep/dash poses in all four directions. It is not wired to Stage VII and still has no story outcome, rewards, saves, replay, or final audio.

### KI-006 - Audio settings are session-only

- **Status:** Open.
- **Impact:** Music, SFX, and UI mute states return to defaults after restart.

### KI-003 - Target platform priority is undecided

- **Status:** Open.
- **Impact:** Export, input, rendering, and performance budgets lack a final desktop/web/mobile priority order.
