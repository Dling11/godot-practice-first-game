# Twinsteel walking grip correction — 2026-10-12

Owner accepts the preceding DOWN idle/attack polish for now and requests left/right and up/down walking correction. This pass replaces faulty blade attachment; it does not regenerate or resize the accepted King bodies.

## Cause and installed result

The shared-body builder ranked connected brown regions over each complete cel. Side shoulder regions sometimes outranked the hip glove, causing the near hilt to jump11–13 source pixels between keys. Vertical belt/boot regions sometimes outranked an actual palm, crossing a blade to the other side or lowering it onto a boot. Brown color and connectivity alone did not establish hand identity.

`tools/king_dual_gait_grips.gd` now records reviewed near/far palm coordinates for each of the24 facing/key combinations. The builder validates their native leather pixels and copies an11×11 region containing the complete fist/cuff border around each palm. These source masks paint over the rigid steel; they never redraw or translate an arm separately. Twinsteel selects sibling `shared_bodies/dual_gait_v2/{side,up,down}/run.tres` resources. Both blades retain their scale, side hidden rear handle and existing camera-relative depth. LEFT is the same mirrored side gait. All24 complete walking cels remain the exact same immutable body_library/v1 PNGs used by the other families. Natural authored body sway/arm swing remains.

Only three running selections change in the Twinsteel profile. Accepted attack/idle rasters, timings, weapon rules, other families, controls and saves remain exact. The earlier shared_bodies/dual walking resources stay as protected provenance/rollback dependencies.

## Native review and play

- [Original equipped frames](before.png), [corrected equipped frames](after.png), plus matching wider `before_full.png`/`after_full.png` captures include complete blade tips at the outer gallery columns. These render the actual equipped Player at the same nearest-neighbor3× zoom; they are still contact sheets, not a claim of owner motion approval.
- `source_side.png`, `source_up.png`, `source_down.png`: enlarged complete immutable walking cels used to identify real palms. The gait test also runs actual input-driven movement through every key in all four directions, real wall collisions, attack entry and released idle.
- Restart F5 → F9 → F7 → Weapons → Twinsteel. WASD walks, held world LMB attacks, Tab opens Bag, Escape closes it. Stop for four seconds to see the existing proud idle. `tools/launch_king_twinsteel_training.ps1` opens the actual non-saving Lab with Twinsteel equipped and three paused Rootlings.

## Reproduce

Use the installed Godot console with `--path .`. Rebuild with `--headless --script res://tools/build_king_shared_bodies.gd --quit-after 2`, then import with `--headless --editor --import --quit`. Render before/after with `--rendering-method gl_compatibility --audio-driver Dummy --fixed-fps 60 --script res://tools/review_king_dual_gait.gd --quit-after 300 -- --label=before_full` or `--label=after_full`. Before rendering reads the hash-protected old gait clips explicitly; archived family selectors retain absolute live paths and must not be mistaken for isolated dependencies.

Run `tests/king_dual_gait_smoke.gd` natively at fixed60fps with `--quit-after 1100`. Existing shared-body and gameplay checks accept `--output=res://art_source/review/combat/king_dual_gait_2026_10_12/` (use a `gameplay/` child for gameplay). Idle timing uses wall time, so omit fixed-fps and use its `idle/` child output. Frozen library verification remains `tools/check_king_body.gd`. No new runtime dependency or anatomy solver is installed.

## Scope of evidence

- `gait_checks.json`/`gait.log`:2070 checks,0 failures. Real four-direction input, all eight keys, both rendered grips, blocked-travel frame freeze, run-to-attack full-cel/grip continuity, idle settling, camera depth, cyclic palm-lane checks, canonical anatomy and1095 unchanged pre-existing King asset files. The stock selector is compared against the pre-work text with only its three running paths replaced.
- `body_checks.json`/`shared_body.log`:864 checks,0 failures, including every family gait's exact canonical pixels and existing Sword/axe preservation rules. `library.log`:all10 frozen complete body atlas hashes verified.
- `gameplay/validation.json`/`gameplay.log`:244 checks,0 failures through ordinary F9 ownership, actual Lab/Bag/equipment, four-facing queue/contact/slashes, skills and Stage I. This run exits without its previously recorded teardown warning.
- `idle/idle_checks.json`/`idle.log`:100 checks,0 failures through four-facing planted idle, timing, retrieval, movement cancellation and swap; clean exit. First glance begins2.485–2.514s after the plant/fold entry starts, preserving the1.10s entry plus1.40s neutral hold.
- `rebuild_checks.json`:96 existing/new shared `.png`/`.tres` outputs and both family selectors reproduce byte-identically; build exit0. `import_checks.json` verifies all three new masks use lossless compression, no mipmaps or alpha-border expansion; the existing presenter retains nearest filtering.
- [Pre-work snapshot](../../../archive/king_dual_gait_before_2026_10_12/README.md):1097 King asset/builder/selector files copied and independently SHA256-verified. The new regression protects1095 assets and allows only the explicitly scoped builder/selector changes. `final_preservation.json` confirms all1095 remain exact after the final rebuild and import.

Tests and static galleries do not establish owner walking-feel approval. No uncontended combat-performance, phone/export or campaign acquisition claim is made. Iron Reaper remains deferred until this walking review.
