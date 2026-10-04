# King gait correction V3 — 2026-10-04

Owner rejects the prior run and requests side/back deep planting while retaining crossed arms. Built-in image_gen generated two unchanged transparent source sheets: sixteen full run poses and four narrow passing keys. Exact prompts are in prompts.json; source paths/checksums are in manifest.json.

Runtime registration is reproducible: build_king_confidence_v2.gd first for opening/idle definitions, then build_king_gait_repair.gd to replace both registered run clips, then Godot import. Face center is registered at (107,61) with a one-pixel logical bob; do not center each frame on its lowest foot. One uniform density per source sheet. Passing keys replace indices2/6; metadata records all sources, density and attachment anchors. Canonical axe/greatsword remain unchanged. Runtime stays under greatsword_confidence_v2/ to preserve existing references.

This corrects a review candidate, not owner approval of gait. Eight distinct hashes do not prove good animation. Inspect every frame and the actual distance-driven loop at native size. Current evidence: art_source/review/combat/king_gait_loop_v3_2026_10_04/ and king_gait_repair_v3_2026_10_04/. Up/down and normal equipment integration remain pending.
