# Architecture

`GroundPointTargeting` owns only Skill 3 intent/preview. `SovereignPursuitComponent` clamps the requested point, exposes traversal velocity to `Player` movement authority, grants protection only during its active phase, and opens one radial hitbox window at the actual collision-safe landing position. Body, VFX, cursor, and audio observe phase/strike signals and never calculate damage or relocate the actor.

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
- `EvadeComponent`: owns dash/recovery phases, locked direction, speed, invulnerability events, and observable reuse-cooldown state.
- `DashVisual`: observes evade events and creates replaceable placeholder afterimages.
- `AbilityComponent`: owns generic cast phases, snapshotted equipped-weapon damage, definition-owned hitbox selection, timed per-strike hitbox activation, instance-local cooldown state, and definition-opted invulnerability events. `AbilityDefinition` supplies stable identity, activation/presentation modes, flat-plus-weapon scaling, per-strike damage/knockback/stagger data, active movement speed, timings, shape, dash-cancel permission, and read-only UI metadata. `EchoingSeverComponent` is a narrow subclass that inserts a truly inactive delay between two windows while delegating non-Echoing definitions to the generic scheduler for Opaw regression compatibility.
- `PiercingRushVisual`: observes cast phases and draws the white-gold spirit blade, streaks, and sparks without owning movement, contacts, damage, or cooldown. The preserved `SweepingCutVisual` remains available to the unequipped Sweeping Cut content.
- `PlayerProgressionComponent`: owns player-local XP, level, coins, cap evaluation, and progression signals from immutable `ProgressionDefinition` data, synchronizing totals through `RunSession` when they change.
- `PlayerVitalityComponent`: combines immutable Opaw base/per-level vitality with one future flat equipment bonus, then asks `HealthComponent` to change its maximum while preserving missing damage. It never applies damage or owns death.
- `PlayerHealthRegenerationComponent`: observes accepted damage and health changes, then uses one delay timer plus one fixed tick timer to request low-rate healing from `HealthComponent`. It stops at full health/defeat and never owns current health.
- `EquipmentShowcaseDefinition`: player-configured, immutable content used only by the paused character preview. It does not own inventory, equip state, stat modifiers, acquisition, or saving.

Opaw's active `assets/characters/playable/opaw/compact_armless/opaw_compact_armless_sprite_frames.tres` is wired directly into `player.tscn`. It keeps the established action names, direction order, frame counts, 18x27 upright scale, and foot baseline, so the controller/menu API does not change. `tools/apply_opaw_attack_vertical_revision.gd` composes only the corrected down/up rows into the attack source while preserving approved left/right rows; `tools/process_opaw_compact_armless_assets.gd` then converts the seven generated boards into binary-alpha runtime sheets. The complete former active model lives under `variants/wayfarer_original/` with its own independently loadable `SpriteFrames` resource; changing one scene resource path is sufficient for a visual rollback. Rejected `handless`, `armless`, and `armless_small_feet` experiments and the superseded Awakened presentation live only under Godot-ignored `art_source/archive/`; their retired build scripts and tests no longer register with the project.

Ashwood Blade and Iron Sword each use a shared `WeaponDefinition` resource whose stable ID, authoritative damage/knockback/timings, world texture, grip metadata, and melee `Shape2D` are consumed by combat and presentation. Balanced Slash uses the reusable `balanced_sword_cleave.tres` beginner-sword fan: 58 pixels forward and 48 pixels to either side near the visible arc. `MeleeAttackComponent` installs that shape on equip; `PlayerWeaponVisual` reads both forward reach and half-width only to size the white-gold inner trail and translucent white-blue outer cleave band. The front grip joins the hilt to Opaw's left torso edge and rotates the tip outward toward screen-left, away from the head; side grips remain raised close to the body. Their referenced `SwordAttackStyleDefinition` owns only detached orbit, active extension, trail, strike-accent tuning, and a cyclic normal-swing presentation sequence. `PlayerWeaponVisual` advances the sequence on authoritative wind-up events; Balanced Slash currently cycles outward, reverse, and extended-finish variants. Sequence index never enters damage calculation. Balanced Slash is active for both early swords; Swift Slash and Heavy Cleave are inactive reusable profiles. Future short swords, greatswords, axes, scythes, and other families provide their own reviewed shape/style pairs through the same definition instead of branching in `Player`. `Player.set_weapon_definition()` remains the idle-only low-level synchronization seam for `MeleeAttackComponent` and `PlayerWeaponVisual`; `Player.equip_owned_weapon()` validates catalog identity, ownership, and class compatibility, commits the equipped ID through `WeaponInventory`, and either uses the seam immediately or retains one pending definition until the next safe idle frame. This prevents a paused menu opened during a committed action from silently rejecting equip. `MeleeHitbox` deduplicates contacts per swing, `HurtboxComponent` forwards explicit `DamageInfo`, and `HealthComponent` owns healing, damage, and death state.

The player dash uses shared `EvadeDefinition` data. `Player` remains movement authority and chooses dash velocity while `EvadeComponent` is in `DASHING`. `HealthComponent` receives invulnerability state from evade signals. Starting a dash remains mutually exclusive with an active attack and with abilities that do not opt into dash cancellation. Consecutive Thrust is the first explicit exception: `Player.request_evade()` cancels that component before starting the ordinary dash, so the ability and dash invulnerability sources never overlap.

`PlayerInputSource` exposes movement, right-stick aim, and discrete action intent. Ordinary combat still never derives facing from passive pointer motion: `Player` resolves movement to one retained cardinal facing. `DirectionalWedgeTargeting` becomes active only for a compatible requested skill, owns exact 360-degree preview direction/geometry but no cost or damage, and gives right-stick input priority over the pointer. Movement preserves that state; dash cancels it before starting. Left-click/right-trigger confirms instead of leaking into basic attack, repeating the skill input is consumed without commitment, and right-click/Esc cancels. Only the emitted exact confirmed direction reaches `AbilityComponent.request_cast()`, where cooldown and damage authority begin together; the body independently resolves that direction to its nearest available cardinal animation.

Echoing Sever's immutable resource owns the 130-pixel/100-degree wedge, 110% + 75% strike multipliers, 0.30-second echo delay, phase timings, and cooldown. `EchoingSeverComponent` reactivates one `MeleeHitbox` exactly twice, clearing its per-window target set only at each authored contact. `EchoingSeverVisual` observes phase/strike signals and selects `wind_up`, `primary`, `rift_hold`, or `echo` from a separate exact-grid `SpriteFrames`; neither it nor `DirectionalWedgeTargeting._draw()` can deal damage. The target node stays at zero rotation while the ability pivot freezes the exact confirmed direction for both contacts and rotates the VFX with it. `CursorService` owns the hardware cursor vocabulary. `tools/process_echoing_sever_vfx.py` deterministically converts the approved 3x2 chroma-clean boards into binary-alpha 160x160 runtime cells.

Echoing Sever presentation also observes `strike_started`: `PlayerActionSfx` routes strike zero to the ordinary sword cut and strike one to the original generated fracture WAV, while `PlayerAnimation` applies one two-pixel nearest-cardinal recoil/settle only on strike zero. Both are presentation-only and cancel/reset with the normal action lifecycle. `PlayerWeaponVisual` suppresses its detached Opaw trail for this integrated-sword ability so only one slash owner is visible.

`RiftbreakComponent` is the first `SELF_AREA` King ability. `Player` dispatches that activation family through the same buffered immediate-cast path without opening a targeting adapter. The component installs the definition-owned circle at King's ground/foot position and asks `MeleeHitbox.activate_radial()` for one contact window. `MeleeHitbox` retains per-target deduplication but derives each accepted `DamageInfo.direction` from the circle center to that target, producing true outward control without moving damage authority into presentation. `PlayerAnimation` observes Ability 2 and selects the dedicated six-frame `riftbreak_<direction>` family; its phase map uses frames 0-2 for anticipation, frame 3 for exact damage contact, and frames 4-5 for recovery. `RiftbreakVisual` observes those same signals and drives a separate generated effect-only `AnimatedSprite2D`: two wind-up frames, three impact/decay frames, then one residual fissure frame. `PlayerActionSfx` observes the strike event for its original ground-slam cue. The former procedural drawing, line-target adapter, dynamic line/endpoint shapes, and `request_cast_at()` seam were removed rather than left as unused Skill 2 code. The Ability 2 node remains compatible with explicit Opaw regression reconfiguration because the King subclass falls back to base behavior for non-Riftbreak definitions.

`Player` owns one non-stacking basic-attack buffer during `EvadeComponent.DASHING` and snapshots the movement-owned facing used when the attack was requested. When the evade announces `RECOVERY`, the player asks `EvadeComponent.cancel_recovery()` to end only that vulnerable phase, then requests the ordinary `MeleeAttackComponent` attack. A basic attack requested after recovery begins follows the same recovery-only cancel immediately. The active dash cannot be canceled, so full distance and invulnerability finish before the normal weapon wind-up, hitbox, damage, and presentation begin. No second dash-attack damage authority exists.

Piercing Rush uses the shared `AbilityDefinition` plus `AbilityComponent`. On accepted cast, the component snapshots `flat_damage + equipped_weapon.damage * weapon_damage_multiplier`, assigns the definition-owned hitbox shape, and owns phase/cooldown time. During `ACTIVE`, `Player` consumes the component's directional velocity and remains the only body/collision authority; movement-enabled abilities return zero velocity during wind-up/recovery so rush momentum cannot leak into a slide. `PiercingRushVisual` observes those phases and advances an effect-only six-frame atlas generated independently from Opaw and every sword. `tools/process_piercing_rush_vfx.gd` captures the intentionally irregular source zones, downsamples them with nearest-neighbor filtering, hardens alpha, and packs six 192x192 cells; `AbilityPivot` rotates the same right-facing frames for all four directions. The definition-owned 128x40 tapered lance matches the widened bright central visual spear; its roughly 160-pixel outer plume remains cosmetic. `AbilityDefinition` exposes the forward tip and widest half-width of a thrust shape so the core guide reads this immutable runtime data instead of duplicated presentation numbers. `PlayerActionSfx` observes the same definition/phase boundary and selects dedicated Piercing charge/thrust streams, while `CombatFeedbackPresenter` plays a dedicated impact stream only from accepted ability contacts. The active slot definition points to Piercing Rush, while the old Sweeping Cut definition and slot remain valid unequipped content. Weapon and ability hitboxes send normal `DamageInfo` with optional pushback strength. Enemy-local `KnockbackComponent` observes accepted damage and exposes a brief decaying velocity contribution; each enemy remains movement authority and decides when that contribution may affect motion. Committed Mireling leaps ignore pushback motion so their marked landing remains predictable.

Consecutive Thrust reuses that component with seven definition-owned strike multipliers. Its definition opts into full-cast invulnerability and dash cancellation; the component emits invulnerability changes on normal completion or cancellation, while `HealthComponent` remains the only damage gate. Each timed strike reactivates the same shape, deliberately resetting its one-target-per-window contact set, and emits `strike_started` for presentation only. `ConsecutiveThrustBodyVisual` hides the normal locomotion body only while it advances an eight-beat sheet deterministically built from approved Opaw frames; `ConsecutiveThrustVisual` rotates an independent 6x2 effect-only atlas through `AbilityPivot`, reads the same shape bounds for its longer pale-blue guide, and never owns contact; `PlayerWeaponVisual` alternates shallow sword poses; and `PlayerActionSfx` plays three spaced steel-thrust beats before a final sword thrust. Its 128x44 tapered lane uses immutable definition data. Visual shallow-angle offsets never change the snapshotted cast direction or contact lane. Small flurry contacts create a number/flash only on alternating hits; only the finishing strike requests heavy feedback and its contact-only blade sound. The 18/19/20/21/22/25/100% damage sequence, zero non-final knockback, 150 final knockback, 0.21 repeated stagger, and 0.42 final stagger remain in `consecutive_thrust.tres`.

`DamageInfo` carries optional knockback and stagger values alongside damage/source/direction. `KnockbackComponent` and `StaggerComponent` observe accepted health damage and scale control through `EnemyDefinition.CrowdControlTier`: Light is full strength, Elite is 35% movement knockback and 45% stagger duration, and Boss is fully control-immune. Enemy controllers configure their components from their own definition, own the `STAGGER` state, deactivate their hitbox on entry, and resume their ordinary state loop only after the observer says stagger expired. The components never choose enemy movement, attack timing, or visuals.

The Forsaken Thrall uses shared `EnemyDefinition` data, canonical runtime art under `assets/characters/enemies/forsaken_thrall/`, and an explicit state machine. Chase facing follows navigation steering rather than direct target bearing, attacks require unobstructed world line-of-sight, and enemy movement bodies collide with world but not the player. Hitboxes and hurtboxes retain combat authority, preventing attack-lock pinning.

`CombatHUD` binds to the player's `HealthComponent` and observes health/damage-blocked signals. `PlayerLevelUpVisual` alone observes `leveled_up` for a small world-space glow, a rising `LEVEL N` label above Opaw, and the deterministic UI-bus chime. It never mutates progression/health, pauses play, or creates a center-screen HUD panel. `Player` owns the defeated state and cancels its active combat components. `ArenaFlow` observes `Player.defeated`, reveals the restart presentation through the HUD, and owns scene reload. The HUD never applies damage or reloads gameplay itself.

`EnemyHealthBar` is a reusable world-space presentation component used by Thralls, Mirelings, Rootlings, Bramble Spitters, and Rootbound Husk. Mireling runtime art is canonicalized under `assets/characters/enemies/mireling/`; no superseded Mireling body remains in runtime or source archives. The health bar observes `HealthComponent.health_changed` and `died`, updates only on signals, and uses a one-shot timer to hide after 2.2 seconds. It never owns, calculates, or mutates health. Boss scenes may author a larger parent offset around the same component; Husk moves it above its antlers without changing health authority.

`EnemyRewardComponent` observes its own actor's `HealthComponent.died` event and grants the injected player XP/coins from its `EnemyDefinition`. Enemy definitions own only reward values; the recipient owns mutable totals. `RunSession` retains XP, coins, and current player health across scene replacement; each new `PlayerProgressionComponent` reconstructs its level from the cumulative `0/150/400/750/1200/1750/2400/3150/4000/4950` thresholds. `PlayerVitalityComponent` then resolves `140 + 12 * (level - 1) + equipment bonus`, reaching 248 at Level 10; `HealthComponent.set_maximum_health()` preserves missing damage when that maximum changes. `Player` restores the run's current-health snapshot after child vitality setup and synchronizes every later health change. `PlayerHealthRegenerationComponent` waits five damage-free seconds and requests 1 HP/s through `HealthComponent.heal()`. New journey and defeat restart clear the snapshot through `RunSession.reset_run()`. Armor may eventually supply flat vitality/regeneration bonuses, while lifesteal, critical stats, potions, and mana remain separate future authorities. `CombatHUD` and `CharacterMenu` observe health/progression/vitality signals and never calculate thresholds, maximum health, healing, or rewards.

In debug builds only, `Player` handles the F9 `debug_max_progression` action, first suppresses autosave, asks `PlayerProgressionComponent` to apply the authored level-cap XP plus 999 coins, grants all current compatible `WeaponCatalogDefinition` entries to `WeaponInventory`, asks `MaterialInventory` to fill only absent catalog IDs with deterministic sample quantities, then switches from the normal immutable loadout to `opaw_debug_test_loadout.tres`. That test resource exposes only fully authored slots 1-2; HUD and character-menu observers rebuild from normal signals. Each inventory remains its own mutation authority. Release builds reject the preset, and it never writes disk state, marks Eira/Orren progression as complete, or claims that sample materials were earned.

`Rootling` is an independent `CharacterBody2D` controller rather than a Thrall variation. It uses the shared health, reward, navigation, separation, knockback, stagger, and hitbox contracts, but owns the unique `CHASE -> WIND_UP -> ACTIVE -> RECOVERY` sequence. Entering `WIND_UP` snapshots its direction, rotates the 40x16 `AttackPivot` lane once, and emits a crack telegraph. Neither later target motion nor its own knockback changes that pivot; `ACTIVE` emits the VFX/sound and activates the same locked lane. `RootlingVisual` owns the four-direction 32x32 walk/reaction atlases and the separate 48x48 root-jab VFX atlas. `tools/process_rootling_atlas.py` converts only approved chroma-cleaned source boards into those compact runtime atlases.

`RootboundHusk` is a separate Boss-tier `CharacterBody2D` mini-boss controller. It directly preloads its attack-profile script so editor parsing does not depend on newly refreshed global-class metadata. The profile owns spear, fan, point-blank burst, and below-half-health timing values; `EnemyDefinition` owns health, damage, range, movement, and rewards. The controller snapshots directions, rotates authoritative 112x20 lane hitboxes before wind-up, stages the fan's center and side windows, and activates a separate circular burst hitbox when the target crowds its body. `RootboundHuskVisual` observes controller signals through one `AnimatedSprite2D` body and ground-layer root VFX; named animations never activate damage. `tools/assemble_rootbound_husk_redesign.gd` and `tools/process_rootbound_husk_assets.gd` keep fixed direction-row scale, a stable foot baseline, complete up-facing crowns, exact mirrored side walks, and non-shrinking `72x64` walk plus `96x64` root-command sheets. `tools/build_rootbound_husk_sprite_frames.gd` creates exactly 28 body animations, including approved `hurt_*` and four-frame `dead_*`, plus the separate six-stage `128x64` ground-root VFX animations. Root-command presentation uses only `root_attack_wind_up_*`, `root_attack_active_*`, and `root_attack_recovery_*`; every cast-named asset, stale import, and retired Husk body archive was permanently deleted.

`RootboundHuskActionSfx` observes telegraph and eruption signals separately. Telegraphs play the deterministic woody tension/creak cue; attack starts layer a distinct snapping-root eruption with a pitched-down earth body. `tools/build_rootbound_husk_root_spear_sfx.py` reproduces both runtime WAVs. Audio never decides attack timing or contacts.

The authored death sequence now keeps its four manually reviewed directional reaction frames. `RootboundHuskVisual` fits their playback to the controller's 0.6-second death window before the actor frees itself; the asset builder reproduces the same four-frame `dead_*` mapping, while `hurt_*` remains on the final root-attack body.

The current mini-boss controller also owns a data-profiled point-blank Root Burst. It selects the circular burst before lane attacks when the target is within 34 pixels, snapshots the telegraph, activates a controller-owned hitbox after 0.48 seconds, and emits presentation-only events for ground VFX, layered root audio, and camera response. The player's `EvadeComponent` tracks a 0.85-second reuse cooldown independently from dash recovery so attack cancels remain responsive without allowing continuous invulnerability. Mireling presentation uses one external 16-animation `SpriteFrames` resource: `mireling_walk_sheet_32x32.png` owns compact idle/hop frames and `mireling_action_sheet_48x32.png` owns fixed-scale four-frame slam/collapse sequences. Its leap controller remains authoritative and unchanged.

`EncounterController` owns a stage's data-driven wave lifecycle, bounded reinforcement queue, injects the shared `World/Projectiles` parent into projectile-capable enemies, and creates one `StagePortal` after the final wave. `EncounterWaveDefinition` owns counts, initial cadence, and reinforcement delay; the controller never allows more than its configured four active enemies. Each queued replacement emits `reinforcement_announced`, waits the authored delay, then releases one enemy so burst kills earn a readable reset instead of instantly backfilling the crowd. HUD observes that signal for its warning. `StagePortal` owns player proximity and F-input, emits prompt visibility, and delegates valid destinations to the `SceneTransition` autoload. HUD owns prompt presentation. Stage 1 targets Stage 2, Stage 2 targets Stage 3 after clear, and Stage 3 returns to Sanctuary after its mini-boss.

`Stage2Flow` composes player/HUD binding, an arrival-lore delay, manual `EncounterController.start_encounter()`, Stage 2 clear messaging, and local defeat/restart ownership. `EncounterController` retains encounter authority; `Stage2Flow` never creates enemies, applies damage, or decides wave results.

`EncounterController.gated_wave_numbers` provides an optional reusable inter-wave pause seam after normal recovery. A gated transition emits `inter_wave_gate_requested` and awaits an explicit release without moving spawn authority into presentation. `Stage3Flow` uses Wave II's gate to open a portrait-equipped `DialoguePanel`, then releases it on either completion or skip. The solo Husk and its wave-owned music cannot begin before release. `DialoguePanel` owns pause/resume and accepts an optional presentation-only `Texture2D`; it never changes hostility or gameplay authority.

`AudioDirector` is a narrow autoload that owns Music, SFX, and reserved UI buses plus one music player. The director and music player process while the scene tree is paused so dialogue and menus never interrupt ambience, and assigned OGG music is normalized to loop. A level-local `StageMusic` requests an `AudioStream`; it never owns gameplay timing or combat authority. The Headless display backend assigns streams but intentionally skips native playback because no audio device exists.

`PlayerActionSfx` and `ActorActionSfx` are actor-local `Node2D` observers, so positional sounds follow their owning actor. Player swings/dash and enemy attack cues respond to existing phase/state signals. Accepted hit and player-damage sounds remain in `CombatFeedbackPresenter`, while the Bramble impact scene owns its self-cleaning impact cue. All playback is presentation-only and uses the SFX bus.

`CombatFeedbackPresenter` is a level-local presentation observer configured with the player, World/Effects parent, and player camera. It listens to accepted player melee/ability hits and accepted player damage, then spawns self-cleaning `DamageNumber` and `HitBurst` scenes. Every target retains its own number, burst, and temporary shader-owned white silhouette. A normal swing coalesces camera, impact audio, and one non-stacking 0.025-second scene-tree pause across all contacts; heavy Consecutive Thrust finish contact uses 0.04 seconds. A process-always timer restores play. It never changes damage, hit detection, knockback acceptance, or actor state; incoming hits and rejected contacts do not request hitstop.

`SummonEffect` is instantiated under `World/Effects` at the selected spawn position. It owns only rune/lightning/spark presentation, cleans itself after 0.8 seconds, and never changes spawn timing, health, collision, or damage. Wave-clear presentation observes controller signals during the 2.25-second inter-wave recovery.

## System Boundaries

### Encounter pacing

`EncounterWaveDefinition` remains the only content authority for stage composition. Its independent `rootling_count` composes the approved third Stage 1 role without controller branching, while `reinforcement_delay` defines readable release spacing after the initial group. The current authored pass extends Stage 1 to six Mireling/Rootling/Thrall waves (30 total enemies) and Stage 2 to seven Grove waves (32 total enemies). `EncounterController` does not gain skill-specific or level-specific branching: it queues immutable wave data, preserves the 2.25-second recovery, and releases one pending enemy per warned delay instead of instantly refilling every vacant slot. Four active enemies remains the explicit performance and readability ceiling pending a separate profile-backed decision.

### Actors

Player, enemies, and bosses coordinate reusable components. They should not duplicate health, damage, hit detection, or status-effect rules.

Decisions 071-072 add a planned character layer without replacing `Player` as the technical actor or retiring Opaw. Immutable `PlayableCharacterDefinition` data should identify the character, vitality/progression, presentation scene or `SpriteFrames`, signature combat style, basic attack chain, skill loadout, ultimate, compatible essence families, and fallback essence. A future roster authority owns selected/unlocked character IDs and per-character snapshots; shared resources never store runtime level, health, cooldown, or equipment state. Opaw is the first implemented character definition target and King is the first additive target.

Character scenes may compose shared movement, evade, health, damage, input, ability, and interaction components, but body/hand anchors, signature weapon presentation, combo animation mapping, and cinematic presentation belong to the character. Do not rename generic systems to King or fork the whole `Player` controller for each roster member.

King's active proof reuses the generic `Player` scene authority while changing its presentation/loadout seams. `tools/process_king_simple_locomotion.py` discovers the locomotion board plus three six-pose direction strips, retains locomotion's 28-pixel/y=30 contract, applies an 88% attack calibration because attack islands include the extended sword, anchors attack frames from warm boot pixels rather than low blade pixels, derives left by exact right mirroring, preserves strict left-to-right chronology, and emits exact `48x32` locomotion plus `64x32` six-column basic-slash atlases into one named `SpriteFrames` resource. `PlayerAnimation` maps King's two frames per wind-up/active/recovery phase through a presentation-only midpoint-rounded Tween while three-frame characters retain one pose per phase; the body node stays on its idle pivot throughout the attack. The real player and isolated cycling preview each own exactly one body `AnimatedSprite2D`. `PlayerWeaponVisual.show_weapon_sprite = false` hides only the detached equipment sprite for King's integrated sword; the observer may still present trails while `MeleeAttackComponent` retains contact/damage authority. `king_starting_loadout.tres` supplies four complete but unequipped presentation slots, so input rejects unimplemented skills. Opaw-specific tests explicitly inject his frames/loadout where needed. This is a reversible default-scene proof, not roster state or per-character persistence.

### Combat

Combat should model attack intent/data separately from visual effects. Hitboxes produce explicit hit information; hurtboxes validate and forward it to a damage receiver. Damage authority belongs to gameplay logic, not animation callbacks alone.

Implemented sword flow:

```text
PlayerInputSource -> Player -> MeleeAttackComponent
-> wind-up -> active MeleeHitbox -> HurtboxComponent
-> HealthComponent -> health/damage/death signals
```

`MeleeAttackComponent` captures one cardinal direction when an attack is accepted. `SwordPivot` must lock to that direction until `attack_finished`; live movement-facing changes may be cached for the following locomotion frame but cannot rotate an active or recovering hit shape. Body, weapon, trail, damage, and pushback must observe the same snapshot.

Implemented ability flow:

```text
PlayerInputSource or SkillBarSlot click -> Player request_ability -> AbilityComponent
-> damage/shape snapshot -> cast phases -> Player active velocity + MeleeHitbox
-> HurtboxComponent
-> HealthComponent -> optional KnockbackComponent response
-> cooldown signals -> reusable SkillBarSlot bound through the player loadout
```

Presentation observes facing and action-phase signals. Opaw's canonical runtime body lives under `assets/characters/playable/opaw/compact_armless/` as separate direction-row sheets for idle, walk, weaponless attack body, dash, interaction, hurt, and defeat. `tools/process_opaw_compact_armless_assets.gd` removes chroma, expands around ideal generated cells, retains the primary connected actor silhouette plus nearby pieces, rejects neighboring-pose spill, quantizes hard alpha, and normalizes every direction's standing reference to an 18x27 silhouette on the shared 32-pixel foot baseline. Ordinary states use 32x32 cells; extended attack/dash/interaction poses use 48x32, and defeat uses 64x32 so horizontal collapse never forces a smaller body. `PlayerAnimation` keeps the same `<action>_<direction>` API, maps authoritative wind-up/active/recovery directly to attack frames 0/1/2, and never modifies sprite scale. A sibling `PlayerWeaponVisual` renders the `WeaponDefinition.world_texture` under `VisualRoot`, treats its node as the detached equipment pivot, applies definition-owned grip offset/scale/radius data, and consumes the selected sword style for armless-body integer anchors, true mirrored side rotations, extension, trail, and accent through wind-up, active, recovery, ability, and defeat. The active strike's style-driven accent and tapering `SwordSwingTrail` change neither hit timing nor reach. `SwordPivot` remains invisible and orients only the authoritative melee hitbox; body art, visible weapons, effects, audio, HUD icons, or inventory UI must not become damage authority. The complete Wayfarer backup, superseded single Opaw atlas, and former Awakened 24x32/64x48 presentation remain legacy material with no active player reference.

Top-down actors use circular underfoot movement footprints centered near `y = -4`, but player and enemy authority are separate. Opaw remains a 6-pixel footprint. Enemy `EnemyDefinition` resources own `movement_footprint_radius` and `crowd_separation_radius`; `EnemyFootprintSystem` duplicates the instance movement shape, synchronizes `NavigationAgent2D.radius`, and configures optional `EnemySeparationComponent` detection. Current enemy bands are 6-pixel Rootling/Mireling, 7-pixel Thrall/Spitter, and 16-pixel Husk. Hurtboxes remain separate damageable-body shapes, while ability and weapon contact shapes stay independently authored. Character shadows are centered at `y = -2`, directly beneath sprite feet.

### Abilities and Weapons

Definitions should be custom resources; runtime state should live in nodes or plain runtime objects owned by the actor. Shared resource assets must never accidentally store per-instance cooldown or mutable combat state.

The destination equipment model supports character-owned visible combat plus stat-bearing essences/relics. A future equipment definition must distinguish its stable item identity, slot, grade, compatible character/combat families, stat modifiers, optional authored trait, icon, and crafting data from world-weapon presentation. Equipping a Weapon Essence must not swap King's integrated signature sword unless King's presentation contract explicitly supports that variant. Opaw's current `WeaponDefinition`, `WeaponCatalogDefinition`, `WeaponInventory`, and Ashwood/Iron ownership remain supported compatibility content rather than conversion targets.

A planned `BasicAttackChainDefinition` owns ordered step resources with wind-up/active/recovery, buffer/reset windows, damage multipliers, knockback/stagger, movement rules, contact shapes, and animation names. King's chain additionally owns pre-attack/charge threshold, maximum hold, charged-release step, and tap-chain policy. `PlayerInputSource` reports attack press/release intent and duration without selecting combo outcomes. The runtime component advances the authoritative chain; `AnimatedSprite2D`, weapon/body presenters, audio, trails, camera, and hit feedback only observe the accepted step and phase. Opaw may keep his current simple `MeleeAttackComponent` path until a deliberate migration provides value.

Cinematic ultimates should compose an authoritative ability component with a character-scoped presentation director. `AnimationPlayer`, CanvasLayer overlays, camera events, shaders, audio, and effect atlases may produce screen cracks, black-frame cuts, letterboxing, or reality distortion, but the director must release every overlay/camera lock on finish, cancellation, defeat, scene transition, and teardown. It never calculates contact or damage.

### Enemy AI

Use finite-state or hierarchical state behavior appropriate to complexity. Expensive sensing and path recalculation should be scheduled or staggered rather than executed for every enemy every frame.

The Forsaken Thrall uses scheduled `NavigationAgent2D` target updates and follows the baked arena path. Thralls, Mirelings, Rootlings, and Bramble Spitters compose `EnemySeparationComponent`, an `Area2D` that observes only nearby enemy bodies and blends gentle repulsion into movement steering. Its data-owned detection radius is configured with the same footprint pass but remains distinct from physical collision. Attack states, committed Mireling leaps, Rootling wind-ups/jabs, and committed Spitter shots ignore separation so combat timing remains predictable. Rootbound Husk retains its 16-pixel movement/navigation radius without ordinary crowd separation.

The Bramble Spitter uses canonical 32x32 runtime art under `assets/characters/enemies/bramble_spitter/` and an explicit positioning/wind-up/recovery state machine. It snapshots one player position before presentation displays a world-space red ground marker. `HostileProjectile` owns seed travel and hit delivery through the standard `DamageInfo`/`HurtboxComponent` contract; the sprite and marker remain presentation-only. The configured seed terminates at its committed target position, collides with player hurtboxes and world bodies along the route, and retains a fixed lifetime safety limit.

Spitter firing presentation observes `shot_telegraphed` and `shot_fired`: it owns the three-frame charge sequence, swelling, restrained recoil, red target marker, muzzle flash, and sparks. Movement steering and facing are intentionally separate while kiting so the creature backs away without visually turning from its target. `HostileProjectile` creates a configured presentation-only impact scene when authoritative collision resolves; trails and impact art never determine damage or hit timing.

### Save System

`SaveService` owns one versioned disk-profile boundary. It composes version-1 snapshots from `RunSession`, `StoryState`, `WeaponInventory`, `MaterialInventory`, `RecipeDiscovery`, and `LootState`, validates every nested version before mutation, restores those authorities only after complete validation, and records Sanctuary as the current safe scene. Material inventory, recipe discovery, and stage claims/bad-luck counters occupy their reserved `extensions` sections; regional progress remains reserved. Each authority owns its explicit versioned snapshot/restore contract and none performs file I/O. Earlier version-1 profiles with empty material/recipe/stage-claim extension dictionaries remain valid and reconstruct clean default state.

The additive King/roster work requires a later profile version or a validated extension contract. The intended ownership is shared story/boss/discovery/key-item/material/recipe/stage-claim/coin/character-unlock state plus per-character XP, level, current health, awakenings, mastery, and equipped item IDs. Version-1 Opaw keys and weapon IDs retain their meaning. The new schema reconstructs an Opaw character record from them and adds King separately; it must never require erasing a valid Opaw journey.

The primary JSON file is `user://battle_of_gods_profile.json`. Each save is serialized to `.tmp`, read back through the full schema validator, and only then committed. A valid former primary rotates to `.bak`; if the primary is absent or corrupt, Continue restores the backup and repairs the primary without rotating corruption over the valid recovery file. Version 1 has no earlier disk format; every future `PROFILE_VERSION` increase requires an explicit migration before release.

Sanctuary entry, Sanctuary weapon purchase/equip, Sanctuary skill awakening, and post-record stage clear are the only current autosave milestones. All checkpoints resume in Sanctuary. Ordinary damage/healing, enemy rewards, active waves, attacks, timers, and scene trees are never serialized. Returning to Sanctuary therefore commits current run attrition/progression, while quitting during a stage returns to the previous safe checkpoint. F9 marks the active debug session non-persistable before it grants test equipment/routes; loading a real profile or beginning a new journey clears that guard. `TitleScreen` enables Continue only for a validated primary or backup, focuses it when available, and requires confirmation before New Journey deletes the old profile. Headless tests suppress production-path writes unless they install an isolated debug `user://` path. Settings remain separate.

### Loot and Crafting Foundation

The approved Forest loot/crafting architecture is specified in `docs/design/forest-loot-crafting-and-regional-material-plan.md`. Segment 2 implements immutable `MaterialDefinition`, exact `MaterialStackDefinition`, `MaterialDropEntryDefinition`, `DropProfileDefinition`, `LootTableDefinition`, and deterministic `RecipeDefinition` resources. Global validated material and recipe catalogs reject malformed definitions and duplicate stable IDs. Current material content lives under `data/items/materials/forest/`; enemy profiles and stage tables live under `data/loot/forest/`; starter recipe blueprints live under `data/crafting/recipes/forest/`.

Segment 3 adds two narrow global authorities. `LootService` owns random resolution of immutable enemy/stage tables, grants validated quantities only through `MaterialInventory`, requests recipe/story grants through their owning authorities, and emits presentation-only reward signals. `LootState` owns persisted first-clear claim IDs and bad-luck miss counters. `MaterialInventory` still owns quantities and now exposes validated atomic batch additions; `RecipeDiscovery` still owns known recipe IDs separately from narrative flags. No enemy, pickup, chest, HUD, or encounter controller edits saved dictionaries or writes the profile.

Each current enemy scene configures its existing `EnemyRewardComponent` with one `DropProfileDefinition`. On authoritative death, that component requests a resolved result from `LootService` and instantiates one `MaterialPickup` per combined stack under the stage's Y-sorted actor owner. Ordinary common and secondary entries are percentage rolls with profile-owned persisted protection keys; boss entries remain explicit guarantees. The component injects the authoritative player recipient into each already-resolved pickup. A pickup owns only its hop, hover, brief readability delay, magnetic movement, contact fallback, icon, and fade presentation; reaching the player asks `LootService` to grant the stack. `_physics_process()` runs only during the short homing phase, while idle hover uses a tween. Physics monitoring changes from an overlap callback are deferred. The HUD observes `material_granted` for a compact toast and never calculates a drop.

`EncounterController.completion_reward_mode` owns the final-wave branch. `DIRECT_PORTAL` commits the active expedition through `LootService`, creates the ordinary portal, and then emits `stage_cleared`; Stages I-II use this mode and configure no chest/table resources. `STAGE_CHEST` creates one configured `StageRewardChest` under the same Y-sorted `Actors` owner as the player and props; Stage III uses this mode with its Rootbound Reliquary table/tier. The chest owns a small solid ground footprint, a larger interaction area, and a presentation-only reusable rune/spark reveal. It submits its `LootTableDefinition` to `LootService` only after explicit `F` interaction, changes to tier-specific open art on success, releases its footprint, and reports the claim to the controller. Tier selection owns art, prompt copy, footprint size, and accent only—it never changes reward resolution. The controller then creates the portal and emits `stage_cleared`, preserving story-record and autosave order. First-clear versus replay selection comes solely from the table's stable claim ID in `LootState`; the chest cannot duplicate a one-time reward by reopening or reloading.

`LootService.begin_expedition()` snapshots material quantities, recipe discoveries, first-clear claims, and bad-luck counters at stage entry. Direct ordinary-stage completion or milestone-chest success commits that baseline before `stage_cleared`. Defeat restart, pause-menu Return to Sanctuary, and defensive Sanctuary entry restore it first, so uncommitted combat drops never leak through an abandoned expedition or get written by the next safe checkpoint. XP, coins, and current HP retain their existing run semantics. Segment 5 must add `CraftingService` and actual output/equipment integration before any recipe definition is described as craftable. Its output contract is now blocked on the essence/relic migration: Stage V core relics, Stage VIII standard accessories, and Stage X signature/relic-tier crafting; no later-stage seal authority is implemented yet.

The implemented Sanctuary Rootweaver service is a presentation boundary separate from Armskeeper Orren. `DialogueNpc` emits optional portrait metadata with speaker/lines; `SanctuaryFlow` composes Nema's completed dialogue into `RootforgeMenu`. That paused menu reads `RecipeCatalogDefinition`, `MaterialInventory`, and `RecipeDiscovery`, builds filterable recipe and ingredient presentation, and keeps its primary action disabled. It contains no recipe balance, remove/grant/discover call, output fabrication, or save request. Nema's `RootweaverWorkIdle` uses a timer and animation callbacks for her stationary work loop and strike cue; it never polls or moves interaction/collision authority. Planned permanent crafting seals and repeatable boss catalysts remain separate stable-ID concepts: seals unlock a category once and are never consumed, while catalysts are inventory materials consumed by recipes. Stage V is the core-gear seal milestone, Stage VIII is the standard-accessory seal milestone after Stages VI-VII component preparation, and Stage X is the relic/signature seal milestone. None of those later-stage records is implemented yet.

Runtime material art belongs under `assets/items/materials/common/` and `assets/items/materials/<region>/`; reusable source templates belong under `art_source/generated/items/materials/templates/`. The ten current Forest definitions each reference a distinct flattened 24x24 runtime texture derived from the preserved generated source/review board. Template reuse is an art-production optimization only. Runtime recoloring, filename parsing, and label-driven gameplay logic are prohibited.

### UI

UI observes model state through signals or presenters and sends player intent through explicit interfaces. Gameplay rules must not be owned by HUD nodes.

The implemented combat HUD displays a larger high-contrast corner vitality bar, blocked-damage feedback, and the fallen/restart panel. Persistent control/build banners were removed from combat space; future help belongs in a contextual or paused surface. These controls may be reskinned without changing health or arena flow.

Stage presentation is a brief top-edge label. The centered lower screen contains one themed action tray with a fixed `52x48` dash control, a 20-pixel effective semantic gap, and four fixed `52x48` skill controls.

The lower HUD and `CharacterMenu` consume the same player-owned `SkillLoadoutDefinition`. `CombatHUD` creates four icon-first `SkillBarSlot` observers plus one `DashBarSlot`; each native click button forwards intent to `Player`, while ability/evade components own readiness and emit cooldown state. Fixed-size controls show only icon, key, short state, and cooldown bar so localized names cannot alter layout. Cooldown disables repeat clicks, while unbound definitions remain visibly sealed. The top-right `MENU [ESC]` button locates the current scene's registered `PauseMenu`; it does not own pause state. `CharacterMenu` creates four fixed `128x68` `SkillSlotCard` title/status buttons and places the full selected description in one detail strip, preventing repeated copy from expanding the modal. Ground-target definitions are rejected until a separate targeting authority supplies a confirmed point.

The character surface consumes immutable weapon and material catalogs while observing their separate mutable authorities. Its `CHARACTER & BAG` page composes seven reusable `EquipmentSlotCard` positions around Opaw's canonical live sprite/weapon pose, a 12-by-2 grid of compact `InventorySlotButton` scenes, and one `EquipmentDetailPanel` that switches between equipment actions and read-only material details. The menu owns a separate left-shifted preview grip so the blade stays outside Opaw's face without changing gameplay weapon anchors. Only owned catalog weapons and nonzero `MaterialInventory` stacks populate selectable cells; placeholders remain disabled. Equipment occupies the displayed 24-slot bag capacity, while materials are explicitly capacity-free even when the All filter shows them in the same grid. Consumable and key filters are forward-compatible empty states, not fabricated inventories. Clicking a cell only selects details; the explicit Equip button asks `Player` to validate and equip it. The UI never mutates ownership dictionaries, rolls drops, crafts output, writes profiles, or calculates damage.

`WeaponInventory` is an autoload with profile-backed ownership and per-character equipped IDs. It always registers Ashwood as Opaw's default, permits shared storage of weapons for other classes, rejects incompatible equip requests, and exposes one purchase transaction that delegates coin deduction to `PlayerProgressionComponent.spend_coins()`. Ownership/equip state survives scene replacement, safe-point Continue, and defeat reload, and resets only when confirmed New Journey starts. `RunSession` remains XP/coin/current-health authority; `WeaponInventory` does not grant currency or vitality. Orren's `WeaponShopMenu` purchases Iron for 90 coins without auto-equipping, then changes the same action to explicit Equip when the selected weapon is owned.

Mouse click and directional focus plus `ui_accept` select tabs and cards. Physical Tab is handled by `CharacterMenu._input()` before Godot can consume it as `ui_focus_next`; Escape or the top-right button closes the surface. The HUD's satchel button emits `character_menu_requested`, and each level flow connects that presentation intent to the local `CharacterMenu` without making the HUD own pause, inventory, or equipment state. Neither character page calculates readiness, progression, rewards, unlocks, casts, ownership, or equipment bonuses.

Native Godot `Button` signals remain the common activation path for mouse, keyboard, and controller input. `SceneTransition` owns the only global layer-100 input shield: its transparent overlay uses `MOUSE_FILTER_IGNORE` while idle, switches to `MOUSE_FILTER_STOP` only during an active fade/scene replacement, and restores pointer pass-through after completion or failure. Decorative controls must not intercept pointer events. Gameplay modals keep explicit focus loops and visible pointer-operable controls.

Reusable interaction prompts are contextual: an interactable emits visibility, text, and an optional semantic presentation icon while the HUD presents one prompt above the centered skill bar. The portal configures `icon_interaction_portal`; NPCs use `icon_interaction_talk`. `DialogueNpc` retains the nearby `Player` only while they overlap, requests `begin_interaction(global_position)` before opening dialogue so Opaw faces the speaker, and finishes the interaction when dialogue/prompt ownership returns. Interactables do not duplicate the same instruction in world space, gameplay does not branch on icon filenames, and leaving the area clears both text and icon immediately.

`battle_of_gods_theme.tres` is the shared base for HUDs and menus. It owns common panel, label, button, progress-background, separator, focus, disabled, and tooltip treatment. Individual scenes retain local overrides only for meaningful state such as health fill, cooldown, equipped, or sealed presentation. Named icons are independent textures so presentation can replace one concept without repacking an atlas or modifying gameplay authority.

`TitleScreen` is the project entry scene and owns only menu presentation and navigation intent. It resets `RunSession` for a new journey, delegates scene replacement to `SceneTransition`, and changes audio-bus mute state through the existing AudioDirector-owned bus names. Its settings are session-only. `TitleBackground` is a separate presentation scene with `Base`, `DistantSilhouette`, `Atmosphere`, and `Vignette` layers; its tweens perform restrained visual motion without polling or gameplay authority.

`SanctuaryFlow` composes the safe hub. It binds the existing player HUD, forwards contextual prompt and optional portrait metadata from three reusable `DialogueNpc` instances plus `ExpeditionAltar`, and opens `DialoguePanel`, `CharacterMenu`, `WeaponShopMenu`, `RootforgeMenu`, or `ExpeditionMenu`. Entering Sanctuary records `awakened_in_sanctuary`. Eira's completed dialogue opens `CharacterMenu.open_skillkeeper_menu()`; at Level 3 the selected second slot exposes `AWAKEN SKILL • FREE`, and `Player.awaken_skill_2()` records `opaw_consecutive_thrust_awakened` in `StoryState` before switching to the authored two-skill loadout. New Player instances restore that loadout from the flag. Orren's completed dialogue opens his weapon shop; Nema's completed portrait dialogue opens the read-only Rootforge preview. Escape cancellation restores play without chaining into a service menu. Each modal owns its temporary pause and restores it on close.

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

Stage I and II share `verdant_forest_ground_tileset.tres`, a 4x4 atlas of grass, path, clearing, and shrine-stone roles. Stage III deliberately owns `rootbound_ground_tileset.tres` because its corrupted palette and arena semantics are region-specific, but that TileSet also registers the shared forest atlas as source 1 so a single baked layer can describe progressive decay. `AuthoredGroundLayout.tile_legend` accepts legacy `Vector2i` atlas coordinates for source 0 or `Vector3i(x, y, source_id)` for mixed-source cells. Generated boards and cleaned intermediates remain under `art_source/`; only normalized runtime atlases live under `assets/environment/forest/shared/` or the named region folder. Landmark scenes remain under `environment/props/` so texture replacement cannot silently discard collision or navigation ownership.

Sanctuary owns a separate 64x64 `sanctuary_ground_tileset.tres`; it never reuses the combat-stage grass resource. `SanctuaryGround` fills the 18x12 hub and derives cardinal pavement transitions from an authored route set. Because the even-width map centers its portal and fountain between columns, their north-south avenue deliberately occupies both center columns; service roots are snapped to exact tile-center door approaches, and the cart uses one bounded two-cell bay. The east-west connector remains one row and preserves explicit grass breaks so alignment does not become an oversized paved plaza. `tools/process_sanctuary_direction_board.gd` now reproduces only ground and trees from the preserved direction board; all retired service crop definitions and idle-sheet helpers were removed so it cannot regenerate superseded art. `tools/process_sanctuary_individual_assets.gd` normalizes the portal, fountain, compact Eira/Orren sheets, skillkeeper lodge, armskeeper workshop, and armskeeper cart through deterministic green-key removal, hard alpha, palette reduction, exact-canvas fitting, and four-frame role-accent pulses. `skillkeeper_lodge.tscn`, `armskeeper_workshop.tscn`, and `armskeeper_cart.tscn` retain independent visual glow, editable collision, and preview ownership. Runtime scenes load only normalized assets under `assets/`; replaced scenes, PNGs, sources, and imports live in the Godot-ignored archive.

`ExpeditionAltar` now owns only the portal interaction, glow/runes, open center staircase, guardian footprints, rear backstop, and compact doorway trigger. The portal raster is deterministically split without changing its appearance: `GroundSprite` contains the stairs/threshold at `z_index = -1`, while the arch, guardians, and doorway normally remain at Z 0 and participate in the hub's Y-sort. A separate front-only `FrontDepthArea` begins farther south than the smaller interaction trigger and spans the full west-to-east guardian facade; entering it event-drives the structure to Z -1 before the character's head can be clipped at the doorway or either guardian, while leaving restores Z 0 and ordinary front/behind Y-sorting. The prompt trigger retains its independent close range, and no per-frame depth polling is used. `PortalBackstopCollision` is physics-only: it stops traversal through the monument's rear and never controls visual depth. `DivineFountain` is an independent sibling `StaticBody2D` with an editable basin polygon and presentation-only water/glow motion. Sanctuary deliberately leaves a visible courtyard gap between their baselines; automated radius-six traversal checks validate both walk-around routes and the center staircase. `NpcIdleBreath` is a reusable event-driven `Timer` that applies one-pixel steps to an injected visual node while collision, interaction, shadow, and gameplay authority remain stationary.

`EditorPreviewBackdrop` is reusable authoring-only presentation under `tools/editor/`. It draws a configurable ground checker only when its direct parent is the editor's current isolated scene root. It disables processing, self-removes outside editor hint mode, owns no collision or navigation, and therefore remains absent from composed-level editing, F5/F6, and exported gameplay.

Sanctuary house roots remain `StaticBody2D` physics owners. Their visual ground shadows are `Polygon2D`, while their independently editable blocking footprints are `CollisionPolygon2D`. The collision polygons begin from the previously validated rectangular bounds but may be refined around ground-contact architecture without coupling collision to sprite alpha, roof silhouettes, or shadow geometry.

`ArenaNavigation` builds a `NavigationPolygon` from one traversable arena outline and convex prop footprints with an exported bake radius. Ordinary arenas retain the six-pixel baseline; Stage III uses 20 pixels so the 16-pixel-radius Rootbound Husk cannot receive a path that wedges it against the central seal. Thralls and Husk call `get_next_path_position()` every chase frame as required by `NavigationAgent2D` and limit target reassignment. Focused coverage samples the complete north/south seal route against the boss-expanded collision footprint instead of relying only on endpoint existence.

## Autoload Policy

Autoloads are reserved for truly cross-scene services and must not become general-purpose mutable state. `SceneTransition` pauses gameplay, enables its top-layer fade/loading input shield, changes to validated scene paths, resumes the tree, fades back in, and disables the shield. `AudioDirector` owns audio-bus setup and cross-scene music routing; actor-local presenters own positional combat playback. `RunSession` is a deliberately narrow in-memory bridge containing XP, coins, and current player health; it does not calculate maximum vitality, regeneration, damage, or death. `StoryState` is a separate narrow in-memory authority containing only story flags, boss victories, discoveries, and narrative key items. Neither service awards combat rewards, evaluates menu focus, owns scene transitions, or writes disk data.

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

`res://tests/portal_interaction_smoke.gd` verifies prompt enter/exit and explicit interaction. `res://tests/scene_transition_smoke.gd` verifies fade-controlled Stage 2 and Stage 3 loading, destination spawn, exact current-health continuity, delayed exit-portal absence, and configured post-clear destinations. `res://tests/stage_2_encounter_smoke.gd` verifies the Grove's seven-wave role escalation, tile layout, navigation path, Y-sort ownership, and removal of placeholder presentation. `res://tests/stage_3_encounter_smoke.gd` additionally samples a cross-arena route and verifies the Husk's full 16-pixel footprint clears the central seal under the Stage III 20-pixel navigation bake.

`res://tests/player_progression_smoke.gd` verifies initial state, the increasing cumulative threshold curve, cap behavior, the 140-to-248 level-scaled vitality curve, coin spending, reward delivery after enemy death, and compact overhead level-up presentation. `res://tests/run_session_progression_smoke.gd` verifies XP/coin/current-health reconstruction across player replacement, delayed timer-owned regeneration, health-snapshot synchronization, and explicit run reset. `res://tests/save_profile_snapshot_smoke.gd` verifies the composed profile version, extension seams, reconstruction of run/story/weapon/loot state, nested-version rejection, and no partial mutation on invalid input. `res://tests/material_crafting_data_smoke.gd` verifies current material/drop/loot/recipe definitions, IDs, 24x24 icons, quantities, references, boss guarantees, and duplicate rejection; `res://tests/material_inventory_snapshot_smoke.gd` verifies material/recipe mutations, snapshot reconstruction, legacy-empty compatibility, invalid-extension rejection, and no partial profile mutation. `res://tests/loot_resolution_smoke.gd` verifies enemy profile wiring, guaranteed and protected drops, boss core delivery, pickup/chest resources, expedition rollback, Stage I-II direct wiring, Stage III first-clear/replay material distinction with no blueprint unlock, open-chest presentation, and `LootState` reconstruction. `res://tests/save_disk_persistence_smoke.gd` verifies validated temporary commits, backup rotation, corrupt-primary recovery/repair, material/recipe/claim-state reconstruction, and exact cleanup; `res://tests/safe_milestone_autosave_smoke.gd` verifies stage-clear reward state saves into a Sanctuary checkpoint; `res://tests/title_continue_smoke.gd` verifies Continue focus/restore/transition plus guarded New Journey replacement. `res://tests/character_menu_smoke.gd` verifies the shared loadout, compact reusable selectable cards, two-page focus ownership, pause ownership, close control, Opaw's owned armory, and reactive progression/vitality labels. `res://tests/equipment_preview_smoke.gd` verifies the Wood/Iron catalog, stable cross-resource IDs, shared Balanced Slash, exact art sizes, class restriction, price, and authoritative weapon tuning. `res://tests/weapon_inventory_shop_smoke.gd` verifies insufficient funds, exact purchase deduction, non-auto-equip ownership, explicit Equip-button gameplay/presentation synchronization, deferred live swapping after committed actions, replacement-player continuity, class rejection, and new-journey reset. `res://tests/sword_attack_style_smoke.gd` verifies all three presentation profiles, shared body animation across weapon-grade/style swaps, definition synchronization, body-connected outward-rising front placement, the definition-owned 58-pixel-reach/48-pixel-half-width fan, family-specific shape/style swapping, and idle-only swap locking. `res://tests/title_screen_smoke.gd` additionally guards the global transition overlay's idle/during-fade pointer-filter contract and initial Sanctuary autosave. `res://tests/audio_director_smoke.gd` verifies the Music bus and stage-stream routing; it intentionally does not require physical playback in headless mode.

`res://tests/player_control_scheme_smoke.gd` verifies movement-owned cardinal facing and standing retention, left-click without right-click basic attack, the physical F9 binding, authoritative level/coin synchronization, and visible debug confirmation. `res://tests/skill_awakening_smoke.gd` verifies Level-3 eligibility, Eira's explicit free-awakening action, session story memory, and loadout restoration on a replacement player. `res://tests/consecutive_thrust_smoke.gd` verifies F9 loadout replacement, the refreshed clickable second slot, seven ordered directional strike windows across the widened 128x44 lane, one target contact per window, 225% Ashwood total, final-only knockback, authored stagger metadata, full-cast invulnerability, dash cancellation, cleanup, and ordinary input exclusion. `res://tests/hud_action_controls_smoke.gd` verifies the top-right Menu action, one compact non-overlapping tray, the visible dash-to-Skill-1 gap, clickable dash cooldown feedback, and that a clicked skill cannot leak into a basic attack. `res://tests/enemy_crowd_control_smoke.gd` verifies Rapid Thrust interrupts a Light enemy's active attack while a Boss control profile rejects both stagger and pushback. `res://tests/dash_attack_smoke.gd` verifies one buffered attack begins only after full dash distance and invulnerability, recovery-only cancellation works both before and after recovery begins, and no duplicate or invulnerable sword attack is emitted.

`res://tests/piercing_rush_smoke.gd` verifies active slot identity, immediate-direction mode, the widened 128x40 lane, roughly 50-pixel movement with no recovery slide or invulnerability, weapon-scaled damage snapshots, one path hit, knockback, generated-atlas presentation, clicked HUD activation, and cooldown lockout. `res://tests/sweeping_cut_smoke.gd` now verifies the unequipped Sweep resource/slot still performs fixed multi-target damage, pushback, phase exclusion, and cooldown through the same component.

`res://tests/combat_feedback_smoke.gd` verifies accepted incoming and outgoing hits create a number plus burst, then clean up without changing combat authority.

`res://tests/combat_audio_smoke.gd` verifies Music/SFX/UI bus creation, assigned player and enemy action streams, state synchronization, accepted-hit cues, and Bramble impact audio without requiring device playback in headless mode.

`res://tests/sanctuary_hub_smoke.gd` verifies the dedicated tileset, aligned central/door/cart pavement cells and protected garden gaps, normalized binary-alpha assets, NPC idle animation, Opaw's speaker-facing interaction pose/restoration, Eira-to-skill-menu handoff, Orren-to-weapon-shop handoff, split portal depth/idle layers, the compact doorway trigger, continuous six-pixel-footprint routes around both fountain sides, prompt ownership, pause restoration, and the Stage 1 destination.

`res://tests/runtime_archive_boundary_smoke.gd` verifies that active Opaw/service resources and the supported Wayfarer rollback remain loadable while retired Awakened, rejected Opaw variants, obsolete service scenes, and retired builders remain absent from Godot runtime folders.

`res://tests/expedition_unlock_smoke.gd` verifies stable route definitions, combined level/story/boss/discovery/key-item evaluation, unavailable unbuilt destinations, new-story reset, versioned snapshot restoration, and rejection of unsupported snapshot versions. `res://tests/sanctuary_hub_smoke.gd` additionally verifies that the menu builds the current four-route catalog with correct available/sealed states and a complete focus loop.

