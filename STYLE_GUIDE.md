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
- Hit flash and hitstop may observe only accepted-hit signals. They must remain presentation feedback, must not decide damage or contact, and repeated multi-target contacts must not stack hitstop duration.
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
- Keep action buffers actor-owned, non-stacking, and bounded to explicit state transitions. Snapshot any required direction/target when input is accepted, expose phase-specific cancel methods instead of broadly resetting a state machine, and regression-test that damage and invulnerability never overlap unintentionally.
- Ability data may declare activation mode, presentation style, authoritative shape, flat/weapon scaling, and phase movement. Snapshot resolved combat values at cast acceptance; actor controllers consume movement, hitboxes consume contacts/damage, and skill visuals/HUD/audio only observe those states.

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
- UI icons use stable canonical concepts and native 16x16 or 24x24 textures; detailed inventory item portraits use the approved 64x64 contract. Pass them as presentation configuration or metadata; never parse their filenames to decide gameplay behavior.
- Keep small pixel icons on binary alpha with one readable symbol and transparent internal margin. Regenerate the baseline kit through `tools/build_ui_icon_kit.gd` rather than hand-editing generated runtime files inconsistently.
- Menu screens must establish an initial focused control, explicit directional focus loops, modal focus transfer, and focus restoration when the modal closes.
- Every gameplay modal must provide a visible mouse-operable primary/close control and support `ui_cancel`; do not rely on a hidden keyboard-only toggle to dismiss it.
- Use native `Button.pressed` activation as the shared path for mouse click, `ui_accept`, and controller confirmation. Do not create separate gameplay outcomes for each device.
- Handle global modal-open shortcuts in `_input()` when their physical key also serves GUI navigation, mark accepted events handled, and ignore open requests while another owner has paused the tree. Use `_unhandled_input()` only when GUI consumption is intended.
- HUD entry buttons emit intent signals to the current scene flow; they do not locate menus globally or mutate pause, inventory, or equipment state directly.
- Full-screen transition or modal shields may use `MOUSE_FILTER_STOP` only while they are intentionally active; transparent idle overlays and decorative controls must use `MOUSE_FILTER_IGNORE` so they cannot silently consume clicks.
- Repeated skill presentation must consume `SkillLoadoutDefinition`/`SkillSlotDefinition` data through reusable slot scenes. HUD views may observe an injected `AbilityComponent`, but UI must not own cast, cooldown, unlock, or damage authority.
- Repeated weapon presentation must consume `EquipmentDefinition` through reusable item, slot, and detail scenes and read authoritative combat tuning only from its linked `WeaponDefinition`. UI may request a purchase or equip command, but `WeaponInventory`, `PlayerProgressionComponent`, and `Player` validate and commit ownership, coin spending, class compatibility, and combat swapping respectively.
- Expedition routes must consume immutable `ExpeditionDefinition` and `ExpeditionRequirement` data. Use stable `snake_case` IDs for story flags, bosses, discoveries, and narrative key items; display text may humanize or localize those IDs but must never become authority.
- Equipment rank color is semantic: the active beginner pair uses warm ash brown for Wood and pale steel for Iron; spirit blue is reserved for a later higher grade. Stonebound and former A/S/Legendary/Mythic concepts are inactive legacy/future material until a later decision reintroduces them. Rank animation remains a restrained pulse and must not compete with menu focus.
- Store class compatibility as stable lowercase class IDs on item data. Shared ownership may contain another class's weapon, but equip validation must reject it before presentation or combat changes. Every playable character must retain one owned default/fallback weapon; purchasing must never auto-equip or sell skills.
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
- Opaw and future modular playable bodies use an 18x27 upright reference on a 32-pixel-high foot-baseline contract. Idle, locomotion, and compact reactions use 32x32 cells; authored reaches may use 48x32 and grounded defeat may use 64x32 so the body is never scaled down to fit a pose. Existing enemy-humanoid locomotion may retain its validated 24x32 contract, and small creatures retain 32x32. Do not substitute larger illustrations that are merely downscaled or filtered to appear pixelated.
- Keep active actor sheets on a fixed direction-row grid: down, left, right, up; action time advances across columns.
- Character body scale must remain constant across directions and action cells. Normalize from a per-direction standing reference, keep one foot baseline, and allocate a wider cell rather than shrinking an actor, long weapon, reach, lean, or collapse.
- Prefer action-owned playable sheets when one mixed board would couple unrelated frame counts or encourage unstable crops. Preserve the `<action>_<direction>` animation API so scenes do not depend on atlas layout.
- Generated poses may cross an ideal source-grid boundary. Isolate the complete connected actor from an expanded cell before measuring scale; do not use a fixed inset that can flatten a head or include the next pose in the reference bounds.
- Attack and dash normalization must preserve a fully padded head silhouette and direction-appropriate facial landmarks: two readable eyes facing down, one profile eye facing left/right, and a complete back-of-head facing up. Down/up attacks keep the head and tunic centered on the same screen-space vertical axis; do not reuse a diagonal side lunge for a cardinal vertical strike. Put extreme motion into torso, feet, cloth, and equipment rather than rotating a low-resolution head until its face disappears.
- Existing integrated actor actions that extend beyond a 24x32 locomotion cell may retain a documented larger fixed canvas, currently 64x48, provided body scale and foot baseline remain constant across every frame.
- Modular playable weapons may be separate `Sprite2D` presentation driven by the same `WeaponDefinition` and attack-phase signals as the actor. Treat the presentation node as the equipment pivot; store each texture's `sprite_offset_from_grip`, visual scale, and swing radius in weapon data. Never rotate a weapon around its texture center unless the grip is actually centered. Visible weapons must use reviewed integer-pixel anchors, never own hit timing or damage, and remain close enough to read as intentionally controlled. A truly armless body uses a small explicit gap and bounded phase-driven orbit; a limb-bearing body aligns the pivot to its hand. Do not use unbounded decorative orbits or free rotation unrelated to combat phases.
- Keep sword grade separate from animation duplication. Grades may reuse one weaponless body sheet and one `SwordAttackStyleDefinition`; author a new style only when the weapon family needs a meaningfully different orbit, extension, trail, or accent. Style data is presentation-only and must not silently alter authoritative reach, damage, knockback, or phase timing.
- Normal sword variety may cycle deterministic style-owned sweep directions and arc/extension multipliers when an authoritative wind-up begins. Keep the sequence readable, reset it when changing weapon definitions, and describe any visually stronger final sweep honestly unless gameplay authority separately grants a combo bonus.
- Alternate or superseded character art must use a separate variant folder and complete presentation resource. Before an active-model replacement, preserve the previous full sheet set and `SpriteFrames` as a restorable variant; never depend on filename history alone for a requested visual backup.
- Keep only active assets and explicitly supported loadable rollbacks under `assets/`, active scenes, `tools/`, and `tests/`. After confirming no runtime references, move rejected experiments, superseded scenes, obsolete processors/tests, and legacy runtime material intact under Godot-ignored `art_source/archive/`; document the move and never leave stale regeneration commands pointing at archived code.
- Left/right modular weapon attacks must be true screen-space mirrors unless the weapon explicitly requires asymmetric technique. Keep the trail center on the authored hand path rather than the face or actor origin; small scale/color accents may add impact but must remain presentation-only.
- Integrated weapon-and-hand art remains appropriate for non-modular actors whose silhouettes depend on it. Do not mix integrated and detached versions of the same active weapon without an explicit presentation owner.
- Defeat presentation should use authored recoil/weaken/slump frames before a runtime fade. Keep active raster edges binary-alpha; translucency belongs to runtime modulation rather than partially transparent sprite fragments.
- Active hard-pixel sheets must use binary alpha only. Semi-transparent edge fragments are prohibited.
- Oversized ability VFX may use effect-only atlases with cells larger than the actor when that space preserves a peak plume, shock ring, or decay frame without shrinking it. Keep one stable local origin, rotate reusable directional effects through a presentation pivot, use a narrow bright core to communicate the real contact lane, and document all larger outer ribbons as cosmetic. Never bake Opaw, a hand, or one sword grade into a reusable Warrior-technique atlas.
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
- Pixel-character ambient breathing should use integer-pixel, timer/animation-driven visual steps with a stable gameplay footprint; do not poll or translate the actor root every frame.
- Use the shared `EditorPreviewBackdrop` as a direct child when an isolated transparent asset is unreadable against Godot's dark 2D canvas. Editor previews must be context-gated, processing-disabled, collision-free, and absent from runtime drawing.

## Tilemaps and Modular Environments

- Build reusable terrain and prop sets instead of painting one-location-only combined images.
- Support terrain transitions, ground variations, decorative overlays, collision, navigation, and foreground occlusion as separate data/layers where appropriate.
- Keep decorative variation independent from gameplay collision whenever possible.
- Reuse tile sources and terrain definitions across maps; do not duplicate a tileset solely to recolor or rearrange one level without a documented reason.
- Validate seams, transition coverage, collision edges, navigation continuity, and pixel alignment before content-scale painting.
- On even-width tilemaps, center a landmark between the paired middle columns only when its approach also uses both columns; snap single-cell service approaches to the owning doorway's exact tile center and preserve intentional terrain breaks around local aprons.
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
