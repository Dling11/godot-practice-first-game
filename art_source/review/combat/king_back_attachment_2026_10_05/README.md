# Upward Greatsword head/torso attachment — 2026-10-05

Owner clarifies the upward head/torso split and rejects the prior smaller, upward-only white effects. The old carry identity rectangle included scarf/shoulder art, and an asymmetric scarf landmark placed the head sideways. The corrected up builder references hair only, aligns source scalp center/bottom and preserves the drawn collar/torso. No new source image generation was necessary. Side/down attacks, huge steel, locomotion/proud idle, damage/reach/timing and phase walking remain.

Review `motion.gif`: the actual production Player chain in four views beside the unchanged axe, fixed60Hz simulation and30fps readback,130 looping frames. This uses real buffered attacks rather than manually sampled body art. GIF frame/loop metadata was decoded after encoding.

Each `{sweep,rise,slam,turn,return}_body_comparison.png` shows five source moments: **top raw registered drawing; middle the rejected full head/scarf transplant; bottom installed hair-only correction**. Natural source torso lean remains; the head is attached to its own drawn scalp, not forced onto a stationary foot-center axis. `attacks/after/` contains46 native queued up poses and galleries; empty slots are released branches not observed during the queued chain.

`carry_0.png` through `carry_7.png` inspect the8 actual run keys in four facings. Side run is shoulder-held; up/down run is deliberately back-stowed, hands free, sword behind the body and no holding-hand mask. The down gait was checked and preserved. `carry_inspection.json` records the actual production routing/anchors.

Validated with native Godot4.7.2 Compatibility unless noted:

| Evidence | Result | Scope |
| --- | --- | --- |
| anatomy_validation.json / anatomy.log |216/0, headless offline|54 up poses: scalp center/bottom, exact below-scalp collar/torso pixels, hair-only reference|
| validation.json / motion_native.log |2901/0|four-facing full combo, identity/anatomy, hands/steel, entry/release/queue, timing/travel, actual130 frame captures|
| slash_style_validation.json / slash_style_native.log |84/0|16 ordinary frames in four actual transparent viewports; opaque coverage agrees within2% raster tolerance|
| readability_validation.json / readability_native.log |158/0|phase walking, knockback/dodge, proud rest and up body/FX occlusion|
| gameplay_native.log |151/0|actual Sanctuary/Bag equipment and combat routing|
| confidence_native.log |83/0|preserved pride/run/plant/retrieval after removing obsolete opening-clip audit|
| practice_native.log |17/0|visible practice Bag, Tab/Esc, movement/attack and F9|
| preservation_validation.json |40 unchanged /15 up changed|55 prior runtime files; all changes are up attack atlases/resources|
| cardinal_preservation_validation.json |12 identical|retained up/down carry/run after builder cleanup|
| deterministic_validation.json |55 identical|fresh Oathbound rebuild reproduces current runtime files|
| archive_validation.json |66 intact entries|65 moved files plus copied old builder match archive hashes|
| import_final.log |no script/resource errors|editor import after archive moves and derived rebuild|

Shared ordinary FX sampling is restored; meteor alone uses blade-specific transforms. This proves directional raster density, not that every texel of the full source atlas fits inside every contact polygon. The previous smaller full-envelope fit is explicitly owner-rejected history under `king_upward_cut_2026_10_05/`.

The first `motion_headless.log` diagnostic omitted fixed simulation FPS and ended its130-loop fixture before the timed chain finished. The actual native fixed-FPS run passes; that early diagnostic is not a runtime defect claim. Practice still reports the preexisting57 ObjectDB instances at process exit. That separate transition diagnostic is documented, not claimed repaired here. Owner visual judgement/device profiling remain open.

Reproduce from the project root using `D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe`:

```powershell
# Offline anatomical proof
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script tests/king_back_attachment_smoke.gd
# Native full chain (native RenderingServer readback is required)
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script tests/king_oathbound_greatsword_smoke.gd -- --capture --output=res://art_source/review/combat/king_back_attachment_2026_10_05/
& ./tools/build_king_axe_motion_gif.ps1 -ReviewFolder king_back_attachment_2026_10_05
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --script tests/king_directional_slash_style_smoke.gd
```

Owner test: restart F5 → Sanctuary → F9 → Tab → Royal Greatsword → EQUIP ITEM → close Bag, attack upward and buffer the whole combo. F9 suppresses saving. Cleanup manifests are under `art_source/archive/{greatsword_back_attachment_cleanup_2026_10_05,upward_slash_fit_rejected_2026_10_05}/`; raw sources and earlier evidence remain. No commit/push.
