# King character review - September 13

`review.mp4` is a rendered 30fps Godot Combat Lab capture, covering four-direction movement, each basic combo direction, all current skills, the jump-to-Riftbreak link, native scale and the character/skill menus. Capture command: Godot `--path . --script tools/capture_king_greatsword_review.gd --write-movie <review.avi> --fixed-fps 30 -- --polish`; encode H.264/AAC and verify a full decode. This review is rewardless and does not save player progression.

## Frame audit

`down_all_frames.png`, `left_all_frames.png`, `right_all_frames.png`, and `up_all_frames.png` show all 280 installed frames. Row order: idle, walk, opening attack, return cut, finishing sweep, Echoing Sever, Riftbreak, Pursuit, Worldsplitter, dash, hurt, defeat, interact. Vertical guides mark x48; horizontal guides mark foot y48. `frame_bounds.json` records each frame's nontransparent bounds; all have padding inside their 96x64 cell. `walk_detail_6x.png` shows the gait at nearest-neighbor inspection scale, in down/left/right/up order.

Review covered character mass/palette, front/back identity, planted foot anchors, blade presence and full tips, action transitions and ground effect origins. Deliberate torso turns, crouches and the existing 13px presentation hop are poses, not per-frame scale changes. Automatic bounds checks cannot establish artistic quality alone; the direction boards and rendered capture provide the visual evidence.

Corrections:

- Front/back walk now uses one corrected reference sheet with opposite leading-foot contacts and passing poses; side poses are retained. Removed the separately generated front contact that changed the body/head appearance.
- Basic finishing sweep has horizontal blade motion instead of borrowing Skill 2's planted slam. New source frames 6/7 were rejected for missing/edge-touching blade artwork; recovery uses the approved guard. No replacement anatomy is drawn by the importer.
- Back-facing defeat no longer ends on a front-facing drawing. It holds the complete back-facing kneel. Dark-magenta source fringes are removed throughout the body sheets.
- Riftbreak plays all four preparation drawings, has one seven-frame impact and one residual, captures the actual contact world point, and retains its finite impact/residual after recovery. Its eight source contact anchors map to native (96,96); no debris bounding-box recentering.
- Pursuit's actual landing hit, crater and shockwave share King's current foot origin. Its travel, invulnerability duration, range, radius and damage values are preserved.
- Movement cadence no longer leaks into dash/reaction animation speed. Resolve's building/ready wording, hover explanation and simultaneous link cue are verified.

`riftbreak_cast_1_contact_*.png` isolates Skill 2's successive contact frames. Cast 2 shows the jump/Skill 2 link.

Source artwork and exact built-in imagegen prompts: `art_source/generated/characters/king/polish_2026_09_13/manifest.json`. New skill mechanics are proposals in `docs/design/king-action-kit-brainstorm.md`, not installed by this review. Full campaign balance and the owner's judgment of feel remain playtesting work.
