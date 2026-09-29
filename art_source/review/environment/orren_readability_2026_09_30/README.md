# Orren readability V2

Owner approved the workshop/theme and requested a larger head, clearer body and bolder outer edges like King. Current generated source and exact prompt are in `art_source/generated/environment/sanctuary/orren_workshop_2026_09_30/idle_readable_source.png` and `READABILITY_PROMPT.md` (built-in image generation). Runtime atlas: `assets/characters/npcs/armskeeper/renewal/idle_work_v2.png`.

Eight unique96px cells; all body bounds35x60, fixed y80 feet, .5scale, named `idle_down` with endpoint holds. Matching portrait retained. New outlined name/role labels identify Orren without adding a shop or health bar. Previous source/atlas/captures retained.

78 rendered checks pass. `orren_native.png` is actual960x540 gameplay; `orren_detail_2x.png` is a2x camera for inspection. Other captures cover dialogue, roof fade, overview, comparison and services. Existing two5460-byte GPU shutdown texture leaks remain. No mobile profiling claim.

Run `tools/launch_sanctuary_study.ps1`, press F beside Orren, use top buttons to compare. New-chat continuation is in `CONTINUE_SANCTUARY.md`. Revised NPC still awaits owner acceptance; workshop is approved.
