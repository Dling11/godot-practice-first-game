# Huge greatsword motion and impact review

**Current review (2026-10-05):** Owner rejects the detached-arm body/grip/rotation and slow pacing beside the accepted axe. Launcher/game now use [responsive full-body motion](king-greatsword-responsive-motion.md), with moving queued/released recoveries and3.00s timing. Original steel size, source cels, carry/run/planted idle and damage/contact remain. Earlier versions and phase totals below are history; current owner feel remains open.

**Current motion follow-up (2026-10-05):** Owner rejected the earlier recovery-only pacing. Installed fourth/fifth now each take0.70s, fifth0.08/0.22/0.40s with weighted low return/settle and registered blade interpolation. New front/back greatsword five-cut/carry/run artwork is in the production Player, with exact queued contact boundaries and no endpoint interpolation snap. Original huge steel, first four side drawings and proud side idle remain. Native final gameplay151/0, motion143/0, practice17/0; current native GIF: art_source/review/combat/king_greatsword_final_motion_2026_10_05/motion.gif. Owner feel remains pending. Current runtime/art/limits: king-greatsword-gameplay.md; earlier timings/vertical-fallback statements below are historical.

**Owner accepted and installed (2026-10-05):** LOW RETURN is accepted. Royal Greatsword now equips in actual F5 gameplay through F9 → Bag → Equip, retaining huge steel/idle/run/first four and sharing immutable data with this review. Native gameplay127/0, chain236/0, confidence101/0, planted21/0 and relevant regressions pass. Current implementation/limits/cleanup: king-greatsword-gameplay.md. Earlier isolated-only/owner-review/version notes below are historical.

**Current implementation (2026-10-05):** Owner preserves existing greatsword and selects ONLY B number3 “Return swing” as the missing fifth motion. Existing launcher now opens LOW RETURN4→5 with a dedicated16-key fifth. It inherits actual turn5, hits the same frontal lane, follows through low behind King without changing facing, then settles into exact existing carry. Original huge steel, first-four body/hand atlases, proud planted idle and gait/carry resources remain unchanged. Normal campaign equipment/F5 is not promoted. Native checks and actual right/left GIF pass; owner animation feel remains open. Prior concept/V10 directions below are historical.

## Fifth-only low return repair — 2026-10-05

Builder: tools/build_king_greatsword_low_return.gd. Runtime: assets/characters/playable/king/greatsword_low_return/return.tres. Built-in image_gen generated12 body-only poses from the exact existing fourth body plus B3 motion reference; source/prompt/hash/reference/registration are in art_source/generated/characters/king/greatsword_low_return_2026_10_05/. Source5 resets forward and source10 raises the wrong-side hand, so neither enters playback. Eleven middle keys use ten selected source drawings, including two registered lift patches from source11. Registration uses one0.184145 density; local torso/arm patches sit over the existing fourth stance, with existing head pixels protected. Entry0/1 and carry13–15 copy accepted cells/grips verbatim. New art does not replace the original first four, sword or idle.

WeaponFamilyPoseDefinition.pose_count defaults8; the new attack declares16 with a4x4 atlas and complete matching arrays. Shared presenter clamps to the current count and holds its last key for continuation. Existing eight-key actions retain their layout. Fifth WIND0–1 / ACTIVE2–6 / RECOVERY7–15: contact moves through the front, then the blade reaches the selected B3 low rear pose8. Later one-hand poses declare secondary landmarks as shaft directions, not fictitious glove contacts.

The fifth keeps the previous0.08/0.28/0.98 timing,190% physical damage,220% knockback,8px step and same frontal104/full116 shape. Full chain remains4.90s,8.45 base-hit units and46px actual forward travel. Fourth linked recovery0.12 and turn5 hold are retained. Rear blade follow-through does not turn attack direction, add rear hits or grow range.

WeaponReturnFollowThrough observes pose/phase/finish events and reuses original white raster art, faintly attached to the canonical blade only during fifth RECOVERY keys7–10. It stops on carry/cancel/finish, has no per-frame processing and owns no collision/damage. Existing contact trails and first-four FX remain unchanged.

Native evidence: tests/king_five_cut_smoke.gd239 checks /0 failures verifies16-key playback, original head colors/first-four atlases/huge steel, exact entry/carry, monotonic headings, mirrored raster visibility, all real front hits/rear misses/range bounds, manual buffer, full chain, pause/cancel and reset. Pause-gap fixture now pauses on attack_finished instead of polling a35ms window; a60s watchdog bounds failures. Preserved confidence/run101/0 and planted21/0 pass; melee/style smoke pass. Counts with actual phase sampling can vary slightly.

Static32-key right/left gallery: art_source/review/combat/king_low_return_2026_10_05/return_keys.png. Preserved motion captures are beside it. Actual-clock120-frame paired GIF/timeline: art_source/review/combat/king_low_return_pair_2026_10_05/. Capture tools/capture_king_low_return_motion.gd; encode tools/build_king_axe_motion_gif.ps1 -LowReturn. Capture inset enlarges presentation only; live actor scale stays0.5 and steel stays30x140.

Launch tools/launch_king_greatsword_review.ps1, click Try linked4→5 or Play five-move combo; A/D runs/faces, SPACE/click attacks, proud-idle button preserves the accepted stance. Save/reward isolation remains. Owner feel of the repaired runtime fifth, front/back family directions and campaign equipment integration remain separate open work.

2026-10-04. Status: implemented isolated horizontal run/attack/stance review; owner feel/final design and normal equipment promotion pending. The owner requests a very huge sword, strong impact frames, jumping and body movement. Weapon-only steel design was generated/shown first, then separate body/effect art.

## Current V10 linked fourth-to-fifth stroke - 2026-10-04

The fifth must begin at the fourth actual contact endpoint, then strike back through the opposite motion across the same frontal enemy. V9 correctly reversed ACTIVE cells but still played fourth recovery6/7 and fifth entryturn7/6; that lowers/reloads the weapon. Previous boundary checks compared guard7 with guard7 and did not prove the swing-end handoff.

The duplicated fourth clip declares linked_recovery_pose5. The optional presenter continuation_pending query holds that exact turn5 pose at RECOVERY only when input/autoplay requests another cut; continuation_requested holds it through the controller-owned0.035s gap. Fifth keys are verbatim turn5, turn5, turn5, turn4, turn3, rise3, rise5, idle0. WIND0-1 / ACTIVE2-4 / RECOVERY5-7: its entry matches the fourth last attacking body/gloves/blade exactly, then ACTIVE reverses5/4/3. Unbuffered fourth still plays ordinary recovery and returns to carry. Requests after recovery already completed begin a new exchange rather than being a buffered link.

Fourth recovery is0.12s and fifth wind/contact/settle is0.08/0.28/0.98s. Moving commitment from the handoff into the final settle keeps total4.90s,8.45 authored damage units and46px travel. First three timings, all contact shapes/facing/damage/knockback and accepted body/carry/run/planting artwork remain. Fourth recovery timing/presentation changes; do not claim all first four animations are unchanged. No rear attack, new body generation or campaign promotion.

Native five-cut190 checks/0 failures plus planted21/0 pass. New checks sample actual queued recovery and fifth entry, buffer real manual input on both sides, compare last ACTIVE5 with next WIND0, verify unbuffered fourth, and retain contact/effect/pause/cancel/reset proofs. Raster coverage is now deterministic: pause the contact clock and render all four real FX drawings explicitly, then resume real gameplay contact, avoiding missed-sample failures caused by GPU timing. These assertions establish the handoff implementation, not owner approval of animation feel.

Existing tools/launch_king_greatsword_review.ps1 opens **LINKED 4 -> 5**. **Try linked 4 -> 5** isolates the pair; **Try return slash** and **Play five-move combo** remain. Builder tools/build_king_greatsword_return_v10.gd records exact accepted source cells under art_source/registration/characters/king/greatsword_return_v10_2026_10_04/. Runtime assets/characters/playable/king/greatsword_return_v10/; test artifacts art_source/review/combat/king_linked_return_v10_2026_10_04/. Native120-frame right/left paired motion: art_source/review/combat/king_linked_return_pair_v10_2026_10_04/. Capture tools/capture_king_linked_return_motion.gd and encode tools/build_king_axe_motion_gif.ps1 -LinkedReturn. Owner feel/full-facing/equipment remain pending.
## Historical V9 return slash - 2026-10-04 (guard handoff corrected in V10)

Owner rejects V8: "return sword attack" means reversing the sword across the same enemy in front, not a separate attack behind King. V9 returns through cut4 contact cells5→4→3, opposite cut4's3→4→5, while keeping facing and frontal104px/full116 contact. It does not reuse V7's rising-cut contact or V8's rear contact. Four unchanged white cells play backward with ordinary mirrored front sampling. Rear polygon/outward knockback/rear UV rotations are removed from the current fixture; first four attacks remain unchanged.

Eight verbatim accepted body cells: turn7, turn6, turn5, turn4, turn3, rise3, rise5, idle0. WIND0–1 / ACTIVE2–4 / RECOVERY5–7. Recovery is a separate one-handed shoulder settle, not reversed anticipation; old accepted upper/front gloves provide explicit shaft axes in settling keys5/6. Body pixels, colors, density and leading hand origins remain exact. Fourth-to-fifth entry and fifth-to-carry exit remain exact. The quicker fifth reply uses0.20s wind-up /0.28s contact /0.64s settle (total1.12s), retaining190% physical damage/220% knockback/8px step and total4.90s/8.45 chain tuning. Adjacent ACTIVE headings reverse the fourth and remain close; separate settling headings may change up to80 degrees across the longer recovery.

Current PS opens **V9 RETURN SLASH**; **Try return slash** isolates5 against a frontal target, and front-crowd/full-chain controls remain. Native source-pixel, reverse-contact, real frontal hit/forward-knockback, rear/beyond-range miss, both-side effect and continuity/pause/cancel checks pass. Registration: art_source/registration/characters/king/greatsword_return_v9_2026_10_04/; runtime: assets/characters/playable/king/greatsword_return_v9/; native evidence: art_source/review/combat/king_return_slash_v9_2026_10_04/. Build build_king_greatsword_return_v9.gd, import, capture existing key/motion tools and encode -ReturnSlash. Owner feel remains pending; normal campaign equipment/up-down stay outside this correction. V8 below is rejected interpretation.

## Historical V8 returning backswing —2026-10-04 (rear-enemy interpretation rejected)

Owner accepts restored King appearance but corrects choreography: down swing → up swing → jumping slam → back-to-front cleave → **front-to-back returning backswing**. The fifth is not another frontal rising attack. The first four remain unchanged. V8 retains verbatim V7 turn/rise/carry body cells and exact entry/exit; the review duplicates that clip and sets WIND0–4 / ACTIVE5–6 / RECOVERY7. Front loading is anticipation; actual contact occurs while the steel crosses overhead and behind King. Facing remains committed; body/carry/run colors and dimensions are unchanged.

The fifth uses a rear-biased convex contact polygon:96px rear,26px close-front,64px half-height. Existing radial_steps mode supplies per-victim outward knockback only; it does not replace the polygon with a360-degree circle. Rear victims are pushed away from King rather than toward him. Four cached white samples rotate-100/-120/-140/-160 degrees through that same clipped rear lane. Contact duration0.22s, physical190%, knockback220% and8px forward step remain; total4.90s/8.45 authored hit units is unchanged. That aggregate budget assumes victims on the respective attack lanes, **not**8.45 hits against one distant frontal target; the fifth trades repeated frontal coverage for rear clearing. Final balance remains review tuning.

Native five-cut165/0 passes: accepted pixels/leading anchors, all four effect drawings for five strikes on both sides, fifth rear contacts, far-front/out-of-rear-range misses, outward rear impact directions, exact boundaries, pause/cancel and reset/wrap. Existing PS opens **V8 RETURNING BACKSWING**. **Try returning backswing** places a rear target and isolates cut5; **Place targets · front + rear** prepares the complete chain. Native keys and240-frame actual-clock preview: art_source/review/combat/king_backswing_v8_2026_10_04/. Capture existing key/motion tools, encode with build_king_axe_motion_gif.ps1 -Backswing. Owner appearance is accepted; new backswing feel still needs owner review. Up/down and normal campaign equipment remain pending. V7 below records the now-superseded frontal contact.

## Historical V7 matched King —2026-10-04 (appearance accepted; fifth direction corrected)

Owner rejects V6 fifth body design/color. The generated sheet widened anatomy, changed armor/belt shapes and shifted colors. Previous motion/opaque-pixel checks did not prove character consistency. V7 replaces all eight cells with **verbatim accepted pixels**: turn7, turn6, rise2, rise3, rise4, rise5, idle2, idle0. No rescaling, palette mapping or new body generation is used. Leading hand anchors remain original. Rise5's upper glove carries the recovery one-handed toward the shoulder; its secondary landmark explicitly provides a shaft axis, and the free hand is not a false grip. All other handedness/masks follow accepted cells.

Chronological return, exact fourth/fifth/carry boundaries, monotonic upward active arc, maximum60-degree adjacent blade headings, queued follow-through, upward white registration and existing contact/timing/damage stay. Current launcher opens **V7 MATCHED KING**. Normal F5 equipment, accepted idle/gait and up/down scope remain unchanged. Native five-cut155/0 passes, including each fifth body image compared byte-for-byte with its accepted source and original leading-anchor checks. Registration/provenance: art_source/registration/characters/king/greatsword_return_v7_2026_10_04/; runtime: assets/characters/playable/king/greatsword_return_v7/; native evidence: art_source/review/combat/king_matched_return_v7_2026_10_04/. Build build_king_greatsword_return_v7.gd, import, capture existing motion/key tools and encode with build_king_axe_motion_gif.ps1 -MatchedKing. Final owner appearance/motion approval remains pending; V6 source is rejected history.

## Historical V6 continuous return —2026-10-04 (body appearance rejected)

Owner reports a broken fifth cut and requests a continuous combo. V5's reversed recovery art is superseded by a dedicated chronological return resource. Five newly registered body drawings join exact old turn-end and carry keys; a shoulder-carry settle replaces the generated front-facing rebound. The leading glove anchors a rigid unchanged blade; explicitly one-handed load/middle/settle keys use a shaft axis, not a false second grip. No adjacent blade key turns more than60 degrees; ACTIVE rises through the front without reversing target facing. Four existing white drawings play backward, with cached registered rotations of-5/-20/-45/-75 degrees following the upward swing inside the unchanged contact polygon. Current review title: Greatsword V6 CONTINUOUS RETURN.

The shared presenter optionally queries continuation_requested at attack_finished. A queued review cut holds pose7 through the0.035s continuation gap, so no idle carry interrupts any of the five cuts. Default callers keep existing finish behavior. The controller/timer still owns input buffering and attacks; presentation never shortens recovery or issues damage. Fourth pose7 and fifth pose0 match exactly in body pixels and blade basis; fifth pose7 and carry pose0 match exactly too. Idle/run/slam,4.90s/8.45-hit budget, contact geometry and46px steps are retained. Cancellation clears the pending timer before returning to carry; pause holds the timer and pose.

Native five-cut139/0 and atlas6/0 pass; checks cover actual contacts/damage/all four FX drawings for every cut on both sides, mirrored pixels, queued-gap follow-through, exact boundary keys, monotonic active blade arc, cancel/reset/wrap. Planted21/0 passes. Current source/prompt/registration: art_source/generated/characters/king/greatsword_return_v6_2026_10_04/. Runtime: assets/characters/playable/king/greatsword_return_v6/. Native keys and240-frame action preview: art_source/review/combat/king_continuous_return_v6_2026_10_04/. Reproduce capture_king_return_keys.gd / capture_king_confidence_motion.gd; build GIF with build_king_axe_motion_gif.ps1 -Continuous. Owner feel remains pending. Normal F5 gear/recipes and up/down are unchanged.

## Historical V5 five-cut / left FX review —2026-10-04

Owner approves V4's idle. Up/down running is still **not implemented**: current family review supports A/D side travel only. The owner reports absent left white fragments, requests a fifth opposite swing and asks about slower/heavier damage. Existing greatsword PS now opens V5; axe remainsV6.

Ordinary FX sampled right-facing atlas coordinates even when its real hit polygon faced left. Common AxeSwingTrail now reflects actor-space X for ordinary samples. Blade-bound meteor maps already own facing, but their across axis also needed handedness reflection to match the complete right-facing basis. Both fixes preserve actual contact, inward3px fade and atlas-cell isolation. Native GPU proof renders the real generated raster separately, verifies all four drawings of all five strikes in both directions and compares their visible opacity counts.

Fifth is a **reverse finishing cleave** through the front, keeping committed target facing. It reuses turning-cut cells in reverse through optional pose_order, with equally reversed grip/layer metadata and explicit phase windows; the last slash row plays backward. No new bitmap source is claimed. It has the same104px forward/full116 contact as cut4,220% knockback and8px physical step. Five steps total46px. The approved idle, grip, gait and meteor remain.

| Move | Full nominal seconds | Physical damage / rolled basic hit | Knockback |
|---|---:|---:|---:|
| Sweep |0.86|140%|160%|
| Rise |0.72|135%|140%|
| Meteor |1.28|220%|240%|
| Turning cleave |0.92|160%|180%|
| Reverse finishing cleave |1.12|190%|220%|

First four phase times are retained; fifth wind-up/contact/recovery is0.46/0.22/0.44s. Full chain4.90s and8.45 rolled-basic-hit units gives1.724 normalized DPS versus axe6.10 units/3.60s=1.694 (about1.8% higher), before speed bonuses, continuation gaps, misses, criticals, defenses and crowd efficiency. This is comparison tuning, not final campaign balance. Stronger individual hits compensate commitment; a longer animation does **not** automatically build damage. Optional hold-to-charge is separate future design, not introduced by this pass. Avoid forcing every ordinary greatsword cut to2s solely for weight; retain responsive opening and make meteor/finisher the committed accents.

Native five-cut112/0, atlas6/0 and edge25/0 pass. Checks cover real physical100-base fixture amounts, once-per-target contacts, all five steps on both sides, mirrored actual pixels, reverse body grips,46px movement, autoplay/reset/wrap. Current evidence: art_source/review/combat/king_five_cut_v5_2026_10_04/. Capture240 actual-clock frames via capture_king_confidence_motion.gd and encode build_king_axe_motion_gif.ps1 -FiveCut. Next owner fifth/speed feel and front/back art; normal gear/recipes are not promoted.

## Historical V4 grip / shallow upright stance —2026-10-04

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

SPACE/click attacks with one buffered cut. **Play five-move combo** runs the current full chain. **Try meteor slam** isolates the jump. Buttons place an88px target, two extra front targets, or a rewardless moving Rootling. ESC pauses; cancel clears pending attacks; reset rebuilds the fixture. King is immune in this review; storage is isolated/suppressed. Right-facing attack steps work, ordinary WASD/skills/UI are deliberately disabled. The accepted axe launcher remains separate.

Build: tools/build_king_huge_greatsword.gd, then editor import. Native checks: tests/king_huge_greatsword_review_smoke.gd. Capture: tools/capture_king_huge_greatsword_motion.gd, then tools/build_king_axe_motion_gif.ps1 -Greatsword.

Final native Godot4.7.2 Compatibility run:447 checks,0 failures (frame-dependent count). Verified all32 foot/grip/body anchors, rigid texture, all16 slash frames, real crowd dedup/reach,38px actual steps, wall/bounds stop, grounded18px jump,5 bounded bursts for a12-contact combo, pause/cancel/reset and shared sword preservation. Melee, sword-style and combat-feedback smoke tests pass; native axe edge test25/0 passes.110-frame real-clock GIF decodes successfully. Capturing PNGs adds wall-clock overhead; this is presentation evidence, not device profiling.

Sources and exact prompts: art_source/generated/characters/king/huge_greatsword_2026_10_04/. Runtime: assets/characters/playable/king/huge_greatsword_proof/. Gallery/GIF/timeline/validation: art_source/review/combat/king_huge_greatsword_2026_10_04/.

## Remaining boundary

LOW RETURN is owner-approved and installed as Royal Greatsword in F5 through F9/Bag. Horizontal art/gait, proud idle/draw and equip/action handoff are native-tested. Up/down attacks/movement and skill/evade/reaction art retain the current directional fallback. New family-specific vertical/skill art, armor masks, recipe acquisition and final balance remain pending. The accepted axe remains in its separate review. See king-greatsword-gameplay.md for current runtime/validation; earlier version and isolated-only notes above are history.
