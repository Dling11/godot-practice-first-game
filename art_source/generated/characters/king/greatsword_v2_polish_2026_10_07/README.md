# Greatsword V2 polish source

Four raster sheets generated with the built-in image_gen tool on2026-10-07. Exact prompts, reference roles and original filenames are in [prompts.json](prompts.json). Raw alpha sources remain unchanged.

- up_body_source.png:24 full-body up-facing sweep/return/jump drawings.
- down_body_source.png:24 full-body down-facing sweep/return/jump drawings.
- jump_source.png:8 side jump/momentum bodies.
- slash_source.png:16 independent heavy Greatsword FX cels; axe raster art is not copied.

Offline ingestion: tools/build_king_front_combo_preview.gd. Fixed density per directional source; native approved heads/palette, sole plane95, actual brown glove grips and canonical30x140 steel. Side hilt spacing7texels; projected new vertical pairs6texels. Two-hand load angles may follow drawn glove geometry; exact frontal contact angles remain. Up/down bodies use54-texel standing source density rather than scaling every pose. Carry/run/proud idle keep their approved artwork.

Generated grids are calibrated explicitly: slash row edges0/332/650/901/end; row-specific column gutters, common row fit within144texels and at least24texels cell padding. Old side-source neighboring islands are removed before shared-density registration. Packed pose arrays are duplicated before spin reordering. Authored side spin bodies are reused through actual directional turn poses; no runtime detached arm/head rig.

Runtime output:38 PNG/TRES files under assets/characters/playable/king/greatsword_front_combo_preview/. New clips all have16 load/contact/released/queued keys with exact queued endpoints. Original V1 is preserved. [Current native proof](../../../../review/combat/king_greatsword_v2_polish_gameplay_2026_10_07/README.md).

Rebuild with the project engine: headless builder, editor import, tools/review_greatsword_v2_cardinal.gd and tests/king_greatsword_v2_gameplay_smoke.gd with native Compatibility rendering. Frame hashes and retained source hashes accompany this source. Rendering checks do not replace owner feel approval.
