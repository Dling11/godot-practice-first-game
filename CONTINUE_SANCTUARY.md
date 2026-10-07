# Sanctuary — temporarily complete

2026-10-02. Owner requested old-code/design cleanup and temporary closeout. **Do not resume a Sanctuary redesign by default.** Decision165 and docs/design/sanctuary-closeout.md own the current baseline.

Start meaningful work with PROJECT_CONTEXT.md, ROADMAP.md and KNOWN_ISSUES.md. Read GAME_DESIGN.md for design, ARCHITECTURE.md/STYLE_GUIDE.md for implementation, and relevant decisions. Preserve user changes; no commits or pushes.

## What runs

Normal F5 -> Continue, new game and expedition return use the renewed Sanctuary directly. Normal entry heals and saves; no debug controls or fixture rewards appear. Current King, all five accepted skills, workshop/furniture scale and F-required entry are preserved.

F talks to all four services. Eira is directly right of the lectern and opens Training after dialogue; Loadout arranges ten keys. Nema keeps canonical crafting and Umi keeps sale/reconstruction. Map/minimap/directory and M/noticeboard map interaction are temporarily hidden (TownMap.PRESENTATION_ENABLED=false). Tab/bag opens searchable inventory with centered King; Esc closes menus. F at Orren's door enters; F inspects/leaves inside. Walking alone does not enter. Compact248x64 Portrait Link puts HP/XP digits inside bars; owner-selected A Centered Paperdoll is live, with five paired equipment rows around King, real details at right and the bag below. Frame/slot silhouettes/sword source prompts are under art_source/generated/ui/centered_paperdoll_2026_10_02/;87 rendered interface/14 demo/68 town checks pass. B/C remain unselected concepts.

Current ground/buildings/map/theme, NPC names/markers/greetings, courier gait/dialogue, foliage and birds mount once through levels/sanctuary/town/sanctuary_town.gd. NPC scenes load renewed frame resources directly; one shared presenter handles planted work/dialogue holds. HP/growth/bag remain shared improvements.

## What was archived

art_source/archive/sanctuary_retired_2026_10_02/ preserves retired code/resources, UID/import sidecars, old comparison suites/processors and complete pre-closeout docs/code snapshots. .gdignore excludes it from Godot imports. README.md, retired_paths.json and file_manifest.json explain recovery. Current source art/prompts/builders and useful evidence remain.

Old/new comparison, legacy town instances and NPC idle helpers have no runtime fallback. The previous long handoff is preserved under snapshots/CONTINUE_SANCTUARY.md. Consult history for provenance, not current directions.

## Safe test

`powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_sanctuary_study.ps1 -InterfaceDemo`

Temporary XP/gold/materials at Nema; controls test XP, damage, heal and stage caps. -TrainingDemo gives temporary Level10 at Eira. F10 -> SANCTUARY TEST · NO SAVES enables visits/overview on the same town. Saving is suppressed before testing and stays suppressed until restart. Normal F5 saving remains active.

## Next work and limits

Current combat work is the equipped Iron Beard five-hit exchange: chop → rising cut → axe-head thrust → hop slam → whirlwind. Third hit pushes the cutting head forward with broad white impact frames; connected queued poses, planted contact and complete slashes remain. The previous four-cut assembly and rejected handle jab are archived. See [current guide](docs/design/king-axe-cardinal-motion.md) and CONTINUE_PROGRESS.md. Accepted Sanctuary and native axe idle/gait remain preserved.

Expedition objectives/reward receipts are implemented for Stages I–VI;81 rendered checks verify fight -> loot -> return -> craft -> equip -> train -> save/Continue with explicit fixtures. Use tools/launch_expedition_review.ps1 for a no-save interactive review and read docs/design/expedition-objectives-and-receipts.md. Next: owner loop review, measured balance and replayable Hunts. Sanctuary stays temporarily complete unless a concrete regression is reported. Further interiors/indoor audio, representative-phone performance and whole-kit balance are deferred. Existing GPU shutdown warnings remain.

Tests/evidence: CHANGELOG.md and docs/design/sanctuary-closeout.md. Temporary completion does not claim phone profiling or final balance approval.
