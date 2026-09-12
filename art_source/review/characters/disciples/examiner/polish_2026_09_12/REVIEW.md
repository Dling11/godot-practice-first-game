# Examiner follow-up review

Use F7 or the root `Play Examiner.cmd`. King begins invincible; turn the toggle off for a fight.

- `examiner_polish.mp4`: captured Godot presentation with sound, four-direction walking, left thrust, charge, slam, Refutation, Axiom, and Divine Descent.
- `walk_contact_sheet.png`: four real gait poses per direction. Contacts are columns 0 and 2; columns 1 and 3 pass the opposite knee.
- `attack_audit_1.png` and `attack_audit_2.png`: directional action silhouettes.
- `frame_audit.json`: all 336 packed body cells, transparency and minimum padding.
- `12b_descent_peak.png`: expanded slate eruption after the brief contact silhouette.

Built-in ImageGen sources and full prompt history: `art_source/generated/characters/disciples/examiner/polish_2026_09_12/`. The final walk sources are `walk_down_final.png`, `walk_profile.png`, and `walk_up_final.png`; earlier gait attempts are comparison material. `slam.png` repairs the original overlapping source. Final effect sources are `energy.png`, `axiom_beam.png`, `sweep.png`, `impact.png`, and `telegraphs.png`.

Rebuild body/effect assets with `tools/process_examiner_rework.py`, reimport Godot textures, then run `tools/build_examiner_rework_frames.gd`. `tools/generate_examiner_rework_sfx.py` reproduces the original audio. `tools/audit_examiner_art.py` and `tools/capture_examiner_polish.gd` regenerate review evidence.

Checks: Python extractor regressions; Examiner trial, Examiner rework, effect lifecycle, Combat Lab, and runtime/archive smoke tests. Capture is scripted using the real controller and presentation, not a player playthrough. Final feel/mix remains for owner review; production Stage VII is still pending.
