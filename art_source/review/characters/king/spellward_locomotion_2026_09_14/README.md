# King C locomotion correction

Owner accepts the down/up gait. Left/right has a newer [side-step correction](../spellward_sidewalk_2026_09_14/README.md) and [actual Lab GIF](../spellward_sidewalk_2026_09_14/sidewalk.gif); this earlier recording predates those two missing forward-foot poses.

Open a fresh game session, F7 → KING REVIEW. This updates the opt-in C comparison. The campaign still uses its existing King presentation.

Idle/walk/interact use one new built-in-imagegen sheet, copied into the project under art_source/generated/characters/king/spellward_locomotion_2026_09_14/locomotion.png. prompts.txt records the selected prompt and rejected gait experiments. The importer fixes horizontal registration to the upper hair band, keeps one scale per direction, and retains 192x128 cells, y96 foot baseline and 56px standing-body target at half node scale. Idle has a two-second loop; walking retains equipment-derived cadence. The rear shoulder blade lies below the hair at scarf/upper-back height.

A one-source-texel charcoal outline preserves texture interiors and applies to every C body clip, including attacks and reactions. Disabling C restores the original material as well as frames/script/scale. No gameplay timing, collision, damage, speed limits or skill rules change.

The three approved attack PNGs are unchanged:

- attack.png: C87688E853F80A90DBC8730A8F76296B94D56CBEDF038F1F761B6C2C3ECD7C3E
- return_cut.png: 45915D0335637CACAE3F27E80305FB19DE3A7A183EA173E3CF61330025B5DD1E
- heavy_cleave.png: 37BCB43DF97F0D6BAE4DE16CB26C7C8C7D5F29636B86E72C2C5DFAE64B377E13

## Review and verification

king_c_locomotion.mp4 and idle/walk/combo GIFs come from Godot's real Lab renderer and player controller. The capture substitutes scripted device intent to prevent desktop keyboard/controller activity contaminating the recording. It asserts stationary four-direction idle and records actual motion through Player. It does not alter the live game's input source. The video retains game audio and 1080p rendering; GIFs are cropped close-ups.

221 focused checks pass, including four-direction facing signals, real three-hit collision, speed caps, hit/stun release and comparison material restoration. Source measurement JSON records packed bounds. Side-stride overlap and gait feel still need owner approval; mirrored clothing asymmetry and provisional skill body mappings remain known limitations.

## Reproduce

1. Godot --headless --path . --script tools/build_king_spellward_preview.gd -- --locomotion-only
2. Godot --headless --path . --editor --import --quit
3. Godot --headless --path . --script tools/build_king_spellward_preview.gd -- --frames-only
4. Godot --path . --fixed-fps 60 --write-movie art_source/review/characters/king/spellward_locomotion_2026_09_14/capture_verified.avi --script tools/capture_king_spellward_locomotion.gd
5. Python tools/export_king_spellward_locomotion.py --ffmpeg <ffmpeg executable>

Intermediate AVI can be removed after successful encoding and decode verification.
