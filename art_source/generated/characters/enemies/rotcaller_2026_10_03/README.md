# Rotcaller prototype sources

Built-in imagegen originals: walk_source.png (four directions), actions_source.png (staff rise, release, struck/recovery, death), south_walk_source.png (dedicated down-facing replacement). Exact walk/action/south requests are preserved beside them. The original south row had inconsistent staff placement and is replaced in the runtime atlas; other directions retain their source drawings.

tools/build_rotcaller_art.gd uses technical crop/alpha0.7/nearest normalization, uniform source-resolution factors,64px cells and the fixed y56 foot baseline. normalization.json records native sizes/origins. Runtime walk/action atlases and24 SpriteFrames animations live under assets/characters/enemies/rotcaller/. Native combat evidence: art_source/review/characters/rotcaller_2026_10_03/. These are first playable drawings awaiting owner acceptance, not campaign-balance approval. See docs/design/stage-4-eastern-rot-and-rotcaller-trial.md.
