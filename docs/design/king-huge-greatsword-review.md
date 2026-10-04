# Huge greatsword motion and impact review

2026-10-04. Status: implemented isolated horizontal run/attack/stance review; owner feel/final design and normal equipment promotion pending. The owner requests a very huge sword, strong impact frames, jumping and body movement. Weapon-only steel design was generated/shown first, then separate body/effect art.

## Current V4 grip / shallow upright stance —2026-10-04

Owner likes the stance but rejects deep burial and hidden run handles, and asks for reuse by future greatswords. Greatsword run now registers the brown raised glove, exposes the handle by drawing it above body, and masks only the gripping glove above the weapon. Anchors vary at most1 logical X pixel. Axe run moves its attachment from low/front to rear shoulder, directs the shaft nearly vertically toward the back hip and disables the cutting-edge reflection used for attacks. Legs, real travel/collision and attack/slam authority stay unchanged.

Planting is upright beside King with10 logical/5 world pixels of tip buried. Optional data/weapons/weapon_planting_definition.gd stores ground anchor, depth, clearance and preparation/release indices; each clip stores its own texture, primary grip and tip landmark. The presenter solves orientation/placement from those landmarks. This sword's hilt ends above King's head when planted shallowly, so finite preparation lifts body art while the hand stays at the grip, rotates the blade upright, releases it and settles into existing crossed arms. Reverse retrieval uses the same geometry. Actor collision is never lifted or moved and steel is never resized.

Compatible future greatswords can duplicate/rebind the family clips with their texture/grip/tip and reuse the stance/body sequence. Native fixtures with75/145 logical grip heights, in addition to the actual113px blade, confirm the same ground/depth with different hilt heights. This is tested reusable presentation, not a claim that every shape fits without registration or that normal equipment selection is wired. Each variant still needs native art/grip/facing/skill fit review.

Current launchers: **Greatsword V4 GRIP / SHALLOW PRIDE** / **Axe V6 BACK MOUNT**. Native confidence101/axe20/plant21 checks pass; GPU tests verify shallow ground clipping, unchanged palette, rigid texture and hand-aligned preparation. New evidence: art_source/review/combat/king_grip_loop_v4_2026_10_04/ (64-frame loop/all keys) and king_grip_plant_v4_2026_10_04/ (200-frame action/idle/gallery). Build tools unchanged; GIF switches -GripLoop / -GripPlant. Owner feel remains pending.

## Historical V3 gait / burial correction —2026-10-04

Owner rejects V2 walking/running and likes crossed arms while correcting where the sword plants. The previous native tests established runtime behavior, not good animation. Support-foot X rebasing moved the torso and held blade across frames; the source lacked a clear narrow passing step. A time-driven loop also advanced against walls.

The replacement combines a new16-pose run source with four narrow passing drawings, using one density per source sheet and stable face registration. Both families have eight registered poses; the shoulder attachment stays at one X with only a1px logical bob. WeaponReviewHorizontalMotion advances presentation from actual collision-checked displacement. A48px stride at90px/s replaces the old32px timed cycle; blocked motion freezes feet, changing facing preserves the phase, pause/focus/release/cancel/reset remain handled. Side directions only; owner feel approval is pending.

Pride preserves the forceful drive and crossed arms but points the blade down-left. Poses5–7 hide steel below the registered foot plane via ground_clipped_poses and planted_weapon.gdshader; other poses/resources default to no clipping. The canonical blade stays rigid/full-size, with its tip buried rather than resized. Hand anchors remain fixed through release. Dust/decal sits at the visible steel/ground seam, mirrored with horizontal facing. Drawing back out still takes0.28s before gameplay begins.

Existing launchers open **Greatsword V3 GAIT / BURIED PRIDE** and **Axe V5 STABLE GAIT**. Opening/slam/contact/range/steps/audio remain from the prior refinement. Native confidence93 and axe11 checks pass, including steady shoulder registration and blocked phase; native planted-raster11 checks confirm a visible side seam, no steel below ground, original full blade underneath and unchanged texture palette. Edge25 and melee regressions pass. Original sources/prompts/registration: art_source/generated/characters/king/gait_repair_v3_2026_10_04/. Native all-eight-key sheet/64-frame run loop: art_source/review/combat/king_gait_loop_v3_2026_10_04/. Native gallery/pride/200-frame action capture: art_source/review/combat/king_gait_repair_v3_2026_10_04/.

Build build_king_confidence_v2.gd, then build_king_gait_repair.gd, then editor import. Capture capture_king_gait_repair.gd / capture_king_confidence_motion.gd and encode via build_king_axe_motion_gif.ps1 -GaitLoop / -GaitRepair. Earlier V2 source, evidence and figures below are history, not the current gait quality or cadence. Future native checks and owner feedback must keep these separate.

## Historical V2 refinement —2026-10-04 (gait rejected)

The owner likes the slam and intentional step, requests more opening momentum, blade-edge white art, running carry and confident planted-sword idle. Existing greatsword launcher selects launch_king_greatsword_confidence_review.gd; axe launcher selects launch_king_axe_run_review.gd. Legacy V1/V3 GDScript fixtures remain available.

- **Run:** A/D moves left/right at90px/s,32px cycle distance (~0.356s per eight-pose loop), with alternating legs, real collision/bounds, pause/release/focus handling. Axe is back-stowed/free arms; greatsword rests on the shoulder in one hand. No up/down production set is claimed.
- **Opening:** New8-pose torso/hip/back-view load and follow-through. Review wind-up/contact/recovery0.38/0.16/0.32s; physical damage125% and knockback160%. Reach104/full width116 and physical8px step remain. The step happens during anticipation on every accepted attack, even misses, not in response to a landed hit.
- **Slam trail:** Same generated raster source, registered actor-to-cell UVs place it over roughly the outer three-quarters of the blade. Four transforms correspond to meteor poses5/6; shader discards UV samples outside the active cell, preserving original contact clipping/3px feather and preventing neighbor-frame bleed. Side-facing ground impact mirrors only X.
- **Confidence idle:** One-hand carry,4s inactivity,0.48s forceful planting sequence and crossed arms. Frames5/6/7 keep a rigid weapon at identical ground anchors; released6/7 have no glove mask and render behind the body to expose folded arms. A small settling dust marker establishes the tip's ground point. This visual sword creates no collision/damage/defense. **Plant sword / proud idle** previews it immediately.
- **Retrieval:** Before moving or attacking from rest, reverse authored poses for0.28s. Gameplay attack has not yet started; pausing holds retrieval, cancellation kills it and buffered follow-up remains one. Run/attack handoff resumes event/tween state, without idle frame polling.

Greatsword cuts still use two hands for weight; one-handed carry supplies the requested confident personality. Existing sound sources are retained. No new lore/stat/passive benefit is inferred from pride.

New native checks: confidence82/0 (running/pause/retrieval/cancel/reset and left ground contact), axe run10/0 (back/free hands, actual movement/wall/pause-release/left hit), blade atlas6/0 (real rendered cell isolation); old axe495/0 and edge25/0 plus melee/style regressions pass.32 new generation frames in greatsword_confidence_v2_2026_10_04/,48 current greatsword body poses including preserved follow-ups. Build build_king_confidence_v2.gd after prior assets, import, capture_king_confidence_motion.gd, then build_king_axe_motion_gif.ps1 -Confidence. Native gallery/200-frame real-clock GIF/timeline: art_source/review/combat/king_confidence_v2_2026_10_04/. Capturing adds wall-clock overhead; this is not campaign/device profiling.

## V1 four-move slice (historical baseline)

One canonical30x140 logical steel sword stays rigid through32 body poses; native15x70 beside King's roughly27px body. Broad bright steel, dark groove, long brown two-hand grip, no gold glow. Body frames change torso, hips, knees, boots and back view. The jump includes a tucked-knee apex and low landing brace. Default is a low two-hand guard.

| Move | Forward reach / full width | Physical step | Wind-up / contact / recovery | Damage / knockback multiplier |
|---|---|---|---|---|
| Stepping sweep |104 /116px|8px|0.30 /0.20 /0.28s|110% /125%|
| Rising cut |96 /96px|10px|0.28 /0.18 /0.26s|120% /140%|
| Meteor slam |96 /84px|12px|0.64 /0.24 /0.40s|185% /240%|
| Turning cleave |104 /116px|8px|0.36 /0.22 /0.34s|145% /180%|

These are comparison values, not approved campaign balance. Existing equipped attack-speed scaling applies. One follow-up buffers; continuation window1.05s. Commit direction and geometry through real MeleeAttackComponent; each target takes one physical hit per cut. Turning cleave stays front-facing contact, not radial spin.

Attack steps use CharacterBody2D.move_and_collide and movement_bounds during the later wind-up; physics stops when blocked/idle/cancelled. They are separate gameplay authority from the pose observer. All four total38px on clear ground. Visual jump peaks18 native pixels and lands before ACTIVE. It grants no invulnerability or obstacle crossing; existing Skill3 is unchanged.

Four4-frame generated slash rows follow ACTIVE only, clip to real contact and fade3px inward. Separate4-frame metal-contact and4-frame grounded dust/stone effects provide weight. One contact flash per cut, plus one ground burst for meteor even on a miss. Contact flashes observe accepted hits; effects never duplicate damage. Ground landing(46,32) lies inside the fan and matches the blade tip. Pausable physics tweens end/clear on cancellation; no idle polling.

The review opts out of global CombatFeedbackPresenter hitstop through a new default-true flag; local effects, numbers, sounds and existing target feedback remain. Production hitstop remains enabled. A native test exposed a pre-existing global hitstop timeout that can release a concurrently requested manual pause; this review has no such global pause ownership. Broader pause ownership repair is separate work.

## Play and reproduce

Run from the project folder:

~~~powershell
powershell -ExecutionPolicy Bypass -File .\tools\launch_king_greatsword_review.ps1
~~~

SPACE/click attacks with one buffered cut. **Play four-move combo** runs the full chain. **Try meteor slam** isolates the jump. Buttons place an88px target, two extra front targets, or a rewardless moving Rootling. ESC pauses; cancel clears pending attacks; reset rebuilds the fixture. King is immune in this review; storage is isolated/suppressed. Right-facing attack steps work, ordinary WASD/skills/UI are deliberately disabled. The accepted axe launcher remains separate.

Build: tools/build_king_huge_greatsword.gd, then editor import. Native checks: tests/king_huge_greatsword_review_smoke.gd. Capture: tools/capture_king_huge_greatsword_motion.gd, then tools/build_king_axe_motion_gif.ps1 -Greatsword.

Final native Godot4.7.2 Compatibility run:447 checks,0 failures (frame-dependent count). Verified all32 foot/grip/body anchors, rigid texture, all16 slash frames, real crowd dedup/reach,38px actual steps, wall/bounds stop, grounded18px jump,5 bounded bursts for a12-contact combo, pause/cancel/reset and shared sword preservation. Melee, sword-style and combat-feedback smoke tests pass; native axe edge test25/0 passes.110-frame real-clock GIF decodes successfully. Capturing PNGs adds wall-clock overhead; this is presentation evidence, not device profiling.

Sources and exact prompts: art_source/generated/characters/king/huge_greatsword_2026_10_04/. Runtime: assets/characters/playable/king/huge_greatsword_proof/. Gallery/GIF/timeline/validation: art_source/review/combat/king_huge_greatsword_2026_10_04/.

## Remaining boundary

Owner feel, up/down art, dash/hurt/defeat, armor masks, skill/equip transitions, recipe routing and final balance remain pending. Horizontal mirrored movement is native-tested in the current V4/V6 reviews; aesthetic approval remains open. Earlier right-facing/stationary statements in V1 history do not describe current launchers. Compatible greatswords reuse family poses and shared planting after texture/grip/tip/proportion proof; another family still needs its own action art/authority. Normal F5 King/collection recipes remain unchanged.
