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
- `PlayerAnimation`: observes movement, facing, attack, evade, interaction, damage, and defeat events and selects Opaw's compact armless action-owned `AnimatedSprite2D` states without changing node scale.
- `PlayerWeaponVisual`: observes facing, normal-attack phases, ability phases, resume, and defeat; it treats its node as an authored detached equipment pivot, applies definition-owned grip/scale/radius metadata plus `SwordAttackStyleDefinition` orbit/trail/accent data, and drives the visible weapon without owning contacts, damage, or attack timing.
- `EvadeComponent`: owns dash/recovery phases, locked direction, speed, and invulnerability events.
- `DashVisual`: observes evade events and creates replaceable placeholder afterimages.
- `AbilityComponent`: owns generic cast phases, snapshotted equipped-weapon damage, definition-owned hitbox selection, timed per-strike hitbox activation, and instance-local cooldown state. `AbilityDefinition` supplies stable identity, activation/presentation modes, flat-plus-weapon scaling, per-strike damage/knockback/stagger data, active movement speed, timings, shape, and read-only UI metadata.
- `PiercingRushVisual`: observes cast phases and draws the white-gold spirit blade, streaks, and sparks without owning movement, contacts, damage, or cooldown. The preserved `SweepingCutVisual` remains available to the unequipped Sweeping Cut content.
- `PlayerProgressionComponent`: owns player-local XP, level, coins, cap evaluation, and progression signals from immutable `ProgressionDefinition` data, synchronizing totals through `RunSession` when they change.
- `EquipmentShowcaseDefinition`: player-configured, immutable content used only by the paused character preview. It does not own inventory, equip state, stat modifiers, acquisition, or saving.

Opaw's active `assets/characters/playable/opaw/compact_armless/opaw_compact_armless_sprite_frames.tres` is wired directly into `player.tscn`. It keeps the established action names, direction order, frame counts, 18x27 upright scale, and foot baseline, so the controller/menu API does not change. `tools/apply_opaw_attack_vertical_revision.gd` composes only the corrected down/up rows into the attack source while preserving approved left/right rows; `tools/process_opaw_compact_armless_assets.gd` then converts the seven generated boards into binary-alpha runtime sheets. The complete former active model lives under `variants/wayfarer_original/` with its own independently loadable `SpriteFrames` resource; changing one scene resource path is sufficient for a visual rollback. Rejected `handless`, `armless`, and `armless_small_feet` experiments and the superseded Awakened presentation live only under Godot-ignored `art_source/archive/`; their retired build scripts and tests no longer register with the project.

Ashwood Blade and Iron Sword each use a shared `WeaponDefinition` resource whose stable ID, authoritative damage/knockback/timings, and world texture are consumed by combat and presentation. Their referenced `SwordAttackStyleDefinition` owns only detached orbit, active extension, trail, strike-accent tuning, and a cyclic normal-swing presentation sequence. `PlayerWeaponVisual` advances the sequence on authoritative wind-up events; Balanced Slash currently cycles outward, reverse, and extended-finish variants. Sequence index never enters damage calculation. Balanced Slash is active for both early swords; Swift Slash and Heavy Cleave are inactive reusable profiles. `Player.set_weapon_definition()` remains the idle-only low-level synchronization seam for `MeleeAttackComponent` and `PlayerWeaponVisual`; `Player.equip_owned_weapon()` validates catalog identity, ownership, and class compatibility before using that seam and committing the equipped item to `WeaponInventory`. `MeleeAttackComponent` consumes weapon damage and timings, `MeleeHitbox` deduplicates contacts per swing, `HurtboxComponent` forwards explicit `DamageInfo`, and `HealthComponent` owns health/death state.

The player dash uses shared `EvadeDefinition` data. `Player` remains movement authority and chooses dash velocity while `EvadeComponent` is in `DASHING`. `HealthComponent` receives invulnerability state from evade signals. Starting a dash remains mutually exclusive with an active attack or ability; Decision 046 adds only the explicit basic-attack buffer and recovery-cancel boundary described below.

`PlayerInputSource` exposes movement and discrete action intent but no longer derives combat aim from the pointer. `Player` resolves each non-zero movement vector to one cardinal facing through the input source and retains that direction while standing. The InputMap binds basic attack to left mouse/right trigger; right mouse is intentionally unassigned. Reserved right-stick aim actions remain available for a future explicit targeting state; they do not change ordinary facing.

`Player` owns one non-stacking basic-attack buffer during `EvadeComponent.DASHING` and snapshots the movement-owned facing used when the attack was requested. When the evade announces `RECOVERY`, the player asks `EvadeComponent.cancel_recovery()` to end only that vulnerable phase, then requests the ordinary `MeleeAttackComponent` attack. A basic attack requested after recovery begins follows the same recovery-only cancel immediately. The active dash cannot be canceled, so full distance and invulnerability finish before the normal weapon wind-up, hitbox, damage, and presentation begin. Abilities remain mutually exclusive with evade, and no second dash-attack damage authority exists.

Piercing Rush uses the shared `AbilityDefinition` plus `AbilityComponent`. On accepted cast, the component snapshots `flat_damage + equipped_weapon.damage * weapon_damage_multiplier`, assigns the definition-owned hitbox shape, and owns phase/cooldown time. During `ACTIVE`, `Player` consumes the component's directional velocity and remains the only body/collision authority; movement-enabled abilities return zero velocity during wind-up/recovery so rush momentum cannot leak into a slide. `PiercingRushVisual` observes those phases and advances an effect-only six-frame atlas generated independently from Opaw and every sword. `tools/process_piercing_rush_vfx.gd` captures the intentionally irregular source zones, downsamples them with nearest-neighbor filtering, hardens alpha, and packs six 192x192 cells; `AbilityPivot` rotates the same right-facing frames for all four directions. The definition-owned 128x30 tapered lance matches the bright central visual spear; its roughly 160-pixel outer plume remains cosmetic. `AbilityDefinition` exposes the forward tip and widest half-width of a thrust shape so the core guide reads this immutable runtime data instead of duplicated presentation numbers. `PlayerActionSfx` observes the same definition/phase boundary and selects dedicated Piercing charge/thrust streams, while `CombatFeedbackPresenter` plays a dedicated impact stream only from accepted ability contacts. The active slot definition points to Piercing Rush, while the old Sweeping Cut definition and slot remain valid unequipped content. Weapon and ability hitboxes send normal `DamageInfo` with optional pushback strength. Enemy-local `KnockbackComponent` observes accepted damage and exposes a brief decaying velocity contribution; each enemy remains movement authority and decides when that contribution may affect motion. Committed Mireling leaps ignore pushback motion so their marked landing remains predictable.

Consecutive Thrust reuses that component with seven definition-owned strike multipliers. Each timed strike reactivates the same shape, deliberately resetting its one-target-per-window contact set, and emits `strike_started` for presentation only. `ConsecutiveThrustBodyVisual` hides the normal locomotion body only while it advances an eight-beat sheet deterministically built from approved Opaw frames; `ConsecutiveThrustVisual` rotates an independent 6x2 effect-only atlas through `AbilityPivot`; `PlayerWeaponVisual` alternates shallow sword poses; and `PlayerActionSfx` plays three spaced steel-thrust beats before a final sword thrust. Its 128x26 tapered lane uses immutable definition data, while its compact 72-pixel white guide and 24-pixel gold origin flare stay deliberately shorter so the rapid VFX remains a flurry instead of a long spear. The final visual starts its largest effect cell from that same final `strike_started` event, then uses a one-shot timer to step through three smaller, lower-opacity cells over about 0.18 seconds; it is not replaced by a recovery-frame flash. The atlas packer retains the final source cell's extra rightmost tip pixel and one matching output pixel, preventing the finishing lance point from reading as cut while keeping its placement, scale, and contact lane unchanged. It also strips only the detached forward residue from rapid frames 8 and 10, so their otherwise complete lance tips cannot read as a broken neighboring cell. The selected final sword source has a delayed dramatic burst, so `PlayerActionSfx` begins it at its measured 0.50-second audible onset; the accepted-contact source similarly starts at its measured 0.125-second metal onset. Visual shallow-angle offsets never change the snapshotted cast direction or contact lane. Small flurry contacts create a number/flash only on alternating hits, avoiding burst/camera/hitstop churn; only the finishing strike requests heavy feedback and its contact-only blade sound. The 18/19/20/21/22/25/100% damage sequence, zero non-final knockback, 150 final knockback, 0.21 repeated stagger, and 0.42 final stagger remain in `consecutive_thrust.tres`.

`DamageInfo` carries optional knockback and stagger values alongside damage/source/direction. `KnockbackComponent` and `StaggerComponent` observe accepted health damage and scale control through `EnemyDefinition.CrowdControlTier`: Light is full strength, Elite is 35% movement knockback and 45% stagger duration, and Boss is fully control-immune. Enemy controllers configure their components from their own definition, own the `STAGGER` state, deactivate their hitbox on entry, and resume their ordinary state loop only after the observer says stagger expired. The components never choose enemy movement, attack timing, or visuals.

The Forsaken Thrall uses shared `EnemyDefinition` data, canonical runtime art under `assets/characters/enemies/forsaken_thrall/`, and an explicit state machine. Chase facing follows navigation steering rather than direct target bearing, attacks require unobstructed world line-of-sight, and enemy movement bodies collide with world but not the player. Hitboxes and hurtboxes retain combat authority, preventing attack-lock pinning.

`CombatHUD` binds to the player's `HealthComponent` and observes health/damage-blocked signals. `Player` owns the defeated state and cancels its active combat components. `ArenaFlow` observes `Player.defeated`, reveals the restart presentation through the HUD, and owns scene reload. The HUD never applies damage or reloads gameplay itself.

`EnemyHealthBar` is a reusable world-space presentation component used by Thralls, Mirelings, Rootlings, Bramble Spitters, and Rootbound Husk. Mireling runtime art is canonicalized under `assets/characters/enemies/mireling/`; no superseded Mireling body remains in runtime or source archives. The health bar observes `HealthComponent.health_changed` and `died`, updates only on signals, and uses a one-shot timer to hide after 2.2 seconds. It never owns, calculates, or mutates health. Boss scenes may author a larger parent offset around the same component; Husk moves it above its antlers without changing health authority.

`EnemyRewardComponent` observes its own actor's `HealthComponent.died` event and grants the injected player XP/coins from its `EnemyDefinition`. Enemy definitions own only reward values; the recipient owns mutable totals. `RunSession` retains only XP and coin totals across scene replacement; each new `PlayerProgressionComponent` reconstructs its level from immutable thresholds. `CombatHUD` and `CharacterMenu` observe progression signals and never calculate thresholds or award currency.

In debug builds only, `Player` handles the F9 `debug_max_progression` action, asks `PlayerProgressionComponent` to apply the authored level-cap XP plus 999 coins, grants all current compatible `WeaponCatalogDefinition` entries to the session `WeaponInventory`, then switches from the normal immutable loadout to `opaw_debug_test_loadout.tres`. That test resource exposes only fully authored slots 1-2; HUD and character-menu observers rebuild from `skill_loadout_changed`, including the test inventory. The component remains mutation authority, synchronizes `RunSession`, and emits normal progression signals; release builds reject the preset, and it never writes disk state or marks Eira/Orren progression as complete.

`Rootling` is an independent `CharacterBody2D` controller rather than a Thrall variation. It uses the shared health, reward, navigation, separation, knockback, stagger, and hitbox contracts, but owns the unique `CHASE -> WIND_UP -> ACTIVE -> RECOVERY` sequence. Entering `WIND_UP` snapshots its direction, rotates the 40x16 `AttackPivot` lane once, and emits a crack telegraph. Neither later target motion nor its own knockback changes that pivot; `ACTIVE` emits the VFX/sound and activates the same locked lane. `RootlingVisual` owns the four-direction 32x32 walk/reaction atlases and the separate 48x48 root-jab VFX atlas. `tools/process_rootling_atlas.py` converts only approved chroma-cleaned source boards into those compact runtime atlases.

`RootboundHusk` is a separate Boss-tier `CharacterBody2D` mini-boss controller. It directly preloads its attack-profile script so editor parsing does not depend on newly refreshed global-class metadata. The profile owns spear, fan, point-blank burst, and below-half-health timing values; `EnemyDefinition` owns health, damage, range, movement, and rewards. The controller snapshots directions, rotates authoritative 112x20 lane hitboxes before wind-up, stages the fan's center and side windows, and activates a separate circular burst hitbox when the target crowds its body. `RootboundHuskVisual` observes controller signals through one `AnimatedSprite2D` body and ground-layer root VFX; named animations never activate damage. `tools/assemble_rootbound_husk_redesign.gd` and `tools/process_rootbound_husk_assets.gd` keep fixed direction-row scale, a stable foot baseline, complete up-facing crowns, exact mirrored side walks, and non-shrinking `72x64` walk plus `96x64` root-command sheets. `tools/build_rootbound_husk_sprite_frames.gd` creates exactly 28 body animations, including approved `hurt_*` and four-frame `dead_*`, plus the separate six-stage `128x64` ground-root VFX animations. Root-command presentation uses only `root_attack_wind_up_*`, `root_attack_active_*`, and `root_attack_recovery_*`; every cast-named asset, stale import, and retired Husk body archive was permanently deleted.

The authored death sequence now keeps its four manually reviewed directional reaction frames. `RootboundHuskVisual` fits their playback to the controller's 0.6-second death window before the actor frees itself; the asset builder reproduces the same four-frame `dead_*` mapping, while `hurt_*` remains on the final root-attack body.

The current mini-boss controller also owns a data-profiled point-blank Root Burst. It selects the circular burst before lane attacks when the target is within 34 pixels, snapshots the telegraph, activates a controller-owned hitbox after 0.48 seconds, and emits presentation-only events for ground VFX, layered root audio, and camera response. The player's `EvadeComponent` tracks a 0.85-second reuse cooldown independently from dash recovery so attack cancels remain responsive without allowing continuous invulnerability. Mireling presentation uses one external 16-animation `SpriteFrames` resource: `mireling_walk_sheet_32x32.png` owns compact idle/hop frames and `mireling_action_sheet_48x32.png` owns fixed-scale four-frame slam/collapse sequences. Its leap controller remains authoritative and unchanged.

`EncounterController` owns a stage's data-driven wave lifecycle, bounded reinforcement queue, injects the shared `World/Projectiles` parent into projectile-capable enemies, and creates one `StagePortal` after the final wave. `EncounterWaveDefinition` owns counts, initial cadence, and reinforcement delay; the controller never allows more than its configured four active enemies. Each queued replacement emits `reinforcement_announced`, waits the authored delay, then releases one enemy so burst kills earn a readable reset instead of instantly backfilling the crowd. HUD observes that signal for its warning. `StagePortal` owns player proximity and F-input, emits prompt visibility, and delegates valid destinations to the `SceneTransition` autoload. HUD owns prompt presentation. Stage 1 targets Stage 2, Stage 2 targets Stage 3 after clear, and Stage 3 returns to Sanctuary after its mini-boss.

`Stage2Flow` composes player/HUD binding, an arrival-lore delay, manual `EncounterController.start_encounter()`, Stage 2 clear messaging, and local defeat/restart ownership. `EncounterController` retains encounter authority; `Stage2Flow` never creates enemies, applies damage, or decides wave results.

`EncounterController.gated_wave_numbers` provides an optional reusable inter-wave pause seam after normal recovery. A gated transition emits `inter_wave_gate_requested` and awaits an explicit release without moving spawn authority into presentation. `Stage3Flow` uses Wave II's gate to open a portrait-equipped `DialoguePanel`, then releases it on either completion or skip. The solo Husk and its wave-owned music cannot begin before release. `DialoguePanel` owns pause/resume and accepts an optional presentation-only `Texture2D`; it never changes hostility or gameplay authority.

`AudioDirector` is a narrow autoload that owns Music, SFX, and reserved UI buses plus one music player. The director and music player process while the scene tree is paused so dialogue and menus never interrupt ambience, and assigned OGG music is normalized to loop. A level-local `StageMusic` requests an `AudioStream`; it never owns gameplay timing or combat authority. The Headless display backend assigns streams but intentionally skips native playback because no audio device exists.

`PlayerActionSfx` and `ActorActionSfx` are actor-local `Node2D` observers, so positional sounds follow their owning actor. Player swings/dash and enemy attack cues respond to existing phase/state signals. Accepted hit and player-damage sounds remain in `CombatFeedbackPresenter`, while the Bramble impact scene owns its self-cleaning impact cue. All playback is presentation-only and uses the SFX bus.

`CombatFeedbackPresenter` is a level-local presentation observer configured with the player, World/Effects parent, and player camera. It listens to accepted player melee/ability hits and accepted player damage, then spawns self-cleaning `DamageNumber` and `HitBurst` scenes. Accepted outgoing hits temporarily apply a shader-owned white silhouette and one non-stacking 0.045-second scene-tree pause restored by a process-always timer. It never changes damage, hit detection, knockback acceptance, or actor state; incoming hits and rejected contacts do not request hitstop.

`SummonEffect` is instantiated under `World/Effects` at the selected spawn position. It owns only rune/lightning/spark presentation, cleans itself after 0.8 seconds, and never changes spawn timing, health, collision, or damage. Wave-clear presentation observes controller signals during the 2.25-second inter-wave recovery.

## System Boundaries

### Encounter pacing

`EncounterWaveDefinition` remains the only content authority for stage composition. Its independent `rootling_count` composes the approved third Stage 1 role without controller branching, while `reinforcement_delay` defines readable release spacing after the initial group. The current authored pass extends Stage 1 to six Mireling/Rootling/Thrall waves (30 total enemies) and Stage 2 to seven Grove waves (32 total enemies). `EncounterController` does not gain skill-specific or level-specific branching: it queues immutable wave data, preserves the 2.25-second recovery, and releases one pending enemy per warned delay instead of instantly refilling every vacant slot. Four active enemies remains the explicit performance and readability ceiling pending a separate profile-backed decision.

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
PlayerInputSource or SkillBarSlot click -> Player request_ability -> AbilityComponent
-> damage/shape snapshot -> cast phases -> Player active velocity + MeleeHitbox
-> HurtboxComponent
-> HealthComponent -> optional KnockbackComponent response
-> cooldown signals -> reusable SkillBarSlot bound through the player loadout
```

Presentation observes facing and action-phase signals. Opaw's canonical runtime body lives under `assets/characters/playable/opaw/compact_armless/` as separate direction-row sheets for idle, walk, weaponless attack body, dash, interaction, hurt, and defeat. `tools/process_opaw_compact_armless_assets.gd` removes chroma, expands around ideal generated cells, retains the primary connected actor silhouette plus nearby pieces, rejects neighboring-pose spill, quantizes hard alpha, and normalizes every direction's standing reference to an 18x27 silhouette on the shared 32-pixel foot baseline. Ordinary states use 32x32 cells; extended attack/dash/interaction poses use 48x32, and defeat uses 64x32 so horizontal collapse never forces a smaller body. `PlayerAnimation` keeps the same `<action>_<direction>` API, maps authoritative wind-up/active/recovery directly to attack frames 0/1/2, and never modifies sprite scale. A sibling `PlayerWeaponVisual` renders the `WeaponDefinition.world_texture` under `VisualRoot`, treats its node as the detached equipment pivot, applies definition-owned grip offset/scale/radius data, and consumes the selected sword style for armless-body integer anchors, true mirrored side rotations, extension, trail, and accent through wind-up, active, recovery, ability, and defeat. The active strike's style-driven accent and tapering `SwordSwingTrail` change neither hit timing nor reach. `SwordPivot` remains invisible and orients only the authoritative melee hitbox; body art, visible weapons, effects, audio, HUD icons, or inventory UI must not become damage authority. The complete Wayfarer backup, superseded single Opaw atlas, and former Awakened 24x32/64x48 presentation remain legacy material with no active player reference.

Top-down movement collision is a 6-pixel circular foot footprint centered at `y = -4`. Hurtboxes are separate 24-pixel body capsules centered at `y = -14`. Character shadows are centered at `y = -2`, directly beneath sprite feet. Sword and Thrall attack shapes are centered 18 pixels from their body-centered pivots.

### Abilities and Weapons

Definitions should be custom resources; runtime state should live in nodes or plain runtime objects owned by the actor. Shared resource assets must never accidentally store per-instance cooldown or mutable combat state.

### Enemy AI

Use finite-state or hierarchical state behavior appropriate to complexity. Expensive sensing and path recalculation should be scheduled or staggered rather than executed for every enemy every frame.

The Forsaken Thrall uses scheduled `NavigationAgent2D` target updates and follows the baked arena path. Thralls, Mirelings, Rootlings, and Bramble Spitters compose `EnemySeparationComponent`, an `Area2D` that observes only nearby enemy bodies and blends gentle repulsion into movement steering. Attack states, committed Mireling leaps, Rootling wind-ups/jabs, and committed Spitter shots ignore separation so combat timing remains predictable.

The Bramble Spitter uses canonical 32x32 runtime art under `assets/characters/enemies/bramble_spitter/` and an explicit positioning/wind-up/recovery state machine. It snapshots one player position before presentation displays a world-space red ground marker. `HostileProjectile` owns seed travel and hit delivery through the standard `DamageInfo`/`HurtboxComponent` contract; the sprite and marker remain presentation-only. The configured seed terminates at its committed target position, collides with player hurtboxes and world bodies along the route, and retains a fixed lifetime safety limit.

Spitter firing presentation observes `shot_telegraphed` and `shot_fired`: it owns the three-frame charge sequence, swelling, restrained recoil, red target marker, muzzle flash, and sparks. Movement steering and facing are intentionally separate while kiting so the creature backs away without visually turning from its target. `HostileProjectile` creates a configured presentation-only impact scene when authoritative collision resolves; trails and impact art never determine damage or hit timing.

### Save System

Disk persistence is not implemented. `StoryState` provides a versioned snapshot dictionary for stable story flags, boss victories, discoveries, and narrative key items, but deliberately performs no file I/O. This is the first schema boundary, not a complete profile. A future save service still needs explicit serialization, migration support, failure recovery, and separation of settings, roster/profile progression, story memory, owned inventory, and run/session state. Do not serialize arbitrary scene trees as the save format.

### UI

UI observes model state through signals or presenters and sends player intent through explicit interfaces. Gameplay rules must not be owned by HUD nodes.

The implemented combat HUD displays a compact corner vitality bar, blocked-damage feedback, and the fallen/restart panel. Persistent control/build banners were removed from combat space; future help belongs in a contextual or paused surface. These controls may be reskinned without changing health or arena flow.

Stage presentation is a brief top-edge label. The centered lower screen contains a compact four-slot bar that remains readable without covering the playfield center.

The centered HUD and `CharacterMenu` consume the same player-owned `SkillLoadoutDefinition`. `CombatHUD` creates four reusable `SkillBarSlot` observers; an equipped/ready slot exposes a transparent native click button that emits its slot number, and the HUD requests `Player.request_ability()` without calculating targets, damage, movement, or cooldown. Cooldown disables repeat clicks, while unbound definitions remain visibly sealed. `CharacterMenu` creates four reusable `SkillSlotCard` buttons for read-only information and future setup intent. Ground-target definitions are rejected until a separate targeting authority supplies a confirmed point.

The character surface consumes one immutable `WeaponCatalogDefinition`. Its Gear page composes reusable `EquipmentSlotCard`, `EquipmentItemCard`, and `EquipmentDetailPanel` scenes around Opaw plus only the catalog items currently owned by `WeaponInventory`. `EquipmentDefinition` owns stable item ID, slot, rank, icon, class compatibility, purchase price, lore, and a link to the authoritative `WeaponDefinition`; it never duplicates combat tuning. Clicking a compatible owned card asks `Player` to equip it, then refreshes the slot, portrait weapon, attack label, combat component, and detached world sprite from the same definition. The UI never mutates the ownership dictionaries or calculates damage.

`WeaponInventory` is an autoload with application-session ownership and per-character equipped IDs. It always registers Ashwood as Opaw's default, permits shared storage of weapons for other classes, rejects incompatible equip requests, and exposes one purchase transaction that delegates coin deduction to `PlayerProgressionComponent.spend_coins()`. Ownership/equip state survives scene replacement and defeat reload, resets only when Begin the Awakening starts a new journey, and is not written to disk. `RunSession` remains XP/coin authority; `WeaponInventory` does not grant currency. Orren's `WeaponShopMenu` observes both services, purchases Iron for 18 coins, and never auto-equips it. Eira's future skill authority is separate: skills are level-eligible and freely awakened, never purchased from either service.

Mouse click and directional focus plus `ui_accept` select tabs and cards. Physical Tab is handled by `CharacterMenu._input()` before Godot can consume it as `ui_focus_next`; Escape or the top-right button closes the surface. The HUD's satchel button emits `character_menu_requested`, and each level flow connects that presentation intent to the local `CharacterMenu` without making the HUD own pause, inventory, or equipment state. Neither character page calculates readiness, progression, rewards, unlocks, casts, ownership, or equipment bonuses.

Native Godot `Button` signals remain the common activation path for mouse, keyboard, and controller input. `SceneTransition` owns the only global layer-100 input shield: its transparent overlay uses `MOUSE_FILTER_IGNORE` while idle, switches to `MOUSE_FILTER_STOP` only during an active fade/scene replacement, and restores pointer pass-through after completion or failure. Decorative controls must not intercept pointer events. Gameplay modals keep explicit focus loops and visible pointer-operable controls.

Reusable interaction prompts are contextual: an interactable emits visibility, text, and an optional semantic presentation icon while the HUD presents one prompt above the centered skill bar. The portal configures `icon_interaction_portal`; NPCs use `icon_interaction_talk`. `DialogueNpc` retains the nearby `Player` only while they overlap, requests `begin_interaction(global_position)` before opening dialogue so Opaw faces the speaker, and finishes the interaction when dialogue/prompt ownership returns. Interactables do not duplicate the same instruction in world space, gameplay does not branch on icon filenames, and leaving the area clears both text and icon immediately.

`battle_of_gods_theme.tres` is the shared base for HUDs and menus. It owns common panel, label, button, progress-background, separator, focus, disabled, and tooltip treatment. Individual scenes retain local overrides only for meaningful state such as health fill, cooldown, equipped, or sealed presentation. Named icons are independent textures so presentation can replace one concept without repacking an atlas or modifying gameplay authority.

`TitleScreen` is the project entry scene and owns only menu presentation and navigation intent. It resets `RunSession` for a new journey, delegates scene replacement to `SceneTransition`, and changes audio-bus mute state through the existing AudioDirector-owned bus names. Its settings are session-only. `TitleBackground` is a separate presentation scene with `Base`, `DistantSilhouette`, `Atmosphere`, and `Vignette` layers; its tweens perform restrained visual motion without polling or gameplay authority.

`SanctuaryFlow` composes the safe hub. It binds the existing player HUD, forwards contextual prompt metadata from two reusable `DialogueNpc` instances and `ExpeditionAltar`, and opens `DialoguePanel`, `CharacterMenu`, `WeaponShopMenu`, or `ExpeditionMenu`. Entering the composed Sanctuary records the stable `awakened_in_sanctuary` story memory. Eira's completed dialogue opens the existing skill-information surface; Orren's completed dialogue opens his weapon shop; Escape cancellation restores play without chaining into either menu. Interactables own proximity and emit intent; they do not draw HUD text, mutate progression, calculate prices, or replace scenes. Each modal owns its temporary pause and restores it on close. A future expedition-abandon action belongs in a pause/flow authority with confirmation and explicit run-state policy, not in a stage-local raw scene-change input.

`ExpeditionDefinition` owns immutable route identity, display metadata, optional destination scene, and one `ExpeditionRequirement`. Requirements combine minimum player level with any number of story flags, boss victories, discoveries, and narrative key items. `ExpeditionMenu` creates route buttons from those resources, reads level through `ProgressionDefinition` plus `RunSession`, asks `StoryState` about narrative memory, exposes unmet requirements, and delegates only valid existing destinations to `SceneTransition`. It cannot record victories, grant key items, or open an unbuilt route. Stage 2 records current Forgotten Grove completion/discovery when its authoritative encounter-clear signal fires.

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

Combat-stage terrain uses `TileMapLayer` plus `AuthoredGroundLayout`. Each layout owns exact map size, a compact glyph-to-atlas legend, and explicit rows; `authored_ground.gd` can materialize the layout when a scene is empty, while `tools/bake_authored_ground.gd` saves those cells into the stage scene for direct Godot TileMap editing. Runtime reads the baked cells and performs no random fill or per-frame terrain work. `prototype_ground.gd` and the old 2x2 atlas are legacy prototype material with no active stage references.

Stage I and II share `verdant_forest_ground_tileset.tres`, a 4x4 atlas of grass, path, clearing, and shrine-stone roles. Stage III deliberately owns `rootbound_ground_tileset.tres` because its corrupted palette and arena semantics are region-specific rather than a rearrangement of bright forest tiles. Generated boards and cleaned intermediates remain under `art_source/`; only normalized runtime atlases live under `assets/environment/forest/shared/` or the named region folder. Landmark scenes remain under `environment/props/` so texture replacement cannot silently discard collision or navigation ownership.

Sanctuary owns a separate 64x64 `sanctuary_ground_tileset.tres`; it never reuses the combat-stage grass resource. `SanctuaryGround` fills the 18x12 hub and derives cardinal pavement transitions from an authored route set. Because the even-width map centers its portal and fountain between columns, their north-south avenue deliberately occupies both center columns; service roots are snapped to exact tile-center door approaches, and the cart uses one bounded two-cell bay. The east-west connector remains one row and preserves explicit grass breaks so alignment does not become an oversized paved plaza. `tools/process_sanctuary_direction_board.gd` now reproduces only ground and trees from the preserved direction board; all retired service crop definitions and idle-sheet helpers were removed so it cannot regenerate superseded art. `tools/process_sanctuary_individual_assets.gd` normalizes the portal, fountain, compact Eira/Orren sheets, skillkeeper lodge, armskeeper workshop, and armskeeper cart through deterministic green-key removal, hard alpha, palette reduction, exact-canvas fitting, and four-frame role-accent pulses. `skillkeeper_lodge.tscn`, `armskeeper_workshop.tscn`, and `armskeeper_cart.tscn` retain independent visual glow, editable collision, and preview ownership. Runtime scenes load only normalized assets under `assets/`; replaced scenes, PNGs, sources, and imports live in the Godot-ignored archive.

`ExpeditionAltar` now owns only the portal interaction, glow/runes, open center staircase, guardian footprints, rear backstop, and compact doorway trigger. The portal raster is deterministically split without changing its appearance: `GroundSprite` contains the stairs/threshold at `z_index = -1`, while the arch, guardians, and doorway normally remain at Z 0 and participate in the hub's Y-sort. A separate front-only `FrontDepthArea` begins farther south than the smaller interaction trigger and spans the full west-to-east guardian facade; entering it event-drives the structure to Z -1 before the character's head can be clipped at the doorway or either guardian, while leaving restores Z 0 and ordinary front/behind Y-sorting. The prompt trigger retains its independent close range, and no per-frame depth polling is used. `PortalBackstopCollision` is physics-only: it stops traversal through the monument's rear and never controls visual depth. `DivineFountain` is an independent sibling `StaticBody2D` with an editable basin polygon and presentation-only water/glow motion. Sanctuary deliberately leaves a visible courtyard gap between their baselines; automated radius-six traversal checks validate both walk-around routes and the center staircase. `NpcIdleBreath` is a reusable event-driven `Timer` that applies one-pixel steps to an injected visual node while collision, interaction, shadow, and gameplay authority remain stationary.

`EditorPreviewBackdrop` is reusable authoring-only presentation under `tools/editor/`. It draws a configurable ground checker only when its direct parent is the editor's current isolated scene root. It disables processing, self-removes outside editor hint mode, owns no collision or navigation, and therefore remains absent from composed-level editing, F5/F6, and exported gameplay.

Sanctuary house roots remain `StaticBody2D` physics owners. Their visual ground shadows are `Polygon2D`, while their independently editable blocking footprints are `CollisionPolygon2D`. The collision polygons begin from the previously validated rectangular bounds but may be refined around ground-contact architecture without coupling collision to sprite alpha, roof silhouettes, or shadow geometry.

`ArenaNavigation` builds a `NavigationPolygon` from one traversable arena outline and convex prop footprints. Thralls call `get_next_path_position()` every chase frame as required by `NavigationAgent2D`, use corridor-funnel postprocessing, and limit target reassignment to five times per second. This prevents empty-path deadlocks and extreme edge-centered detours around props.

## Autoload Policy

Autoloads are reserved for truly cross-scene services and must not become general-purpose mutable state. `SceneTransition` pauses gameplay, enables its top-layer fade/loading input shield, changes to validated scene paths, resumes the tree, fades back in, and disables the shield. `AudioDirector` owns audio-bus setup and cross-scene music routing; actor-local presenters own positional combat playback. `RunSession` is a deliberately narrow in-memory bridge containing only XP and coins. `StoryState` is a separate narrow in-memory authority containing only story flags, boss victories, discoveries, and narrative key items. Neither service awards combat rewards, evaluates menu focus, owns scene transitions, or writes disk data.

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

`res://tests/combat_audio_smoke.gd` additionally asserts that Opaw's dash and accepted-damage streams are dedicated assets, remain on the SFX bus, and cannot resolve to the Thrall claw stream.

`res://tests/ability_input_buffer_smoke.gd` verifies that a ready immediate-direction skill waits through a normal attack or active dash, starts only at the safe recovery boundary with its captured facing, and remains committed against dash input.

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

`res://tests/character_animation_smoke.gd` verifies all seven binary-alpha compact armless Opaw sheets, every populated cell, 18x27 directional reference scale, shared foot baseline, attack/dash head padding and facial-detail retention, down/up attack skin-to-tunic axis alignment, intact up-head contour, left/right dash area parity, separate three-frame attack/dash data, attack-phase frame mapping, unchanged node scale, detached integer-pixel anchors, mirrored side rotations, definition-owned grip motion, hurt recovery, four-frame defeat/fade, plus the existing Thrall action-art and foot-plane ownership contracts. `res://tests/opaw_model_backup_smoke.gd` verifies the active compact model and archived Wayfarer model expose matching animation APIs while loading independent textures.

`res://tests/mireling_smoke.gd` verifies spawn state, body-slam damage, and sword damage against the weak Mireling.

`res://tests/mireling_leap_dodge_smoke.gd` verifies leaving the snapshot landing point avoids damage. `res://tests/enemy_obstacle_behavior_smoke.gd` verifies statue line-of-sight blocking, steering-facing agreement, and non-pinning enemy movement collision.

`res://tests/rootling_behavior_smoke.gd` verifies Rootling's own definition, completed warning-to-eruption sequence, immutable post-telegraph pivot, and narrow 40x16 lane. `res://tests/bramble_spitter_smoke.gd` verifies the ranged warning, committed aim direction, dodge behavior, and completed firing state transition.

`res://tests/thrall_statue_endpoint_smoke.gd` reproduces the exact opposite-side statue chase and guards against long stalls or incomplete routing. `res://tests/encounter_wave_structure_smoke.gd` enforces six Stage 1 waves and their data-driven endurance composition; `res://tests/encounter_reinforcement_smoke.gd` clears a complete queued encounter and proves every authored enemy arrives without exceeding the active cap.

`res://tests/enemy_crowd_separation_smoke.gd` starts a tightly clustered mixed group and verifies minimum spacing, lateral spread, and continued pursuit.

`res://tests/summon_effect_smoke.gd` verifies encounter integration, segmented lightning construction, and effect cleanup without residual nodes.

`res://tests/portal_interaction_smoke.gd` verifies prompt enter/exit and explicit interaction. `res://tests/scene_transition_smoke.gd` verifies fade-controlled Stage 2 loading, destination spawn, delayed exit-portal absence, and its configured post-clear return destination. `res://tests/stage_2_encounter_smoke.gd` verifies the Grove's seven-wave role escalation, tile layout, navigation path, Y-sort ownership, and removal of placeholder presentation.

`res://tests/player_progression_smoke.gd` verifies initial state, threshold leveling, cap behavior, coin spending, reward delivery after enemy death, and HUD presentation. `res://tests/run_session_progression_smoke.gd` verifies XP/coin reconstruction across player replacement and explicit run reset. `res://tests/character_menu_smoke.gd` verifies the shared loadout, reusable selectable cards, two-page focus ownership, pause ownership, close control, Opaw's owned armory, and reactive progression labels. `res://tests/equipment_preview_smoke.gd` verifies the Wood/Iron catalog, stable cross-resource IDs, shared Balanced Slash, exact art sizes, class restriction, price, and authoritative weapon tuning. `res://tests/weapon_inventory_shop_smoke.gd` verifies insufficient funds, exact purchase deduction, non-auto-equip ownership, click-to-equip gameplay/presentation synchronization, replacement-player continuity, class rejection, and new-journey reset. `res://tests/sword_attack_style_smoke.gd` verifies all three presentation profiles, shared body animation across weapon-grade/style swaps, definition synchronization, front anchor placement, style-owned extension/trail data, and idle-only swap locking. `res://tests/title_screen_smoke.gd` additionally guards the global transition overlay's idle/during-fade pointer-filter contract. `res://tests/audio_director_smoke.gd` verifies the Music bus and stage-stream routing; it intentionally does not require physical playback in headless mode.

`res://tests/player_control_scheme_smoke.gd` verifies movement-owned cardinal facing and standing retention, left-click without right-click basic attack, the physical F9 binding, authoritative level/coin synchronization, and visible debug confirmation. `res://tests/consecutive_thrust_smoke.gd` verifies F9 loadout replacement, the refreshed clickable second slot, seven ordered directional strike windows, one target contact per window, 225% Ashwood total, final-only knockback, authored stagger metadata, input exclusion, and presentation cleanup. `res://tests/enemy_crowd_control_smoke.gd` verifies Rapid Thrust interrupts a Light enemy's active attack while a Boss control profile rejects both stagger and pushback. `res://tests/dash_attack_smoke.gd` verifies one buffered attack begins only after full dash distance and invulnerability, recovery-only cancellation works both before and after recovery begins, and no duplicate or invulnerable sword attack is emitted.

`res://tests/piercing_rush_smoke.gd` verifies active slot identity, immediate-direction mode, narrow shape, roughly 50-pixel movement with no recovery slide or invulnerability, 135% Ashwood/Iron damage snapshots, one path hit, knockback, generated-atlas presentation, clicked HUD activation, and cooldown lockout. `res://tests/sweeping_cut_smoke.gd` now verifies the unequipped Sweep resource/slot still performs fixed multi-target damage, pushback, phase exclusion, and cooldown through the same component.

`res://tests/combat_feedback_smoke.gd` verifies accepted incoming and outgoing hits create a number plus burst, then clean up without changing combat authority.

`res://tests/combat_audio_smoke.gd` verifies Music/SFX/UI bus creation, assigned player and enemy action streams, state synchronization, accepted-hit cues, and Bramble impact audio without requiring device playback in headless mode.

`res://tests/sanctuary_hub_smoke.gd` verifies the dedicated tileset, aligned central/door/cart pavement cells and protected garden gaps, normalized binary-alpha assets, NPC idle animation, Opaw's speaker-facing interaction pose/restoration, Eira-to-skill-menu handoff, Orren-to-weapon-shop handoff, split portal depth/idle layers, the compact doorway trigger, continuous six-pixel-footprint routes around both fountain sides, prompt ownership, pause restoration, and the Stage 1 destination.

`res://tests/runtime_archive_boundary_smoke.gd` verifies that active Opaw/service resources and the supported Wayfarer rollback remain loadable while retired Awakened, rejected Opaw variants, obsolete service scenes, and retired builders remain absent from Godot runtime folders.

`res://tests/expedition_unlock_smoke.gd` verifies stable route definitions, combined level/story/boss/discovery/key-item evaluation, unavailable unbuilt destinations, new-story reset, versioned snapshot restoration, and rejection of unsupported snapshot versions. `res://tests/sanctuary_hub_smoke.gd` additionally verifies that the menu builds one available route and two requirement-bearing sealed routes with a complete focus loop.

