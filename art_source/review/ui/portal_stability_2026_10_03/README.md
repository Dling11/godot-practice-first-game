# Portal frame stability correction

2026-10-03; native Godot4.7 Compatibility/OpenGL, AMD,960x540.

The source atlases have unchanged generated shape drift. source_geometry.json records raw body centers/used bounds/alpha changes. Runtime uses a fixed reference silhouette and measured whole-pixel current registration, with adjacent-color interpolation tied to AnimatedSprite frame_progress. Rendered geometry is fixed; interior energy and internal hand shading remain animated.

- stability_native.log:144 checks,0 failures. Every authored-scale frame and halfway blend has identical alpha across all six variants; three inner zones change with rim glimmer disabled. Frame7 blend1 equals frame0; real gameplay pause freezes frame/progress/blend. rendered_geometry.json and *_registered.png retain evidence.
- integration_native.log:54/0; actual F/failure prompt, all variants/lightning, title/loading/pause and real StageI arrival. Loading seal/King changed7/13 frames. Focused headless portal_interaction_smoke and scene_transition_smoke also pass.
- comparison_native.gif:32 rendered10fps frames, raw source left and corrected runtime right, same Calm/Grasp tier scale beside native King. Separate lightning is hidden only to make body drift readable. comparison_frames retains source captures. This GIF is a short comparison clip, not the exact8-frame cycle; rendered seam checks are separate.
- motion_native.log records56 refreshed native Grasp/Maw/loading captures in ../stage_presentation_2026_10_03/; complete production lightning remains there.

Reproduce from project root with the configured Godot console:

```powershell
& "D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe" --headless --path . --script tools/audit_portal_frame_geometry.gd
& "D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe" --path . --script tests/portal_surface_stability_smoke.gd
& "D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe" --path . --script tools/capture_portal_stability_review.gd
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_stage_presentation_gifs.ps1 -PortalStability
```

Stability requires actual rendering, not headless. Tests suppress saves or use isolated profiles. Re-audit StagePortalArt.SURFACES reference/offset data after source replacements. Existing two Texture/RID5460byte shutdown warnings remain. Restart playtest to load updates. No combat/reward/performance claim.
