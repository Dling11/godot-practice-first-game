# King momentum, confident stance and run sources

2026-10-04. Built-in image_gen with exact King/body reference. Both original PNGs remain byte-for-byte unchanged; [manifest/checksums](manifest.json), [exact prompts](prompts.json), [registered crops/density/hands](registration.json).

- action_source.png: eight loaded greatsword opening poses, eight confident one-hand carry/plant/arms-crossed poses.
- run_source.png: eight alternating contact/pass/opposite-contact/pass poses for free-arm axe back carry, eight with one steady greatsword shoulder hand.
- Whole connected bodies are segmented before export; one calibrated density per sheet, support floor(96,96),192x128 cells at0.5 scene scale. Hands are authored coordinates, snapped only near their local opaque edge. Released pride poses keep the planted sword anchors fixed and omit hand masks; local behind-body order exposes crossed arms.
- Existing canonical greatsword/axe rasters are reused unchanged. One-handed virtual secondary anchors specify shaft direction, not a fake grip. Axe run has free hands and a fixed back attachment.

Runtime assets: assets/characters/playable/king/greatsword_confidence_v2/. Build tools/build_king_confidence_v2.gd after huge-greatsword/axe assets, then editor import. Launch existing greatsword/axe PowerShell tools; A/D moves with real collision, SPACE attacks, ESC pauses. Greatsword has a plant/pride button and4s AFK timer; retrieval precedes attacking or running.

[Native gallery](../../../../review/combat/king_confidence_v2_2026_10_04/gallery.png), [200-frame action/run/pride GIF](../../../../review/combat/king_confidence_v2_2026_10_04/motion.gif), [complete scope and controls](../../../../../docs/design/king-huge-greatsword-review.md). New suites: confidence82/0, axe run10/0, atlas isolation6/0. Existing axe495/0 and edge25/0 plus melee/style regressions pass. Full up/down art, armor/action layers, normal F5 equipment/crafting and final balance remain pending.
