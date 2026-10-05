# Three greatsword motion and slash concepts

2026-10-04. Generated with the built-in image_gen tool. Status: owner-choice storyboards; no selected gameplay replacement.

- [Exact three generation prompts](prompts.json), [exact spacing-edit prompt](spacing_prompt.txt), [source hashes/provenance](manifest.json).
- a_source_v1.png / b_source_v1.png / c_source_v1.png are the initial generated sheets. a_source.png / b_source.png / c_source.png are the spacing-corrected sheets.
- Identity reference: art_source/generated/characters/king/iron_beard_motion_proof_2026_10_04/references/light_leather_king.png. Steel reference: art_source/generated/characters/king/huge_greatsword_2026_10_04/weapon_source.png.
- Twenty chronological body/weapon/slash keys per choice; all three use different five-strike patterns, body movement and slash silhouettes/palettes.

Render tools/render_greatsword_combo_concepts.gd, then encode tools/build_greatsword_combo_concept_gif.ps1 -Choice a/b/c individually. The renderer isolates full raster components across nominal cell edges, adds padding, uses a uniform source scale and registers boots vertically with explicit jump offsets. Pixel alpha cutoff20/255 and tiny detached noise filtering are documented; original PNGs remain unchanged.

Final GIFs: art_source/review/combat/greatsword_combo_choices_2026_10_04/a/motion.gif, b/motion.gif and c/motion.gif. Each contains20 decoded frames, authored delays and an infinite loop. All-key galleries, foot/margin audit and validation accompany them. See docs/design/greatsword-combo-art-choices.md for scope and next production steps.
