# Front → return → spin → jump preview

2026-10-06. Current Greatsword-only sample. `motion.gif` has207 decoder-verified native frames and60Hz-derived timing. It shows accepted side gait,120° front slash,120° return, full-body360° spin and jump strike at3× normal world scale. This is presentation review; F5 remains accepted Oathbound.

Right1507/0 and left1507/0 native Compatibility checks pass. `checks.json`, `native.log`, `native_left.log`, `motion_timeline.json` and `left/` retain evidence. Four contact PNGs show the active poses. Validations include native head/grip connectivity, exact angles/boundaries, canonical steel, all rendered blade/FX margins, jump landing and facing/replay controls. The deterministic clock is not a performance benchmark or combat authority.

`rebuild.json` records13 byte-identical generated PNG/TRES outputs. `preservation.json` records the original backup and667 unchanged protected runtime files. Asset source/prompts/registration are retained separately. Previous first-study/scythe resources and tooling are archived, with no active scythe switch.

Replay with `tools/launch_king_heavy_burst_review.ps1`: Space replay, A/D facing, Escape close. Re-render with `tools/review_king_front_combo.gd -- --capture` or `--capture --left`, using Compatibility, Dummy audio and `--fixed-fps 60`. Encode with `tools/build_king_axe_motion_gif.ps1 -ReviewFolder king_greatsword_front_combo_2026_10_06 -FinalDelayMs 350`.

[Design and next work](../../../../docs/design/king-greatsword-front-combo.md). Owner feel choice, true vertical attacks, real Player integration and balance remain pending. Scythe is deferred.
