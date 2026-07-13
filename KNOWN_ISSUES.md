# Known Issues

This file tracks confirmed limitations, unresolved risks, and decisions blocking implementation. Remove resolved entries and record their resolution in `CHANGELOG.md` or `DECISIONS.md` as appropriate.

## Current Limitations

### KI-003 - Target platforms are undecided

- **Status:** Open
- **Impact:** Input, rendering, performance budgets, UI, and export decisions lack firm constraints.
- **Planned resolution:** Prioritize desktop, web, and/or mobile targets before the vertical slice.
- **Workaround:** Keep early designs platform-neutral where inexpensive.

### KI-004 - Pixel rendering baseline is not art-validated

- **Status:** Open
- **Impact:** The 960x540 baseline has strict directional sprite validation but no moving-camera or production animation timing validation yet.
- **Planned resolution:** Validate pixel stability with camera movement, richer walk cycles, and representative combat effects.
- **Workaround:** Treat 960x540 as the active prototype baseline, not an irreversible final asset constraint.

### KI-005 - Progression persistence and skill setup are undecided

- **Status:** Open
- **Impact:** The session-only level-10 XP/coin foundation is implemented, but save/death persistence, coin sinks, authored unlocks, and the three-versus-four active skill budget are undecided.
- **Planned resolution:** Design the skill-information/setup menu and unlock/currency rules after feel-testing the current reward pace.
- **Workaround:** Keep XP and coins session-only; avoid random run-based upgrade assumptions.

## Current Bugs

None currently. The project and main scene pass headless editor import and runtime loading under Godot 4.7 stable.

## Technical Limitations

No active crowd-separation limitation at the current four-enemy wave scale. Larger hordes still require profiling before increasing encounter caps.
