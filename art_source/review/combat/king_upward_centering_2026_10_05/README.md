# Small upward body centering — 2026-10-05

Owner asks for less tilt in the upward attack's body and head together. Offline registration reduces upper-body lean halfway toward the carry head center, capped at4 logical texels (2 normal world pixels). Head/neck/shoulders receive one horizontal translation; torso rows taper toward untouched boot rows. The foreground hands follow the same transform before final sword grip registration. No runtime rotation, detached head movement, new source generation or skill/damage/timing change.

`motion.gif` is the actual Player queued five-hit chain in four facings with the unchanged axe,130 native frames at fixed60Hz simulation/30fps capture. GIF frame/loop metadata passes decode verification. `attacks/comparison.png` shows first/fourth ACTIVE examples before on the left and after on the right. `attacks/{before,after}/` each contains46 actual queued poses plus galleries/timelines; blank slots are unobserved release branches, not missing sprites.

Each `{sweep,rise,slam,turn,return}_body_comparison.png` contains five source moments: **top raw registered drawing; middle previous hair-only pose; bottom current slight body centering**. The correction is deliberately subtle and keeps some swing lean. Across54 tested generated poses, mean horizontal head lean drops from3.13 to1.31 logical texels. Head and collar remain joined; source torso colors remain exact at their translated positions.

Godot4.7.2 Compatibility results:

- Native full motion:2901 checks /0 failures, including connected anatomy, original head/steel, grips, queue/release, complete pose bounds, equal fourth/fifth timing and actual46px physical travel.
- Native readability/actual movement:158/0, including upward body/FX visibility, grounded bodies, proud idle, phase walking, knockback and dodge.
- Offline anatomical centering:216/0, covering54 generated up poses, decreased lean/4-texel limit, unchanged head height, exact translated collar/torso pixels and hair-only identity.
- `preservation_validation.json`:55 files compared; only15 up attack files change,40 other-facing/canonical/idle/run files remain byte-identical.
- `rebuild_validation.json`: all55 current runtime files reproduce byte-identically on a second offline rebuild.
- `import.log`: no script/resource errors. Source PNGs and white FX are unchanged. Prior cleanup/style/equipment/control evidence remains in `king_back_attachment_2026_10_05/`; it is not represented as newly rerun.

Rebuild with `--headless --path . --script tools/build_king_oathbound_greatsword.gd`, then import before testing. Run `tests/king_back_attachment_smoke.gd` headlessly. Native motion/readability commands accept `--output=res://art_source/review/combat/king_upward_centering_2026_10_05/`. Encode with `tools/build_king_axe_motion_gif.ps1 -ReviewFolder king_upward_centering_2026_10_05`. Native capture uses `tools/capture_king_upward_cut.gd -- --after`; an unflagged capture overwrites the before baseline, so preserve it during later tests.

Restart F5 → Sanctuary → F9 → Tab → Royal Greatsword → Equip → close Bag, then attack upward. F9 suppresses saving. Owner pose judgement remains open. No commit/push.
