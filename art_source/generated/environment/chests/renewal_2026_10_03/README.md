# Existing reward chest renewal

2026-10-03. Built-in imagegen, using the current rendered Rootbound objective/chest capture as perspective/theme reference. Exact prompt in prompts.json. Source has2columns(closed/open)x3rows(Forest/Rootbound/Varkuun), true alpha.

tools/build_reward_chest_art.gd performs technical alpha threshold/nearest reduction. Each pair shares a scale and ground registration; normalization.json records sizes/origins. Runtime PNGs: assets/gameplay/loot/stage_clear_chest/renewed/. Canvases remain64x48,72x64 and74x66. Bottom baselines43,60,63 match existing sprite placements/footprints.

Chest contents, F claims, bank/save and stage sequencing are unchanged; stage_reward_chest.gd is unchanged. Two authored states per chest, existing spawn/glow/fade; not an eight-frame lid animation. No extra chests added.
