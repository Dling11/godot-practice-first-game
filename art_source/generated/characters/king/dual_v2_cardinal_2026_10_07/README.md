# Twinsteel V2 cardinal, movement and proud-idle sources

2026-10-07. Built-in `image_gen` with transparent output; final originals copied into this project. No CLI/API fallback. Exact prompts are in [prompts.json](prompts.json); deterministic body/grip/head/occlusion/density records in [registration.json](registration.json).

| Final sheet | Original generated file |
|---|---|
| up_source.png | exec-fada8ff3-93b6-40b1-84a9-cac641cb2082.png |
| down_source.png | exec-1f6c27c1-1c7e-4bb6-8da0-da5625626477.png |
| gait_source.png | exec-a922814a-4d39-4df7-b547-d9476efac563.png |
| idle_source.png | exec-f32a5d5a-0abe-4680-9ebe-ce00ced8474d.png |
| fx_up_source.png | exec-5ed05115-bb28-484e-a235-4a2426b027c6.png |
| fx_down_source.png | exec-ce0bc8bd-8ed3-4c86-858f-3453bfba7e2b.png |

Original directory: `C:/Users/Administrator/.codex/generated_images/01a0eed4-5878-7032-a315-e493f92ce97a/`. Initial up/down attempts copied side facing and were rejected; their prompts remain as iteration history. A dedicated back/front reference corrected orientation. Diagnostic grip_failure.png records the source-hidden rear palms, not live art.

Build `godot --headless --path . --script res://tools/build_king_dual_v2_cardinal.gd`, then import with the matching engine. Builder writes only `assets/characters/playable/king/dual_v2/`. Dedicated cuts1/2/3/5 are new; the approved full-body side spin receives cardinal phase mapping. Every raw row is phase-selected using its real cel count. Foot/head registration is fixed-density, not per-pose rescaling. Rest head turns are baked over a fixed folded torso; both blades are detached at the floor. Read [installed rules and limitations](../../../../../docs/design/king-dual-v2-cardinal.md).
