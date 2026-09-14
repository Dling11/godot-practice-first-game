# Upward Earthsplitter stray-line fix

`before.png` reproduces the distant lower-left line with the old 4x4 sheet framing. `after.png` uses the production clipped frame region, with the same source PNG, scale, position and rotation. The faint sliver is around image coordinates x281-337, y534-590 before; those pixels are clear afterward.

Reproduction requires transform and vertex pixel snapping, matching the project viewport. Scale .7 exposes the issue at noninteger desktop presentation. Default SubViewport snapping is off and did not reproduce it.

Run Godot with `--path . --rendering-method gl_compatibility --script res://tests/earthsplitter_atlas_render_smoke.gd` and a display, not --headless. The 29 checks include a positive control reproducing the old defect and all seven windup frames at two scales/two subpixel positions using the production selector. The normal Earthsplitter smoke test passes 116 gameplay checks.

The approved sword and explosive ground baseline remain intact. This corrects rendering boundaries only. Godot's [Sprite2D region clipping contract](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html#class-sprite2d-property-region-filter-clip-enabled) describes the neighboring-texture clipping behavior used here.
