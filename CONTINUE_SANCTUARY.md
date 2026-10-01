# Sanctuary — temporarily complete

2026-10-02. Owner requested old-code/design cleanup and temporary closeout. **Do not resume a Sanctuary redesign by default.** Decision165 and docs/design/sanctuary-closeout.md own the current baseline.

Start meaningful work with PROJECT_CONTEXT.md, ROADMAP.md and KNOWN_ISSUES.md. Read GAME_DESIGN.md for design, ARCHITECTURE.md/STYLE_GUIDE.md for implementation, and relevant decisions. Preserve user changes; no commits or pushes.

## What runs

Normal F5 -> Continue, new game and expedition return use the renewed Sanctuary directly. Normal entry heals and saves; no debug controls or fixture rewards appear. Current King, all five accepted skills, workshop/furniture scale and F-required entry are preserved.

F talks to all four services. Eira is directly right of the lectern and opens Training after dialogue; Loadout arranges ten keys. Nema keeps canonical crafting and Umi keeps sale/reconstruction. M/minimap opens the service directory. Tab/bag opens searchable inventory; Esc closes menus. F at Orren's door enters; F inspects/leaves inside. Walking alone does not enter.

Current ground/buildings/map/theme, NPC names/markers/greetings, courier gait/dialogue, foliage and birds mount once through levels/sanctuary/town/sanctuary_town.gd. NPC scenes load renewed frame resources directly; one shared presenter handles planted work/dialogue holds. HP/growth/bag remain shared improvements.

## What was archived

art_source/archive/sanctuary_retired_2026_10_02/ preserves retired code/resources, UID/import sidecars, old comparison suites/processors and complete pre-closeout docs/code snapshots. .gdignore excludes it from Godot imports. README.md, retired_paths.json and file_manifest.json explain recovery. Current source art/prompts/builders and useful evidence remain.

Old/new comparison, legacy town instances and NPC idle helpers have no runtime fallback. The previous long handoff is preserved under snapshots/CONTINUE_SANCTUARY.md. Consult history for provenance, not current directions.

## Safe test

`powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_sanctuary_study.ps1 -InterfaceDemo`

Temporary XP/gold/materials at Nema; controls test XP, damage, heal and stage caps. -TrainingDemo gives temporary Level10 at Eira. F10 -> SANCTUARY TEST · NO SAVES enables visits/overview on the same town. Saving is suppressed before testing and stays suppressed until restart. Normal F5 saving remains active.

## Next work and limits

Move to expedition objective/reward feedback, then verify fight -> loot -> craft -> equip -> train. Sanctuary stays temporarily complete unless a concrete regression is reported. Further interiors/indoor audio, representative-phone performance and whole-kit balance are deferred. Existing GPU shutdown warnings remain.

Tests/evidence: CHANGELOG.md and docs/design/sanctuary-closeout.md. Temporary completion does not claim phone profiling or final balance approval.
