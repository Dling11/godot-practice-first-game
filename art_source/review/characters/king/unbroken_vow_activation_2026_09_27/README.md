# Unbroken Vow activation-body study

**In-engine testing is now prepared:** F7 -> KING REVIEW -> BUFF TEST, then T/REPLAY. The direct launcher is `tools/launch_unbroken_vow_test.ps1`. See the sibling `unbroken_vow_in_engine_2026_09_27/` review for real GPU captures and31-check results. The GIFs below remain the earlier composited study; the new Lab test grants no buff stats.

2026-09-27. The owner approved the planted pressure-release flow, blue protection with restrained crimson power, Advanced movement speed and Mature empowered third combo strike. This deliverable is a **down-facing art/timing review**, not a playable buff or a Godot combat recording. No live character sheet, HUD, collision, slot, save or balance data was changed.

- `index.html`: click-to-play normal/slowed sequence with original pressure sound and native-scale comparison. No sound plays automatically.
- `activation.gif`, `activation_slow.gif`, `activation_native.gif`: .32s cast, 3x-slow cast inspection and native gameplay-scale versions. Eight pose slots include identical approved idle bookends; they are not eight wholly new drawings. Sustain repeats the approved three barrier states and then composites the exact existing four-frame down walk in place. Review resets instantly at the end; this is not a proposed shield expiry.
- `activation_body_down_4x2.png`: 192x128 body cells, shared .25 source scale, standing 56px, y96 foot anchor. Brace compresses to52px; a one-pixel release rebound is57px. Normal game scale stays .5 (~28px standing). `measurements.json` records actual packed alpha bounds.
- First and last body slots are copied from the exact approved idle. All other source poses are palette-matched to existing King colors. The generator duplicated a weapon-side forearm in two release poses; the unchanged shoulder-grip region is restored from the approved idle during packing. The rejected narrow-body source is retained only as provenance, never used by the review.
- The accepted V2 shell is reused exactly. Generated crimson current/pressure drawings are layered separately; a two-beat, one-source-pixel view jolt illustrates the release. The actual body PNG anchors do not move with the view jolt. Directional sword-edge tracking remains future work.
- `pressure_contact.wav`: original deterministic mono44.1kHz16-bit .65s pressure cue; low rounded impact plus filtered air and quiet harmonic tail. Peak normalized to0.5. No third-party audio. The browser review synchronizes it with cast pose5. It is not installed in runtime audio.

Built with `tools/build_unbroken_vow_activation_review.gd`; GIFs use `tools/build_unbroken_vow_review_gif.ps1 -Activation` plus `-Slow` or `-Native`. Full built-in ImageGen prompts and sources are under `art_source/generated/characters/king/unbroken_vow_activation_2026_09_27/`.

Still pending: remaining direction poses, the Mature rising-step combo finisher, shield-hit/break/expiry states, Foundation gameplay, trained upgrades, HUD shield readout, actual terrain/combat/moving-player validation and save-safe Worldsplitter slot5 migration. No implemented movement-speed or attack bonus is claimed by this visual study.
