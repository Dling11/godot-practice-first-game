# Eclipse Bind action-bar sources

Owner selected concept B, `art_source/review/ui/shadow_action_bar_concepts_2026_09_27/eclipse_bind_concept.png`, on 2026-09-27. The original generated concept has baked icons/text and is review-only. Built-in ImageGen edited that local reference into two transparent source images:

- `eclipse_bind_frame_source.png`: preserve the continuous inward-curling obsidian thorns, centered eclipse, thin violet veins and ivory highlights; remove every baked skill box, icon, number and label, leaving a plain dark interior for live controls.
- `eclipse_dash_source.png`: isolate a right-lunging shadow-step silhouette with short violet afterimages, no dragon, wings, sword, frame or text.

`tools/build_eclipse_bind_hud_art.gd` crops the occupied alpha, scales to 760x120 and 24x24, applies a fixed obsidian/ivory/violet palette and binary alpha, and writes native assets to `assets/ui/hud/eclipse_bind/`. Rebuild with Godot's headless script runner, then run the editor import once. `ui/combat_hud.tscn` owns only the frame placement; labels, counts, cooldowns and buttons remain Godot UI. The 960x540 runtime capture is under `art_source/review/ui/eclipse_bind_runtime_2026_09_27/`.
