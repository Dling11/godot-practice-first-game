# Twinsteel — compact hip carry

2026-10-05. Historical compact-carry baseline, accepted overall by the owner before requesting still closer side swords. The current follow-up changes only the side-run raster grip: [closer side hilts](../king_dual_close_hilt_2026_10_05/README.md). This folder preserves **TWINSTEEL / COMPACT HIP CARRY** and its original evidence below.

- Side forearms are reposed around native shoulder attachments; fists move from (83,74)/(111,71) to (87,75)/(105,75). Body, grips and finger masks share the same ±1 logical pixel vertical bob. Native head/neck pixels and all eight original leg cels below Y77 remain exact.
- One 16×62 blade, with grip (8,50) and tip (8,0), replaces the 22×82 blade in every carrying/attack state. The builder always resizes the immutable archived original; repeated builds do not shrink it further.
- UP/DOWN running holds its accepted first upper-body cel with the same small bob and fixed grip X, retaining the calibrated leg cycle. Blades tilt outward only 3°, moving each tip about 1.3 world pixels sideways. They do not cross.
- Planted native front idle, five-cut combo bodies/timing/damage/range, silver swing atlas, hops and collision travel remain. Shorter visible swords deliberately retain the broad white effects and combat reach.

| Evidence | Verified boundary |
| --- | --- |
| before.png / gait_and_scale.png | Previous versus current four-direction gait and heavy-family size comparison |
| after.png | Native side source, current compact hip carry and unchanged planted front idle |
| gait/motion.gif | 48 native gait frames, four directions at 3× and actual game size |
| motion.gif / motion_frames / motion_timeline.json | 105 native full-combo frames, four attack directions |
| validation.json / cardinal.log | 4455 checks, zero failures: native head/legs, coherent carrying upper body, hip grips, compact blade landmarks, subtle non-crossing tilt, planted boots, full combo continuity |
| review_validation.json / review.log | 113 actual practice checks, zero failures: controls, buffering, contacts, range, blocked gait, pause/cancel/reset; handoff gaps [0,0,0,0] |
| before.json / after.json / scope_validation.json | 28 assets change, 37 remain identical; all 92 recorded heavy/source files are unchanged |
| rebuild_validation.json / rebuild.log | All 65 runtime PNG/TRES outputs reproduce identically |

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/launch_king_dual_twinsteel_review.ps1
```

WASD moves/faces, SPACE/click attacks, G plays five, Tab controls, Esc pause. Test A/D for hip-level hands, W/S for tiny outward tilt and steady upper anatomy, and G for the smaller blades with broad white attacks.

Current builder: `tools/build_king_dual_unified.gd`; `builder_before.txt` records the previous pass. No new generated identity art or runtime rig is introduced. Existing cardinal imports repair fully transparent border RGB; preservation checks ignore that invisible RGB only when both texels have zero alpha. This remains a rewardless prototype, pending owner visual acceptance and normal F5 equipment promotion. [Current rules/rebuild](../../../../docs/design/king-dual-sword-design.md).
