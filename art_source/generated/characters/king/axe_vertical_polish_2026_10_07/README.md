# Iron Beard vertical registration

2026-10-07, Decision192. This folder records offline ingestion metadata, not a newly generated character sheet. `body_registration.json` records each registered head, anatomical density, sole plane, view/lane and attack name.

Immutable inputs: `assets/characters/playable/king/axe_cardinal/{up,down}/` original cuts/idle/run and `art_source/generated/characters/king/axe_head_thrust_2026_10_06/{up,down}/push_{body,hands}.png` plus their original body registration. Their source prompts remain with the original dated generation folders.

Builder: `tools/build_king_axe_flow.gd`, sharing `tools/king_cardinal_body_registration.gd`. Run with the configured Godot console using `--headless --path . --script res://tools/build_king_axe_flow.gd`; import with `--headless --editor --path . --import --quit`. Rebuilding never reads its own normalized outputs. Side output and common FX reproduce identically.

Runtime: `assets/characters/playable/king/axe_flow/{up,down}/` has five attacks plus sibling idle/run resources. Complete raster nearest sampling, fixed head density, preserved source forearms/palms and one density per view/lane retain authored motion. Register raw cuts before copying the exact ready and previous-combo endpoints. One-hand secondary anchors describe shaft orientation, so preserve their vector relative to the moved palm. Steel is not resized. New PNG imports use lossless/no-mipmaps/no alpha-border fixing; the presenter uses nearest filtering.

[Native review and rollback](../../../../review/combat/king_axe_vertical_polish_2026_10_07/README.md) · [Rules and scope](../../../../../docs/design/king-axe-cardinal-motion.md).
