# Sanctuary courtyards and working residents

**Perspective correction:** The owner subsequently rejected the diagonal artisan-house projection. Current Nema/Umi houses match the overhead Orren baseline with left-positioned entrances. The corner map, compact HUD and shared menu theme are documented in sanctuary-interface-renewal.md. Angled-house descriptions below record the superseded iteration; NPC/gait/ambient behavior remains current.

2026-10-01 follow-up to Decision 163. Implemented in the optional no-save study; owner visual/feel acceptance and campaign promotion remain open. This supersedes the earlier handoff that left Nema and Umi pending.

## Owner feedback and resulting behavior

The owner found the courier gliding, Eira's lectern occupying a road, static vegetation and too many front-facing buildings. They authorized continuing Nema, then Umi, with a more coherent and interactive town.

- Rowan's replacement walk sheet has distinct contact/passing poses, plus a dedicated front/back correction board. A 22-world-pixel stride cycle advances from actual physics displacement, not elapsed time. Stops, player yielding and collisions select standing poses and freeze the stride phase. Old sheets remain preserved. Native movement still needs the owner's feel judgment; image uniqueness alone is not gait verification.
- Eira stands at344,438 on a teaching nook east of the lodge. The lectern at344,410 is on earth, outside `path_cells`. The main doorway lane remains atx224; a short branch reaches her from the southern road. A planter and lamp frame the nook without occupying it.
- Nema keeps her existing service root at342,630. The new angled grove-smith house at232,648 exposes its side elevation and a right-facing forge annex. Its separate ground footprint and annex collision leave the service approach at366,658 clear. The former lower-west wall moves south toy704.
- Umi keeps her existing root at786,650, beside the blue-roof atelier at904,668 with a porch facing the inner town. The southern road runs west of the house instead of through it; her clear approach is784,686. The original Rootforge building and Echo Crucible prop are disabled only in the study.
- Six trees have individually phased, bounded pixel-stepped upper-foliage wind; collision roots remain static. Their canopy reveal remains active. Two small swallows use four authored wing poses, crossing for12seconds and resting offscreen for10seconds. They have no collision or service authority.
- Rowan is now an optional civilian conversation: approach for a local F prompt, hear his delivery rounds and town directions. Fixed NPC services take interaction priority when radii overlap. He gives no rewards and does not open shops or modify progression.

## Character presentation

Nema retains her adult human grove-smith identity: dark auburn braid, moss apron, hammer and tongs. Eight poses show inspection, lift, strike and recovery. Umi retains blue hair, cobalt witch hat and restrained crystal work. Eight poses inspect/turn/charge/lower a shard. Both use96px atlas cells at half scale, foot baseline80, nearest sampling and binary alpha. Nema's standing silhouette is58-59px with a64px raised-hammer extent; Umi's64-66px extent includes her hat. Portraits are96px deterministic crops of the same generated source identities.

`artisan_renewal_review.gd` adapts each existing DialogueNpc without replacing its body/trigger shapes. It stops the old WorkIdle timer, uses the separate `artisan_work` animation, holds frame0 for greetings/dialogue and resumes afterward. Nema's retained strike audio fires at contact frame5. Original art, portrait and timer return in comparison. CraftingService, MaterialExchangeService, menus, recipes and progression remain authoritative.

## Navigation, depth and review

New houses have body/bench collision, roof reveal and planned Doorway/Approach/ReturnPoint markers. Interiors are not implemented. The town map schematic follows revised roads and house bounds; service markers still derive positions from live NPC nodes. Greetings hide immediately when King leaves, and Rowan's local prompt hides as dialogue opens.

Run `tools/launch_sanctuary_study.ps1`, or F5 -> Continue -> F10 -> SANCTUARY REVIEW. The top controls now include Visit Nema, Visit Umi and Find Rowan alongside Orren/Eira, comparison and overview. Find Rowan places both actors in an authored clear delivery stop; step away to watch him resume his route. M opens the town map, F talks. Saving remains suppressed for that whole process, including old comparison. Restart normal play to resume saves. The production campaign map has not been promoted.

## Sources and evidence

Built-in imagegen produced the raster art; `tools/build_sanctuary_courtyards.gd` performs deterministic crop/nearest/binary-alpha normalization only.

- Nema: `art_source/generated/characters/npcs/nema/renewal_2026_10_01/` -> `assets/characters/npcs/rootweaver/renewal/`.
- Umi: `art_source/generated/characters/npcs/umi/renewal_2026_10_01/` -> `assets/characters/npcs/umi/renewal/`.
- Rowan: `art_source/generated/characters/npcs/courier/locomotion_v2_2026_10_01/` -> `assets/characters/npcs/courier/walk_v2.png` and `portrait.png`. Side rows use `walk_source.png`; front/back use `vertical_source.png`. Original standing poses remain.
- Houses/swallow: `art_source/generated/environment/sanctuary/courtyards_2026_10_01/` -> `assets/environment/sanctuary/courtyards/`. Exact prompts and manifest are retained. `nema_front_rejected.png` preserves the rejected frontal draft.
- Native rendered review: `art_source/review/environment/sanctuary_courtyards_2026_10_01/`; existing regression captures remain under `sanctuary_life_2026_10_01/`.
- Focused checks: `tests/sanctuary_courtyards_smoke.gd` exercises real F dialogue, cancellation/completion, both service menus, eight-pose playback, original restoration, unchanged shapes, road/door/service access, collision-driven feet, courier/service F priority, roof reveal, birds, cleanup and save suppression. Run alongside `sanctuary_life_smoke.gd`, `sanctuary_refuge_review_smoke.gd` and the production `sanctuary_hub_smoke.gd`.

Verified: 99 rendered courtyard checks, 95 rendered town-life checks, 108 rendered existing study checks and production hub smoke pass. Remaining: owner gait/composition/audio judgment, interiors, representative-phone profiling and deliberate campaign promotion. Existing shared GPU texture teardown warnings remain separate from these runtime changes.
