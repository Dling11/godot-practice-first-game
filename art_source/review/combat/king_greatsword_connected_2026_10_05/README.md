# Connected Greatsword native evidence — 2026-10-05

**Owner-rejected:** Body motion, grip/rotation and slow pacing are rejected compared to the accepted axe. These files preserve the experiment; the geometry counts do not establish good animation. Current installed proof is `king_greatsword_responsive_2026_10_05/`. `historical_motion_test.gd` preserves the old test, while the normal test entry now runs the replacement.

`motion.gif` is a 160-frame, looping four-facing capture of the installed Player presentation. It runs the real buffered five-hit chain, with the unchanged 30×140 weapon and 4.26s phase budget. The fixture enlarges the actors for inspection; normal game presentation remains half-scale.

`validation.json` records 6468 checks / 0 failures and 160 native images. `motion_timeline.json` records each facing's actual cut, phase, pose, hilt transform and arm reach. `rebuild_validation.json` records 48 PNG/TRES files with zero SHA256 differences after rebuilding. `preserved/` contains current run/carry/plant review screenshots; it does not overwrite earlier review evidence.

Other completed native checks: Player gameplay151/0, contact60/0, preserved run/plant101/0, planted21/0, practice input17/0, axe114/0. Generic headless melee/style checks also pass. Practice/axe scene transitions retain the documented exit-only ObjectDB leak diagnostic; these results do not resolve that separate debt. The older run test's render-clock timer sometimes expired after31 physics ticks (46.5px), despite correct focused running state. It now measures40 actual physics ticks and regains focus before testing travel.

Owner evaluation of feel/style and phone profiling remain open. Numeric continuity is not subjective animation approval. Source art, exact generation prompts and registration are in `art_source/generated/characters/king/greatsword_connected_2026_10_05/`; the first armor-style generation is rejected and has no runtime references. Full implementation details: `docs/design/king-greatsword-motion-polish.md`.

To inspect interactively, run `tools/launch_king_greatsword_review.ps1`, then choose **Play five-move combo**. SPACE/click attacks, A/D runs, and Tab opens playable Combat Lab with its visible Bag. This review suppresses saves/rewards.
