# Enemy-arrival in-engine art choices

2026-10-03. Generated with **built-in imagegen**, not CLI/API and not vector drawing. Exact six-drawing prompt set: [prompts.json](prompts.json). References were the original A/B/C concept board and current32px Rootling walk sheet. The owner accepts the sound but needs actual gameplay before choosing. No family has been selected or promoted to normal F5 stages.

## Saved originals

- a_source.png — Veil Tear; original generated_images/01a0eed4-5878-7032-a315-e493f92ce97a/exec-0bac0a10-5b2f-4411-9f72-fd54616ad261.png.
- b_source.png — Earthwake; original exec-7367a8ca-8ae3-4964-815d-8e90ee22b81a.png in the same Codex generated-images folder.
- c_source.png — Shadow Cocoon; original exec-6194c132-e9db-411f-864c-be7fbdd9fac2.png in the same folder.

Originals are1536x1024,3x2 cells, real transparent alpha. Source translucency includes soft glow. The runtime comparison copies use a .65 alpha threshold and clear transparent RGB; no opaque background is keyed out, no vector geometry is substituted, and no original is overwritten. Source designs still carry some small local debris; there is no broad dirt island in the native derivatives.

## Reproduce

Run tools/build_enemy_arrival_review_art.gd with the local Godot console, then an editor --import --quit pass. The builder crops six512x512 cells, uses **one uniform56/512 nearest scale** across every pose/family, registers authored seam origins and places the floor at(32,52) in64x64 cells. It asserts occupied cells/padding and saves registration.json containing every crop/origin/offset/bounds. Do not use moving bright rim pixels to guess floor origins. Native comparison atlases and named warning/release SpriteFrames are under assets/vfx/enemy_arrival_review/.

Two warning drawings occupy the real .3s reservation. Four release drawings last .56s; the last remnant fades over .14s through a pause-aware Tween. Natural growing/collapsing silhouettes remain; the whole effect has no stretch, bounce, continuous translation or vector fallback. Native effect width34–47px/peak height45–49px; cells/pivots do not change.

Run tools/launch_enemy_arrival_art_review.ps1 to compare on actual renewed Stage IV. A/B/C switches and replays the same1/3/8 batch. Reset clears enemies before choosing another batch size; Replay repeats the current count; Ground toggles living grass and dark eastern terrain. The dark comparison appears below the gateway arch so the effect is visible. All trial enemies have reward components removed before ready. Existing sound/placement/cap/warning/actor authority remains; storage user://enemy_arrival_art_review.json and suppressed autosaving protect campaign saves. Normal Stage IV opens existing normal-wave review in this same isolated session.

## Verification and remaining choice

Native Godot4.7.2 Compatibility/OpenGL AMD art review: **57 checks /0 failures**. Existing procedural review regression: **30 /0**. Editor imports and diff whitespace checks pass. Native captures of all three warning/open/collapse/walking on grass/dark: art_source/review/encounters/arrival_art_2026_10_03/. Exact native logs copied there as .txt. Existing shared two5460byte Texture/RID and RenderingServer shutdown errors remain unchanged.

These remain earlier playable visual references, not approved art or a whole-game/phone performance result. Decision176 supersedes primary A/B/C selection: the owner wants one generic underfoot spawn rather than per-size/tier sheets. Review tools/launch_generic_spawn_review.ps1 and ../generic_spawn_2026_10_03/README.md. Do not expand these families into size-specific atlas production or freeze their silhouettes merely to satisfy an emblem-style no-change test.
