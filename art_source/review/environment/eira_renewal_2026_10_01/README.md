# Eira renewal in-engine review — 2026-10-01

Actual GPU captures from `tests/sanctuary_refuge_review_smoke.gd` at960x540. `eira_native.png` uses native1x camera; `eira_detail_2x.png` explicitly uses2x. `eira_dialogue.png` and `eira_skills.png` show real F interaction and retained service. Other captures cover Orren, comparison, overview and roof fade.108 rendered/94 headless checks pass. Shared GPU texture teardown warnings persist; mobile performance and owner visual acceptance remain unverified.

Run `tools/launch_sanctuary_study.ps1` to open beside Eira. F talks; complete dialogue opens skills; cancel returns to reading. Top controls visit Orren/Eira, compare original art/layout and overview/walk. Autosaving is suppressed; campaign art is unchanged.
