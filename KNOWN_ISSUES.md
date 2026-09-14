# Known Issues

**Owner correction (2026-09-14):** Intended Advanced is three spatial lanes in a rotating fan (center plus two angled sides) for wider AOE. The current sequential Cascade remains implemented and preserved as a possible later/third upgrade; it is not the accepted Advanced design. Fan implementation is pending. Resume from [the handoff](docs/design/earthsplitter-fan-handoff.md).

This file tracks current limitations only. Resolved and retired systems belong in `CHANGELOG.md` and the decision records.

## Current Limitations

### KI-025 - Divine collection and future reward gates remain incomplete

- **Implemented:** Decision 147 exposes ten equipped slots on 1–0, controller slot selection, expanded HUD/collection and compatible four/ten-entry saves. Eight techniques exist; extra positions can remain empty.
- **Remaining:** The proposed domain spell families, broader status system, divine passives and future stage reward gates are not implemented. Minus/plus remain optional later extensions.
- **Next:** Review the responsive core in combat, then build earned spells with bounded player commitments and explicit stage/reward authority. See Decisions 145–147.

### KI-024 - King skill responsiveness, future milestones and balance need review

- **Owner rejection / pause:** Latest Skills 2/3 and old/new coexistence are not accepted. Increasing skill numbers should represent stronger progression tiers. Broader skill redesign remains pending; September 14 authorization now also permits Decision 149's isolated targeted Riftbreak review. Passing checks do not establish an approved final kit.
- **Latest concept direction:** Skill 1 Earthsplitter Foundation is an opt-in Lab motion proof (Decision 150): separate summon, short cast, wall-safe released rupture and one hit per enemy without stun. The sword and fuller ground-eruption revision are owner-approved; the thin pressure-only pass remains rejected. The subsequent distant lower-left line on upward casts was reproduced as pixel-snapped atlas bleed and corrected with clipped sword cells. Advanced Cascading Rupture is implemented as a Lab-only form (Decision 152), pending owner feel/balance review. Later forms/gates, final bespoke cast-body art and campaign replacement/removal remain pending. Skill 2's approved local molten lift/crash is still a concept. Targeted Riftbreak remains an earlier experiment. Decision 151 supplies fixed 164px reach, continuous aim, width-aware terrain stops and upright rock/dust eruptions with directional flashes. Endpoint spice is presentation only, not an extra damage pulse or new upgrade. No terrain destruction is implemented.
- **Riftbreak review:** Targeted 180px cast, 30px stun center / 68px flinch-and-push blast, 0.38s commitment and 16-drawing VFX are implemented behind the Lab toggle. Campaign promotion, bespoke skill-body frames, future stage radius growth and owner feel approval remain pending.
- **Character baseline accepted:** Owner approves the final continuous side leg-cycle, the existing down/up walk, hand motion, three basic attacks and the existing hurt/stun body poses. The repeated-foot/leg-identity issue is resolved by owner review. Accepted proof: `spellward_legcycle_2026_09_14`. C remains opt-in Lab art at unchanged human scale.
- **Character work remaining:** Campaign promotion, final ancillary-state review (dash/defeat), mirrored clothing asymmetry and provisional skill-body mappings remain. Targeted Riftbreak is an opt-in Lab comparison; other skill replacements remain pending. Preserve the approved gait and attacks rather than reopening the character design.

- **Implemented:** Eight-technique collection, ten equipped slots, four finite forms, Stage II/V gates, Sanctuary persistence and isolated Lab previews. Decision 147 adds short fixed commitments, released targeted damage, center/rim tiers, Light-only rim slow, collision-stopped Breakstep and earned riposte. Focused behavior and regression coverage pass.
- **Remaining:** Production Stage XX and late-game rewards do not grant Ascendant/Unbound yet. Their story flags are hooks, not completed routes. Campaign pacing, future gear, crowd damage and the Examiner seal matchup require playtesting; the current campaign still reaches VI.
- **Current timing:** Crosscut/Griefwake/Breakstep/Last Oath commit for 0.48/0.42/0.32/0.62 s before hit pauses, unchanged by form. Dash can cancel the damaging core skills; Breakstep completes its short evasive sequence.
- **Next:** Owner feel-test timing, sound and incoming pressure with debug helpers off, then tune campaign damage and later forms with actual gear measurements. F7's unlimited-skill helper is for review, not cooldown balance.

### KI-023 - Examiner Stage XX balance and scenario integration remain pending

- **Status:** Owner approved the corrected animation identity. Decisions 139-141 combat mechanics are implemented in F7; production Stage XX is not connected.
- **Implemented:** Physical opening step, Reprisal, Held Judgment, a separate absorbing seal and interrupt/stun window, animated Borrowed Sun, 60%/35% escalation, Crownfall, interruptible Crimson Firmament, persistent enrage aura and finite 800 raw Verdict, varied legal attack choices, warned Axiom follow-ups, seal reactions and a skippable F7 victory acknowledgment. Body identity is preserved; focused authority and cleanup checks pass.
- **Remaining:** Measure actual player success, seal DPS, normal attack damage, and later gear survival. Stage XX gear is not implemented, so the current values cannot guarantee Stage I-X equipment dies and later equipment survives. Stage routing, required encounter outcome, power reward, replay, and saving remain open. The One Above's direct encounter is no longer fixed at XX.
- **Next:** Play F7 with invincibility off; test straight retreat versus sidestep/behind, seal success/failure, faster Sun escapes, randomized red rain from center and arena edges, and berserk Crownfall at 35% HP. Keep the approved character identity.

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

### KI-014 - King greatsword needs campaign feel and balance measurements

- **Status:** Implemented; owner playtesting remains.
- **Implemented:** Decision 143 installs C's compact greatsword identity, alternating gait, eight-frame action families, portrait, three-cut combo, contact-clipped raster trails, Resolve, Pursuit/Riftbreak link, original audio and bounded skill/XP progression.
- **September 13 correction:** Replaced inconsistent front/back walk poses, separated basic finishing sweep from ground-slam art, corrected the wrong-facing defeat settle, removed dark-magenta fringes, and reviewed all 280 installed frames. Riftbreak's duplicate/offset crater and premature impact cleanup are corrected; Pursuit damage/crater/shockwave now share the current foot origin. Resolve HUD explains building versus ready and retains the simultaneous landing-link cue. The original brainstorm is superseded by implemented Decision 144; the subsequent responsiveness redesign remains a proposal.
- **Remaining:** Judge swing readability and audio in crowded fights, plus first-clear pacing with no armor/starter/Stage V gear. +25% Resolve, +15% link and stage cap thresholds are authored starting values, not campaign-balance claims. Final level progression beyond the implemented six-stage campaign remains undefined.

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
- **Planned direction:** Decision 138 assigns Examiner to the required Stage XX false-mentor scenario; the direct One Above encounter is unscheduled. Stage IX retains modular reclaimed magical ruins with provisional Mage/Warden roles. These are documentation anchors, not runtime destinations.
- **Disciple preparation:** Decisions 139-141 extend the accepted F7 Examiner body/court proof with separate seals, Unbound and Crimson Firmament. Production Stage XX has no route, outcome, reward, save or replay implementation yet. The owner accepted the living-charge/Unbound pass; the new random pressure and outro need playtesting.

### KI-006 - Audio settings are session-only

- **Status:** Open.
- **Impact:** Music, SFX, and UI mute states return to defaults after restart.

### KI-003 - Target platform priority is undecided

- **Status:** Open.
- **Impact:** Export, input, rendering, and performance budgets lack a final desktop/web/mobile priority order.
