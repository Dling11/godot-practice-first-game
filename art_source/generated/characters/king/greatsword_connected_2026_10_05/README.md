# Connected Greatsword art provenance

**Owner-rejected presentation:** The owner rejects the whole motion, grip/rotation and slow pacing. Generated modular sources/runtime clips are retained for history and are not referenced by current Royal Greatsword game/review. Current motion reuses complete installed cels; see `docs/design/king-greatsword-responsive-motion.md`.

Generated with the built-in imagegen tool, using local installed character art as references. No external CLI/API or plugin was used.

- `modular_source.png`: selected arm-free edit of `existing_style_reference.png`; exact prompt in `STYLE_PROMPT.md`.
- `protected_body_reference.png`: twelve verbatim original native cels, exported by `tools/export_king_motion_style_reference.gd`.
- `existing_style_reference.png`: the same board enlarged exactly 2x with nearest sampling for the tool reference.
- `registration.json`: common source-body density, explicit shoulder sockets, protected identity regions and boot baseline. Detached limb pieces have explicit runtime dimensions.
- `rejected_armor_style_source.png`: rejected first design's background-cleanup variant. Large round armor and extra trim depart from the approved Spellward baseline. It has no runtime reference. Original generation prompt is retained in `INITIAL_PROMPT.md`.

The selected edit is not trusted to preserve identity by itself. The builder restores protected original head/face and boot pixels, plus original central cloth where no baked skin/glove is present. Runtime body cels are bounded composites; new arms are articulated over them. Sword/carry/run/planted-idle assets are the existing files.

Rebuild after changing registration: run Godot headless with `--script res://tools/build_king_connected_greatsword.gd`, then import the project. Export the reference board only when deliberately refreshing its original source inputs. Runtime outputs live under `assets/characters/playable/king/greatsword_connected/`; the builder also writes the shared Royal Greatsword pose root. Source PNGs and previous user work are retained. Pre-edit mutable-file backups are under `D:/WORK_APP/godot-backups/greatsword-polish-20261005/`.

Current rules and validation: `docs/design/king-greatsword-motion-polish.md`. Appearance/feel remains subject to owner judgement.
