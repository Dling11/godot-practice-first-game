# Orren workshop interior proof

2026-10-02. The next unfinished Sanctuary slice is implemented as one walkable workshop in the optional review. The accepted exterior, Orren identity, service positions and generated interface theme remain the visual baseline. Other interiors and campaign promotion remain pending.

The owner found the first furniture too large beside King. Current V2 reduces the room shell to 75% and separately calibrates furniture against King's unchanged native body: workbench 56x30, rack 48x39 and forge 56x60 including the tall hood. Collision, navigation, inspection distances and camera centering follow the revised dimensions. Original runtime assets and captures are preserved. The owner accepted the current furniture size for now on 2026-10-02. Retain this scale; whole-room acceptance and campaign promotion are separate. Door labels use Enter workshop, replacing Walk in.

## Player experience

F5 -> Continue -> F10 -> SANCTUARY REVIEW -> **Workshop door**. Walk up to the doorstep to enter automatically. F remains available from the lower approach. Inside, WASD walks and right click chooses a destination; furniture blocks movement and the navigation mesh routes around it. F near the workbench, forge or weapon rack opens a brief inspect dialogue using the shared menu theme. F at the south opening returns King to the exterior ReturnPoint. Tab inventory and Esc pause continue working indoors.

The entry apron is a 56x76 rectangle relative to the actual Doorway marker, covering the doorstep and lower approach. The former 24px circle around Approach dropped the F prompt when King walked closer than that circle to the door; owner feedback reproduced this with real walking. Both prompting and entry validation now use the same apron, keeping sideways/far-away entry unavailable.

Following the owner's automatic-entry request, a smaller 48x30 doorstep rectangle triggers entry on the existing 100ms proximity timer. The lower Approach and ReturnPoint lie outside it, preventing unwanted entry on visit/exit. The same busy/modal/service-priority guards apply. An F press that also crosses into the automatic zone is consumed once so it cannot immediately exit again.

The existing direct launcher also accepts user argument `--workshop-door` after Godot's `--` separator to start beside this entrance. Its default Orren start remains available. Current interface-regression images are versioned under `art_source/review/ui/sanctuary_theme_2026_10_02/`; the October 1 baseline captures are preserved.

Orren remains at his courtyard station. Inspection offers atmosphere only: no shop, pickups, recipes, rewards or progression are added. The room has a warm forge with six bounded embers, separate workbench and rack sprites, stone/timber walls and a quiet plank floor. Camera projection, native pixel density and King scale match the town. Furniture depth sorts at its feet; collision uses ground footprints, not the entire tall sprite.

The outdoor minimap and study controls hide while indoors; the workshop header hides when a modal opens. Leaving restores the map selection and camera. Comparison or a visit/overview action first returns King outside, so he cannot be stranded inside an inactive room. Entry is rejected during a dash, attack, cast, aiming, defeat or recovery. The review remains save-suppressed until process restart.

## Implementation

- `levels/sanctuary/review/workshop_interior.gd` composes a 480x168 room shell, separate furniture, walls, embers and NavigationRegion2D at a separate world position. Physics and navigation share the same measured furniture rectangles. The region, collision and particles are inactive outside a visit.
- `workshop_visit.gd` owns doorway prompting, entry/exit, local inspection and snapshots of movement bounds, camera transform/limits/smoothing and navigation waypoint tolerance. It uses the existing Player, inventory and DialoguePanel. Town services keep interaction priority.
- Entry and exit cancel stale click movement and assisted targets. The room uses a 3px waypoint tolerance to avoid early corner turning at the workbench; the outdoor tolerance is restored. Navigation is baked once when the study is composed, following the [Godot NavigationPolygon API](https://docs.godotengine.org/en/stable/classes/class_navigationpolygon.html) and [source geometry API](https://docs.godotengine.org/en/stable/classes/class_navigationmeshsourcegeometrydata2d.html).
- `town_map.gd` gains temporary suspension without clearing the chosen destination. `sanctuary_ui_review.gd` observes room state when restoring modal overlays. `refuge_study.gd` composes the visit and exposes Workshop door.
- Orren workshop metadata is now `review_playable`. Eira, Nema and Umi doorway metadata remains `planned`. There is no campaign room transition or saved interior location.

## Art provenance

Built-in imagegen generated a kit referenced to the accepted Orren exterior and then extracted alpha. Exact prompts, original kit and alpha kit: `art_source/generated/environment/sanctuary/orren_interior_2026_10_02/`. Both generated originals are retained.

`tools/build_orren_interior_art.gd` performs deterministic panel cropping, nearest scaling and binary-alpha normalization from the existing generated kit; no new artwork generation is needed for this scale correction. Current manifest: `normalization_v2.json` beside the sources. Current runtime: `assets/environment/sanctuary/interiors/orren/v2/`:

- `shell.png`: 480x168.
- `forge.png`: 56x60.
- `workbench.png`: 56x30.
- `rack.png`: 48x39.

Current native Godot captures: `art_source/review/environment/orren_interior_scale_v2_2026_10_02/` (entry, room, King beside the bench on the same floor baseline, three inspections and courtyard return). Original assets under `orren/` and original captures under `orren_interior_2026_10_02/` preserve the oversized iteration.

## Verification and remaining work

`sanctuary_workshop_interior_smoke.gd`: 57 rendered checks pass at 960x540, including automatic entry through real walking, optional physical F-key entry/exit, same-event and exit re-entry prevention, side/far-entry rejection, WASD against the resized solid bench, an actual right-click route around furniture, inspection/inventory overlay behavior, restored bounds/camera/path tolerance/map selection, comparison and visit escape, active-dash rejection, Eira service continuity and save suppression. In headless mode the click test supplies the same movement intent directly because no physical pointer is available.

Existing interface: 63 rendered checks pass. Courtyards: 90 headless checks pass. Previous Sanctuary review: 94 headless checks pass. Production hub smoke passes. `git diff --check` passes. Existing shared GPU two-texture teardown warnings remain. Owner accepted the current furniture size for now; broader room feel/art judgment, other interiors, indoor footstep/forge audio and phone profiling remain open. This is one reusable room proof, not a completed interior system or campaign promotion.
