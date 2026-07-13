# Decision 037: Generate and Normalize a Dedicated Sanctuary Art Kit

- **Date:** 2026-07-14
- **Status:** Accepted

## Context

The first functional Sanctuary proved the title-to-hub-to-expedition loop, but its code-drawn houses, fountain, altar, NPC, reused Stage 1 grass, and scattered prototype trees did not meet the approved luminous dark-fantasy quality bar. Replacing the entire hub with one painted background would improve the screenshot while breaking traversability, interaction, collision, Y-sorting, reusable props, and future editing.

## Alternatives Considered

- Keep the functional prototype art and postpone visual identity.
- Use one flattened Sanctuary illustration as the playable map.
- Import the generated direction board directly as runtime art.
- Preserve the generated direction board as source and reproducibly normalize selected assets into separate runtime sprites, scenes, and tiles.

## Decision

The approved generated Sanctuary direction board is preserved under Godot-ignored `art_source/` as source material. `tools/process_sanctuary_direction_board.gd` owns reviewed crop rectangles, crop-color-matched border background removal, binary-alpha normalization, exact runtime canvases, four-frame accent animation, and the dedicated 64x64 Sanctuary ground atlas. Broad global dark-key removal is restricted to the reviewed portal crop; character, building, stall, and tree crops must preserve dark outlines, interiors, limbs, and connectors.

Runtime presentation remains decomposed: the angel portal/fountain is the existing expedition interaction, with fountain, statue, doorway-pillar, rear-backstop, and threshold responsibilities kept separate so the player can step into the portal from either side. Skillkeeper Eira and Armskeeper Orren reuse one `DialogueNpc` contract, buildings and the weapon stall own footprint collision and bounded light idle effects, and Sanctuary trees own footprint collision plus presentation-only sway. `SanctuaryGround` paints a compact authored route network from Sanctuary-only grass and cardinal pavement transitions; combat-stage grass is no longer reused.

The first code-drawn Sanctuary kit and its obsolete generator were removed after the replacement passed runtime, interaction, and asset validation. They must not be recreated or receive new runtime references. Shop prices, purchasing, equipment, and coin sinks remain deferred; Orren is an honest interactive preview, not a fake completed shop.

## Consequences

- The hub now matches the approved generated visual language while remaining editable and mechanically correct.
- Source art, runtime crops, collision, interaction, and idle presentation can evolve independently.
- Rebuilding the kit is deterministic as long as the 1536x1024 source board and documented crop contract remain unchanged.
- Crop cleanup is asset-specific; a convenient global dark-key pass is forbidden when it would erase legitimate sprite structure.
- New Sanctuary props should extend the dedicated kit rather than reusing combat-stage tiles or flattening interaction into background art.
- The generated source and exact crop choices require review if the board is replaced.
