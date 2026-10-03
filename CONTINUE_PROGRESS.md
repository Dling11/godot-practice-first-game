# Continue Battle of Gods

Updated 2026-10-03. Workspace: D:/React_ONLY_2026/GODOT-BATTLE-OF-GODS.

## Read first

Read PROJECT_CONTEXT.md, ROADMAP.md and KNOWN_ISSUES.md, then this file. For this task read GAME_DESIGN.md, ARCHITECTURE.md, STYLE_GUIDE.md, Decisions119/129/172/173, docs/design/stage-exits-and-quiet-transitions.md and docs/design/stage-5-renewal-and-combat-polish.md. STORY_BIBLE.md and docs/design/divine-patrons-and-manufactured-invasion.md contain internal spoilers; never copy their reveal into early UI.

Do not commit, push, change branches or reset the dirty tree. This checkout contains substantial accepted work from the same conversation. Do not restore the normal player profile from an older hash or run tests that overwrite it; use SaveService suppression or isolated test storage.

## Owner's latest request and approvals

Owner asks to begin implementation and leave a reliable handoff because this may be the last prompt in this chat.

- All SIX threat portal concepts are selected. This is five existing destination tiers with TWO red Boss variants, not six new playable tiers.
- Normal blue/calm; Mini Boss purple/ominous; Boss red with grasping-hand or hungry-rim design; future God white-gold; future Transcendent near-black/violet.
- Destination threat decides the gate, not the stage just defeated. Current route: I→II blue, II→III purple, III→IV blue, IV→V red, V→VI blue, VI→Sanctuary blue.
- Portals requested here are STAGE-COMPLETION EXITS. Sanctuary portal stays outside scope.
- Generic quiet/mysterious loading screen: ENTERING THE NEXT STAGE, small seal, slim bar, light mascot movement, no fixed forest backdrop or spoilers. Progress must reflect actual loading; no artificial delay for the mascot.
- Loading/portal production comes first; title/homepage art and existing reward-chest renewal follow. Keep F interaction, chest contents, claim/bank/save order, existing controls and compact UI.
- New lore direction is documented under Decision172: apparent monster/demon invasion, credible divine aid, eventual patron reversal. Exact origins/powers/endings remain proposals. Do not implement or reveal those through artwork alone.

## Implemented and verified in this turn

Decision173 promotes the chosen portal/loading/title/chest presentation. Read docs/design/stage-exits-and-quiet-transitions.md for the detailed contract and docs/decisions/173-promote-threat-portals-and-quiet-stage-presentation.md for rationale.

- Six real eight-frame portal bodies are integrated under five tiers; Grasp/Maw are two red Boss variants. Current IV→V uses Grasp. Maw is a selectable review/authored alternate. God/Transcendent remain future-content artwork, not new playable routes.
- The existing separate16-frame lightning field stays active. It draws ABOVE terrain and BEHIND the body. Colored bodies are white-modulated to avoid double tint. One union/scale/origin per source loop preserves pose motion and ground anchors.
- QuietLoadingView composes a new generic navy background, animated gold seal, current outlined Spellward King walk, native labels and a280x16 rail. Actual resource fractions appear inside the bar. Loading does not wait for a mascot cycle.
- SceneTransition starts threaded resource IO before fading, polls only while pending, gets only a LOADED PackedScene, then installs/waits/reveals. Concurrent requests are rejected. Failure preserves the old scene/previous pause; title controls and nearby F prompts recover. Main-thread scene instantiation/GPU upload still need profiling.
- Normal title startup is re-arted to the same quiet seal palette. Native Continue/New Journey/Settings/Quit, valid-save gating, overwrite confirmation and focus remain.
- Existing Forest/Rootbound/Varkuun chests have new closed/open pairs registered to unchanged64x48/72x64/74x66 canvases. Chest reward script, contents, static footprint, III/V claims and bank/save rules are unchanged. No extra chests or story gifts added.
- Source sheets, exact prompts, normalization manifests, builders, native captures and recovery snapshots are saved in the repo. Archive is ignored by Godot; old shared PNGs retained for offline tools/recovery. No repo-wide deletion is claimed.

## Quick owner review

Run from the project:
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\launch_stage_presentation.ps1
```
It uses user://stage_presentation_review.json, including title/New Journey/real travel, so it cannot read/delete/write the ordinary profile. Six buttons show actual gates/FX beside native King and all chest states. Loading motion preview uses labelled fixed37%; Esc closes it. Test REAL loading enters normal StageI. Title / menu preview opens actual startup. Close/relaunch to return to the gallery.

F5 still opens normal title and ordinary Continue. Campaign clear exits require F; III/V require their chests first. Sanctuary portal is unchanged.

## Current verification

- Native stage_transition_presentation_smoke:54 checks,0 failures; actual paused transition advances seal/King6/12 frames. Headless focused presentation:45/0 with5/10 frames. Counts may vary with loader progress events.
- Native expedition_feedback_smoke:108 checks,0 failures after final runtime changes; ordinary I–IV and V guard/boss/chest/receipt/return/service/save/Continue flow retained.
- Native title_screen_smoke and title_continue_smoke pass, including focus/audio/overwrite/reset and genuine save restoration.
- Headless portal_interaction_smoke, scene_transition_smoke and stage_5_defeat_sequence_smoke pass. The first validates all six binary-alpha native loops, inner/rim motion, tier FX, real overlap, HUD prompt and F. Real II→III→IV install/health carry and Varkuun collapse/chest timing are retained.
- Logs/captures: art_source/review/ui/stage_presentation_2026_10_03/. GIFs: grasp_native.gif, maw_native.gif and loading_native.gif. GIF loading is a fixed37% motion rehearsal; loading_real_transition.png captures actual loading. Source frames retained.
- Ordinary player profile SHA256 remained61064D867D024D1F63491540ECF67F3118244177F2131724EEDDA79AD2EEF8BA. Never restore it if the owner plays later.
- Known existing GPU shutdown warnings persist:two Texture/RID allocations,5460bytes each, RenderingServer null. Some early-exit tests retain ObjectDB references. No whole-game performance or phone claim.

## Sources and builders

Approved source boards remain under art_source/generated/ui/threat_portal_previews_2026_10_03/ and quiet_threshold_previews_2026_10_03/. Their old boards/GIF are concept/rehearsal history, superseded by native implementation above.

Production source folders:

- art_source/generated/environment/portals/threat_family_2026_10_03/
- art_source/generated/ui/quiet_transition_2026_10_03/
- art_source/generated/environment/chests/renewal_2026_10_03/

Each has README.md/prompts.json; manifests record technical registration. Build threat art with tools/build_threat_transition_art.gd -- --art-only, editor --import, then -- --frames-only. Build chests with tools/build_reward_chest_art.gd, then editor --import. Do not crop/scale each animation pose independently or remove backgrounds using dark-color keys.

## Verified preceding baseline

Decision171 renews normal III/IV/V, adds campaign Rotcaller and fixes Skill1 repeated global hit pauses. III13roots+1caster/five live then solo Husk; IV60/eight live; V finite5roots+1caster/five live then Varkuun. StageApproachEncounter guard completion never banks the boss stage.

Prior checks:139 headless/native V environment/guards;47 rendered Rotcaller;42 native V review controls;27 device audio;108 native expedition→chest→receipt→Sanctuary/Nema/Eira/bag/save/Continue; III/IV137/153 navigation;10 pressure;49 Vow/Worldsplitter. Native Skill1 eight contacts/seven ticks retains0 global pauses. These results predate the current transition work; rerun affected checks after changes.

Original ordinary save SHA256 at turn start:61064D867D024D1F63491540ECF67F3118244177F2131724EEDDA79AD2EEF8BA. Path: C:/Users/Administrator/AppData/Roaming/Godot/app_userdata/Battle of Gods/battle_of_gods_profile.json. This is evidence, not an instruction to restore bytes; the owner may legitimately change it later.

Godot4.7 console: D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe. GUI: D:/WORK_APP/godot/Godot_v4.7-stable_win64.exe. PowerShell; AMD Compatibility graphics. Native WPF GIF encoder is available; ffmpeg/Python are not on PATH. Built-in imagegen works without CLI/API setup. Do not install media packages merely for previews.

## Runtime owners to inspect

- gameplay/encounters/stage_portal_art.gd: immutable six-family resource selection.
- gameplay/encounters/stage_portal.gd and .tscn: F proximity, destination tier, base/FX animation, player departure, travel failure restoration.
- autoload/scene_transition.gd: long-lived transition and input/pause ownership; threaded resource loading, generic QuietLoadingView, actual progress and failure restoration.
- gameplay/loot/stage_reward_chest.gd and .tscn: one-shot LootService claim, real closed/open state and footprint release.
- ui/screens/title/title_screen.gd and .tscn: valid-save Continue, guarded New Journey, session audio settings and focus.
- tests/portal_interaction_smoke.gd, tests/scene_transition_smoke.gd, tests/title_screen_smoke.gd, tests/title_continue_smoke.gd: existing contracts.

## Next work, in order

1. Read this handoff and inspect current engine captures; incorporate any owner feedback on compact hand/rim readability, FX contrast, title/loading pacing and chest scale. Do not ask the owner again to choose between the six accepted concepts.
2. Enemy emergence/arrival audio: a short readable ground warning/materialization, correct facing and one quiet cue per spawn/batch. Revalidate placement against King/obstacles/chest spaces. Compare one/three arrivals and normal IV eight-live pressure. Keep EncounterController/health/reward authority separate.
3. Combat contact sound/readability: blade/wood/armor/guard/interruption cues and bounded shared camera/audio per swing. Preserve Skill1's fixed repeated global pauses, contacts/reach/ranks and interrupt rules. Compare one/eight enemies with vulnerable King and actual gear.
4. Cold/warm physics/render/audio/VFX profiling; diagnose before pooling. Then pointer/movement polish, keeping keyboard/left-click/assisted controls and real footstep displacement.
5. StageVI muted teal altitude/stone/water renewal, warned Burrowkin prototype, useful entrance scout, saved Sanctuary reactions, authored lore/cache/breakables and Hunts remain later slices. Do not broaden into endless hordes/multiple casters without balance review.

Owner art/feel/audio mix/minimum-gear difficulty, phone performance and shared shutdown ownership remain open. Newly matched chest opening/arrival/hit audio is NOT delivered. Title/loading/gate/chest art IS delivered. The proposed divine powers, breach mechanisms, new gods/factions, clue placements and ending are NOT implemented. Internal lore must not become spoiler copy.

## Suggested next-chat message

Continue Battle of Gods in the same folder. Read PROJECT_CONTEXT.md, ROADMAP.md, KNOWN_ISSUES.md and CONTINUE_PROGRESS.md. Decision173 portal/loading/title/chest production is integrated and verified. Review the latest native captures, preserve the dirty tree and ordinary profile, then work on readable enemy emergence/arrival sound and combat contact audio under docs/design/stage-exits-and-quiet-transitions.md. Do not commit/push, change destination tiers/reward/save rules, reveal proposed lore or re-ask the six-portal selection.
