# Roadmap

This file records current production progress. Historical implementation detail belongs in `CHANGELOG.md`; major superseded choices remain in `docs/decisions/`.

## Completed

- Godot 4.7 top-down production foundation with 960x540 logical rendering, keyboard/mouse/controller input, pause flow, scene transitions, and reusable data-owned combat authority.
- King is the sole production player with four-direction locomotion/basic attack, dash/backstep, hit reactions, defeat, persistent vitality/progression, equipment aggregation, and four active skills: Echoing Sever, Riftbreak, Sovereign Pursuit, and Worldsplitter.
- Basic attacks and skills use committed direction, authored hit shapes, damage, knockback, stagger, hitstop, camera response, audio, and world-space feedback without moving authority into animation.
- Combat controls through Decision 114: right-click/WASD movement clears combat intent; left-click performs directional air swings, one-click enemy selection, and repeated same-enemy pursuit/attack; right-click/`Esc` cancels targeted skills; optional `AUTO ALL` and `AUTO SKILL` remain explicit.
- Size-aware enemy footprints drive movement collision, navigation radius, crowd separation, readable tier auras, foot-circle selection, and assisted approach distance. Hurtboxes and attack shapes remain separate.
- One six-cell generated combat-action atlas supplies King Skills 1-4, Basic Attack, and Dodge/Dash through reusable `AtlasTexture` resources.
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
- F7 now opens on a rewardless, one-at-a-time Examiner combat proof in the modular Court of the First Measure layer. Nine compact-pixel, action-owned `192x128` runtime sheets drive the complete physical kit; V5 replaces malformed Descent art with intact compression/launch/fall/contact/recovery bodies. The 70% phase break includes calm dialogue/camera focus, a 0.17-second complete offscreen launch, a 3.8-second four-pylon cover lesson, a 0.15-second meteor return, exact safe-zone authority, finite 260-damage exposed impact, synchronized 0.055-second silhouette/red-eye contact, a rotating original seal, stronger aura/impact response, five added cues, one CC0 vocal music foundation with cancellable phase fades, Phase II cadence, and an idempotent Examiner-only force button. Normal movement facing follows actual velocity. None of this grants Stage VII route, outcomes, rewards, replay, or save authority.

## In Progress

- Owner feel-test Decision 114 in the normal game: click priority, repeated-click timing, footprint picking, pursuit around obstacles, moving targets, large bosses, movement cancellation, roster discovery, and long-name marquee readability.
- Owner feel-test the taller enemy roster, target panel, tier foot auras, target chevron, generated cursors, six-cell action atlas, and Stage IV eight-enemy readability at 960x540.
- Owner feel-test the fixed Sanctuary gate energy crop and Decision 119 threat ladder at 960x540: quiet blue Normal, restrained purple Mini Boss, red Boss, searing-light God, near-black Transcendent, independent lightning reach, and screen-edge direction pointer.
- Owner feel-test Umi's close dialogue portrait, right-facing-bowl hand alignment, lateral workbench scale/collision, reconstruction owned-count clarity, 760x420 Sell/Reconstruct density, click/right-click fuel flow, Auto Fill explanation, and first-play gold pacing at 960x540.
- Feel-test King's attack timing and the complete four-skill kit, especially Riftbreak impact readability, Sovereign Pursuit anchoring, and Worldsplitter commitment/damage/cooldown against crowds and bosses.
- Validate Stage V pacing, Varkuun audio/telegraphs, reward cadence, and saved direct continuation into Stage VI in a complete non-debug playthrough.
- Owner feel-test Stage VI with no armor, starter gear, and the Stage V crafted set; record clear time, damage taken, target-priority pressure, five-live crowd readability, corrected Spitter scale/counter/retreat feel, Bear four-hit stagger breakout and slam/audio, Hog charge interruption, and Crag material yield.
- Test a composition-first Stage VI Wave 4-5 pressure variant with approximately two late-section Armored Hogs while preserving eight Bears and the five-live cap; approve exact counts only from no-armor/starter/Stage-V-set measurements.
- Owner feel-test the rebuilt F7 Examiner proof at 960x540: velocity-aligned walking during target crossovers, thrust/sweep commitment, Judgment Charge fairness, Ground Judgment recovery, Refutation cadence, Axiom lanes, V5 Descent compression/instant exit/meteor return, 3.8-second pylon reach, seal brightness, impact accent/weight, protected/exposed feedback, dialogue/camera timing, and single-foundation Phase I-to-II music fades. No charge-zone slow is active.
- Keep documentation aligned with King-only runtime truth and classify any newly discovered dead asset before moving it to the archive.

## Planned

### Forest Production

1. Promote or revise the accepted F7 Examiner/Court combat proof after owner feel-testing. The production Stage VII gate still requires the ordinary roster, two-portal placement, arrival/return transitions, dialogue, expected-loss/abnormal-victory handling, reward/replay/save contracts, final mix, and final balance. Keep the Executioner documentation-only.
2. Add replayable Hunts for completed stages with explicit reward families and modifiers.
3. Continue authored Forest content through Stage X. Keep Stage VIII's standard-accessory/Umi milestone, reserve modular reclaimed magical ruins plus the provisional Mage/Warden pressure pair for Stage IX, and retain Stage X's relic/signature milestone.
4. When Stage VIII gains canonical completion authority, use it to unlock Umi and the whole Echo Crucible service; keep the current instance available until then for production testing.
5. Preserve Stage XX as the first planned direct confrontation with The One Above; do not implement it until intervening regions and the slow disclosure earn that moment.
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

Owner feel-test the new F7 Examiner proof before any Stage VII integration. First confirm scale/baseline and body motion without relying on lane VFX; then judge the court, Refutation window, Axiom safe space, and final dash. After that, lock the two-route placement, expected-loss/abnormal-victory handling, dialogue, reward, replay, audio, and safe-point contract. Stage VI's candidate Wave 4-5 Hog-pressure measurements remain a separate balance gate.
