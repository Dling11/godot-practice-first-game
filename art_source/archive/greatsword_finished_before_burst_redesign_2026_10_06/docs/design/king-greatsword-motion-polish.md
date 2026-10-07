# Royal Greatsword connected motion — 2026-10-05

**Historical — superseded2026-10-05:** Detached-arm and subsequent mixed-source responsive attacks are rejected. Current runtime/cleanup: [Oathbound](king-greatsword-oathbound-motion.md).

**Owner-rejected experiment:** The owner rejects body motion, grip/rotation and slow pacing compared to the accepted axe. Current runtime uses [responsive complete poses](king-greatsword-responsive-motion.md), not this modular-arm system. The following preserves the experiment and its geometric proof as history; passing counts did not establish good animation.

## Installed change

The owner requested a whole-system five-hit redesign, retaining the current sword size and established King art style. This supersedes earlier constraints to preserve the first four attack cels. Normal Player gameplay and the focused review share the replacement resources.

The old system inferred blade rotation from inconsistent drawn hand pairs, used shortest-angle rotation for some strokes, and held contact-end cels during queued recovery. Copying a boundary cel could hide an endpoint mismatch while leaving disconnected motion inside the attack.

The replacement has five twenty-key tracks in side/front/back views: descending cleave, rising cut, overhead meteor slam, winding cleave, low finishing return. Left mirrors the complete side rig. Anticipation loads the stance; contact accelerates through the frontal lane; recovery continues into the next chamber. All four recovery→opening boundaries reuse complete body/socket/grip endpoints. A released chain brakes into carry over an interruptible 0.18s cosmetic transition; a new attack inherits its actual rendered hilt.

The original 30×140 steel and its (15,113) leading grip remain unchanged. The second grip is (15,126), inside the existing hilt. Both wrists derive from this one rigid transform, with two-bone textured arms and stable elbow poles. Explicit unwrapped angles and exposure-aware monotone Hermite interpolation prevent shortest-path reversals and velocity discontinuities between keys. Bodies stay crisp raster cels; shoulders attach to the current torso cel. Presentation never applies damage or moves collision.

The far arm draws behind the torso; the near arm and gloves remain visible around the hilt. Legacy carry/run painter order is assigned relative to the body, so timers and optional arm containers cannot accidentally bury the held weapon.

Existing carry, actual-travel run, proud planted idle/retrieval and skill/reaction fallbacks remain. The five-hit phase budget remains 4.26s; damage remains 8.45 base-hit units; physical steps remain 8/10/12/8/8px. Contacts, frontal knockback, equipment IDs, saves and acquisition are unchanged. The focused review's continuation gap is shortened to the next physics boundary.

## Art consistency

The first modular generation added large round metal shoulder armor and extra trim. The owner called out the shift; that source is rejected and not loaded by runtime resources.

`ART_DIRECTION.md`, `STYLE_GUIDE.md` and the installed Spellward sprites establish the baseline: compact charcoal asymmetric tunic, pale seam trim, short crimson scarf, wrapped wrists, brown leather and plain determined face. A native export provides twelve existing reference cels. Built-in imagegen edits those references to remove arms and supply matching small arm parts. The offline builder protects the original head/face regions and boot pixels, restores compact central cloth from the original where it does not contain baked skin/gloves, and registers shoulder sockets. This is a bounded generated torso/arm patch, not a claim that every body pixel is verbatim original art. Native review and owner judgement still matter.

Runtime cells remain 192×128 with half-scale presentation, binary alpha and nearest filtering. Source body art uses one common density; detached oversized limb specimens are registered explicitly to 7×14, 6×15 and 5×5 runtime pieces. Original head/boot pixels do not undergo that source resizing. Original source PNGs, exact prompts, registration and protected references live under `art_source/generated/characters/king/greatsword_connected_2026_10_05/`.

## Ownership and files

- `data/weapons/weapon_family_pose_definition.gd`: optional continuous tracks and arm registration, with complete-layout validation. Legacy clips retain their cel playback.
- `gameplay/presentation/weapon_family_pose_presenter.gd`: existing physics Tween samples motion, handles queued endpoints and interruptible carry settlement.
- `gameplay/presentation/two_hand_weapon_rig.gd`: two-bone arm geometry and fixed hilt grips; no attack authority.
- `assets/characters/playable/king/greatsword_connected/{side,up,down}/`: fifteen authored twenty-key tracks.
- `data/weapons/families/royal_greatsword/poses.tres` and `presentation.tres`: production/review routing. Existing combo tuning resource is unchanged by this pass.
- `greatsword_blade_trail.gd`: contact-clipped existing raster art samples the actual directional motion clip rather than stale meteor grip indices. Rear follow-through remains cosmetic and direction-aware.
- `player_weapon_family_presentation.gd`: observes committed ability phases/finish, fixing a fast-render-frame skill visibility race caused by observing ability_started before WIND_UP was committed.
- `tools/export_king_motion_style_reference.gd`, `tools/build_king_connected_greatsword.gd`: reproducible reference export and ingestion.

## Review and verification

Run `tools/launch_king_greatsword_review.ps1`, then **Play five-move combo**. SPACE/click attacks; A/D runs. Tab enters actual Combat Lab and its visible Bag. Normal F5 game access remains F9 → Tab → Royal Greatsword → Equip, with saves suppressed for that debug session. Restart a running instance to load the new resources.

`tests/king_connected_greatsword_smoke.gd` checks the installed four-facing Player rigs, every quarter-key wrist/arm reach sample, rigid steel scale, directed contact paths, all queued handoffs, original head/boot pixels, real five-hit buffered input, physical steps and final carry. `king_greatsword_motion_smoke.gd` routes to that current proof. `king_five_cut_smoke.gd` routes to the current contact proof rather than obsolete art-preservation/held-endpoint assertions; the contact proof checks every move on both sides for correct damage, once-per-target contact, frontal knockback and rear/out-of-range misses.

Native capture uses a fixed 60Hz engine clock and 30fps readback; real-time gameplay/input tests run separately. Preview/evidence is under `art_source/review/combat/king_greatsword_connected_2026_10_05/`. See its validation summary for final counts. Capture with `--fixed-fps 60 --script res://tests/king_connected_greatsword_smoke.gd -- --capture`; encode with `tools/build_king_axe_motion_gif.ps1 -ConnectedMotion`.

Final native proofs: connected motion **6468/0**, real Player gameplay **151/0**, ten directional contact trials **60/0**, preserved carry/run/plant review **101/0**, planted idle **21/0**, practice input **17/0**, and axe integration **114/0**. The motion GIF contains 160 verified frames. A second build reproduces all 48 generated PNG/TRES files byte-for-byte (SHA256). Generic melee/style regressions also pass. The older run fixture used a render-clock timer for a physics-travel assertion; a busy native run expired after31 movement ticks (46.5px), despite correct resource, focus and running state, while a faster run traveled58.5px and passed. It now measures40 actual physics ticks and explicitly regains focus after its manual cel audit. Gameplay focus-loss cancellation remains intact.

Owner assessment of the final feel/art remains open. Phone performance, armor overlays, family-specific skills and comparative campaign balance are not established by these checks. The pre-existing scene-transition exit diagnostic remains separate debt. No commit, push or branch change was made.
