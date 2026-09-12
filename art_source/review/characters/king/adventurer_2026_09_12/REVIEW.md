# King adventurer identity and scale study

Preview only, awaiting owner visual feedback. This is not a completed walk or attack sheet and is not installed in the game.

`current_top_candidate_bottom_4x.png`: current King on the top row, candidate underneath, both enlarged exactly 4x with nearest-neighbor sampling. Columns face down, right, left, up. Candidate body height is 27px inside 48x32 cells, with y=30 baseline and head/torso centering independent of sword extent. Runtime collision, reach and body resources are unchanged.

Built-in image generation produced the four-view source from the actual old locomotion and portrait references. `PROMPT.txt` records the exact prompt. `tools/review_king_adventurer_scale.gd` performs chroma extraction and uniform native-scale packing for this review. No generated royal design is used as a reference.

The previous unfinished combo/passive code is retained in `combat_draft/`, under the Godot-ignored art_source tree. It is not active or validated as a feature. Further King animation and skill work follows identity review; Examiner's completed changes are preserved.
