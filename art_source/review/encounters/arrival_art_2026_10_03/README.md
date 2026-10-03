# Playable A/B/C spawn-art review

2026-10-03. **Owner choice pending; no campaign art promotion.**

Launch from the project: powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\launch_enemy_arrival_art_review.ps1.

- A Veil Tear, B Earthwake, C Shadow Cocoon: switch and replay the current batch.
- One Rootling / Three roots + caster / Eight-live crowd: actual actors/AI. Reset before changing batch size; Replay repeats the selected count.
- Ground: grass/dark uses the real western/eastern Stage IV environment. Dark sample sits below the gateway arch rather than behind it.
- WASD, attack/skills, Tab bag, Esc pause and King safe toggle remain available. Trial rewards are removed and saves are suppressed in a separate profile.

Built-in imagegen originals/exact prompts/registration manifest: art_source/generated/vfx/enemy_arrival_runtime_preview_2026_10_03/. Native six-cell atlases/resources: assets/vfx/enemy_arrival_review/. Preview effect consumes real encounter warning/release and accepted sound; it never creates an enemy, grants a reward or changes damage/caps.

controls.png documents the native960x540 controls. {a,b,c}_{grass,dark}_{warning,open,collapse,walking}.png are **actual native game renders**, not composited mockups; captured at roughly .10/.40/.64/1.29s after a real one-enemy batch request. Animated foliage/actors remain live, so scene pixels can differ independently of the VFX. Watch the interactive review for the whole motion.

Native art-review **57 checks /0 failures** and existing procedural-review regression **30 /0**; see native_smoke.txt/original_review_smoke.txt. Coverage: genuine A/B/C mouse clicks, binary-alpha six-cell assets, fixed cell/pivot/full enemy scale, pause, warning/materialization, cleanup,1/3/8 batches/replay, grass/dark, rewards/saves, bag controls and visible viewport buttons. Capture/import logs retained. Existing two5460byte Texture/RID leaks/RenderingServer-null shutdown messages reproduce unchanged; no new parser/runtime errors remain. These checks do not establish owner animation acceptance, overall campaign FPS or phone readability.

Superseded next step (Decision176): owner rejects size/tier-dependent frame expansion and requests one generic monster spawn. Review tools/launch_generic_spawn_review.ps1 and art_source/review/encounters/generic_spawn_2026_10_03/README.md instead. A/B/C remain earlier visual references; no family was promoted. Keep source/unselected candidates as provenance until cleanup is requested.
