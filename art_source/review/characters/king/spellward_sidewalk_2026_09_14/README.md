# King C side-walk correction

Superseded: the owner rejected this foot-only correction as mechanical. Use the [whole-body side-walk review](../spellward_bodywalk_2026_09_14/README.md) for the current implementation.

Owner approved the down/up gait; only left/right needed the missing half-step. The previous forward boot stayed planted through almost the whole cycle. The new four poses show split contact, rear-foot lift, forward-foot passing lift and forward extension. Shoulder carry, stable head registration, foot baseline, outline and movement-equipment cadence remain.

Built-in imagegen produced two missing poses from the current approved source. Source: `art_source/generated/characters/king/spellward_locomotion_2026_09_14/side_pass.png`. Exact prompt: prompts.txt. Rebuild via the existing `tools/build_king_spellward_preview.gd -- --locomotion-only`, followed by Godot import. Frame count/rate remain four at 7 FPS before equipment scaling.

Verified down/up rows are pixel-identical to walk_before.png, and idle/three approved attack atlases retain their SHA256 hashes. Only side rows changed. The 221-check focused suite passes. Godot-rendered frames.png exposes all normalized side poses. sidewalk.mp4 / sidewalk.gif record actual movement using scripted device intent through the unchanged Player controller. Capture: tools/capture_king_spellward_sidewalk.gd. The first 3.1 seconds contain movement; the final debug frame board is excluded from the video/GIF.

Open F7 → KING REVIEW in a fresh session. Campaign art remains unchanged. Final side-gait feel still needs owner review.
