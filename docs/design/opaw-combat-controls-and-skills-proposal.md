# Opaw Combat Controls and Skills Proposal

- **Date:** 2026-07-18
- **Status:** Discussion; not implemented or accepted as final balance

## Player Direction

- WASD/left-stick movement becomes Opaw's combat-facing authority.
- Moving diagonally remains allowed, but four-direction art resolves facing from the dominant movement axis and retains the last non-zero cardinal direction while standing.
- Ordinary mouse motion no longer rotates Opaw or redirects basic attacks.
- Right mouse becomes basic attack. The current three-swing outward/reverse/finish sequence remains the basic sword chain.
- Mouse input remains fully available for UI, clickable HUD skills, and explicit ground-targeting modes.

## Reusable Skill Activation Modes

Do not hard-code cursor behavior inside one skill. Each ability should declare one activation mode:

1. **Immediate directional:** pressing the key or clicking the HUD slot casts along Opaw's current movement-facing direction.
2. **Ground targeted:** pressing the key or clicking the HUD slot enters targeting, changes the cursor, and presents a range/area preview. Left click confirms a valid point. Escape or pressing the skill again cancels. Right-click cancellation may flow immediately into basic attack after feel testing.
3. **Self/area:** activates around Opaw without a target cursor.

While a ground-targeted skill is pending, gameplay continues and Opaw may move. Damage, displacement, cooldown, and cast commitment begin only after a valid confirmation. A controller version should aim the preview with the right stick and confirm/cancel with explicit actions; passive right-stick aim must not silently override movement-facing basic attacks.

## Proposed Warrior Kit

### Basic Attack — Balanced Sword Chain

- Right-click.
- Current three visual variants remain: outward slash, reverse return, extended finish.
- Equipped sword owns authoritative base damage and knockback.

### Skill 1 — Piercing Rush

- Immediate directional thrust-dash using current facing.
- Opaw commits forward behind the sword, damages targets along the path, and ends with a sharp white thrust line and restrained impact stop.
- This should be the first new vertical slice because it validates movement, collision, hit delivery, body pose, sword pose, VFX, SFX, and camera feedback together.

### Skill 2 — Consecutive Thrust

- Immediate directional multi-hit technique.
- Several narrow thrusts build rhythm; minor hits use light feedback so repeated hitstop does not make the game stutter, while the final thrust receives the strongest white flash, knockback, sound, and camera response.
- Multi-hit deduplication must be authored per strike rather than bypassing the shared hurtbox contract.

### Skill 3 — Provisional Ground-Targeted Leap

- Candidate identity only; final name and balance are open.
- Enter ground-target mode, confirm a reachable point, leap/vanish toward it, then land with a sword impact, circular or forward-biased area hit, dust, and separate ground-crack presentation.
- Ground cracks are presentation assets and never determine the authoritative damage area.

### Skill 4 — Ultimate

- Identity remains intentionally open.
- It should receive the strongest unique anticipation, red Eira awakening ritual, musical/SFX accent, hit feedback, and screen presentation without sacrificing readable danger or dodge timing.

Sweeping Cut should be preserved as a reusable learned technique or alternate loadout skill instead of deleting its tested code and assets. Whether it stays equipped during the transition is an approval choice.

## Damage Scaling Proposal

Move future weapon skills away from unrelated fixed damage. `AbilityDefinition` should support authoritative weapon scaling such as:

- base flat damage, when a skill truly requires it;
- equipped-weapon damage multiplier;
- an ordered list of per-hit multipliers for multi-hit skills;
- final-hit knockback and impact tier separate from cosmetic trail size.

The cast snapshots the equipped weapon and resolved damage when the skill begins so changing equipment cannot alter an attack already in progress. UI may display the formula but never calculates it. Exact multipliers remain balance decisions after the motion feels correct.

## Feedback and Theme

- Reuse the existing accepted-hit white enemy flash, white-hot burst, world damage numbers, sound routing, and non-stacking hitstop boundary.
- Give each skill an authored impact tier. Repeated small hits receive restrained feedback; committed finishers receive longer but still bounded presentation pauses.
- Keep simulation timing authoritative and avoid global time-scale freezes.
- White/gold sword energy remains Opaw's grounded Warrior language. Violet/gold belongs to normal Eira awakening; red orbiting energy is reserved for ultimate awakening.
- Large slash shapes, landing dust, and cracks must remain readable at 960x540 and must not hide enemy telegraphs.
- Search or generation of external sounds happens only after a skill's timing is approved. Prefer reusable CC0 material with recorded attribution and separate Music/SFX ownership.

## Asset and Code Organization

```text
data/abilities/opaw/warrior/<skill_id>.tres
gameplay/abilities/targeting/
gameplay/abilities/opaw/warrior/
assets/characters/playable/opaw/skills/<skill_id>/
assets/effects/skills/opaw/<skill_id>/
assets/audio/sfx/skills/opaw/<skill_id>/
art_source/generated/skills/opaw/<skill_id>/
ui/targeting/
```

Reuse Opaw's stable body sheets and detached sword rig when the action remains readable. Generate a dedicated action sheet only when the skill needs a silhouette that existing wind-up/active/recovery poses cannot communicate, such as a deep thrust brace or airborne landing. Preserve source and cleaned intermediates, normalize to the existing foot/body scale, and keep VFX/SFX independently replaceable.

## Development Testing Preset

Add debug-build-only testing controls rather than changing normal progression:

- `F9`: set the current run to level 10 and 999 coins, with a visible debug confirmation.
- A later debug action may awaken all authored test skills after real awakening authority exists.
- The shortcut must be ignored in release builds and must not claim disk-save behavior.

## Recommended Implementation Order

1. Approve movement-facing, right-click basic attack, Sweeping Cut preservation, and provisional skill identities.
2. Implement the control remap and debug testing preset with regression coverage.
3. Implement reusable skill activation/targeting modes and clickable HUD skill buttons.
4. Build Piercing Rush completely, generating only the body/VFX/audio assets it proves necessary.
5. Build Consecutive Thrust and validate multi-hit feedback.
6. Approve and build the ground-targeted third skill.
7. Return to Eira's level-eligible free awakening flow using the finished skill definitions.
8. Design the ultimate separately after the ordinary Warrior kit feels coherent.
