# Architecture

## Status

This document combines the implemented project foundation with proposed gameplay architecture. Sections explicitly identify systems that do not exist yet.

## Architecture Goals

- Responsive deterministic-enough gameplay logic with presentation kept separate where practical.
- Composition for reusable capabilities such as health, hurtboxes, hitboxes, movement, status effects, and abilities.
- Data-driven content through custom `Resource` types.
- Explicit ownership and one-way dependencies.
- Event-driven updates instead of unnecessary `_process()` work.
- Support large enemy counts without premature abstraction.
- Avoid hard-wiring decisions that make later multiplayer authority separation impossible.

## Proposed Folder Organization

Create folders only when their first real asset is added.

```text
res://
  assets/                 # Source game assets grouped by type/domain
  audio/                  # Audio buses and audio resources
  autoload/               # Deliberately small global services
  core/                   # Reusable low-level components and utilities
  data/                   # Custom Resource definitions and content data
  entities/
    player/
    enemies/
    bosses/
    npcs/
  gameplay/
    abilities/
    combat/
    items/
    progression/
    status_effects/
  levels/                 # Maps, encounter scenes, and level-specific logic
  ui/                     # Screens, HUD, menus, and reusable controls
  tests/                  # Automated tests when a test framework is selected
```

## Proposed Runtime Scene Hierarchy

The first playable slice should converge on a hierarchy similar to:

```text
Game
|- World
|  |- Level
|  |- Actors
|  |- Projectiles
|  `- Effects
|- GameplayServices
`- UI
```

Exact ownership should be validated by the prototype. Nodes must not locate core dependencies through fragile absolute scene paths.

## Implemented Foundation

The main scene is `res://levels/test_arena/test_arena.tscn`. Its current hierarchy is:

```text
Game
|- World
|  |- Level
|  |- Actors
|  |- Projectiles
|  `- Effects
|- GameplayServices
`- UI
```

The arena owns a reusable `Player` instance under `World/Actors`. Projectile, effect, and service containers remain empty ownership boundaries for upcoming systems.

The player currently composes:

- `PlayerInputSource`: translates keyboard, mouse, and gamepad input into movement/aim intent.
- `PlayerMovementComponent`: pure acceleration, deceleration, and speed calculation.
- `Player`: owns physics authority, movement bounds, and facing state.
- Hidden attack pivot: observes `facing_changed` and rotates only the authoritative melee hitbox.
- `MeleeAttackComponent`: owns sword attack phase state and activates its hitbox from weapon data.
- `PlayerAnimation`: observes movement, facing, attack, evade, interaction, damage, and defeat events and selects Alden's action-owned `AnimatedSprite2D` states without changing node scale.
- `PlayerWeaponVisual`: observes facing, normal-attack phases, ability phases, resume, and defeat; it treats its node as an authored grip pivot, applies definition-owned sprite offset/scale/radius metadata, and drives the visible weapon plus short-lived swing trail without owning contacts, damage, or attack timing.
- `EvadeComponent`: owns dash/recovery phases, locked direction, speed, and invulnerability events.
- `DashVisual`: observes evade events and creates replaceable placeholder afterimages.
- `AbilityComponent`: owns Sweeping Cut cast phases and instance-local cooldown state using immutable `AbilityDefinition` data; its definition also supplies read-only name, icon, and description metadata to presentation.
- `SweepingCutVisual`: observes cast phases and renders a replaceable frontal sword arc without owning damage.
- `PlayerProgressionComponent`: owns player-local XP, level, coins, cap evaluation, and progression signals from immutable `ProgressionDefinition` data, synchronizing totals through `RunSession` when they change.
- `EquipmentShowcaseDefinition`: player-configured, immutable content used only by the paused character preview. It does not own inventory, equip state, stat modifiers, acquisition, or saving.

The Ashwood Blade uses a shared `WeaponDefinition` resource whose stable ID and world texture are consumed by presentation. `MeleeAttackComponent` consumes its damage and timings, `MeleeHitbox` deduplicates contacts per swing, `HurtboxComponent` forwards explicit `DamageInfo`, and `HealthComponent` owns health/death state. A resettable training target exercises the full path.

The player dash uses shared `EvadeDefinition` data. `Player` remains movement authority and chooses dash velocity while `EvadeComponent` is in `DASHING`. `HealthComponent` receives invulnerability state from evade signals. Attack/evade mutual exclusion is enforced through the player's public request methods.

Sweeping Cut uses `AbilityDefinition` plus `AbilityComponent`. `SkillLoadoutDefinition` references four immutable `SkillSlotDefinition` resources; the first points to that same Sweeping Cut definition while the remaining slots describe sealed presentation without inventing gameplay components. `Player.get_ability_component_for_slot()` resolves an equipped definition to actor-owned runtime state. Its wider `MeleeHitbox` sends normal `DamageInfo` with optional pushback strength. Enemy-local `KnockbackComponent` observes accepted damage and exposes a brief decaying velocity contribution; each enemy remains movement authority and decides when that contribution may affect motion. Committed Mireling leaps ignore pushback motion so their marked landing remains predictable.

The Forsaken Thrall uses shared `EnemyDefinition` data, canonical runtime art under `assets/characters/enemies/forsaken_thrall/`, and an explicit state machine. Chase facing follows navigation steering rather than direct target bearing, attacks require unobstructed world line-of-sight, and enemy movement bodies collide with world but not the player. Hitboxes and hurtboxes retain combat authority, preventing attack-lock pinning.

`CombatHUD` binds to the player's `HealthComponent` and observes health/damage-blocked signals. `Player` owns the defeated state and cancels its active combat components. `ArenaFlow` observes `Player.defeated`, reveals the restart presentation through the HUD, and owns scene reload. The HUD never applies damage or reloads gameplay itself.

`EnemyHealthBar` is a reusable world-space presentation component used by Thralls, Mirelings, and Bramble Spitters. Mireling runtime art is canonicalized under `assets/characters/enemies/mireling/`; its superseded 24x24 experiment is preserved outside Godot runtime imports. The health bar observes `HealthComponent.health_changed` and `died`, updates only on signals, and uses a one-shot timer to hide after 2.2 seconds. It never owns, calculates, or mutates health. Boss health presentation may reuse the binding approach without requiring the same compact scene.

`EnemyRewardComponent` observes its own actor's `HealthComponent.died` event and grants the injected player XP/coins from its `EnemyDefinition`. Enemy definitions own only reward values; the recipient owns mutable totals. `RunSession` retains only XP and coin totals across scene replacement; each new `PlayerProgressionComponent` reconstructs its level from immutable thresholds. `CombatHUD` and `CharacterMenu` observe progression signals and never calculate thresholds or award currency.

`EncounterController` owns a stage's data-driven wave lifecycle, injects the shared `World/Projectiles` parent into projectile-capable enemies, and creates one `StagePortal` after the final wave. `StagePortal` owns player proximity and F-input, emits prompt visibility, and delegates valid destinations to the `SceneTransition` autoload. HUD owns prompt presentation. Stage 1 has three beginner waves and targets Stage 2; Stage 2 has two authored introductory waves and opens its return portal only after clear.

`Stage2Flow` composes player/HUD binding, an arrival-lore delay, manual `EncounterController.start_encounter()`, Stage 2 clear messaging, and local defeat/restart ownership. `EncounterController` retains encounter authority; `Stage2Flow` never creates enemies, applies damage, or decides wave results.

`AudioDirector` is a narrow autoload that owns Music, SFX, and reserved UI buses plus one music player. The director and music player process while the scene tree is paused so dialogue and menus never interrupt ambience, and assigned OGG music is normalized to loop. A level-local `StageMusic` requests an `AudioStream`; it never owns gameplay timing or combat authority. The Headless display backend assigns streams but intentionally skips native playback because no audio device exists.

`PlayerActionSfx` and `ActorActionSfx` are actor-local `Node2D` observers, so positional sounds follow their owning actor. Player swings/dash and enemy attack cues respond to existing phase/state signals. Accepted hit and player-damage sounds remain in `CombatFeedbackPresenter`, while the Bramble impact scene owns its self-cleaning impact cue. All playback is presentation-only and uses the SFX bus.

`CombatFeedbackPresenter` is a level-local presentation observer configured with the player, World/Effects parent, and player camera. It listens to accepted player melee/ability hits and accepted player damage, then spawns self-cleaning `DamageNumber` and `HitBurst` scenes. It moves camera offset briefly in pixel units but never adjusts global time scale, damage, hit detection, or actor state.

`SummonEffect` is instantiated under `World/Effects` at the selected spawn position. It owns only rune/lightning/spark presentation, cleans itself after 0.8 seconds, and never changes spawn timing, health, collision, or damage. Wave-clear presentation observes controller signals during the 2.25-second inter-wave recovery.

## System Boundaries

### Actors

Player, enemies, and bosses coordinate reusable components. They should not duplicate health, damage, hit detection, or status-effect rules.

### Combat

Combat should model attack intent/data separately from visual effects. Hitboxes produce explicit hit information; hurtboxes validate and forward it to a damage receiver. Damage authority belongs to gameplay logic, not animation callbacks alone.

Implemented sword flow:

```text
PlayerInputSource -> Player -> MeleeAttackComponent
-> wind-up -> active MeleeHitbox -> HurtboxComponent
-> HealthComponent -> health/damage/death signals
```

Implemented ability flow:

```text
PlayerInputSource -> Player request_ability_1 -> AbilityComponent
-> cast phases -> wide MeleeHitbox -> HurtboxComponent
-> HealthComponent -> optional KnockbackComponent response
-> cooldown signals -> reusable SkillBarSlot bound through the player loadout
```

Presentation observes facing and action-phase signals. Alden's canonical runtime body lives under `assets/characters/playable/alden/` as separate direction-row sheets for idle, walk, weaponless attack body, dash, interaction, hurt, and defeat. `tools/process_alden_modular_assets.gd` removes chroma, expands around ideal generated cells, retains the primary connected actor silhouette plus nearby pieces, rejects neighboring-pose spill, quantizes hard alpha, and normalizes every direction's standing reference to an 18x27 silhouette on the shared 32-pixel foot baseline. Ordinary states use 32x32 cells; extended attack/dash/interaction poses use 48x32, and defeat uses 64x32 so horizontal collapse never forces a smaller body. `PlayerAnimation` keeps the same `<action>_<direction>` API, maps authoritative wind-up/active/recovery directly to attack frames 0/1/2, and never modifies sprite scale. A sibling `PlayerWeaponVisual` renders the `WeaponDefinition.world_texture` under `VisualRoot`, treats its node as the grip pivot, applies definition-owned sprite offset/scale/radius data, and uses body-rig hand anchors plus true mirrored side rotations through wind-up, active, recovery, ability, and defeat. The active strike uses a short scale/color accent and a hand-centered tapering `SwordSwingTrail`; neither changes hit timing or reach. `SwordPivot` remains invisible and orients only the authoritative melee hitbox; body art, visible weapons, effects, audio, HUD icons, or inventory UI must not become damage authority. The superseded single Alden atlas and former Awakened 24x32/64x48 presentation remain legacy material with no active player reference.

Top-down movement collision is a 6-pixel circular foot footprint centered at `y = -4`. Hurtboxes are separate 24-pixel body capsules centered at `y = -14`. Character shadows are centered at `y = -2`, directly beneath sprite feet. Sword and Thrall attack shapes are centered 18 pixels from their body-centered pivots.

### Abilities and Weapons

Definitions should be custom resources; runtime state should live in nodes or plain runtime objects owned by the actor. Shared resource assets must never accidentally store per-instance cooldown or mutable combat state.

### Enemy AI

Use finite-state or hierarchical state behavior appropriate to complexity. Expensive sensing and path recalculation should be scheduled or staggered rather than executed for every enemy every frame.

The Forsaken Thrall uses scheduled `NavigationAgent2D` target updates and follows the baked arena path. Thralls, Mirelings, and Bramble Spitters compose `EnemySeparationComponent`, an `Area2D` that observes only nearby enemy bodies and blends gentle repulsion into movement steering. Attack states, committed Mireling leaps, and committed Spitter shots ignore separation so combat timing remains predictable.

The Bramble Spitter uses canonical 32x32 runtime art under `assets/characters/enemies/bramble_spitter/` and an explicit positioning/wind-up/recovery state machine. It snapshots one player position before presentation displays a world-space red ground marker. `HostileProjectile` owns seed travel and hit delivery through the standard `DamageInfo`/`HurtboxComponent` contract; the sprite and marker remain presentation-only. The configured seed terminates at its committed target position, collides with player hurtboxes and world bodies along the route, and retains a fixed lifetime safety limit.

Spitter firing presentation observes `shot_telegraphed` and `shot_fired`: it owns the three-frame charge sequence, swelling, restrained recoil, red target marker, muzzle flash, and sparks. Movement steering and facing are intentionally separate while kiting so the creature backs away without visually turning from its target. `HostileProjectile` creates a configured presentation-only impact scene when authoritative collision resolves; trails and impact art never determine damage or hit timing.

### Save System

Not designed. Future saves need versioned schemas, explicit serialization, migration support, and separation of settings, profile progression, and run/session state. Do not serialize arbitrary scene trees as the save format.

### UI

UI observes model state through signals or presenters and sends player intent through explicit interfaces. Gameplay rules must not be owned by HUD nodes.

The implemented combat HUD displays a compact corner vitality bar, blocked-damage feedback, and the fallen/restart panel. Persistent control/build banners were removed from combat space; future help belongs in a contextual or paused surface. These controls may be reskinned without changing health or arena flow.

Stage presentation is a brief top-edge label. The centered lower screen contains a compact four-slot bar that remains readable without covering the playfield center.

The centered HUD and `CharacterMenu` consume the same player-owned `SkillLoadoutDefinition`. `CombatHUD` creates four reusable `SkillBarSlot` observers; the slot bound to an actor `AbilityComponent` displays its signal-driven cooldown, while unbound definitions remain visibly sealed. `CharacterMenu` creates four reusable `SkillSlotCard` buttons for read-only information and future setup intent.

The character surface also consumes one immutable `EquipmentShowcaseDefinition`. Its Gear page composes reusable `EquipmentSlotCard`, `EquipmentItemCard`, and `EquipmentDetailPanel` scenes around presentation-only Alden plus the same Ashwood Blade world texture used by the player. `EquipmentDefinition` owns stable ID, slot, rank, icon, lore, preview power, and future synergy copy. The current showcase contains exactly one Wood-rank starter; Stonebound, Iron, Rare, ownership, and acquisition remain unimplemented. The UI never feeds preview power or synergy text into `MeleeAttackComponent`, `AbilityComponent`, rewards, or persistence. A future mutable inventory/equipment authority must issue explicit equip commands and aggregate approved stat modifiers outside the UI.

Mouse click and directional focus plus `ui_accept` select tabs and cards. Physical Tab is handled by `CharacterMenu._input()` before Godot can consume it as `ui_focus_next`; Escape or the top-right button closes the surface. The HUD's satchel button emits `character_menu_requested`, and each level flow connects that presentation intent to the local `CharacterMenu` without making the HUD own pause, inventory, or equipment state. Neither character page calculates readiness, progression, rewards, unlocks, casts, ownership, or equipment bonuses.

Native Godot `Button` signals remain the common activation path for mouse, keyboard, and controller input. `SceneTransition` owns the only global layer-100 input shield: its transparent overlay uses `MOUSE_FILTER_IGNORE` while idle, switches to `MOUSE_FILTER_STOP` only during an active fade/scene replacement, and restores pointer pass-through after completion or failure. Decorative controls must not intercept pointer events. Gameplay modals keep explicit focus loops and visible pointer-operable controls.

Reusable interaction prompts are contextual: an interactable emits visibility, text, and an optional semantic presentation icon while the HUD presents one prompt above the centered skill bar. The portal configures `icon_interaction_portal`; NPCs use `icon_interaction_talk`. `DialogueNpc` retains the nearby `Player` only while they overlap, requests `begin_interaction(global_position)` before opening dialogue so Alden faces the speaker, and finishes the interaction when dialogue/prompt ownership returns. Interactables do not duplicate the same instruction in world space, gameplay does not branch on icon filenames, and leaving the area clears both text and icon immediately.

`battle_of_gods_theme.tres` is the shared base for HUDs and menus. It owns common panel, label, button, progress-background, separator, focus, disabled, and tooltip treatment. Individual scenes retain local overrides only for meaningful state such as health fill, cooldown, equipped, or sealed presentation. Named icons are independent textures so presentation can replace one concept without repacking an atlas or modifying gameplay authority.

`TitleScreen` is the project entry scene and owns only menu presentation and navigation intent. It resets `RunSession` for a new journey, delegates scene replacement to `SceneTransition`, and changes audio-bus mute state through the existing AudioDirector-owned bus names. Its settings are session-only. `TitleBackground` is a separate presentation scene with `Base`, `DistantSilhouette`, `Atmosphere`, and `Vignette` layers; its tweens perform restrained visual motion without polling or gameplay authority.

`SanctuaryFlow` composes the safe hub. It binds the existing player HUD, forwards contextual prompt metadata from two reusable `DialogueNpc` instances and `ExpeditionAltar`, and opens `DialoguePanel`, `CharacterMenu`, or `ExpeditionMenu`. Eira's completed dialogue opens the existing skill-information surface; an Escape cancellation restores play without chaining into that menu. Orren remains an honest dialogue-only preview until shop authority is designed. Interactables own proximity and emit intent; they do not draw HUD text, mutate progression, calculate prices, or replace scenes. Dialogue and expedition surfaces own their temporary pause and restore it on close. Future route requirements belong in a profile/story access authority, not in button labels or portal code. A future expedition-abandon action belongs in a pause/flow authority with confirmation and explicit run-state policy, not in a stage-local raw scene-change input.

### Environment Assets

Reusable environment props should be self-contained scenes when they need behavior or multiple gameplay layers. A large prop may own:

```text
EnvironmentProp
|- Visuals
|  |- LowerVisual       # Trunk/base that can appear behind the player
|  `- UpperOccluder     # Canopy/roof that can appear in front of the player
|- Collision
|- Navigation           # Obstacle/region data when required
|- Shadow
|- Effects
|- Audio
`- InteractionArea
```

Only include nodes the prop actually needs. Collision represents traversability and must remain independent from decorative sprite transparency.

Use Godot 4.7 `CanvasItem` ordering and Y-sorting at deliberate ownership boundaries. Split lower and upper visuals when one sprite cannot produce correct occlusion. Do not solve depth by changing arbitrary `z_index` values from unrelated gameplay scripts.

The first environment prototype must validate player-versus-prop ordering, collision, navigation impact, shadow placement, and performance before this becomes a locked scene template.

The implemented `AncientTree` and `RuinedStatue` each use one seam-free convex footprint derived directly into navigation. This replaced the statue's overlapping rectangles and stale small navigation cutout. The tree canopy retains low-frequency presentation-only sway.

### Tile-Based Worlds

Use Godot 4.7's current tilemap workflow and reusable tile data rather than one-off level sprites. Separate conceptual responsibilities where the content requires them: base terrain, transition/variation data, decorative overlays, collision, navigation, and foreground occlusion.

Terrain and tile-source conventions remain provisional until a representative environment test is built. Avoid producing a broad tileset before scale, palette, transitions, collision shapes, and navigation behavior are validated together.

The proving ground uses `TileMapLayer` with a reproducible `bright_ground_tileset.tres` generated from a 2x2 atlas. `prototype_ground.gd` fills a 30x18 test map with deterministic variation. Terrain transitions and editor-painted production maps remain future work.

Sanctuary owns a separate 64x64 `sanctuary_ground_tileset.tres`; it never reuses the combat-stage grass resource. `SanctuaryGround` fills the 18x12 hub and derives one-cell cardinal pavement transitions from an authored route set, including branches to both side buildings. Its terrain, buildings, stall, trees, and Eira crop are reproduced by `tools/process_sanctuary_direction_board.gd` from the preserved direction board. The separately generated portal, fountain, and Orren sources are normalized by `tools/process_sanctuary_individual_assets.gd`, which performs deterministic green-key removal, largest-component isolation, hard alpha, palette reduction, exact-canvas fitting, and Orren's four-frame accent sheet. Runtime scenes load only normalized assets under `assets/`.

`ExpeditionAltar` now owns only the portal interaction, glow/runes, open center staircase, guardian footprints, rear backstop, and compact doorway trigger. The portal raster is deterministically split without changing its appearance: `GroundSprite` contains the stairs/threshold at `z_index = -1`, while the arch, guardians, and doorway normally remain at Z 0 and participate in the hub's Y-sort. A separate front-only `FrontDepthArea` begins farther south than the smaller interaction trigger and spans the full west-to-east guardian facade; entering it event-drives the structure to Z -1 before the character's head can be clipped at the doorway or either guardian, while leaving restores Z 0 and ordinary front/behind Y-sorting. The prompt trigger retains its independent close range, and no per-frame depth polling is used. `PortalBackstopCollision` is physics-only: it stops traversal through the monument's rear and never controls visual depth. `DivineFountain` is an independent sibling `StaticBody2D` with an editable basin polygon and presentation-only water/glow motion. Sanctuary deliberately leaves a visible courtyard gap between their baselines; automated radius-six traversal checks validate both walk-around routes and the center staircase. `NpcIdleBreath` is a reusable event-driven `Timer` that applies one-pixel steps to an injected visual node while collision, interaction, shadow, and gameplay authority remain stationary.

`EditorPreviewBackdrop` is reusable authoring-only presentation under `tools/editor/`. It draws a configurable ground checker only when its direct parent is the editor's current isolated scene root. It disables processing, self-removes outside editor hint mode, owns no collision or navigation, and therefore remains absent from composed-level editing, F5/F6, and exported gameplay.

Sanctuary house roots remain `StaticBody2D` physics owners. Their visual ground shadows are `Polygon2D`, while their independently editable blocking footprints are `CollisionPolygon2D`. The collision polygons begin from the previously validated rectangular bounds but may be refined around ground-contact architecture without coupling collision to sprite alpha, roof silhouettes, or shadow geometry.

`ArenaNavigation` builds a `NavigationPolygon` from one traversable arena outline and convex prop footprints. Thralls call `get_next_path_position()` every chase frame as required by `NavigationAgent2D`, use corridor-funnel postprocessing, and limit target reassignment to five times per second. This prevents empty-path deadlocks and extreme edge-centered detours around props.

## Autoload Policy

Autoloads are reserved for truly cross-scene services and must not become general-purpose mutable state. `SceneTransition` pauses gameplay, enables its top-layer fade/loading input shield, changes to validated scene paths, resumes the tree, fades back in, and disables the shield. `AudioDirector` owns audio-bus setup and cross-scene music routing; actor-local presenters own positional combat playback. `RunSession` is a deliberately narrow in-memory bridge containing only XP and coins. It does not award rewards, evaluate levels, unlock skills, or write save data.

## Signals and Event Flow

- Use direct signals for local ownership boundaries: component to actor, actor to HUD/presenter, or encounter to level.
- Use typed signals and connect them in code when the relationship is dynamic; editor connections are acceptable for stable scene-local wiring.
- Avoid a global event bus for routine communication. If one is introduced, document event ownership and lifecycle.
- Prefer commands/method calls for requests and signals for notifications of completed state changes.

Example combat flow:

```text
Input/AI intent -> Actor controller -> Ability/weapon runtime
-> Hitbox query -> Hurtbox validation -> Health/damage component
-> state-changed signal -> animation, audio, effects, and UI observers
```

## Data Flow and Resources

Custom resources are appropriate for immutable/shared definitions such as:

- Weapon definitions
- Ability definitions
- Enemy archetypes
- Status-effect definitions
- Loot/progression tables

Runtime state such as current health, cooldown remaining, or proc counters must be instance-owned.

## Dependency Rules

- Domain gameplay code may depend on `core` abstractions and data definitions.
- Presentation may observe domain state; domain logic must not depend on a specific HUD or visual effect.
- Levels may compose actors and services; reusable actors must not depend on a specific level.
- Content resources configure systems; resources must not reach into the active scene tree.
- Avoid circular dependencies and `get_node()` calls that cross distant ownership boundaries.

## Performance Principles

- Measure before introducing pooling; pool frequently spawned objects only when profiling shows allocation/lifecycle cost or spikes.
- Reuse projectiles/effects through a lifecycle-safe pool when volumes justify it.
- Use physics collision layers and masks narrowly.
- Prefer squared-distance checks where exact distance is unnecessary.
- Stagger AI sensing/path updates and disable processing outside relevant states.
- Budget particles, lights, navigation work, and simultaneous audio for enemy-dense encounters.
- Keep collision shapes simple and visual effects independent from damage detection.

## Multiplayer Readiness

Multiplayer is not planned for the first milestone. To avoid blocking it completely:

- Separate player intent from authoritative state changes.
- Avoid reading local input inside reusable combat/domain components.
- Give gameplay entities stable runtime identities when save/network requirements demand them.
- Keep random outcomes injectable/seedable where they affect gameplay.

Do not add networking abstraction before a real requirement; maintain clean authority boundaries instead.

## Testing and Verification

The project should eventually include:

- Unit tests for formulas, data validation, save migrations, and state transitions.
- Integration scenes for combat interactions and abilities.
- Performance test scenes for enemy/projectile budgets.
- Manual feel checks for input latency, dodge timing, telegraph clarity, and controller parity.

The automated test framework is undecided.

An interim headless smoke script at `res://tests/player_movement_smoke.gd` verifies speed limiting, diagonal normalization, and deceleration. It is intentionally lightweight and does not replace the future test framework.

`res://tests/melee_combat_smoke.gd` verifies a full sword attack deals one configured hit and returns to idle.

`res://tests/player_evade_smoke.gd` verifies dash distance, invulnerability, recovery lockout, and attack exclusion.

`res://tests/forsaken_thrall_smoke.gd` verifies enemy-to-player damage, sword-to-enemy damage, and lethal death-state transition.

`res://tests/player_defeat_flow_smoke.gd` verifies blocked-damage feedback, lethal defeat, combat lockout, zero-health HUD state, and delayed defeat presentation.

`res://tests/enemy_health_bar_smoke.gd` verifies hidden-at-full-health, damage visibility/value synchronization, timed hiding, and death hiding for both current enemy archetypes.

`res://tests/environment_navigation_smoke.gd` verifies 135 populated tile cells, Y-sort ownership, deferred navigation synchronization, a multi-point route, and 14-20 pixels of lateral tree clearance.

`res://tests/character_animation_smoke.gd` verifies all seven binary-alpha Alden action sheets, every populated cell, 18x27 directional reference scale, shared foot baseline, intact up-head contour, left/right dash area parity, separate three-frame attack/dash data, attack-phase frame mapping, unchanged node scale, arm-level anchors, mirrored side rotations, definition-owned grip motion, hurt recovery, four-frame defeat/fade, plus the existing Thrall action-art and foot-plane ownership contracts.

`res://tests/mireling_smoke.gd` verifies spawn state, body-slam damage, and sword damage against the weak Mireling.

`res://tests/mireling_leap_dodge_smoke.gd` verifies leaving the snapshot landing point avoids damage. `res://tests/enemy_obstacle_behavior_smoke.gd` verifies statue line-of-sight blocking, steering-facing agreement, and non-pinning enemy movement collision.

`res://tests/bramble_spitter_smoke.gd` verifies the ranged warning, committed aim direction, dodge behavior, and completed firing state transition.

`res://tests/thrall_statue_endpoint_smoke.gd` reproduces the exact opposite-side statue chase and guards against long stalls or incomplete routing. `res://tests/encounter_wave_structure_smoke.gd` enforces three waves, one-to-four enemies per wave, and one portal after stage clear.

`res://tests/enemy_crowd_separation_smoke.gd` starts a tightly clustered mixed group and verifies minimum spacing, lateral spread, and continued pursuit.

`res://tests/summon_effect_smoke.gd` verifies encounter integration, segmented lightning construction, and effect cleanup without residual nodes.

`res://tests/portal_interaction_smoke.gd` verifies prompt enter/exit and explicit interaction. `res://tests/scene_transition_smoke.gd` verifies fade-controlled Stage 2 loading, destination spawn, delayed exit-portal absence, and its configured post-clear return destination. `res://tests/stage_2_encounter_smoke.gd` verifies the Grove's two-wave Spitter introduction, tile layout, navigation path, Y-sort ownership, and removal of placeholder presentation.

`res://tests/sweeping_cut_smoke.gd` verifies multi-target 20-damage delivery, pushback metadata and actor displacement, cast-time attack/dash exclusion, cooldown rejection, and reusable HUD-slot ready/cooldown feedback.

`res://tests/player_progression_smoke.gd` verifies initial state, threshold leveling, cap behavior, reward delivery after enemy death, and HUD presentation. `res://tests/run_session_progression_smoke.gd` verifies XP/coin reconstruction across player replacement and explicit run reset. `res://tests/character_menu_smoke.gd` verifies the shared loadout, reusable selectable cards, two-page focus ownership, pause ownership, close control, Alden/Ashwood armory inspection, and reactive progression labels. `res://tests/equipment_preview_smoke.gd` verifies the single Wood-rank Ashwood definition, stable cross-resource weapon ID, shared world-art dimensions, compact-palette binary-alpha portrait, equipped state, and unchanged authoritative 25-damage tuning. `res://tests/title_screen_smoke.gd` additionally guards the global transition overlay's idle/during-fade pointer-filter contract. `res://tests/audio_director_smoke.gd` verifies the Music bus and stage-stream routing; it intentionally does not require physical playback in headless mode.

`res://tests/combat_feedback_smoke.gd` verifies accepted incoming and outgoing hits create a number plus burst, then clean up without changing combat authority.

`res://tests/combat_audio_smoke.gd` verifies Music/SFX/UI bus creation, assigned player and enemy action streams, state synchronization, accepted-hit cues, and Bramble impact audio without requiring device playback in headless mode.

`res://tests/sanctuary_hub_smoke.gd` verifies the dedicated tileset, eleven normalized binary-alpha assets, NPC idle animation, Alden's speaker-facing interaction pose/restoration, Eira-to-skill-menu handoff, Orren dialogue, split portal depth/idle layers, the compact doorway trigger, continuous six-pixel-footprint routes around both fountain sides, prompt ownership, pause restoration, and the Stage 1 destination.

