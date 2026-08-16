# Known Issues

This file tracks current limitations only. Resolved and retired systems belong in `CHANGELOG.md` and the decision records.

## Current Limitations

### KI-018 - Portal presentation needs final owner-scale approval

- **Status:** Open.
- **Verified:** Sanctuary architecture is one fixed raster with an isolated energy animation. Stage exits structurally pass eight-frame vortex, five-tier styling, local guidance, and distant screen-edge pointer checks.
- **Risk:** Headless checks cannot judge the final vortex size, tier-color distinction, loop cadence, or pointer comfort during a complete moving-camera playthrough.
- **Next:** Review Sanctuary plus Normal/Mini Boss/Boss exits at 960x540; tune presentation data only unless collision or transition behavior actually fails.

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

### KI-013 - Crafting transactions and Hunts are not implemented

- **Status:** Open.
- **Implemented:** Immutable recipe/material/output data, inventories, pickups, claims, Stage V equipment, persistence, and Nema's read-only preview.
- **Impact:** Players cannot yet spend ingredients through a normal atomic craft or select replay Hunts.
- **Next:** Implement one validated spend-once/grant-once/save-once crafting transaction before expanding recipes or regions.

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
