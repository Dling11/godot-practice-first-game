# Existing greatsword fifth — low return

Built-in image_gen generated body_source.png using existing_fourth_body_large.png for identity and the B3 “Return swing” board for motion ONLY. Final prompt: prompt.txt; original tool output/hash/references/canonical weapon hash: manifest.json. Existing body reference PNGs are native exports/enlargements, not generated replacements.

Only fifth is repaired. Original huge30x140 sword, first-four action art, run/carry and proud idle remain. Runtime uses the original canonical blade sprite; source contains no weapon or VFX. Source5 resets forward and source10 raises the wrong-side hand, so they are omitted. Source11 supplies two shifted lift patches. Eleven middle keys use ten unique source drawings; exact fourth turn5 supplies keys0/1, original carry supplies13–15.

Builder tools/build_king_greatsword_low_return.gd extracts complete body components and uses one0.184145 density. Registered torso/arm regions patch the existing stance; protected head rectangle94,44,28,23 retains original visible pixels. Local hand patches alpha-blend rather than erase the underlying legs. Binary alpha cutoff0.65; source PNG remains untouched. Registration.json records actual source indices, grips, headings and one-hand shaft-axis declarations. Late one-hand landmarks describe an axis, not another glove.

Runtime assets: assets/characters/playable/king/greatsword_low_return/{return_body.png,return_hands.png,return.tres};16 keys in4x4 cells, WIND0–1 / ACTIVE2–6 / RECOVERY7–15. Native real blade reaches B3 low rear pose8 while King remains enemy-facing, then retrieves original shoulder carry. Front contact rules and prior combo budget stay unchanged.

Rebuild with native or headless Godot --path . --script tools/build_king_greatsword_low_return.gd, then Godot --path . --editor --import. Existing tools/launch_king_greatsword_review.ps1 opens LOW RETURN4→5. Capture tools/capture_king_low_return_motion.gd; encode tools/build_king_axe_motion_gif.ps1 -LowReturn.

Evidence: art_source/review/combat/king_low_return_2026_10_05/ (static right/left keys and preserved-motion captures); king_low_return_pair_2026_10_05/ (actual120-frame motion/timeline/GIF). Native239/101/21 checks plus melee/style pass. Motion reference is selected; owner feel of this actual runtime repair remains open. This is still isolated review, not normal campaign equipment.
