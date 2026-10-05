# Oathbound head/neck correction — 2026-10-05

Owner accepts hitting motion partially but finds cropped/floating heads. A fixed rectangular graft plus cleared halo separated the original head from moving torso/shoulders. The original unchanged-pixel assertion missed the anatomical defect.

Current ingestion detects the dense scalp independently of thin raised-arm outlines, anchors the complete installed head to the actual crimson neck socket, preserves cool cloth and foreground raised fists, and alpha-composites silhouette edges. It removes tiny discarded scalp islands. Head/body/gloves remain in one complete raster cel; no independent head animation or runtime solver is added.

`before_necks.png` and `after_necks.png` enlarge actual atlas bodies4× with nearest sampling over a flat background. Rows: side/back/front. Columns: original carry, opening windup1, contact4, recovery7. These are atlas samples, not separate gameplay animations. The opening side windup previously had body/head components533/416 pixels plus fragments; it now has one1030-pixel component. All twelve final samples have one visible connected body component. Log: `neck_inspection.log`.

`motion.gif` / `motion_frames/` / `motion_timeline.json` are native actual Player all-facing five-hit playback alongside unchanged axe, with fixed60Hz simulation and30fps capture.130 frames; GIF metadata/decode verification passes.

Native `validation.json` / `motion_test.log`: **2381 checks,0 failures**. Every head connects to substantial torso pixels and its registered glove; opaque crown coverage is complete. Visible original face/lower-hair identity stays exact except actual foreground brown glove occlusion, verified against the same hand atlas. Rigid steel, full queued endpoints, late/standalone entry, carry return, full input chain,46px physical travel, equal fourth/fifth duration, broad white FX and four directional tip-aligned slam bursts remain covered.

Native current regressions: gameplay151/0, contact60/0 and preserved idle/run101/0. Sources, attack pattern, nominal3.00s timing, damage/reach/knockback, collision travel, carry/run/proud idle and controls remain. Registered grips follow final visible hands.

Original source PNGs/prompts are unchanged. `rebuild_manifest.json` records current runtime asset hashes. Initial Oathbound1601 evidence remains historical at its old path. Existing unrelated transition-exit diagnostics and owner animation judgement remain open; this does not establish phone performance or final balance.

Current implementation/access: [Oathbound motion](../../../../docs/design/king-greatsword-oathbound-motion.md).
