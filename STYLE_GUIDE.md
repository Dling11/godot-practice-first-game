# Style Guide

## Scope

These conventions apply to Godot 4.x GDScript, scenes, resources, and game assets. Prefer consistency with an established local pattern when it is clearly intentional; record any durable convention change here.

## Naming

- Files and folders: `snake_case`.
- GDScript variables and functions: `snake_case`.
- Classes and named custom resources: `PascalCase` via `class_name` when globally useful.
- Constants and enum members: `UPPER_SNAKE_CASE`.
- Signals: past-tense or state-event `snake_case`, such as `health_changed` or `died`.
- Private implementation members: leading underscore when it improves API clarity.
- Node names: `PascalCase`, descriptive, and stable within reusable scenes.
- Input actions: namespaced `snake_case`, such as `player_move_left` and `player_dodge`.

## GDScript Organization

Use this order when sections are present:

1. `class_name` and `extends`
2. Documentation comment
3. Signals
4. Enums
5. Constants
6. Exported variables
7. Public variables/properties
8. Private variables
9. `@onready` references
10. Godot lifecycle callbacks
11. Public methods
12. Private methods

Use static typing for public APIs, exported data, signals, return values, and non-obvious local values. Avoid `Variant` unless polymorphism is intentional.

## Script Responsibilities

- A script should have one clear reason to change.
- Prefer components and collaborators over deep inheritance trees.
- Avoid giant actor controllers; extract coherent capabilities once boundaries are understood.
- Do not create an abstraction for a single trivial use unless it enforces an important boundary.
- Presentation scripts must not silently own combat rules.
- Avoid hidden mutations of shared `Resource` assets.

## Signals

- Signals notify that something happened; methods request that something happen.
- Declare typed signal parameters.
- Connect/disconnect dynamic relationships with lifecycle ownership in mind.
- Avoid signal chains that obscure the source of a gameplay state change.
- Do not use a global event bus as the default communication mechanism.

## Audio

- Use `AudioDirector` only for cross-scene music routing; level-local `StageMusic` nodes request tracks.
- Audio observes gameplay and level state. It must not own damage, timing, rewards, or other gameplay authority.
- Route ambience/music through `Music`, combat/world cues through `SFX`, and menu feedback through `UI`.
- Positional actor sounds must live beneath a `Node2D` transform owner and respond to authoritative state signals or accepted-hit events.
- Add third-party audio only with a recorded license and attribution file beside the asset when required or useful for provenance.
- Headless tests may validate stream routing without requiring device playback.

## Scene Organization

- Reusable scenes own their internal nodes and expose a small configured API.
- Use exported node/resource references for required dependencies when editor wiring is stable.
- Use unique node names sparingly and only within a clear scene ownership boundary.
- Avoid distant absolute node paths.
- Keep collisions, visuals, audio, and gameplay components clearly named.
- Prefer instantiable entity scenes over duplicating node trees in levels.

## Formatting and Documentation

- Use tabs as produced by the Godot editor for GDScript indentation.
- Keep lines readable; break long calls and data declarations deliberately.
- Document intent, invariants, units, and surprising constraints—not obvious syntax.
- Use `##` documentation comments for public classes, exported configuration, and public APIs where useful.
- Include units in names or docs when ambiguity exists, such as `duration_seconds`.
- Remove dead code and stale comments rather than commenting out implementations.

## Physics and Frame Updates

- Put physics movement and collision work in `_physics_process()`.
- Use `_process()` only for frame-dependent presentation or logic that truly needs it.
- Prefer signals, timers, animation callbacks, and explicit state transitions over permanent polling.
- Make delta usage explicit and avoid frame-rate-dependent gameplay behavior.

## Error Handling

- Validate external/configuration data at boundaries.
- Use assertions for developer invariants, not recoverable player-facing failures.
- Fail visibly in development when required dependencies are missing.
- Do not silently swallow invalid state.

## Assets and Pixel Art

- Give each approved asset a canonical semantic ID in `ASSET_CATALOG.md`.
- Runtime filenames use descriptive `snake_case`; prefer `<identity>_<action-or-purpose>_<asset-type>_<dimensions>` where the dimensions communicate a real grid contract.
- Never use `final`, `new`, `fixed`, `better`, unexplained numbers, or personal names in runtime filenames.
- Keep source, cleaned intermediate, runtime, and archived states distinct. Only runtime assets belong in load-bearing scene paths.
- Backgrounds, icons, and panel art are presentation dependencies. Reference them through configured scenes/resources rather than branching gameplay logic on filenames.
- Follow `ART_DIRECTION.md` for palette roles, lighting, pixel density, and replaceable-background requirements.
- Apply `assets/ui/themes/battle_of_gods_theme.tres` at reusable UI roots; add local theme overrides only for semantic states the shared theme cannot represent.
- UI icons use stable canonical concepts and native 16x16 or 24x24 textures. Pass them as presentation configuration or metadata; never parse their filenames to decide gameplay behavior.
- Keep small pixel icons on binary alpha with one readable symbol and transparent internal margin. Regenerate the baseline kit through `tools/build_ui_icon_kit.gd` rather than hand-editing generated runtime files inconsistently.
- Menu screens must establish an initial focused control, explicit directional focus loops, modal focus transfer, and focus restoration when the modal closes.
- Every gameplay modal must provide a visible mouse-operable primary/close control and support `ui_cancel`; do not rely on a hidden keyboard-only toggle to dismiss it.
- Title/loading/background art remains under a named presentation owner. Never bake navigation labels or controls into background textures.
- Generated dark-background crops must use asset-specific border cleanup. Do not globally key all dark pixels from characters, buildings, or props; preserve legitimate outlines, interiors, limbs, and connectors.

- Favor strong silhouettes, limited palettes, and readable animation keys.
- Use nearest-neighbor filtering and pixel-consistent import settings once the base resolution is decided.
- Avoid subpixel shimmer by aligning camera/rendering policy with the chosen pixel scale.
- Separate gameplay hit shapes from sprite opacity or detailed outlines.
- Name animation clips and sprite assets consistently with their gameplay action.
- Align sprite origins deliberately, usually around the gameplay contact point or feet for Y-sorted actors and props.
- Keep pixel density consistent; scaling a sprite to disguise a mismatched source resolution requires explicit art-direction approval.
- Maintain a documented shared palette and lighting direction once the first production palette is approved.
- Judge animation at gameplay scale and speed, not only zoomed in within an art tool.
- Prefer simple color blocks and controlled clusters over noisy micro-detail; environment assets must not visually overpower actors or combat telegraphs.
- Validate asset scale in the full gameplay viewport before approving detail density.
- Prototype actors use exact 24x32 cells. Do not substitute larger illustrations that are merely downscaled or filtered to appear pixelated.
- Keep active actor sheets on a fixed direction grid: down, left, right, up.
- Character body scale must remain constant across action cells. Never shrink an entire actor to fit a long weapon silhouette.
- Actions that extend beyond the 24x32 locomotion cell may use a larger fixed canvas, currently 64x48, provided body scale and foot baseline remain constant across every frame.
- Held weapons must be authored together with hands, arms, and body poses throughout attack frames. Avoid detached overlays, independent weapon orbits, or freely rotating polygon weapons.
- Active hard-pixel sheets must use binary alpha only. Semi-transparent edge fragments are prohibited.
- Movement collision represents the foot footprint; hurtboxes represent the damageable body and remain separate shapes.
- Palette reduction must use no dithering for the current style unless a later art-direction decision explicitly changes it.

## Environment Scene Organization

- Group visuals, collision, navigation, shadows, effects, audio, and interaction areas under clearly named owners.
- Do not add empty organizational nodes when a prop does not need that responsibility.
- Split tall objects into lower and upper visuals when correct player occlusion requires separate draw ordering.
- Place collision around the traversability footprint, not the full visible canopy, roof, or decorative silhouette.
- Keep navigation obstacles/regions consistent with collision unless a documented gameplay rule requires different behavior.
- Keep shadows presentation-only; shadows must not determine collision or damage.
- Use `Polygon2D` for an editable visual shadow and `CollisionPolygon2D` for an irregular static physics footprint. Never expect a visual polygon to participate in collision.
- Use Y-sorting within controlled world/prop boundaries and reserve fixed canvas layers or `z_index` bands for genuinely separate visual planes.
- Never manipulate draw order every frame when a stable scene hierarchy, Y-sort origin, or split sprite solves the relationship.
- Test each large prop from the front, behind, and both sides with the player before approving it for reuse.
- Safe-hub props follow the same separation as combat props: raster, shadow/glow, collision, interaction, and idle presentation remain independently replaceable.
- Ambient idle motion uses bounded tweens or animations. It must not move collision, interaction ranges, navigation footprints, or gameplay authority.
- Use the shared `EditorPreviewBackdrop` as a direct child when an isolated transparent asset is unreadable against Godot's dark 2D canvas. Editor previews must be context-gated, processing-disabled, collision-free, and absent from runtime drawing.

## Tilemaps and Modular Environments

- Build reusable terrain and prop sets instead of painting one-location-only combined images.
- Support terrain transitions, ground variations, decorative overlays, collision, navigation, and foreground occlusion as separate data/layers where appropriate.
- Keep decorative variation independent from gameplay collision whenever possible.
- Reuse tile sources and terrain definitions across maps; do not duplicate a tileset solely to recolor or rearrange one level without a documented reason.
- Validate seams, transition coverage, collision edges, navigation continuity, and pixel alignment before content-scale painting.
- Prefer maintainable Godot 4.7 tilemap tooling over custom placement code unless profiling or authoring requirements prove it insufficient.

## Asset Review Checklist

Before approving a sprite, prop, tile set, or environment scene, verify:

1. Pixel density, palette, lighting direction, and origin match the project baseline.
2. Silhouette and interaction state remain readable during combat.
3. Collision and navigation match the intended traversable footprint.
4. Foreground/background ordering works from every relevant approach direction.
5. The asset is reusable and does not contain unnecessary level-specific coupling.
6. Animation, effects, and shadows do not obscure hazards or player feedback.

## Version Control

- Keep commits focused and describe the player-facing or architectural outcome.
- Do not commit `.godot/` generated cache content.
- Do commit project settings, import metadata required by Godot, source assets, scenes, resources, scripts, and documentation.
- Update affected documentation in the same change as the code.
