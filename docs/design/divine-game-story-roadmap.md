# Divine Game Story Roadmap

## Status and Spoiler Boundary

This is the internal canonical roadmap for the divine Game, King's long-term motive, and the staged reveal surrounding The One Above. It contains story spoilers that must not be copied directly into early player-facing dialogue, expedition descriptions, marketing copy, or UI.

This document records story/design direction only. It does not mean that the opening sequence, Stage VII, Stage IX, Stage XX, the Disciples, rival Champions, future gods, or their assets and mechanics are implemented.

Use these labels throughout this roadmap:

- **Accepted:** durable direction unless a later decision explicitly supersedes it.
- **Planned:** intended stage/story anchor whose exact production contract still requires approval.
- **Open:** deliberately unresolved and must not be silently invented during implementation.

## Accepted Story Foundation

### The universe and the Game are different things

Reality, the gods, and mortal worlds exist beyond the Game. The Game is a constructed system within that larger existence. It organizes Champions, stages, trials, monsters, rewards, materials, Sanctuary access, resurrection, progression, and divine interference, but it is not automatically the whole universe.

The One Above architected the Game. That title does **not** establish that he created reality, created every god, or is the strongest being in existence. His actual name remains open. `Aethron` is only a working possibility and must not enter permanent lore, stable IDs, dialogue, or asset names without separate approval.

The title is intentionally misleading from a mortal perspective. Early characters may reasonably interpret “The One Above” as a supreme-being claim. Much later, the story may challenge that assumption through the recurring idea that there is always something above.

### Mortal struggle is divine spectacle

Many gods treat mortal grief, hope, terror, rage, revenge, endurance, and transformation as entertainment, nourishment, research, wager, art, or proof. They do not all share one personality or moral position:

- some are openly cruel;
- some believe suffering improves mortals;
- some are indifferent to mortal cost;
- some appear compassionate while manipulating outcomes;
- some may oppose the Game or be constrained by divine law.

Early player-facing story must not simply announce that “the gods are evil.” Their disregard for mortal life should emerge through evidence, contradictions, choices, and consequences.

### King is a selected Champion

King loses his family and dies or falls in his former world. In the transitional Sanctuary/Veil space, an unknown entity appears only as `???` and offers him another chance. The entity suggests that his family's souls still exist somewhere beyond King's current reach and that survival, growth, and continued ascent may lead him to them.

King enters the Game willingly. He initially believes this being saved him and preserved the only hope he had left. His immediate motive is therefore sincere and understandable:

1. survive the Game;
2. recover his fractured memories;
3. find his family and determine the condition of their souls;
4. reach the beings who understand or control the ascent;
5. learn why he was chosen and why the Veil remembered him.

King begins as a mortal father, not a chosen demigod who already understands divine rules. His supernatural growth must be earned through the journey.

## Internal Hidden Truth

The accepted long-term twist is that The One Above did not merely discover King after his tragedy. He selected King before or as part of it and was materially involved in creating the conditions that produced King's loss, grief, hope, struggle, rage, and growth.

The exact causal method remains open. Do not yet decide whether The One Above directly killed the family, ordered another actor, altered probability, commissioned a Champion, or transformed an existing disaster into part of the Game.

The family promise should not collapse into a trivial total lie. The preferred direction is that an authentic part of King's family—their souls, preserved identities, imprisoned continuities, or another genuine form—still exists because The One Above deliberately retained the source of King's hope. Their exact condition remains open.

The manipulation is therefore:

`selection -> engineered or exploited loss -> preserved hope -> voluntary entry -> observed growth`

King believes he was rescued. Internally, he was motivated. This truth is not early player knowledge.

## Disclosure Ladder

| Story band | What King and the player may understand | What must remain hidden |
|---|---|---|
| Revised opening | `???` offers King a return and says his family may still be reachable | The title, the Game's architect, Champion selection, and responsibility for the tragedy |
| Stages I-VI | Sanctuary and staged realms are real; corruption sometimes imitates memory; divine forces exist | The gods as the central antagonistic structure and The One Above's personal interest |
| Stage VII | A Disciple identifies The One Above as the being responsible for King's return and reinforces that King's family still exists | The One Above's involvement in the tragedy and the full purpose of Champion selection |
| Stage IX vicinity | Ancient magical/divine infrastructure makes the Game's constructed nature more visible | The complete architect, hierarchy, and family truth |
| Stage XX | King directly confronts The One Above, still presented partly as benefactor and examiner; impossible knowledge creates the first major crack | The entire tragedy must not automatically be explained in one conversation |
| Later arcs | Other gods, other Champions, divine factions, and incompatible accounts challenge the supreme-title assumption | Final hierarchy and The One Above's ultimate place remain open until explicitly authored |

Story delivery should prefer short dialogue, environment, enemy behavior, artifacts, recovered memories, boss phases, and contradictions over exposition dumps.

## Revised Opening — Planned, Not Implemented

The current title-to-Sanctuary flow remains runtime truth. A later opening revision should establish:

1. King's fall or death after losing his family.
2. A strange transitional Sanctuary or Veil space.
3. A conversation with `???`, not a named god.
4. An offer to return or continue.
5. A credible suggestion that King's family is not completely gone.
6. King's voluntary acceptance and entrance into the Game.

The opening should create more questions than answers. It must not name The One Above, explain the Game's complete rules, reveal divine culpability, or confirm the family's exact condition.

## Immediate Production Bridge

### Stage VI final balance pass

Stage VI is implemented with eight Crag Bears, fourteen Forsaken Thralls, five Bramble Spitters, and one Armored Hog under a five-live cap. Owner feedback says the late stage still feels somewhat easy.

Before Stage VII implementation, test composition-first pressure changes in Waves 4-5. The first candidate is approximately two Armored Hogs across the late-wave section, placed so their committed charges create target-priority pressure with Bears, Thralls, and Spitters. Preserve the approved Bear quantity. Do not compensate by globally inflating health or damage.

No exact Hog count or wave edit is accepted until the candidate composition is played at 960x540 with no armor, starter gear, and the Stage V set.

## Stage VII — The Examiner's Choice

### Role and environment

Stage VII is a compact story/spice stage, not the large magical-ruins production. Its ordinary Continue route reuses the established top-down Forest-region grammar and remains inexpensive enough that character, dialogue, choice, and combat quality receive the production budget. Decision 133 gives only the optional white-gold Challenge branch a separate one-screen divine arena, provisionally called the Court of the First Measure. This does not move Stage IX's larger magical-ruins identity into Stage VII.

The stage introduces the first **Disciple of The One Above**, using the accepted role title **The Examiner**. He has a masculine, tall, lean, athletic silhouette; pale ivory/white-stone armor; restrained gold geometry; a smooth fully covered mask; long controlled lines; and a Divine Split Glaive. `Examiner` is a role title rather than a finalized personal name. Decision 132 and `docs/design/disciples-of-the-one-above-visual-contract.md` own his art-first scale gate, animation, weapon, palette, and reusable-asset contract. He does not need to match King's size; a tall or huge approved presentation is acceptable.

### Narrative function

The first Disciple is calm, curious, polite, and potentially respectful. They recognize King without behaving like an obvious villain. Their dialogue should connect the opening entity to The One Above and increase King's trust:

- the Disciple recognizes King as the selected mortal;
- their master knows King well;
- The One Above is identified as responsible for King's return;
- the Disciple may confirm that King's family genuinely remains somewhere beyond reach;
- nothing in the exchange should reveal that The One Above helped create the tragedy.

Any sample dialogue remains conceptual until the Stage VII conversation is separately approved.

### Two-path choice

The encounter presents an honest choice:

- **Continue:** take the ordinary route and proceed without fighting the Disciple.
- **Challenge:** enter the white-gold God-tier route and show the Disciple what King has become.

The choice should be embodied by two clear paths, portals, or equivalent world interactions rather than a misleading mandatory boss prompt. The normal route must remain understandable and available. Exact scene placement, return behavior, saving, health carryover, and replay rules remain part of the Stage VII implementation contract.

### Combat contract

The Examiner is far beyond ordinary Stage VII enemies but must demonstrate superiority through mechanics rather than cheap instant death. The base body and Split Glaive animation must communicate every action before VFX are added.

The first-pass combat design uses:

- controlled stance and deliberate footwork;
- properly animated weapon combinations;
- anticipation, contact, follow-through, and recovery;
- a dash or gap closer;
- high but explicit stagger resistance;
- an answer to basic-attack stun spam, such as a bounded parry, escape, or resistance transition;
- one recognizable divine technique, **Axiom Divide: First Measure**;
- strong, fair damage with readable telegraphs;
- correct use of existing hit-pause, damage, stagger, super-armor, and presentation boundaries.

Axiom Divide separates the Split Glaive into three readable sections, creates accurate sequential gold-white lane warnings and cuts, then commits the Examiner to a final marked dash. The special arena keeps its dormant engraving low contrast and provides genuine safe space; terrain decoration never doubles as an authoritative warning. `docs/design/examiner-court-of-first-measure-arena.md` owns the environment and presentation contract.

The expected first result is not the Disciple's death. At a designed threshold, on King defeat, or after a readable test condition, the Disciple may stop the encounter and permit King to continue rather than triggering an ordinary Game Over.

The encounter must also handle abnormal player performance:

- declining the challenge;
- expected defeat/test completion;
- reaching the intended recognition threshold;
- unexpectedly depleting the Disciple's combat threshold through grinding, a powerful build, or later replay.

Unexpected victory earns distinct recognition and dialogue but does not permanently kill the Disciple or break later story continuity. Exact rewards and replay access remain open; no mandatory progression reward should depend on beating an intentionally overpowered optional opponent.

### Future second Disciple

The One Above has a future second important Disciple using the accepted role title **The Executioner**: a feminine/subtly feminine, taller, broader, heavily armored contrast who is contemptuous of mortals and willing to kill King if not restrained by orders. Her smooth covered mask, darker white-stone/void armor, restrained violet accents, four to six fractured halo pieces, and broken circular Divine Execution Wheel establish future visual continuity. Stage VII introduces only the Examiner; a single restrained reference to a harsher sister/peer may foreshadow the Executioner without showing or explaining her. She remains documentation-only, and neither role title is a final personal name.

## Stage IX — Reclaimed Magical Ruins

Stage IX, not Stage VII, is the planned home for the larger magical-ruins identity. It should still use modular top-down pieces rather than one monolithic backdrop:

- broken stone paths and reusable edge/corner pieces;
- ruined pillars, moss-covered walls, and old statues;
- restrained runes or crystals;
- small pools and streams that continue the region's water language;
- vegetation reclaiming constructed space;
- clear combat lanes, navigation, occlusion, and reusable collision owners.

Two provisional recurring-enemy roles create the encounter's core relationship:

1. **Fast Mage / ranged caster:** attacks at range, repositions rapidly, performs one bounded retreat when crowded, then stops at a useful distance and resumes legal combat. It must never reproduce infinite directly-away Bramble Spitter kiting.
2. **Stone Warden / golem:** very durable, highly stagger-resistant, physically large, and capable of controlling space through path occupation, heavy melee, shockwave pressure, and an occasional short forward commitment. Its role is to protect ranged threats, not merely walk slowly with high health.

Their exact identities, names, art, stats, drops, and recipes remain unapproved. Their material families should prepare later accessories:

- Warden material: durable, physical, ancient, or structural component;
- Mage material: magical, arcane, resonant, or channeling component.

Common through boss rarity should continue expressing acquisition intent. Drops must support a real recipe purpose without making every important material guaranteed or creating purposeless grind.

## Stage XX — First Direct God Encounter

Stage XX is the planned first direct confrontation with The One Above. It is not a declaration that he is the universe's strongest god or the final boss.

From King's current perspective, The One Above should appear absurdly powerful and may intentionally restrict himself to participate in his own Game. He fights because King's development has become personally interesting, not because of simple hatred.

He initially retains the demeanor of a benefactor:

- congratulates King's progress;
- frames the encounter as another trial;
- treats participation as attention or favor;
- does not immediately confess the hidden truth.

The first major fracture comes from knowledge he should not possess: private details of King's original tragedy that King never disclosed. King's question—conceptually, “How do you know that?”—opens suspicion without resolving the entire mystery at Stage XX.

Exact arena, phases, outcome, rewards, return rules, and later rematch structure remain open and must not be implemented from this roadmap alone.

## Future Divine Expansion

No rigid divine hierarchy is accepted. `God` is a category or nature, not an automatic maximum-power label. Future beings may consider The One Above an equal, rival, superior, subordinate, entertainer, or minor architect.

Other gods may select their own Champions. This permits future rival Champions, divine factions, wagers, blessings, curses, interference between patrons, loyal worshippers, informed participants, discovered victims, and rebels. These are world-building opportunities, not promised runtime systems.

The long disclosure rhythm is:

`mysterious rescue -> architected Game -> Disciples -> other gods -> competing Champions -> impossible knowledge -> suspected complicity -> engineered suffering -> a hierarchy still beyond him`

## Data and Production Boundaries

- `StoryState` remains the durable owner of occurred events, discoveries, victories, and narrative keys. A story flag records an event; it does not silently grant combat power.
- Stage flows own when dialogue and choices occur. Dialogue presentation does not own travel, rewards, combat results, or save authority.
- Reusable enemy, projectile, VFX, sound, material, and environment identities must not include the stage number merely because that stage introduces them. Stage data composes reusable content.
- Frame-authored important enemies use `AnimatedSprite2D` with named `SpriteFrames`. VFX enhance readable body animation and never conceal missing physical action.
- The Stage IX and Stage XX sections are roadmap only. Do not generate their actors/environments or add sealed runtime resources until their individual content contracts are approved.

## Open Decisions Before Stage VII Implementation

1. **Resolved:** the two-character reference is preserved and static Examiner V2 is the approved design direction. Exact runtime normalization remains open.
2. The Examiner's personal name, speaking voice, exact shared divine emblem, and final mask-detail simplification.
3. Owner approval/correction of the special-arena empty preview, plus exact placement of the ordinary and white-gold portals on the compact Stage VII route.
4. Challenge start confirmation, surrender/exit behavior, test threshold, expected-loss handling, and abnormal-victory logic.
5. Whether Stage VII contains ordinary enemies before or after the Examiner, and which reusable roles appear.
6. Reward and replay contract, including whether later Hunts can revisit the test.
7. Exact dialogue and which family fact the Examiner is permitted to confirm.
8. Stable story IDs and safe-point timing.
9. Measured Stage VI Wave 4-5 composition after the late-Hog experiment.
