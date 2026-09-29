# Orren and workshop playable review

Run `tools/launch_sanctuary_study.ps1`. It opens beside Orren; press F to talk and see his new portrait. The top buttons compare original/new art, visit either building and toggle overview. Closing dialogue resumes the working idle. Autosaves are suppressed. Doors reserve future interiors and do not currently open.

`orren_native.png` and `orren_dialogue.png` are actual960x540 viewport captures. `orren_detail_2x.png` uses a2x review camera to compare King and Orren more closely; it is not the default gameplay scale. Roof fade, overview, old comparison, lodge and Eira service captures are also retained. No composited mockups.

Validation:76 rendered assertions passed; production hub smoke passed. Checks cover collision and access, preserved service flow, real F dialogue, sprite registration/alpha/unique poses, eight-frame playback, talk/work transition and restoration of original art. Two pre-existing5460-byte GPU texture leaks and RenderingServer exit warnings persist. No mobile performance claim.

Only Orren is remodeled in this pass; Eira, Nema and Umi still await their sequential redesigns. Sources/prompts/rejected first sheet: `art_source/generated/environment/sanctuary/orren_workshop_2026_09_30/`. Plan: `docs/design/sanctuary-environment-renewal.md`.
