# Greatsword V2: front slash → return → spin → jump cleave

**Current owner-authorized body correction, 2026-10-07:** Compare UP/DOWN with accepted side art. Offline vertical anatomy/head registration and sibling vertical carry/run resources address smaller ready bodies and apparent growth at attack start. Accepted side artwork, canonical steel, slash/landing rasters and gameplay clocks remain unchanged. [Current scope and proof](king-cardinal-proportions.md), [Decision191](../decisions/191-match-vertical-king-body-proportions.md). The acceptance/freeze below remains the baseline outside this explicit vertical body request.

**Current closure, 2026-10-07:** The owner subsequently requests V1 removal. The approved V2 is the sole selectable **Royal Greatsword**, retaining its existing save ID and approved animation; V1 definitions are archived and saved ownership/equipment migrate. Normal/finisher contact audio and real-enemy role comparisons are complete. [Current catalog/audio/migration rules and proof](weapon-impact-closure.md). Older original/new comparison statements below describe earlier deliveries.

**Owner-approved baseline, 2026-10-07:** After testing the rear/edge corrections and dedicated UP/DOWN jump impacts, the owner explicitly accepts the installed Greatsword V2. Preserve the complete four-direction combo, accepted cadence, white/silver slash and ground effects, canonical steel and approved carry/gait/proud idle. This acceptance is separate from technical checks and does not establish final encounter balance, campaign acquisition or device performance. Further animation redesign requires a new owner request.

2026-10-07 latest polish. The owner approves V2's fast swing cadence and requests larger slashes/spin, rear-loaded jump momentum, true UP/DOWN bodies and held-click repeating. Original Royal Greatsword remains the accepted five-cut Oathbound implementation. Scythe is deferred.

## Rear landing and remaining edge correction

The owner identifies three remaining defects after the preceding polish: front gloves visible on the UP landing back, a small side return-load boot at the left edge, and a neighboring white cleave tip. Earlier connected-component/padding checks did not detect all three.

The UP jump now uses four corrected complete rear landing/recoil bodies from built-in imagegen. Only bottom-row columns5–8 of the correction sheet are consumed. Native back head, palette, foot plane, steel and standing source density remain. Both original drawn front palms stay in the provenance hand mask and project together behind the new torso on the same six-texel rigid hilt. Optional `occluded_hand_poses` hides that foreground mask only for jump keys4–11/13–14; overhead loading and released/queued carry endpoints show their normal hands. The rear torso also replaces the baked front cuffs/gloves and face; hiding an overlay alone was insufficient. Defaults preserve other clips; captured attack entries retain hand visibility.

Return preparation uses calibrated narrow minimum-cost seams through the source's real transparent/outline gaps. Nominal twelve-column cuts had clipped a boot and retained a neighboring boot joined by a thin alpha bridge; keeping the largest component could not remove a connected neighbor. The first attack's queued endpoint inherits the repaired return entry. Jump FX assign complete connected ribbons and their separate sparks to their source frame before a shared-density padded fit. The second cleave tip extends into the nominal third gutter: it now remains whole in the second cel rather than appearing as a68-pixel shard in the third. Current minimum alpha margin is22texels. Other effect rows and landing dust remain unchanged.

No combo timing, damage, reach, axe tuning, input, carry, gait or proud-idle rules change in this correction. [Sources and exact prompt](../../art_source/generated/characters/king/greatsword_v2_rear_cleanup_2026_10_07/README.md), [native anatomy/fragment proof](../../art_source/review/combat/king_greatsword_v2_rear_cleanup_2026_10_07/README.md), [actual Player recordings](../../art_source/review/combat/king_greatsword_v2_rear_cleanup_gameplay_2026_10_07/README.md). Owner visual judgment remains separate from passing checks.

## Direction-specific jump impact, 2026-10-07

The owner subsequently accepts LEFT/RIGHT impact placement but reports that UP/DOWN still look like the same side effect rotated into a vertical panel. Those two views now have separately generated four-frame curved cleaves and four-frame directional floor bursts. New `vertical_slash.png` and `vertical_landing.png` each contain UP and DOWN rows; all 38 existing V2 art/resource outputs are unchanged. No side impact artwork, placement, phase budgets, damage, sound or camera strength changes.

Source magenta registration crosses are removed offline and align every frame's actual contact endpoint, with one density per row and complete alpha margins. UP/DOWN art stays in the screen's camera plane, without a 90° rotation. Cleave pivots (96,40)/(96,152) use (.8,.55) depth scaling; floor pivots (96,128)/(96,64) use (.45,.30). Both front/rear ground contacts now register to the actual rendered blade tip at ACTIVE entry, replacing the old generic 52px vertical offset. The single floor burst remains fixed and finishes across recovery. Other attacks continue using their existing atlas; switching views restores the appropriate texture/row.

Native cardinal 1529/0 and actual Player 202/0 pass, including real UP/DOWN texture selection, endpoint alignment, no rotation, correct rear/front row, hidden rear hands, all four combos and existing cancels/Stage I use. [New sources and exact built-in prompts](../../art_source/generated/characters/king/greatsword_v2_vertical_impact_2026_10_07/README.md), [latest proof](../../art_source/review/combat/king_greatsword_v2_vertical_impact_2026_10_07/README.md), [latest actual Player footage](../../art_source/review/combat/king_greatsword_v2_vertical_impact_gameplay_2026_10_07/README.md). The owner subsequently accepts this version on 2026-10-07; the recorded fixture still reports 58 ObjectDB/1-resource shutdown warnings.

## Play

Stop/restart F5, enter Sanctuary, press F9, then F7. Open **Weapons** and choose **Royal Greatsword** (the approved V2; V1 is retired). Every catalog weapon has an equip button. F9 grants test ownership without saving and keeps Weapons selected. Tab opens the normal Bag, Escape closes it. WASD moves; left click attacks; another click queues the next move; holding left click for0.18s continuously repeats the full combo. Release finishes the current strike and removes only an automatic queued followup. Space dodges.

`tools/launch_king_greatsword_v2_training.ps1` opens the actual Combat Lab with V2 equipped, three paused Rootlings and isolated non-saving storage. The previous `launch_king_heavy_burst_review.ps1` shortcut delegates to this launcher. It no longer opens an inert art-only rig.

## Jump diagnosis and correction

The earlier jump returned to ground before its downward blade sweep finished, then drove the oversized tip below the floor. Its isolated preview lacked a separate ground burst. That combination read as a weak descending stab.

Eight new original full-body source cels replace the side jump load/contact/recoil. One sheet density preserves native body size; the existing King head/palette and canonical30×140 sword remain. The pose compresses, lifts12 world pixels with tucked boots, releases quickly from overhead, and braces on bent knees. The body is grounded at ACTIVE entry (key4). Drawn paired palms7 logical texels apart orient the same rigid hilt. Contact/recoil blade tips lie at logical sole plane95, giving a shallow forward/down landing blade instead of a deep vertical plunge.

The latest generated rear-shoulder load pulls the blade diagonally behind King before the fast overhead release. New independent white/silver effects replace all four slash rows with thicker ribbons and padded complete silhouettes. A four-frame low ground burst stays fixed for0.26s across recovery with one landing sound. A2.6px request goes through CombatFeedbackPresenter's sole camera owner after contact; no independent camera-offset tween or added global hitstop exists. Cancelled attacks clear their FX. Pose lift is presentation, not terrain vaulting or invulnerability.

## Installed rules

| Cut | Wind / contact / recovery | Base multiplier | Knockback | Reach |
|---|---|---:|---:|---|
| Two-hand front slash | 0.20 / 0.10 / 0.20s | 1.35 | 76.8 | Frontal fan, up to96px |
| Two-hand return | 0.16 / 0.10 / 0.18s | 1.35 | 72 | Same frontal fan |
| One-hand full spin | 0.18 / 0.28 / 0.18s | 1.50 | 86.4 | 82px radial |
| Two-hand jump cleave | 0.32 / 0.12 / 0.32s | 2.10 | 144 | Frontal landing shape, up to96px |

Physical base roll10–12; Skill Power25 and base48 knockback remain. Total2.34s and6.30 base-hit units produce29.6 nominal base DPS (mean11); original five-cut8.45 units /3.00s remains31.0 DPS. First/second/jump budgets remain unchanged; only spin has a longer contact/recovery. This excludes armor, criticals, buffs, misses and input gaps; it is provisional comparative tuning, not encounter balance approval.

Only spin hits behind King. Melee owns contact/deduplication/damage and buffering. Collision-aware steps advance8/7/0/10px during loading; spin stays planted. Ordinary walking ratios remain25% wind /0% contact /60% recovery. Skill, evade and hit-reaction fallback use existing systems.

Side front/return retain opposite120° blade sweeps. Spin uses drawn front/profile/back body poses, not a stationary body rotated by code. Four sixteen-key side clips separate load/contact/released/queued windows; queued endpoints equal following entries, released endpoints and final queued endpoint use accepted carry. Original native gait, one-hand carry and proud planted idle are retained in both versions.

**New vertical bodies:** Generated UP/DOWN front/return/jump sheets replace the legacy wrappers. All directional clips have16 phase/branch keys, standing source density54texels, actual6-texel projected two-palm registration and accepted native heads/palette. Spin reuses its complete rotating-body cels with a facing-specific phase shift, with independent packed arrays to prevent grip remapping corruption. Carry/gait/proud idle retain approved art. The owner accepts the installed version on 2026-10-07.

**Source/atlas repair:** Isolate complete source bodies before registration, including the curved source seams described above where boots share an alpha bridge. Assign complete jump ribbons before fitting; retain one density/origin convention per row and transparent margins (current minimum22texels). Body/hand/slash AtlasTextures enable filter_clip. Padding alone cannot remove a neighboring fragment baked into a cel.

**Held input:** PlayerHeldAttackComponent starts only from accepted unhandled world LMB. A0.18s hold delay and0.06s active timer coalesce one followup into Player's normal buffer; Melee owns contact/recovery. UI clicks and targeting confirmations do not start holding. Release, focus loss, pause, NPC interaction, cinematic lock, hit reaction/restraint, skills and dodge cancel it; a new press is required. Cancellation preserves separately queued manual/skill inputs. All six weapons loop their full combos; no new save fields or idle polling.

**Axe cadence:** Iron Beard retains contact/art/reach/damage, but shorter loading/recovery reduce3.52 to3.19s (9.4% shorter); nominal mean15×6.15/3.19=28.9 base DPS. Its contact windows still give each impact readable time.

## Files and evidence

- Item/weapon: `data/items/equipment/king_royal_greatsword_v2.tres`, `data/weapons/king_royal_greatsword_v2.tres`.
- Immutable combo/presentation: `data/weapons/families/royal_greatsword_v2/`.
- Raster presenter: `gameplay/presentation/greatsword_v2_swing.gd/.tscn`; ordinary family adapter supplies it through optional profile fields.
- Lab equipment page: `levels/combat_lab/weapon_review.gd`; normal catalog, inventory and Player equip authority.
- Offline builder: `tools/build_king_front_combo_preview.gd`;40 PNG/TRES outputs in `assets/characters/playable/king/greatsword_front_combo_preview/`, including the two new vertical impact atlases.
- [Directional impact sources and exact built-in imagegen prompts](../../art_source/generated/characters/king/greatsword_v2_vertical_impact_2026_10_07/README.md).
- [Latest actual Player cardinal footage and checks](../../art_source/review/combat/king_greatsword_v2_vertical_impact_gameplay_2026_10_07/README.md).
- [Rear-correction source and exact built-in imagegen prompt](../../art_source/generated/characters/king/greatsword_v2_rear_cleanup_2026_10_07/README.md).
- [Preceding rear-correction footage and checks](../../art_source/review/combat/king_greatsword_v2_rear_cleanup_gameplay_2026_10_07/README.md).
- [Preceding full body/FX source prompts](../../art_source/generated/characters/king/greatsword_v2_polish_2026_10_07/README.md).
- [Real Player footage, UI, Stage I and validation](../../art_source/review/combat/king_greatsword_v2_gameplay_2026_10_07/README.md).
- [Enlarged deterministic art study and mirrored checks](../../art_source/review/combat/king_greatsword_v2_landing_2026_10_07/README.md).
- [Original679-file backup](../../art_source/archive/greatsword_finished_before_burst_redesign_2026_10_06/README.md), [pre-landing V2 snapshot](../../art_source/archive/greatsword_two_hand_before_landing_2026_10_07/README.md).

Latest checks and rebuild hashes are retained with the latest native proof. Earlier delivery: actual Player181/0 and horizontal art1713/0 per facing verified the previous side-only landing implementation; those counts and GIFs are historical. All28 PNG imports are lossless, without mipmaps or alpha-border fixing.

Regressions: original Greatsword146/0; native sword/axe/dual closure217/0; Lab sidebar26/0; equipment catalog passes with6 items. All679 backup copies match; original V1 art/data/gait/idle are unchanged. Two backed-up shared code files intentionally change (profile and Player adapter); documentation also advances. Earlier667-unmodified-runtime claims describe the isolated study, not this integration.

The focused end-to-end fixture still emits ObjectDB/resource exit warnings. Verbose evidence names existing expedition MP3 playback and zero-reference objects, not V2 art resources. This remains teardown debt; assertions do not establish a clean exit, owner feel, exported builds or phone performance. PNG/GIF capture costs are not normal frame-rate measurements.

Next: preserve the owner-approved V2 visual and motion baseline. True UP/DOWN attacks and impacts are installed. Campaign acquisition, encounter balance, fixture teardown and device profiling remain open; do not introduce scythe in this pass. [Reference research and exact-timing limitations](king-heavy-burst-study.md).
