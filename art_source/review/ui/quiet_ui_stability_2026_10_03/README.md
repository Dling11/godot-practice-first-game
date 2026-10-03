# Quiet homepage/loading stability

2026-10-03 · Godot4.7 native Compatibility/OpenGL AMD,960x540.

Source geometry confirms shared112x112 engraving poses drift:666–1736 alpha pixels change versus first frame, ornament bounds shift. Runtime keeps frame0 engraving/alpha fixed and animates light on the real Sprite clock. Unique per-instance material; hidden ancestry disables processing. Title specks fade at fixed pixel positions. Source raster files unchanged.

- stability_native.log:195 checks,0 failures on actual title/loading views. Eight frames and halfway phases have identical silhouette; real changing light and exact loop seam; paused UI advances; stopped hidden seal does no process; material independence; six title glimmers remain planted; loading King and actual percentage retained.
- integration_native.log:55/0, real resource transition seal/King7/13; native title_native.log passes. Headless title_continue_smoke passes against isolated storage.
- title_native.gif/loading_native.gif:24 native10fps frames each, title/loading view unchanged in scale. Loading shows labelled37% rehearsal, not resource progress. Existing stage gallery captures/loading GIF refreshed. source_geometry.json/rendered_geometry.json and8 crops per actual seal retained.

Reproduce native tests/quiet_ui_stability_smoke.gd, then powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_stage_presentation_gifs.ps1 -QuietUiStability. Rendering is required; tests isolate/suppress profile storage. Create the log directory before passing --log-file to this Godot version (a missing directory caused a pre-start engine crash). GIF tooling parses real control/data blocks before adjusting delays.

Existing two Texture/RID5460byte shutdown warnings and early-exit ObjectDB references remain. No profile bytes restored. Restart running playtest for updated scripts/materials.
