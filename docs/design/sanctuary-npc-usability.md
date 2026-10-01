# Sanctuary NPC and skill-menu usability

2026-10-02. The owner redirected work from additional houses/interiors to useful NPC services, readable layouts and skill arrangement. Further interior work is deferred. Retain the approved workshop furniture size and F-required entry.

## Eira approach and service

In the optional study Eira stands at (400,450), to the right of the lectern at (344,410). Her visit/interaction approach is (400,486). The neighboring lamp moves to (456,432), clearing the label and approach. The name is checked against the actual book silhouette at native size. Character art, body/trigger shapes, teaching animation, map tracking and service authority remain unchanged. Comparison restores the original NPC position.

Her prompt is **PRESS F · TRAIN & ARRANGE SKILLS**. Updated dialogue names the five current techniques, including Unbroken Vow, instead of retired four-skill content. Complete/skip dialogue to open Skills, then choose **TRAIN & ARRANGE**. Tab opens the ordinary character menu, whose Skills page offers **ARRANGE SKILLS** without Eira training permission.

## Skill presentation and interaction

- Equipped slots use two rows of five: 1–5, then 6–0. Icons are limited to 24px; the large Vow source no longer stretches its row. Arrow navigation follows the visible grid. Future Ultimate/Reality Breaking previews sit separately below the details, disabled.
- The training/loadout window lists the five techniques in core hotkey order. Selecting one shows its description, equipped slot and, where implemented, current rank, next-rank benefit, required level and current level. A disabled train button names the requirement instead of silently offering an unavailable action.
- Select a technique, then click a combat slot to equip it. Occupied skills swap using existing library rules. Right-click clears a slot; the explicit Clear selected slot button provides the same action without requiring right-click. Restore core layout restores learned core skills to 1–5. Result text reports assignment, clearing, restoration or training success/failure.
- Focus survives rebuilding after assignment. Esc returns from the collection to the paused character menu; Esc again closes that menu and resumes gameplay. Existing shared generated menu frames and modal/map exclusion remain.

The presentation is shared by normal play and review. Eira's relocated work corner remains study-only. This does not promote review environment art into the campaign or change skill balance, unlocks, costs or save policy.

## Authority and limits

`CharacterMenu` owns page context, the training/arrangement entry and grid focus. `king_skill_collection.gd` displays controls and dispatches intent through `KingSkillLibrary`; the library retains edit guards, slot swapping, trainer/level requirements, rank application and saving. No new progression grant or training rank is introduced. Pursuit still trains at Levels 5/8, Vow at 7/10 and Worldsplitter at 10/15; Earthsplitter/Molten later forms remain outside campaign training.

Review saves remain suppressed for the process. Eira skill arrangement can be tried safely there; training still depends on existing save authority. Normal training/persistence is verified using isolated test profiles, separate from the review.

## Test route and evidence

F5 -> Continue -> F10 -> **SANCTUARY REVIEW · NO SAVES** -> **Visit Eira** -> F -> finish/skip dialogue -> **TRAIN & ARRANGE**. Select Pursuit to see its Level 5 requirement. Select a technique and click a slot to swap, right-click to clear, or restore the core layout. The direct launcher accepts `--eira` after `--`.

Native evidence: `art_source/review/ui/sanctuary_functionality_2026_10_02/`. Earlier theme/scale captures remain preserved. No artwork was generated for this pass.

Verification: 43 rendered functional checks cover physical F, name/book separation, real pointer swap/clear/restore, live HUD/menu updates, arrow navigation, focus retention, requirements, ordinary-menu trainer exclusion, pause cleanup and save suppression. Shared interface: 64 rendered checks. Character menu and Pursuit trainer/persistence smoke pass; Vow and Worldsplitter training/persistence each pass 14 checks. Courtyard and prior study pass 90/94 headless checks. Existing GPU shutdown texture warnings remain; owner usability judgment and representative-phone profiling remain open.

## Next scope

Review this service flow, then improve Nema crafting and Umi exchange usability: selected-item clarity, requirements, result feedback and keyboard/mouse access. Continue skill-menu polish from observed play issues. Further houses/interiors remain deferred by owner direction; full-game production readiness and campaign promotion are separate milestones.
