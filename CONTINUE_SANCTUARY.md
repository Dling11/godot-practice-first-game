# Continue Sanctuary renewal

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
