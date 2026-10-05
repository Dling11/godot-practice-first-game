# Greatsword readability proof — 2026-10-05

Native Godot4.7.2 Compatibility on AMD OpenGL. No user saves/rewards were written.

- `motion.gif`: decoded/verified130-frame actual Player comparison, fixed60Hz simulation and30fps readback. `motion_timeline.json` records phases and pose indices. Axe is the unchanged motion benchmark.
- `validation.json`:2901/0 motion/anatomy/identity/sole/cel-boundary/contact/continuity checks.
- `readability_validation.json`:158/0 centered vertical carry/proud idle, exact side gait head, four-direction plant/retrieval, actual held/diagonal movement by phase, full-speed release, knockback and dodge checks. Five paired native contact readbacks verify that no opaque interior body pixels are hidden by upward FX.
- `proud_all_directions.png`: final rest in right/left/up/down.
- `up_contact_0.png` through `up_contact_4.png`: actual upward contact cels with FX.
- `side_carry_run_before.png` / `side_carry_run_after.png`: original carry and all eight gait cels at nearest enlargement.
- `up_*_body_comparison.png`: raw registered source bodies above installed complete body cels. Carry and released endpoint overrides are expected.
- `gameplay_native.log`:151/0 real equipment/Bag/basic-input/action/vertical-motion checks. `contact_native.log`:60/0 damage/front contact/rear misses. `carry_native.log`:101/0 preserved side carry/gait/pride/action checks; images copied under `preserved/`.
- `rebuild_validation.json`: all55 runtime PNG/TRES hashes match after readability→import→Oathbound regeneration; `verified_import.log` contains final import.

Current five-hit timing/damage/reach remain unchanged. Walking uses25% wind-up /0% contact /60% recovery; collision steps and explicit third-hit lift remain. Technical verification is not owner approval or device profiling. Main guide: `docs/design/king-greatsword-oathbound-motion.md`.
