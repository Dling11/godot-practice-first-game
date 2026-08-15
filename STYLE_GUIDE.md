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
- Hit flash and hitstop may observe only accepted-hit signals. They must remain presentation feedback and must not decide damage or contact. Preserve target-local confirmation, but coalesce camera, hitstop, and impact-audio work once per swing/cast impact so multi-target contacts cannot stack pauses or rebuild shared effects.
- Avoid hidden mutations of shared `Resource` assets.

## Signals

- Signals notify that something happened; methods request that something happen.
- Declare typed signal parameters.
- Connect/disconnect dynamic relationships with lifecycle ownership in mind.
- Avoid signal chains that obscure the source of a gameplay state change.
- Do not use a global event bus as the default communication mechanism.

## Audio

- Route repeated cooldown attempts through the shared player request method and one presentation-only denied signal. Do not make individual abilities own rejection sounds, do not buffer cooldown-blocked inputs, and keep cooldown buttons tappable across mouse/touch while locked or unavailable slots remain disabled.

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
- Inventory grids use compact reusable focusable slots and explicit disabled placeholders. Present equipment and materials through their owning authorities; never create a UI-owned item dictionary. Capacity labels must state which categories consume space, and destructive discard must require a separate confirmed command rather than slot-click side effects.

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
- When an `Area2D` collection/overlap callback needs to change `monitoring` or `monitorable`, use `set_deferred()`; the physics server blocks direct changes while flushing enter/exit signals. Keep a synchronous logical guard so a deferred disable cannot double-grant the interaction.
- Keep action buffers actor-owned, non-stacking, and bounded to explicit state transitions. Snapshot any required direction/target when input is accepted, expose phase-specific cancel methods instead of broadly resetting a state machine, and regression-test that damage and invulnerability never overlap unintentionally.
- Ability data may declare activation mode, presentation style, authoritative shape, flat/weapon scaling, and phase movement. Snapshot resolved combat values at cast acceptance; actor controllers consume movement, hitboxes consume contacts/damage, and skill visuals/HUD/audio only observe those states.
- Aggregate character/level/equipment maximum-health inputs in a player stat component, then apply the result through `HealthComponent`. Cross-scene current-health memory may live in the narrow run-session service, but every restore, heal, regeneration tick, and damage event must still pass through `HealthComponent`. Prefer damage-reset timers plus discrete healing ticks over per-frame regeneration. Armor UI, level banners, and potion presentation must not become health authority. Keep future mana in a separate resource/component unless an approved shared-stat contract proves necessary.
- Resolve armor only in `HealthComponent` with diminishing returns (`raw * 100 / (100 + armor)`). Enemy armor belongs to `EnemyDefinition`; future player equipment must aggregate into the same component rather than subtracting damage in attacks, hurtboxes, feedback, or UI. Preserve both raw and accepted damage for honest feedback and testing.
- Multi-strike abilities declare their ordered damage multipliers and final-versus-non-final knockback in immutable ability data. The ability runtime may reactivate a hitbox only at explicit strike windows; each body/VFX/sword/audio flourish must observe the emitted strike signal and never create a second contact or damage path.

## Error Handling

- Validate external/configuration data at boundaries.
- Use assertions for developer invariants, not recoverable player-facing failures.
- Fail visibly in development when required dependencies are missing.
- Do not silently swallow invalid state.
- Save authorities expose explicit versioned dictionaries and validate complete input before mutating live state. Disk writes use a validated temporary file plus recoverable backup; never serialize nodes, resources by instance identity, active attacks, or scene trees.
- Autosave only at authored safe milestones. UI may request Continue/New Journey, but `SaveService` owns file validation, recovery, deletion, and restoration. Headless tests must use isolated `user://` paths or suppress production-path persistence.
- Activate a reserved profile extension through its own versioned authority. Preserve explicitly supported legacy-empty sections as clean default state, validate every extension before any authority mutates, and add disk reconstruction plus corruption coverage in the same change.
- Immutable content Resources own stable IDs and authored quantities; global catalogs reject invalid definitions and duplicate IDs. Mutable inventories store only known IDs and plain values, never `Resource` instances or display labels. Recipe discovery remains separate from story flags unless a recipe is itself a narrative key item.
- Enemy controllers, stage scenes, chest UI, and crafting UI may reference definitions or submit requests, but they must not roll rewards, edit material dictionaries, consume recipe costs, or write profiles directly.
- Resolve enemy/stage reward definitions through one gameplay authority, combine repeated material stacks before presentation, and grant only through the owning inventory authority. World pickups present and collect an already-resolved stack; a stage chest requests one idempotent table claim; HUD toasts only observe successful grants.

## Assets and Pixel Art

- Give each approved asset a canonical semantic ID in `ASSET_CATALOG.md`.
- Runtime filenames use descriptive `snake_case`; prefer `<identity>_<action-or-purpose>_<asset-type>_<dimensions>` where the dimensions communicate a real grid contract.
- Never use `final`, `new`, `fixed`, `better`, unexplained numbers, or personal names in runtime filenames.
- Keep source, cleaned intermediate, runtime, and archived states distinct. Only runtime assets belong in load-bearing scene paths.
- Backgrounds, icons, and panel art are presentation dependencies. Reference them through configured scenes/resources rather than branching gameplay logic on filenames.
- Follow `ART_DIRECTION.md` for palette roles, lighting, pixel density, and replaceable-background requirements.
- Follow `docs/design/character-animation-pixel-contract.md` when generating or processing character boards; prompts, source boards, runtime cells, safe margins, and acceptance scans must share one explicit pixel contract.
- Apply `assets/ui/themes/battle_of_gods_theme.tres` at reusable UI roots; add local theme overrides only for semantic states the shared theme cannot represent.
- UI icons use stable canonical concepts and native 16x16 or 24x24 textures; detailed inventory item portraits use the approved 64x64 contract. Pass them as presentation configuration or metadata; never parse their filenames to decide gameplay behavior.
- Crafting material icons use a 24x24 runtime contract; crafted equipment portraits use the existing 64x64 inventory contract. A material may reuse an approved source silhouette/container template, but its distinct contents, inset glyph, accent cluster, and flattened runtime PNG must communicate its actual identity. Keep names, counts, rarity frames, and region labels in UI/data rather than baking text into the icon.
- Exact reuse is reserved for the same material ID; template reuse may preserve a vial, cloth bundle, shard, plate, seed, spore, or core silhouette; original art is required for signature materials, boss cores, or any resource whose gameplay importance would be obscured by a family template. Do not use runtime recoloring to manufacture separate materials.
- Cross-region progression must not become `Leather+`, `Leather++`, or palette-only enemy variants. Reuse universal components where their fiction still fits, introduce real region materials with new behavior, and distinguish threats through silhouette, animation, telegraph, and mechanics as well as color.
- Before producing a future enemy, record its stage purpose, ecology, combat role, body/action/VFX frame contracts, data-owned movement radius, separate hurtbox/attack shapes, map navigation clearance, audio identity, drop profile, recipe purpose, portrait need, and focused test expectations. Art generation may begin only when that content contract is coherent.
- External or generated audio must match the creature/material action, use a project-compatible license, retain exact provenance/attribution, and be previewed in the live mix before approval. Do not import an entire sound pack when only selected cues are needed.
- Every newly approved named character or recurring enemy should receive a reusable square portrait when it can support dialogue, expedition previews, bestiary entries, or character descriptions. Current dialogue/bestiary portraits use transparent 96x96 runtime PNGs, preserve the gameplay model's identity and upper-left lighting, and remain presentation metadata rather than gameplay authority.
- Multi-speaker dialogue must author an ordered speaker/text/portrait entry per line; do not infer speaker identity from body text or filenames. Keep a visible mouse-operable Skip control on cinematic conversations and route Skip through the same safe owner handoff as normal completion.
- Boss defeat quotes should reveal character or future tension, not merely announce zero health. Keep dialogue, collapse/fade, reward manifestation, and reward claim as distinct ordered beats so a chest never replaces the boss on the same death frame.
- Major-boss chests require a silhouette and footprint distinct from ordinary caches and mini-boss reliquaries. Chest tier may select presentation assets, prompt copy, accent, and collision dimensions; contents and first-clear rules must remain in `LootTableDefinition` and `LootService`.
- Keep small pixel icons on binary alpha with one readable symbol and transparent internal margin. Regenerate the baseline kit through `tools/build_ui_icon_kit.gd` rather than hand-editing generated runtime files inconsistently.
- Menu screens must establish an initial focused control, explicit directional focus loops, modal focus transfer, and focus restoration when the modal closes.
- Every gameplay modal must provide a visible mouse-operable primary/close control and support `ui_cancel`; do not rely on a hidden keyboard-only toggle to dismiss it.
- Use native `Button.pressed` activation as the shared path for mouse click, `ui_accept`, and controller confirmation. Do not create separate gameplay outcomes for each device.
- Route pointer-bound world attacks through `_unhandled_input()` when HUD/menu Controls must consume clicks first. Do not poll the same mouse action per physics frame behind native Buttons.
- Handle global modal-open shortcuts in `_input()` when their physical key also serves GUI navigation, mark accepted events handled, and ignore open requests while another owner has paused the tree. Use `_unhandled_input()` only when GUI consumption is intended.
- HUD entry buttons emit gameplay intent without calculating outcomes. The shared `MENU [ESC]` entry may locate the one scene-registered `PauseMenu`, but that menu remains pause authority.
- Full-screen transition or modal shields may use `MOUSE_FILTER_STOP` only while they are intentionally active; transparent idle overlays and decorative controls must use `MOUSE_FILTER_IGNORE` so they cannot silently consume clicks.
- Repeated skill presentation must consume `SkillLoadoutDefinition`/`SkillSlotDefinition` data through reusable slot scenes. HUD views may observe an injected `AbilityComponent`, but UI must not own cast, cooldown, unlock, or damage authority.
- Keep frequently scanned combat actions icon-first and bounded. The current lower tray uses fixed `52x48` dash/skill controls with a visible semantic gap between mobility and Skill 1; long names belong in tooltips or paused detail surfaces and must never expand the combat layout.
- Ordinary level gain must remain non-modal and combat-readable. Attach its small glow/text confirmation to the actor rather than covering the viewport with a central panel; presentation observes progression and never applies stat changes.
- Major bosses use one scene-owned top-screen `BossHealthHUD` bound to their authoritative `HealthComponent`; do not also retain an actor-local `EnemyHealthBar`. Threshold marks and phase labels may communicate approved health boundaries, but HUD presentation never changes phase behavior, damage, or targeting.
- Repeated paused selectors should show identity/status once and route long descriptions into one selected-detail panel. Do not duplicate multi-line ability copy inside every card when it can force the modal beyond its authored bounds.
- Repeated weapon presentation must consume `EquipmentDefinition` through reusable item, slot, and detail scenes and read authoritative combat tuning only from its linked `WeaponDefinition`. UI may request a purchase or equip command, but `WeaponInventory`, `PlayerProgressionComponent`, and `Player` validate and commit ownership, coin spending, class compatibility, and combat swapping respectively.
- Weapon cards select and preview; a labeled Equip action commits. If a modal freezes the actor outside an idle-only presentation seam, retain one validated pending weapon definition and apply it on the next safe idle frame instead of silently rejecting the command.
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
- Opaw uses an 18x27 upright reference on a 32-pixel-high foot-baseline contract. Idle, locomotion, and compact reactions use 32x32 cells; authored reaches may use 48x32 and grounded defeat may use 64x32. Preserve that contract as Opaw's supported roster identity, but do not force it onto King or later characters.
- King and future character-owned combatants start from a reviewed four-direction turnaround, not Opaw's body. King's provisional cells are `64x64` for armed compact actions and `96x80`/`128x96` for extended greatsword actions; his body remains approximately 28-32 visible pixels tall, and exact actor height/foot baseline freeze only after the turnaround and one side-attack strip pass at 1x/960x540. The style is hard-pixel chibi with an oversized head, short body, simple connected visible arms, and readable hand-to-signature-weapon contact—not realistic anatomy or an armless orbit. Existing enemy-humanoid locomotion may retain its validated 24x32 contract, and small creatures retain 32x32.
- Prefer one exact-grid PNG per coherent action family with `down/left/right/up` rows and time across columns. Do not default to unwieldy one-row strips or combine unrelated idle, walk, attack, and skill actions into one atlas. Every frame uses the same declared cell, and PNG dimensions equal cell size times column/row count. Keep King's body/weapon and oversized crescent VFX in separate `AnimatedSprite2D` assets even if a combined proof is used for timing review.
- Keep active actor sheets on a fixed direction-row grid: down, left, right, up; action time advances across columns.
- Character body scale must remain constant across directions and action cells. Normalize from a per-direction standing reference, keep one foot baseline, and allocate a wider cell rather than shrinking an actor, long weapon, reach, lean, or collapse.
- Generated multi-frame actors must never be independently width-fit or height-fit per cell. Derive one scale from the approved standing reference for each direction row, apply it unchanged across that row, preserve the source-cell origin, and widen the runtime canvas for extended poses. Prefer source-board dimensions divisible by the declared grid; when a preserved legacy board is not divisible, derive rounded proportional boundaries instead of truncating every cell. Recover only the connected actor when a pose crosses an ideal source-cell edge and reject disconnected neighboring fragments or decorative debris. Prefer named `SpriteFrames` on `AnimatedSprite2D` for recurring body states so artists can preview the active animation in Godot; controller signals still own gameplay timing and hitboxes.
- For a visible-limbed playable character, reject any frame with disconnected hands, changing arm count/length, a weapon grip that jumps between hands, inconsistent weapon length, or anatomy that changes between directions. Approve identity and contact frames at gameplay scale before producing a complete skill sheet.
- Validate rigid weapons as complete constructions, not blade silhouettes: extend both blade rails through the guard and reject any hand, grip, or pommel outside them. If an integrated character/weapon sheet fails, regenerate or repair that integrated sheet one direction/action at a time. Do not replace its character or weapon with programmer-drawn raster layers unless the owner explicitly approves that visual method.
- Prefer action-owned playable sheets when one mixed board would couple unrelated frame counts or encourage unstable crops. Preserve the `<action>_<direction>` animation API so scenes do not depend on atlas layout.
- Generated poses may cross an ideal source-grid boundary. Isolate the complete connected actor from an expanded cell before measuring scale; do not use a fixed inset that can flatten a head or include the next pose in the reference bounds.
- Attack and dash normalization must preserve a fully padded head silhouette and direction-appropriate facial landmarks: two readable eyes facing down, one profile eye facing left/right, and a complete back-of-head facing up. Down/up attacks keep the head and tunic centered on the same screen-space vertical axis; do not reuse a diagonal side lunge for a cardinal vertical strike. Put extreme motion into torso, feet, cloth, and equipment rather than rotating a low-resolution head until its face disappears.
- Existing integrated actor actions that extend beyond a 24x32 locomotion cell may retain a documented larger fixed canvas, currently 64x48, provided body scale and foot baseline remain constant across every frame.
- Modular playable weapons may be separate `Sprite2D` presentation driven by the same attack-phase signals as the actor, or integrated into character-owned action frames when the silhouette requires visible hand/weapon contact. There must be one presentation owner per action. Never rotate a separate weapon around its texture center unless the grip is actually centered. Visible weapons use reviewed integer-pixel hand anchors, never own hit timing or damage, and remain close enough to read as intentionally controlled. Opaw's legacy armless body may retain its small explicit gap and bounded orbit; King and later visible-limbed characters align to authored hands. Equipping an essence does not automatically replace the signature weapon sprite.
- Each obtainable melee weapon must reference a valid data-owned `Shape2D`. Combat installs that shape as contact authority; presentation may read its bounds to size a trail or cleave guide but may never derive damage or contacts. Every opaque or strongly emphasized part of a contact VFX, including its side edges and tip, must remain inside that authority and receive focused center/edge regression coverage. New greatsword, axe, scythe, spear, or dual-weapon families must author reviewed family shapes instead of silently inheriting Balanced Slash.
- Keep weapon skill power separate from normal-hit tuning. `WeaponDefinition.damage` feeds weapon-scaled abilities; `basic_damage_minimum/maximum` own the integer normal-hit roll. Do not rebalance one by silently changing the other.
- Front-facing detached equipment must make the grip connection readable before implying anatomical handedness. Opaw's current sword hilt meets the left torso edge and its blade rises outward toward screen-left, away from the head; side grips remain close and above the torso midpoint unless a weapon family's weight deliberately requires a broader stance.
- Keep sword grade separate from animation duplication. Grades may reuse one weaponless body sheet and one `SwordAttackStyleDefinition`; author a new style only when the weapon family needs a meaningfully different orbit, extension, trail, or accent. Style data is presentation-only and must not silently alter authoritative reach, damage, knockback, or phase timing.
- Normal sword variety may cycle deterministic style-owned sweep directions and arc/extension multipliers when an authoritative wind-up begins. Keep the sequence readable, reset it when changing weapon definitions, and describe any visually stronger final sweep honestly unless gameplay authority separately grants a combo bonus.
- A true combo must be data-owned rather than inferred from visual cycling. Each accepted step snapshots its direction and owns timings, damage multiplier, movement, contact shape, control values, buffer/reset windows, and animation key; presentation may not redirect the step when later movement input arrives.
- Alternate or superseded character art must use a separate variant folder and complete presentation resource. Before an active-model replacement, preserve the previous full sheet set and `SpriteFrames` as a restorable variant unless the project owner explicitly requests permanent deletion after approving the replacement; never depend on filename history alone for a requested visual backup.
- Keep only active assets and explicitly supported loadable rollbacks under `assets/`, active scenes, `tools/`, and `tests/`. After confirming no runtime references, move rejected experiments, superseded scenes, obsolete processors/tests, and legacy runtime material intact under Godot-ignored `art_source/archive/`; document the move and never leave stale regeneration commands pointing at archived code.
- Left/right modular weapon attacks must be true screen-space mirrors unless the weapon explicitly requires asymmetric technique. Keep the trail center on the authored hand path rather than the face or actor origin; small scale/color accents may add impact but must remain presentation-only.
- Integrated weapon-and-hand art remains appropriate for non-modular actors whose silhouettes depend on it. Do not mix integrated and detached versions of the same active weapon without an explicit presentation owner.
- Compact service NPCs may use visible integrated arms and role tools when a stationary authored work animation depends on readable hand-to-tool contact. Treat this as an actor-specific action silhouette, keep body scale and foot baseline stable, and do not generalize the exception to Opaw's approved armless modular model.
- Defeat presentation should use authored recoil/weaken/slump frames before a runtime fade. Keep active raster edges binary-alpha; translucency belongs to runtime modulation rather than partially transparent sprite fragments.
- Active hard-pixel sheets must use binary alpha only. Semi-transparent edge fragments are prohibited.
- Remove generated source mattes before nearest-neighbor reduction and fail processing when matte-family pixels remain connected to or isolated around an actor. Inspect transparent outputs over checkerboard, green grass, lime-corrupted terrain, and a dark floor; visible green/lime, magenta, blue, or dark background fringe is never an acceptable runtime pixel.
- Oversized ability VFX may use effect-only atlases with cells larger than the actor when that space preserves a peak plume, shock ring, or decay frame without shrinking it. Keep one stable local origin, rotate reusable directional effects through a presentation pivot, use a narrow bright core to communicate the real contact lane, and document all larger outer ribbons as cosmetic. Never bake Opaw, a hand, or one sword grade into a reusable Warrior-technique atlas.
- Cinematic character skills may coordinate `AnimatedSprite2D`, `AnimationPlayer`, CanvasLayer overlays, camera, shader, and audio presentation, but must release overlays and camera state on completion, cancel, defeat, pause, transition, and teardown. Screen cracks, black frames, letterboxing, and reality distortion never own hit resolution, invulnerability, or saved progression.
- Movement collision represents the underfoot footprint; hurtboxes represent the damageable body and remain separate shapes. Enemy movement and crowd-separation radii belong to `EnemyDefinition` and must be applied through `EnemyFootprintSystem` so physical collision and `NavigationAgent2D` cannot drift. Attack geometry remains ability-specific and must never be replaced by the movement circle merely for consistency.
- Palette reduction must use no dithering for the current style unless a later art-direction decision explicitly changes it.

## Environment Scene Organization

- Group visuals, collision, navigation, shadows, effects, audio, and interaction areas under clearly named owners.
- Do not add empty organizational nodes when a prop does not need that responsibility.
- Split tall objects into lower and upper visuals when correct player occlusion requires separate draw ordering.
- Place collision around the traversability footprint, not the full visible canopy, roof, or decorative silhouette.
- Keep navigation obstacles/regions consistent with collision unless a documented gameplay rule requires different behavior. Bake obstacle clearance for at least the largest movement radius expected to use that map, and verify routes around large blockers with that actor's physical footprint; do not mask a wedged route with teleport correction.
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
- Save active combat-stage TileMap cells in the owning scene. Use `AuthoredGroundLayout` as the diffable composition source and `tools/bake_authored_ground.gd` when regenerating a whole map; ordinary local adjustments may then be painted and saved directly in Godot without runtime randomization.
- In authored ground legends, use `Vector2i(atlas_x, atlas_y)` for source 0 and `Vector3i(atlas_x, atlas_y, source_id)` only when a transition map intentionally combines registered TileSet sources.
- Keep shared biome tiles under `assets/environment/<biome>/shared/`; keep genuinely region-specific tiles and props under `assets/environment/<biome>/<region>/`. Preserve generated source/clean boards under the matching `art_source/generated/environment/` hierarchy.
- Organic tree placement may be asymmetric. Landmark props must align to a visible path, threshold, plaza, encounter boundary, or authored symmetry and must not be scattered through empty space merely for variation.
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
