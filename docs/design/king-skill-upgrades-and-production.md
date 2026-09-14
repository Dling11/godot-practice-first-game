# King Skills 1-2: upgrade and production plan

**Owner correction (2026-09-14):** Intended Advanced is three spatial lanes in a rotating fan (center plus two angled sides) for wider AOE. The current sequential Cascade remains implemented and preserved as a possible later/third upgrade; it is not the accepted Advanced design. Fan implementation is pending. Resume from [the handoff](earthsplitter-fan-handoff.md).

Status: Skill 1 Foundation motion proof is implemented in the Lab (Decision 150), September 14, 2026. Advanced Cascading Rupture is also implemented in the Lab (Decision 152), pending owner feel review. Other forms, gates and Skill 2 are planning only. Numbers below are prototype targets, not final campaign balance. The separate-summon correction in [the concept note](king-spirit-sword-concepts.md) overrides the older images. Current proof: .36s base commitment, .20s contact, 164px range, 17px lane radius and 165% weapon damage once per enemy; existing hit pauses add wall-clock time. Current equipment attack-speed bonuses affect basic attacks, not skill phase speed; no new cast-speed stat is introduced.

The September 14 owner-approved sword is the durable summoned-weapon reference (Decision 151). Foundation now has fixed 164px directional aiming and sequential ground eruptions with embedded white-blue energy; its decorative endpoint burst is not the planned upgraded damaging explosion; stage-based unlocks described below are still planned; Advanced can currently be selected manually in the Lab. Within each future form, cursor distance should not alter reach; authored stage/form data sets its bounded range.

## Locked direction and responsiveness

King acts while a distinct large sword appears. Earthsplitter swings into the ground and sends a fast rupture toward the aim. Molten Crash briefly lifts its summoned sword before a local impact around King. Preserve the approved compact character and molten palette.

Target a 0.32-0.42 second player commitment at baseline equipment speed, with first contact around 0.18-0.24 seconds. These are starting targets for the motion proof. Target selection time is separate. Higher forms must not extend the commitment. Respect existing equipment/cast-speed authority; do not independently accelerate damage and animation clocks. Summoned weapon, rupture and debris can finish after movement returns. No new invulnerability is assumed.

Use short anticipation, accelerating travel, a crisp contact beat and a short body recovery. Author enough distinct poses and smear/impact drawings to cover these beats without slowing playback to show every drawing.

## Proposed upgrade forms

These are upgrade ranks within each skill, not new equipped slots. Skill 2 remains the stronger close-area control tier; Skill 1 owns aimed lane pressure. Ten-slot progression remains intact.

| Form | Earthsplitter | Molten Crash |
| --- | --- | --- |
| Foundation | One short advancing fracture and one damage opportunity per enemy. Clear, narrow aimed lane. | One compact circular impact. Explicit stun on initial contact only. |
| Advanced (corrected intent; pending) | Three spatial lanes released together: center plus two angled sides for wider AOE. Current sequential Cascade is preserved as a possible later/third upgrade; its rank and fan combination remain undecided. | Moderately wider impact and higher damage. A clearer outward dust/ember burst, not a longer cast or longer stun. |
| Awakened | The last rupture section detonates. Reserve part of the cast's damage budget for that endpoint; accurate placement earns it. | One brief heat aftershock remains at the original impact location. It deals damage but never reapplies stun. |
| Mature | Stronger endpoint and modest lane-width growth; a capped visual crescendo. Preserve the recognizable swing and earth-tearing silhouette. | Stronger central impact with a gentler outer edge and one aftershock. Retain a bounded radius and readable enemy telegraphs. |

Current Earthsplitter Lab budgets: Foundation 165% and Advanced 225% weapon damage (1.364x Foundation). This supersedes the earlier illustrative 1.15x Developed target. Advanced releases at 0/.16/.32s after contact, each wave traveling .25s, with the same .36s player cast and 5s cooldown. Apply existing equipment, mastery and eligible combo modifiers once before splitting the budget. Later-form and Molten Crash budgets need fresh tuning above this tested baseline; no four-step campaign damage ladder is implemented.

For Awakened Earthsplitter, initially test 70% of the budget in the advancing rupture and 30% at the endpoint. For Awakened Molten Crash, initially test 80% on the crash and 20% on its aftershock. Mature redistributes its budget across center/rim/aftermath rather than adding a full-damage hit for each visual layer. One cast needs per-target hit accounting.

Start with maximum growth limits of 1.4x Earthsplitter length, 1.25x lane width and 1.2x Molten radius relative to each Foundation form. A 1.2x radius already gives 1.44x area. Actual base dimensions must be tested against the arena and enemy sizes.

## Stage and level progression

Verified runtime: King mastery adds 2% skill weapon damage per level after 1, capped at 18%; king_path starts the level ceiling at 3, unlocking 4/5/6/7/10 after the first five stage clears. These existing rules remain authoritative.

Plan each new stage-clear upgrade as a bounded damage/range/area step within its unlocked form. Larger behavior changes require an authored progression milestone, not repeated farming. First-region content should teach Foundation and Advanced; later region/boss rewards can unlock Awakened and Mature. Exact stage numbers beyond implemented content remain unset, rather than inventing Stage 10/20 progression that does not exist yet. Do not change the eventual whole-game level cap here.

Repeated stage clears cannot repeatedly award the same upgrade. After the final form, equipment and future skill choices remain relevant without infinitely increasing hit counts or screen coverage. Additional stored charges are deferred until cooldown and damage-budget testing; extra rupture sections are not charges.

## Trails, particles and sound

Earthsplitter: a brief curved white smear follows the summoned blade only during its fast swing. At contact, a compact white flash and stone chips launch a jagged fracture. Light lives inside the split; broken floor plates and the advancing dust front define the trail. No clean flying crescent, dotted lightning line or stationary magic-geyser chain.

Molten Crash: a short upward ember draw precedes the descending sword. Contact creates white-hot orange cracks, low outward debris and brief sparks. The residual cools toward dark red and charcoal. The aftershock is a quick readable pulse, not continuous bright fire hiding enemies.

Keep large particles away from King's face and enemy tells. Ground scars stay at their contact location; debris follows short arcs and settles. Particle density increases less than damage does. Preserve the established pixel density, outlines, palette and camera perspective.

Audio recipe: quiet manifestation cue -> fast sword/air movement -> contact crack plus restrained low impact -> short stone scatter (Skill 1) or subdued heat tail (Skill 2). Avoid a separate loud boom on every upgraded rupture section. Give the endpoint one accent; cap simultaneous sounds and shake so crowd hits cannot multiply loudness or camera motion. Reuse existing accepted-hit feedback authority; physical ground contact and confirmed enemy hit remain separate events.

## External resource shortlist

Official creator pages checked September 14, 2026. These are candidates and references, not installed assets or auditioned final sounds.

| Resource | Intended use | Published terms / status |
| --- | --- | --- |
| [Kenney Impact Sounds](https://kenney.nl/assets/impact-sounds) | Audition short impact/foley layers for contact and debris. | 130 files; CC0. |
| [Kenney RPG Audio](https://kenney.nl/assets/rpg-audio) | Audition weapon movement and supporting foley. | 50 files; CC0. |
| [Pimen Earth Spell Effect 01](https://pimen.itch.io/earth-spell-effect-01) | Reference rock formation, break-up and impact timing; potential supporting art after style review. | Name-your-price; personal/commercial modification allowed; sprite resale/redistribution prohibited; credit appreciated. |
| [Pimen Fire Spell Effect 02](https://pimen.itch.io/fire-spell-effect-02) | Reference explosion shape changes and cooling aftermath; potential supporting art after style review. | Two explosion animations; same stated use/modification and redistribution terms. |
| [GDQuest: Juicing up your game attacks](https://www.gdquest.com/library/juicy_attack/) | Study short anticipation, swing-only smear, easing and layered feedback. | Technique reference; no code/assets copied in this plan. |

Use references to improve timing and shapes while retaining King's identity and our approved sword/ground-effect language. Do not mistake a pack's frame count for final animation quality. If a pack is adopted, preserve its actual included license and source attribution; do not publish its raw sprites as a redistributed asset pack. No purchases or downloads in this planning pass.

## Execution order and acceptance

1. Skill 1 baseline motion proof: separate spawn, weighted fast swing, blade-to-ground contact, moving rupture and early control return. Show real-speed playback plus slow review.
2. Test against walls, multiple targets, four facing directions and equipment speed extremes. Damage must coincide with visible contact; weapons cannot clip their frame edges. No stun on Skill 1.
3. Build Skill 2 using its approved local molten design, the lift/drop motion and explicit first-impact stun only. Verify boss resistance and movement during aftermath.
4. Compare Foundation and upgraded forms side by side at equal equipment. Test per-target damage budgets, stage unlock persistence, bounded size, repeated input and busy-scene audio/readability.
5. Replace old alternatives only as part of the reviewed integration step. No runtime removals or new god-power lore are performed by this plan.
