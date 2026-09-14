# King side leg-cycle review

Owner-approved on September 14. This is the accepted side-walk baseline; preserve its hand/upper-body motion and leg cycle during later integration. Earlier pending-approval text below records the pre-review verification boundary.

The owner accepts the preceding hand movement but rejects the feet. This correction retains those upper-body drawings and renders the legs through one continuous cycle instead of assembling disconnected generated poses.

## Motion

Each leg owns a full support/swing cycle, offset by half a cycle from the other. During support the ankle follows a level backward path relative to the torso. During swing it returns forward on a low four-source-pixel arc. Fixed 11/10-pixel segments solve to a forward-bending knee; the near leg stays in front and the far leg is shaded. This establishes consistent leg identity. It does not add world-space foot locking or change gameplay movement speed.

Generated thigh/shin/boot raster pieces are animated in an offline Godot viewport and packed into the existing eight-frame side atlas. No rig runs in gameplay. The accepted upper 73 rows and authored hand regions retain their exact opaque pixels. A small tunic-edge mask excludes the obsolete raised-knee protrusions below that boundary. Original walk.png, idle and all three attacks remain unchanged. Side cadence, equipment scaling and four/eight-frame turn continuity remain intact.

## Review

- [Normal-speed gameplay followed by quarter-speed study](legcycle.mp4).
- [Quarter-speed loop](slow_cycle.gif), both directions.
- [All eight poses in both directions](frames.png).

The capture uses real Player movement for the gameplay segment and the actual SpriteFrames at 25% playback for the isolated study. It substitutes scripted device intent only in the capture. Foot-path JSON records hips/knees/ankles and support flags for inspection. Visual approval remains pending; the 232 passing behavior checks verify integration, not naturalness.

## Source and build

Built-in imagegen produced `art_source/generated/characters/king/spellward_locomotion_2026_09_14/leg_parts.png`; [exact prompt](prompts.txt). Locked upper art: `side_upper_approved.png` in the same folder. The earlier `side_body.png` remains provenance, not the final leg sequence.

1. Godot --path . --script tools/build_king_side_leg_cycle.gd
2. Godot --headless --path . --editor --import --quit
3. Godot --path . --fixed-fps 60 --write-movie art_source/review/characters/king/spellward_legcycle_2026_09_14/capture_final.avi --script tools/capture_king_spellward_sidewalk.gd -- --bodywalk --legcycle

The rig renderer requires a rendering backend, so do not use --headless for step 1. The older whole-body generator now writes only a normalized source study and cannot overwrite the corrected side atlas. Capture metadata provides the slow-loop start/end; the MP4 contains the first 5.45 seconds. Source and normalized raster frames stay in the workspace; large intermediate AVIs can be removed after decode validation.
