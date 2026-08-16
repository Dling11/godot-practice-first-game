# Changelog

## 2026-08-16 - Rapid Engage and Navigation Facing Correction

- Accepted Decision 110 after owner review rejected Decision 109's realistic painted skill icons: generated and installed a B+C hybrid family for King Skills 1-4, normalized every runtime icon to native 24x24, binary alpha, and one fixed 14-color palette, and added native-size regression checks. The cursor experiment remains a separate pending visual review; the accepted four-arrow move marker remains.
- Accepted Decision 108: replaced the walking-foot click marker with a small original two-frame four-arrow convergence indicator, normalized all four King skill icons, added animated targeted-skill cancel feedback, refined the themed hand/sword cursor silhouettes, and tightened action-tray/enemy-roster accents.
- Accepted Decision 107: manual left-click attacks now face toward the clicked cardinal side; the enemy roster adds explicit Auto All and Auto Skill toggles that reuse normal targets, navigation, casts, cooldowns, and damage; and the move marker received its initial two-frame proof, later superseded by Decision 108. Added matching cyan/gold/navy Auto icons and reused the authored sword icon on the far-right Attack fallback.
- Accepted Decision 106: restored left-click immediate manual sword attacks, made right click or `Esc` cancel targeted-skill previews without leaking movement, and moved the unnumbered Attack HUD fallback to the far-right end after Skills `1`-`4`.
- Accepted Decision 105 and replaced the interim number-`1` Attack/double-click scheme: right-clicking ground now clears combat and moves, right-clicking an enemy immediately selects and auto-engages, Skills return to `1`-`4`, and the HUD Attack fallback is unnumbered. Targeted skills confirm with left click/controller and use `Esc` as their only cancel input; right click is safely consumed while a preview is active.
- Corrected owner-reported engagement/facing gaps: same-enemy rapid clicks now provide a 420-millisecond fallback to the native double-click flag, and assisted/click-to-move locomotion faces along its actual navigation steering direction.

## 2026-08-15 - Numbered Click Combat and Footprint Aura Refinement

- Accepted Decision 104: reordered the action tray and keyboard to `1` Attack followed by Skills `2`-`5`; Basic Attack now swings freely when no target is selected or the selection is outside its 260-pixel assist radius instead of auto-acquiring or forcing a long pursuit.
- Single enemy click now selects, double-click explicitly engages auto attack, and ground click clears target/auto attack before moving. Fixed an unreachable ability-cancel input branch discovered during the correction.
- Replaced the oversized red underfoot selection circle with a small animated overhead chevron. Added subtle animated oval footprint auras to King and every live enemy scene, sized by movement footprint with richer Elite/Boss arcs while leaving all physics authority unchanged.
- Moved the live enemy roster beneath the top-right Menu button, increased its height without widening it, enlarged threat rows, and added a slim translucent scrollbar. Added focused control, assisted-combat, HUD-order, and aura regression coverage.

## 2026-08-15 - King Combat Control and Target UX

- Accepted Decision 103: empty left-click now creates a navigation-aware blue movement destination, while clicking an enemy selects it without beginning combat. `BASIC ATTACK` or a bottom-right enemy card starts approach-and-repeat attacks; Escape, right-click, and the selected-target × stop it.
- Added readable control without changing enemy tiers: King's basic sword hit now causes a 0.11-second Light flinch, Skills 1/2 apply stronger interruption, and Skill 3 applies a 0.78-second stun-like interruption. Elite reduction and Boss immunity remain intact.
- Slowed King's basic sword cycle to 0.59 seconds and renamed/compacted the action-tray control from `ATTACK / AUTO` to `BASIC ATTACK`.
- Moved the selected enemy health card into the left status column with a circular portrait, added a scrollable bottom-right live enemy roster with circular portraits/health/Boss-or-Elite labels, and changed the world selection mark to a red footprint-sized circle.

## 2026-08-15 - Single-Target Assisted Combat

- Accepted Decision 102 and added optional click-to-target combat without removing WASD, manual attacks, dash, skills, or the shared action buffer.
- Added navigation-aware approach, automatic legal-boundary normal attacks, nearest-target Attack-button assistance, right-click clearing, one gold world marker, and a top target name/health panel. Decision 103 supersedes its automatic click-to-attack behavior and presentation.
- Increased basic-attack hitstop from a fixed 0.018 seconds to accepted-damage scaling between 0.024 and 0.034 seconds. It remains presentation-only; normal attacks still carry no stagger and cannot permanently interrupt enemies.
- Added focused regression coverage for click picking, one-target replacement, manual movement priority, automatic facing/attack, death cleanup, nearest acquisition, HUD layout, and hitstop capping.

## 2026-08-15 - Complete Stage V Armor and Live Equipment Authority

- Accepted Decision 101, added Mirebound Leggings, and finalized one Weapon Essence, five armor positions, and four accessory positions without expanding the compact Character & Bag footprint.
- Added profile-backed `GearInventory`, live HP/armor/Ward/attack-speed/movement-speed aggregation, generic detail stat copy, matching-slot drag-to-equip, and slot/name/rarity/quantity inventory sorting.
- Retuned King's unequipped baseline to 110 px/s movement and a 0.46-second normal-attack cycle. The complete Stage V armor set provides +32 HP, +16 armor, +4% Ward, +12% normal-attack speed, and +15% grounded movement.
- Expanded Nema to six Stage V recipes plus two future accessory previews. F9 grants the full set, discoveries, Stage V seal, and maximum materials without saving, so the preview reports test readiness while normal atomic crafting remains disabled.
- Replaced the unclear Varkuun Core material icon with a cracked living seed-heart held by roots and added the matching 64x64 Mirebound Leggings icon. Both use deterministic binary-alpha processing and preserved source/review assets.

## 2026-08-15 - Stage V Core Equipment Data and Art Lock

- Accepted Decision 100 and finalized Varkuun Edge, Old Bark Helm, Heartwood Plate, Rootfiber Gloves, and Mirehide Boots before enabling material spending or non-weapon equipping.
- Preserved all four approved objects from the existing Forest/Varkuun concept board and generated only the missing helmet. A deterministic processor emits five matching 64x64 binary-alpha runtime icons plus clean and 4x review artifacts.
- Added one immutable five-item equipment catalog and implemented stat data: Varkuun Edge 11-13 basic/28 skill power; the armor set totals +20 maximum health, +17 armor, and +0.25 HP/s regeneration. Only Varkuun Edge currently has live equip authority through the existing weapon path.
- Replaced the two provisional Stage V recipe previews with five exact Tier-2 recipes while retaining two sealed Stage VIII accessory previews. The complete set costs four Varkuun Cores, matching first clear plus two replay claims.
- Nema's read-only Rootforge now shows each Stage V output icon and stat summary, compacts seven recipe buttons safely, and still cannot consume materials or grant output. F9 provides maximum materials and Varkuun Edge for non-saving tests.

## 2026-08-15 - Final Nine-Slot Character Loadout

- Accepted Decision 099 and finalized one Weapon Essence, four armor positions (Head, Plate, Gloves, Boots), and four accessory positions (Bracer, Amulet, Ring, Talisman), superseding broad Body/Hand/Foot Relics and generic Accessory I-II labels.
- Preserved the compact two-page Character surface while fitting all nine positions around King. Character & Bag keeps the loadout upper left, selected-item information upper right, and the 24-position filtered inventory underneath; Active Skills remains separate.
- Tightened the RPG loadout presentation again: Head leads the left armor column, Weapon Essence sits above King, both slot columns move inward beside the portrait, inventory cells shrink from 46x46 to 38x38, and King's body/feet center over the portrait shadow independently of his integrated sword's visual weight.
- Expanded `EquipmentDefinition.Slot` to the finalized identities while preserving Weapon at ordinal zero for existing resources. Only Weapon has runtime equip authority; armor/accessory items, stats, crafting, and persistence remain deliberately unimplemented.
- Changed debug F9 from small material samples to the supported maximum of every authored material for repeated future crafting simulations; compact cells display `MAX` while tooltips retain exact quantities. Added the Divine weapon versus declared-God immunity concept as future design direction only, with no current combat authority.
- Added focused regression coverage for the exact slot schema, weapon placement, page focus/visibility, modal bounds, and non-overlapping loadout cards.

## 2026-08-15 - King Front-Face Readability and Forest Core-Gear Concept

- Corrected only the down-idle hair pixel that extended into King's left eye, preserving both approved dark pixels in each eye without changing atlas dimensions, alpha bounds, foot baseline, animation timing, side/up views, collision, or skill authority. Riftbreak and Sovereign Pursuit endpoint frames inherit the corrected exact idle pixels.
- Added a focused regression that protects both pixels of every down-facing eye and the warm separation pixel beneath the repaired idle fringe.
- Generated and cleaned a non-runtime four-item Forest core-gear concept board for the Sanctuary Rootforge direction: Weapon Essence, Body Relic, Hand Relic, and an unmistakable boot-shaped Foot Relic share Varkuun-core green, petrified root, blackened iron, restrained violet seams, and forge-gold accents. Runtime icons, item definitions, stats, crafting, and equipping remain deliberately unimplemented pending visual approval.

## 2026-08-15 - King, Varkuun, and Stage II Balance Pass

- Corrected Varkuun becoming permanently wedged against Stage V's solid carrion and dead-forest props. Chase now consumes his `NavigationAgent2D` path, applies a short collision-derived side detour when a static footprint still blocks him, and validates every committed jump landing against both navigation and his physical boss footprint.
- Added a production Stage V regression that places King and Varkuun on opposite sides of the carrion landmark, requires a real lateral detour and forward progress, and rejects a jump target overlapping that prop.
- Closed Varkuun's final-phase kite loophole: at 30% health or lower, sustained long range can start a ready 3/4/5-jump pursuit without requiring the boss to land a melee attack first. Full-map bounds, committed landing markers, prison sequencing, and cooldowns remain unchanged.
- Added reusable diminishing-return armor to `HealthComponent` and enemy armor data to `EnemyDefinition`. Varkuun now has 30 armor, preserving raw and accepted damage values for accurate feedback and future player equipment integration.
- Separated normal-hit damage from weapon skill power. King's own signature sword retains 25 skill power but rolls 10-12 per normal swing.
- Added a distinct King weapon/catalog identity with integrated visual support and version-1 save migration. Opaw's Ashwood/Iron catalog retains its original fixed 25/32 damage and Balanced Slash presentation instead of leaking into King.
- Replaced King's inherited 58x96 Balanced Slash authority with his dedicated 48x56 sword form and matching restrained presentation profile.
- Raised only Stage II's active-enemy ceiling from four to six, preserving its authored reinforcement queue and every other stage-specific ceiling.
- Added and updated focused regression coverage for armor, boss anti-kiting, variable basic damage, tightened edge contact, equipment separation, sword style, and Stage II pressure.

## 2026-08-15 - Varkuun Conversation and Stage V Milestone Chest

- Added a three-line defeat exchange beginning with Varkuun's `Impossible...` and ending on King's answer, establishing a reusable dramatic final-quote pattern for later bosses.
- Delayed chest manifestation until 2.2 seconds after the defeat dialogue closes, allowing Varkuun's complete collapse, corpse hold, and fade to finish before the reward occupies his death position.
- Split the root-prison sound sequence into warning, lock, low execution rumble, and a separate heavy impact layered on the 300-damage eruption.
- Corrected the owner-tested chest scale from an oversized 112x96 presentation to 74x66, exactly two pixels larger per axis than Stage III's Reliquary, and tightened its glow, interaction, and physical footprint accordingly.
- Reworked the chest palette around restrained oxblood/crimson and royal plum panels, aged gold hardware, dark petrified structure, and the existing small green core so its boss tier is noticeable without becoming oversaturated.
- Expanded the entrance into a six-line Varkuun/King exchange with per-line 96x96 portrait switching, a new identity-matched King portrait, and a visible mouse-operated Skip control.
- Added Varkuun's Chest as a third, larger major-boss chest tier with distinct petrified-wood/root closed and open art instead of reusing Stage III's Rootbound Reliquary.
- Added the 24x24 Varkuun Core boss material and a Stage V loot table: first clear grants two cores plus the permanent Forest core-gear seal/discovery, while replays grant one core without repeating the seal.
- Changed Stage V completion so the chest appears at Varkuun's actual death position and the return portal/story/save finalize only after a successful claim.

## 2026-08-15 - Shared Cooldown-Denied Feedback

- Added a dedicated real CC0 error/denied recording for repeated Dash and equipped-skill requests while their cooldown remains active.
- Routed keyboard, controller, mouse, and future touch attempts through one `Player.action_denied` presentation signal without buffering or changing cooldown authority.
- Kept grey countdown controls tappable for feedback while preserving sealed and unavailable controls as disabled.

## 2026-08-15 - Varkuun Entrance and Boss Audio

- Named the Stage 5 guardian Varkuun, Lord of the Withered Grove.
- Added the production threshold sequence: hidden approach, aerial drop, crater landing, portrait dialogue, then boss HUD/combat and dedicated music.
- Replaced the rejected procedural cues with curated real CC0 recordings for the entrance, footsteps, lunge, slap, three-part combat jump, root prison, phase escalation, hurt, and defeat; retained a CC0 orchestral boss loop with complete provenance.
- Corrected owner-tested production behavior: awakening still begins in the northern basin, but Varkuun can now pursue across the whole traversable map. Replaced the effectively inaudible boss track with Cleyton Kauffman's CC0 fantasy/JRPG `Boss Battle Theme` OGG and raised only boss playback from -13 dB to -7 dB.
- Removed duplicate `ui_accept` handling from `DialoguePanel`; its focused native button now exclusively owns Space/Enter while F remains the explicit shortcut, preventing one key press from advancing twice.

## 2026-08-15 - Stage 5 Boundary and Carrion Readability Correction

- Replaced the oversized realistic Stage 5 animal runtime detail with a handmade 48x32 stylized pixel carrion asset and retained fly presentation as four independent tweens.
- Moved all eighteen repeated dead-tree thickets so each is rooted at or partly outside an actual map boundary, preserving their branch-tree silhouette while clearing the interior read.

## 2026-08-14 - Production Stage 5 Dead Forest Route

- Added a real 24x18 scrolling Stage 5 scene connected directly from Stage 4's eastern gateway.
- Authored a southern arrival, traversable decayed approach, and separately triggered northern boss basin; the boss remains targetless and physics-disabled until King crosses the basin threshold.
- Added one reusable three-tree edge-thicket asset and placed eighteen deliberate scale/mirror variants around the map boundary instead of randomly scattering interior trees.
- Added a non-graphic corrupted forest-animal carcass landmark with four separately tweened flies, plus individual approved tall tree, snag, fallen-log, and uprooted-log variation.
- Deleted the owner-rejected standalone stump generated source, cleaned source, runtime texture/import, review image, scene, processor references, and live/test references.
- Added production boss HUD/combat feedback, stage completion persistence, expedition commit, and a Sanctuary return ring while leaving entrance dialogue, dedicated audio/music, and milestone reward explicit future work.

## 2026-08-14 - Stage 5 Grounding, Movement, and Boss Death Correction

- Reduced the tall bare tree and snapped snag in the F8 composition while retaining their approved source/runtime textures.
- Replaced flattened full-texture prop shadows with tight contact polygons for the tall tree, snag, fallen trunks, uprooted trunk, and older root-stump so their ground contact no longer reads as floating.
- Added an automated movement assertion proving King traverses the F8 arena; documented that the 960x540 fixed-camera room is an isolated boss proof rather than the future full Stage 5 map.
- Reprocessed all twenty directional boss defeat frames through proportional collapse envelopes, retaining all five frames without the generated body-width inflation.
- Added a 0.2-second corpse hold followed by a 0.65-second synchronized body/shadow fade after the 1.25-second collapse.

## 2026-08-14 - Authored Stage 5 Boss Basin Environment

- Replaced the focused F8 boss proof's flat arena with a deterministic 15x9 TileMap basin backed by a new full-decay 4x4 terrain family.
- Expanded the scenery from repeated root-stumps into an unmistakable dead-forest set: one tall bare ancient tree, one snapped hollow snag, two horizontal fallen trunks, one uprooted diagonal trunk, and one retained older root-stump. Each obstacle has authored collision/navigation behavior and deliberate perimeter placement.
- Added a dormant broken shrine landmark at the north edge with two colliding side masses and an open center; it is explicitly not a portal or implemented story trigger.
- Replaced Stage 4's unrelated eastern statue with the same broken-gateway architecture and moved its post-clear ring anchor inside that ruin, establishing one ancient route family while preserving the current Sanctuary destination.
- Left the real Stage 5 route, entrance, rewards, and possible later godlike manifestation unimplemented.
- Added a reproducible environment processor, visual review exports, and a focused smoke test for asset dimensions, authored layout, props, navigation, and portal separation.

## 2026-08-14 - Stage 5 Boss Portrait

- Generated an identity-matched head-and-shoulders portrait from the approved Stage 5 boss concept, preserving its dead-bark crown, broken armor, plum heartwood, luminous eyes, and exposed core.
- Added a reproducible cleanup/normalization path that removes the generated chroma field, crops the connected boss silhouette, and emits a transparent 96x96 dialogue/bestiary asset plus a 4x review image.
- Cataloged the portrait as presentation-only; the production ID remains `stage_5_boss` until its final lore name and real Stage 5 encounter are approved.

## 2026-08-14 - Reusable Boss Health HUD

- Added one reusable top-screen boss health scene with exact HP, delayed damage trail, 80%/30% threshold marks, and Phase I/II/III status.
- Replaced the F8 arena's duplicated proof panel and bound the shared HUD directly to the real Stage 5 boss health authority.
- Made Combat Lab bind the newest spawned Stage 5 boss, clear the HUD with the simulation, and restore another valid boss binding when necessary.
- Removed the Stage 5 actor's competing world-space enemy bar and added focused coverage for phase boundaries, easing, defeat, F8 binding, lab lifecycle, and local-bar suppression.

## 2026-08-14 - Stage 5 Health-Scaled Jump Pursuits

- Scaled repeatable jump chains by current boss health: one jump at 80-100%, alternating two/three below 80%, and cycling three/four/five at 30% or lower.
- Varied pursuit targets through direct tracking, velocity prediction, and alternating escape-lane cutoffs while keeping every shown marker committed and dodgeable.
- Added 120% mid-health and 150% low-health finishing slams with escalating impact presentation; prison begins only after the final landing.
- Started explicit 4.6/3.8/2.6-second tier cooldowns after prison recovery and kept a one-melee low-health gate so rapid chains recur without becoming continuous.
- Expanded focused coverage for tier boundaries, deterministic counts, recurring low-health chains, final damage, and fast-prison handoff.

## 2026-08-14 - Faster Stage 5 Boss and Positional Root Execution

- Raised the boss proof from 42 to 58 px/s, acceleration from 320 to 480, and walk playback from 7.5 to 9 fps.
- Tightened lunge from 0.82/0.14/0.90 seconds to 0.62/0.12/0.66 and slap from 0.78/0.14/0.72 to 0.60/0.12/0.54 while retaining their damage, reach, order, and readable committed phases.
- Changed the delayed root execution from restraint-status damage to a fixed 34-pixel location check. Dash-avoiding capture or breaking free now enables escape movement but still receives the provisional 300 physical damage when King remains inside the locked ground core.
- Added Decision 090 and focused tests for exact tempo, outside-zone miss, ordinary failed escape, and dash-avoided in-zone execution.

## 2026-08-14 - Stage 5 Up-Walk and Combat Lab Focus Correction

- Replaced cell-first Stage 5 boss walk extraction with full-board connected-actor recovery. All six up-facing bodies crossed 22-24 source pixels into the preceding row; recovering the 24 complete actors restores their crowns while preserving six unique frames per direction, fixed stature, binary alpha, and the y=90 foot baseline.
- Made every Combat Lab administration control mouse/touch-only for keyboard focus. Clicking Spawn x1/x4/x8, selector, toggles, test kit, Clear, Reset, or Exit can no longer retain UI-accept focus and reinterpret Space/Dash as another administration click.
- Added focused crown-edge and complete admin-control focus regression checks.

## 2026-08-14 - Stage 5 Boss Hurt Stability Correction

- Rebuilt the active directional reaction atlas with per-view hurt-width envelopes while preserving the approved action-family height and y=98 foot baseline, removing the visible scale pop when hits swap from idle/walk into reaction poses.
- Made chase hurt playback presentation-exclusive and priority-safe: facing/movement updates cannot cut its three frames short, repeated contacts do not restart it, and committed lunge/slap/jump/root states retain their authored body animation while shared hit flash still confirms damage.
- Restored the Dash HUD from restraint using the evade component's real cooldown state rather than unconditionally displaying `READY`.
- Added focused silhouette-width, hurt-completion, committed-attack, and Dash cooldown regression coverage; the Stage 5 boss, root prison, HUD, Combat Lab, combat-feedback, control, buffer, and King asset smoke tests pass.

## 2026-08-14 - Root Execution Visual and Prompt Correction

- Replaced equal-strip execution extraction with complete-component assignment around eight real frame anchors, removing the visible left/right fragments imported from neighboring eruptions.
- Reduced the prison effect from boss-effect scale to a 64x44 content envelope around King's real 48x32 body while retaining the 128x112 stable atlas contract and open foot center.
- Looped the two intact capture poses so the restraining roots flex instead of becoming a static ring; progressive struggle inputs still select the authored fracture/break stages.
- Added `MASH DASH / TAP` and `0/5` progress above the prison, plus a highlighted clickable Dash slot that changes to `TAP` / `BREAK n/5` and restores normal Dash UI on release. Left-click is intentionally not shown because the shared Dash action is the actual keyboard/controller/mobile authority.
- Corrected final-zero restraint release ownership so the fifth HUD tap always emits release and restores the Dash indicator. Focused visual, HUD, boss, input-buffer, and lab tests protect the correction.

## 2026-08-14 - Stage 5 Boss Root Prison Execution

- Added the fourth boss-proof action after each jump: planted-hand wind-up, foot-tracking warning, world lock, 34-pixel capture, 2.2-second channel, execution, and punishable recovery.
- Added reusable player restraint authority. Capture cancels buffered/current attacks, dash, targeting, and all skills; freezes movement; rejects skill/attack requests; and converts keyboard/controller/mobile dash activation into five struggle points. Ability invulnerability cannot bypass capture.
- Added separate eight-frame root-prison and eight-frame 300-damage execution atlases, progressive break presentation, HUD struggle counter, world-locked broken remains, and an execution camera shake stronger than slap/jump feedback.
- Added focused coverage for automatic post-jump cadence, active movement-skill cancellation, frame ranges, exact five-input escape, escaped damage immunity, fixed effect ownership, release, and exact 300 failed-escape damage.

## 2026-08-14 - Stage 5 Boss Lunge and Overhead Slap

- Corrected the existing basic attack's runtime language from “sweep” to “lunge”; its authored frames are a forward physical root-arm extension, not a lateral arc or root summon.
- Added a separate 32-frame, four-direction overhead root-hand slap sheet with eight chronological poses per direction. Deterministic processing extracts every complete actor globally, normalizes a shared ground baseline, preserves binary alpha, and consumes every generated frame.
- Added independent lunge and slap state families/hitboxes. The boss alternates quick lunge and slower 42-damage slap before its jump threshold; slap contact emits a smaller presentation-only camera kick while jump landing retains the stronger shake.
- Expanded focused boss coverage from 44 to 56 directional runtime animations and verified the lunge, slap, locked jump, landing damage, crater/spike ownership, and camera restoration paths.

## 2026-08-14 - Debug Admin Mode and Combat Lab

- Added session-only debug Admin Mode. F10 reveals a Sanctuary-side Combat Lab entrance; F7 enters/exits the lab, while the existing F8 Stage 5 focused arena remains available only to an enabled admin session. Release builds reject the tooling and no admin state is saved.
- Added a reusable 960x540 Combat Lab using the real King, navigation, projectiles, feedback, and all seven current enemy scenes. Controls spawn 1/4/8 of the selected actor, pause/resume enemy targets, toggle King invincibility, enable the authored unlimited-skill test kit, clear, reset, and return to Sanctuary. The current Stage 5 boss is selected and spawned on entry for immediate review.
- Lab actors have `EnemyRewardComponent` removed before entering the tree, and entering suppresses debug-session autosaves. Focused tests verify F7/F10 bindings, complete roster, reward stripping, AI control, x1/x4/x8 counts, invincibility, clear, and Sanctuary panel visibility.

## 2026-08-14 - Playable Stage 5 Boss Combat Proof

- Added an isolated F8-accessible arena using the real King and a provisional Stage 5 boss controller. The boss now chases, performs a readable root-arm sweep, snapshots a visible jump target, travels through an actor-root arc, lands one controller-owned radial hit, and leaves a world-owned crater that survives recovery and fades independently.
- Installed all six current exact-grid boss texture families as runtime assets. A signal-driven visual builds 44 directional animation ranges without moving damage into animation; focused coverage verifies those ranges, sweep phases, locked targeting, exactly one landing hit, and world effect ownership.
- Corrected the basic sweep atlas processor after live review exposed amputated root-arm ends. It now recovers each complete connected actor before assigning it to its authored source-grid position, preserving long wind-up/contact silhouettes that cross artificial parent-sheet boundaries without generating or discarding frames.
- Corrected the jump-impact processor after live review exposed neighboring crater fragments at the final frame edges. Complete debris/components now follow their nearest authored impact center, the crater's ground center aligns exactly with the boss's feet, a new six-frame open-center root-spike layer rises and retracts independently, and a short landing camera shake plays even on a successful dodge. Damage and hit radius are unchanged.
- This is a visible combat/scale proof, not Stage 5 completion. Final name, balance, audio, additional skills/phases, dialogue, rewards, and the real encounter remain open.

## 2026-08-14 - Stage 5 Boss Identity Approval

- Approved the Stage 5 major-boss concept: a massive hunched humanoid forest guardian with enormous asymmetric root arms, split dead-bark torso armor, a luminous hollow core, heavy mobile legs, and a natural armor-break phase silhouette. Locked its future scale above the Rootbound Husk but below colossal Stage 10 scale. The concept remains source-only; mechanics, name, standing normalization, animation, runtime authority, audio, reward, and Stage 5 are not implemented.
- Approved its exact-grid four-direction standing and six-frame-per-direction walking checkpoints at approximately 1.4x Husk height. Added a separate review-only 32-frame hurt/defeat family assembled from two 4x4 parent sheets: three hurt/recovery poses flow into buckle, collapse, grounded defeat, and final settle in every direction. Wider 144x112 cells preserve the approved body scale and contact anchor; all 32 frames remain retained and distinct.
- Reserved `Lord` as the eventual display-title pattern rather than the creature's entire name. The stable production identifier remains `stage_5_boss` until its lore and combat domain are approved.
- Added a review-only 32-frame basic-melee candidate for the Stage 5 boss. Its asymmetric root-arm sweep uses authored down/left/right/up views, three staged anticipation poses, a separate release, one clear contact, overshoot, and two recovery poses. The deterministic assembler preserves all generated frames in fixed-scale 144x112 cells with the existing action-family ground anchor and no baked VFX or gameplay authority.
- Added review-only Stage 5 boss jump assets: 32 fixed-scale directional body frames covering compression through rebound, plus a separate centered eight-frame forest-earth impact with lime core contact, stone/root shockwave, settling debris, and persistent crater. The animated body review previews integer arc offsets while the exact atlas remains origin-stable for future actor-root travel. Two direction-drifted right-profile landing cells are deterministically derived from their approved left-profile counterparts; no rejected replacement creature was retained.

## 2026-08-14 - Incoming Player Hitstop

- Added non-stacking hitstop when King accepts enemy damage. Incoming blows resolve the existing light/medium/heavy/devastating 18/30/45/65 ms presentation tiers from damage amount, so ordinary contacts stay quick while Armored Hog and future boss impacts read heavier. Red damage numbers, hurt bursts, camera feedback, sound, health authority, invulnerability, and damage values remain unchanged.

## 2026-08-13 - Stage 4 Armored Hog and Strength-Scaled Hitstop

- Added the approved stylized Armored Hog to all five Stage 4 waves without changing their 6/8/10/12/14 totals or eight-live cap. Its readable brace snapshots a straight charge, living-bark forehead reduces frontal damage while committed, side/rear hits remain full strength, and a completed or blocked charge creates a punishable daze.
- Completed coherent four-direction locomotion, brace/charge/crash, hurt/daze, collapse, and death art with one shared scale/baseline and every generated frame used. Added original hoof/brace/crash sounds plus an attributed CC0 boar vocal layer; the rejected realistic draft is recoverably archived and runtime-inaccessible.
- Added protected Armored Hog Hide (20%, sixth-miss cap) and Living Bark Plate (8%, twelfth-miss cap), distinct 24x24 icons, stable catalog IDs, pickups, persistence compatibility, and drop regression. No current recipe consumes them yet.
- Generalized outgoing hitstop into data-owned light/medium/heavy/devastating tiers (18/30/45/65 ms). Each hit callback is bound to its real emitting ability, same-frame crowd contacts remain coalesced, white hurt flash stays independent, and King Skill 4's final explosion receives the devastating tier.

## 2026-08-12 - King Skill 4 and Ground-Impact Presentation

- Added playable Stage 4 `Eastern Rot`: five existing-roster waves total 6/8/10/12/14 enemies under an eight-active stage ceiling, while Stages 1-3 retain four. Stage 3 now advances into Stage 4 after its Reliquary, Stage 4 banks and returns to Sanctuary, and a Level-4 expedition entry evaluates the Rootbound Hollow story/boss/discovery memories. Decision 083 reserves later explicit cap increases and a profile-backed Stage 6 horde step instead of a dangerous global no-cap rule.
- Baked a 24x14 Stage 4 ground whose Rootbound decay enters from the eastern/right edge: 63.1% living terrain, 32.7% Rootbound ground, and 4.2% deterministic mirrored transition cells. Eastern trees and ruin carry the rot while the western approach stays living. Added a review-only armored hide-bearing Forest beast contract; no unapproved enemy art, stats, drops, or palette swap is presented as playable.

- Rebalanced Stage 3 terrain from a centered 43.75% Rootbound mass into a restrained west-origin decay: 22.0% fully corrupted ground, 4.2% generated mixed root/grass transition cells, and 73.8% living forest. Restored the eastern trees to living presentation while preserving the western warning edge, central boss seal, collision, navigation, encounters, and loot flow. Stage 5 remains reserved for the fully sinister dead-terrain/dead-tree escalation.
- Added two visible but disabled character-menu tier previews after the four active skills: `Ultimate` and the separate stronger finisher tier `Reality Breaking`. They intentionally own no input, ability resource, cooldown, unlock, or save mutation.

- Accepted Decision 082 and implemented King's fourth skill as the approved ground-targeted giant spiritual sword: a 58-pixel 220% first crash, visible embedded resistance and automatic second drive, then a 104-pixel 300% AOE explosion on a 20-second cooldown. King stays committed and vulnerable; the first hit pins without displacement so normal enemies remain eligible for the delayed blast.
- Replaced the initial static white/cold-blue sword with one generated eight-frame 4x2 sword atlas: three formation poses, four embedded resistance/second-drive poses, and one dissolve pose. Every normalized `144x192` cell fixes the point at local y=188 while Godot retains physical descent, rebound, accelerated 20-pixel ground-clipped burial, and cleanup. The embedded point now overlaps the impact core by two pixels so the shader cutoff reads as burial rather than a severed tip. After owner review rejected the mismatched layered 6+4 ground package, replaced it with one visually consistent eight-frame 4x2 contact-to-crater atlas: contact, cracks, split plates, resistance, compression, drive, explosion, and settled crater; the last crater pose is lowered nine pixels to preserve its impact center. Runtime regression requires all sixteen sword/ground frames to play. Deterministic processing enforces exact cells, stable baselines, limited palette, nearest scaling, and binary alpha; rejected and retired assets are archive-only.
- Corrected repeated basic attacks bypassing the authored 0.21-second weapon recovery. One latest primary intent remains buffered, but primary-to-primary chaining now starts only after `attack_finished`; focused rapid-repeat, dash-to-attack, shared-buffer, and sword-style regressions protect the intended cadence.
- Made F9 enable session-only unlimited skill cooldowns for rapid skill presentation testing. The idempotent preset clears active cooldowns even when level/coins already match the debug values, clears each later cooldown at cast completion, updates the HUD announcement, and leaves targeting, active/recovery phases, normal ability resources, and saving boundaries unchanged.
- Generalized `GroundPointTargeting` from a Skill-3-specific adapter into an explicit `AbilityComponent` ground-targeting contract, preserving confirmation/cancellation and cooldown authority for both Pursuit and Skill 4. Added separate original formation, first-impact, and explosion cues plus gameplay-scale review captures and focused center/outer/outside damage regression.
- Accepted Decision 081 and generalized the narrow attack/dash buffer into one 0.8-second latest-intent combat rule for normal attack, dash, and equipped skills. `Sovereign Pursuit -> Riftbreak` now executes at the ability-finished boundary; stale input expires, cooldown-blocked input is rejected, targeting is never guessed, and committed contacts remain uninterrupted.
- Re-centered every Sovereign Pursuit ground frame horizontally as well as vertically, correcting the final crater's roughly seven-pixel left drift from King's foot position.
- Added Sovereign Pursuit's missing second VFX layer: a separate generated three-frame white/cold-blue power sheath follows King only during traversal, stays behind the body through an open center, and releases before the world-space landing effect. The hop and ground shatter now read as one powered action without coupling presentation to movement authority.
- Corrected owner-playtest regressions: Riftbreak now detaches from King at cast start so its residual crater stays in world space, and Sovereign Pursuit's six generated frames are normalized to one foot-contact baseline instead of jumping vertically between launch, impact, and crater poses.
- Added a brief presentation-only white/cold-blue landing shockwave to Sovereign Pursuit so the confirmed impact reads as a powered skill before the authored debris and crater decay. Damage, radius, traversal, invulnerability, and approved jump body frames remain unchanged.
- Preserved Sovereign Pursuit's owner-approved jump body frames while correcting effect chronology: launch now leaves a small fixed dust/pressure mark at takeoff, bright sword contact appears only at the actual landing, earth chunks throw outward, and a generated dark crater remains after recovery before fading.
- Rebuilt Pursuit into separate non-tonal launch and rock-impact cues and removed the generic technique sound from its travel phase. Reworked Riftbreak's cue toward earth/rubble noise and allowed its residual ground fracture to persist and fade instead of being cut off at recovery.
- Extended focused regression coverage for fixed launch position, landing-only impact, world-locked Skill 2/3 residue, shared ground anchoring, crater/residual lifetime and cleanup, separate audio wiring, damage, collision-safe traversal, and existing Skill 2 authority.

## 2026-08-11 - Simple King Reboot and Targeted-Skill Direction

- Implemented King Skill 3 `Sovereign Pursuit`: Skill `3` opens a 220-pixel ground-point reticle, primary attack confirms, right-click/Esc cancels freely, and King performs a collision-safe leap with invulnerability restricted to traversal. Landing resolves one 52-pixel 125% radial sword contact with outward knockback; the skill naturally sets up Riftbreak without hidden combo state.
- Added a dedicated normalized 6x4 Sovereign Pursuit body atlas, separate generated six-frame 192x192 royal-cross landing VFX, icon, original landing cue, player/loadout wiring, and focused regression coverage.

- Corrected the visible idle-to-Riftbreak model pop: Skill 2 no longer normalizes every direction to a blanket 28-pixel height. Down/left/right/up action rows inherit their real 27/26/26/28-pixel locomotion heights, and frames 0 and 5 embed the exact corresponding idle pixels so entry and exit retain identical size, center, silhouette, and baseline.
- Strengthened King's asset regression to compare every Riftbreak boundary frame pixel-for-pixel against its locomotion idle source in addition to checking atlas geometry, binary alpha, and y=30 baselines.
- Completed Riftbreak's first authored presentation pass: a dedicated six-pose-by-four-direction King slam sheet, fixed per-direction scale, exact y=30 boot baseline, binary-alpha 64x32 runtime cells, and phase timing that lands the damage window on the grounded contact drawing.
- Replaced the temporary code-drawn ring/cracks with a separate generated six-frame ground-rupture VFX family: contact spark, spreading fissures, circular shock ring, white-blue peak rupture, debris decay, and residual cracks. The 3x2 source is chroma-cleaned and normalized into binary-alpha 192x192 runtime cells driven by `AnimatedSprite2D` phase signals.
- Refreshed the Skill 2 icon and added an original 0.38-second steel/stone ground-slam cue. Extended focused coverage for both Riftbreak atlases, phase animation names, scale/baseline constraints, dedicated body/VFX selection, and audio wiring; presentation never owns damage or knockback, and all 62 smoke tests pass.
- Simplified King Skill 2 after owner review: replaced the temporary travelling Riftline with immediate self-centered `Riftbreak`, one 84-pixel 150% sword-power contact around King's feet, 6.5-second cooldown, and no targeting, jump, lift, invulnerability, endpoint, or hidden combo state.
- Extended `MeleeHitbox` with reusable radial-direction activation so every Riftbreak target receives knockback away from King rather than sharing one facing direction. Per-window target deduplication and normal damage authority remain unchanged.
- Replaced the line/endpoint proof with a minimal expanding white/cold-blue fracture ring and new radial-crack icon. Removed the obsolete ground-line targeting adapter, `request_cast_at()` seam, dynamic line/endpoint definitions, old icon, slot, test, and resources instead of retaining dead Skill 2 code.
- Added focused coverage for immediate self-area activation, exact radius/damage, outside-circle rejection, opposite outward knockback directions, King/Opaw presentation separation, hitbox cleanup, and loadout/menu truth.
- Accepted Decision 079 and replaced the planned Skill 2 leap with playable `Riftline Execution`: exact-angle pointer/right-stick ground targeting, 210-pixel range, world-collision clamping, free confirm/cancel flow, and grounded vulnerable commitment.
- Added a King-owned two-window Riftline scheduler: a 28-pixel-wide 90% travelling fissure, a genuinely inactive 0.12-second delay, then one 68-pixel 150% endpoint eruption with stronger final control and a 7.5-second cooldown.
- Added deterministic temporary path/crack/cross presentation plus an original code-native skill icon. The proof deliberately reuses King's stable body slash and suppresses the detached Opaw trail; final grounded slam body art, VFX, audio, and heavy feedback remain pending feel approval.
- Added focused targeting/timing/shape/loadout coverage and refreshed active-King and benched-Opaw regressions without altering Opaw's preserved ability data.
- Fixed Riftline Execution temporarily transforming King into Opaw: the preserved Consecutive Thrust body and lance observers now verify the active ability ID before hiding King's body or showing Opaw-only art. Riftline coverage protects the separation.
- Approved the Echoing Sever visual direction and replaced its code-drawn slash/rift proof with separate generated primary-cleave and delayed-echo boards, chroma-cleaned and deterministically packed into six 160x160 binary-alpha cells per family with `wind_up`, `primary`, `rift_hold`, and `echo` animations.
- Corrected the primary cleave's source-facing mismatch: its runtime cells are mirrored into the canonical +X basis before `AbilityPivot` rotates them to the confirmed 360-degree aim, while the already-forward delayed rift remains unchanged.
- Removed the stray rear normal-attack slash during Echoing Sever by suppressing Opaw's shared detached-weapon trail for King's integrated-sword ability; the dedicated cleave/rift VFX is now the only skill effect layer.
- Added an original deterministic 0.42-second magical fracture cue exclusively for Echoing Sever's delayed contact, replacing the pitch-shifted reuse of the ordinary sword swing.
- Added a presentation-only two-pixel nearest-cardinal recoil and settle on Echoing Sever's primary contact; it never moves King's authoritative `CharacterBody2D` or changes damage.
- Reworked the target hardware cursor into a compact white/cyan sword-point silhouette and moved its hotspot to the blade tip for precise confirmation.
- Upgraded Echoing Sever from four snapped directions to smooth 360-degree aiming: the wedge, confirmed hitbox, and VFX retain the exact pointer/right-stick angle while King's body intentionally selects the nearest available cardinal animation.
- Refined Echoing Sever controls after owner playtesting: Skill 1 now enters targeting only, left-click/right-trigger confirms, repeating Skill 1 is safely consumed, Esc/right-click cancels for free, walking preserves the preview, and dash cancels it before movement; confirmation never leaks into King's normal attack.
- Replaced the rotating smooth debug cone with a zero-node-rotation exact-angle pixel guide featuring restrained dark-blue fill, a bright exact far edge, sword-path curve, runes, player-center gap, stepped pulse, and a brief non-spatial direction-change flash.
- Added `CursorService` and three original 24x24 hardware cursor assets for normal play, interactive controls, and skill confirmation. Targeting restores the normal cursor on confirm, cancel, dash, defeat, or node exit without using a latency-bearing Sprite2D cursor.
- Accepted Decision 078 and replaced the sealed Crescent Sever placeholder with playable `Echoing Sever`: Skill 1 opens an explicit directional wedge, mouse/right stick aim smoothly, left-click/right-trigger confirms, and right-click/Esc cancels without starting cooldown.
- Added a King-owned two-window ability scheduler: 110% weapon damage on the primary cut, a genuinely inactive 0.30-second rift delay, then one 75% echo in the same snapshotted wedge. Dedicated tests protect cancel cost, aim priority, direction lock, exact strike count, timing, King loadout exposure, and Opaw's inherited generic ability path.
- Added fresh code-native Echoing Sever icon, targeting preview, rift/echo proof VFX, and two-pitch sword contact cues without reusing Piercing Rush art, data, or behavior. Final exact-grid skill body/VFX sheets remain explicitly pending owner feel approval.
- Removed the zero-reference rejected `king_core_sprite_frames.tres`, an unused atlas-anchor constant, and dead attack-direction/pivot branches after the centered slash correction. Retained all seven simple King animation families because live `PlayerAnimation` requests each one.
- Replaced King's owner-rejected weak four-pose slash with separate six-pose down/right/up strips, exact right-to-left mirroring, corrected chronological atlas packing, stable per-direction scale/baseline normalization, and two readable presentation frames per authoritative combat phase.
- Corrected the remaining idle-to-attack pop: attack art now uses an 88% weapon-aware scale, boot-only horizontal anchoring, a fixed body-node pivot, and midpoint frame selection so the second pose of every phase is actually visible instead of flashing for one instant.
- Rebuilt the isolated King review scene around exactly one cycling `AnimatedSprite2D`, matching the live player's one-body scene structure, and archived the rejected v1 source/cleaned pair outside active imports.
- Accepted Decision 077 and temporarily benched Opaw as the default presentation while preserving his complete compact/Wayfarer art, abilities, data, and regression coverage.
- Generated one focused simple King basic-slash board with the built-in image workflow, chroma-cleaned it, and extended the deterministic processor to emit a binary-alpha `256x128` atlas of `64x32` cells sharing locomotion's scale and foot baseline.
- Made King the active `player.tscn` identity with real idle/walk/basic-attack animations, safe locomotion-derived action aliases, hidden detached equipment sword art, retained cleave/contact authority, and a matching Character & Bag preview.
- Added a complete King development loadout whose four named skills remain honestly unequipped. F9 preserves those sealed slots, and Eira's Opaw awakening path now rejects non-Opaw characters.
- Added active-King, King-asset, benched-Opaw, character-animation, menu, melee, dash-buffer, sword-style, combat-feedback, audio, Sanctuary, archive-boundary, and startup regression coverage.
- Accepted Decision 076: replaced the unstable detailed visible-arm/shoulder-greatsword King with an owner-approved Opaw-complexity identity using chunky black hair, plain two-eye face, crimson scarf, compact navy/charcoal body, mitten hands, tiny feet, and one short broad straight signature sword.
- Preserved the approved identity and first source-only four-direction four-pose walking board under `art_source/generated/characters/playable/king/simple_reboot/`.
- Removed the rejected detailed King runtime sheets, previews, processors, tests, generated/cleaned sources, and review assets from active Godot paths. They remain recoverable under `art_source/archive/characters/playable/king/rejected_detailed_package_2026-08-11/`; Opaw was not changed.
- Approved explicit skill activation families for future implementation: line/wedge/cone and actor-dependent skills enter aim-preview mode; jump-smash/ground AOE uses a movable valid-range marker; cancel spends no cost/cooldown; instant activation is limited to self-AOE, aura, buff, defense, or naturally broad waves. No targeting runtime or playable King is claimed yet.
- Converted the approved simple 4x4 walking board into a reproducible binary-alpha `48x32` locomotion atlas with one shared scale and foot anchor, directional idle/walk `SpriteFrames`, an isolated four-direction preview, enlarged review sheet, and focused Godot smoke coverage. King remains non-playable.
- Audited every active Sanctuary NPC texture, `SpriteFrames`, scene, and script owner; all current Armskeeper, Skillkeeper, and Rootweaver assets remain live and were preserved.
- Archived the zero-reference `assets/characters/prototype/` folder and obsolete `assets/characters/sprites_24x32/` package—including a stale Thrall resource whose two texture dependencies were already missing—under `art_source/archive/characters/legacy_runtime_cleanup_2026-08-11/`. Runtime-boundary coverage now prevents those paths from returning.

## 2026-08-11 - King Core Locomotion and Side-Combo Art Package

- Completed King's exact-grid four-direction idle and walk presentation: four purposeful frames per direction in `64x64` cells, with authored down/left/up motion and exact mirrored right-facing side motion.
- Added separate integrated body and effect packages for the side-facing Opening Cut (8 frames), Reversal Cut (8), Horizon Break (10), and Falling Divide (12). The greatsword remains part of King's connected body silhouette; white/cold-blue crescents, charge sparks, horizontal burst, and impact fragments remain separate VFX layers.
- Used `128x96` body cells for grounded side attacks and `128x128` for Falling Divide so the overhead straight greatsword is not shrunk or clipped. The first obsolete `128x96` Falling Divide export was moved to the source archive.
- Added deterministic chroma cleanup inputs, `process_king_core_animation_assets.py`, consolidated body/VFX `SpriteFrames`, an isolated `AnimatedSprite2D` preview, enlarged review boards, metrics, and `king_core_animation_asset_smoke.gd` coverage for animation counts, loop modes, preview ownership, nearest-neighbor filtering, and exact mirrors.
- Verified the package under Godot 4.7 with `KING_CORE_ANIMATION_ASSET_SMOKE_OK`. King is still not playable; front/back attacks, roster state, tap/hold authority, contact shapes, and damage remain pending owner motion approval and later implementation.

## 2026-08-02 - Attack Direction Integrity and King Redesign Contract

- Accepted the replacement integrated front/down King source for processing and normalized only that sheet into four distinct `64x64` frames. The `256x64` runtime strip uses one 36-pixel full-silhouette scale, y=58 feet, a centered footprint, binary alpha, no retained magenta matte, and a shared 48-color maximum.
- Added a single-animation `idle_down` `SpriteFrames` resource, isolated `AnimatedSprite2D` preview, repeatable processor, enlarged nearest-neighbor review sheet, per-frame metrics, and focused Godot smoke coverage. No left/right/up sheet, gameplay controller, roster state, or combat behavior was added.
- Owner review rejected the layered/programmer-drawn King idle because correcting sword geometry destroyed the approved visual quality. Removed its runtime sheets, `SpriteFrames`, preview scene, processor, and test from active project paths and preserved the failed package under `art_source/archive/characters/playable/king/rejected_layered_idle_runtime/`.
- Returned King production to the preferred integrated greatsword turnaround and adopted a strict one-sheet-at-a-time gate. Generated only one four-frame front/down idle source on chroma for review; it is not cleaned, sliced, imported, or described as runtime-complete.
- Corrected King's idle weapon after owner markup proved that the apparently straight generated blade and detached handle occupied parallel/offset rails. Rejected integrated v1-v3 candidates were removed from runtime and preserved only in the Godot-ignored source archive.
- Rebuilt the idle pipeline around a clean generated body-only board plus deterministic runtime body/sword layers. Every sword now places blade tip, blade core, guard, wrapped hand, grip, and pommel on one exact 45-degree axis; the combined sheet remains the `AnimatedSprite2D` preview input.
- Extended `king_idle_asset_smoke.gd` to load both layer sheets, validate all sixteen recorded sword axes, sample every tip-to-pommel axis pixel for gaps, and retain the existing alpha/palette/baseline/mirroring/atlas checks.
- Generated and corrected King's first production idle source so the up/back pose now visibly bends the sword-side arm into a shoulder-height hilt grip while the off-hand hangs naturally.
- Added deterministic King idle processing into a 256x256 exact-grid runtime sheet: 64x64 cells, four purposeful frames for each `down/left/right/up` row, frozen 32-pixel body target, y=57 foot baseline, x=31.5 geometric center, exact mirrored sides, binary alpha, no chroma residue, and a 20-color maximum.
- Added an idle-only named `SpriteFrames` resource and isolated `AnimatedSprite2D` preview scene. King is not yet selectable and the live Opaw player, skills, scenes, and saves were not changed.
- Added source provenance, a 4x review sheet, per-frame metrics, the reusable builder/processor, and `king_idle_asset_smoke.gd` coverage for dimensions, authored frame variation, safe margins, alpha, matte residue, palette, mirroring, atlas regions, animation loops, and preview anchoring.
- Accepted Decision 075 after owner review: replace universal eight-frame idle/walk quotas with purposeful ranges, store each coherent action family in its own exact-grid direction-row sheet, and reserve larger frame budgets for attacks and skills that need more authored phases.
- Approved King's greatsword Opening Cut composition, white-hot blade, cold-blue crescent, particles, recoil, and recovery. Marked the v1 turnaround's up/back grip as rejected because its lowered sword-side hand makes the blade look mounted across the back; production requires a bent arm and visible shoulder-height hand-to-hilt connection.
- Added durable rejection checks for per-frame scale/center/baseline/weapon drift and source-background contamination. Runtime processors must remove chroma before resampling, emit binary alpha, reject matte-color fringe such as leftover lime pixels, and preview sheets against contrasting gameplay backgrounds.
- Accepted Decision 074: King now carries a broad signature greatsword on his weapon-side shoulder, with the hilt close to his body and the blade angled outward away from his head. The change supersedes Decision 073's modest-sword and `48x48` armed-cell clauses while preserving the approved coarse body identity.
- Added a four-direction greatsword turnaround reference and an eight-beat Opening Cut composition proof. The latter overcharges the physical blade into a thick white-hot, cold-blue-edged crescent tied to the sword path instead of a detached thin wind slash.
- Clarified that horizontal action strips are valid Godot sprite sheets only after deterministic normalization to exact equal cells. The new wide references are deliberately cataloged as non-runtime proofs; production targets `64x64` armed cells and separate body/weapon and VFX layers.
- Marked the earlier modest-sword motion boards as superseded provenance rather than runtime-normalization candidates.
- Established King's top-down three-quarter cardinal pose rule and raised the planned animation budget to purposeful eight-frame idle/walk loops, ten-frame Opening/Reversal cuts, and larger separately owned finisher/skill sequences instead of two-or-three-frame shortcuts.
- Generated and preserved four non-runtime King motion proofs: eight-frame down idle, eight-frame right walk, ten-frame `PRE_ATTACK -> Opening Cut`, and ten-frame Reversal Cut. Raw chroma sources and binary-alpha intermediates remain source-only pending exact-cell normalization and green/smear cleanup.
- Reworked the provisional King skill variety around distinct targeting: Crescent Sever remains immediate-direction, Riftfall Judgment becomes a ground-targeted leap/impact/crack, Sovereign Pursuit becomes an enemy-targeted crossing combo, and Worldsplitter remains a committed forward-line cinematic ultimate. None is implemented yet.
- Accepted Decision 073 and preserved the owner-approved King direction reference: an actual coarse four-direction gameplay sprite identity with compact visible limbs, chunky black hair/pale streak, navy/charcoal/crimson clothing, restrained armor, and a modest straight sword. The enlarged reference is cataloged as provenance, not falsely claimed as an exact `48x48` runtime sheet.
- Fixed the reported opposite-movement attack failure by locking `SwordPivot` to `MeleeAttackComponent`'s accepted direction for the whole attack. Later movement facing is cached and applied after `attack_finished`, so body/weapon presentation and the authoritative hit shape cannot diverge mid-swing.
- Extended `melee_combat_smoke.gd` with the exact down-attack/up-movement regression: center and visible-edge targets in the accepted lane take damage, the opposite target does not, and the pivot adopts the queued facing only after recovery.
- Verified the repair alongside player controls, dash-to-attack buffering, ability buffering, sword styles, Piercing Rush, and Consecutive Thrust under Godot 4.7.
- Accepted Decision 071: King becomes the planned protagonist and first character-owned combat baseline; visible signature weapons belong to characters, while equippable essences/relics carry stats and traits.
- Added the King/roster/real-combo/cinematic-ultimate/essence migration contract and updated the story canon around King's family and the gods' hunger for emotional resonance.
- Accepted Decision 072 after owner review: Opaw and his current skills remain supported playable roster content rather than an archive target. King is additive, young-prime, sword-based, and mechanically distinct.
- Proposed King's immediate pre-attack, rapid tap-buffered three-step chain, hold-to-charge Falling Divide, tiered recoil/shake, and the current varied-targeting four-skill kit: Crescent Sever, Riftfall Judgment, Sovereign Pursuit, and Worldsplitter: Last Horizon.
- Paused Forest crafting Segment 5 output work until its crafted equipment conforms to the essence/relic contract. No runtime King sprites/animations, roster code, save-schema change, item relabel, or active Opaw deletion is claimed in this slice.

## 2026-08-01 - Rootweaver Layout, Forest Equipment Phases, and Enemy Footprints

- Replaced Nema's cramped front-facing service board with a preserved/generated screen-left three-quarter source, chroma-clean intermediate, and deterministic binary-alpha `192x96` runtime sheet. Every `48x48` frame now keeps complete boots, connected handheld tools, at least four transparent pixels below the feet, and safe horizontal margins.
- Moved the Living Rootforge from `(352, 704)` to the west-mid garden at `(240, 610)`, moved Nema to its screen-right work side at `(342, 630)`, and shifted the southwest tree away from the service silhouette. The central avenue remains clear and the expedition portal remains the northern/top landmark.
- Changed the read-only Rootforge's planned seal wording to `STAGE V CORE GEAR SEAL REQUIRED` and `STAGE VIII ACCESSORY SEAL REQUIRED`; no crafting transaction or later-stage unlock authority was activated.
- Approved the Forest category cadence: Stage V unlocks weapons/chest/gloves-or-bracers/boots, Stages VI-VII introduce accessory components/blueprints, Stage VIII unlocks standard accessories, and Stage X unlocks relic/signature crafting. Two generic accessory slots accept jewelry families; bracers remain a gloves-family item.
- Added data-owned movement and crowd-separation radii to `EnemyDefinition` plus `EnemyFootprintSystem`, synchronizing per-instance circular movement collision, navigation radius, and optional separation detection for Rootling, Mireling, Thrall, Bramble Spitter, and Rootbound Husk while preserving independent hurtboxes and attack shapes.
- Added `enemy_footprint_smoke.gd`, updated Rootweaver service coverage/visual capture, and recorded Decisions 069-070.

## 2026-07-29 - Rootweaver Nema and the Living Rootforge

- Clarified that the Rootweaver is a friendly Sanctuary crafting artisan, while the Stage IV monster remains a separate unnamed armored hide-bearing Forest beast.
- Initially explored `Rootweaver Nema` as an elderly human craftswoman before owner review redirected the identity toward a more charismatic blacksmith fantasy.
- Generated and preserved non-runtime character/portrait/workshop concept boards through the built-in image workflow; the proposal records each exact prompt and runtime simplification boundary.
- Rejected the first Rootweaver board after owner review found its anatomy and workshop too realistic for Sanctuary, then generated and cataloged a compact v2 using Eira and Orren's actual 48x48 sheets as proportion/style references.
- Replaced the elderly v2 with the approved attractive adult female grove-smith v3: auburn side braid, moss forge apron, root hammer and gold-thread tongs, plus an organic anvil-and-brazier Living Rootforge distinct from Orren's ordinary steel shop.
- Generated an eight-frame actor source board, then added a deterministic processor that exports Nema's binary-alpha 192x96 idle/work sheet, reusable 96x96 portrait, and 176x144 Rootforge from preserved sources.
- Added Nema's colliding dialogue scene, optional reusable `DialogueNpc` portrait metadata, timer/signal-driven forge-work presentation, and an original deterministic wood/stone/root strike cue.
- Placed the colliding, Y-sorted Living Rootforge and Nema on the southwest Sanctuary lawn while preserving the central avenue and front approach.
- Added `RootforgeMenu`, a paused filterable preview of all four current recipes, discovery state, milestone seals, and exact owned/required ingredients. Its action remains disabled and it cannot consume materials, discover recipes, fabricate outputs, or save state.
- Recorded Nema's visible integrated arms/tools as a work-animation-specific NPC exception without changing Opaw's armless contract; ADR 068 protects the service and authority boundary.
- Added dedicated art/scene/menu/no-mutation regression coverage plus world/menu review captures. Crafting transactions, recipe outputs, and seal progression remain Segment 5.

## 2026-07-29 - Sparse Loot and Milestone Reward Cadence

- Reduced ordinary Forest materials to 15-25% common and 5-10% secondary rolls, with bad-luck protection on the sixth and twelfth unresolved attempts respectively; Rootbound Husk boss guarantees remain unchanged.
- Added explicit direct-portal versus stage-chest completion modes to `EncounterController`. Stages I-II now commit collected expedition loot and open their portals directly, with obsolete Stage I-II clear tables and chest wiring removed.
- Retuned the Stage III Rootbound Reliquary to a modest guaranteed pool of ordinary Stages I-III materials on first clear/replay. It grants no blueprint or crafting-category unlock; Husk Heartwood and Rootbound Core remain separate guaranteed enemy-profile drops.
- Approved the III/V/VIII/X milestone cadence: Stage III regular-material payout, Stage V permanent weapon/armor crafting seal plus repeatable catalyst, Stage VIII accessory-material mini-boss payout, and Stage X permanent accessory/relic seal plus repeatable signature catalyst. Later milestones remain planned.
- Reassigned Rootfiber Wraps/Huskbound Guard to the planned Stage V milestone and Mireward Charm/Thornward Clasp to Stage X; recorded permanent seals versus consumable repeatable catalysts in ADR 067.
- Updated focused loot, stage configuration, direct-banking, chest-tier, rollback, and encounter regressions.

## 2026-07-29 - Forest Loot, Pickups, and Stage-Clear Chests

- Completed Forest production Segment 3 by connecting all five current enemy scenes to their immutable ecology-linked drop profiles through centralized `LootService` resolution.
- Rebalanced ordinary enemy materials from universal common drops to 20-55% profile-owned rolls with short persisted bad-luck caps. Mire Resin/Root Fiber are 45%, Forsaken Cloth 50%, Barbed Seed 55%, and optional secondaries 20-28%; the Husk still guarantees both Husk Heartwood and Rootbound Core.
- Upgraded material pickups with a short launch hop, wobble/hover idle, half-second readability window, and accelerated magnetic auto-collection to the injected player recipient while retaining contact collection as a fallback.
- Moved reward chests into the stage's Y-sorted Actors owner, added a small solid footprint plus accessible interaction range, and added a reusable presentation-only rune/spark arrival effect. Claiming releases the footprint before the portal opens.
- Added the 72x64 closed/open Rootbound Reliquary tier for Stage III, with preserved generated/clean/review provenance; Stages I-II retain the ordinary 64x48 Forest Cache. Tier selection never owns reward contents.
- Added world-space material pickups with pop/glow/quantity presentation, contact collection, upper-right HUD toasts, combined stacks, optional-drop bad-luck protection, and a guaranteed Rootbound Core from the Husk.
- Added a reusable closed/open Forest reward chest to Stages I-III. The final wave now spawns the chest; explicit `F` claim grants a guaranteed non-empty first-clear or replay table and only then opens the existing portal.
- Added `LootState` for versioned first-clear claim IDs and protection counters, activated the save profile's `stage_claims` extension with legacy-empty compatibility, and made New Journey reset it.
- Added expedition reward baselines: material/recipe/claim deltas commit at successful chest claim and roll back on defeat, restart, Return to Sanctuary, or a defensive unclaimed Sanctuary return.
- Produced ten distinct binary-alpha 24x24 Forest material icons and a 64x48 closed/open Forest chest pair from preserved built-in image-generation source boards; connected every material definition to its runtime texture.
- Added atomic material batch grants, first-clear blueprint/discovery delivery, replay reward selection, and readable chest/material reward summaries without activating crafting outputs.
- Fixed pickup collection to defer `Area2D.monitoring` changes during physics overlap callbacks.
- Added focused loot-resolution coverage and expanded material, stage, save-profile, disk-recovery, safe-milestone, Character & Bag, and HUD validation.
- Recorded the finalized probability, pickup, boss-guarantee, collision, and chest-tier boundary in ADR 066.

## 2026-07-29 - Character and Bag Inventory Redesign

- Replaced the oversized Gear/Armory card layout with a themed `CHARACTER & BAG` page built around Opaw's canonical live sprite and detached weapon pose.
- Added seven paper-doll equipment positions, a compact 12-by-2 bag grid, five item filters, disabled empty slots, equipment state badges, material quantities, and mouse/controller tooltips.
- Connected the grid only to real `WeaponInventory` ownership and nonzero `MaterialInventory` quantities. Equipment counts toward the displayed 24-slot capacity; crafting materials remain in a capacity-free pouch.
- Extended the shared detail panel with read-only material family, rarity, quantity, source, and description presentation while preserving explicit safe weapon equip through `Player`.
- Added family-glyph fallbacks for materials whose approved runtime icons have not been produced, retained honest empty future categories, and documented Sanctuary stash/discard/final icon work as pending.
- Moved the live Character & Bag preview grip left so the sword tip stays outside Opaw's face without changing gameplay weapon anchors.
- Added non-saving F9 material samples through `MaterialInventory` so every current material/filter/detail state can be tested before normal loot acquisition exists.
- Removed the unreferenced oversized `EquipmentItemCard` scene/script after the compact slot replaced it, and kept design mockups outside Godot imports.
- Updated character-menu and weapon-shop regression coverage, validated 960x540 modal bounds, and recorded ADR 065.

## 2026-07-29 - Forest Material and Crafting Data Foundation

- Finalized ten stable ecology-linked Forest materials for Mireling, Rootling, Forsaken Thrall, Bramble Spitter, and Rootbound Husk sources.
- Added validated immutable material, material-stack, enemy drop-profile, stage loot-table, and deterministic recipe Resources plus global material/recipe catalogs.
- Authored five current-enemy drop profiles, three Stage I-III clear-reward tables, and four starter Forest recipe blueprints without activating reward rolls, chests, crafting, or equipment outputs.
- Added profile-backed `MaterialInventory` and dedicated `RecipeDiscovery` authorities; New Journey resets both while safe-point Continue and backup recovery reconstruct them.
- Preserved existing version-1 profiles by treating their previously reserved empty crafting extensions as valid empty state.
- Added focused validation for stable IDs, duplicate rejection, invalid quantities/costs, boss guarantees, recipe references, inventory mutations, snapshot reconstruction, disk rotation/recovery, and atomic invalid-profile rejection; recorded ADR 064.

## 2026-07-29 - Safe-Point Save and Continue

- Completed the first single-profile persistence slice at `user://battle_of_gods_profile.json`, preserving XP, coins, current HP, story memory, awakened Skill 2, weapon ownership, and equipped weapon across application restarts.
- Added validated temporary JSON writes, previous-primary backup rotation, corrupt-primary fallback, and automatic repair from the valid backup.
- Added safe autosaves on Sanctuary entry, Sanctuary weapon purchase/equip, Eira awakening, and post-record stage clear. Continue always resumes in Sanctuary rather than serializing active combat.
- Prevented the F9 testing preset from overwriting legitimate autosaves for the remainder of its debug session.
- Added a compact title Continue action with valid-save focus, a disabled no-save state, and confirmation before New Journey replaces an existing autosave.
- Suppressed production-path persistence during headless validation unless a test explicitly installs an isolated `user://` path.
- Added disk, backup recovery, safe-milestone, title Continue, and New Journey protection coverage; recorded ADR 063.

## 2026-07-26 - Versioned Core Save-Profile Schema

- Added `SaveService` as the profile-schema coordinator and registered it after the existing state authorities.
- Added explicit version-1 snapshot validation/restoration for run XP, coins, current HP, weapon ownership, and per-character equipped weapon while composing the existing story snapshot.
- Reserved extension seams for future material inventory, recipe discovery, stage claims, and regional progress without implementing those systems.
- Added focused validation for full profile reconstruction, incompatible nested-version rejection, and prevention of partial live-state mutation.
- Disk files, autosave, backup/recovery, migration, and title-screen Continue remain intentionally unimplemented for the next Segment 1 slice.

## 2026-07-26 - Forest Loot, Crafting, and Regional Material Design Lock

- Approved the long-term Forest loop as Fight -> Loot -> Craft -> Build -> Master -> Advance, keeping Stages 1-10 replayable through purposeful material acquisition and later Hunt contracts.
- Defined ecology-linked drops for the current forest enemies and provisional Stage 4-10 enemy/material roles, including the Stage 10 regional signature core.
- Locked deterministic crafting, non-empty stage-clear chests, a separate Rootweaver/Grove Artificer Sanctuary service, bounded regional Mastery, and Save/Continue as the required first implementation segment.
- Established reusable material icon families across future regions: shared silhouettes and container templates may recur, but each distinct material receives its own flattened runtime art, data identity, name, contents/glyph, and gameplay purpose rather than `Leather++` recolors.
- Added ADR 062 and the complete segmented design plan. No gameplay code, scene, save file, loot table, recipe, NPC, or runtime asset was added by this documentation-only change.

## 2026-07-26 - Early Progression and Iron Economy Retune

- Stretched cumulative Level 1-10 thresholds to `0/150/400/750/1200/1750/2400/3150/4000/4950`, with each step costing 100 XP more than the previous step.
- Stage I's unchanged 304 XP now ends at Level 2, cumulative Stage II reaches Level 3 at 692 XP, and the complete current forest arc reaches Level 4 at 872 XP.
- Raised Iron Sword from 18 to 90 coins. Stage I's 46 coins can no longer buy it; the complete implemented forest arc supplies 144 coins.
- Preserved enemy rewards, the free Ashwood fallback, explicit non-auto-equip purchase behavior, Level-3 Eira awakening, and F9's definition-driven Level-10 shortcut.
- Updated progression, skill-awakening, equipment-catalog, debug-preset, and shop transaction coverage.

## 2026-07-26 - Starter Cleave, Overhead Level-Up, and Clustered-Hit Pass

- Tightened Balanced Slash from 62x108 to a 58-pixel-forward, 96-pixel-wide beginner-sword fan and reduced its matching trail width while preserving center, visible-edge, and tip contact.
- Confirmed the existing data contract already supports weapon-specific cleaves: each future short sword, greatsword, axe, scythe, or other family may supply an independent authoritative shape and presentation style without player-controller branching.
- Removed the center-screen level/vitality banner. Level gain now produces only a small low-opacity glow around Opaw, a rising overhead `LEVEL N` label, and the existing restrained chime.
- Coalesced normal-swing camera, impact audio, and light hitstop once per swing instead of once per contacted enemy; every target retains its own flash, damage number, and burst.
- Shortened light hitstop to 25 milliseconds and retained a separate 40-millisecond heavy tier for Consecutive Thrust's finisher.
- Added regression coverage for the tightened cleave, family-specific shape/style swapping, compact overhead level feedback, and four-target shared-feedback behavior.

## 2026-07-26 - Combat Integrity, Run Vitality, and Stage III Routing

- Expanded Balanced Slash into a convex 62-pixel-forward, 108-pixel-wide authority fan and made the visible trail read both reach and half-width; centered and side-edge contacts now receive the same single hit.
- Added configurable navigation bake clearance, set Stage III to 20 pixels for the Rootbound Husk's 16-pixel body, and protected the central-seal route with full-footprint path sampling.
- Inserted a 20-pixel effective semantic gap between dash and Skill 1 while retaining the compact fixed-size action controls.
- Raised Opaw to `140 + 12 per gained level` maximum HP, reaching 248 at Level 10. Current health now survives stage and Sanctuary transitions and regenerates at 1 HP per second after five damage-free seconds.
- Retuned enemy damage against the larger health curve: Mireling 8, Rootling 10, Forsaken Thrall 18, Bramble Spitter 12, and Rootbound Husk 18 before its authored burst multiplier.
- Expanded melee, Stage III, HUD, scene-transition, run-session, vitality, and enemy-definition regression coverage.

## 2026-07-26 - Compact UI, Vitality, and Combat-Reach Pass

- Rebuilt the lower HUD as one centered themed action tray with five fixed `52x48` icon-first controls, preventing dash/skill overlap; renamed the visible top-right action to `MENU [ESC]`.
- Reduced Active Skills cards to compact title/status selectors and retained full copy in one detail panel, eliminating Skillkeeper modal overflow. Added current/max vitality to the character header and aligned its front-view sword preview with the body-connected gameplay pose.
- Corrected the down-facing detached sword pivot so the hilt visibly meets Opaw's left torso edge and the tip rises outward toward screen-left instead of leaning into his head or floating beside him.
- Added `PlayerVitalityDefinition`/`PlayerVitalityComponent`: Opaw now has `100 + 8 per gained level` maximum HP, reaching 172 at Level 10 before future armor bonuses.
- Added a world-space gold/spirit level aura, dedicated `LEVEL UP` vitality banner, and original deterministic UI chime.
- Moved normal melee reach into `WeaponDefinition`; Balanced Slash now uses a reusable `52x36` cleave polygon with a matching longer inner trail and translucent white-blue outer slash band.
- Raised and tightened the detached side grips and corrected the front-view sword hand. Future greatswords, axes, and scythes may supply distinct shapes and presentation through the same weapon contract.
- Widened Piercing Rush from `128x30` to `128x40` and Consecutive Thrust from `128x26` to `128x44` without changing their damage, timings, cooldowns, or defensive rules.
- Expanded progression, character-menu, HUD-layout, weapon-style, animation, and active-skill regression coverage.

## 2026-07-26 - Pre-Stage-IV Progression, Equipment, and Combat-UI Pass

- Rebalanced Opaw's cumulative level thresholds to `0/100/250/450/700/1000/1350/1750/2200/2700`; the authored 304 XP in Stage I now finishes near Level 3 instead of Level 7.
- Added Eira's normal free Consecutive Thrust awakening at Level 3, clear `AWAKEN SKILL • FREE` UI wording, session-only story memory, and cross-scene loadout restoration.
- Made Consecutive Thrust invulnerable for its full cast and explicitly cancelable into dash while retaining its seven hits, 225% total damage, 128x26 lane, and five-second cooldown.
- Changed owned weapon cards to selection-only previews and added explicit Equip buttons in both Orren's shop and the Character detail panel. Valid swaps paused during a committed action now apply at the next safe idle frame.
- Routed pointer-bound basic attack through unhandled input so native skill/dash/menu buttons consume clicks first; added a clickable dash cooldown slot, top-right Options button, larger vitality panel, clearer level wording, and slightly smaller skill slots.
- Rebuilt the Rootbound Husk cue as separate woody telegraph/creak and snapping-root eruption WAVs with a low earth layer, driven by dedicated attack signals.
- Rebuilt the canonical Mireling `SpriteFrames` resource after validation exposed `dead_left` pointing at locomotion art; every collapse direction now uses the authored action sheet again.
- Added focused Eira-awakening and HUD-action smokes; expanded progression, weapon, Consecutive Thrust, Husk audio, and Sanctuary route coverage.

## 2026-07-26 - Rootbound Hollow Living-Forest Decay Pass

- Refactored Stage III from a nearly total wicked treatment into a dual-source dying forest: 147 of 336 cells (43.75%) use Rootbound terrain and 189 cells (56.25%) retain living forest.
- Concentrated corruption around the ritual arena and Rootbound seal, then extended irregular tendrils into the southern approach through mossy dirt, grass/dirt blends, and root-scarred living tiles.
- Extended `AuthoredGroundLayout` to support mixed TileSet sources through `Vector3i(x, y, source_id)` legend entries while preserving all existing `Vector2i` layouts.
- Registered the shared verdant atlas as source 1 in Stage III's TileSet, rebaked the editable scene cells, and added focused ratio/source validation.
- Hardened the ground bake tool so encounter-owned gated-wave overrides are reasserted before packing; restored and verified Stage III's Wave 2 dialogue gate.

## 2026-07-23 - Authored Forest TileMaps and Rootbound Hollow Environment

- Replaced the four-tile seeded-random combat ground with two organized sixteen-tile atlases: a shared bright-forest set for Stages I-II and a dedicated maroon/violet Rootbound Hollow set for Stage III.
- Added `AuthoredGroundLayout`, editor-visible `authored_ground.gd`, and a bake tool that stores exact cells in each stage scene. Runtime now uses editable baked TileMaps and performs no random terrain fill.
- Re-composed Stage I as a processional path into a paired shrine court, moved its path-blocking tree, and removed the former loose-statue arrangement.
- Re-composed Stage II around one central Broken Heart plaza with a split approach, removing the duplicate west/east statues while keeping trees as organic grove structure.
- Built Stage III's root-scarred approach and ritual arena, added four blighted edge trees, and introduced a dedicated transparent Rootbound arena seal with collision and navigation cutout ownership.
- Organized active forest textures under shared and Rootbound Hollow runtime folders; preserved generated source/clean art and real-camera review captures outside Godot imports.
- Expanded environment, Stage II, and Stage III smoke coverage for authored layout/TileSet ownership, exact cell counts, landmark identities, and navigation-aware props.

## 2026-07-23 - Rootbound Hollow Reveal and Enemy Portraits

- Connected the playable forest sequence end-to-end: Stage 2's clear portal now advances directly into The Rootbound Hollow, while Stage 3 retains the post-mini-boss return portal to Sanctuary.
- Confirmed Stage 1 still contains exactly six wave resources and 30 total enemies; reinforcement and clear announcements are presentation events rather than a seventh wave.
- Replaced chapter-like Sanctuary labels with Stage I-IV hierarchy and renamed Stage III from `Ashen Pilgrimage` to `The Rootbound Hollow`, including stable IDs, requirements, arrival text, and mini-boss description.
- Reworked Stage III's approach into ten Rootlings released under the unchanged four-active-enemy cap, followed by a reusable inter-wave gate and a solo Rootbound Husk finale.
- Added a short skippable Husk introduction after the brood falls. Dialogue owns pause safety, includes the Husk portrait, releases the encounter on complete or skip, and prevents the mini-boss wave/music from beginning behind the modal.
- Generated and normalized reusable transparent 96x96 portraits for Rootling, Rootbound Husk, Mireling, Forsaken Thrall, and Bramble Spitter; preserved full source and cleaned intermediates outside runtime imports.
- Extended `DialoguePanel` with an optional portrait slot while retaining portraitless NPC calls, and expanded Stage III smoke coverage for brood count, active cap, gate configuration, portrait display, paused safety, and skip/resume behavior.

## 2026-07-23 - Rootbound Husk Attack and Pixel Contracts

- Replaced the original long-antler Rootbound Husk with a broad stump-guardian redesign across locomotion, six-stage root-command attacks, hurt/recovery, and compact defeat while preserving controller-owned attack timing, hitboxes, and six-beat ground-root VFX.
- Rebuilt side walking around individually reviewed contact A, passing A, opposite contact B, and passing B poses. Foreground/background legs now exchange forward/back positions while arms counter-swing; the assembler fixes one source-row scale and the processor derives every opposite side frame by exact mirroring.
- Fixed a visible 40-to-56-pixel side-walk size pop caused when debris filtering removed disconnected pieces from the direction-board contact source. Contact A now comes from the complete approved side strip; all four side-walk silhouettes and the neutral walk/cast/reaction references retain the 56-pixel body-height contract, protected by the focused boss smoke.
- Restored the clipped `walk_up` crown by recovering each connected up-facing actor through a bounded source-row overlap, and recovered complete cast limbs that crossed ideal generated cell boundaries without changing the approved body design.
- Replaced the visually stale root-command body revealed by the editor with a new v4 six-stage board matching the final stump-guardian walk model in all four directions. The assembler now recovers and normalizes every raw root-attack actor into an exact 6x4 source grid before runtime processing.
- Replaced the two down-active poses that turned into side profiles with dedicated front-facing root-command frames matching the approved `walk_down` identity, and added a symmetry smoke so down-facing attacks cannot silently rotate sideways again.
- Removed obsolete reaction poses from the active animation set, kept `hurt_*` on approved final-model root-command frames, and preserved the manually authored four-frame directional `dead_*` sequences. Death playback now fits the Husk's 0.6-second cleanup window so the full collapse appears before cleanup.
- Renamed every root-command body animation to `root_attack_wind_up_*`, `root_attack_active_*`, and `root_attack_recovery_*`; permanently deleted every former `cast_*` animation, cast-named Husk asset, stale import cache, and retired Husk model archive so the editor exposes only authoritative content.
- Added the reproducible v4 body assembler, complete-component retention, sheet-specific debris rejection, raw mirror verification, and expanded boss smoke coverage. No former Husk body package is retained as rollback material.
- Archived the asymmetric v2 source/intermediate and expanded the focused boss smoke to protect canonical left/right atlas-row wiring.
- Fixed editor parsing of the new attack-profile type by using a direct script preload, moved the damage-revealed health bar above the Husk's antlers, and expanded the focused smoke to protect both contracts.
- Replaced the gliding v1 walk with the superseded original-body fixed-scale cycle; the later stump-guardian redesign above now owns the active four-step contact/passing gait.
- Replaced the four-frame tree-like eruption with six ground-owned beats: crack, spread, bulge, spear, peak, and collapse. VFX now sit unrotated on the ground plane instead of near horizontal hand height, while authoritative 112x20 lanes and attack timing remain unchanged.
- Moved superseded v1 walk/VFX sources and the old `64x64` walk runtime sheet into the Godot-ignored archive after confirming no active references.
- Replaced the mini-boss's strict attack alternation with a dedicated data profile: a quick Root Spear, a slower three-lane Root Fan whose warned center erupts before its sides, a telegraphed point-blank Root Burst, and a modest faster/fan-heavier second phase below half health. The focused tune raises health to 280 and damage to 12 while retaining Boss control resistance and the four-enemy cap.
- Layered the Husk's enemy-specific root impact with a quiet pitched-down ground rumble, added restrained camera response to root eruptions, and moved its music/SFX into `miniboss` and enemy-specific audio folders.
- Rebuilt Mireling around the newly approved cute forest-slime model across all directions and states: 18-pixel idle/hop frames plus four-frame body-slam and collapse sequences in fixed-scale `48x32` action cells. Removed the mismatched legacy model, its embedded scene resource, original sources, and archived 24x24 sheet rather than preserving another confusing rollback. Leap gameplay authority remains unchanged, and leap/landing players use the dedicated `SFX` bus.
- Added a 0.85-second dash reuse cooldown independent from recovery, preserving attack cancels while preventing immediate repeat-dash invulnerability.
- Expanded focused smokes for Husk burst selection, health/audio/death timing, Mireling locomotion, dash cooldown, and Stage 3 mini-boss routing.
- Added the character-animation pixel contract, updated the Husk processor to use rounded proportional source-grid boundaries, rebuilt all active Husk sheets, and verified every walk/reaction/root-attack cell is contained and single-component. Rejected body material was later permanently deleted after final approval.

## 2026-07-22 - Rootbound Husk Native Animation Rebuild

- Regenerated the earlier Rootbound Husk root-command and reaction boards around one stable bark body, antler silhouette, lime chest core, body scale, and foot baseline; the rejected root-command body was later replaced and permanently deleted.
- Replaced per-frame Python normalization and manual `Sprite2D.frame`/Tween loops with a reproducible Godot fixed-scale processor, generated body/VFX `SpriteFrames`, and named `AnimatedSprite2D` animations using wider cast cells instead of actor shrinkage.
- Recovered the left active-cast hand across its generated source-cell boundary, removed detached foot/head debris from right-facing walk/cast/hurt frames, centered the down defeat pose, and added strict overflow rejection plus one stable scale per direction row.
- Moved root telegraph and eruption presentation beneath actor silhouettes without changing the snapshotted 112x20 Root Spear or alternating three-lane boss authority. Rootbound Husk, Stage 3 encounter, and expedition-unlock smokes pass.

## 2026-07-19 - Distinct Opaw Damage and Dash Audio

- Replaced the generic player-hurt clip with an original short cloth/body impact used only after accepted damage, so it no longer reads as a Thrall attack.
- Replaced the synthetic dash burst with artisticdude's curated CC0 `swish-4.wav` at restrained volume, then archived all rejected generic/synthetic dash candidates outside runtime imports. Combat-audio, feedback, input-buffer, Stage 2, and Stage 3 smokes pass.

## 2026-07-19 - Safe Attack-to-Skill Input Buffer

- Added one bounded latest-valid-input buffer for normal attacks and immediate-directional skills. A skill pressed during a normal strike or active dash now begins at the first safe vulnerable boundary instead of being rejected; it never overlaps a live hit window or dash invulnerability.
- Preserved committed-skill behavior: dash input cannot cancel an active skill. Added `ability_input_buffer_smoke.gd` and passed it alongside existing dash and both active-skill smokes.

## 2026-07-19 - Rootbound Husk Stage 3 and Developer Routes

- Added Stage 3 Ashen Pilgrimage, the Boss-tier Rootbound Husk, its anchored Root Spear and three-lane root-volley telegraphs, dedicated runtime art/audio, and boss-wave music trigger.
- Added Sanctuary menu routes for directly testing Stage 2 and Stage 3. Normal gates remain authored; debug F9 grants the required in-memory route flags alongside its existing skills, gear, level, and coin preset.
- Added focused Husk behavior, Stage 3 composition/music, and updated expedition-unlock smoke coverage.

## 2026-07-19 - Reinforcement Fairness Pass

- Changed the encounter queue to warn before every queued replacement and release exactly one enemy after its authored delay. A fast multi-kill now creates a real reset window instead of immediately refilling every empty slot.
- Added the `REINFORCEMENTS APPROACH` HUD announcement to both expedition scenes while retaining the four-enemy cap, existing wave totals, health values, and initial spawn cadence.
- Expanded the queued-encounter smoke test to verify one warning per pending enemy and prevent releases before the readable delay.

## 2026-07-19 - Reinforced Expedition Pacing

- Added a data-driven encounter reinforcement queue. `EncounterWaveDefinition` now carries a short reinforcement delay, so long waves release pending enemies as positions open while `EncounterController` retains a strict four-enemy live cap.
- Expanded Stage 1 from four to six waves (30 total Mireling/Rootling/Thrall enemies) and Stage 2 from three to seven waves (32 total enemies, including taught Spitter and Rootling pressure). Late waves become longer through reinforcements, not inflated health or an opening horde.
- Added structural Stage 1/Stage 2 regression coverage and a runtime reinforcement smoke test that clears every queued enemy and asserts the active cap never breaks. Rootbound Husk is explicitly reserved for Stage 3.

## 2026-07-19 - Rootling Jab Readability and Audio Polish

- Finalized Rootling as one cohesive four-direction design: restored its original unified walk board for down/left/right/up, removed the mismatched standalone down-walk input, normalized its front frames on one planted baseline, and archived all superseded Rootling generations. The future Rootbound Husk package remains preserved separately for Stage 2.
- Removed Rootling's vertical wind-up squash: its root brace now widens without shortening the down-facing body.
- Removed the temporary static-front-hop workaround; Rootling now uses the subtle authored walk motion from its one approved direction board.
- Added a dedicated original 0.31-second root-pop/wood-crack WAV generated by a committed deterministic builder; Rootling no longer reuses Bramble impact audio. Focused smoke coverage now protects the full-height pose and dedicated stream assignment.
- Restored Ashwood Blade's required Warrior class metadata so it remains valid as Opaw's default catalog weapon during normal startup and headless verification.

## 2026-07-19 - Rootling Stage 1 Forest Mob

- Added the approved cute Rootling as an independent Light-tier forest enemy with four-direction walk/reaction art, a separate directional crack/eruption VFX sheet, health/reward/knockback/stagger/health-bar composition, and an actor-local forest-jab cue.
- Its controller snapshots the telegraphed direction before a 0.58-second wind-up and activates only a narrow 40x16 root-jab lane. Later target movement cannot rotate either the visual or authoritative hitbox.
- Extended wave data and encounter spawning with `rootling_count`; Stage 1 now teaches Rootling beside Mirelings before introducing Thralls, while preserving the four-enemy cap. Added Rootling source/runtime asset catalog entries, ADR 054, and focused direction-lock regression coverage.

## 2026-07-19 - Authored Expedition Pacing Pass

- Extended Stage 1 from three to four beginner melee/leap waves, creating a readable 2/3/3/4-enemy progression without bringing ranged pressure into the tutorial route.
- Extended Stage 2 from two to three Grove waves. Its third wave combines two Mirelings, one Forsaken Thrall, and one Bramble Spitter after the earlier isolated Spitter lesson.
- Preserved the validated four-enemy cap, spawn telegraphs, 2.25-second recovery, navigation-safe spawning, and scene-owned encounter authority; expanded focused wave-structure and Stage 2 regression coverage.

## 2026-07-19 - Consecutive Thrust Detached-Tip Cleanup

- Removed the isolated front fragments from rapid VFX frames 8 and 10. Their pointed thrusts now end cleanly, without the neighboring-cell-like pieces visible beyond their tips; skill timing, visual scale, and gameplay authority are unchanged.

## 2026-07-19 - Consecutive Thrust Final-Tip Repair

- Corrected the rapid-thrust atlas packer so its final impact retains the source's last opaque point pixel and gains one matching output pixel. The finishing lance no longer reads as slightly cut; its visual scale, timing, damage lane, and hitbox are unchanged.

## 2026-07-19 - Rapid Thrust Core Readability Pass

- Replaced Consecutive Thrust's full-length yellow underlay with a compact 72-pixel white guide and 24-pixel gold cast-origin flare, keeping the rapid technique from reading as a long spear. Its 128x26 contact lane, damage, timing, and final-impact treatment are unchanged.

## 2026-07-19 - Thrust Lane Alignment Pass

- Expanded Piercing Rush's definition-owned contact lane from 98x22 to 128x30 and Consecutive Thrust's stationary lane from 76x18 to 128x26, preserving their damage, crowd control, cooldowns, and timing.
- Added immutable thrust-shape reach/width helpers so both bright central VFX guides now read their true runtime lane rather than drifting from hard-coded presentation lengths.
- Extended focused skill smoke coverage to enforce both lane dimensions and confirm Rapid Thrust reaches a target beyond its former stationary tip.

## 2026-07-19 - Consecutive Thrust Final-Audio Onset Fix

- Measured the selected CC0 final sword and final-contact clips, then skipped their 0.50-second and 0.125-second silent/build-up lead-ins at playback. The final sword burst and an accepted target-contact burst now start on their corresponding final-hit events.

## 2026-07-19 - Consecutive Thrust Final-Impact Timing Pass

- Moved Skill 2's largest spirit-lance frame from recovery onto the final `strike_started` event, aligning the visual impact with the final sword-thrust cue.
- Added a fast event-driven four-frame 11-to-8 collapse with shrinking core length and fading opacity, clearing the oversized effect in about 0.18 seconds instead of presenting delayed slow motion.

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
