# Eclipse Bind action-bar sources

Owner selected concept B, `art_source/review/ui/shadow_action_bar_concepts_2026_09_27/eclipse_bind_concept.png`, on 2026-09-27. The original generated concept has baked icons/text and is review-only. Built-in ImageGen edited that local reference into two transparent source images:

- `eclipse_bind_frame_source.png`: preserve the continuous inward-curling obsidian thorns, centered eclipse, thin violet veins and ivory highlights; remove every baked skill box, icon, number and label, leaving a plain dark interior for live controls.
- `eclipse_dash_source.png`: isolate a right-lunging shadow-step silhouette with short violet afterimages, no dragon, wings, sword, frame or text.

`tools/build_eclipse_bind_hud_art.gd` crops the occupied alpha, applies a fixed obsidian/ivory/violet palette and binary alpha, and writes native assets to `assets/ui/hud/eclipse_bind/`. It retains the first opaque 760x120 version and also builds the active 720x104 version with dark center pixels cleared. A separate 78%-opacity `EclipseVeil` in `ui/combat_hud.tscn` supplies adjustable readability behind the active border. The Dash icon stays 24x24. Rebuild with Godot's headless script runner, then run the editor import once. Labels, counts, cooldowns and buttons remain Godot UI. Compare 960x540 captures under `art_source/review/ui/eclipse_bind_runtime_2026_09_27/`, `art_source/review/ui/eclipse_bind_compact_2026_09_27/` and `art_source/review/ui/eclipse_bind_tuned_2026_09_27/`.
