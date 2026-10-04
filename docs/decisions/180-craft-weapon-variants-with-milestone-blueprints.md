# Decision 180: Craft weapon variants with milestone blueprints

**Implementation update (2026-10-04):** Axe V3 review now uses actual72px forward reach and68px radial whirlwind, side/rising/down/hop/spin actions, low carry and4s AFK back stow.48 registered body frames/20 white raster FX; native496 checks and melee/style regressions pass. Still an isolated stationary comparison, not normal collection/equipment/recipes. This preserves the accepted acquisition decision; previous36px/three-step proof details below are historical.

- **Status:** Accepted design direction; collection implementation pending
- **Date:** 2026-10-04

## Context and decision

The owner accepts the recommended crafting-led collection and asks to start. Separate fighting family, compatible item appearance/tuning, and acquisition. Campaign milestones/discoveries unlock known blueprints; purposeful materials and Nema's existing Rootforge produce the chosen weapon. Later stages expand variants rather than forcing a single family on every player. Start with two families and a few useful recipes, then expand the approved Sword/GreatSword/Dual/Axe/Scythe scope.

Allow many distinct owned designs and one equipped weapon; initially keep one copy per design. Guaranteed boss catalysts avoid progression depending entirely on random drops. Preserve existing IDs, Varkuun's usefulness and the Stage VIII accessory baseline. Stage11/20 were hypothetical examples; exact unlocks, costs and family order remain open. Random affixes, duplicate farming and dismantling are outside this first implementation.

## First implemented step

An isolated Iron Beard axe proof uses new body-only art, one canonical weapon texture and authored hand foreground masks. Eight right-facing poses observe the real melee wind-up/contact/recovery clock. It retains current sword contact/damage as explicitly temporary comparison tuning, with 0.24/0.13/0.31-second review timings. It has no walking, directional routing, equipment recipe or F5 promotion. Iron Beard is the first implementation candidate, not an independently owner-selected production variant.

The review disables player locomotion, hides the baked sword body/trail, reuses current cut sound and allows real target/Rootling contact. Storage is isolated, autosaving suppressed and Rootling reward components removed. An explicit reposition button moves the stationary rig into reach; Rootling attack range is unchanged.

## Consequences and next work

Prove other directions, genuine leg-exchange walking and skill/weapon transitions before normal equipment switching. Generalize CraftingService's fixed Stage V output catalog and explicit seal routing while preserving canonical validation, transaction rollback and old profiles. Then add the first two-family recipe choice through the existing Nema interface. Do not add fake recipes before these dependencies exist.

Sources: [weapon-family plan](../design/king-weapon-family-and-basic-hit-redesign.md), [proof source and prompt](../../art_source/generated/characters/king/iron_beard_motion_proof_2026_10_04/README.md).
