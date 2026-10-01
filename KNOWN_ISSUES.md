# Known Issues

**Eira service corrections (Decision 164, 2026-10-02):** Below-book placement, extra menu step, absent Skills1/2 campaign training and unreachable World Mature are resolved. Training/Loadout and current/next rank requirements are explicit; all upgrades are reachable by cap10 and persist normally. 84 rendered flow/91 curriculum checks pass. Review changes are session-only; owner balance/usability and phone profiling remain open. Existing GPU teardown texture warnings persist. See docs/design/sanctuary-npc-usability.md.

**NPC/skills usability (2026-10-02):** Eira name/book overlap, oversized Vow menu icon, retired four-skill dialogue and unclear training/arranging entry are corrected. Native functional/interface checks pass 43/64; character menu, trainer persistence and 90/94 courtyard/study regressions pass. Owner usability judgment and phone profiling remain pending. Further interiors are deferred; existing GPU teardown warnings remain. See docs/design/sanctuary-npc-usability.md.

**Sanctuary workshop review (2026-10-02):** Orren has one walkable review interior with furniture collision, bench-safe mouse navigation, F entry, inspection and exit. V2 corrects oversized furniture and the room shell against unchanged King; owner accepted the furniture size for now, while broader room acceptance remains pending. Other interiors remain planned. Outdoor camera/bounds/path tolerance and selected minimap restore on exit; comparison/visit controls return King outside first. 60 rendered interior checks, 63 interface checks, 90 headless courtyard checks, 94 headless study checks and production hub smoke pass. Owner room/art judgment, indoor audio, phone profiling and campaign promotion remain open. Review saving stays suppressed until restart; shared GPU teardown warnings persist. See docs/design/sanctuary-workshop-interior.md.

**Worldsplitter correction (Decision 162, 2026-09-27):** The rejected bouncing sword and narrow sideways splash are replaced by fresh summoned blades and broad radial detonations. Distinct-blade, burial, all-direction AOE and control checks pass. Owner art/audio acceptance and mobile profiling remain open. Existing shared GPU shutdown warnings persist.

**Resolved 2026-09-27 — Worldsplitter overhead crater:** The generic GreatswordEffects observer emitted a redundant radial burst at King on skill release. Worldsplitter now bypasses that observer; its dedicated ground effect still appears only at the target on contact. All three ranks pass early-activation GPU regression checks. Existing shared GPU shutdown warnings remain.

**Historical Worldsplitter upright rebuild (Decision 160; superseded by Decision 161 above):** Skill 5 previously used a larger straight-down generated blade and a connected shattered-ground eruption, replacing the rejected X faults and angled concept.32 new drawings; .32s King commitment, independent contacts near .60/.84s, roughly1.84s total visual lifetime. Foundation/Advanced/Mature grow radius/damage with Eira Level10/15 training and saved rank; Mature is campaign-locked by the current cap but all forms are available in F7 -> Skills. Skill4 is unchanged. See `docs/design/worldsplitter-upright-descent.md`; owner balance/mix review and mobile profiling remain pending.

**Skills 4–5 runtime update (2026-09-27):** Resolved missing fifth skill and animation-only buff: Vow is playable in 4, Worldsplitter in 5, with Eira upgrades and migration. Shared GPU exit warnings remain. Current directional Vow body art uses the dedicated generated down pose and approved heavy-cleave frames for left/right/up; these directions are playable and size-consistent but do not yet have bespoke brace sheets. Barrier response uses the approved atlas for hit flashes, low-shield flicker and reverse-frame break/expiry, without new painted fracture frames. Owner feel, precise balance and phone performance remain unverified. These limits supersede the older no-buff/no-slot-migration notes below.

**Resolved Combat Lab control overlap (2026-09-27):** Floating collection/review/buff panels now live in the right AI/Skills sidebar, bounded above the action bar. Explicit dropdowns reject busy upgrade changes without displaying an unapplied rank. Lab entry overrides sparse/custom loadouts locally; F9 keeps upgraded component definitions bound. 26 focused assertions and native 960x540 captures verify layout/state. Skills scrolls for loadout and body diagnostics. Unbroken Vow remains animation-only; previously recorded shared GPU shutdown warnings remain unresolved.

**Unbroken Vow testing update (2026-09-27):** In-engine rehearsal is now available under F7 -> Skills tab -> BUFF · ANIMATION TEST, replacing the earlier GIF-only testing limitation. Down-facing activation and real movement/dodge/attack sustain are verified; shield/stats/depletion/upgrades and other cast directions remain pending. GPU capture exits report two5460-byte texture RID leaks plus RenderingServer teardown errors; identical errors reproduce on ordinary title-screen startup/exit without entering the test, so shared shutdown cleanup remains open.

**Skill 4 activation review boundary (2026-09-27):** The current preview adds down-facing King body poses and original pressure audio at .32s, preserving production size and exact idle bookends. Other directions, weapon-following crimson accents, shield-hit/break/expiry, Mature finisher and gameplay integration remain pending. Walk transition is composited in place, not a live combat capture; end-of-loop disappearance only resets the review.

**Skill 4 V2 art limitation:** The current six-drawing review shows a wrapping shell and ground seal over static King C. Its twelve-frame GIF repeats sustain drawings. Directional weapon accents, moving-player depth, shield damage/break/expiry and all gameplay integration remain unimplemented. Generated source halos were stripped in the review derivatives; original source is not import-ready.

**King Skill 4–5 pending implementation (Decision 159, 2026-09-27):** The owner has chosen the buff/fifth-slot direction and to keep Worldsplitter learned, but the generated `Unbroken Vow` effect is review-only. The active build still has Worldsplitter in slot 4, no shield/damage buff or Eira upgrade for Skill 4, and no save migration to slot 5. The six-frame effect requires an approved looping aura, cast body pose, depletion/recast frames, audio and real gameplay measurement before promotion.

**Action-bar visual review (2026-09-27):** Owner selected Eclipse Bind and accepted the compact size, then found the 55%-opacity center too transparent. The active 720x104 binary-alpha border now uses a separate 78%-opacity center veil. Native 960x540 dark- and bright-backdrop captures and the live-control smoke check pass. Owner combat-scene feel and representative-phone readability remain unverified; no gameplay rules depend on the frame.

**Previous dragon HUD art (2026-09-27):** The detached dragon pass is no longer referenced by active UI scenes. Its original source and runtime derivatives remain for provenance and can be removed during the planned asset cleanup after reference audit.

**Action-tray follow-up (2026-09-27):** Cyan Dash and gold Attack side cards and the replacement grounded Dash cue are implemented. Automated checks verify the bound `SFX` resource and clickable actions, and the 960x540 capture verifies layout. Exact loudness/feel in a crowded fight and phone-size legibility still need live review.

**Resolved 2026-09-27:** Pursuit travel speed no longer bleeds into landing recovery; ranked ability duplication no longer disconnects its equipped hotkey/HUD binding. Action-slot key/icon/status overlap caused by `PanelContainer` sizing is fixed. The smaller tray and larger status text were rendered at the project viewport; phone-scale legibility still needs device review.

**Skill 3 follow-up (Decision 158, 2026-09-27):** Eira-gated Level 5/8 Pursuit charges and 220/250/280px range are implemented and saved by rank. Charge stock refills on scene entry; owner combat-feel, exact level pacing, HUD legibility and representative-phone profiling remain open. Decision 159 supersedes the Unbroken Stand counter proposal with a Skill 4 buff direction; Worldsplitter remains active until the replacement and fifth-slot migration are built. Older "charges unimplemented" notes below are historical.

**Current King follow-up (Decisions 157–158):** King C, Earthsplitter Foundation, blue Molten Crash Foundation and trained blade-cut Pursuit are the production baseline. The old Oath collection and original Skill 1/2 nodes are retired. F7 form/rank buttons are session-only. Campaign unlock/persistence for later Skills 1/2 forms, final Skill 4 design, owner combat feel and phone performance remain open. Historical Lab-only issue notes below are superseded where they describe the default player.

**Skill 3 production status (Decisions 157–158):** The blue-white blade-cut Sovereign Pursuit travel/landing art and 1-to-3 trained-use progression are active in the campaign. Owner feel approval and representative-device performance checks remain open.

**Molten Crash upgrades (Decision 155, 2026-09-26):** Skill 2 now has four selectable Lab forms: 72px blue stone-and-light Foundation, 80px molten Advanced, 84px Awakened with one delayed 86px damage-only heat pulse, and 86px Mature with a stronger center and gentler damage rim. One .36s local sword cast, 8s cooldown and initial authored stun remain. The pulse resolves at the original impact while King can move. F7 -> Skills tab -> SKILL 2 and FORM compares them. Campaign unlock/persistence and owner feel review remain pending.

**Skill 1 accepted direction (2026-09-26):** Earthsplitter Foundation is active in the campaign. The Lab-only Fan releases three simultaneous lanes at center and +/-20 degrees, followed .22s later by one stronger, longer center wave. Initial lanes reach 196px (19px radius), deal 100% weapon damage once per enemy across the fan, and use light push/flinch. The follow-up reaches 228px (21px radius), deals 140% once more, and has heavier impact/55 knockback. Maximum unmitigated noncritical weapon budget is 240% per target; side targets usually receive only the fan. No stun. Cascade remains a separate Lab comparison. Upgrade gates and phone testing remain pending.

This file tracks current limitations only. Resolved and retired systems belong in `CHANGELOG.md` and the decision records.

## Current Limitations

### KI-025 - Divine collection and future reward gates remain incomplete

- **Implemented:** Ten equipped slots on 1–0, controller slot selection, expanded HUD/collection and compatible four/ten-entry saves. Four current King techniques are learnable; extra positions can remain empty. Retired Oath save IDs migrate to the corresponding core slots.
- **Remaining:** The proposed domain spell families, broader status system, divine passives and future stage reward gates are not implemented. Minus/plus remain optional later extensions.
- **Next:** Review the responsive core in combat, then build earned spells with bounded player commitments and explicit stage/reward authority. See Decisions 145–147.

### KI-024 - King skill responsiveness, future milestones and balance need review

- **Current kit:** Earthsplitter Foundation, Molten Crash blue Foundation, blade-cut Sovereign Pursuit and Worldsplitter are the four playable skills. King C body and its accepted gait, attacks and outline are production in gameplay and the character menu. The retired Oath and targeted Riftbreak proofs are in the recovery archive.
- **Remaining:** Owner feel/balance review, later-form stage unlocks and persistence for Skills 1/2, bespoke cast-body art, Pursuit charge tuning, Skill 4 redesign and phone performance measurements. No terrain destruction is implemented. The current campaign still reaches VI; Stage XX rewards and the Examiner seal matchup remain future work.
- **Next:** Check this four-skill kit in live combat with debug helpers off; tune after measured damage and incoming pressure. F7's form and unlimited-skill controls are session-only review aids.

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
