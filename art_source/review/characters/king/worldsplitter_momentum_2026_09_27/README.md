# Worldsplitter higher-arrival momentum review

Presentation-only follow-up to the fresh-sword revision. The blade tip starts 144px above its target instead of 86px. Follow-up summoning begins .34s before impact instead of .26s; the first .095s assemble/hold the new sword, then an accelerating descent drives it into the floor. Damage events remain near .60/.88/1.16s from input, and King recovers at .32s. No new artwork, damage, radius, training or save changes.

`tests/worldsplitter_descent_smoke.gd`: **142 rendered checks, 0 failures**, including 24 real 960x540 GPU captures. Covers all three ranks, high arrival, new blade identity, downward-only movement, deep burial, AOE footprint/damage, control return and cleanup. Shared GPU shutdown texture warnings persist. Owner motion/audio acceptance and phone profiling remain open.

Run `tools/launch_king_skills.ps1`: Mature is selected without saving. Press 5, aim/click, and move while the sword sequence completes. F7 -> Skills changes forms; F9 refills the kit. Existing generated sources/prompts remain under `art_source/generated/vfx/king/worldsplitter_summoned_2026_09_27/`.
