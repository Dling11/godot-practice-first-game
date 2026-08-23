# Stage VI Environment Generation Prompt

Built-in image generation supplied two production sources on 2026-08-24.

## Elder Root Canyon Backdrop

- Tall high-angle pixel-art forest canyon.
- Colossal living roots, deep blue-violet mist, pale ancient terraces,
  restrained teal canopy, waterfalls, and upper-left amber light.
- Background and edge-depth presentation only: no characters, portal, UI,
  collision implication, or playable route.

## Elder Root Threshold

- Wide asymmetric living-root arch fused with pale ruins.
- High three-quarter top-down view with two separated grounded feet and one
  large traversable center passage.
- Hard-pixel dark-fantasy palette with teal leaves, amber motes, and restrained
  blue-violet runes.
- Requested transparent source; the generator returned an edge-connected dark
  matte, which `tools/process_stage_6_environment.py` removes conservatively.

The complete prompts are preserved in the associated Codex task history. The
runtime outputs are deterministic products of the checked-in source PNGs and
processor.
