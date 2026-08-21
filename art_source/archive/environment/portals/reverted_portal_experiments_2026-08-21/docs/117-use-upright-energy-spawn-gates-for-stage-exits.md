# Decision 117: Use Upright Energy Spawn Gates for Stage Exits

Status: Accepted

## Context

Owner review clarified that the approved stage-exit concept was not a structure and not a vortex lying on the ground. It is a free-standing vertical dimensional tear made only from twisting mana and lightning. Gate color and energy intensity should communicate the next route's threat. The prior generated ground vortex remained strong loading imagery.

## Alternatives

- Keep the eight-frame floor vortex as both the world exit and loading indicator.
- Return to a stone/root architectural gate.
- Use an upright structure-free spawn gate in the world and retain the ground vortex only for loading.

## Decision

World stage exits use one generated pixel-art `4x4` sheet with six spark-to-portal materialization frames and ten active-loop frames. Fully open frames preserve one wide asymmetrical doorway silhouette, center, and scale while the jagged edge lightning and rotating interior energy change. The opening remains irregular rather than a smooth oval and is visibly large enough for King to enter. The edge keeps hard alpha; a small documented set of interior alpha values lets stage scenery remain recognizable but substantially obscured through the portal. Runtime presentation maps Normal, Mini Boss, Boss, God, and Transcendent tiers to blue, orange-red, crimson, violet, and gold, with increasing scale, speed, spawn burst, and ambient particle counts. Guidance, collision, travel, and scene-transition authority remain unchanged. `SceneTransition` retains the prior eight-frame ground vortex as its loader only.

Owner review subsequently found the first veil too faint and its internal motion too stiff, then found the corrected narrow tear still too small to read as an actual portal. The active generated replacement widens the fully open body to roughly 59% of its height, preserves source-authored rotating energy bands, adds counter-ribbon flow and circulating sparks behind the veil, and gives the outer edge a restrained horizontal energy breath. Tier assignment describes the destination threat: Stage II to III is Mini Boss, Stage III to IV is Normal, Stage IV to V is Boss, and the Stage V return to Sanctuary is Normal.

The follow-up runtime review found those vertical ribbons too subtle to read as the requested central vortex. `StagePortalInnerFlow` therefore draws a clearly visible presentation-only vortex immediately behind the translucent generated veil: a subdued tier-colored depth field, three expanding rotating spiral arms, four broken counter-rotating orbit fragments, and a luminous center eye. The generated hard edge remains in front. Tier speed and intensity continue to drive this motion, while interaction, collision, guidance, and transition ownership remain unchanged.

## Consequences

- Stage exits read as passages the player walks into rather than black holes in the floor.
- One compact animation sheet supports every threat tier.
- Boss and God gates can feel materially more dangerous without new gameplay authority or duplicate large textures.
- Runtime tests must preserve the six-plus-ten animation contract, hard outer edges, translucent interior veil, tier escalation, and loader/world separation.
