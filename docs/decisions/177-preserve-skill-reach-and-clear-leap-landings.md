# Decision177: Preserve skill reach and clear leap landings

**Owner refinement (2026-10-03):** Ornate silver rings are rejected as too wide/huge/distracting. Current presentation is a single1px blended boundary with small ticks/open center, quiet range arcs and24px hardware cursors. It retains authored hit geometry and all terrain rules. Decorative PNGs are archived and only the four generated cursor assets stay active. Native39 current-art checks and UI/icon smoke pass. Clearing native hardware bindings at teardown removes the two texture/RID and RenderingServer-null warnings in the focused test; broad full-session verification remains open.

Date: 2026-10-03. Status: Implemented; owner feel review remains open.

## Context

Owner reports scenery shortening Skills 1/5 and wants Skill 3 to retain its full aiming range. Their explicit clarification selects jumping over **any intervening obstacle when the landing is clear**. They also reject gold circles/pointers and request smoother RPG targeting art.

## Decision

Earthsplitter keeps authored full lanes through world scenery, both in preview and travelling hurtbox authority. Worldsplitter keeps its range-clamped chosen point and applies radius contacts across scenery without a terrain LOS filter. Basic sword already uses its full physical fan without terrain LOS; preserve that authority and verify it.

Pursuit validates its real foot shape and authored navigation ground at the destination, within range and playable bounds. Flight temporarily disables only King's world-collision mask bit; other collision bits stay intact. Intervening walls, trees and rocks can all be crossed. An occupied destination retreats up to 32px toward the origin before a safe approach/in-place fallback. Revalidate at wind-up release. Landing, cancellation and teardown restore the previous mask bit; interrupted flight inside scenery returns to the last safe feet. Charges, travel-only invulnerability and normal movement remain component-owned.

Ground aiming uses King's physical feet for preview and commit. Generated silver/slate/violet rings, landing glyph and hardware cursors replace plain blue/gold targeting presentation. Render-frame aim updates run only while targeting; unchanged pointer/origin/stick skips redraw/queries. Confirmation refreshes current aim and each cast resolves its own target. Exact circle/lane geometry remains visible alongside decorative sprites; no visual easing delays the actual chosen point.

## Alternatives and consequences

Shortening supernatural attacks at the first prop contradicts owner intent and makes their preview misleading. Defaulting to wall-stopped flight was considered; owner explicitly chose all-obstacle crossing. Permanently changing Player collision or teleporting directly would lose ordinary walking rules/travel presentation. A new particle manager or shader reticle is unnecessary: registered raster assets plus existing native geometry retain gameplay boundaries and low overhead. This grants wall-crossing mobility intentionally, but does not permit landing in solid geometry or outside authored ground. No damage/rank/range tuning or new skill is added.

Validation: native terrain33/0 (actual attacks, max-range trained jumps, blocked landing, bounds/navigation, pause/cancel/restoration), native art45/0 (six Stage IV captures, cursor state, transparency and no gold in all seven new assets). Worldsplitter118 headless checks, charge/selected-target tests and Fan/Cascade horde contacts pass. Existing renderer shutdown warnings and full campaign/phone profiling remain open. See docs/design/king-targeting-and-terrain.md.
