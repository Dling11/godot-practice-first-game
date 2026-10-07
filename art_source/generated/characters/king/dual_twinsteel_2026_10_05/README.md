# Twinsteel source and reproducible build

**Historical initial side ingestion.** Current correction uses `tools/build_king_dual_polish.gd` → `tools/build_king_dual_polish_fx.gd` → import. See `dual_polish_2026_10_05/README.md` and the current design guide. Original builders below alone would restore the older rejected gait/scale/exposure.

2026-10-05. Owner permits A as the default, keeps B Mooncut as a possible future curved design and authorizes a creative five-cut spin combo. These images were generated with the **built-in imagegen tool**, not CLI. Original outputs remain under `C:/Users/Administrator/.codex/generated_images/01a0eed4-5878-7032-a315-e493f92ce97a/`.

| Source | Exact prompt | Original output filename |
| --- | --- | --- |
| blade_source.png | blade_prompt.txt | exec-961a37e5-39d4-4a3b-8d0f-ab9c9967b561.png |
| body_source.png | body_prompt.txt | exec-695d4f00-4206-48b2-a504-115f7b105f47.png |
| run_source.png | run_prompt.txt | exec-d584fae0-5108-4545-af0b-7f9ef4bd8e87.png |
| fx_source.png | fx_final_prompt.txt | exec-dba46411-8ffb-45dd-a231-806d24932e4e.png |
| fx_source_v1.png — rejected | fx_prompt.txt | exec-073a6cfa-c255-460b-9d21-7469ce805f97.png |
| fx_source_v2.png — rejected | fx_spacing_prompt.txt | exec-5be1307a-ab24-4850-8d12-b90c5a1b3f76.png |

Reference roles: approved A weapon board for the blade; installed side/front/back King identity and complete side-carry reference for new body/run art. The final effect sheet is a fresh padded portrait layout, with silver-grey rather than saturated cyan and no edge-clipped finisher. Only the final source is consumed. All generated files retain true alpha. `generation_manifest.json` records hashes; raw rejected sheets are source history and not loaded by the game.

`tools/build_king_dual_twinsteel.gd` extracts50 connected attack bodies and16 carry/run bodies using the retained Oathbound helper pipeline. It applies one density per sheet, installed palette and complete side-head attachment at drawn crimson neck landmarks. The spin keeps complete generated turning bodies/heads, avoiding an independently rotated or duplicated head. Actual brown gloves receive separate blade anchors/axes and foreground masks. Fists are not inferred from the existing second shaft landmark. Canonical22×82 steel, grip(11,66), tip(11,0); rigid0.5 world scale. Relaxed carry/travel blade headings166°/14° clear the94logical-pixel sole plane at every registered key.

Five13-slot attacks use WIND0–3 / ACTIVE4–6 / released RECOVERY7–9 / queued RECOVERY10–12. Both grip tracks and complete body/mask endpoints are inherited. Only the last attack has explicit lift, at most8logical/4world pixels. Idle has8 recorded breathing/rest source cels, but the current runtime carry displays its first cel; a longer idle animation is not claimed. Run uses eight travel-driven leg-exchange cels.

`tools/build_king_dual_twinsteel_fx.gd` fits the fixed4×5 source into20 padded128×128 cells. Frame density stays fixed within a row; ignition/fade are not separately enlarged. The spin is centered on the melee pivot; ordinary forward cuts use a registered32px forward visual center. Existing trail geometry clips/feathers to authoritative contact shapes. FX never deal damage.

Rebuild from the project root with the console engine:

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_dual_twinsteel.gd
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_dual_twinsteel_fx.gd
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import --quit
```

Runtime assets live in `assets/characters/playable/king/dual_twinsteel/`. Nearest filtering, lossless imports, no mipmaps and disabled alpha-border fixing match registered-family conventions. `registration.json`/`fx_registration.json` preserve source bounds and per-key landmarks. A second build reproduces all23 runtime PNG/TRES files byte-for-byte (`rebuild_validation.json`). All79 recorded accepted axe/Greatsword/runtime files are unchanged.

Play `tools/launch_king_dual_twinsteel_review.ps1`; native proof is in `art_source/review/combat/king_dual_twinsteel_2026_10_05/`. Up/down, campaign equipment/recipes and normal skill/reaction/dodge flows remain pending. Exact rules and next work: `docs/design/king-dual-sword-design.md`.
