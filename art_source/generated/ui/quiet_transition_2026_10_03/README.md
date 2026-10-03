# Quiet transition layers

2026-10-03. Built-in imagegen edits the approved loading_quiet_threshold reference into a background-only image and an eight-frame transparent seal. Exact prompts/reference paths: prompts.json.

tools/build_threat_transition_art.gd reduces background to960x540 and registers the seal into112x112/eight-frame horizontal cells with a96px maximum extent. Seal normalization is recorded in the portal production normalization.json. Runtime assets: assets/ui/quiet_transition/. Lossless/no mipmaps/nearest.

QuietLoadingView adds native text and a280x16 real progress rail, plus the current outlined Spellward King walk. No baked labels, percent, stage-specific biome, future bosses or patron spoilers. SceneTransition owns real background IO and actual progress; view owns no travel/reward authority. TitleBackground shares the backdrop/seal but retains native menu controls.

loading_native.gif is a fixed37% MOTION PREVIEW. loading_real_transition.png captures actual resource loading. Native test checks King/seal frame changes during real pause. Do not claim the GIF is a recorded load or force production loading to wait for animation.
