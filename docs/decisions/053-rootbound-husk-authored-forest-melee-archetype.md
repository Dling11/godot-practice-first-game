# Decision 053: Rootbound Husk as an Authored Forest Melee Archetype

- **Date:** 2026-07-19
- **Status:** Accepted

## Context

The forest roster needs a third family, but a recolored Forsaken Thrall would add no new readable decision or future boss foundation. The player approved the larger Rootbound Husk: an evil bark-and-vine humanoid with roots, moss glow, and thorns that uses a distinct attack language. Later review correctly identified its tall antlered silhouette as too boss-like for the first small Stage 1 mob; Decision 054 assigns that beginner role to Rootling instead.

## Alternatives Considered

- Reuse the Forsaken Thrall controller and only replace its sprite.
- Introduce a more complex charging Thornback Ram before the base forest roster is established.
- Build a separate rooted melee archetype with one ground-root lane attack.

## Decision

Rootbound Husk is a dedicated enemy scene/controller, not a Thrall variant. It chases with a deliberate root-heavy walk, then anchors in place to telegraph a short forward crack before a `Root Spear` erupts along the ground. The player avoids it by stepping or dashing sideways; it uses no projectile and does not track the player after its wind-up begins.

Its initial Light-tier tuning target is 70 health, 48 px/s movement, 9 contact damage, a 0.62-second root/ground-crack wind-up, 0.14-second active spear, 1.05-second recovery, 0.75-second materialization, 13 XP, and 2 coins. The attack's own tapered forward lane—not effect pixels—owns damage. A complete direction-row animation package supplies walking, six attack poses, hurt/wither/defeat, and a separate four-cell ground-eruption VFX board.

## Consequences

- A later Stage 3 introduction gains a larger lateral-dodge role while the readable Stage 1 beginner space remains owned by Rootling and Stage 2 escalates only established forest roles.
- The Rootbound Elder can later evolve the same Root Spear language into multi-lane and arena-root boss mechanics without invalidating the base mob.
- The enemy requires independent art, collision, controller, audio, health UI binding, navigation, and regression coverage before it enters a wave.
