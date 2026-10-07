# Greatsword V2 jump/impact source — 2026-10-07

Original raster artwork generated with the built-in imagegen tool. Exact submitted prompts, reference intent and source result filenames are retained in [prompts.json](prompts.json). References were approved native King carry, existing paired-hand contact art and established white/silver slashes. No external game's frames are copied.

- jump_source.png: two rows of four complete bodies. Magenta handle guides are removed offline. One sheet density, native crowns/faces, connected paired palms and a ground-plane blade solve preserve King and canonical30×140 steel.
- impact_source.png: two rows of four padded effects. Row1 replaces the jump release only; row2 creates the separate landing atlas. Offline cleanup removes cyan generation artifacts; runtime uses white/silver/charcoal raster textures.
- source_hashes.json identifies source/prompt files; runtime_hashes.json records38 reproducible PNG/TRES outputs.

Builder: tools/build_king_front_combo_preview.gd. Run headless in Godot4.7.2, then import. It writes assets/characters/playable/king/greatsword_front_combo_preview/ and registration metadata. Existing V1 vertical resources are read and cloned into labelled fallback wrappers, never overwritten. All38 outputs repeat identically;26 PNG imports are lossless/no mipmap/no alpha-border fix, with nearest runtime sampling.

.gdignore keeps raw sources out of runtime/import/export scans. [Rules, actual footage and limits](../../../../../docs/design/king-greatsword-front-combo.md).
