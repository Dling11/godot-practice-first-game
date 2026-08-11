# King Sword Combat and Skill Kit

## Status

Owner-directed combat proposal under active proof. Decisions 076-077 supersede the former detailed greatsword art clauses with a simple black-haired, crimson-scarf swordsman and one short broad rigid signature sword while preserving benched Opaw. King now runs in the normal player scene with locomotion and one shared-authority basic slash; old combo names, timings, damage, ranges, skill descriptions, and targeting remain proposals unless explicitly updated.

## Combat Identity

King is a **young-prime Rift Swordsman**: fast at the opening, increasingly forceful through a committed chain, and deliberately exaggerated at the finisher. He is not a copy of Opaw.

| Character | Primary strength | Shape language | Main risk |
|---|---|---|---|
| Opaw | forward lane pressure and repeated thrusts | narrow lanes and controlled spirit lances | positioning and committed skill windows |
| King | broad cleaves, buffered combo routing, charged burst, crowd impact | white crescents, crosses, rings, and fractured space | large finishers have readable commitment/recovery |

King keeps normal movement, dash, left-click/right-trigger basic attack, and four numbered skill slots. He does not require mana or a second new resource for his first proof.

## Young-Prime Visual Direction

- **Approved identity reference:** `art_source/generated/characters/playable/king/king_turnaround_direction_reference_approved.png`. This is the owner-approved design direction, not an exact-grid runtime sheet.
- Apparent age: late twenties, lean and athletic; energetic posture, clean-shaven or extremely light stubble, no heavy beard or weary “father” silhouette.
- Proportions: hard-pixel chibi with an oversized head, compact torso, short legs, visible simplified arms, and small readable hands.
- Hair: dark, active silhouette with one restrained pale memory streak; avoid a crown-shaped hairstyle.
- Clothing: fitted deep-navy travel coat/tunic, charcoal trousers, light shoulder/forearm protection, and one crimson memory cord tied at the sword hilt. Avoid bulky kingly armor, a cape that hides the arms, or ornate realism.
- Lighting/palette: warm skin and bone highlights under the project's upper-left light, deep navy/charcoal body mass, crimson memory accent, silver-white sword, and white-to-cold-blue attack effects. This separates him from Opaw's green/rust/gold palette.
- Expression: focused and angry when committed, but not permanently grim or old. His grief belongs in story and ultimate moments rather than every idle frame.
- Working title: `KING • MORTAL RIFT SWORDSMAN`. “King” is his name/display identity, not a requirement for a literal crown.
- Runtime density: approximately 28-32 visible body pixels tall inside a `64x64` armed-idle cell, one-pixel outline, roughly 12-16 character colors, and only two or three flat shade steps. The larger cell protects the greatsword silhouette; it does not authorize scaling King's body up. Reject realistic/anime portrait detail, gradients, antialiasing, individual hair strands, eyelashes, and rendered armor micro-detail.

### Directional perspective

- Battle of Gods uses a cardinal top-down three-quarter RPG view, not a pure frontal portrait and not a side-view platformer.
- `idle_down` faces unmistakably toward the bottom attack lane while the torso/shoulders turn roughly 10-15 degrees, the sword-side shoulder sits slightly behind, and the feet use a shallow diagonal stagger.
- `idle_up` mirrors that readable three-quarter staging from the back. Side directions retain a small visible top shoulder/back plane rather than becoming perfectly flat profiles.
- Locomotion changes the pose and direction row, not the camera language: walking down continues using the down-facing three-quarter identity, and stopping returns to the last movement direction's idle.
- A slightly angled pose may never rotate the authoritative cardinal attack lane or make the player misread which direction King will strike.

## Signature Greatsword

King begins with one character-owned heavy greatsword, provisionally called the **Veil Edge**:

- broad silver-white straight blade with a dark steel spine/core and a heavy angular tip, readable at gameplay scale;
- dark compact grip, restrained broken-halo guard, and crimson memory cord near the pommel;
- large enough to read as a true two-handed heavy weapon without becoming a screen-filling slab;
- rests on King's weapon-side shoulder during idle: the hand and hilt remain close to the body while the blade angles upward and outward, never through or toward his head and never sheathed on his back;
- integrated with King's body action frames so hand-to-hilt contact, shoulder weight, and blade pivot cannot drift;
- essence equipment may change stats, runes, aura, or trail accents but does not swap the greatsword silhouette by default.

The owner approved the greatsword/shoulder-carry direction in Decision 074. The final weapon name still requires approval.

### Weapon-bound crescent language

- Normal and skill attacks overcharge the physical blade: the blade edge brightens first, then the crescent grows directly from its authored swing path.
- The active slash is a thick white-hot melee silhouette with a cold-blue inner edge and restrained pale-violet fragments. It is not a thin wind line or a detached projectile.
- Peak contact may wrap around King at roughly two to two-and-a-half body widths, provided its opaque damaging edge and tip remain inside the authoritative contact shape.
- Runtime body/weapon frames and VFX remain separate `AnimatedSprite2D` layers. A combined review proof may show both only to validate timing, pivot, recoil, and visual ownership.

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

### Skill 2 — Riftfall Judgment

**Role:** ground-target mobility, impact damage, and delayed radial area denial.

- Activation opens a live ground reticle rather than firing toward the last movement direction. Mouse aims directly; controller uses the right stick; a future mobile control drags outward from the skill button. Confirming snapshots one valid landing point, while canceling spends no cooldown.
- Proposed target range is 180 pixels. World collision and navigation clamp the landing point before commitment; King may cross enemy footprints but never pass through walls, sealed portals, or invalid terrain.
- A readable 0.20-second crouch remains vulnerable. King is invulnerable only during the roughly 0.24-second airborne travel, then becomes vulnerable on landing/recovery.
- The sword-first impact hits a roughly 52-pixel core for proposed 190% sword power. After 0.15 seconds, a cracked outer ring expands to roughly 96 pixels for 85%; a target still inside both real shapes may receive both contacts.
- Light enemies may receive authored upward/outward control; Elites and Bosses continue using the existing crowd-control resistance authority.
- Visual and audio: compressed launch dust, a short white descent line, heavy stone/blade impact, then a separately animated branching ground crack. Body, target marker, landing burst, and crack remain separate assets.
- Proposed cooldown: 8 seconds.

### Skill 3 — Sovereign Pursuit

**Role:** enemy-target dueling burst and deliberate pursuit.

- Activation selects one living enemy beneath the pointer or inside the aim cone, up to roughly 220 pixels with valid world line of sight. An invalid target produces clear feedback and spends no cooldown.
- King performs two short collision-validated crossings around the selected enemy, then one broad finishing cross at its current/last-valid position. The proposed contacts are 65% + 75% + 170% sword power.
- Invulnerability exists only during the two brief traversal windows. The visible holds between cuts and the final recovery remain vulnerable, so target selection does not become a free escape.
- If the target dies or becomes invalid mid-sequence, King completes safely at the last valid position instead of teleporting through world collision. Bosses remain immune to forced displacement and stagger unless their data explicitly permits it.
- Visual: restrained navy afterimages attached to the traversals, two thin white cuts, then a larger cold-white X with a crimson center spark. Body, afterimages, cuts, and final X remain separate assets.
- Proposed cooldown: 11 seconds.

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

- Use one `AnimatedSprite2D` with action-owned `SpriteFrames` for King's body and integrated Veil Edge greatsword.
- Use separate `AnimatedSprite2D` atlases for crescents, target markers, landing cracks, pursuit cuts, and ultimate fractures.
- Keep a symmetric costume so left can be reviewed and then exactly mirrored for right; do not independently generate both unless a real asymmetry is approved.
- Provisional armed idle/locomotion cell: `64x64` with a roughly 28-32-pixel upright body. Extended combo/skill bodies may use `96x80` or `128x96` rather than shrinking King or clipping the greatsword.
- Stable foot baseline and body scale across every direction and action.
- The rejected rear-view proof must not be copied: a lowered sword-side hand makes the blade read as mounted across King's back. In every up/back shoulder-carry frame, bend the sword-side arm and show the hand visibly gripping the hilt at shoulder height; keep the guard just outside the shoulder, attach the crimson cord to the pommel beside that grip, and let only the off-hand hang down.

### Sheet geometry contract

- Produce one exact-grid PNG per action family rather than one very long horizontal strip or one giant all-action atlas. Examples: `king_idle`, `king_walk`, `king_basic_combo`, `king_dash`, and one body sheet per skill. Effect art uses separate action-owned sheets.
- Each body sheet stores canonical direction rows `down`, `left`, `right`, `up`; time advances across columns. This keeps the complete action together and makes Godot `AnimatedSprite2D` slicing and manual inspection predictable.
- Every cell in a sheet has one fixed size and pivot contract. Runtime PNG dimensions must equal `cell_width * columns` by `cell_height * rows`; a visually horizontal generated board is not sufficient.
- Generated review boards with irregular dimensions are source proofs only. They must be normalized into exact cells, binary alpha, stable foot/pivot anchors, and nearest-neighbor pixels before Godot imports or slices them.
- Record per-frame occupied bounds during processing and fail when actor height, foot baseline, shoulder grip, weapon length, or cell-center offset drifts outside the approved tolerance. Never independently center or scale each frame.
- A direction may use a deliberately shorter animation through `SpriteFrames` metadata; do not duplicate meaningless art merely to fill columns.

### Minimum key poses, not filler

| Action | Key art target |
|---|---:|
| Idle | 3-4 purposeful loop frames per direction |
| Walk | 4 core gait frames per direction; use 6 only when extra recoil/reach poses materially improve motion |
| Pre-attack | 3-4 immediate button-down anticipation frames per direction |
| Charge hold | 4-6 escalating/loopable tension frames per direction |
| Combo Step 1 — Opening Cut | 8-10 frames per direction |
| Combo Step 2 — Reversal Cut | 8-10 frames per direction |
| Combo Step 3 — Horizon Break | 10-12 frames per direction |
| Charged Falling Divide release | 12-14 frames per direction |
| Dash | 4-6 frames per direction |
| Hurt | 3-4 frames per direction |
| Interact | 4-6 frames per direction |
| Defeat | 8-12 frames per direction |
| Skill 1 body | 8-12 frames per direction plus separate VFX |
| Skill 2 body | 14-20 launch/air/descent/impact/recovery frames per direction plus target/crack VFX |
| Skill 3 body | 14-20 pursuit/strike/finish/recovery frames per direction plus cut VFX |
| Skill 4 body | 18-24 tell/cross/hold/return frames per direction plus cinematic VFX |

These are purposeful ranges, not quotas. A complete four-frame walk with contact, passing, opposite contact, and opposite passing is better than eight duplicated or misaligned cells. Idle uses slower playback; attacks and skills receive more poses because anticipation, contact, recoil, follow-through, and recovery need them. Gameplay timers still control authoritative phase duration, and one animation frame never grants damage by itself.

### Generated direction proofs awaiting runtime normalization

Decision 074 adds two direction references under `art_source/generated/characters/playable/king/greatsword_proofs/`:

- `king_greatsword_turnaround_reference_v1.png`: approved body/weapon design direction for down and side views, but its up/back pose is rejected because the sword-side hand hangs below the hilt and makes the weapon read as back-mounted;
- `king_greatsword_opening_cut_vfx_reference_v1.png`: owner-approved eight-beat combined motion/VFX proof showing blade charge, thick weapon-bound crescent, recoil, fragmentation, and recovery.

These wide dark-background images are review references, not runtime sheets. The attack proof intentionally combines body and effect to approve composition; production must separate those layers.

### Current simple-reboot checkpoint

- `simple_reboot/king_simple_identity_reference_v1.png` is the approved identity reference.
- `simple_reboot/king_simple_walk_source_v1.png` is a source-only 4x4 walking board with `down/left/right/up` direction rows and four contact/passing poses.
- The rejected detailed greatsword sheets, VFX strips, `SpriteFrames`, preview, processors, tests, and reviews are archive-only under `rejected_detailed_package_2026-08-11/`.
- Active runtime proof: exact `48x32` locomotion and `64x32` basic-slash atlases share one scale/baseline and drive the temporary live King. Dedicated dash/reaction sheets, tap/hold combo authority, and skills do not exist yet.
- Narrow directional attacks/skills require aim-preview confirmation; jump-smash/ground AOE uses a movable valid-range marker; instant activation is reserved for self-AOE, aura, buff, defense, or naturally broad waves.

### Superseded modest-sword source proofs

The first source pass is preserved under `art_source/generated/characters/playable/king/motion_proofs/`:

- eight-frame down-facing three-quarter idle;
- eight-frame right-facing walk with alternating contacts and passing poses;
- ten-frame right-facing `PRE_ATTACK -> Opening Cut` body strip;
- ten-frame right-facing Reversal Cut body strip.

Each action has a raw `*_source_v1.png` chroma board and a binary-alpha `*_clean_v2.png` intermediate. Decision 074 supersedes their modest-sword silhouette. They remain provenance inputs only while the greatsword direction is reviewed; do not normalize or reference them from Godot. After the replacement production strips pass review, move these obsolete proofs to the Godot-ignored archive.

### Production order

1. **Attack/effect direction approved:** preserve the owner-approved coarse King identity, heavy greatsword design, and white-hot weapon-bound crescent.
2. **Correct and normalize the armed turnaround:** replace the rejected up/back pose with a visibly bent sword-side arm and hand-on-hilt shoulder grip, then produce one exact `64x64` four-row binary-alpha idle sheet with unchanged 28-32-pixel body scale and one stable baseline.
3. Gameplay-scale approval against one Rootling, one Thrall, and Rootbound Husk.
4. Produce an exact-cell right-facing Opening Cut with separate body/weapon and crescent VFX strips; validate that every opaque damaging edge fits contact authority.
5. Exact mirrored left strip and independently authored front/back cuts.
6. Full locomotion and reactions.
7. Combo finisher and charged cleave.
8. Skill 1 body/VFX proof, then Skills 2-4 one at a time.
9. Portrait only after the gameplay identity is stable.

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

- Final signature greatsword name; `Veil Edge` remains provisional.
- Whether King's third light attack should launch/lightly stagger or remain pure knockback.
- Whether fully charged Falling Divide may move King forward or remain planted.
- Final targeting controls and balance for Riftfall Judgment and Sovereign Pursuit after temporary-shape mouse/controller feel tests.
- Final skill names and balance after the first temporary-shape feel test.
