# Skill 4 proposal: Unbroken Vow

Status: role, blue barrier, planted pressure-release flow and upgrade identities approved, 2026-09-27. Numeric balance remains provisional. A down-facing activation-body/pressure/audio study now exists under `art_source/review/characters/king/unbroken_vow_activation_2026_09_27/`; it is not a playable buff. No production ability, loadout, save, audio, character frames, or Worldsplitter behavior changed. Existing players keep Worldsplitter learned and equipped after its eventual move to5. Until Skill4 is playable, Worldsplitter remains in the current fourth slot.

## Role

King briefly gathers power through his real greatsword and releases a sharp body-centered pressure burst. An elliptical ground seal rises into a connected curved blue-violet barrier enclosing his body, then follows him through walking, dodging, and other skills. Concentrated arm/greatsword energy communicates the outgoing damage bonus. The activation can create breathing room, but Molten Crash remains the local stun and Worldsplitter remains the large targeted finisher. The appearance never changes King's approved C sprite scale or redraws him per aura frame.

Owner visual correction, 2026-09-27: floating ornaments alone do not communicate protection. V2 replaces that visual direction with a wrapping shell and a more deliberate ground circle. `art_source/review/characters/king/unbroken_vow_v2_2026_09_27/` contains the current generated review; V1 remains historical comparison. This is a visual revision, not approval of balance numbers or a playable implementation.

## Proposed Foundation rules

- Start-up/return of control: 0.25–0.35 seconds, with the current body study at0.32s. King draws energy inward, braces, and the outward burst marks activation. The lingering aura runs while the player controls King.
- A one-time approximately 42px pressure pulse at activation pushes eligible Light enemies without damage or stun. Elite/Heavy/Boss control rules remain authoritative. No hit pause from a zero-damage push.
- For 6 seconds, a shield absorbs mitigated incoming damage up to 25% of current maximum HP. The shield is a separate temporary pool; it does not alter equipment armor, ward or maximum HP. A partial break passes excess damage through. No invulnerability; Examiner's authored Verdict still pierces Dodge and can overwhelm an early shield.
- While shield remains, basic attacks and damaging skills gain +12% damage. End the bonus when the shield breaks or the duration expires. Combine this additively with temporary Resolve and Pursuit-link bonuses before normal weapon/critical calculations, so stacking remains bounded and legible. The buff itself cannot consume Resolve or its own damage bonus.
- Cooldown prototype: 20 seconds from activation. The shield cannot stack with another cast of itself. Defeat, scene exit and skill reconfiguration clear its transient state.

These are first balance targets, not approved values. Measure against Stage VI crowds, starter/Stage V armor, the existing Resolve/Pursuit-to-Molten burst, and the Examiner's finite 800-raw Verdict before promotion.

## Eira upgrade ladder, proposed

| Form | Provisional training gate | Shield / duration / damage | New decision |
|---|---|---|---|
| Foundation | Learned with Skill 4 | 25% max HP / 6s / +12% | Quick activation push creates room, then shielded offense. |
| Advanced | Eira at Level 7 | 30% max HP / 7s / +15% | Add modest movement speed while shielded; begin testing at+8%, through existing equipment/movement rules and caps. |
| Mature | Eira at Level 10 | 35% max HP / 8s / +18% | Retain Advanced speed and empower the third basic-combo strike with a short rising step, heavy downward cut and compact pressure impact. Preserve normal combo timing, equipment speed and explicit stun rules. Final damage/radius need a separate measured prototype. |

The owner accepted this upgrade flow. It supersedes the earlier shield-break push and Mature recast explosion proposals. No automatic stun or jump invulnerability is granted by the finisher's appearance; no secondary cooldown, extra contact or uncapped damage budget is implied. Numbers and Eira gates are still tuning targets.

The current stage caps make Levels 7 and 10 reachable after Stages IV and V. Training should be manual through Eira, like Pursuit. No automatic upgrade on level-up. Worldsplitter stays learned and moves to fifth slot for existing players and fresh kits. Saved layouts require a migration that moves it from slot 4 to 5 while placing Unbroken Vow in slot 4, preserving explicitly customized other slots where possible.

## Animation, sound, and HUD contract

Activation-body study: eight192x128 pose slots, exact approved idle in first/last, one shared .25 source scale and y96 foot anchor. Standing body remains56px at .5 production scale; the brief brace compresses to52px and release rebounds to57px. The review has normal/slow/native GIFs, unchanged down-walk transition, separate generated crimson currents/ground pressure, a tiny release-only view jolt and an original .65s pressure WAV. This is a composited art study, not runtime gameplay. The first narrow-body generation was rejected; the final source uses an exact existing-sprite template, and two duplicated forearms were corrected with approved pixels. No new character design or UI scale is approved by this work.

V2 barrier semantics remain accepted: the ground seal ignites, curved shell rises, closure burst marks activation, then three quiet barrier drawings loop. Keep the center open so King and enemy tells remain readable, with a front lip over the boots and the rest behind the body. Surface glints indicate curved protective substance rather than detached gems. In production, crimson weapon-edge/forearm accents signal increased outgoing damage and follow the actual directional weapon. Remaining directions and weapon tracking still need authoring. The seal does not imply continuous ground damage. Accepted shield damage creates one localized ripple; low remaining shield introduces cracks; breaking removes shell and damage accents together. Natural expiry collapses quietly. These response states remain planned.

The V1 floating-shard source/review directories remain historical comparison. V2 owns the accepted shield design; the activation-body study layers new motion and pressure around it. Production still needs remaining directions, shield-break/expiry, Mature combo-finisher frames and careful moving-player depth. Keep one contact audio/camera cue per release; the sustain should stay quiet.

The shield needs a visible numeric/bar readout near King's HP or Skill4 status; the aura alone cannot communicate remaining protection. Show remaining duration without replacing ten-slot click targets. Aura VFX observes buff state. `HealthComponent` owns mitigated damage/partial absorption, a dedicated King buff component owns duration/rank, and outgoing damage and movement authorities own their temporary modifiers. The melee combo owns the Mature finisher contact. Save ranks, not transient shield time.

## Review boundary

Ready test route: F7 -> KING REVIEW -> BUFF TEST, or `tools/launch_unbroken_vow_test.ps1`. This now runs the down-facing pose and barrier on the real Player, returns control after .32s, and permits normal movement/dodge/attack during a six-second visual sustain. It grants no buff stats. The 31-check smoke plus King/Lab regressions pass; actual GPU screenshots and shutdown-warning evidence are in `art_source/review/characters/king/unbroken_vow_in_engine_2026_09_27/`. Always include this kind of owner-accessible test alongside future art/gameplay deliveries.

Role and visual flow are approved. Continue Foundation implementation in F7, validate the new poses against production King, and promote with slot migration after a playable comparison. Worldsplitter's existing stable ability ID can remain even when equipped in slot5; node names are not player-facing slot authority. Do not rename that ID or orphan existing saved layouts. The old counter-only Unbroken Stand remains superseded history.
