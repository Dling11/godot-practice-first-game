# King Sword Combat and Skill Kit

## Status

Owner-directed combat proposal for review before implementation or image generation. Decision 072 already locks King as a separate young-prime sword character and preserves Opaw. Names, exact timings, damage, and ranges below are recommended starting values, not implemented balance.

## Combat Identity

King is a **young-prime Rift Swordsman**: fast at the opening, increasingly forceful through a committed chain, and deliberately exaggerated at the finisher. He is not a copy of Opaw.

| Character | Primary strength | Shape language | Main risk |
|---|---|---|---|
| Opaw | forward lane pressure and repeated thrusts | narrow lanes and controlled spirit lances | positioning and committed skill windows |
| King | broad cleaves, buffered combo routing, charged burst, crowd impact | white crescents, crosses, rings, and fractured space | large finishers have readable commitment/recovery |

King keeps normal movement, dash, left-click/right-trigger basic attack, and four numbered skill slots. He does not require mana or a second new resource for his first proof.

## Young-Prime Visual Direction

- Apparent age: late twenties, lean and athletic; energetic posture, clean-shaven or extremely light stubble, no heavy beard or weary “father” silhouette.
- Proportions: hard-pixel chibi with an oversized head, compact torso, short legs, visible simplified arms, and small readable hands.
- Hair: dark, active silhouette with one restrained pale memory streak; avoid a crown-shaped hairstyle.
- Clothing: fitted deep-navy travel coat/tunic, charcoal trousers, light shoulder/forearm protection, and one crimson memory cord tied at the sword hilt. Avoid bulky kingly armor, a cape that hides the arms, or ornate realism.
- Lighting/palette: warm skin and bone highlights under the project's upper-left light, deep navy/charcoal body mass, crimson memory accent, silver-white sword, and white-to-cold-blue attack effects. This separates him from Opaw's green/rust/gold palette.
- Expression: focused and angry when committed, but not permanently grim or old. His grief belongs in story and ultimate moments rather than every idle frame.
- Working title: `KING • MORTAL RIFT SWORDSMAN`. “King” is his name/display identity, not a requirement for a literal crown.

## Signature Sword

King begins with one character-owned straight sword, provisionally called the **Veil Edge**:

- silver-white single straight blade, readable at gameplay scale;
- dark compact grip with a small broken-halo guard;
- crimson memory cord near the pommel;
- long enough to support exaggerated cleaves without becoming a greatsword;
- integrated with King's body action frames so hand-to-hilt contact cannot drift;
- essence equipment may change stats, runes, aura, or trail accents but does not swap the sword silhouette by default.

The final weapon name and silhouette require owner approval with the turnaround.

## Basic Attack Input Contract

### Recommended tap-versus-hold behavior

1. **Press attack:** immediately enter a short `PRE_ATTACK` anticipation. The pose starts on button-down, so hold detection does not leave King visually idle.
2. **Quick release:** commit the next light-chain step.
3. **Rapid second press:** buffer exactly one next step. `click-click` therefore always produces the first two attacks even when the second input arrives during wind-up/active time.
4. **Third press inside the link window:** queue the broad finisher.
5. **Hold beyond 0.16 seconds:** convert the same pre-attack into `CHARGE` and suppress the light chain. Release performs one heavy cleave; holding never auto-repeats light attacks.
6. **Maximum hold:** auto-release at 0.80 seconds so the character cannot remain stuck indefinitely.
7. **Direction:** snapshot facing when each light step or charged release is accepted. Later movement may queue locomotion but cannot rotate the committed attack.

This gives the requested fast press/press double attack and a separate long-press attack without adding a second attack button.

### Proposed chain

| Step | Intent | Timing target | Contact target | Damage target | Cancel/link rule |
|---|---|---:|---:|---:|---|
| 1 — Opening Cut | fast diagonal entry | 0.10 / 0.07 / 0.15 s | 84 reach x 120 width fan | 100% sword power | Step 2 buffers during wind-up/active; dash after active |
| 2 — Reversal Cut | opposite sweep with body recoil | 0.08 / 0.08 / 0.17 s | 96 reach x 144 width fan | 115% | Step 3 buffers during active/recovery; dash after active |
| 3 — Horizon Break | exaggerated horizontal finisher | 0.14 / 0.10 / 0.28 s | 118 reach x 192 width fan | 155% | committed through active; dash only in late recovery |
| Hold — Falling Divide | one charged overhead-to-wide cleave | 0.16-0.80 charge / 0.12 / 0.34 s | up to 150 reach x 240 width fan | 220-300% by charge | no light chain; dash only after active |

These are intentionally larger than Opaw's starter cleave. The visual white slash must fit inside the real contact shape at its opaque edge and tip. Cosmetic sparks may escape it, but no solid blade-like ribbon may imply damage outside authority.

### Chain reset and input feel

- One pending attack only; repeated clicks do not build an invisible queue.
- Link grace target: 0.34 seconds after Step 1 and 0.38 seconds after Step 2.
- The chain resets after the grace window, dash, skill, damage interruption, defeat, character switch, or weapon-definition change.
- Button press/release intent belongs to the input source; attack state, timers, direction, hit windows, and queue belong to gameplay authority.
- Body/VFX frame playback follows those phases and never decides whether an attack lands.

## Impact, Recoil, and Screen Shake

King should feel heavier than Opaw without causing multi-enemy lag or constant camera nausea. Feedback is coalesced once per attack window, not once per contacted enemy.

| Impact tier | Camera amplitude / duration target | Hitstop target | Use |
|---|---:|---:|---|
| Quick | 1.5 px / 0.06 s | 0.025 s | combo Step 1 |
| Firm | 2.5 px / 0.08 s | 0.032 s | combo Step 2 and Skill 1 contact |
| Heavy | 4 px / 0.12 s | 0.045 s | combo finisher and Skill 2 detonation |
| Crushing | 6 px / 0.16 s | 0.060 s | fully charged cleave and Skill 3 finish |
| Ultimate | up to 9 px / 0.22 s | 0.080 s | Skill 4 confirmed culmination only |

- Add a one- or two-frame presentation recoil/settle after confirmed heavy contact; do not shift the authoritative actor backward unless the attack definition explicitly owns movement.
- Use directional camera impulse aligned with the slash, then a restrained return rather than random vibration.
- Provide a future reduced-shake accessibility multiplier. Combat remains readable at zero shake through flashes, sound, recoil pose, VFX, and enemy response.
- Multi-target contact keeps one camera/hitstop/audio event for the attack while every target still receives damage, flash, number, and local burst.

## Four-Skill Kit

### Skill 1 — Crescent Sever

**Role:** immediate-direction ranged cleave and crowd opener.

- King steps 18-24 pixels into a wide cut and releases one huge white crescent up to roughly 190 pixels forward.
- Contact is a broad tapered fan/wave, not a thin projectile. Each target is hit once for a proposed 175% sword power.
- No invulnerability. A short recovery keeps ranged clearing from becoming free.
- Visual: dense white core, cold-blue inner edge, sparse gold/crimson fragments, then rapid dissolution. The visible core remains inside contact authority.
- Proposed cooldown: 4 seconds.

### Skill 2 — Riftstep Cross

**Role:** mobility, repositioning, and delayed burst.

- King dashes up to roughly 125 pixels through a collision-limited lane with invulnerability only during the authored movement.
- Two crossed cut traces remain on the traversed lane and detonate 0.12 seconds after King exits.
- Proposed two contacts: 80% on pass and 145% on cross detonation. A target may receive both only when it occupies the real lane at both windows.
- Visual: thin white travel line, dark-blue afterimage, then one large white X with a screen-space directional kick.
- Proposed cooldown: 6 seconds.

### Skill 3 — Blade Dominion

**Role:** close-range crowd control and sustained area pressure.

- King plants his stance and performs three escalating circular cuts around himself: low ring, reverse ring, then a larger rising finish.
- He may steer slowly at roughly 35-40% movement speed but cannot dash-cancel before the second contact. No full-cast invulnerability; proposed 35% damage reduction keeps the choice risky but usable.
- Proposed strike scaling: 55% + 65% + 150% sword power in roughly a 120/135/165-pixel radius sequence.
- Visual: white rings with separated gaps so enemy telegraphs remain visible, followed by a short vertical recoil and outward debris.
- Proposed cooldown: 9 seconds.

### Skill 4 — Worldsplitter: Last Horizon

**Role:** cinematic ultimate and King's largest authored moment.

- A 0.35-second readable tell narrows the soundscape and marks one enormous forward wedge/cross lane. King remains committed and vulnerable until the actual cut unless later balance explicitly grants protection.
- King crosses the lane in one high-speed slash. Confirmed targets receive the authoritative strike; 0.18 seconds later the marked space fractures and resolves the second authored damage window.
- Proposed damage: 240% initial cut + 360% fracture. Boss control resistance still applies; the skill never bypasses encounter authority.
- Presentation may use a very short black-frame cut, letterbox, desaturated arena, white screen crack, silhouette hold, and sound return. The full interruption should remain well under one second outside the cast itself.
- Every overlay, camera override, shader, and audio duck must release on completion, cancel, defeat, pause, scene transition, or node teardown.
- Initial proof may use a long cooldown such as 24 seconds; a separate ultimate resource/gauge is deferred.

## Animation Production for Faster, Cleaner Frames

“Faster” should mean responsive timing and a reliable production pipeline, not simply raising sprite FPS.

### Body/action structure

- Use one `AnimatedSprite2D` with action-owned `SpriteFrames` for King's body and integrated Veil Edge.
- Use separate `AnimatedSprite2D` atlases for crescents, crosses, rings, and fractures.
- Keep a symmetric costume so left can be reviewed and then exactly mirrored for right; do not independently generate both unless a real asymmetry is approved.
- Provisional compact cell: 48x48 with a roughly 30-34 pixel upright actor. Extended combo/skill bodies may use 64x48 or 80x64 rather than shrinking King.
- Stable foot baseline and body scale across every direction and action.

### Minimum key poses, not filler

| Action | Key art target |
|---|---:|
| Idle | 4 frames per direction |
| Walk | 6 true contact/passing frames per direction |
| Pre-attack/charge | 3 pre-attack + 3 charge-intensity frames per direction |
| Combo Step 1 | 5 frames per direction |
| Combo Step 2 | 5 frames per direction |
| Combo Step 3 | 6 frames per direction |
| Charged cleave | 7 frames per direction |
| Dash | 4 frames per direction |
| Hurt | 3 frames per direction |
| Interact | 3 frames per direction |
| Defeat | 6 frames per direction |

Each attack needs anticipation, contact, follow-through, and recovery, but gameplay timers control their real duration. The contact pose may display for only one or two render frames while the named animation remains easy to preview in Godot.

### Production order

1. Young-prime four-direction turnaround with sword carried low and arms visible.
2. One right-facing pre-attack -> Opening Cut -> Reversal Cut strip.
3. Gameplay-scale approval against one Rootling, one Thrall, and Rootbound Husk.
4. Exact mirrored left strip and independently authored front/back cuts.
5. Full locomotion and reactions.
6. Combo finisher and charged cleave.
7. Skill 1 body/VFX proof, then Skills 2-4 one at a time.
8. Portrait only after the gameplay identity is stable.

Do not generate one giant board containing every action. It increases anatomy drift, bad crops, repeated poses, and repair time—the main causes of Opaw's slower art iteration.

## Implementation Order After Approval

1. Add character definitions and roster selection while preserving Opaw as the default compatibility path.
2. Extend input intent to expose attack press/release duration without putting combo rules in UI code.
3. Add data-owned basic attack steps and a tap/hold state machine with direction-lock tests.
4. Implement King using temporary debug silhouettes/contact guides before final art.
5. Produce and integrate the turnaround plus two-hit side combo proof.
6. Add impact-tier profiles and verify multi-target coalescing/performance.
7. Implement and review one skill at a time; Skill 4 comes last.
8. Add per-character save/load and roster UI only after both Opaw and King pass the same Stages I-III regression set.

## Approval Questions Still Open

- Final signature sword name and exact silhouette.
- Whether King's third light attack should launch/lightly stagger or remain pure knockback.
- Whether fully charged Falling Divide may move King forward or remain planted.
- Whether Riftstep Cross can pass through Boss bodies or stops at their movement footprint.
- Final skill names and balance after the first temporary-shape feel test.
