# Known Issues

This file tracks current limitations only. Resolved and retired systems belong in `CHANGELOG.md` and the decision records.

## Current Limitations

### KI-019 - Stage VI-XV gear pacing is designed but not encounter-validated

- **Status:** Planned.
- **Implemented:** Varkuun Edge and the five Stage V armor pieces now have their Decision 121 stats, critical-hit behavior, caps, comparison copy, compact UI, and distinct icons.
- **Risk:** Stages VI-XV and their enemy roster are not implemented, so the intended starter-versus-crafted clear-time and incoming-damage gap has not been measured in real encounters. Lifesteal is a future unique-effect idea, not a current stat authority.
- **Next:** Author Stage VI without Mirelings/Rootlings in its campaign roster, permit entry with any equipment, then record clear time and damage taken with starter gear versus Varkuun/Forest gear before extending the band.

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

### KI-006 - Audio settings are session-only

- **Status:** Open.
- **Impact:** Music, SFX, and UI mute states return to defaults after restart.

### KI-003 - Target platform priority is undecided

- **Status:** Open.
- **Impact:** Export, input, rendering, and performance budgets lack a final desktop/web/mobile priority order.
