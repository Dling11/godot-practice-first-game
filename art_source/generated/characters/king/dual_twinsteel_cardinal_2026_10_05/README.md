# Twinsteel front/back source — 2026-10-05

**Historical initial vertical ingestion.** Owner subsequently reports shorter bodies and faulty gait. Current correction uses `tools/build_king_dual_polish.gd` → `tools/build_king_dual_polish_fx.gd` → import; see `dual_polish_2026_10_05/README.md` and the current design guide. Original cardinal ingestion alone would overwrite corrected proportions/running.

Owner accepts the fast side pass and requests proper top/bottom attacks. Built-in image_gen produced these three transparent raster sheets; exact prompts are alongside them. These are new reference-guided images, not edits of accepted runtime atlases.

| Source | Original generated output | Content |
| --- | --- | --- |
| up_source.png | exec-2b47b036-146e-47fa-ae80-864121ec2b93.png | 50 complete back-facing attack cels, five rows of ten |
| down_source.png | exec-9c275c0f-d482-44d5-a957-424ad368089d.png | 50 complete front-facing attack cels |
| gait_source.png | exec-145a634d-815c-4254-8475-57da7c69f82e.png | Front carry/run, back carry/run; four rows of eight |

Reference roles: accepted Twinsteel body/run sources establish proportions and stroke style; installed_identity_reference.png establishes King's exact side/front/back identity. All references were viewed before generation. generation_manifest.json records source/prompt/reference/output hashes.

Offline ingestion uses the existing complete-body extraction, fixed density per source/view, installed palette, foot anchor(96,94), 192×128 cells and canonical22×82 blade. Ordinary front identity is attached at its drawn neck. Back reference is hair only, preserving drawn shoulders. Spin retains whole generated turning heads and bodies. Real brown glove regions are registered before identity composition, excluding thin belt strips and boot tops; raised brown fingers are restored in front. Five authored source poses occlude the far fist; the far blade is hidden in those poses rather than mounted to the belt. registration.json records each pose, grip, identity, density, floor and occlusion.

Each direction has65 attack slots plus16 carry/run slots. WIND0–3, ACTIVE4–6, released recovery7–9, queued recovery10–12; shared body, hand, both shaft and visibility endpoints are inherited. The original side/blade/FX are never rewritten. Vertical carry175°/5° clears the sole plane. No additional idle ritual or breathing timer is implemented.

Rebuild from project root:

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_dual_twinsteel_cardinal.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import --quit
```

Native verification (run GUI fixtures sequentially when focus/input matters):

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tests/king_dual_twinsteel_cardinal_smoke.gd -- --capture
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --resolution 1280x720 --script res://tests/king_dual_twinsteel_review_smoke.gd
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_king_axe_motion_gif.ps1 -ReviewFolder king_dual_twinsteel_cardinal_2026_10_05
```

Motion3063/0; playable review89/0;105 decoded GIF frames.42 new runtime PNG/TRES outputs rebuild identically.23 accepted side and79 previously recorded heavy-family files remain unchanged. Native contact/pose evidence and assembled front/back galleries are in art_source/review/combat/king_dual_twinsteel_cardinal_2026_10_05/.

Play tools/launch_king_dual_twinsteel_review.ps1: W/A/S/D, SPACE/click, G combo, Tab controls, Esc pause. The profile is isolated; no F5/Bag/catalog, crafting, armor, normal Player skill/reaction/dodge or final balance promotion. Technical checks do not establish owner vertical art acceptance.
