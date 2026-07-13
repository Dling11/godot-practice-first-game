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

### KI-005 - Skill unlocks, coin sinks, and disk persistence are undecided

- **Status:** Open
- **Impact:** The in-memory level-10 run, defeat reset, four-slot budget, and character information menu are implemented, but profile saves, coin sinks, authored unlock rules, and slots 2-4 content are undecided.
- **Planned resolution:** Design the first authored skills and unlock/currency rules after feel-testing the current reward pace and menu.
- **Workaround:** Keep XP and coins in-memory for the active run and keep slots 2-4 sealed; avoid random run-based upgrade assumptions.

### KI-006 - Title audio settings are session-only

- **Status:** Open
- **Impact:** Music, combat-sound, and menu-sound mute states return to defaults after closing the game.
- **Planned resolution:** Store audio preferences in the future versioned settings/profile system.
- **Workaround:** The title screen applies all three toggles immediately for the current session.

## Current Bugs

None currently. The project and main scene pass headless editor import and runtime loading under Godot 4.7 stable.

## Technical Limitations

No active crowd-separation limitation at the current four-enemy wave scale. Larger hordes still require profiling before increasing encounter caps.
