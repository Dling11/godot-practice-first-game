# Worldsplitter fresh-sword and radial-blast review

Twenty-one native 960x540 Godot captures from `tests/worldsplitter_descent_smoke.gd`: formation, each deep plunge and blast, fresh follow-up summons, and final embedded fracture. These are actual game renders, not concept composites. Capture briefly pauses the scene after combat hitstop completes so GPU readback cannot skip the inspected phase.

Final rendered run: **139 checks, 0 failures**. Earlier headless run: 116 checks, 0 failures, before adding two atlas-footprint assertions. Additional tests: activation 13, combined Vow/combat 49, training 14, sidebar 26, and production-kit zero failures. Final headless editor import has no script/import errors. Shared GPU shutdown warnings about two 5460-byte textures and RenderingServer persist.

Use `tools/launch_king_skills.ps1` to test normal motion/audio. Mature is selected only for this debug session. Press **5**, aim/click, and move while three separately summoned crimson blades plunge deep and detonate. F7 -> Skills changes rank; F9 refills the kit. Campaign saves are suppressed.

Source art and full prompts: `art_source/generated/vfx/king/worldsplitter_summoned_2026_09_27/`. Packed runtime impact/summon atlases: `assets/vfx/abilities/king/worldsplitter/summoned/`. Design: `docs/design/worldsplitter-fractured-light.md`; Decision 162 supersedes the rejected single-blade pullout choreography. Owner visual/audio approval and representative-phone profiling remain pending.
