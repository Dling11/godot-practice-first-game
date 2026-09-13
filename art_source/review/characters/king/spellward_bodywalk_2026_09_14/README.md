# King C whole-body side-walk review

The owner accepted the hands but rejected this version's feet. The [continuous leg-cycle review](../spellward_legcycle_2026_09_14/README.md) supersedes the lower-body motion while retaining the approved upper-body source.

This supersedes the rejected foot-only side fix. Left/right now use eight coordinated poses with visible free-arm swing, waist/chest silhouette changes, scarf overlap and alternating support. The shoulder-carry identity remains. The owner-approved front/back walk, idle and three attacks are byte-identical to their previous assets.

Runtime art: assets/characters/playable/king/spellward_preview/walk_side.png. Eight 192x128 cells, two rows left/right, y96 foot baseline, one fixed anatomy scale across both source rows. Side clips run at 14 FPS instead of four at 7 FPS, keeping cycle duration and equipment scaling unchanged. Preview-only animation logic carries normalized stride phase between four/eight-frame directions. No gameplay control or speed changes.

Built-in imagegen source: art_source/generated/characters/king/spellward_locomotion_2026_09_14/side_body.png. Original study is side_body_study.png. Exact generation/edit prompts: [prompts.txt](prompts.txt). New source, including upper-body poses, is one coherent sheet. Old side_pass drawings remain historical inputs to the old unused side rows, not the live side clips.

## Review

- [Actual Godot movement GIF](bodywalk.gif) and [video](bodywalk.mp4).
- [All normalized side frames](frames.png): first two rows right-facing, last two left-facing.
- [Right](moving_right.png) and [left](moving_left.png) game render stills.

232 focused checks pass, including actual collision, equipment speed caps and four/eight-frame stride continuity. Original walk atlas, idle and all three attacks retain their bytes/hashes. The capture uses scripted device intent through the real Player controller to avoid desktop input contamination. Passing runtime checks does not establish final motion approval.

## Reproduce

1. Godot --headless --path . --script tools/build_king_spellward_preview.gd -- --side-body-only
2. Godot --headless --path . --editor --import --quit
3. Godot --headless --path . --script tools/build_king_spellward_preview.gd -- --frames-only
4. Godot --path . --fixed-fps 60 --write-movie art_source/review/characters/king/spellward_bodywalk_2026_09_14/capture_final.avi --script tools/capture_king_spellward_sidewalk.gd -- --bodywalk

Video/GIF use the first 3.1 seconds of movement, excluding the ending frame board. Video: H264 CRF19 at 30 FPS with AAC; GIF: 28 FPS, crop1200x600 at360,230, nearest resize720x360, 128-color palette without dithering. Intermediates can be removed after decode verification. Open F7 → KING REVIEW in a fresh session to try it.
