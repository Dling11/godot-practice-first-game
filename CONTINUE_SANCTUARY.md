# Continue Sanctuary renewal

## Latest continuation - Eira mentor curriculum, 2026-10-02

Read required docs, then docs/design/sanctuary-npc-usability.md and Decision164. Eira is DIRECTLY RIGHT of the book at384,410 on the same foot baseline; approach384,446. F/dialogue opens Training directly. Five-technique current/next effects and reachable free ranks: Earth2, Molten3/6/9, Pursuit5/8, Vow7/10, World8/10. Earth/Molten ranks save compatibly; custom hotkeys remain. Loadout separately offers swap/clear/core restore. Esc from Eira resumes play; ordinary inventory retains its nested return.

Test immediately: `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_sanctuary_study.ps1 -TrainingDemo` opens temporary Level10 beside Eira with saves suppressed. Or F5 -> Continue -> F10 -> SANCTUARY REVIEW -> Visit Eira -> F -> finish/skip dialogue. Native evidence: art_source/review/ui/eira_training_v2_2026_10_02/. 84 rendered flow,91 curriculum,64 interface,94 study,14 World training,49 combined combat checks and menu/progression/production kit smoke pass. Baseline GPU shutdown warnings remain.

Next: owner usability/balance feedback, then Nema crafting/Umi exchange clarity and feedback. Further houses/interiors are deferred; retain accepted furniture and F-required entry. Preserve user changes; do not commit or push. Phone profiling/campaign art promotion remain separate. Earlier positions400,450/400,486, two-step menu routes, Lab-only Skills1/2 and World10/15 gates below are superseded.

## Current continuation - NPC service usability, 2026-10-02

Owner redirected work away from further houses/interiors toward NPC function, layout and skill arrangement. Read required project docs, then `docs/design/sanctuary-npc-usability.md`. Eira is now right of her lectern at400,450 with a400,486 approach; labels clear the books and the nearby lamp moves to456,432. Current five-skill dialogue replaces retired names. Shared Skills has two rows of five capped icons, TRAIN & ARRANGE through Eira, ARRANGE SKILLS through ordinary inventory, explicit training requirements and swap/clear/restore feedback with retained focus. Existing authority and progression remain.

**Test:** F5 -> Continue -> F10 -> SANCTUARY REVIEW -> Visit Eira -> F -> finish/skip dialogue -> TRAIN & ARRANGE. Select a technique, click a slot to swap/assign, right-click or Clear selected slot to clear, Restore core layout to restore. Esc returns, then closes Skills. The launcher accepts `--eira` after `--`. Review saving stays suppressed until restart.

**Verified:** 43 rendered functional checks, 64 rendered interface checks, character menu/Pursuit trainer persistence smoke, 14 each Vow/Worldsplitter training checks, 90/94 headless courtyard/study checks. Evidence: `art_source/review/ui/sanctuary_functionality_2026_10_02/`. Existing shared GPU teardown warnings remain.

**Next:** owner service-flow review, then Nema crafting and Umi exchange clarity/requirements/result feedback and skill-menu polish. Additional houses/interiors are deferred by owner direction; earlier interior-first recommendations are superseded. Retain accepted furniture scale, F-required workshop entry, user changes and no-commit/no-push boundary. Campaign promotion and phone profiling remain separate work.

## Current continuation - first workshop interior, 2026-10-02

Read the required docs, then `docs/design/sanctuary-workshop-interior.md`. One walkable Orren workshop now connects to the accepted courtyard exterior. It has separate generated room/furniture sprites, measured collision, mouse navigation around the bench, forge embers and three F inspection points. Orren remains outside at his station. The owner-reported oversized furniture is corrected in V2, with a smaller room and furniture calibrated against unchanged King. Owner accepted the current furniture size for now; retain it. Entry requires F, with the restored PRESS F · ENTER WORKSHOP prompt available even at the doorstep; walking alone does not enter. Previous house/UI/NPC/ambient changes remain.

**Test:** F5 -> Continue -> F10 -> SANCTUARY REVIEW -> **Workshop door**, then approach the door and press F to enter. WASD walks; right click routes to a spot; F inspects the bench/forge/rack; F at the south opening returns. Tab inventory and Esc pause work indoors. Review saves remain suppressed until restart. Other interiors and campaign promotion remain pending.

**Verified:** 60 rendered interior checks, 63 rendered interface checks, 90 headless courtyard checks, 94 headless study checks and production hub smoke pass. Native images: `art_source/review/environment/orren_interior_manual_entry_2026_10_02/`. Shared GPU teardown warnings remain.

**Next:** follow the NPC-usability priority above. Further Eira/Nema/Umi interiors are deferred; indoor audio, phone profiling and deliberate campaign promotion remain pending. Scale approval does not approve the whole room or promote it to campaign. Preserve user changes and do not commit/push. Earlier all-interiors-planned descriptions below are superseded for Orren only.

## Current continuation - house perspective and interface, 2026-10-01

Read the required project docs, then `docs/design/sanctuary-interface-renewal.md`. The owner rejected diagonal artisan-house perspective. New Nema/Umi houses preserve the overhead Orren baseline with entrances positioned left. Added a top-right parchment minimap, smaller action frame and generated slate/gold/ivory/amethyst theme for dialogue, inventory, skills, technique collection and service/pause menus. Nema recipe overflow is fixed through a bounded scrolling body. Previous NPC, courier, foliage and bird work remains.

**Test:** F5 -> Continue -> F10 -> SANCTUARY REVIEW, or the existing launcher. Visit Nema/Umi, click the corner map or press M, F talk, Tab inventory; complete Eira dialogue for skills. Compare restores previous presentation. Saving stays suppressed until process restart; campaign art/theme is not promoted. The smaller-skills request was interpreted as the bottom HUD, retaining native button/icon sizes and combat effects.

**Verified:** 63 rendered interface checks, 99 courtyard checks, 95 town-life checks, 108 existing study checks, production hub and crafting-service smoke pass. Native UI evidence: `art_source/review/ui/sanctuary_theme_2026_10_01/`. Shared GPU teardown warnings remain.

**Next:** owner perspective/UI judgment, interiors and phone profiling before deliberate campaign promotion. Preserve user changes; do not commit/push. Earlier sections below describe superseded house/UI iterations.

## Current continuation — courtyard correction and Nema/Umi, 2026-10-01

Read the required project docs, then `docs/design/sanctuary-courtyard-renewal.md`. The owner authorized continuing after rejecting gliding courier legs, Eira's road placement and static surroundings. Implemented: contact/passing gait driven by distance, an off-road teaching nook, Nema and Umi working sprites/portraits and angled houses, foliage wind, two occasional swallows, and F dialogue with Rowan. NPC service authority and King are retained.

**Test:** F5 -> Continue -> F10 -> SANCTUARY REVIEW, or `tools/launch_sanctuary_study.ps1`. Visit Nema/Umi, Find Rowan, F talk, M map; step away from Rowan to watch him resume. Compare restores old art/layout, but saves remain suppressed until process restart. Campaign art is not promoted.

**Verified:** 99 rendered courtyard checks, 95 town-life checks, 108 existing study checks and production hub smoke pass. Courtyard tests exercise real F/cancel/complete/menu flow, eight-pose playback, original restoration, road/door access, physical blockage/distance cadence, service priority, roof reveal and birds. Native images: `art_source/review/environment/sanctuary_courtyards_2026_10_01/`. Shared GPU teardown warnings remain.

**Next:** owner native-scale gait/composition/identity review, one complete interior proof, phone profiling and deliberate promotion. Nema/Umi are implemented candidates, not approved content. Preserve user changes; do not commit/push.

Everything below is historical where it describes the earlier town iteration or says Nema/Umi are pending.

## Current continuation — inhabited town, 2026-10-01

Verified: town-life suite91 rendered/82 headless checks, existing Sanctuary review108 rendered checks, production hub smoke and `git diff --check` pass. Shared GPU texture shutdown warnings remain. No commit, branch switch or push was performed.

Owner's latest screenshot request: remove Orren's obsolete red cart, replace old trees in the approved theme, give walls intentional layout, make NPCs stand out/react and add a walking civilian. Decision163 implements this **only in the optional study**. Accepted workshop/lodge, King, services and saves remain the boundaries.

**Test directly from Godot:** F5 → Continue → F10 → **SANCTUARY REVIEW · NO SAVES**. Or run `tools/launch_sanctuary_study.ps1`. Both start beside Orren. **M** opens the town map; choose an NPC/gate for a direction cue and highlighted ground ring. **F** talks or opens the map at the noticeboard south-west of the fountain. Top buttons compare old/new, visit Orren/Eira and switch overview/walk. Saving is suppressed until process restart, including old comparison.

The new view replaces the red cart and six legacy trees with planted linden/cedar trees, anvil/tool station, Eira lectern, noticeboard and connected intact limestone boundaries. Trees fade when King walks behind their canopy; small separate footprints preserve access. All four service NPCs have labels, role-colored rings and20-second-throttled greetings. Orren/Eira look up for1.1seconds, then resume work. The generated teal courier walks a fixed circuit, rests near Eira/Orren with dedicated standing frames and yields near King. No shop, interior, reward or new service authority was added.

Implementation: `town_dressing.gd`, `town_map.gd`, `town_map_drawing.gd`, `town_noticeboard.gd` under `levels/sanctuary/review/`; reusable `entities/npcs/presentation/service_beacon.gd`; `entities/npcs/courier/sanctuary_courier.gd`. Art builder `tools/build_sanctuary_life_art.gd`; assets under `assets/environment/sanctuary/inhabited/` and `assets/characters/npcs/courier/`. Sources/exact prompts retained in identity-owned `art_source/generated/.../inhabited_2026_10_01/` folders. Native evidence: `art_source/review/environment/sanctuary_life_2026_10_01/`.

**Next:** owner native-scale review of composition, discovery, greetings and courier gait/pacing; then Nema/Umi individually, one interior proof and deliberate campaign promotion. Do not automatically promote or batch-redesign remaining service characters. Read `docs/design/sanctuary-environment-renewal.md` and Decision163. Earlier handoff sections below are historical where they say Eira is next, the old cart/trees remain, or launch starts beside Eira.

## Earlier Eira continuation — 2026-10-01

Orren V2 was reviewed at native/2x scale beside King and retained as Eira's scale reference following the owner's confirmation. Eira now has eight generated reading/page-turn poses, a matching96px portrait and Eira/Skillkeeper nameplate beside the accepted lodge at288,438. Her feet stay registered at y80 in96px cells;60–61px body, half-scale presentation, binary alpha and nearest filtering. Her actual hands/page/head animate; the old whole-body idle helper and floating aura are disabled only in the study.

`tools/launch_sanctuary_study.ps1` now opens beside **Eira**. Press **F** for the portrait/dialogue, finish dialogue for existing skills, or cancel to resume reading. Top buttons: Compare old environment, Visit Orren, Visit Eira, Overview/walk. Original Eira position/art/portrait/aura/idle return in old comparison. Services, body/trigger resources, saves, King and approved buildings are preserved.

New files: `levels/sanctuary/review/eira_renewal_review.gd`, `tools/build_eira_renewal.gd`, `assets/characters/npcs/skillkeeper/renewal/`, and `art_source/generated/characters/npcs/eira/renewal_2026_10_01/` (sources, exact prompts, manifest). Current captures: `art_source/review/environment/eira_renewal_2026_10_01/`;108 rendered checks/94 headless checks pass, including real F, canceled/completed dialogue, service resume, all-eight playback, body/trigger preservation and old/new restoration. Production hub smoke passes. Shared GPU texture teardown warnings remain.

**Next:** Owner visual review of Eira before moving to Nema and Umi individually. Interiors and campaign promotion remain planned. The September30 handoff below is historical where it says Eira is unimplemented, Orren approval is next, or the launcher starts beside Orren.

Handoff requested by the owner on 2026-09-30 for a new chat in the SAME project: `D:\React_ONLY_2026\GODOT-BATTLE-OF-GODS`.

Read `PROJECT_CONTEXT.md`, `ROADMAP.md`, `KNOWN_ISSUES.md`, then this file and `docs/design/sanctuary-environment-renewal.md`. Inspect live files before acting. The working tree contains this work and the previous portal collision/test repair; preserve it. Do not commit or push for the owner.

## Latest owner decisions

- Owner loves the new Orren workshop/house and the fantasy Sanctuary theme. Keep the accepted building and environment direction. They want a noticeable MMORPG-style inhabited settlement, clear NPC identity and purposeful buildings.
- Previous Orren was too small, especially his head; King had bolder outlines. A new generated readability revision is now installed in the OPTIONAL study: larger head, broader silhouette, stronger dark outlines, 60px source body at half scale (30 logical px), matching King better. All eight frames share the foot baseline and reference height. Await owner judgment of this revision before making more NPC sheets.
- Added reusable name/role presentation: Orren / Armskeeper, outlined text with a brighter near-interaction state. This is presentation only; Orren still has dialogue, not a shop.
- The workshop and portrait stay as accepted; current King art and Skills1–5 are accepted. Do not regenerate King or restart skill design.
- All NPCs must eventually be remodeled, but gradually. Orren first, Eira next beside her lodge, then Nema and Umi with their environments. New portraits and real role-specific idle poses are required. No whole-body wobbling as a substitute for animation. Keep service functions and body/interaction authority.
- Houses should eventually support approach -> enter -> interior -> safe return. This is planned; current doorway markers DO NOT constitute implemented interiors.

## What runs now

Run `./tools/launch_sanctuary_study.ps1` from the project. Godot GUI: `D:/WORK_APP/godot/Godot_v4.7-stable_win64.exe`; console variant in the same folder. Review opens beside Orren. F opens his portrait/dialogue; closing it resumes blade inspection. Top buttons: Compare old environment, Visit Orren, Visit lodge, Overview/walk. Autosaves are suppressed.

The review uses the REAL Sanctuary hub/services with an optional presentation/layout overlay. The default campaign still has its old NPC/building art. Do not claim the entire Sanctuary or all NPCs are replaced. Comparison restores original Orren frames, portrait, position and idle helper plus original workshop/collision.

## Relevant files

- `levels/sanctuary/review/refuge_study.gd`: overlay, controls and comparison.
- `levels/sanctuary/review/orren_workshop_review.gd`: workshop, Orren adapter, dialogue-pose hold/resume, retained service authority.
- `entities/npcs/presentation/npc_nameplate.gd`: reusable name/role labels; only Orren currently uses it in this review.
- `levels/sanctuary/review/refuge_ground.gd`:32px ground and courtyard paths over1152x768.
- `assets/characters/npcs/armskeeper/renewal/idle_work_v2.png`: active eight96px-cell atlas; `idle_work.png` is the prior smaller version, retained.
- `assets/characters/npcs/armskeeper/renewal/portrait.png`:96px portrait.
- `assets/environment/sanctuary/refuge_review/orren_workshop.png`: approved workshop,320x224 with door anchor160,208.
- `art_source/generated/environment/sanctuary/orren_workshop_2026_09_30/`: original/rejected/revised sources, exact prompts and normalization manifests. Current source is `idle_readable_source.png`; see `READABILITY_PROMPT.md`.
- `tools/build_orren_workshop_review.gd`: builder for current source. Keeps binary alpha, one shared scale, padded cells and foot baseline80. Runtime named `idle_down` uses5fps with endpoint holds. Import after rebuilding.
- `art_source/review/environment/orren_readability_2026_09_30/`: latest native captures; `orren_detail_2x.png` explicitly uses a2x camera. Prior review captures remain under `orren_workshop_2026_09_30/`.

## Verification and limits

Latest rendered `tests/sanctuary_refuge_review_smoke.gd`:78 checks,0 failures. Covers routes, buildings' collisions/roof fade, unique registered frames and all-eight playback, real F interaction, dialogue pause/resume, existing NPC services, save suppression and old/new restoration including nameplate visibility. Production `tests/sanctuary_hub_smoke.gd` also passes. Existing shared GPU shutdown warnings persist (two5460-byte texture leaks / RenderingServer null); they are not a clean-exit claim. Mobile performance remains unverified.

Commands:

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --path . --resolution 960x540 --script res://tests/sanctuary_refuge_review_smoke.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tests/sanctuary_hub_smoke.gd
./tools/launch_sanctuary_study.ps1
```

## Continue from here

First respond to owner feedback on Orren's new proportions/outline/nameplate, using live native-size evidence. If accepted, work on Eira's identity, portrait and genuine idle beside the accepted trainer lodge. Use current King and revised Orren as style/scale references, not only numerical height. Preserve workshop/theme and working skills. Keep generated sources/rejected variants, test in-engine, and update routed docs. Later complete Nema/Umi, one interior proof and accepted campaign promotion. Do not redesign every NPC in one unreviewed batch.
