# Architecture

This document records current production ownership. Detailed historical migrations live in `docs/decisions/` and `CHANGELOG.md`.

## Runtime Composition

- `Player` is the sole authority for King movement, facing, attack requests, dash, constraints, and skill dispatch.
- Components own isolated state machines: melee, evade, abilities, health, progression, equipment aggregation, interaction, assisted targeting, and optional auto combat.
- Immutable `.tres` definitions own balance/content data. Runtime state belongs to nodes or profile-backed autoloads, never shared resources.
- Presentation nodes observe accepted events. Animation, VFX, audio, HUD, cursor, target markers, and hitstop never decide damage, movement, cooldown, rewards, or persistence.

## Economy and material memory

- `MaterialDefinition` owns immutable exchange metadata: source enemy, sale/meld values, reconstruction costs and memory thresholds, catalyst overrides, and protection flags. `material_catalog.tres` is the only list Umi reads.
- `EnemyDefinition.enemy_id` supplies the stable defeat key. `EnemyRewardComponent` records ordinary defeats; the Stage V claim flow records Varkuun after the milestone is actually secured.
- `EnemyMemory` owns defeat counts and spent ten-victory boss-memory charges. `SaveService` persists it as a backward-compatible extension and New Journey resets it.
- `MaterialExchangeService` is the sole sell/reconstruct transaction coordinator. It validates catalog identity, inventory, memory, catalysts, points, and gold; snapshots material/coin/memory state; mutates once; saves once; and restores every snapshot on failure.
- `CraftingService` similarly includes `RecipeDefinition.gold_cost` in its existing material/output/save transaction. `RunSession` is the durable coin authority and live `PlayerProgressionComponent` mirrors its progression signal.
- `UmiExchangeMenu` and `RootforgeMenu` display authority results but do not calculate or mutate inventory ownership directly.

## Input and Assisted Combat

- `PlayerInputSource` converts keyboard, mouse, and controller events into intent.
- `PlayerCombatTargetingComponent` owns an optional living target, selection query, target signals, pursuit intent, and size-aware approach distance. It does not move or attack.
- Right click always starts navigation movement and clears target, pursuit, optional automation, and repeated-click state. WASD clears the same combat intent.
- A world left click first cancels navigation movement and optional automation. One enemy click selects only; a repeated same-actor click inside the bounded time/position window engages; empty ground requests a directional air swing.
- Selection queries enemy hurtboxes first, then the physical enemy `CharacterBody2D` footprint with an eight-pixel `CircleShape2D` assist.
- Assisted approach stops at `player footprint + EnemyDefinition.movement_footprint_radius + padding`; the real `MeleeHitbox` remains the only normal-attack contact authority.
- Held WASD cancels pursuit and selection. Dash, restraints, targeted previews, and active/recovery commitments retain priority.
- `AutoCombatComponent` cycles living enemies and requests ordinary attacks/skills through the same Player APIs and cooldown rules. Manual world left-click or right-click ground disables it.

## Combat

- `MeleeAttackComponent` owns wind-up, active, recovery, attack buffering boundary, and hitbox activation.
- `AbilityComponent` and narrow King-specific subclasses own cast phases, target snapshots, movement requests, strike windows, invulnerability requests, and cooldowns.
- `HealthComponent` accepts `DamageInfo`, resolves armor/control profile, and emits accepted results. Long-lived projectiles validate their stored source before constructing damage so an already-freed shooter becomes `null` rather than an invalid typed Object.
- `KnockbackComponent` and enemy controllers cooperate so each enemy remains its own movement authority. Light enemies flinch; abilities may stagger/stun; Elite/Boss resistance is data-owned.
- `CombatFeedbackPresenter` observes accepted hits for flash, numbers, sparks, camera response, sound, and presentation-only hitstop.
- King loads `data/weapons/king_signature_sword.tres` and `data/skills/king_starting_loadout.tres`: Echoing Sever, Riftbreak, Sovereign Pursuit, and Worldsplitter.
- `WeaponDefinition` owns bounded critical chance/damage data. `MeleeHitbox` rolls once when a basic swing or skill strike activates and carries the shared result in every `DamageInfo` emitted by that activation; multi-target cleaves therefore cannot roll independently per victim. `AbilityComponent` receives the equipped weapon profile before cast, while feedback only observes `DamageInfo.is_critical`.
- `MeleeAttackComponent` and `PlayerMovementComponent` clamp aggregated equipment bonuses at 50% attack speed and 35% movement speed. Weapon definitions clamp critical chance at 50%; no UI or save data may bypass those runtime caps.

## Enemy Footprints and Navigation

- `EnemyDefinition.movement_footprint_radius` owns physical underfoot size; `crowd_separation_radius` independently owns spacing.
- `EnemyFootprintSystem` synchronizes movement collision, `NavigationAgent2D.radius`, and optional separation detection.
- Hurtboxes and attack shapes remain separately authored; visible foot auras observe tier/radius and do not replace collision.
- Stage flows own spawn caps and reinforcement timing. Stages I-III preserve four live enemies, Stage IV permits eight, and Stage III keeps Rootbound Husk solo.

## UI and Presentation

- `CombatHUD` binds to player health/progression/actions and observes the current target. It owns no gameplay mutation beyond forwarding explicit button requests.
- The enemy roster forwards target/auto requests and displays health/tier information only after visible actors enter discovery range. `MarqueeLabel` clips/pads every name and animates only real overflow; a roster signature prevents quarter-second row reconstruction from restarting that presentation.
- `CombatTargetMarker` uses the small selected chevron; `CombatFootAura` communicates footprint/tier.
- `CursorService` owns normal, interactive, attack-target, and skill-confirm cursor presentation.
- The six `AtlasTexture` action icons share `assets/ui/icons/combat/combat_action_atlas_bc_6x1_24.png` in fixed Skills 1-4, Basic Attack, Dodge/Dash order.
- `CharacterMenu` observes King equipment/material/skill state. Its compact slot detail compares a selected item with the currently equipped definition. `RootforgeMenu` places a small output icon at the right of every formula row, including a locked-box icon for sealed previews; these icons and comparison labels are presentation only. Ultimate and Reality Breaking are disabled previews with no input, ability, cooldown, unlock, or save authority.

## Sanctuary and Stages

- `SanctuaryFlow` composes dialogue, expedition selection, Character & Bag, Eira's skill information, Orren dialogue, and Nema's Living Rootforge. `RootforgeMenu` observes readiness and delegates mutation to `CraftingService`; that service validates the canonical recipe/category/seal/cost/unique-output contract, coordinates `MaterialInventory` with `WeaponInventory` or `GearInventory`, and requests `SaveService` only after successful in-memory mutation. Any failed step restores pre-transaction snapshots. Sanctuary entry separately restores King to current maximum health before its ordinary safe-point write.
- The retired weapon shop and skill-awakening transaction are not runtime dependencies.
- Stage flows own dialogue gates, wave completion, reward/chest milestones, and transitions. They delegate reward calculation to loot services and persistence to save authorities.
- Authored `TileMapLayer` data and environment scenes own collision/navigation/occlusion; runtime-random terrain generation is not production authority.

## Persistence

- `RunSession`, `StoryState`, `WeaponInventory`, `GearInventory`, `MaterialInventory`, `RecipeDiscovery`, and `LootState` own mutable session/profile domains.
- `SaveService` validates and atomically writes the versioned profile with backup recovery.
- Safe milestones are Sanctuary entry, equipment changes, and completed stage banking/chest claims. Active combat/waves are never serialized.
- Legacy version-1 weapon state migrates to King's default signature sword; archived player/shop content is not reconstructed.
- Debug F9 marks the session non-persistable before granting test progression, gear, materials, and cooldown relief.

## Asset Lifecycle

- `assets/` contains imported runtime files. `art_source/` contains generated/cleaned/review provenance.
- `art_source/archive/` is ignored by Godot and may contain recoverable retired material, but runtime code/resources must never reference it.
- Cleanup requires reference-graph proof before an asset moves, followed by active-image reachability, editor import, and full smoke verification.

## Verification

- Active `tests/*_smoke.gd` scripts are the executable structural contract.
- `assisted_combat_targeting_smoke.gd` covers movement cancellation, single selection, repeated-click engagement, footprint picking, size-aware approach, a landed melee hit, and manual override.
- `ExpeditionDefeatReturn` owns production defeat exit: abort uncommitted loot, preserve `RunSession`, and request Sanctuary through `SceneTransition`; `expedition_defeat_return_smoke.gd` verifies the real transition and progression boundary.
- `StagePortal` owns proximity, a generated 16-frame full-surface vortex/deforming-rim layer, and an independent 16-frame lightning/particle layer. Its immutable tier table separately owns base/FX color, scale, speed, opacity, and FX reach: Normal disables lightning while higher threats progressively expand it. The selected presentation travels with the scene-change request so `SceneTransition` can mirror the tier in its blocking loading veil without gaining portal, encounter, or scene-choice authority.
- `auto_combat_smoke.gd` covers target cycling and real skill/cooldown use.
- `runtime_archive_boundary_smoke.gd` guards the archive/runtime boundary.
- Run all active smoke scripts after cross-system cleanup; do not retain documentation references to tests moved into an archive.
