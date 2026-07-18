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
- **Impact:** The 960x540 baseline mechanically validates Opaw's active compact armless action set and the new compact Eira/Orren service corner, but their oversized-head/tiny-foot silhouettes, detached props, widened sword orbit, and new building/cart density still need human in-motion judgment in Sanctuary and both combat stages. The complete previous Wayfarer model is available as a safe player rollback if Opaw fails that review.
- **Planned resolution:** Feel-test Opaw's gameplay scale, serious black-eye/scarf readability, four-frame locomotion, three-pose body/weapon synchronization in all directions, dash lean, hurt recovery, defeat fade, Eira/Orren scale and role props, service-building collision, and representative effects in Sanctuary and both stages.
- **Workaround:** Treat 960x540 and the compact armless sheets as the active prototype baseline, not irreversible final assets; restore the archived Wayfarer `SpriteFrames` resource if a rollback is required.

### KI-005 - Skill unlocks, equipment acquisition, coin sinks, and disk persistence are undecided

- **Status:** Open
- **Impact:** The in-memory level-10 run, defeat reset, four-skill budget, and read-only Gear/Armory preview are implemented, but profile saves, owned inventory, equip commands, stat formulas, Stonebound/Iron/Rare acquisition, drops, prices, coin sinks, authored skill unlocks, and slots 2-4 content are undecided.
- **Planned resolution:** Approve persistent profile/death rules first, then inventory/equipment authority, acquisition and balance, and the first authored skills.
- **Workaround:** Keep XP and coins in-memory, slots 2-4 sealed, and Ashwood Blade as the only active starter presentation. Stonebound, Iron, and Rare remain planned; former high-tier concepts remain legacy-only. Do not grant items or apply preview power/synergy text to combat.

### KI-006 - Title audio settings are session-only

- **Status:** Open
- **Impact:** Music, combat-sound, and menu-sound mute states return to defaults after closing the game.
- **Planned resolution:** Store audio preferences in the future versioned settings/profile system.
- **Workaround:** The title screen applies all three toggles immediately for the current session.

### KI-007 - Story memory is not persisted to disk and future expeditions have no content

- **Status:** Open
- **Impact:** The Sanctuary portal now evaluates data-driven level, story, boss, discovery, and narrative key-item requirements, but `StoryState` survives only for the current application session. Ashen Pilgrimage and The Drowned Bells have no destination scenes, required boss encounters, or obtainable key items.
- **Planned resolution:** Approve the first versioned disk-profile boundary, then author the Thornbound Warden, Cinder Sigil, and Ashen Pilgrimage before enabling Route II.
- **Workaround:** Forgotten Grove remains the only playable portal-selected route. Future routes honestly display their first unmet requirement and remain sealed even if test code satisfies their requirement data.

### KI-008 - Expeditions have no voluntary return action

- **Status:** Open
- **Impact:** After entering Stage 1, the player must complete the current Stage 1-to-Stage-2 route or restart after defeat before returning to Sanctuary.
- **Planned resolution:** Add a confirmed `Abandon Expedition / Return to Sanctuary` pause-menu action after defining when it is allowed and whether current run XP/coins are retained.
- **Workaround:** Complete Stage 2 to use its existing Sanctuary return portal.

## Current Bugs

None currently. The project and main scene pass headless editor import and runtime loading under Godot 4.7 stable.

## Technical Limitations

No active crowd-separation limitation at the current four-enemy wave scale. Larger hordes still require profiling before increasing encounter caps.
