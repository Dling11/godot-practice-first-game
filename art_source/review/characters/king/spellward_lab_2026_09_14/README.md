# King C — isolated playable and visual review

The owner-approved attacks remain current. Idle/walk/interact and the body outline have a newer correction and capture in [the locomotion review](../spellward_locomotion_2026_09_14/index.html); the videos below show the initial version.

## Try it

Open the normal game, press F7, then KING REVIEW at the lower right. The first opening switches to C, clears the current trial and starts one paused-AI Thrall. Reopening hidden controls does not reset the fight. Use existing Lab buttons to spawn other actors, enable AI or disable invincibility. Campaign King stays unchanged.

- LOOK: compare C and the original. Switch only outside committed actions/control states.
- SPEED: cycle actual equipped bonuses, zero-bonus baseline, and existing +35% movement / +50% attack caps. No equipment inventory or weapon resource is edited. Equipping gear restores the real equipment mode.
- VIEW: gameplay view or 2x close-up.
- HIT / STUN: accepted 0.11s / 0.8s control samples through HealthComponent and StaggerComponent, with HP and immunity restored. Even low-health King cannot die from these samples.
- REACH: outline the real basic-attack collision polygon; bright only during contact.
- HIDE: hide the review controls; KING REVIEW reopens them.

Direct launch: Godot --path <project> res://levels/combat_lab/combat_lab.tscn -- --king-review

## What is implemented

Fine-detail C body at 56 source pixels, displayed at 0.5 node scale for roughly 28 logical pixels. Canvas-items rendering preserves that finer detail at the 1920x1080 development display. Binary-alpha 192x128 cells share the y96 foot baseline; Body remains at (0,-16). Four directions include mirrored left/right. Idle, four-pose gait, distinct descending/reverse-rising/horizontal cuts, dash/brake, hurt, held stagger and two defeat poses are available in the opt-in Lab presentation. Three cuts follow unchanged wind-up/contact/recovery authority and equipment timing. Existing generated white trail/impact art and action sounds are reused; the finisher samples a separate trail row, all clipped to the real contact polygon. No new damage or stun rules.

The built-in imagegen tool created the character source poses. Final prompts are alongside this README; source PNGs are in art_source/generated/characters/king/spellward_lab_2026_09_14. The importer removes the magenta matte, extracts complete connected sprites, registers foot origins, applies one body scale per action/direction row and packs atlases. Bad generated blade-loss poses are replaced by complete guard/recovery poses. Opposite stride drawings are explicitly composed from the extra stride study; no whole-body bob pretends to be a walk.

## Limits to judge in this review

This is a review build, not final campaign promotion. The small stance-to-gait transitions and side-stride overlap still need owner feel approval; sources are not hand-cleaned final animation. Mirrored directions also mirror costume asymmetry. Hurt uses a complete braced-to-dazed pose because the generated recoil drawing lost its sword. Stun is an intentionally held dazed stance released by gameplay, not a separate looping full-body sequence. Dash/defeat use two poses each.

Skills retain current rules/effects with temporary aliases to the new C action poses. They are not the final skill redesign, and Breakstep has not been removed by this character task. No future god powers, passive progression, stage rewards or campaign balance changes are included.

## Evidence

- king_c_lab_review.mp4: actual Godot recording, native 1920x1080, 30 FPS, game audio, about 20.8 seconds.
- Five GIFs: cropped close-ups from the same capture, not simulated animation. Opening video contact uses a stationary high-HP Thrall and invincible King; isolated sections show all directions, combo, reactions, speed caps and defeat.
- playable_lab.png and contact_check.png: inspected rendered UI/contact views.
- tests/king_spellward_preview_smoke.gd: 215 checks pass, including real three-hit collision/damage, distinct combo animations, switching restrictions, restored original resources, speed caps, stun hold/release, low-health reaction safety and non-resetting panel reopen.
- Existing Combat Lab regression passes. Greatsword/mastery suite: 385 checks pass. All exported GIFs/video decode; editor import and diff whitespace checks pass.

Reproduce with tools/build_king_spellward_preview.gd, Godot import, then the builder's --frames-only mode. Record with tools/capture_king_spellward_lab.gd and export with tools/export_king_spellward_review.py. Create this review directory before --write-movie. Capture/intermediate AVI is removed after successful packaging; generated source art and final artifacts remain.
