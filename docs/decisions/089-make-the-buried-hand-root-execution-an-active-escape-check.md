# Decision 089: Make the Buried-Hand Root Execution an Active Escape Check

- Status: Accepted
- Date: 2026-08-14

## Context

The boss needed one signature large-area threat beyond ordinary dodgeable contact. The owner proposed roots appearing beneath King, preventing skill-based escape, and a lethal delayed hit that the player actively breaks free from using the same action on keyboard, controller, and mobile.

## Decision

After each jump cycle, the boss buries and holds its root hand. A warning follows King's feet for 0.55 seconds, then locks to the world. Capture within 34 pixels deals 12 initial damage, cancels current combat actions and skill invulnerability, and restrains King for 2.2 seconds. While restrained, movement, attack, and skills are rejected; each shared dash activation removes one of five break points without starting dash cooldown. Escape leaves the broken prison and allows movement before the fixed execution. Failure applies one provisional 300 physical-damage hit. The execution remains armor-tankable in future rather than true damage.

## Alternatives Considered

- Immediate 300-500 damage would make struggle meaningless.
- Allowing movement skills to escape would let King's strongest traversal ignore the boss's signature check.
- A keyboard-only mash key would fail controller/mobile parity.
- Attaching the prison to Player would recreate the previously fixed moving-crater defect.

## Consequences

The proof now has an avoid, capture, active escape, miss, and failure-execution branch. `Player` gains a reusable restraint interface; the boss owns timing/damage; VFX and HUD only observe. Current 140 HP cannot survive the 300 hit, while future health/armor can potentially do so. Accessibility alternatives to repeated tapping remain a future settings decision.
