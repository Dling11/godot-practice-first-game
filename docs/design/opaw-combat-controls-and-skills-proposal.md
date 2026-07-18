# Opaw Combat Controls and Skills Proposal

- **Date:** 2026-07-18
- **Status:** Movement-facing, left-click basic attack, dash-to-attack chaining, F9 testing, clickable immediate-direction activation, weapon scaling, and Piercing Rush are implemented. Ground targeting, later skill identities, exact future balance, and encounter pacing remain proposals.

## Player Direction

- WASD/left-stick movement becomes Opaw's combat-facing authority.
- Moving diagonally remains allowed, but four-direction art resolves facing from the dominant movement axis and retains the last non-zero cardinal direction while standing.
- Ordinary mouse motion no longer rotates Opaw or redirects basic attacks.
- Left mouse remains basic attack. The current three-swing outward/reverse/finish sequence remains the basic sword chain; right mouse is unassigned for a future reviewed action.
- Mouse input remains fully available for UI, clickable HUD skills, and explicit ground-targeting modes.

## Reusable Skill Activation Modes

Do not hard-code cursor behavior inside one skill. Each ability should declare one activation mode:

1. **Immediate directional:** pressing the key or clicking the HUD slot casts along Opaw's current movement-facing direction.
2. **Ground targeted:** pressing the key or clicking the HUD slot enters targeting, changes the cursor, and presents a range/area preview. Left click confirms a valid point. Escape, right click, or pressing the skill again cancels. Normal left-click attacks resume after targeting ends.
3. **Self/area:** activates around Opaw without a target cursor.

While a ground-targeted skill is pending, gameplay continues and Opaw may move. Damage, displacement, cooldown, and cast commitment begin only after a valid confirmation. A controller version should aim the preview with the right stick and confirm/cancel with explicit actions; passive right-stick aim must not silently override movement-facing basic attacks.

## Proposed Warrior Kit

### Basic Attack — Balanced Sword Chain

- Left-click.
- Current three visual variants remain: outward slash, reverse return, extended finish.
- Equipped sword owns authoritative base damage and knockback.

### Skill 1 — Piercing Rush

- **Implemented:** immediate directional thrust-dash using current facing, triggered by `1`, legacy Q, left shoulder, or the ready HUD slot.
- Opaw commits about 50 collision-limited pixels behind the sword, damages each target once along the narrow path for 135% snapshotted equipped-weapon damage, and uses 78 pushback without invulnerability.
- The detached sword enters a forward thrust while a white-gold spirit blade, blue/gold streaks, sparks, and shared confirmed-hit feedback carry the presentation. The existing weapon-technique sound is reused temporarily until timing is approved.

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

Sweeping Cut is preserved as a reusable learned technique/alternate loadout resource with its tested code, data, old slot, presentation, and fixed damage, but it is no longer equipped.

## Spectral Skill Presentation Strategy

- Opaw's equipped weapon remains the authoritative weapon throughout a technique. A skill does not secretly unequip it or switch weapon data.
- A white-gold spectral blade may briefly overwhelm or replace the small world-sword silhouette at the strongest thrust frame. If the equipment sprite is hidden, it is hidden only for those presentation frames and returns before recovery ends.
- Piercing Rush should read as Opaw driving a much longer spirit edge through the target: a narrow white thrust core, gold rim, short afterimages, and directional streak communicate power without changing the collision shape.
- The body, hitbox, resolved weapon damage, and equipped item stay independent from the spectral overlay. The overlay never decides contacts or damage.
- Stronger skills may grow the spirit silhouette, ground response, and finish impact, but enemy telegraphs and Opaw's facing must remain visible at 960x540.

## Damage Scaling and Power Budget

Move future weapon skills away from unrelated fixed damage. `AbilityDefinition` should support authoritative weapon scaling such as:

- base flat damage, when a skill truly requires it;
- equipped-weapon damage multiplier;
- an ordered list of per-hit multipliers for multi-hit skills;
- final-hit knockback and impact tier separate from cosmetic trail size.

The cast snapshots the equipped weapon and resolved damage when the skill begins so changing equipment cannot alter an attack already in progress. UI may display the formula but never calculates it. Exact multipliers remain balance decisions after the motion feels correct.

A skill's total power budget includes raw damage, hit count, area, stun or other control, mobility, defensive safety, commitment/recovery, cooldown, and any resource cost. Later slots should normally feel stronger overall, but slot number alone does not require every later technique to have the largest raw-damage number. A stun technique may trade some damage for control; a committed third skill should still have a clearly larger total payoff than a quick first skill. Balance should preserve the exciting motion and effect before considering reductions, while enemy health and encounter composition keep those tools from trivializing play.

## Encounter Length and Enemy Pressure

The current expeditions are acknowledged as short and lightly populated. Do not compensate by only inflating enemy health or dumping an unreadable horde onto one screen. With Piercing Rush now playable, measure time-to-kill, stage-clear duration, damage taken, crowd readability, and skill uptime, then extend encounters with authored reinforcement waves and mixed enemy roles. Stage 1 should still teach; Stage 2 should add ranged pressure; later elites and bosses should demand the stronger skill budget without becoming passive health sponges.

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

The implemented debug-build-only testing control changes test state without changing normal progression:

- `F9`: set the current run to level 10 and 999 coins, with a visible debug confirmation.
- A later debug action may awaken all authored test skills after real awakening authority exists.
- The shortcut must be ignored in release builds and must not claim disk-save behavior.

## Recommended Implementation Order

1. ~~Approve and implement movement-facing, left-click basic attack, dash-to-attack chaining, and the debug testing preset.~~ Completed on 2026-07-18; Piercing Rush now occupies Skill 1 and Sweeping Cut is preserved unequipped.
2. Feel-test the completed control remap and debug preset in Sanctuary and both stages.
3. Implement reusable skill activation modes and clickable HUD skill buttons. **Immediate-direction mode and clicking are complete; ground targeting remains open.**
4. ~~Build Piercing Rush completely, generating only the body/VFX/audio assets it proves necessary.~~ Completed with code-native spectral VFX and a temporary reused technique cue.
5. Build Consecutive Thrust and validate multi-hit feedback.
6. Approve and build the ground-targeted third skill.
7. Return to Eira's level-eligible free awakening flow using the finished skill definitions.
8. Design the ultimate separately after the ordinary Warrior kit feels coherent.
