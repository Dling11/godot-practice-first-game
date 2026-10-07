# Royal Greatsword and Iron Beard gameplay — 2026-10-05

**Current Iron Beard update (2026-10-06):** Equipped axe now uses five cuts: chop → rise → axe-head thrust → hop slam → spin, with all cardinal roots, connected queue endpoints and25/0/60% walking. The third pushes the actual cutting head along a78px lane and has four new broad white impact cels. Chain3.52s/6.15 base-hit units supersedes the preceding four-cut timing; native axe carry/gait, canonical steel and Greatsword remain. [Axe guide](king-axe-cardinal-motion.md). Campaign acquisition and family action art remain pending.

**Current animation replacement (2026-10-05):** Equipment/authority/practice controls remain. Basics now use [Oathbound](king-greatsword-oathbound-motion.md): new complete side/front/back bodies, protected identity,3.00s and matching0.54s fourth/fifth. Earlier motion timing/source claims below are historical.

**Current implementation:** [Oathbound motion](king-greatsword-oathbound-motion.md) owns the new complete body art, protected identity, queued/released branches and3.00s timing. Damage/contact, catalog/equip/input, carry/run/rest and acquisition rules remain as documented here; the older phase totals below are history. Sword size and established Spellward style remain.

## Previous cel motion follow-up (superseded)

Owner still found the fifth uneven after the earlier recovery-only adjustment and requested the same speed as the fourth plus missing top/bottom attacks. In this combo context, “fourth skill” means the fourth basic swing; Skill 4 remains the existing self-buff. This correction preserves the accepted huge steel, first four side-facing drawings, low return path and shallow planted/crossed-arm side idle.

Fourth and fifth each take 0.70s, with the same 0.22s contact phase. Fifth phases are 0.08s windup / 0.22s contact / 0.40s recovery. Its 16 existing chronological keys remain. Weighted recovery puts 0.128s into the low rear return (keys 7–10), then 0.272s into lifting/settling to carry (keys 11–15). This replaces the earlier uniformly timed 0.42s recovery and 0.78s cut; frame count does not set attack duration.

Weapon-angle interpolation follows the registered hand between return keys. Grip position stays pinned to the current drawn body cel; the foreground glove rotates with the rigid blade rather than drifting away from the arm. Bodies remain crisp cel art. Existing clips default to their original playback unless explicitly opted in.

## Previous front/back cel artwork (superseded for basic attacks)

Built-in imagegen supplied two body-only 48-key sheets: front-facing/down and back-facing/up. Raw PNGs, exact prompts, registration and provenance are under art_source/generated/characters/king/greatsword_cardinal_2026_10_05/. The offline builder tools/build_king_greatsword_cardinal.gd creates five attack clips, carry and eight-key travel-driven run per direction under assets/characters/playable/king/greatsword_cardinal/.

Both source sheets use one 54/136 density, nearest sampling, binary runtime alpha, 192×128 logical cells and ground Y95. Every direction uses the original 30×140 rigid steel, grip (15,113) and tip (15,0). Body/glove masks are registered to visible brown gloves. Runtime opening/carry and queued boundaries reuse exact registered cels rather than pretending every runtime slot is a unique generated drawing.

All four vertical combo handoffs clone the actual preceding contact-end body/grip into the next opening. Pending cuts hold that endpoint during recovery. Running carries the blade behind King and advances from actual collision-checked travel at 48px/cycle. Vertical basic strikes use front/back bodies; they do not rotate the side-facing body. White sampling follows the committed attack direction, and vertical slam impact is on its centerline.

New up/down carry has no invented planted AFK sequence. The existing side-facing proud idle is retained. Skills, evade, interactions, hurt and defeat still use existing integrated directional artwork. Iron Beard's up/down art remains legacy; only greatsword basic attacks/carry/run received this new cardinal set. Armor overlays, family-specific skills and other families remain future work.

## Play it

Restart any running game/review to load the new resources. F5 → Continue/New Journey → Sanctuary → F9 → Tab → select Royal Greatsword or Iron Beard Axe → EQUIP ITEM → close Tab. Left click attacks; SPACE dodges in actual gameplay. Enter an expedition or F7 Combat Lab to test enemies. F9 grants test gear and suppresses saving for that session; default equipment, existing save IDs and campaign recipes are unchanged.

Either focused review launcher supports Tab / Playable practice → actual Combat Lab with the reviewed weapon equipped, both families owned and a visible Bag. Esc resumes. SPACE attacks only in the focused review; actual Lab uses normal controls. Hidden review CharacterMenu input is disabled so it cannot open an invisible pause menu.

## Runtime ownership and numbers

- Catalog IDs: weapon_king_royal_greatsword and weapon_king_iron_beard_axe.
- Weapon definitions and immutable family combo resources own timing, physical contacts, damage and knockback. Review and production share these resources.
- Royal Greatsword: sweep → rise → meteor slam → turning cleave → low return. Nominal full chain 4.26s; 8.45 base-hit damage units; physical steps 8/10/12/8/8px. Fifth damage 190%, knockback 220%; rear follow-through is cosmetic and adds no rear contact. Nominal uninterrupted output 1.984 base units/s is provisional, before bonuses/misses/defense.
- Iron Beard: unchanged 3.60s / 6.10 base-hit units, 72px forward contact and 68px radial fifth with outward knockback. Approved V6 side body, back-mounted gait/rest and 20 white drawings remain.
- Both retain provisional 10–12 basic physical / 25 Skill Power for comparison. Attack-speed modifiers scale phase durations in MeleeAttackComponent. Campaign acquisition and final comparative balance remain pending Decision 180.
- Player owns primary/evade/skill input and one latest intent. Family primary buffers cover remaining committed cut + margin; deferred continuation lets finish observers settle. Planted retrieval resumes only a valid pending action.
- WeaponFamilyPresentationDefinition selects side/up/down attack, idle and run resources. PlayerWeaponFamilyPresentation swaps scene-owned observers on weapon/action/facing changes; null optional cardinal resources retain legacy bodies.
- Presentation profiles declare raster rows/origins/scale, SFX and optional step/impact/meteor/rear/plant effects. These create no damage; MeleeAttackComponent and MeleeStepMotion retain gameplay authority.
- Bag shows the equipped family's portrait stance and the actual Lab owns/binds CharacterMenu.

## Verification and evidence

Native Godot 4.7.2 Compatibility desktop:
- Final gameplay: 151 checks / 0 failures. Actual Sanctuary/F9/Bag equip; all five cuts and new directional bodies; travel-driven up/down gait/carry; buffered fifth; pause, planted draw, skill/evade fallback, switching, old snapshot restoration, real target and Stage I scene carry.
- Final motion: 143/0. Four installed Player presentations, equal fourth/fifth pacing, registered interpolated grip and all eight vertical endpoint→opening body/rig comparisons. Fourth→fifth finishes and returns to correct carry in each direction.
- Final practice input: 17/0. Physical Tab enters actual Lab, visible Bag owns pause, Esc resumes, F9/equip/movement/attack/HUD Bag work.
- This turn's preserved side-chain 240/0, planted 21/0 and axe gameplay 114/0 pass. Headless catalog/menu/buffer regressions pass. Relevant runtime import is clean.

Final logs, timeline, validation and 100-frame native GIF: art_source/review/combat/king_greatsword_final_motion_2026_10_05/. Preview uses a fixed 60Hz engine clock with 30fps native capture and rounded absolute GIF timestamps; renderer readback stalls do not stretch the exported attack. Real-time gameplay/input tests run separately without that capture clock. This is installed Player footage, not a concept storyboard or evidence of phone FPS.

Owner judgement of feel and comparative balance remains open. The earlier “slow fifth resolved” note was premature: owner rejected that first timing adjustment. Existing transition-fixture exit-only zero-reference/57-instance diagnostic remains unproven debt; this work does not claim its cause is fixed. Phone profiling and the existing global hitstop/manual-pause limitation remain outside this correction.

## Cleanup and next work

The previous cleanup archived four rejected return runtime folders and ten obsolete tools under art_source/archive/greatsword_rejected_returns_2026_10_05/, with .gdignore and MANIFEST.txt. Active code uses the shared extractor and does not load archived paths. Current source and evidence are retained for reproducible rebuilding.

Next: owner tests the connected motion described in king-greatsword-motion-polish.md. Keep the original huge steel and proud side idle; current attack motion follows the latest whole-combo redesign request. Other weapon and acquisition work remains outside this correction.

