# Decision 163: Make the Sanctuary study an inhabited settlement

- Date: 2026-10-01
- Status: Implemented in optional review; owner visual/feel review pending.

## Context

The owner identified the old red merchant cart beside Orren's accepted new workshop, mismatched old trees, randomly scattered broken walls and passive NPC presentation. They requested cohesive surroundings, clearer NPC discovery, interaction and a walking civilian. Earlier F5/Continue confusion also exposed the need for an accessible in-game review entry.

## Alternatives

- Retain mixed old/new props and add only labels.
- Make service NPCs wander, moving interaction targets around town.
- Rebuild the entire campaign map immediately.
- Compose a reversible town-life pass on the existing study, keeping reliable service positions.

## Decision

Use the last approach. Hide/disable the legacy cart and six trees only in the study. Replace them with generated planted linden/cedar silhouettes, a modest anvil/tool station, Eira's lectern, a noticeboard and continuous limestone garden boundaries with intentional openings. Preserve accepted workshop/lodge art and the portal.

All four service NPCs gain role-colored ground rings, labels and throttled approach greetings. Orren/Eira briefly hold their attentive pose, then resume authored working frames. Their DialogueNpc and service authorities remain intact; Orren does not gain a shop. A town map exposes existing services and the expedition gate, tracks King and highlights one chosen destination with a compass cue. It gives direction, not automatic pathfinding or movement. F at the noticeboard opens the same map; M toggles it.

One rewardless, nonblocking courier follows an authored collision-checked circuit with service pauses, generated four-direction walk and standing poses, and yields near King. Physics movement is confined to this ambient actor; it owns no player movement, interactions, progression or saving.

F5/Continue retains original campaign presentation. In debug builds, F10 exposes `SANCTUARY REVIEW · NO SAVES`. Entering mounts one study instance, suppresses saving for the rest of that process, starts beside Orren and closes admin mode. The existing launcher reaches the same study directly. Old/new comparison restores original props/collision/presentation but does not re-enable saves. Restart normal play to resume saving.

## Consequences

The town has recognizable destinations, purposeful work corners, ambient circulation and explicit discovery controls without moving essential services or promoting unreviewed content. Asset sources, rejected/old versions and exact prompts remain recoverable. Full interiors, Nema/Umi remodeling, campaign promotion, mobile profiling and owner feel acceptance remain future work.
