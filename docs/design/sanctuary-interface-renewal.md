# Sanctuary perspective and interface correction

2026-10-01. Implemented candidate in the optional, save-suppressed Sanctuary study. The owner liked the town improvements but rejected the diagonal artisan houses; they requested left-positioned entrances in the existing overhead perspective, a smaller skill display, an on-screen themed map and cohesive NPC/inventory modals.

## Implemented presentation

- Nema and Umi use newly generated stone/timber/slate houses referenced to Orren's accepted workshop. Foundations stay horizontal, walls upright and roof projection overhead; entrances occupy the left part of the facade. These are not diagonal isometric buildings or a new camera. Prior angled variants remain archived. Doorway/approach markers remain planning aids, not working interiors.
- The action frame is 660x66 instead of 720x104 at the 960x540 baseline. Native 46x44 skill buttons and 22x22 icons remain readable and functional. Resolve moves with the smaller bar; the interaction prompt stays above it. This interprets the owner's ambiguous smaller-skills request as HUD size; combat effects and abilities are unchanged.
- A 200px-wide parchment minimap is docked top-right below Menu. Click it or press M for the directory. Click a service marker or named button to select the existing beacon and directional guidance. Routes and live NPC/player coordinates supply the map; generated parchment contains no baked labels or invented geography. Closing the directory restores the minimap.
- Dialogue, character/inventory, skills, technique collection, Nema crafting, Umi exchange, expeditions and pause share a generated slate, aged-gold, ivory-feather and amethyst frame. Real Godot controls and existing authorities remain inside the frame. Dialogue text/buttons are more readable. Nema/Umi service headers use their renewed portraits. Map and study controls hide immediately when a modal opens, including the dynamically created technique collection.
- Nema's existing recipe/detail body exceeded the viewport. It now scrolls within a fixed-height body with keyboard focus following; header, category filters, close and footer remain visible. This small layout fix also applies to the normal campaign menu. Crafting rules and transactions are unchanged.

## Ownership and assets

`levels/sanctuary/review/sanctuary_ui_review.gd` snapshots and restores modal themes, local frame overrides, portraits, dialogue font sizes and HUD positions. It observes modal visibility and the existing technique collection's creation; it owns no service, inventory, save or ability rules. `ui/themes/sanctuary_theme.gd` supplies the reusable nine-slice frame and live control palette. Map updates retain the existing 150ms timer and viewport resize anchoring.

Built-in imagegen sources and exact prompts:

- `art_source/generated/environment/sanctuary/orthographic_2026_10_01/` -> `assets/environment/sanctuary/orthographic/` (Nema 200x148; Umi 176x135).
- `art_source/generated/ui/sanctuary_theme_2026_10_01/` -> `assets/ui/sanctuary_theme/` (`panel.png` 288x160, `map_paper.png` 384x256).
- `tools/build_sanctuary_interface_art.gd` crops, resizes with nearest sampling and normalizes alpha; `normalization.json` records results. The UI panel is a cropped opaque rectangle used as a nine-slice, not a transparent silhouette. Original generated images and old house candidates remain available.
- Native rendered evidence: `art_source/review/ui/sanctuary_theme_2026_10_01/`.

## Review and verification

F5 -> Continue -> F10 -> SANCTUARY REVIEW, or the existing study launcher. Visit Nema/Umi to inspect house projection; F talks; Tab opens inventory; M or the corner map opens the directory; complete Eira's conversation to inspect skills. Comparison restores old presentation. Saving stays suppressed for the entire review process; restart normal play to resume saves. Campaign art/theme promotion has not occurred.

`sanctuary_interface_smoke.gd`: 63 rendered checks pass at 960x540, including actual minimap/landmark clicks, F dialogue/service opening, every modal's bounds/frame, reachable crafting action and last recipe, direct collection opening, real dash click, comparison restoration and save suppression. Courtyard regression: 99 rendered checks pass; town-life: 95 rendered checks; previous study: 108 rendered checks; production hub smoke passes. Shared two-texture GPU teardown warnings still occur and are not claimed fixed. Owner visual judgment, interiors and phone profiling remain open.
