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

### KI-005 - Progression persistence and exact scope are undecided

- **Status:** Open
- **Impact:** The compact authored introduction now targets XP, coins, roughly ten levels, and a small skill set, but save rules, death persistence, exact level cap, and three-versus-four active skills cannot be finalized yet.
- **Planned resolution:** Confirm those values after the first authored Stage 2 encounter establishes the playable scope.
- **Workaround:** Keep progression unimplemented while combat and stage boundaries are validated; avoid random run-based upgrade assumptions.

## Current Bugs

None currently. The project and main scene pass headless editor import and runtime loading under Godot 4.7 stable.

## Technical Limitations

No active crowd-separation limitation at the current four-enemy wave scale. Larger hordes still require profiling before increasing encounter caps.
