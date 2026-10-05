# Greatsword chronological return — 2026-10-04

**Rejected appearance / historical source:** Owner reports different fifth design/color. Runtime V7 now uses verbatim accepted turn/rise/carry cells instead. This generated source and its registration are preserved only as history; do not use it as King's accepted style or current return dependency.

Built-in image_gen, using huge_greatsword_proof/turn_body.png as identity/style reference. Original output: C:/Users/Administrator/.codex/generated_images/01a0eed4-5878-7032-a315-e493f92ce97a/exec-83b92242-0e9f-46a2-a4ca-4d13da0b87b8.png. Copy preserved as return_source.png. Exact prompt is in prompt.txt.

The eight generated poses are a source, not a ready-to-use atlas. tools/build_king_greatsword_return.gd thresholds alpha at0.65, extracts regular4x2 source cells, and applies one shared density0.2190669371 to the five selected new body drawings. Registration keeps a192x128 cell and logical foot baseline96, with nearest sampling. No weapon/effect pixels are baked into the new body.

Runtime eight keys: old turning pose7 for entry, generated poses1–5, old carry pose2 for settle and old carry pose0 for exit. Entry/exit preserve the exact existing body pixels, grip and blade basis. Source pose6 is rejected because its front return reverses the follow-through again. Leading brown gloves use registered primary anchors. Keys1/3/6/7 explicitly use one-hand axes, not purported secondary grips; masks include only the actual gripping glove in new one-hand keys. Other new poses use two registered gloves. Successive blade headings remain within60 degrees and the active upward sweep is monotonic.

Runtime: assets/characters/playable/king/greatsword_return_v6/return.tres plus external body/hand PNGs. The canonical sword remains unchanged. White FX reuse the existing last row in reverse, sampled through four cached upward rotations-5/-20/-45/-75 degrees; no new effect bitmap is claimed. Native evidence: art_source/review/combat/king_continuous_return_v6_2026_10_04/.

Rebuild with Godot --headless --path . --script res://tools/build_king_greatsword_return.gd, then import with --headless --editor --quit. Launch the existing tools/launch_king_greatsword_review.ps1. This is review-only and writes no normal saves or rewards.
