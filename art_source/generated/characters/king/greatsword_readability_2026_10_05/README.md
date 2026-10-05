# Greatsword readability source — 2026-10-05

Built-in imagegen tool mode. `vertical_pride_source.png` is the unchanged transparent output `exec-a74f652e-c1b4-49af-a89c-19bfa9da197a.png`. `pride_prompt.txt` is its exact prompt. References: installed side/front/back carry board and Oathbound back body source. Four front bodies and four back bodies supply preparation, release, folding and proud rest. No generated weapon is used.

`tools/build_king_greatsword_readability.gd` extracts complete bodies, uses fixed per-view density, registers soles at (96,95), applies the installed carry palette, attaches original head pixels at the drawn neck and records provenance in `registration.json`. Eight-slot vertical idle contains centered original carry at0–3 and generated rest4–7. Existing shallow planting/retrieval handles the canonical steel. Original carry sources remain intact.

The builder also derives side running from the original confidence V2 gait, preserving body motion and hand anchors while applying the exact carry head. Raised-crown glove restoration is disabled for running; only the actual holding glove may occlude the head. No alternate head palette is installed.

Runtime outputs: `assets/characters/playable/king/greatsword_readability/{up,down}/idle.tres`, `idle_body.png`, `idle_hands.png`, and `greatsword_readability/side/run.tres`, `run_body.png`, `run_hands.png`. Up/down original run clips remain in use. Sources and accepted original idle/gait are not overwritten.

Rebuild: run this builder headless, import, rebuild `tools/build_king_oathbound_greatsword.gd` against the revised vertical carry, then import again. PNG import sidecars retain nearest/lossless/no-mipmap settings with alpha-border fixing disabled. Manifest/provenance record SHA256. Current native art, movement and complete combo evidence: `art_source/review/combat/king_greatsword_readability_2026_10_05/`. Owner judgement remains open; no campaign equipment grant or recipe change.
