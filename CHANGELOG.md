# Changelog

## 2026-07-19 - Crowd-Control Tiers and Rapid Thrust Audio Revision

- Added reusable Light/Elite/Boss crowd-control data: Light enemies accept full knockback/stagger, Elites receive 35% knockback and 45% stagger, and Bosses reject both without per-skill conditionals.
- Added `DamageInfo`/ability stagger metadata plus observing `StaggerComponent`s. Thrall, Mireling, and Bramble Spitter now cancel their current attack while staggered; Rapid Consecutive Thrust refreshes the interruption across its flurry and extends it on the final lance.
- Replaced the noisy rapid swishes with three spaced steel-thrust beats, a strong final sword thrust, and a separate blade-contact impact only after the final hit lands. Archived the replaced V3 swish clips outside runtime imports.
- Added focused coverage for Light attack interruption, Boss resistance, authored stagger values, and final-contact audio configuration.

## 2026-07-19 - Rapid Consecutive Thrust Feel Pass

- Rebuilt F9 Skill 2 from three separated stabs into a 1.34-second seven-lance rapid flurry with 225% total weapon scaling, final-only 150 knockback, and an unchanged forward-only 76-pixel contact lane.
- Kept the approved compact-armless Opaw model intact: an eight-beat runtime body sheet is deterministically built from its existing frames, while a new twelve-cell effect-only VFX atlas supplies the extra visual motion and shallow alternating thrust angles.
- Replaced the restarted stab clip with three alternating short CC0 swishes plus a distinct final whoosh. Small flurry contacts skip expensive burst/camera/hitstop presentation, retaining the strong final impact and smoother clustered-enemy performance.
- Replaced obsolete Skill 2 runtime sheets, builders, and audio with archived copies outside Godot imports; expanded focused multi-hit and audio smoke coverage to the seven-window contract.

## 2026-07-18 - Consecutive Thrust Test Skill and Full F9 Loadout

- Extended reusable ability data/component authority with timed per-strike damage and knockback values, then authored Opaw's debug-test Skill 2 as a three-hit weapon-scaled Consecutive Thrust: 42%, 48%, and 115% damage with heavy final-only pushback.
- Reworked F9 from a progression-only shortcut into a debug-only test loadout: it still gives level 10/999 coins, grants every authored Warrior-compatible weapon, equips every completed Warrior skill, and rebuilds the HUD/character menu without claiming Eira or Orren progression is complete in normal play.
- Added a four-pose action-owned Opaw body sheet made from the approved model, an independent 4x2 white/gold/blue spirit-lance atlas, sword extension, final-hit feedback, a unique icon, and distinct CC0 charge/repeated-stab/final-stab cues. The mismatched generated character board remains archived and unused.
- Added focused test coverage for F9 slot refresh, three ordered hit windows, damage, knockback, input exclusion, VFX cleanup, and the dedicated sound assignments.

## 2026-07-18 - Opaw Runtime Asset Cleanup

- Removed unused duplicate root-level Opaw sheets from the runtime asset folder and preserved them intact under `art_source/archive/characters/playable/opaw/legacy_runtime_root/`.
- Archived the unfinished, unreferenced Consecutive Thrust body/VFX board after review confirmed that it does not meet the approved compact-armless Opaw design. No scene, skill, or animation used that board.
- Added a local Opaw runtime README that identifies the active compact-armless model and the supported Wayfarer rollback at a glance.

## 2026-07-18 - In-Stage Pause and Sanctuary Return

- Added a reusable pause menu to both expeditions. Escape/Start opens Resume, Music/Combat Sound/Menu Sound controls, Return to Sanctuary, and Quit to Desktop with mouse, keyboard, and controller-compatible native buttons.
- Returning home now deliberately preserves the current session's XP, coins, and equipped weapon while abandoning only the active encounter; audio routing remains on the shared buses.
- Added headless coverage for modal pause/resume ownership, shared SFX toggle behavior, and the valid Sanctuary destination.

## 2026-07-18 - Piercing Rush Direction Lock and Clustered-Impact Smoothing

- Fixed Piercing Rush rotating its visible lance and collision shape after movement-facing input changed during an active cast. The ability pivot now locks to the cast direction from wind-up through recovery, then refreshes to the player's latest idle facing.
- Added regression coverage that casts upward while forcing left/down/right facing changes and verifies only the upward enemy takes its 45 damage.
- Kept target-local numbers, bursts, and white flashes for clustered hits while sharing one camera nudge, hitstop request, impact cue, and reusable flash material per physics frame to reduce small multi-target presentation spikes.

## 2026-07-18 - Piercing Rush Reach, Damage, and Dedicated Audio

- Expanded Piercing Rush's authoritative tapered contact lane from 44x12 to 98x22 and raised the first Warrior technique to 180% equipped-weapon damage: 45 with Ashwood and 57.6 with Iron.
- Raised Piercing Rush pushback from 78 to 112 while retaining its roughly 50-pixel cast movement, cooldown, no-invulnerability rule, and one-hit-per-target authority.
- Replaced the reused normal/sweep sound with three positional CC0 audio layers: a quiet wind-up, a loud active thrust, and a separate accepted-hit impact in both expeditions.
- Preserved source-pack provenance, CC0 licensing, and the selected runtime-only clips; added focused hit-range/scaling and dedicated-audio regression assertions.

## 2026-07-18 - Exaggerated Piercing Rush Animation

- Replaced the provisional code-drawn thrust beam with a dedicated generated six-frame pixel-art sequence covering compressed charge, ignition, lance extension, an oversized roughly 160-pixel peak plume, shock-ring impact, and fading ribbons.
- Kept the effect independent from Opaw's armless body and every sword texture so Ashwood, Iron, and future Warrior-compatible swords can reuse one presentation without duplicated character animation.
- Added a deterministic processor that preserves the irregular peak source crop, downsamples with nearest-neighbor filtering, hardens alpha, and packs six 192x192 runtime cells; the generated chroma source and cleaned intermediate remain preserved under `art_source`.
- Retained the narrow definition-owned contact shape, roughly 50-pixel movement, damage, pushback, cooldown, and phase timing. The larger white/blue/gold outer wings are cosmetic exaggeration around a tight readable core.
- Verified Godot import and the focused Piercing Rush movement/scaling/click/hit smoke test after integration.

## 2026-07-18 - Weapon-Scaled Piercing Rush Vertical Slice

- Replaced equipped Skill 1 with Piercing Rush while preserving Sweeping Cut's data, old slot, arc visual, fixed damage/pushback, and regression coverage as unequipped reusable content.
- Extended immutable ability data with activation/presentation modes, authoritative hitbox shapes, flat-plus-weapon damage scaling, and active movement speed; cast acceptance snapshots resolved damage while Player remains movement/collision authority.
- Added collision-limited roughly 50-pixel thrust movement, 135% equipped-weapon damage (33.75 Ashwood / 43.2 Iron), 78 pushback, 0.14/0.18/0.24 cast phases, a 3-second cooldown, and no invulnerability.
- Added a forward detached-sword pose plus a code-native white-gold spirit blade, blue/gold streaks, sparks, binary-alpha Piercing Rush icon, and a temporarily reused sharper-pitched weapon-technique cue.
- Made equipped ready HUD skills clickable through a native overlay button that requests the actor command and disables during cooldown; sealed slots remain inert and ground targeting remains unimplemented.
- Added focused coverage for movement/collision authority boundaries, scaling, hit deduplication, visual activation, click routing, cooldown, icon integrity, and preserved Sweeping Cut reuse.

## 2026-07-18 - Movement-Facing Controls, Dash Attack Chain, and Debug Test Preset

- Replaced passive pointer/right-stick combat facing with movement-owned four-way facing that preserves Opaw's last direction while standing.
- Retained left mouse/right trigger for the basic sword chain, kept right mouse unassigned for a future reviewed action, and kept passive pointer movement from changing combat facing.
- Added a one-input dash-to-attack chain: an attack during active dash movement waits for full distance and invulnerability to end, then cancels only the vulnerable recovery into the ordinary equipped-weapon attack; an attack during recovery cancels it immediately.
- Added a debug-build-only F9 preset that authoritatively synchronizes level-cap XP and 999 coins through the current run, with a visible HUD confirmation and no disk persistence or skill awakening.
- Recorded the proposed white-gold spectral skill-overlay strategy, full-value skill power budget, and measured reinforcement-wave approach without claiming those systems as implemented.
- Added focused regression coverage for bindings, facing resolution/retention, safe dash-attack timing and deduplication, progression synchronization, and HUD feedback.

## 2026-07-18 - Class-Gated Weapon Inventory and Orren Shop

- Added application-session owned weapons with per-character equipped IDs, permanent Ashwood fallback, scene/defeat continuity, class compatibility checks, and explicit new-journey reset without claiming disk persistence.
- Added Orren's functional weapon shop and an 18-coin Warrior-only Iron Sword; purchases deduct authoritative run coins, enter inventory without auto-equipping, and never include skills or selling.
- Converted Opaw's Gear/Armory page from preview-only data to owned click-to-equip behavior that synchronizes combat weapon data, detached world art, portrait, labels, damage, and knockback while reusing Balanced Slash and the same body animation.
- Generated and normalized separate 64x64 inventory and 16x24 world Iron Sword assets with preserved source/provenance and a deterministic processor.
- Added regression coverage for coin spending, insufficient funds, ownership, equip switching, class rejection, replacement-player continuity, Sanctuary shop handoff, and new-journey reset.

## 2026-07-18 - Story Memory and Data-Driven Expedition Access

- Established Opaw's isekai awakening, the lesser gods' treatment of mortal struggle as entertainment, The One Above's unresolved greater mystery, a future switchable roster separated from Warrior/Mage/Archer class concepts, and long-range god/beyond/boundless escalation in `STORY_BIBLE.md`.
- Added immutable expedition definitions and requirements covering minimum level, story flags, boss victories, discoveries, and narrative key items; rebuilt the Sanctuary route menu from those resources with visible unmet requirements and safe focus behavior.
- Added a narrow `StoryState` autoload with versioned in-memory snapshots, Sanctuary awakening memory, and Forgotten Grove completion/discovery recording while deliberately leaving disk persistence, inventory, roster switching, shops, and unbuilt routes inactive.
- Added focused regression coverage for combined unlock evaluation, unavailable destination protection, story reset/snapshot behavior, generated menu routes, and the existing title-to-Sanctuary flow.

## 2026-07-18 - Sanctuary Pavement Alignment Pass

- Recentered the Sanctuary's north-south pavement as a two-cell avenue beneath the even-grid portal and fountain instead of a single lane leaning to the east.
- Snapped the skill lodge and arms workshop door centers to their one-cell approaches, centered the weapon cart on a compact two-cell bay, and retained a restrained one-row service connector with garden breaks.
- Added route-shape regression coverage for the paired central lane, landmark aprons, exact service alignment, cart bay, and preserved grass gaps; captured the composed hub at gameplay scale for visual review.

## 2026-07-18 - Compact Sanctuary Service Corner and Runtime Archive Cleanup

- Rebuilt Skillkeeper Eira and Armskeeper Orren as compact 48x48-cell NPCs aligned with Opaw's oversized-head, tiny-body scale language while preserving their violet-scholar and rust/iron-armskeeper identities.
- Replaced the mushroom dwelling, merchant hall, and weapon stall with a complete skillkeeper lodge, armskeeper workshop, and prop-only weapon cart; no NPC body or cropped figure is baked into the new structures.
- Kept dialogue, interaction, collision, portal/fountain/ground presentation, and Orren's preview-only service rules unchanged.
- Split Sanctuary generation ownership so the direction board produces only ground/trees and the standalone processor owns landmarks plus all service content.
- Moved superseded service scenes/assets/sources, rejected Opaw variants and their retired builders/tests, and the legacy Awakened presentation under Godot-ignored `art_source/archive/`; retained the full Wayfarer rollback under active assets.
- Added gameplay-scale review capture and regression coverage for binary alpha, exact canvases, compact NPC bounds, editable service-building collision, preview behavior, dialogue flow, and archive-safe runtime references.
- Restored the player sword, Sweeping Cut, and dash audio players' explicit `SFX` bus declarations after the full active-suite cleanup exposed scene drift.

## 2026-07-18 - Three-Swing Sword Sequence and Higher Front Placement

- Raised the down-facing Ashwood Blade from `(12, -6)` to `(12, -8)` so it sits higher beside Opaw in the front view.
- Expanded sword-style data with a deterministic three-attack presentation sequence: broad outward sweep, reverse return sweep, and a farther-reaching visual finishing sweep.
- Kept all three variants on the shared weaponless Opaw body animation and unchanged weapon timing, hitbox reach, damage, and knockback.
- Reset the sequence on weapon-definition changes and added runtime coverage for variant order, reverse direction, and finishing extension.

## 2026-07-18 - Reusable Sword Attack Styles and Raised Front Blade

- Raised the down-facing Ashwood Blade two pixels so its front-view grip sits higher beside Opaw's torso.
- Added immutable Balanced Slash, Swift Slash, and Heavy Cleave presentation profiles for sword orbit, extension, trail, and impact accent; Ashwood uses Balanced Slash while the other profiles remain inactive foundations.
- Added an idle-only weapon-definition switch seam that synchronizes combat and detached presentation while preserving Opaw's shared weaponless body animation.
- Kept damage, knockback, phase timing, hitbox reach, ownership, acquisition, and persistence outside the style resource, and added focused regression coverage for those reuse boundaries.

## 2026-07-18 - Vertical Attack Direction and Front Sword Spacing

- Re-authored only Opaw's down/up attack rows so their wind-up, committed strike, and recovery remain centered on the screen-space vertical axis instead of leaning into a side-facing pose.
- Kept down attacks fully front-facing with both eyes and up attacks fully back-facing with a symmetrical head, torso, belt, and stance; the approved left/right source rows remain unchanged.
- Moved the down-facing idle/recovery Ashwood pivot inward from `(16, -5)` to `(12, -4)`, keeping the sword beside the torso without returning it to the face-overlap zone.
- Preserved the generated vertical revision and added a deterministic row-composition tool plus runtime skin/tunic-axis regression coverage.

## 2026-07-18 - Opaw Attack and Dash Face-Integrity Repair

- Replaced the compact armless attack and dash source boards whose extreme head rotation lost eyes and facial contour after 18x27 normalization.
- Kept down-facing frames front-readable with both eyes, preserved complete left/right profile heads and eyes, and kept up-facing frames as complete back-of-head silhouettes across all wind-up, launch/strike, and settle/recovery poses.
- Shifted motion emphasis from head rotation into torso lean, tiny-foot bracing, and scarf follow-through while retaining the existing action grids, timings, detached sword presentation, and gameplay authority.
- Moved down-facing idle/dash placement and side-facing wind-up anchors farther outside the head so the detached Ashwood Blade cannot visually slice across the repaired face.
- Added source crop-edge rejection for attack/dash and runtime regression checks for head padding, minimum head size, and direction-appropriate eye detail.

## 2026-07-18 - Compact Armless Opaw Activated With Full Model Backup

- Created a complete original compact top-down Opaw set across idle, walk, attack, dash, interaction, hurt, and defeat while preserving his serious black eyes, rust scarf, green tunic, tiny boots, direction contract, and stable gameplay scale.
- Removed arm, sleeve, and hand silhouettes from the active body; attack momentum now comes from deep whole-body anticipation, lunge, overshoot, foot bracing, and scarf follow-through.
- Switched `player.tscn` and the character preview to the compact armless `SpriteFrames`, moved the Ashwood Blade farther outside the body, and widened its presentation-only swing orbit without changing damage, reach, collision, or hit timing.
- Backed up the complete previously active Wayfarer model under `variants/wayfarer_original/` with seven independent textures and a loadable rollback `SpriteFrames` resource.
- Preserved every generated source and clean intermediate, added a reproducible compact-asset processor, documented that the supplied game screenshot informed broad proportion/readability only, and added regression coverage for active/backup independence.

## 2026-07-18 - Armless Compact-Feet Chibi Candidate

- Preserved the first truly armless Opaw attack model unchanged and created a separate sibling candidate with shorter lower legs and smaller compact boots.
- Kept Opaw's serious face, narrow torso, fully armless silhouette, direction rows, attack phases, scarf momentum, and grounded combat stance while moving the proportion modestly toward chibi.
- Extended the armless prototype builder to regenerate both candidates independently without touching the active player sheets.
- Expanded regression coverage across both 144x128 binary-alpha candidates and confirmed neither is wired into `player.tscn`.

## 2026-07-18 - Truly Armless Opaw Attack Prototype

- Clarified that the previous `handless` comparison still retained sleeve-shaped arms and preserved it without activating it.
- Added a separate image-generated Opaw attack board with no arms, sleeves, hands, fists, shoulder projections, or detached limbs; attack motion is carried by torso lean, footwork, head direction, and scarf follow-through.
- Added deterministic white-board removal, palette reduction, binary-alpha cleanup, and normalization into a review-only 144x128 sheet containing three 48x32 phases across all four directions.
- Kept Opaw's current active animation and gameplay scene unchanged pending an in-motion review of the armless prototype beside the detached Ashwood Blade.
- Added focused regression coverage for grid dimensions, binary alpha, complete cells, and active-art isolation.

## 2026-07-18 - Handless Opaw Candidate and Sword-Momentum Pass

- Preserved the approved Opaw sheets and added a complete grid-identical handless candidate whose exposed hands are replaced with closed green sleeve ends across all seven action sets.
- Preserved an image-generated handless attack-board exploration as source material and added a deterministic variant builder plus independent `SpriteFrames` resource; the candidate is not wired into the active player scene.
- Widened the normal Ashwood anticipation-to-impact arc, extended the committed pose, increased trail density/brightness, and retimed the phases to 0.11-second wind-up, 0.08-second active sweep, and 0.21-second recovery without changing damage authority or reach.
- Extended confirmed-hit presentation to a 0.10-second white silhouette flash and a short white-hot impact core while retaining the 0.045-second non-stacking hitstop.
- Added regression coverage that protects the active Opaw sheets, validates complete animation parity, and confirms the candidate differs without changing any grid dimensions.

## 2026-07-18 - Opaw Identity and Confirmed-Hit Feel Pass

- Renamed the active mortal character from Alden to **Opaw** across player-facing UI, canonical runtime/source assets, loadout and progression resources, build tools, tests, and project documentation while retaining `Player` as the reusable technical role.
- Added a reusable white-silhouette enemy flash and short non-stacking hitstop that trigger only from accepted player hits; misses, blocked contacts, and incoming player damage do not freeze gameplay.
- Added data-driven weapon knockback and configured the Ashwood Blade for a light 48 px/s push, preserving Sweeping Cut's stronger 90 px/s crowd-spacing role.
- Removed the Thrall-only reddish damage pulse so all current enemies use the same confirmed-hit presentation path.
- Extended combat regression coverage for hit flash cleanup, hitstop restoration, and Ashwood knockback metadata.

## 2026-07-15 - Opaw Action-Owned Animation Rebuild

- Replaced fixed generated-cell insets with expanded connected-silhouette isolation, restoring the complete up-facing walk/dash head and preventing neighboring-row fragments from squashing the right dash.
- Lowered and widened Opaw's directional Ashwood hand anchors from face height to arm height, then replaced the inverted left-side perpendicular path with a true mirror of the right swing.
- Centered the active trail on the hand path and added a short snappy weapon scale/color accent plus tapering trail width for more readable impact without changing hit timing, reach, damage, or collision.
- Restored the player sword, Sweeping Cut, and dash players' explicit `SFX` bus assignments after the full regression run exposed missing scene declarations.
- Replaced Opaw's active single mixed-pose atlas with independently generated idle, four-frame walk, three-pose weaponless attack, three-frame dash, two-frame interaction, two-frame hurt, and four-stage defeat sources.
- Refined the playable identity with a slightly boxy head, narrow pure-black determined eyes, rust-red scarf, narrow starter outfit, and small pointed boots while preserving the external Ashwood Blade.
- Rebuilt the deterministic processor around canonical direction rows, safe source-cell isolation, a shared 18x27 reference silhouette, binary alpha, and one y=32 foot baseline.
- Allocated 48x32 cells to extended actions and 64x32 cells to defeat so reaching, leaning, and horizontal collapse never force Opaw's body to become smaller.
- Mapped authoritative melee wind-up, active, and recovery phases directly to body frames 0, 1, and 2; added event-driven hurt playback and locomotion restoration without changing combat authority.
- Rebuilt `opaw_sprite_frames.tres`, preserved the superseded single atlas as legacy material, expanded regression coverage across all seven sheets, and left enemies, collisions, balance, and external weapon hit authority unchanged.

## 2026-07-15 - Opaw Direction, Interaction, and Weapon-Swing Repair

- Corrected the generated Opaw source order from `down/right/left/up` into the runtime `down/left/right/up` convention, fixing reversed side-facing movement and interaction art.
- Removed the crouched/shrunken normal-attack body cell and preserved Opaw's full-size directional silhouette with a restrained one-pixel wind-up and two-pixel active step.
- Rebuilt the visible weapon around a true hand/grip pivot and added data-driven sprite offset, visual scale, and swing radius metadata so later greatswords can reuse the same presentation rig.
- Added a short presentation-only active swing trail while preserving the existing hitbox as the sole reach/contact/damage authority.
- Aligned the character-menu Ashwood Blade preview to the same grip contract instead of positioning the texture independently.
- Made dialogue interactions turn Opaw toward Eira/Orren, hold the canonical directional interaction pose during conversation, and restore locomotion afterward.
- Expanded regression coverage for side-profile semantics, full-size attack frames, grip configuration, swing/trail phases, speaker-facing interaction, and dialogue restoration.

## 2026-07-15 - Opaw Modular Mortal and Ashwood Blade

- Named the active mortal player **Opaw**, with the presentation title `Mortal Wayfarer • Novice Warrior`, while retaining `Player` as the reusable technical actor role.
- Replaced the active Awakened body/attack presentation with a reproducible 128x256 modular atlas containing 32x32 directional idle, walk, brace, interaction, hurt, and staged-defeat poses.
- Added the Wood-rank **Ashwood Blade** as both a 16x24 visible world weapon and 64x64 inventory portrait, sharing one stable ID across weapon and equipment definitions.
- Added a presentation-only weapon observer that uses direction anchors and melee/ability phase signals for idle placement, swing motion, and defeat drop while the existing hidden hitbox remains authoritative.
- Added a three-pose recoil/weaken/slump defeat followed by runtime fade of the complete visual root; collision, damage, and restart authority remain unchanged.
- Reframed the active armory around one honest Wood starter and the planned Wood-to-Stonebound-to-Iron-to-Rare material ladder. Former A/S/Legendary/Mythic concepts and Awakened art remain preserved as legacy material without active player references.
- Updated menu identity, equipment focus behavior for a single item, reusable art rules, canonical asset records, design/architecture decisions, and focused regression coverage.
- Left existing enemies, Sanctuary NPC sprites, environment art, combat tuning, inventory authority, economy, and persistence unchanged for separate future passes.

## 2026-07-15 - Discoverable Character/Gear Entry and Tab Correction

- Corrected `player_character_menu` from an accidental Backspace physical-key code to the real Tab binding.
- Moved the global character-menu open shortcut to the early input stage so Godot's built-in Tab focus navigation cannot consume it first; opening remains blocked while another modal owns pause.
- Added a visible clickable top-left Character button with a reproducible hard-pixel satchel icon to the shared HUD in Sanctuary and both expeditions.
- Routed the HUD button through a presentation-intent signal and scene-flow wiring, keeping pause ownership and future inventory/equipment authority outside the HUD.
- Extended smoke coverage for the exact physical Tab binding, both open paths, modal pause/close behavior, icon dimensions, and binary alpha.

## 2026-07-15 - Equipment and Skill-Synergy Preview

- Rebuilt the paused character surface as polished `Gear & Armory` and `Active Skills` pages while preserving mouse, directional/Enter, Tab-open, Escape-close, pause, and progression behavior.
- Added an animated Awakened portrait, reusable Weapon/Armor/Gloves/Boots/Accessory slot presentation, and reusable equipment item/detail scenes with restrained rank-driven aura motion.
- Added immutable equipment/showcase resources and four original weapon concepts: A-grade Wayfarer's Iron, S-grade Gloamfang, Legendary Sunroot Oath, and Mythic Veilrender.
- Gave each weapon a future skill-synergy identity so equipment reinforces attack/dash/active-skill decisions instead of replacing skills with raw power.
- Kept the system honest and read-only: Wayfarer's Iron is the only equipped preview, while preview power, other weapons, synergies, inventory ownership, purchases, drops, persistence, and combat bonuses remain inactive.
- Generated and normalized one four-weapon source atlas into individually replaceable 64x64, compact-palette, binary-alpha runtime portraits with a reproducible Godot processor.
- Added regression coverage for rarity order, stable IDs, compact palettes, transparent corners, unchanged authoritative sword damage, two-page focus navigation, selectable armory details, and explicit inactive-state copy.

## 2026-07-15 - Reusable Skill Surfaces and Unified Menu Input

- Fixed the layer-100 transition overlay permanently consuming pointer events while transparent; it now blocks input only during an active fade and restores click-through afterward.
- Kept menu activation on native Godot buttons so mouse clicks, arrow-key focus plus Enter, Escape, and controller-ready focus share one event path.
- Added immutable four-slot skill-loadout/slot resources and moved Sweeping Cut's display name, icon, and description into its existing ability definition.
- Replaced duplicated character-menu and combat-HUD slot trees with reusable `SkillSlotCard` and `SkillBarSlot` scenes consuming the same player loadout.
- Preserved gameplay authority in actor-owned `AbilityComponent` instances; the reusable HUD slot observes cooldown signals without calculating casts or damage.
- Added regression coverage for the transition input shield, shared loadout identity, selectable skill cards, four-slot HUD composition, modal close controls, and focus ownership.

## 2026-07-15 - Portal Front/Behind Occlusion

- Split the existing portal image into an always-behind center-stair layer and a normally Y-sorted arch/guardian structure without changing its combined appearance.
- Added a separate front-approach depth area spanning the doorway and both guardians that moves the portal structure behind the character before their head overlaps it, while the smaller expedition prompt trigger keeps its independently authored close range.
- Players now remain visible throughout the southern approach and interaction, then return to normal front/behind Y-sorting after leaving; the user's small front stop, trigger, placement, and rear-backstop edits remain unchanged.
- Documented that `PortalBackstopCollision` prevents physical traversal through the rear monument but does not control render order.

## 2026-07-14 - Walk-In Portal and NPC Idle Refinement

- Replaced the combined portal/fountain runtime crop with a standalone 192x192 angel expedition portal and independent 112x96 divine fountain generated for the approved Sanctuary style.
- Reauthored the north courtyard so the player walks around the fountain, crosses visible open space, and ascends an unobstructed center staircase before the expedition prompt appears at the doorway.
- Split fountain collision and water presentation into a reusable `DivineFountain` scene; the expedition altar now owns only portal interaction, guardian footprints, rear backstop, glow, and runes.
- Replaced Armskeeper Orren's board crop with a standalone full-body source whose hands and silhouette remain intact in all four runtime frames.
- Added reusable timer-driven, one-pixel NPC breathing to Eira and Orren without moving their collision, interaction, shadows, or gameplay authority.
- Added deterministic standalone-asset processing, archived the superseded combined landmark outside runtime imports, and extended Sanctuary traversal, asset, scene, and editor-preview regression coverage.

## 2026-07-14 - Generated Sanctuary Visual and Interaction Rebuild

- Converted the current Mushroom Dwelling and Merchant Hall from rectangle collision resources to editable `CollisionPolygon2D` footprints without changing their existing bounds; visual shadows remain independent `Polygon2D` nodes.
- Added a reusable editor-only green checker backdrop to isolated Sanctuary prop/NPC scenes so transparent art and dark shadows remain readable against Godot's black 2D canvas; it performs no runtime drawing or processing.
- Corrected the Sanctuary crop pipeline so dark faces, arms, building interiors, and sign connectors survive while board background is removed; restored Eira's complete staff/book silhouette and Orren's complete arms while filtering the adjacent weapon-stall pole fragment.
- Moved both houses to connected side routes and rebuilt the angel landmark with a fountain polygon, small statue footprints, separate doorway pillars, a rear backstop, and a compact portal-threshold trigger; both fountain-side approaches remain continuously walkable for the player's footprint.
- Removed the unused first-round code-drawn house, fountain, altar, mushroom decoration, Veilkeeper presentation, their import metadata, and their obsolete sprite-kit generator after confirming no active runtime references remained.
- Added a mouse-operable top-right close button to The Awakened menu, clickable dialogue advance/close behavior, and Escape cancellation without accidental Eira menu chaining.
- Kept ambient music processing through paused modals and enabled continuous OGG looping so NPC conversations no longer interrupt the track.
- Preserved an approved 1536x1024 generated Sanctuary direction board and added a reproducible processor for reviewed crops, dark-background removal, hard alpha, exact canvases, idle accents, and dedicated terrain.
- Replaced borrowed Stage 1 ground with a Sanctuary-only 64x64 grass/cobblestone atlas and an authored one-cell route network.
- Replaced the first-round hub visuals with the angel portal/fountain, mushroom dwelling, merchant hall, weapon stall, two Sanctuary tree silhouettes, Skillkeeper Eira, and Armskeeper Orren.
- Kept the angel landmark as the existing expedition interaction while adding independent rune, portal, and water idle presentation plus traversal collision.
- Added a reusable `DialogueNpc` contract; Eira now opens the existing skill-information menu after restrained dialogue, while Orren honestly previews the future weapon service without purchases or equipment logic.
- Extended Sanctuary regression coverage across nine normalized assets, dedicated tiles, both NPC interactions, idle animation, pause restoration, collision, prompts, and Stage 1 selection.

## 2026-07-14 - Sanctuary Expedition Hub

- Added the safe `Sanctuary of the Remembered Veil` as the new-journey destination and Stage 2 return destination.
- Added a compact 18x12 hub layout with four mushroom homes, border trees, animated divine fountain, glowing mushroom clusters, central paths, and expedition altar.
- Added Veilkeeper Eira with a four-frame lantern idle, contextual talk icon, three-line restrained introduction, and reusable paused dialogue panel.
- Added a reusable expedition menu with Stage 1 available and two clearly sealed future-route previews.
- Added five reproducible exact-grid hard-alpha runtime sprites and kept shadows/glows separate from raster art.
- Added automated Sanctuary asset, animation, dialogue, prompt, pause, altar, and destination coverage.

## 2026-07-14 - Battle of Gods Title Screen

- Changed the F5 main scene from Stage 1 to a dedicated Battle of Gods title screen using the shared UI theme.
- Added a deterministic 960x540 luminous dark-fantasy grove background with a distant divine fountain, separate tree silhouettes, mist/fireflies, and vignette layers.
- Added keyboard, mouse, and gamepad-ready focus loops for Begin the Awakening, Settings, and Quit to Desktop.
- Added functional session-only Music, Combat Sound, and Menu Sound toggles using the existing audio buses.
- Routed new journeys through `RunSession.reset_run()` and the existing fade/loading transition into Stage 1.
- Added automated coverage for background contracts, initial/restored focus, settings behavior, audio toggles, run reset, and title-to-Stage-1 transition.

## 2026-07-14 - Shared UI Theme and Named Icon Kit

- Added a reusable dark-fantasy Godot `Theme` covering common panels, labels, buttons, progress bars, separators, focus, disabled, and tooltip states.
- Added nine reproducible binary-alpha pixel icons for health, XP, coins, attack, dash, Sweeping Cut, sealed slots, portal interaction, and future NPC dialogue.
- Applied the theme and semantic icons to the combat HUD and character menu while retaining local styles only for meaningful health/cooldown/skill states.
- Extended the portal proximity event with presentation metadata so the existing HUD prompt displays a portal icon and can later serve other interactables.
- Added automated theme, icon-size, hard-alpha, scene-wiring, and portal-icon coverage.

## 2026-07-14 - Bramble Spitter Asset Migration

- Migrated the Bramble Spitter's active 32x32 action sheet and `SpriteFrames` into its canonical `assets/characters/enemies/bramble_spitter/` runtime domain.
- Updated the Spitter scene, shared frame builder, architecture, README, roadmap, art-source mapping, and asset catalog.
- Extended exact-grid and binary-alpha regression validation to both 32x32 creature sheets.
- Preserved original and cleaned Bramble generation images under Godot-ignored `art_source/generated/`, completing migration for all current playable character art.

## 2026-07-14 - Mireling Asset Migration

- Migrated the Mireling's active 32x32 action sheet and `SpriteFrames` into its canonical `assets/characters/enemies/mireling/` runtime domain.
- Updated the Mireling scene, shared frame builder, animation test, architecture, README, roadmap, art-source mapping, and asset catalog.
- Preserved original and cleaned generation images under `art_source/generated/` and moved the superseded 24x24 runtime experiment into `art_source/archive/` rather than deleting it.

## 2026-07-14 - Forsaken Thrall Asset Migration

- Migrated the Forsaken Thrall's locomotion sheet, six-frame claw sheet, and `SpriteFrames` into its canonical `assets/characters/enemies/forsaken_thrall/` runtime domain.
- Updated the Thrall scene, shared reproducible frame builder, animation regression test, architecture, README, roadmap, and asset catalog to the canonical identity and paths.
- Preserved four original/cleaned Thrall generation images under Godot-ignored `art_source/` and removed obsolete import sidecars from their former locations.

## 2026-07-14 - The Awakened Asset Migration

- Migrated The Awakened's locomotion sheet, six-frame sword sheet, and `SpriteFrames` into the canonical `assets/characters/awakened/` runtime domain.
- Updated the player scene, reproducible frame builder, animation regression test, architecture, README, and asset catalog to the canonical identity and paths.
- Added the Godot-ignored `art_source/` workspace and preserved four original/cleaned Awakened generation images there without loading them at runtime.
- Removed obsolete Godot import sidecars for the moved files so the editor can regenerate correct metadata at their new paths.

## 2026-07-14 - Visual Asset Documentation Foundation

- Added `ART_DIRECTION.md` as the source of truth for the luminous dark-fantasy theme, palette roles, lighting, pixel baselines, UI language, and replaceable-background contract.
- Added `ASSET_CATALOG.md` with canonical IDs, verified dimensions, current runtime paths, controlled migration targets, runtime owners, planned UI assets, and lifecycle status.
- Defined non-destructive source/intermediate/runtime/archive handling and semantic asset naming before any physical file migration.
- Recorded the asset identity and replaceable-presentation decision as ADR 033.

## 2026-07-14 - Portal Prompt Layout Correction

- Removed the portal's duplicate world-space instruction and retained one reusable HUD-owned interaction prompt.
- Moved the prompt above the centered four-slot skill bar so contextual interaction text no longer overlaps combat controls.

## 2026-07-14 - Four-Slot Skills and Run Continuity

- Moved Sweeping Cut to numbered skill slot 1 while retaining Q as a temporary compatibility binding, and reserved inputs 2-4 for authored future abilities.
- Replaced the corner Q/E display with a centered four-slot combat bar.
- Added a paused Tab character/skill information menu for The Awakened with level, XP, coins, core actions, and sealed skill paths.
- Added a narrow in-memory `RunSession` so XP and coins survive portal transitions while defeat restart begins a fresh run; no disk save behavior was added.
- Added progression-continuity and character-menu regression coverage.
- Replaced the encounter's fixed startup delay with navigation-map readiness checks, preventing first-spawn queries before Godot synchronizes the map.

## 2026-07-14 - Event-Driven Combat Audio

- Added distinct CC0 cues for sword swing/impact, Sweeping Cut, dash, player damage, Thrall claw, Mireling leap/landing, Spitter fire, and seed impact.
- Added dedicated SFX and reserved UI buses beside the existing Music bus.
- Added actor-local positional audio observers synchronized to existing authoritative phase/state signals.
- Retained only ten used clips from the 95-file RPG Sound Pack and recorded their CC0 provenance.
- Added clean headless configuration/state synchronization regression coverage.
- Clarified that `Player` is the technical role while `The Awakened` is only the current prototype archetype/title; no personal name is approved.

## 2026-07-14 - Combat Impact Feedback

- Added reusable world-space damage numbers and three-pixel hit bursts for accepted player hits and accepted incoming player damage.
- Added a restrained 0.11-second camera-offset nudge that preserves gameplay time, dodge windows, telegraphs, and combat authority.
- Added cleanup and accepted-hit regression coverage for combat feedback.

## 2026-07-14 - Session Progression and Ambient Audio Foundation

- Added reusable session-only level-10 XP/coin progression with cumulative thresholds, capped leveling, and a compact level/XP/coin HUD readout.
- Added data-driven death rewards: Mirelings grant 8 XP/1 coin, Thralls 15 XP/3 coins, and Bramble Spitters 20 XP/5 coins.
- Kept levels non-interruptive and free of random upgrade choices; persistence, unlocks, and skill setup remain intentionally deferred.
- Added `AudioDirector`, its dedicated Music bus, stage-local music requests, and headless-safe music-routing coverage.
- Added the CC0 `Cathedral in the Forest (ambient loop)` by congusbongus as the first forest/grove background track, with local attribution.
- Added progression and audio smoke coverage.

## 2026-07-14 - Authored Stage 2 Grove Encounter

- Restored Stage 1 Wave 3 to its beginner 2 Mireling + 2 Thrall composition; the Bramble Spitter no longer appears there.
- Replaced the Stage 2 placeholder with `Thorns of the Forgotten Grove`: a 24x14 grove layout with deliberate tree, statue, navigation, spawn, projectile, and effect ownership.
- Added an arrival-lore delay, a two-Mireling warm-up wave, then one Mireling plus the first Bramble Spitter.
- Added a clear-gated portal back to Stage 1, Stage 2 defeat/restart ownership, and reusable explicit encounter start support.
- Added Stage 2 layout/encounter regression coverage and expanded transition coverage for the delayed return portal.

## 2026-07-13 - Bramble Spitter Ranged Enemy

- Added a 40-health forest-corrupted Bramble Spitter with navigation-aware range positioning and local crowd separation.
- Added a readable 0.75-second committed line telegraph, slow 8-damage seed projectile, world collision, finite lifetime, and 1.25-second recovery.
- Added one Spitter to Wave 3 by replacing one Mireling, preserving the four-enemy encounter cap.
- Increased Forsaken Thrall prototype health from 75 to 100 while preserving its attack damage and timings.
- Added generated 4x4 source art, cleaned provenance, a reproducible strict-pixel atlas processor, and runtime SpriteFrames.
- Added ranged-dodge, wave-composition, Thrall-durability, crowd-separation, and obstacle-navigation regression coverage.
- Removed a stale Mireling SpriteFrames UID reference that caused a harmless load warning after reproducible frame rebuilding.

### Fixed

- Rebuilt the Bramble Spitter SpriteFrames after texture import so every frame references its atlas instead of rendering an invisible body.
- Made the frame builder fail explicitly when the Spitter atlas is unavailable and added runtime coverage for a non-null body frame texture.

### Polished

- Made the Spitter swell and brighten during wind-up, added a dark-outlined warning line, firing recoil, muzzle flash, leaf sparks, a brighter seed trail, and a thorny impact burst.
- Extended the ranged regression test to verify visible telegraph, muzzle-flash, and impact presentation without moving damage authority into effects.
- Recorded the provisional compact-game progression direction: roughly ten levels, XP and coins, an authored skill menu, and three recommended active skill slots rather than random run-based choices.
- Expanded every directional Spitter attack from one pose to a three-frame charge, compression, and spit sequence.
- Replaced the laser-like warning line with a pulsing red ground target marker and made seeds terminate at the committed marked position.
- Separated kiting steering from sprite facing, preventing the Spitter from turning away immediately before attacking, and corrected zero-length navigation fallback steering.

## 2026-07-13 - Grounded Sweeping Cut Ability

- Added reusable immutable `AbilityDefinition` data and instance-owned cast/cooldown runtime state.
- Added Q Sweeping Cut with a broad frontal arc, multi-target 20 damage, light pushback, vulnerable recovery, and 3-second cooldown.
- Added optional pushback metadata to the existing damage contract and reusable signal-driven enemy knockback response.
- Preserved enemy movement authority and ignored pushback movement during committed Mireling leaps.
- Added a compact lower-right Q skill slot driven only by cooldown signals.
- Reused the full-body sword attack animation while adding a separate presentation-only sweep arc.
- Added end-to-end coverage for damage, multi-target behavior, displacement, action exclusion, cooldown, and HUD feedback.
- Clarified its crowd-control role with a wider arc, more visible spacing push, shorter recovery, and 2.5-second cooldown while retaining lower single-target damage than the normal sword.
- Rebuilt the unreliable overlapping skill-panel children as a visible container-based Q/E bar with `READY`, numeric cooldown, and explicit `E LOCKED` states.

## 2026-07-13 - Tiered Project Documentation

- Added `PROJECT_CONTEXT.md` as the compact runtime-state and task-routing entry point.
- Replaced the 721-line active decision log with a compact ADR index while preserving Decisions 001-025 under `docs/decisions/`.
- Condensed duplicated completed-roadmap history into milestone summaries; detailed completion records remain in this changelog.
- Changed documentation guidance to load deep design/history files only when relevant to the task.

## 2026-07-13 - Reusable Enemy Health Bars

- Added a compact world-space enemy health-bar component driven by existing health/death signals.
- Kept full-health enemies visually clean while revealing damage progress for 2.2 seconds after each hit.
- Integrated the same component into Forsaken Thralls and Mirelings without duplicating enemy logic.
- Added a dark, gold-edged frame so enemy health remains distinct over bright grass.
- Added regression coverage for initial visibility, damage updates, timed hiding, and death cleanup.

### Fixed

- Deferred melee hitbox monitoring changes during physics callbacks, preventing Godot's `Function blocked during in/out signal` error when a hit kills an attacking enemy.
- Added an immediate logical enabled-state guard so deferred collision changes cannot allow an extra hit.

## 2026-07-13 - Portal Prompt Proximity Correction

- Increased the reusable portal interaction radius from 18 to 52 pixels so the prompt appears before the player overlaps the portal center.
- Clarified the contextual prompt wording to explicitly say `PRESS F`.
- Added a portal-owned world-space interaction label so prompt visibility does not depend solely on an external HUD connection.

All notable completed project changes are recorded here. This project follows a lightweight changelog format until release/versioning policy is selected.

## Unreleased

### Added - 2026-07-12

- Added a timed non-hostile materialization state for the Forsaken Thrall.
- Added a recoil-and-lunge claw presentation aligned with its existing authoritative attack phases.
- Added limited-palette layered ancient-tree and forgotten-god statue assets.
- Added intermittent event-driven canopy sway without per-frame processing.
- Matched Thrall navigation completion distance and agent radius to its 6-pixel foot footprint.
- Reduced the corner vitality HUD and hid persistent controls/build labels during combat.
- Converted the editor-authored five-shape tree coverage into one smooth convex footprint, removing internal seams that could trap the player.
- Made navigation derive one clean convex obstruction from supported rectangle, circle, or convex collision shapes.
- Added a 384x192 Thrall claw sheet with six full-body attack poses in four directions.
- Synchronized Thrall wind-up, active damage, and recovery with animation frame pairs 0-1, 2-3, and 4-5.
- Reduced the detached red marker to a faint curved wind-up cue; authored scratch trails now communicate impact.
- Added the Mireling enemy with 30 health, hop pursuit, telegraphed body slam, materialization, and directional sprites.
- Expanded the map to 30x18 ground cells and added a non-smoothed pixel-stable player camera.
- Added seven fallback spawn points and three data-driven Stage 1 wave resources.
- Added lifecycle-driven Mireling/Thrall wave progression, transient wave HUD presentation, and a stage-clear portal.
- Removed the training target and manually placed Thrall from normal play.
- Added deterministic weighted terrain variation and purposeful tree/statue landmark placement.
- Added a Mireling combat smoke test and expanded environment/navigation regression coverage to 540 cells.
- Enlarged Mireling presentation to 32x32 cells and reworked attacks into a marked snapshot leap with landing-only damage.
- Fixed Thrall back-walking by facing path steering and prevented attacks through props with world line-of-sight checks.
- Prevented enemy bodies from pinning players and unified statue physics/navigation into one convex footprint.
- Replaced distant random-edge spawning with a 250-340 pixel navigation-safe ring and transient HUD arrows.
- Added leap-dodge and obstacle-chase regression tests.
- Fixed the infinite Thrall stop when the player waited directly opposite a statue.
- Replaced edge-centered Thrall paths with corridor-funnel routing and added exact endpoint regression coverage.
- Added reusable local-neighbor separation for Thralls and Mirelings.
- Preserved committed attacks and leaps while spreading chase-state enemies without player collision.
- Added a four-enemy crowd regression; the validated cluster reached 20.19 pixels minimum spacing.
- Added a reusable self-cleaning summon effect with ground runes, inward sparks, and segmented violet lightning.
- Integrated summon presentation with all encounter-spawned enemy types without changing gameplay authority.
- Added wave-clear announcements and a 2.25-second inter-wave recovery pause.
- Added summon-effect integration and cleanup regression coverage.
- Added explicit F/gamepad-west portal interaction and contextual prompt lifecycle.
- Added a reusable paused fade-to-black/loading/fade-in scene transition autoload.
- Added the minimal Stage 2 Forgotten Grove destination and return portal.
- Added portal interaction and full scene-transition regression coverage.

### Added - 2026-07-11

- Added repository-level contribution and maintenance instructions.
- Added the initial game design source of truth.
- Added the proposed Godot architecture and dependency rules.
- Added coding, scene, signal, performance, and pixel-art conventions.
- Added the project roadmap, known-issues register, decision log, and AI handoff notes.
- Added the initial README with honest pre-production setup status.
- Pinned the initial project to Godot 4.7 stable.
- Added a runnable Godot project using a 640x360 logical viewport and GL Compatibility renderer.
- Added pixel-oriented texture filtering and transform/vertex snapping defaults.
- Added keyboard, mouse, and gamepad-ready prototype input actions.
- Added named 2D physics layers for the world, actors, hitboxes, and interactions.
- Added the initial combat proving-ground scene and runtime ownership hierarchy.
- Added Godot-aware version-control ignore rules and initialized the local Git repository.
- Added a reusable player scene with a readable temporary pixel silhouette.
- Added replaceable local input and movement components.
- Added smooth acceleration, deceleration, normalized diagonal movement, and arena containment.
- Added mouse/right-stick aiming with movement-facing fallback.
- Added a typed `facing_changed` signal and presentation-only aim indicator.
- Added a headless movement smoke test covering maximum speed, diagonal speed, and stopping.
- Added gameplay-first pixel-art, environment-scene, occlusion, tilemap, palette, and asset-review requirements.
- Documented the provisional Godot 4.7 workflow for split environment visuals and controlled Y-sorting.
- Added a data-driven plain sword and reusable weapon definition resource.
- Added explicit wind-up, active, and recovery attack phases.
- Added reusable melee hitbox, hurtbox, damage information, and health components.
- Added per-swing target deduplication and active-overlap detection for close melee targets.
- Added a resettable training target with temporary health presentation and damage feedback.
- Added a deterministic end-to-end melee combat smoke test.
- Added a reusable evade definition and phase-driven evade component.
- Added a short supernatural dash with movement/facing direction fallback.
- Added invulnerability during dash movement and a vulnerable recovery lockout.
- Added player health and hurtbox state for real damage-immunity validation.
- Added temporary dash afterimages as replaceable presentation.
- Added public player attack/evade request boundaries enforcing mutual exclusion.
- Added a deterministic evade smoke test covering distance, immunity, recovery, and attack exclusion.
- Added the data-driven Forsaken Thrall enemy archetype.
- Added direct open-arena pursuit with acceleration and collision-aware movement.
- Added explicit chase, wind-up, active, recovery, and death states.
- Added a visible directional melee telegraph and vulnerable recovery window.
- Reused common hitbox, hurtbox, damage, and health contracts for enemy combat.
- Added an enemy encounter smoke test covering player damage, sword damage, and death.
- Added a signal-driven player vitality HUD with numeric and bar presentation.
- Added damage and dash-immunity visual feedback.
- Added an explicit player defeated state that cancels active attacks/evades and rejects new combat requests.
- Added a delayed fallen panel and arena-scene restart through R/gamepad north button.
- Added arena flow ownership separate from player and HUD logic.
- Added a defeat-flow smoke test covering immunity feedback, lethal damage, combat lockout, HUD state, and defeat presentation.
- Added a dark-fantasy prototype atlas and game-scale raster assets for four ground tiles, tree base, tree canopy, and ruined statue.
- Added a reproducible Godot TileSet builder and deterministic TileMapLayer ground sample.
- Added reusable ancient-tree and ruined-statue scenes with visual, collision, shadow, occlusion, and navigation responsibilities.
- Added shared Y-sort ownership for actors and environment props.
- Added runtime Godot 4.7 navigation baking from traversable geometry and carved prop cutouts.
- Upgraded the Forsaken Thrall to NavigationAgent2D path following with scheduled repaths and isolated-test fallback.
- Added an environment/navigation smoke test proving tile population and routing around the tree.
- Increased the logical viewport from 640x360 to 800x450 and the development window from 1280x720 to 1600x900, retaining exact 2x scaling.
- Added a simpler bright-fantasy raster atlas with grass tiles, green canopy, stump, and mossy shrine.
- Added static player and Forsaken Thrall sprite assets with matching pixel density.
- Replaced placeholder body polygons with sprite presentation without changing gameplay authority.
- Moved tree stump/roots permanently to the ground plane while preserving canopy Y-sort occlusion.
- Reduced prop collision/navigation footprints and changed navigation expansion to use a 6-pixel agent radius.
- Added a navigation regression assertion requiring 14-20 pixels of tree-route clearance.
- Simplified gameplay HUD text and removed the large in-arena title.
- Increased the active logical viewport from 800x450 to 960x540 and the display window to 1920x1080, retaining exact 2x scaling.
- Added exact 96x128 player and Thrall sheets composed of sixteen 24x32 direction/action cells.
- Quantized the player sheet to 10 colors and Thrall sheet to 9 colors without dithering.
- Added reproducible SpriteFrames generation for directional idle, walk, attack, dash, and defeated states.
- Integrated the sword into player attack cells and removed the visible floating polygon sword and permanent aim arrow.
- Kept the directional melee pivot solely for invisible hitbox authority.
- Added event-driven player and Thrall animation presenters.
- Reduced HUD and instruction-panel dimensions for the wider gameplay view.
- Expanded the deterministic ground map from 13x8 to 15x9 tiles.
- Added character animation state regression coverage.
- Rebuilt character sheets with binary alpha and removed semi-transparent extraction fragments.
- Increased retained palette detail to 14 player and 11 Thrall opaque colors to preserve facial pixels.
- Removed enclosed transparent holes from every 24x32 character cell.
- Replaced shrinking player attack cells with stable-bound character poses.
- Added a hand-centered three-frame pixel sword swing for wind-up, active, and recovery.
- Reduced and re-centered the sword hitbox around the visible swing.
- Replaced tall movement capsules with 6-pixel circular foot footprints.
- Added separate 24-pixel full-body hurtbox capsules for player and Thrall.
- Moved actor shadows from `y = 7` to the foot plane at `y = -2` and reduced their opacity/size.
- Expanded animation regression tests to enforce binary alpha, stable attack bounds, swing phases, and shadow/collision placement.
- Added a 384x192 directional sword-attack sheet containing twenty-four 64x48 authored action cells.
- Added six player attack frames per direction: anticipation, coil, swing, impact, follow-through, and recovery.
- Replaced the temporary three-frame weapon overlay with unified character-and-sword poses.
- Mapped wind-up to frames 0-1, active damage to frames 2-3, and recovery to frames 4-5.
- Added shared-scale and common-baseline validation for all authored attack cells.

### Breaking Changes

- None currently recorded.

### Bug Fixes

- Made player component dependencies deterministic on a clean Godot class-cache import by explicitly preloading their scripts.
- Removed a fragile child-ready signal emission that ran before the training target's presentation references were ready.
- Removed empty chase-state tweens that produced runtime warnings without animating a property.
- Replaced deprecated outline triangulation with the Godot 4.7 NavigationServer2D source-geometry baking workflow.

### Performance Improvements

- None.
