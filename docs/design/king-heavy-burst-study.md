# King heavy-burst motion study

2026-10-06. Status: **historical first study, archived**. Owner clarifies Greatsword-only front slash → return → spin → jump strike, and defers scythe. Read [the current four-move study](king-greatsword-front-combo.md). First-study resources/scripts now reside under art_source/archive/heavy_burst_first_study_2026_10_06/; old GIFs/raw sources remain for comparison. The old tool paths and scythe-switch instructions below are historical. Installed Royal Greatsword remains accepted Oathbound.

## Protection and scope

[Verified backup](../../art_source/archive/greatsword_finished_before_burst_redesign_2026_10_06/README.md): 679 files, 6,107,292 bytes, original relative paths and SHA256 manifest. Includes King assets, Greatsword data/audio, shared movement/presentation/player dependencies and relevant tools/tests. All 679 original files matched the snapshot after building and rendering; all backup copies also matched. Later handoff/document edits are intentional, not runtime changes.

Retain the exact 30×140 Greatsword texture, grip(15,113), installed carrying/gait/proud idle, King palette/head, inventory definition and combat authority. No catalog, Player, contact sound, damage, reach, save or skill change is made by this study. Production still has a3.00s five-cut chain; these previews do not retune it.

## Internet reference: verified facts versus interpretation

[ChillyRoom's Alasdair listing](https://store.steampowered.com/app/2494740/Otherworld_Legends__Alasdair/) describes an exceptionally heavy sword, conversion of attack-speed bonuses into damage, protection against stunlock while swinging, and a timed follow-up called Overpower. It does not publish phase timings or animation frame counts. These mechanics support strong commitment and timing; they do not establish that every phase should run faster.

[ChillyRoom's official press kit](https://www.chillyroom.com/en/game-news/11/79) emphasizes responsive controls, pixel animation and distinct hero playstyles. It links [the gameplay trailer](https://www.youtube.com/embed/80jL0LVIWjo) and [Penhaligon's presentation](https://www.youtube.com/embed/XZS8jGj6XU0). Video fetches were throttled and the Alasdair animation asset could not be inspected through the browser tool. **No frame-by-frame measurement of Alasdair or other heroes is claimed.** No copied game artwork ships here.

Our interpretation of the owner's desired direction: readable loading, an explosive short release, large blade-following white ribbons, and weight in the body's recoil/landing. These are original design choices, not recovered timings from another game.

## Original sample

Five forward-facing strokes: descending sweep → rising return → low hop slam → diagonal cut → return stroke. Generated full bodies provide knee/hip/chest motion; the native installed head is registered at the drawn scarf/neck. A fixed density across the source keeps the body from growing on impact. Only the slam has authored lift, capped at12 logical texels. Canonical rigid steel follows drawn glove anchors and foreground fingers.

The prototype uses wind-up0.14/0.12/0.19/0.12/0.12s, four60Hz contact samples per cut (66.7ms), and follow-through0.16/0.16/0.22/0.16/0.18s. Total1.9033s. Queued body/grip/blade endpoints match the next entry exactly. Short visual steps total53 normal world pixels. They are **presentation-only, without collision/damage authority**, and must be converted to collision-checked gameplay steps before promotion.

Original generated raster FX have three four-key rows: descending, rising and slam. Each painted leading point follows the actual rigid weapon tip; a static origin previously floated above the swing during assembly and was corrected. Effects render behind anatomy, preserve complete silhouettes, and have no golden ring. Review canvases have enough margins for every visible blade/effect. These aesthetic choices still require owner judgement.

The scythe is an original hooked silver blade with a dark shaft and restrained red binding. It borrows these side body poses to test silhouette and slash language. It has no item, finished family-specific combo, directional locomotion, skills, damage or acquisition rules. This does not establish an approved scythe design.

## Files and replay

`tools/build_king_heavy_burst_preview.gd` extends existing offline ingestion helpers but overrides initialization; it writes only `assets/characters/playable/king/heavy_burst_preview/`. The installed builder is unchanged. `tools/review_king_heavy_burst.gd` uses the real WeaponFamilyPosePresenter with an inert melee component and a deterministic study clock. It creates no Player or persistence service. Reuse shared pose definitions; do not create a second live combat clock.

Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\launch_king_heavy_burst_review.ps1`. Space replays, Tab switches Greatsword/scythe, Escape closes. Both mirrored side views loop. Greatsword startup briefly shows the exact accepted side gait. The display enlarges normal world sprites2.4×. This is an isolated preview, not normal F5 equipment.

Raw PNGs, prompts and registration: [source folder](../../art_source/generated/characters/king/heavy_burst_2026_10_06/README.md). Rendered evidence and GIFs: [Greatsword](../../art_source/review/combat/king_greatsword_heavy_burst_2026_10_06/README.md), [scythe](../../art_source/review/combat/king_scythe_heavy_burst_2026_10_06/README.md).

## Validation and next work

Godot4.7.2 native Compatibility renders: Greatsword2780/0, scythe2775/0. Checks include valid resources, opaque actual grips, native body margins, exact queued boundaries, canonical steel, visible blade/FX canvas bounds and preview switching/replay. Each GIF decodes as193 frames with timing from the60Hz study clock. These are deterministic art checks, not performance profiling or owner feel approval. All22 generated PNG/TRES outputs rebuild byte-identically.

Next: owner reviews pace, body identity and slash shape. After a chosen direction, author true front/back attacks with the same identity; validate isolated Player integration, real contact timing, collision-safe steps, released recovery/dodge/cancel behavior and balance. Preserve all accepted locomotion/idle when promoting attacks. Scythe needs silhouette/grip selection and its own weapon-specific motion before normal gameplay installation.
