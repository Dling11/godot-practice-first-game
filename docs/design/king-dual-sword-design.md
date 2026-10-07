# Twinsteel — unified King body and thrust/hop combo

**Current Twinsteel V2 (2026-10-07, Decision190):** This equipment now uses diagonal → return → rising cross → hop spin → crossing finish, dedicated front/back cuts, fresh four-direction walking and planted-pair/folded-arm/head-glance idle. Existing ID/role/audio remains; the opening is a fan rather than a thrust. [Current runtime truth/play/proof](king-dual-v2-cardinal.md). Earlier fixed-gait/thrust/prototype details below are historical.

**Current follow-up (2026-10-07):** Owner requests a fresh combo/slash pass, removing the opening thrust and beginning with LEFT/RIGHT. The sibling Twinsteel V2 study is diagonal → return → rising cross → hopping spin → crossing finish, with native identity and accepted carry/gait/steel preserved. It is reviewed through a dedicated viewer; this document's installed four-direction rules remain live until promotion. [New study, sources and evidence](king-dual-side-redesign.md).

**Current role/UI/audio closure (2026-10-06):** Lighter9–11 physical rolls retain the accepted five-hit2.20s exchange and25 Skill Power. Nominal47.7–58.3 chain damage/24.1 base DPS; two blades still grant one contact per enemy/input. Bag icon now visibly shows the pair, with truthful per-cut/role/DPS descriptions and CC0 body impacts. All approved steel/body/FX/gait remain; Greatsword is frozen. [Closure rules and proof](king-weapon-closure.md). Effective encounter balance and owner audio feel remain pending.

Current first-wave correction2026-10-06: the owner reports missing first white frames. The old broad first curve was nearly absent after narrow thrust clipping (6-7 bright actual Player pixels). The existing four raster cels now use a compact160x16 forward-wave registration at(112,102); first-hit white streak/curve is visible in every facing (31-38 bright pixels). Native gameplay244/0 and cardinal4586/0 pass; only swing.png changes, with all other FX rows/body/carry/combat identical. [Current first-hit preview and proof](../../art_source/review/combat/king_dual_thrust_wave_2026_10_06/README.md). Owner visual review remains pending.

Current attack correction2026-10-06: owner-marked DOWN thrust head/scarf frames now register the native head center to the drawn crown/neck axis, with old scalp fragments removed. The original side Crosscut source restores neutral raised sleeve/outline pixels erased by the first ingestion; actual gloves register both swords afterward. Queued endpoints inherit these corrections. Native cardinal4586/0 and actual Player232/0 pass;10 attack/endpoint files change,56 other outputs and92 protected files match, and all66 rebuild identically. The fifth white slash was already present in runtime: all four production facings show739-850 independently measured bright effect pixels. Drawing pose sheets intentionally omit swing FX. [Current repair, revised poses and native slash](../../art_source/review/combat/king_dual_frame_repairs_2026_10_06/README.md). Owner visual review of this correction remains pending; the preceding sketch carry is accepted and unchanged.

2026-10-06. Twinsteel is one normal King equipment item in the catalog, F9 test kit and Tab Bag. The owner rejects the raised-hand chest/palm carry, supplies a yellow lower-hand front-sword sketch, then identifies merged pixels and missing clear edges. Current side run assigns the complete foreground sword to the lower near palm(87,74), using its actual native forearm/fingers; the other grip(91,69) and handle are tucked behind the vest. Canonical steel and the near forearm gain one native charcoal perimeter texel for separation at game size, without a new palette or body scale. Native cardinal4567/0 including105 captures, actual Player220/0 and66 identical repeat-build outputs pass;61 other runtime files and92 protected files remain unchanged. [Current sketch/outline preview](../../art_source/review/combat/king_dual_sketch_carry_2026_10_06/README.md). Previous chest/palm geometry is rejected history. Owner explicitly accepted this carry/outline correction on2026-10-06. Preserve its proportions, native face, lower-hand grip, tucked rear arm and clear dark edges as the baseline for future variants. Campaign acquisition/crafting, comparative balance and device profiling remain open.

Previous follow-up2026-10-06, now owner accepted: screenshot identifies the feet in **UP/back walking**. Its steady upper body retained a moving source pelvis/leg root, drifting up to7.75logical pixels sideways. Each full lower-body stride is registered beneath fixed pelvis X96 at integer shifts0/0/-3/-6/-7/-6/-8/-5. Original step shapes/order, upper anatomy/bob, hand masks, blades and grip metadata remain. Only `up/run_body.png` changed in that follow-up;64 other art outputs and92 protected files were identical. [Focused upward GIF and before/after](../../art_source/review/combat/king_dual_back_feet_2026_10_06/README.md).

## Current player rules

| Input | Motion | Wind / contact / recovery | Damage multiplier | Contact |
| --- | --- | --- | --- | --- |
| 1 | Double thrust | .12 / .12 / .14s | .80 | Narrow72px forward thrust |
| 2 | Crosscut | .10 / .12 / .14s | .85 | 72px frontal fan |
| 3 | Return cut | .14 / .14 / .14s | 1.05 | 72px frontal fan |
| 4 | Small hopping spin | .16 / .20 / .14s | 1.10 | 58px radial circle |
| 5 | Springing X | .20 / .16 / .18s | 1.50 | 80px frontal fan |

Nominal chain2.20s /5.30 base-hit units, current9–11 physical rolls:47.7–58.3 complete-chain damage/24.1 base DPS before defenses/buffs/criticals/hitstop/speed gear. Skill Power25 remains. Collision steps4/4/4/0/6 total18px. In normal gameplay, voluntary walking is50% during wind-up, planted during contact and75% during recovery, then full speed at idle. Collision steps, knockback and dash remain independent. Each input produces one deduplicated contact/critical result per enemy despite two blades. Only spin hits behind King. The older isolated art controller plants voluntary movement throughout its cuts.

The first contact narrows deliberately: a1px target68px ahead is hit, one110px ahead is missed, and a45px-forward/26px-side target is missed in every facing. The old wide first-swing fan is no longer its rule. Silver FX clip to the actual shape. Its first four cels use the compact forward-wave registration rather than the broad curve that formerly disappeared outside this lane.

Spin uses explicit lift up to12 logical texels /6 world pixels, then lands before its endpoint. X retains up to4worldpx lift. These cosmetic hops add no invulnerability, obstacle crossing or separate damage tick. MeleeAttackComponent retains authority.

## Consistent body calibration

Use actual body anatomy and source pixel density, rather than forcing all facings to one bounding-box height. The rejected front idle measured48×54 logical pixels, versus35×53 for the accepted native body. Front idle retains that native head, neck, torso and relaxed hands exactly. Its staggered walking legs are replaced belowY77 by two copies of the complete planted foreground leg, mirrored and separated by a one-pixel boot gap. Both soles areY94; standing dimensions remain35×53. Side/back idle remain54px. Accepted heavy source files are unchanged; this does not claim a global cleanup of their vertical assets.

The prior polish applied a small idle's55/43 or55/48 factor to already larger vertical attacks. Later copying44/45px idle bodies exposed that growth again. Spin also kept a wider independently generated head. Equal height on one static carry frame did not establish matching anatomy across combat.

Current ingestion:

- The earlier24-cel source still supplies thrust and side/back idle. Front idle uses native `greatsword_cardinal/down/run.tres` cel0 aboveY77 and paired native foreground legs below; no generated torso or head replacement is used for it.
- Existing side cuts2/3/5 retain their installed head and authored body poses. Original side-source neutral sleeve/outline pixels repair the Crosscut raised arm before actual grip/mask registration. No second rectangular scalp erasure is applied to those accepted cuts.
- Existing vertical cuts receive one clip-wide calibration factor, preserving the complete head/torso/arms together. Actual crouch and raised arms can change silhouette height; there is no per-frame zoom.
- Spin uses one density per clip, calculated from its scalp-width baseline, plus matching installed front/profile/back head references, including mirrored profile during the turn.
- New idle/thrust, spin and gait use installed King references/common charcoal, crimson, leather and steel palette. Genuine generated cuffs erased outside the new head region are restored from original source pixels, rather than inventing disconnected arms.
- Side carry derives from native greatsword_confidence_v2/axe_run.tres upper cel0 with the accepted idle head/face at its scarf socket(91,41,25,24). The lower near forearm/palm is copied intact, translated(+3,+1), and registered at palm(87,74) from native(84,73). It owns the complete foreground primary sword. The projecting raised far fist is removed, preserving scarf and central chest; rear grip(91,69) stays occluded by the vest and uses the rear offhand blade. The real outlined near forearm is composed after the original legs and copied to the foreground hand atlas, including belowY77, preventing seam clipping and false rectangular armor patches. Head/upper/grips share bob [0,1,0,-1,0,1,0,-1]; all eight native leg keys remain unchanged outside the real foreground arm. UP retains centered pelvisX96 and native steps. DOWN retains its complete native upper anatomy, head(84,41) and palms(85,74)/(107,72). Gait advances from collision-resolved displacement,48px per cycle, and freezes when blocked.
- Every grounded attack cel registers the complete body, both gloves and head metadata to sole Y94 before queue copies. Only explicit spin/X lift moves the body upward; old boot-height drift cannot add an unintended hop.

Installed head references under `assets/characters/playable/king/`:

| View | Reference body/key | Region |
| --- | --- | --- |
| Side | greatsword_confidence_v2/idle.tres,0 | (87,41,25,24) |
| Back | greatsword_cardinal/up/run.tres,0 | (84,41,23,22) |
| Front | greatsword_cardinal/down/run.tres,0 | (84,40,24,24) |

Native checks compare the side head/neck against the independently accepted standing reference, central vest against the intact native torso and actual lower palm against the original glove pixels. They verify coherent bob, foreground fingers above the complete primary sword, the occluded rear grip with no exposed handle, and original leg pixels outside the real foreground arm. No false palm on a belt or broad chest-covering mask is accepted. Front idle head/neck/torso, two planted soles and boot gap remain independently checked; cardinal upper/grip X stays fixed and blades cannot cross. The front thrust centers its crown on the registered body axis within3 logical pixels, preserving the drawn scarf/socket Y and60px silhouette envelope. Raised Crosscut gloves must have an opaque path into the torso/boots, beyond the older whole-body connectivity percentage. Other combat head registration remains unchanged. Connectivity, color or dimensions alone do not establish correct hand ownership or readable edges; owner visual judgement remains necessary.

Both swords use one **16×62** logical canonical blade and tip **(8,0)** at0.5 world scale. Idle/attacks and vertical running use grip **(8,50)**; side running uses **(8,44)** immediately below the guard. The offline builder always resizes the immutable22×82 original, then adds one charcoal perimeter texel from the native body palette within the same canvas. Existing opaque blade colors remain, and repeated builds cannot progressively thicken or shrink the blade. This edge treatment is shared across every state; the carry-only rear variant is derived from that same outlined canonical steel. Broad silver hit FX and gameplay reach remain unchanged.

## Carry respects physical facing

For A/D running only, the near primary sword remains complete and paints in front of the body, registered to the lower palm(87,74), with the actual forearm/finger atlas above its handle. Guard distance remains3 logical pixels/1.5worldpx. The far offhand uses twinsteel_side_rear.png: canonical16×62 canvas, identical tip/blade/guard rows0..42, handle rows43..61 transparent. Rear grip(91,69) paints behind the intact torso and is deliberately occluded, not presented as a separate floating glove. Idle, attacks and vertical carry keep their established anatomy/depth and complete swords. Authored attack entry inherits both actual textures, offsets, rigs, body/mask and depth, then restores full destination textures at the next cel.

Idle uses relaxed arms and empty hands, repeated as a stable cel: native front upper body with two planted boots for DOWN, existing bodies for side/UP. Both blades cross at back attachments(88,56)/(104,56), headings35°/145°, with no false finger masks. This crossed back stow is distinct from the uncrossed running carry.

**UP/W exposes King's back:** draw the crossed swords over that visible back. **DOWN/S exposes his chest:** draw the stowed swords behind the body. Side stow also paints behind. A single screen-behind flag for every facing had placed W-facing weapons on his hidden chest; that is corrected.

Running holds both blades toward the direction King faces. Side angles are +5°/-8°, with lower-near/rear grips(87,74)/(91,69), preserving close parallel blades from the owner sketch and the shared one-pixel upper bob. UP uses -93°/-87°; DOWN +93°/+87°. Their3° outward tilt moves each tip about2.6 logical pixels/1.3 world pixels sideways from its own hilt, forming a shallow V without crossing. Depth follows physical near/far arms. The old outward170°/10° carry remains rejected.

## Combo continuity and runtime ownership

Each cut has13 slots: WIND0–3, ACTIVE4–6, released RECOVERY7–9, queued RECOVERY10–12. The complete endpoint body/mask/grips/depth copies into the next opening. Releasing any cut restores the same directional back stow. The first file retains its legacy name `descending.tres` but now contains the double thrust.

Fixed-grip blade-angle interpolation keeps foreground fingers on their body cel. One pose clock drives both swords. OffhandPoseDefinition owns independent texture/grip/tip/axis/visibility/depth; secondary_hands still orients the primary shaft.

Generation-guarded deferred continuation remains: pause preserves scheduled input, cancel/reset invalidate it. Automatic handoff gaps are[0,0,0,0] additional physics ticks. No new runtime head solver, body-size tween or second combat clock.

Production ownership: `data/items/equipment/king_twinsteel.tres` owns item ID `weapon_king_twinsteel`, one paired weapon slot, warrior compatibility and Bag details. `data/weapons/king_twinsteel.tres` references the shared combo/profile under `data/weapons/families/twinsteel_prototype/`. That folder name remains for offline-tool compatibility. The separate prototype `weapon.tres` omits normal family presentation because its old review controller constructs a rig itself; the game never equips that review definition through the catalog.

Player and MeleeAttackComponent retain input, contact, critical roll, buffer, cancel and phase-movement authority. PlayerWeaponFamilyPresentation owns the pair and white FX; upward ordinary arcs paint before the body. Its existing blocked-state rules hide the family during skills, dash and damage reactions so existing King action cels remain usable, then restore it. Bespoke dual-sword skill/reaction art is not yet authored. WeaponInventory, F9 and CharacterMenu consume the catalog without new save schema or duplicated acquisition logic; both blades occupy one item ID.

The authored opening now inherits each blade sprite local offset as well as its rig/body/hand/depth. This preserves actual side-run grip(8,44) when entering attack grip(8,50), avoiding a3worldpx first-cel jump. Later keys restore their own registered offsets. No accepted art pixels or grip resources changed during integration.

## Play in the actual game and training

Restart F5 → Sanctuary → F9 → Tab → **Twinsteel · Dual Swords** → **EQUIP ITEM** → close Bag. The pair remains equipped across normal Sanctuary/stage Player instances. F9 grants test gear and suppresses autosaving for the session; fresh campaigns keep the signature sword and old snapshots remain valid. F7 opens Combat Lab while Admin Mode is enabled.

For immediate testing with a paused Rootling and Twinsteel already equipped:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\launch_king_twinsteel_training.ps1
```

Window **Battle of Gods — Twinsteel / Combat Lab** uses the real Combat Lab scene, actual Player and visible Bag. WASD moves, left click attacks/buffers the next cut, Space dodges,1–5 use skills, Tab opens Bag and Esc closes it. Sidebar AI can make the Rootling move or spawn more enemies. Its dedicated testing save path and suppressed autosaves keep this launcher session separate from campaign progress. This is the normal training controller, not the old art fixture.

## Current verification and older art fixture

Current UP feet proof: `art_source/review/combat/king_dual_back_feet_2026_10_06/`. Cardinal4398/0 adds independent fixed-pelvis-column and ankle-lane checks; actual Player/gameplay210/0 passes. Both pelvis rows stay within0.5logical pixel of X96, rather than drifting with the original whole-body source. All65 outputs reproduce. The48-frame focused UP GIF shows3x and actual size. These checks establish centered registration while preserving the gait, rather than final owner motion acceptance.

Prior front-walk proof: `art_source/review/combat/king_dual_front_gait_2026_10_06/`. Native cardinal4374/0 includes independent native head/neck/chest/glove, exact head-registration and original-leg checks that detect the reported mismatch. Normal gameplay210/0 still passes. Only `down/run_body.png`, `down/run_hands.png` and `down/run.tres` change from the installed pair;62 other art files and92 protected files remain identical. All65 outputs rebuild identically. The native48-frame all-direction gait GIF shows3x and actual size; body sheets compare before/after against the accepted idle and original gait. Stop and rerun F5 to reimport/load the corrected frames. Visual owner judgement remains open.

Original Godot4.7.2 Compatibility integration proof: `art_source/review/combat/king_twinsteel_gameplay_2026_10_05/` (completed2026-10-06 before the front-walk correction).

- Normal gameplay210/0: physical F9/Tab, one-slot Bag equip and paired paper doll, four actual directional runs and buffered five-cut chains, side-run first-cel registration, upward white FX depth, one contact per enemy/input, rear spin only, out-of-range rejection, all five skill input/confirmation/cancel paths, dash and accepted-damage reaction restoration, axe/Greatsword/signature swaps, snapshot compatibility and actual Stage I attack.
- Cardinal art regression4350/0 and axe/Greatsword2771/0 pass without capture-only assertions. Earlier4455 cardinal checks included105 capture checks; differing totals do not mean dropped gameplay checks.
- All65 approved runtime PNG/TRES hashes and92 protected heavy/source hashes match the pre-integration state; `scope_validation.json` records empty change lists.
- Native Bag, spin, equipped training and Stage I captures are retained. Automated results verify the stated paths; comparative balance and player feel still need gameplay review.

The isolated motion fixture is retained for offline art inspection:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\launch_king_dual_twinsteel_review.ps1
```

Window **TWINSTEEL / CLOSER SIDE HILTS**. WASD runs/faces; SPACE/click attacks with one buffered input; G plays five; Tab toggles visible controls; Esc pauses/resumes. Direction buttons, spin, moving rewardless Rootling, cancel and reset remain. The existing review stops running and restores idle carry before beginning an attack. Committed attacks hold facing. This review's Tab is controls; hidden game Bag input is disabled.

Accepted pre-integration art proof: `art_source/review/combat/king_dual_close_hilt_2026_10_05/`. The owner passes its final closer side hilts. The figures below describe that earlier art/rebuild pass rather than the current game-integration test.

- Native motion 4455/0: preserved native head/legs, coherent hip carry, fixed cardinal upper anatomy/grip X, tiny non-crossing tilt, compact blade landmarks, distinct planted boots, all facings/attack keys, actual grips, connected anatomy, physical stow, hop landing and queue/interpolation.
- Actual practice113/0: five front contacts/one rear spin, no doubled paired hits, movement/blocked gait, buffering, Tab/Esc, pause/cancel/reset and narrow thrust reach/flank rejection in all four facings.
- Current scope and repeat-build hashes are recorded in `scope_validation.json` and `rebuild_validation.json` in that proof folder. All 65 runtime PNG/TRES outputs rebuild identically. Only side `run.tres` changes; the other 64 files, all 92 recorded heavy/source files, body/mask pixels, blade texture, vertical views, silver FX and combat rules remain identical to the accepted compact pass.
- 105-frame attack and48-frame gait GIFs decode-check, with native comparison and playable stage capture.

The owner accepts the closer-hilt art and normal equipment integration is implemented as described above. Comparative balance and device profiling remain open. `king_dual_compact_carry_2026_10_05/` is the accepted overall carry before the side-hilt request. Earlier steady-carry/attachment proofs are partially accepted baselines; older unified/gait/polish proofs are superseded history, with their documented rejections.

## Sources and current rebuild

The current full builder produces66 PNG/TRES outputs, including the side-only rear blade. Current sketch/outline scope changes side run_body.png, run_hands.png, run.tres and both steel textures;61 other outputs and92 protected files match the preceding pass, and all66 reproduce. The older65-output passes below are historical. Both blade imports use nearest/lossless/no-mipmap with alpha-border repair disabled. The optional --side-run-only branch is a quick offline preview that writes only side carry/blades; it does not regenerate the full registration/palette audit and is not the final reproducible-build command.

Source, exact prompt, reference capture, registration, palette and before/after hashes: `art_source/generated/characters/king/dual_unified_2026_10_05/`. Built-in imagegen supplied `thrust_source.png`; original output is preserved under Codex generated images. All source/identity processing is offline.

Deterministic input bodies and metadata: `art_source/archive/dual_existing_gait_rejected_2026_10_05/dual_twinsteel/`. Keep that archive for rebuilds; runtime never loads it. Current builder derives all carry/attack outputs from those inputs and the new source, so older gait/polish builders are not part of the current rebuild:

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_dual_unified.gd
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import --quit
```

The archived original blade and runtime silver atlas are deterministic inputs; the current builder writes a smaller runtime blade. Imports remain nearest/lossless/no-mipmap. Side body imports disable alpha-border repair; existing cardinal body imports retain it. Preservation checks ignore RGB only where both texels are fully transparent. Capture uses native Compatibility rendering; headless is only for offline builds/import.

## Remaining work

Normal Player, equipment/menu, skills/dash/hit-recovery, inventory snapshots and Stage I installation are complete. Owner tests actual combat feel next. Bespoke dual-sword action cels, crowd/audio mix, comparative family balance and campaign acquisition/recipes still need separate work; F9 is the current test-kit acquisition path.

B Mooncut remains a possible curved variant; C Oathpair remains a medium/short-blade concept. Grip/tip/edge/size compatibility must be checked per variant. Recipes, milestone gates, armor, comparative balance and phone profiling remain separate work. Preserve accepted heavy-family art; global legacy vertical-size cleanup is not claimed by this integration.
