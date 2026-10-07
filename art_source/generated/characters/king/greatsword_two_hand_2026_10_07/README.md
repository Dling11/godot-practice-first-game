# Greatsword paired-hand source

2026-10-07. Built-in imagegen produced body_source.png (48 preparation/recoil cels) and contact_source.png (18 explicit two-hand contact cels). Exact submitted prompts and references are in prompts.json; original source hashes are in source_manifest.json. Sources retain generated transparency and are excluded from Godot imports with .gdignore.

Offline tools/build_king_front_combo_preview.gd uses explicitly calibrated transparent row gutters for the first source, filters low-alpha dust and removes the magenta source-only contact handle before connected-component extraction. Both real palms register on canonical30x140 steel,7 logical texels apart. Native heads/palette replace source identity; genuine foreground palm occlusion is retained. Selected preparation/contact poses have one density per source; the earlier full-body spin retains its original source and density as the single one-hand exception. Existing slash raster art is reused unchanged.

registration.json records source density/selection, both original/final grip anchors, actual two-hand flags and native-head regions. Runtime destination remains assets/characters/playable/king/greatsword_front_combo_preview/. No live family/player/equipment changes. See docs/design/king-greatsword-front-combo.md and art_source/review/combat/king_greatsword_two_hand_2026_10_07/ for replay/proof.
