# Responsive Greatsword comparison — 2026-10-05

Current replacement after owner rejection of the detached-arm motion, grip/rotation and slow pacing. No new image generation: complete installed body/hand cels are reused at their original density/palette. Canonical steel is30×140. Greatsword3.00s and unchanged axe3.60s share the same fixed engine clock and real buffered Player input in `motion.gif`.

`validation.json`: native motion1230/0,130 images at30fps from a fixed60Hz engine clock. The two visible actors compare right-facing motion; mirrored/up/down rigs are also exercised outside the capture viewport. `motion_timeline.json` records all five actors' cut/phase/pose/grip/blade direction. Final native gameplay151/0, contact60/0 and preserved idle/run/plant101/0 pass. Generic headless melee/style checks pass. `rebuild_validation.json` records46 PNG/TRES files with zero SHA256 differences after rebuilding; GIF encoding/decoding verifies130 frames.

Checks cover complete moving queued/released branches, every drawn leading-glove hilt anchor, rigid steel, no allocated detached-arm rig, full-pose queued endpoints, actual rendered standalone opening inheritance, all five buffered hits, released carry and46px physical travel. They do not establish owner approval or phone performance. Faster timing raises nominal damage throughput; comparative balance remains provisional. Existing scene-transition exit-only ObjectDB diagnostics remain separate debt.

Rebuild using `tools/build_king_responsive_greatsword.gd`, then import. `assets/characters/playable/king/greatsword_responsive/registration.json` records all original source cells and chamber choices. The earlier modular experiment and prompts remain outside current runtime references. Current guide: `docs/design/king-greatsword-responsive-motion.md`.

Review: run `tools/launch_king_greatsword_review.ps1`, click **Play five-move combo**. SPACE/click attacks, A/D runs, Tab enters playable Lab with visible Bag. No saves/rewards. Owner assessment of the replacement remains open; no commit/push.
