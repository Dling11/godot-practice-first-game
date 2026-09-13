# King skill comparison — discussion only

Open `index.html` for all eight installed skill GIFs and separate basic-attack/walking references. Each card can record Keep as reference / Rework / Replace and a suggested tier, then collect those choices into copyable notes. The page never writes game data.

The owner paused gameplay and character-art work. Old skills were retained in Decision 147, while the owner expected replacements. Higher skill numbers should represent stronger progression tiers; the current old/new collection and latest Skills 2/3 are not an approved final kit. King should remain compact and pixelated, with more detailed future art. Choose references and replacements before further implementation.

These GIFs show actual installed behavior at normal speed, 640x360 and 24 FPS, not generated future concepts. The latest four use their base Mortal form. Targets are stationary for visual comparison. Worldsplitter uses a wider camera to keep its spirit sword visible; do not infer relative area size from differing camera magnification. Breakstep shows its movement cast, without triggering the conditional riposte. GIFs have no sound.

| Original installed skill | Latest installed skill |
|---|---|
| echoing_sever.gif | crosscut_advance.gif |
| riftbreak.gif | griefwake.gif |
| sovereign_pursuit.gif | starfall_step.gif (Breakstep) |
| king_skill_4.gif (Worldsplitter) | oathstorm.gif (Last Oath) |

`basic_combo_clean.gif` and `walking_clean.gif` are body-only references, recorded without targets. The historical stable filenames for Breakstep/Last Oath match existing save IDs; the gallery shows current display names.

Capture tool: `tools/capture_king_skill_choices.gd`. Create this folder before invoking Godot movie capture. `-- --body-only` writes separate `body_segments.json`; its movie should be named `body_capture.avi`. Export tool: `tools/export_king_skill_choice_gifs.py --ffmpeg <executable>`; `--body-only` updates the body references, and `--gallery-only` regenerates the page from existing GIFs. Intermediate AVIs are removed after export validation.

## Owner review — 2026-09-13

| Reference | Feedback for the next design review |
|---|---|
| Echoing Sever / Crosscut Advance | Echoing Sever is acceptable; prefer the latest Crosscut animation and improve it further. |
| Riftbreak / Griefwake | Prefer Riftbreak visually; it needs richer animation frames. |
| Sovereign Pursuit / Breakstep | Prefer Pursuit. Reject Breakstep for the future kit. |
| Worldsplitter | Retain as a potential reference; use lighter/pure-light energy, better animation, and a fast release that lets King move independently of the lingering effect. |
| Last Oath | Keep the liked rotating visual idea as a reference; the skill needs a more creative gameplay concept. |

The owner expects substantial replacement and improvement, not preservation of all eight choices. Higher tiers must feel progressively stronger. These insights do not finalize the new kit; gameplay and character-art implementation remain paused. Breakstep has not been deleted from runtime.

All ten final GIFs decode successfully. Representative contact/body frames were inspected, and both Godot capture runs finished without script errors. Only capture/export tools, review artifacts and the project pause notes were changed for this request; gameplay and runtime character art were not edited.
