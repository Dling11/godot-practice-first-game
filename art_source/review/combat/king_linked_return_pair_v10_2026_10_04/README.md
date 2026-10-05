# Native fourth-to-fifth motion preview

Captured with Godot4.7.2 Compatibility rendering, tools/capture_king_linked_return_motion.gd. Two actual controller-buffered strikes in each side-facing direction; the inset observes the same attack clock and pending-input query. Captured images are encoded after playback to avoid PNG compression stalling the attack clock. Timeline records actual elapsed times, phases, clips and poses; this is visual evidence, not a performance benchmark.

Encode tools/build_king_axe_motion_gif.ps1 -LinkedReturn. The GIF encoder verifies120 decoded frames and preserves actual sample delays. Fourth endpoint pose5 is held for the queued handoff; fifth entry0/1 matches that body/blade exactly, then contacts through the reverse stroke. No guard reset. Final settling returns to accepted carry.

Native tests/king_five_cut_smoke.gd:190 checks/0 failures, including manual buffered input both sides, actual recovery/entry samples, accepted source pixels, real contacts, effects, standalone fourth and pause/cancel/reset. tests/king_planted_weapon_smoke.gd:21/0. Owner animation feel remains pending; campaign equipment is not promoted.
