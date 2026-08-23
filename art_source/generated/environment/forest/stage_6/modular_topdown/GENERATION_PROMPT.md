# Stage VI Modular Top-Down Environment Provenance

- Date: 2026-08-24
- Mode: built-in image generation
- References: approved Stage VI `elder_ascent_ground_atlas_4x4.png` and the existing ancient-tree base/canopy
- Runtime processing: `tools/process_stage_6_environment.py`

## Cliff and Rock Kit

Create a transparent pixel-art environment asset board for Battle of Gods using
the supplied approved top-down Stage VI ground and ancient-tree references.
Maintain the same top-down/slightly angled top-down perspective, pixel density,
limited Forest palette, upper-left lighting, clustered hard pixels, and readable
game scale. Arrange exactly six isolated reusable pieces on a 3x2 board with
wide transparent gutters: grass-topped straight cliff ledge, outer cliff corner,
inner cliff corner, rocky elevated outcrop, boulder cluster, and narrow cliff
ramp. No characters, text, horizon, sky, distant landscape, side-view mountain,
building, altar, portal, or monolithic map background. Each piece must have a
stable ground contact and be suitable for collision authored separately in
Godot.

## Waterfall Animation

Create exactly four equal horizontal pixel-art animation frames of one modular
top-down waterfall using the approved Stage VI ground reference. The silhouette,
cliff lip, pool, rock placement, frame size, and camera angle remain stable;
only water highlights, falling strands, foam, and small ripples change. Show an
upper pool, water crossing a grass-topped cliff lip, a short falling face, and a
lower basin, all from the same top-down/slightly angled top-down perspective.
Transparent background, limited palette, hard-pixel clusters, restrained motion,
no text, character, sky, horizon, distant scenery, or side-view landscape.

## Output Contract

The source boards remain review/provenance assets. Deterministic processing
extracts six transparent prop PNGs, reduces their palettes, writes a `4x1`
waterfall sheet with `192x256` cells, preserves the already approved ground
atlas, and produces nearest-neighbor review images. Gameplay collision and map
composition remain authored Godot data.

## Waterfall Integration Edit V2

- Mode: built-in image generation, precise-object-edit
- Edit target: `upper_terrace_waterfall_4f_192x256.png`
- Placement reference: `stage_6_upper_terrace_full_960x540.png`
- Saved source: `stage_6_waterfall_4f_source_v2.png`

Correct only the waterfall integration and motion. Preserve the established
top-down style, scale, palette, upper pool, cliff rocks, basin, and footprint.
Make the pool feed through a carved notch and make both cliff banks meet the
waterfall cleanly. Return exactly four equal horizontal frames. All non-water
terrain, banks, rocks, grass, silhouette, curtain width, source outline, and
basin outline remain identical. Animate water highlights and vertical streaks
downward only; foam may pulse in place. No horizontal translation, sway,
wobble, width change, bank movement, sky, horizon, or background scene.

The v2 edit supplied the improved carved integration but returned an opaque
checker matte and small frame-to-frame terrain drift. Deterministic processing
therefore restores the validated v1 alpha/color where the checker intrudes,
locks frame zero as the terrain authority, fixes one curtain mask, phases only
its water texture downward by `0/4/8/12` pixels, and pulses foam brightness in
place. It also exports reusable static lip, looping flow, and static basin
modules for future waterfall heights and locations.
