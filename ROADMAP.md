# Roadmap

**Owner correction (2026-09-14):** Intended Advanced is three spatial lanes in a rotating fan (center plus two angled sides) for wider AOE. The current sequential Cascade remains implemented and preserved as a possible later/third upgrade; it is not the accepted Advanced design. Fan implementation is pending. Resume from [the handoff](docs/design/earthsplitter-fan-handoff.md).

- Decision 152 completed: reversible Foundation/Advanced Earthsplitter comparison, three independently released terrain-safe waves, stronger longer third wave, shared damage budget and unchanged .36s cast. Owner feel review is next. Campaign gates/saves, Awakened endpoint explosion and Molten Crash remain planned.

This file records current production progress. Historical implementation detail belongs in `CHANGELOG.md`; major superseded choices remain in `docs/decisions/`.

## Completed

- Earthsplitter eruption baseline accepted by owner. Follow-up upward-cast atlas sliver corrected through explicit clipped sword regions without asset/motion/gameplay changes; 29 rendered checks and 116 gameplay checks pass. Full campaign integration remains pending.

- Decision 150: opt-in Earthsplitter Foundation motion/gameplay proof with generated sixteen-frame sword and rupture sheets, .36s base cast, released wall-safe lane damage, one hit per target, no stun and exact review restoration. Owner approves the sword animation. Decision 151 adds the fixed-length terrain-aware lane. After rejecting the thin pressure-only look, the owner accepts the restored fuller upright ground eruptions, embedded energy bursts and endpoint feedback; full skill integration remains pending.

- Decision 149: separate explicitly authored stun from flinch/knockback, correct shared stars and King pose selection, shorten generic King skill flinches, and add the reversible targeted Riftbreak Lab review with a 16-drawing impact sequence. Owner visual/gameplay acceptance of the preview remains pending.

- September 14 reusable stun indicator: animated head stars on King, six staggerable mobs and Examiner guard break; accepted states own visibility, with authored actor offsets and no gameplay changes. Owner accepts existing King hurt/stun body poses.

- September 14 King motion acceptance: owner approves the continuous side leg-cycle, completing four-direction gait review alongside accepted hands and three basic attacks. Preserve this C baseline; campaign integration and skill redesign remain separate work.

- Decision 147: responsive core, targeted released Griefwake, Breakstep/riposte, Last Oath center/rim, ten-slot keyboard/controller/HUD/collection/save migration, safe core preset and retimed approved presentation. Focused behavior and regression checks pass; rendered review is available.

- Decision 144: Unwritten Oath collection, Crosscut/Griefwake/Starfall/Oathstorm and four authored forms, generated body/VFX/icons, original SFX, safe four-slot swaps, optional stable-ID saving and Lab previews. Mortal/Resonant integrate with the current route; future Ascendant/Unbound reward hooks remain unconnected.

- September 13 King review: corrected front/back gait, dedicated basic finishing sweep, back-facing defeat hold, dark-matte fringe cleanup, clear Resolve/link HUD text, fixed Riftbreak impact/residual lifecycle and unified foot origins for Riftbreak/Pursuit. Full 280-frame review artifacts accompany the changes. Decision 144 now extends that groundwork with four new evolving technique families.

- Decision 143: selected King C greatsword body/portrait/actions, three-cut physical chain, clipped white trails, Resolve passive, Pursuit/Riftbreak bonus, original action cues, +2%-per-level capped skill growth and stage-clear level ceilings. Owner full-campaign feel/balance testing remains active.

- Decision 141: randomized 24-meteor Firmament, recent-action-aware legal attack selection, committed Axiom/Reprisal links, seal-break remarks and a rewardless F7 victory acknowledgment. Production Stage XX integration remains planned.

- Godot 4.7 top-down production foundation with 960x540 logical rendering, keyboard/mouse/controller input, pause flow, scene transitions, and reusable data-owned combat authority.
- King is the sole production player with four-direction locomotion/basic attack, dash/backstep, hit reactions, defeat, persistent vitality/progression, equipment aggregation, and ten equipped slots drawing from eight techniques; Echoing Sever, Riftbreak, Sovereign Pursuit and Worldsplitter remain the defaults.
- Basic attacks and skills use committed direction, authored hit shapes, damage, knockback, stagger, hitstop, camera response, audio, and world-space feedback without moving authority into animation.
- Combat controls through Decision 114: right-click/WASD movement clears combat intent; left-click performs directional air swings, one-click enemy selection, and repeated same-enemy pursuit/attack; right-click/`Esc` cancels targeted skills; optional `AUTO ALL` and `AUTO SKILL` remain explicit.
- Size-aware enemy footprints drive movement collision, navigation radius, crowd separation, readable tier auras, foot-circle selection, and assisted approach distance. Hurtboxes and attack shapes remain separate.
- Four coordinated greatsword skill icons join the existing Basic Attack and Dodge/Dash icons, all through reusable native-24px `AtlasTexture` resources.
- Sanctuary with Eira skill information, Orren lore dialogue, Nema's atomic gold-backed Stage V Living Rootforge, Umi's catalog-driven Echo Crucible for selling/reconstruction, expedition selection, debug-only Combat Lab access, and safe-point autosave.
- Forest Stages 1-5, including authored TileMaps, bounded live-enemy pressure, sparse/protected loot, Stage III Rootbound Husk, Stage IV Armored Hog pressure, and Stage V Varkuun encounter/reward flow.
- Decisions 126-127 production Stage VI: `The Elder Ascent` preserves the approved top-down terrace/waterfall and eight-Bear population while five waves now total 4/4/5/6/9 under a five-live cap. Mirelings are absent; fourteen Thralls, five rebuilt Bramble Spitters, and one finale Hog supply composition pressure. Spitters own fresh `AnimatedSprite2D` action families, bounded retreat, and destructible thorn-seeds. Retuned Crag Iron/Echo Claw drops, clear banking, Level 6 access, Normal return, and F9 review remain active.
- Versioned disk save/Continue with temporary write, rotating backup, story/progression/health, King weapon/gear, materials, recipes, and reward claims.
- Sanctuary/Continue is a full-health recovery checkpoint; expedition stages still preserve attrition between direct stage transitions.
- Expedition defeat returns to Sanctuary, rolls back uncommitted loot, and preserves level/coins. Stage V's approach no longer reuses Sanctuary music.
- Sanctuary locks its generated angels/masonry to one static raster and animates only doorway energy. Stage exits use two approved 16-frame abyssal sheets with full-surface/deforming-rim motion and a separately scalable lightning field. Five threat tiers now progress from blue lightning-free Normal through purple Mini Boss, red Boss, searing-light God, and near-black Transcendent with half-viewport-plus reach; the loading veil preserves the chosen tier.
- The complete implemented clear-route contract now previews destination threat and advances continuously: I->II blue, II->III purple Mini Boss, III->IV blue, IV->V red Boss, V->VI blue, then VI->Sanctuary blue until Stage VII exists. Varkuun's chest/save order remains intact before the Stage VI portal appears.
- The live enemy roster is discovery-gated, uses stable signature refresh, and clips/pads/marquees only overflowing names.
- Long-lived Spitter seeds tolerate shooter death, can be destroyed by player hitboxes without entering enemy targeting, and clean up on range/lifetime/scene unload. Armored Hog's committed brace/charge cannot be permanently canceled by normal-hit spam.
- Decision 128 adds reusable stagger-chain breakout without coupling it to hitstop: weak mobs remain freely interruptible, Hog/Bear resistance thresholds are data-owned, Heavy and Boss response stay distinct, and accepted enemy control now cancels vulnerable King actions and applies Player-owned knockback. The rebuilt Spitter's approved frames are normalized to normal-mob native pixel scale rather than scene-scaled; attack entry now preserves idle actor mass and its seed impact ends on the clean third-frame explosion.
- Decision 121 establishes the first meaningful equipment band: exact Stage V slot identities, Varkuun Edge critical-hit authority, percentage caps, equipped-item comparisons, compact Character/Rootforge layouts, right-edge formula icons, and clearer binary-alpha Forest equipment silhouettes.
- Decision 123 implements persistent enemy memory, metadata-owned material valuation, protected boss reconstruction, exact Stage V crafting fees, and Umi's compact east-Sanctuary service without hardcoded NPC material lists. Umi now has a native-density close dialogue portrait and a 72x64 asymmetrical side-facing Echo Crucible workbench; Common drops are fuel/sale resources rather than reconstruction targets.
- Decision 130 makes earned loot saturate at full material stacks so pickups clean up and milestone chests advance, while paid reconstruction remains capacity-strict and refuses before spending.
- Opaw, the retired weapon shop/awakening flow, unused equipment showcase, obsolete processors/tests, and 30 unreferenced images moved into recoverable Godot-ignored archives. The post-cleanup runtime image audit reports no unreferenced images under `assets/`.
- Decision 136 (2026-09-12) rebuilds the rewardless F7 Examiner proof with ten eight-column `192x160` sheets, 116 named clips, disjoint anticipation/contact spans, original action/footstep audio, an engraved-slate Court, exact traversable cyan wards, compact review controls, and actual phase/technique text. Grounded charge now stops at physical collision. Body baseline is 128 and visual origin is -48; final owner feel approval and production Stage XX integration remain pending. The established Divine Descent rules and one music foundation remain intact. The lab grants no rewards or saves.
- Decision 137 (2026-09-12) follows owner acceptance of the Examiner look with a dedicated four-pose alternating gait, turn-continuous footsteps, complete-source weapon extraction, repaired slam source, four eight-frame raster skill atlases, crimson danger decals, exact Descent safe-hole shading, and heavier fracture/beam audio. The 116 named clips, 192x160 cells, baseline 128, origin -48, controller timing, and trial authority remain intact. The owner accepted the skill effects but rejected the replacement walk identity. The identity follow-up now derives front/profile/back studies from isolated approved locomotion references, restores the narrow mask and long ivory coat, and matches helmet-to-ground body scale per direction. Skills, audio, HUD, and combat authority are unchanged; the owner approved the revised gait. Stage XX integration remains pending.

## In Progress

- **King Skills 1-2 production plan:** Skill 1 Foundation is owner-approved; Advanced Cascading Rupture is implemented in the Lab and awaiting owner feel review. `docs/design/king-skill-upgrades-and-production.md` specifies the remaining upgrade forms, bounded stage growth, VFX/audio candidates and Skill 2 implementation. Numbers/gates remain proposed; old skill removal and campaign promotion are still pending.

- **Latest King concept alignment:** Owner accepts Skill 2 V2's local molten burst and Skill 1 V3's expressive smash/earth rupture with a separate summoned-sword correction. Skill 1 now demonstrates that direction in the Lab; Skill 2's lift/crash is still planned. Upgrade impacts/final explosion, names, counts, charges and lore gates remain provisional. Existing Crosscut and Riftbreak alternatives are still installed. See `docs/design/king-spirit-sword-concepts.md`.

- **King review first:** September 14 authorization permits Decision 148's isolated playable C character review. The isolated targeted Riftbreak comparison is now authorized and implemented; broader skill/tier redesign remains pending. Owner rejects latest Skills 2/3 and old/new coexistence as the final direction, and expects higher skill numbers to represent stronger tiers.
- **Character before skills:** C's shoulder carry, finer detail and three attacks are selected. Decision 148's follow-up replaces mixed-sheet locomotion with registered poses, lowers the rear blade beneath the hair and adds a consistent thin outline in the opt-in Lab. Owner has approved locomotion and reactions; targeted Riftbreak is now a separately authorized Lab comparison. Campaign promotion remains pending.
- **Character integration next:** Directional gait and basic attacks are owner-approved. Hurt/stun body poses are also owner-approved; review dash/defeat, promote the selected Lab presentation into campaign play, and continue the separately authorized Riftbreak skill comparison. No further base-character redesign is needed for the current direction.
- September 13 character review: owner selected C Spellward and requested finer, clearer stylized pixels at the same body scale. Initial one-facing idle/walk/swing studies and interactive small-scale review are in `art_source/review/characters/king/spellward_motion_2026_09_13/`. The walk remains unfinished: the opposite-foot contact is not convincing. Final density, motion cleanup, other directions and runtime integration remain pending; no new runtime assets installed.

- Decision 146: develop the accepted Stage X female Forest Goddess direction (Examiner-sized or larger) and distinct boss traits. Root-fed bark protection and Examiner heat pulses are proposals; boss production, exact scale, passive capacity, survival effects and inheritance rewards remain design work.

- Develop earned domain spells for the implemented ten-slot foundation after core feel review. Eight techniques currently exist; new poison/lightning/gravity/ward/blind/meteor families and production divine reward gates are not implemented.

- Owner feel-test Decision 147 core with immunity/unlimited skills disabled: targeted Griefwake while moving, actual Breakstep evade/riposte versus rupture link, center placement on Last Oath, two-cut cancellation, ten-slot readability and upgraded forms. No final endgame balance claim.


- Owner feel-test Decision 114 in the normal game: click priority, repeated-click timing, footprint picking, pursuit around obstacles, moving targets, large bosses, movement cancellation, roster discovery, and long-name marquee readability.
- Owner feel-test the taller enemy roster, target panel, tier foot auras, target chevron, generated cursors, greatsword skill icons, and Stage IV eight-enemy readability at 960x540.
- Owner feel-test the fixed Sanctuary gate energy crop and Decision 119 threat ladder at 960x540: quiet blue Normal, restrained purple Mini Boss, red Boss, searing-light God, near-black Transcendent, independent lightning reach, and screen-edge direction pointer.
- Owner feel-test Umi's close dialogue portrait, right-facing-bowl hand alignment, lateral workbench scale/collision, reconstruction owned-count clarity, 760x420 Sell/Reconstruct density, click/right-click fuel flow, Auto Fill explanation, and first-play gold pacing at 960x540.
- Feel-test King's attack timing and the complete four-skill kit, especially Riftbreak impact readability, Sovereign Pursuit anchoring, and Worldsplitter commitment/damage/cooldown against crowds and bosses.
- Validate Stage V pacing, Varkuun audio/telegraphs, reward cadence, and saved direct continuation into Stage VI in a complete non-debug playthrough.
- Owner feel-test Stage VI with no armor, starter gear, and the Stage V crafted set; record clear time, damage taken, target-priority pressure, five-live crowd readability, corrected Spitter scale/counter/retreat feel, Bear four-hit stagger breakout and slam/audio, Hog charge interruption, and Crag material yield.
- Test a composition-first Stage VI Wave 4-5 pressure variant with approximately two late-section Armored Hogs while preserving eight Bears and the five-live cap; approve exact counts only from no-armor/starter/Stage-V-set measurements.
- Owner feel-test the Decision 136 F7 rework at 960x540: stable anatomy/foot baseline, all directional action phases, four-pose alternating walking, collision-stopped charges, counter/Axiom readability, Descent cover and impact, sound mix, and compact controls. No charge-zone slow is active.
- Keep documentation aligned with King-only runtime truth and classify any newly discovered dead asset before moving it to the archive.

## Planned

### Forest Production

1. Promote or revise the accepted F7 Examiner/Court combat proof after owner feel-testing. The production Stage XX gate still requires the arrival/return transitions, production scenario dialogue and outcome wiring beyond the F7 victory preview, reward/replay/save contracts, final mix, and final balance. Keep the Executioner documentation-only.
2. Add replayable Hunts for completed stages with explicit reward families and modifiers.
3. Continue authored Forest content through Stage X. Keep Stage VIII's standard-accessory/Umi milestone, reserve modular reclaimed magical ruins plus the provisional Mage/Warden pressure pair for Stage IX, and retain Stage X's relic/signature milestone.
4. When Stage VIII gains canonical completion authority, use it to unlock Umi and the whole Echo Crucible service; keep the current instance available until then for production testing.
5. Build toward the required Stage XX Examiner scenario; The One Above's direct encounter is unscheduled. The Stage 100 family-reunion promise is manipulation, not a confirmed resurrection outcome.
6. Define the Stage XI seam and next-region identity before naming or generating that content.

### Release Readiness

- Decide target-platform priority and set measurable desktop/web/mobile budgets.
- Add accessibility, localization readiness, settings persistence, export validation, compatibility testing, and performance profiling.
- Finish onboarding, balance passes, campaign pacing, and production-quality owner review at the logical viewport.

## Deferred

- Ultimate and Reality Breaking gameplay; both are presentation-only reserved tiers.
- Additional playable characters. New roster work begins only after King and the release slice are stable.
- Utility items such as healing potions, temporary buffs, and a rare revive; define inventory limits, combat-use commitment, rarity, and save rules before implementation.
- Multiplayer, branching routes, challenge modes, and mod support.
- Divine-weapon immunity and other high-tier rules that currently have no production content.

## Technical Debt

- The combat action buffer, assisted targeting, and auto-combat are structurally tested but still need long-session feel/profiling in obstacle-heavy Stage IV/V encounters.
- Some historical ADRs and `CHANGELOG.md` intentionally mention retired Opaw systems. They are records, not current instructions.
- Audio settings remain session-only.
- Sanctuary expedition previews still expose sealed future routes whose content is not implemented.
- The reusable Crag Bear's active art/provenance paths still contain `stage_6`; migrate them only through a controlled reference-safe asset move. New reusable enemy/environment/VFX/audio/material paths must be identity-owned immediately.

## Next Decision Gate

Owner feel-test the new F7 Examiner proof before any Stage XX integration. First confirm scale/baseline and body motion without relying on lane VFX; then judge the court, Refutation window, Axiom safe space, and final dash. After that, lock the required-encounter outcome handling, dialogue, reward, replay, audio, and safe-point contract. Stage VI's candidate Wave 4-5 Hog-pressure measurements remain a separate balance gate.

## Examiner Stage XX direction (Decision 138)

Decision 138 (2026-09-12) supersedes the Stage VII optional-challenge and Stage XX direct-god placement: Examiner is the required Stage XX scenario boss, a false mentor serving the gods' manipulation. They promise reunion at Stage 100; King's family is actually dead. Souls, resurrection, replicas, the ending, and any bestowed power remain open possibilities, not established survival facts. The One Above's direct confrontation is now unscheduled. Only the F7 combat proof is playable; production route/outcome/reward/save integration is pending.

Decision 141 preserves the approved body art, living Sun charge, separate seal/stun rules, 60% Second Measure and 35% Unbound. Crimson Firmament retains its 180-point/3.8s interruptible charge, then releases 24 red meteors in eight randomized waves of three, 0.62s apart, with 0.90s warnings and 48px impact radii. Each wave snapshots King and scatters other impacts while leaving a nearby opening; no permanent safe column remains. Weighted legal attack selection discourages recent repetitions, and selected phase-two Axiom recoveries can lead into a newly warned, committed Reprisal. Seal breaks earn changing remarks. Lethal damage clears hazards, then Examiner kneels, rises, acknowledges King in a skippable conversation and withdraws. This is a rewardless F7 outcome preview: production Stage XX routing, rewards, story persistence and gear balance remain pending.
