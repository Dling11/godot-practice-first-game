# Pre-polish Twinsteel source snapshot

2026-10-05. Preserves pre-correction runtime PNG/TRES/imports and prototype data before the owner-requested height/run/combo/reach changes. `dual_twinsteel/metadata.cfg` records original pose and offhand arrays. The current offline polish builder reads those arrays and PNGs directly. These archived resources are not loaded by the game; the parent art_source tree is ignored by Godot exports. Retain this folder for deterministic rebuilds; do not run its copied resources as a separate game branch.
