# Opaw Runtime Art

This folder deliberately contains only two runtime-ready visual sets:

- `compact_armless/` is the approved active Opaw model. `player.tscn` loads only `opaw_compact_armless_sprite_frames.tres` from this folder.
- `variants/wayfarer_original/` is the complete supported backup of the previous model. It is not active, but remains loadable for a deliberate rollback.

Rejected experiments, duplicate legacy sheets, generated source boards, and incomplete skill art do not belong here. They are preserved under `art_source/archive/`, which Godot does not import into the game.
