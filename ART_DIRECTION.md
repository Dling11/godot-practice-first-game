# Art Direction

This document is the visual source of truth for Battle of Gods. It governs handmade, generated, downloaded, and purchased assets before they become runtime content. `ASSET_CATALOG.md` records the concrete files that follow these rules.

## Visual Promise

Battle of Gods is a readable retro pixel-action game set in an ancient world shaped by divine conflict. The image should feel mysterious, weathered, and epic without becoming muddy, realistic, or excessively detailed.

The active forest direction is **luminous dark fantasy**: living greens and warm natural light sit beside old stone, restrained violet divinity, and deep shadow. Darkness comes from history, danger, and atmosphere rather than making the whole screen black.

The planned Sanctuary follows the same world language. It is a small safe settlement reclaimed around an ancient divine fountain, not a modern town or a cheerful cartoon village.

## Priorities

When visual goals conflict, use this order:

1. Gameplay silhouette and hazard readability.
2. Consistent pixel density, origin, and animation scale.
3. Clear interaction and UI hierarchy.
4. Shared palette and lighting direction.
5. Atmosphere and decorative detail.

Art must never hide collision boundaries, attack telegraphs, the player, or required interaction feedback.

## Runtime Baseline

| Area | Current baseline | Rule |
|---|---|---|
| Logical viewport | 960x540 | Review every asset at this gameplay scale. |
| Development display | 1920x1080 | Preserve exact 2x integer scaling. |
| Humanoid locomotion | 24x32 cells | Feet, body scale, and direction columns remain stable. |
| Extended humanoid actions | 64x48 cells | Six-frame actions may exceed the body cell without shrinking the actor. |
| Small creatures | 32x32 cells | Keep silhouettes readable beside 24x32 humanoids. |
| Prototype terrain | 64x64 tiles | New terrain must match or deliberately replace this density. |
| Standard action/skill icon | 24x24 | Use a centered readable glyph with transparent padding. |
| Compact status/currency icon | 16x16 | Use only when readable at native size. |

Nearest-neighbor filtering, binary-alpha hard-pixel character edges, integer placement, and pixel snapping remain mandatory. Do not disguise an illustration as pixel art by downscaling it.

## Palette and Lighting

The palette is provisional but its semantic roles are stable:

| Token | Reference | Purpose |
|---|---|---|
| `void_ink` | `#090B10` | Deepest background and menu shadow. |
| `obsidian_panel` | `#12151D` | Primary UI panel surface. |
| `bone_text` | `#D9DDCE` | Primary readable text. |
| `muted_moss` | `#74806B` | Secondary text and quiet environment detail. |
| `grove_green` | `#5F8F47` | Living forest midtone. |
| `deep_moss` | `#365A3B` | Forest shadow and structural foliage. |
| `divine_violet` | `#765AA3` | Portals, sealed divinity, and rare arcane accents. |
| `relic_gold` | `#D6C171` | Important focus, equipped state, and earned reward. |
| `spirit_blue` | `#66A4D8` | XP, spirit, and restrained informational emphasis. |
| `danger_red` | `#D65C50` | Damage and hostile warnings only. |

These are coordination references, not a demand that every sprite contain every color. Individual actors should use compact sub-palettes. Avoid uncontrolled hue proliferation.

Default world light travels from upper-left toward lower-right. Highlights, cast shadows, foliage clusters, statues, buildings, icons with volume, and fountain pieces should agree with that direction.

## Character and Creature Rules

- Direction order is `down`, `left`, `right`, `up` unless a documented asset contract says otherwise.
- Animation names use `<action>_<direction>`, such as `walk_left` or `attack_up`.
- Feet are the stable origin for top-down actors and must not drift between frames.
- The face, hands, held weapon, and major silhouette features must survive every frame; no transparent holes or detached fragments.
- Weapons are integrated into attack poses when hands and body motion depend on them.
- Anticipation, active action, and recovery poses matter more than extra decorative frames.
- Shadows are separate presentation and align beneath the foot position.
- Collision and hurtboxes are authored from gameplay needs, not copied from sprite opacity.

## Environment Rules

- Terrain, decoration, collision, navigation, foreground occlusion, and effects remain separable.
- Tall props use independent base/canopy or base/roof layers when the player can walk behind them.
- Prop collision covers the traversability footprint, never the entire visible crown or silhouette.
- Landmarks guide travel and combat spacing. Avoid random dense prop scattering.
- Sanctuary assets reuse the forest's lighting and palette while introducing maintained paths, inhabited structures, warm windows, cloth, and the central divine fountain.
- Fountain visuals should separate base stone, water/glow animation, shadow, collision, and optional interaction marker.

## UI Language

UI should resemble ancient crafted interfaces without sacrificing clarity:

- Dark flat panels with one-pixel or two-pixel borders.
- Relic-gold focus/equipped states and violet sealed/divine states.
- Strong rectangular silhouettes and restrained corner ornament.
- Minimal animation: short fades, focus shifts, small glows, and deliberate selection motion.
- No highly rendered fantasy frames, noisy filigree, fake metallic gradients, or baked-in text.
- Icons use one clear symbol, a limited palette, and a consistent internal margin.

The UI implementation uses `battle_of_gods_theme.tres` as its reusable base. Buttons, panels, labels, progress bars, focus states, and disabled states consume that shared theme; scene-local overrides remain only for semantic states such as health, cooldown, equipped, or sealed content. The first named 16x16/24x24 icon kit follows the same palette and hard-pixel rules.

## Replaceable Background Contract

Title, menu, dialogue, and loading backgrounds must be easy to replace without changing navigation or gameplay code.

- Background presentation lives in a named `Background` owner or a dedicated presentation scene.
- Screens reference backgrounds through exported `Texture2D`, `PackedScene`, or theme/configuration resources.
- Text, buttons, logos, and interaction logic are never baked into a background image.
- Decorative animation layers remain separate from the static base image.
- A title background should support: `Base`, `DistantSilhouette`, `Atmosphere`, and `Vignette` layers when needed.
- Backgrounds design for 960x540 and define whether they crop, letterbox, or tile at other aspect ratios.
- Replacing a background must not change button paths, focus navigation, audio routing, or scene transitions.

A new background can differ in composition, but it must still match Battle of Gods lighting, palette roles, pixel density, and tone.

## Asset Lifecycle

Every visual file has one lifecycle state:

```text
concept -> source -> cleaned -> runtime -> archived
```

- `concept`: reference or exploration; never loaded by a scene.
- `source`: original handmade, generated, or downloaded material preserved for provenance.
- `cleaned`: intermediate crop, chroma removal, palette reduction, or grid correction.
- `runtime`: the exact approved file imported and referenced by Godot.
- `archived`: rejected or superseded work retained for learning and history.

Future non-runtime art belongs under `art_source/`, with a `.gdignore` at its root. This keeps source and mistakes safe without importing them into Godot. Runtime content belongs under `assets/` only.

## External and Generated Art

- Record source URL, author, license, and modification notes for external assets.
- Prefer CC0 or clearly compatible licenses. Do not use an image merely because it can be downloaded.
- Generated images are source material, not automatically approved runtime art.
- Clean generated work onto the required grid, remove anti-aliased fragments, reduce the palette without dithering, and inspect every animation cell.
- Do not mix unrelated asset packs without palette, lighting, scale, and silhouette normalization.
- Keep reproducible processing scripts when they materially transform an asset.

## Approval Checklist

An asset becomes `active_runtime` only when:

1. Its canonical ID and path are recorded in `ASSET_CATALOG.md`.
2. Its dimensions, grid, direction order, and origin are known.
3. It matches the theme, palette roles, and upper-left lighting.
4. It remains readable at the 960x540 gameplay viewport.
5. Its collision, navigation, occlusion, or UI behavior is verified where relevant.
6. Its source/license or generation provenance is recorded.
7. Relevant scenes, generators, and tests load without errors.
