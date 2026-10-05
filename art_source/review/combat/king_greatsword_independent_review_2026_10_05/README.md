# Independent review of the other session's greatsword work — 2026-10-05

Review of the live Decision182 responsive implementation. Production code, weapon tuning and source artwork were preserved. The four-direction/axe capture and isolated gameplay/contact fixtures write evidence here rather than overwrite the previous session's evidence.

## Verified progress

- Runtime selects complete responsive body/hand cels for all five basic cuts in side/up/down directions; the rejected modular-arm rig is not allocated by these clips.
- Nominal chain is 3.00s instead of 4.26s. Huge 30×140 steel, carry/run and proud side idle remain. Faster pacing retains 8.45 base-hit damage and changes comparative throughput.
- Native motion1230/0, actual gameplay151/0 and contact60/0 independently pass. The new 130-frame motion.gif shows both sides, up/back and down/front alongside the unchanged axe using the same engine clock/input. Gameplay/contact fixtures run separately in real time.

## Remaining presentation defects

1. Slam landing and visual contact are inconsistent. The responsive builder forces the side blade downward (tools/build_king_responsive_greatsword.gd:85), while the adapter still places the ground burst at its previous (±46,32) offset (entities/player/presentation/player_weapon_family_presentation.gd:146). At first ACTIVE key3, the side blade tip is (±7,50.5), a 39-world-pixel horizontal displacement from the ground burst. In the vertical views, the first contact cel still holds the blade toward the opposite side: up tip Y30.5 vs burst Y−46, down tip Y−83 vs burst Y46. Setting lift_pixels=0 does not make the raised sword contact the ground. landing_measurements.json and frame_052.png document the issue. Fix the authored contact/landing pose and register the impact to it; do not change damage rules merely to conceal the mismatch.

2. The registered blade mapping now applies the meteor scale to every ordinary cut. gameplay/presentation/greatsword_blade_trail.gd:27 treats any queued_recovery_window clip as registered, and line40 uses meteor_texel_scale=0.30 for all four samples. All current greatsword cuts have that window. Broad ordinary white arcs consequently become small blade strips and can be clipped heavily by their front contact shape. The first cut's frame_016.png and finishing cut's frame_086.png show the reduced effects. Restore ordinary-cut artwork registration/scale, retaining explicit blade-bound slam registration where intended, then verify visible raster samples in all directions.

## Product and proof limits

Fourth is0.54s and fifth0.62s, so the earlier equal-fourth/fifth pacing preference is not currently retained. This may need revisiting alongside the owner's later request for axe-like responsiveness. Faster greatsword nominal output is2.82 base-hit units/s vs axe1.694 before defense/misses/gaps, roughly66% higher; this remains provisional tuning.

The twelve slots reuse existing cels, with repeated keys; they are not twelve newly drawn unique poses per cut. Passing grip/authority assertions does not establish all internal motion or owner visual acceptance. The unchanged skill/reaction/axe vertical art and acquisition/device limitations from the canonical responsive guide remain.

Recommendation: retain the complete body poses and accepted identity/idle, correct these focused contact/VFX problems, then assess the installed animation. Another wholesale generation or rig replacement is not required by these findings. No commit/push was made.

## Reproduce this evidence

Run the local capture_review.gd with Godot --fixed-fps60 and -- --capture; encode with encode_review.ps1 -ResponsiveMotion. The copied motion fixture changes only framing/output so all four directions are visible. gameplay_review.gd and contact_review.gd isolate native behavior proof. landing_probe.gd records actual Player blade-tip and ground-burst coordinates at first slam contact; it is a headless geometry measurement, not a rendered acceptance test.
