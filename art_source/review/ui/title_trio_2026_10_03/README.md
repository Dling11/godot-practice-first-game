# Production A/B/C homepage verification

2026-10-03; Godot4.7 native Compatibility/OpenGL AMD. a.png/b.png/c.png are actual 960x540 homepage captures with real left-side controls. King is a still illustration.

Native tests/title_trio_smoke.gd: 72 checks/0 failures: real title creation/range/no-repeat, persisted cosmetic index, all three art captures, absence of walking sprites, initial focus/native size and resized control bounds. Fresh headless process restart.log: 66/0 also reads retained isolated history and verifies the next choice differs. menu.log/continue.log pass actual settings/audio/focus/New Journey/confirmation and saved Continue. loading_native.log: 27/0 verifies remaining loading seal/motion/pause/hidden behavior.

Tests use user://title_trio_smoke.json and its own cosmetic history; no normal progress bytes replaced. Normal F5 now uses the trio. Runtime picks once on title opening, choosing among the two alternatives to its saved previous index. Existing Texture/RID and early-exit ObjectDB cleanup warnings remain. Original source/prompts are under art_source/generated/ui/title_trio_2026_10_03/.
