# Shared overhead stun indicator review

Captured from the real Combat Lab with King C enabled, plus real Thrall and Armored Hog scenes. Gold outlined pixel stars orbit above authored head offsets. The mob health bars remain visible to check separation. Capture controls pause enemy AI for comparison; runtime markers observe accepted controller states and do not own stun duration.

- `stun_preview.gif`: animated comparison.
- `frame_009.png`: representative active frame.
- `recovered.png`: control returned, stars cleared.
- `examiner.png`: large actor guard-break placement.
- Reproduce with Godot GUI rendering: `--path . --script res://tools/capture_stun_indicator.gd --resolution 960x540`.
- Runtime reusable scene: `gameplay/presentation/stun_indicator.tscn`. Adjust scene position for head height, orbit radius for body width, and named stun states for another controller. The body animation is independent.

Validation: 33 focused state/lifecycle checks and 232 King preview regression checks pass. No damage, control duration, animation frames or movement changes.
