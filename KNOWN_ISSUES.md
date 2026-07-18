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

### KI-005 - Skill awakening, expanded equipment balance, and disk persistence remain incomplete

- **Status:** Open
- **Impact:** Ashwood/Iron ownership, one 18-coin Orren purchase, class-gated equip commands, and defeat/scene retention now work in memory, but closing the application loses them. Drops, selling, armor/stat aggregation, higher tiers, authored Eira awakening, and slots 2-4 content remain incomplete.
- **Planned resolution:** Implement Eira's free level-eligibility awakening next, then approve a versioned disk profile and expand acquisition/balance only with authored enemies and content.
- **Workaround:** Treat Ashwood as the permanent fallback and Iron as the complete beginner shop slice. Do not expose legacy/high-tier previews, sell skills, or claim session ownership is a disk save.

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
