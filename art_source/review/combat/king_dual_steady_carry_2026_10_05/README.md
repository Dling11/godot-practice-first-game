# Twinsteel — steady carry and planted idle

2026-10-05. Historical, partially accepted carry pass. Owner subsequently requests closer hip fists, smaller blades/handles and a very small cardinal tilt. Current implementation/evidence: [compact hip carry](../king_dual_compact_carry_2026_10_05/README.md). This folder preserves the previous **STEADY CARRY & PLANTED IDLE** version.

- Front idle keeps the accepted native head/neck/torso/empty hands. BelowY77, two complete native foreground legs are mirrored and planted at soleY94, with a visible one-pixel gap between boots. Dimensions remain35×53 logical pixels.
- Side run carries native axe upper cel0 with bob `[0,1,0,-1,0,1,0,-1]`; upper anatomy, both fists, rigid blades and finger masks share that same translation. Arms remain in their carrying pose; all eight original leg cels belowY77 still run. Blade angles stay−10°/+8°.
- Cardinal run body and hand pixels remain as accepted. Both UP blades point−90°, both DOWN+90°, staying in separate parallel lanes. Idle crossed back stow remains intentional.

| Evidence | Verified boundary |
| --- | --- |
| before.png / after.png | Partially accepted prior pose versus current steady carry and planted front idle |
| gait/motion.gif |48 native running frames, four directions at3× and actual game size |
| motion.gif / motion_frames / motion_timeline.json |105 native full-combo frames, four attack directions |
| validation.json / motion_check.log |4381 checks, zero failures; exact upper/leg pixels, stable grips, boot separation, blade paths and full combo |
| review_validation.json / review_check.log |113 actual controls, contacts, queue, pause, cancel and range checks, zero failures |
| before.json / after.json / scope_validation.json |11 assets change,54 unchanged;92 protected heavy/source files unchanged |
| rebuild_validation.json | Current deterministic rebuild evidence |

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/launch_king_dual_twinsteel_review.ps1
```

WASD moves/faces, SPACE/click attacks, G plays five, Tab controls, Esc pause. Test S then release for planted front idle; A/D for steady arms and moving legs; W/S for separated swords.

Current builder remains `tools/build_king_dual_unified.gd`; `builder_before.txt` preserves the previous pass. Source/provenance remains under `art_source/generated/characters/king/dual_unified_2026_10_05/`. No new generated identity art or runtime rig is introduced. The five-cut combat art, timing, damage, contacts, FX and collision travel remain. This remains a rewardless prototype; owner final motion acceptance and normal F5 equipment promotion are pending. [Current rules/rebuild](../../../../docs/design/king-dual-sword-design.md).
