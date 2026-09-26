# 159 - Put King's active buff in Skill 4 and retain Worldsplitter in Skill 5

Date: 2026-09-27. Status: direction approved; art/gameplay review and implementation pending.

## Context

The current fourth skill, Worldsplitter, is a large targeted spirit-sword attack. King already has an aimed lane, local stun impact, and targeted mobility. The owner wants an active damage-and-protection buff in fourth position, with a brief charge/body-centered burst and an aura that persists while King moves and fights. Worldsplitter should move to the fifth position and remain available to existing players.

## Decision

Develop Skill4 as a self-buff with a generated activation and persistent blue protective shell. Preserve King C's identity, dimensions, palette and outline; the owner explicitly permits new action poses, not a redesign. Use a short planted brace/pressure release, restrained crimson offense accents, an Advanced movement-speed bonus and a Mature empowered third combo strike. This replaces the earlier Mature recast-explosion proposal. Numeric values/gates remain tuning candidates. Move Worldsplitter to slot5 only when the replacement is playable; preserve its stable ability ID and saved ownership. Existing players keep it learned/equipped. The older counter-only Unbroken Stand remains superseded. See `docs/design/king-skill-4-unbroken-vow-proposal.md`.

## Consequences

Visual refinement after owner feedback: use an enclosing curved barrier, an activating underfoot seal, and distinct concentrated arm/weapon power accents. Protection and outgoing damage must be identifiable from the effect. The six-drawing V2 review supersedes the floating-shard look; runtime implementation and balance remain pending.

The fifth slot becomes meaningfully equipped without losing an existing skill. Slot numbers remain input bindings rather than ability IDs. Saved four- and ten-slot layouts need explicit migration that preserves current ability ownership and user choices. The current live game deliberately stays on Worldsplitter in slot 4 until the buff can replace it without an empty action. The six-frame generated aura review is not a runtime SpriteFrames resource or proof of gameplay balance.
