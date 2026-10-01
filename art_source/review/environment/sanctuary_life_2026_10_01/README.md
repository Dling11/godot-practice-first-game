# Living Sanctuary native review — 2026-10-01

Verification: town-life91 rendered/82 headless checks; existing Sanctuary review108 rendered checks; production hub smoke passes. The renderer reports the pre-existing two5460-byte texture leaks/RenderingServer shutdown errors; these are not clean-exit claims.

Actual960x540 GPU captures from `sanctuary_refuge_review_smoke.gd` and `sanctuary_life_smoke.gd`. Default captures use1x gameplay camera, `*_detail_2x.png` use an explicit2x camera, overview uses.68x to show the complete map. Screenshots are gameplay renders, not generated concept composites.

- `life_admin_entry.png`: F10 button after normal hub entry.
- `life_town_map.png`, `life_tracking.png`: live M map and selected service guidance, contained above the action tray.
- `life_orren_greeting.png`, `life_eira_greeting.png`: attentive approach greetings, ground markers and cleared work corners.
- `life_noticeboard.png`, `life_canopy_fade.png`, `life_courier.png`: actual F board interaction, tree reveal and courier yielding/standing.
- `life_overview.png`: connected boundary/layout pass; other files preserve Orren/Eira portraits/services, original comparison and building depth.

F5 → Continue → F10 → SANCTUARY REVIEW · NO SAVES, or `tools/launch_sanctuary_study.ps1`. Starts beside Orren. M selects a destination; F talks or opens the map at the board. Original campaign art is retained; saving stays off until process restart. Owner art/gait/feel acceptance and mobile performance remain unverified. Shared GPU texture teardown warnings persist.
