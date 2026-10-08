# Axe vertical anatomy and motion correction

Completed2026-10-08; source generation began2026-10-07. Installed on normal Iron Beard equipment for owner review. This replaces Decision193's rejected vertical bodies. It is not a claim of owner appearance/feel acceptance.

[Animated actual Player capture](motion.gif) · [landing contact](complete_slash_3.png) · [before anatomy comparison](identity_before.png) · [new source sheets and exact built-in prompts](../../../generated/characters/king/axe_identity_lock_2026_10_07/README.md) · [immutable King tracing reference](../../../reference/characters/king/native_identity_v1/README.md) · [current axe rules](../../../../docs/design/king-axe-cardinal-motion.md).

The fresh source sheets contain complete UP/DOWN chop/rise/head-push/jump/turn bodies with offline colored weapon guides. Registered native heads, collar/armor density and sole94 replace generated source hair and boot-driven sideways registration. The rear source landing that faced the camera is rejected in favor of this new sheet's rear compression. The compressed front hidden collar is traced explicitly. Actual leather palms hold the unchanged canonical steel. No per-pose actor zoom or invented arm bridge. Vertical carry/run use the same frozen identity; accepted axe side attacks/carry/gait remain exact.

Thirteen keys separate load/contact/release/queue. Exact body/grip endpoints meet ready or the next cut. Existing camera-authored FX are retained; the optional new scene registers only the vertical jump to its rendered blade. All side/non-landing effects retain the configured(0,-16) origin. Player/Melee/held input,3.19s phases, damage/reach/knockback/audio and save IDs remain.

## Verification

- `native.log` / `validation.json`:2858 checks,0 failures;132 native actual Player frames, four facings, queued five-hit chains, exact registration/default FX origins, complete slash boundaries, head-led thrust, landing alignment, travel/stow/draw. `motion_timeline.json` identifies each cut/phase/pose; `motion_frames/` retains all frames, GIF samples every second frame at15fps.
- `gameplay.log`:138 checks,0 failures in the actual Lab/Player/Bag, normal controls/equip/queue/contact and available families. Existing57-object fixture-exit warning remains.
- [Shared anatomy audit](../king_dual_identity_lock_2026_10_08/anatomy_checks.json):1068 checks,0 failures across251 registered poses; connected anatomy, native crowns, real palms, source guide removal, padded cells and exact Greatsword-derived dual side gait.
- `reproducibility.json`:69 of69 combined axe/dual PNG/TRES/scene outputs rebuild identically. `imports.json`:44 PNG imports are lossless, no mipmaps, alpha-border repair disabled.
- `before_manifest.json` / `before/`:472 verified pre-work files. `preservation.json`:469 unchanged; only the two selected family profiles and axe verification script change. Accepted Greatsword/axe-side pixels/resources remain exact. Shared swing-script changes and new sibling assets are explicitly described above; the manifest is not a full-project snapshot.

Correctness/capture timing is not a device performance benchmark. Owner feel, comparative campaign balance, acquisition and cold/phone/export profiling remain open. Iron Reaper remains deferred. Rejected debug probes are retained only under `diagnostics/`, outside imports.

## Rebuild and play

Use `D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe` (actual4.7.2): `--headless --path . --script res://tools/build_king_axe_identity_lock.gd`, then `--headless --editor --path . --import --quit`. The builder writes sibling PNG/TRES, candidate `axe_identity_lock/presentation.tres`, scene and source registration; the stock profile has already been promoted. Keep frozen reference and original generated sources intact.

Restart F5 → F9 → F7 → Weapons → Iron Beard Axe. WASD moves, held LMB repeats ordinary attacks, Space dodges, Tab opens Bag, Escape closes it. Or run `tools/launch_king_axe_training.ps1` from the repository: the actual Lab uses isolated storage and suppresses autosaving. Weapons/Bag can switch to the corrected Twinsteel. No commits/pushes/branch changes.
