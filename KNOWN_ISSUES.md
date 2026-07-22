# Known Issues

This file tracks confirmed limitations, unresolved risks, and decisions blocking implementation. Remove resolved entries and record their resolution in `CHANGELOG.md` or `DECISIONS.md` as appropriate.

## Current Limitations

### KI-011 - Combat responsiveness, audio distinction, and Husk presentation need a playtest repair pass

- **Status:** Open
- **Audio progress:** Opaw's accepted-damage cue is now a distinct original cloth/body impact, and the dash uses a curated light CC0 swish; confirm their volume and clarity against every enemy attack in controller playtests.
- **Progress:** A focused smoke-tested input buffer resolves the reported rejected attack-to-skill follow-up without interrupting live damage or dash invulnerability, and the dash now has a separate 0.85-second reuse cooldown. Rootbound Husk uses direct-preloaded attack-profile typing, a redesigned stump-guardian body, a true contact/passing `72x64` walk, final-model root-command frames, four manually reviewed directional collapse sequences, an above-crown health bar, six-beat ground-root VFX, layered enemy-specific root audio, and a profiled quick-spear/slow-fan/point-blank-burst kit. Its focused tune is 280 health and 12 damage. Mireling now uses one smaller remodeled body across all 16 idle/hop/slam/collapse animations. Automated coverage protects these contracts; human audio balance, Husk time-to-kill, burst readability, dash feel, and controller playtesting remain open.
- **Impact:** Earlier playtesting reported rejected attack-to-skill follow-ups, repetitive dash/incoming-hit audio, unclear threat direction, and Rootbound Husk scale popping. The structural input and Husk animation causes are repaired, but only a controller playtest can approve their final feel.
- **Planned resolution:** Complete the roadmap's responsiveness, feedback/audio, and Husk-repair milestones in that order; measure each change with focused smoke coverage and a controller playtest before changing encounter counts or adding Stage 4 content.
- **Workaround:** Use F9 to test the completed skills and implemented routes; treat only Husk timing/readability and exact combat reach tuning as provisional, not its animation or attack-authority architecture.

### KI-010 - Expedition pacing still needs human controller playtesting

- **Status:** Open
- **Impact:** Automated coverage verifies the four-enemy cap, reinforcement warning/release order, queue completion, crowd spacing, and individual attack behavior, but cannot judge clear-time satisfaction, damage pressure, camera readability, or skill feel with Ashwood and Iron.
- **Planned resolution:** Record timed Stage 1 and Stage 2 controller runs using normal and F9 test loadouts, then adjust authored wave cadence only if the evidence shows a material pacing issue.
- **Workaround:** Keep the current one-at-a-time warned reinforcements, existing low-health starter enemies, and four-enemy ceiling; do not compensate with health inflation or a larger crowd.

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
- **Impact:** Ashwood/Iron ownership, one 18-coin Orren purchase, class-gated equip commands, and defeat/scene retention now work in memory, but closing the application loses them. Consecutive Thrust is complete only in F9's debug test loadout; normal Eira awakening, slots 3-4, drops, selling, armor/stat aggregation, higher tiers, and disk persistence remain incomplete.
- **Planned resolution:** Implement Eira's free level-eligibility awakening for Consecutive Thrust next, then approve a versioned disk profile and expand acquisition/balance only with authored enemies and content.
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

### KI-009 - Ground targeting and normal Skill 2 awakening are not implemented

- **Status:** Open
- **Impact:** Piercing Rush and F9-only Consecutive Thrust prove immediate-direction keyboard/controller/click activation, weapon scaling, cast direction locking, dedicated combat audio, exaggerated effect-only presentation, and Light/Elite/Boss crowd-control resistance. Six authored Stage 1 waves and seven authored Stage 2 waves now provide the current mixed-role pacing slice through controlled reinforcements at a four-enemy cap. No ground-target cursor/preview exists; normal progression still seals Skill 2 until Eira's future ritual, and slots 3-4 remain unimplemented.
- **Planned resolution:** Feel-test both authored techniques and the new encounter clear times, then measure skill uptime, crowd readability, and frame stability before any higher enemy cap. Build the reusable ground-target confirmation flow before the first skill that actually requires it, then return to Eira's free awakening authority.
- **Workaround:** Use F9 in a debug build to compare Ashwood/Iron and both completed Warrior skills quickly. Treat ground targeting, normal Skill 2 awakening, later skills, and encounter sizes above four active enemies as unimplemented.

## Current Bugs

None currently. The project and main scene pass headless editor import and runtime loading under Godot 4.7 stable.

## Technical Limitations

No active crowd-separation limitation at the current four-enemy wave scale. Larger hordes still require profiling before increasing encounter caps.
