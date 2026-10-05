# Royal Greatsword responsiveness — 2026-10-05

**Historical — superseded2026-10-05:** Owner rejects attack-start appearance changes. Decision183 replaces these mixed-source twelve-key attacks with fresh Oathbound complete bodies and thirteen-slot branches, also correcting the independent review slam/white-effect defects. Use [Oathbound motion](king-greatsword-oathbound-motion.md); runtime/test claims below are historical.

## Owner correction and resulting change

The owner rejects the modular-arm result: the whole body motion, grip and sword rotation are wrong, and it feels slow beside the accepted axe. This replaces Decision181's installed presentation. Its6468 geometry checks did not establish good animation.

Current game and review use complete existing Greatsword body/hand cels, with no new generation or detached arms. The five cuts take3.00s, down from4.26s. Axe remains unchanged at3.60s. Canonical30×140 steel, original carry/run/shallow planted idle,8.45 base-hit damage, frontal hit shapes/knockback and8/10/12/8/8px physical steps remain. Faster timing raises nominal throughput:2.82 base-hit units/s before defense/misses/gaps. Comparative campaign balance remains provisional.

| Move | Wind-up | Contact | Recovery | Total |
| --- | ---: | ---: | ---: | ---: |
| Opening cleave | .20 | .16 | .20 | .56 |
| Rising return | .16 | .16 | .18 | .50 |
| Meteor slam | .32 | .18 | .28 | .78 |
| Turning cleave | .18 | .18 | .18 | .54 |
| Low finishing return | .10 | .18 | .34 | .62 |

The rising anticipation omits the old backward-facing sword preparation. Slam uses the existing raised body poses during preparation, lands at ACTIVE and directs its side blade downward at contact. Each hilt stays on its drawn leading glove; other arm anatomy stays in the complete source cel. This is discrete cel animation, like the accepted axe, rather than independently rotated limbs over four repeated torsos.

## Data and playback

`tools/build_king_responsive_greatsword.gd` ingests complete original body/hand cells without density or palette changes. Side sources are confidence opening, original rise/meteor/turn and the installed low return. Up/down reuse the existing cardinal body cels. Outputs are fifteen twelve-key clips under `assets/characters/playable/king/greatsword_responsive/{side,up,down}/`; `registration.json` records source/key choices. No original source atlas is overwritten.

Each clip uses WIND_UP0–2, ACTIVE3–6 and ordinary RECOVERY7–9. Optional `queued_recovery_window=(10,11)` adds a complete moving branch when a primary is buffered. It continues from contact and prepares the next drawn chamber; the next opening inherits its full body/glove/steel/lift state. Released recovery finishes at original directional carry. A new WIND_UP snapshots the actual rendered full body/hand textures and steel basis for its opening cel, so standalone or late input does not teleport into a fabricated preceding chamber. Remaining keys are complete drawn cels.

The presenter uses its existing physics Tween and event-time buffer queries. Player/MeleeAttackComponent/MeleeStepMotion remain authority for buffering, damage and physical motion. No always-running limb solver is added. Experimental arm nodes allocate only if an explicitly experimental angle-track resource is selected; current game/review allocate none. Contact raster samples the current authored clip; rear return remains cosmetic and recovery-only.

Existing F9/Bag equipment access, Tab practice/visible Bag, skills/reactions and saves remain. The committed ability-phase visibility correction from the previous work is retained.

## Verification and review

Independent review of the live implementation passes native motion1230/0, gameplay151/0 and contact60/0, with all four directions now visible in the capture. Remaining defects: side slam steel/ground-burst registration is displaced; first vertical contact still uses a raised/opposite-direction blade cel; meteor-scale registration is applied to ordinary cuts and shrinks their white arcs. Review preserved production code/art/tuning. Evidence and recommended focused corrections: art_source/review/combat/king_greatsword_independent_review_2026_10_05/README.md. Owner feel and these presentation corrections remain open.

Native side-by-side motion capture uses the same fixed60Hz clock,30fps readback and actual buffered Player input for Greatsword and unchanged axe. The fixture also exercises mirrored/vertical Greatsword rigs, complete queued endpoints, visible leading-hand anchors, rigid steel, no allocated arm rig, standalone entry inheritance, release-to-carry, full five-hit input and46px travel. Final native motion **1230/0**,130 captured frames; real-time gameplay **151/0**, contact **60/0**, preserved idle/run/plant **101/0**. Generic melee/style checks pass. Rebuilding reproduces all46 PNG/TRES files byte-for-byte (SHA256). The two visible actors compare side motion; vertical visual judgement remains open.

`tests/king_greatsword_motion_smoke.gd` and `king_connected_greatsword_smoke.gd` route to the current responsive proof. The rejected geometry fixture is preserved in its original evidence folder as `historical_motion_test.gd`, outside runtime import. It does not describe current assets. Run the current proof with `--fixed-fps 60 --script res://tests/king_responsive_greatsword_smoke.gd -- --capture`; the fixed clock is required for the frame-count timeline. Encode with `tools/build_king_axe_motion_gif.ps1 -ResponsiveMotion`.

Preview/evidence: `art_source/review/combat/king_greatsword_responsive_2026_10_05/`. Launch `tools/launch_king_greatsword_review.ps1`; title **RESPONSIVE FULL-BODY COMBO**. SPACE/click attacks, A/D runs, Tab enters playable Lab/Bag. The existing axe remains the owner-accepted benchmark; this replacement is ready for comparison, not claimed owner-approved. Final feel, vertical visual judgement, phone profiling and comparative balance remain open. No commit/push.
