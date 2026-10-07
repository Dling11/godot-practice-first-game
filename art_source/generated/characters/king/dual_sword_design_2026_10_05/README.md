# Dual-sword weapon choices — 2026-10-05

Owner selects Dual swords as the third family after accepting the current Greatsword pass. **The specific pair is not selected or playable yet.**

`source.png` is the unchanged built-in imagegen comparison board:

- A — Twinsteel: matching straight steel swords, simple guards and crimson/leather wraps. Recommended baseline.
- B — Mooncut: mirrored curved short sabers with a clearly visible cutting edge.
- C — Oathpair: medium main sword plus shorter matching parrying blade with a small violet mark.

`prompt.txt` is the exact final prompt. References were the installed King identity board and approved compact V2 axe weapon art; the older dual-sword body study was inspected for context but was not a generation input. The board is one preview asset, not an exact-grid atlas or bulk animation package. Raw output is preserved under the default Codex generated-images folder as `exec-f89e120a-9586-4301-93dd-15a99b72f057.png`, and copied into this project without altering visible pixels. `generation_manifest.json` records source/prompt hashes and reference roles. No CLI fallback or external image model was used.

`native_readability.png` is a real Godot4.7.2 Compatibility scale comparison beside installed King's front carry body. Top row1×, lower row magnifies the SAME80×64 render4× with nearest sampling. All blade designs use one1/16 source scale; King uses his current0.5 body scale. Exact pair crops and source dimensions are in `readability.json`. They are displayed beside King for size/readability review, not held/equipped; no hand attachment, animation or combat is implied.

Reproduce from project root:

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --script art_source/generated/characters/king/dual_sword_design_2026_10_05/render_readability.gd
```

The helper suppresses autosaving, requires native RenderingServer readback, and does not mutate the catalog/equipment. Its native log passes with all3 pair regions inside the source image. These candidates cannot be tested via F5 yet. Next pair selection and a short alternating-strike proof are described in [the design brief](../../../../../docs/design/king-dual-sword-design.md).
