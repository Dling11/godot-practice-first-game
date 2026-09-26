# Unbroken Vow generated effect concept

`activation_source.png` is a built-in ImageGen edit derived from a six-panel VFX concept using `assets/characters/playable/king/spellward/idle.png` as a style/scale reference. It is a **concept source**, not runtime art. The generation was asked to leave King out of every panel so his approved identity can remain pixel-identical.

Final edit prompt: “Keep six sequential VFX designs and fixed positions, with frame four as a fast outward impact and frames five–six as four shield shards. Remove soft glow, gradients, fog and background. Rebuild strokes as hard square pixels in a limited midnight-blue, cobalt, violet, cyan and white palette; six equal registered cells, transparent character-sized center, no character, weapon, text or UI.” The model retained some dark blue background despite the prompt. `tools/build_unbroken_vow_review.gd` therefore thresholds source luminance, downsamples and quantizes each cell to eleven colors with binary alpha, then composites the effect over an unchanged King C idle cell for review.

The two generated stages are review assets only. Production must re-author the stable aura loop and contact/depletion frames with exact frame registration and directional King cast poses, then inspect them in Godot before any active gameplay change.
