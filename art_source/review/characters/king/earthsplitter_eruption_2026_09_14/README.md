# Earthsplitter ground-eruption revision

The owner rejected the pressure-only trail as thin and boring. This revision restores the original rock/dust animation as a sequence of upright eruptions, with short white-blue flashes, a connected fracture bed, ballistic chips and a stronger endpoint beat. The approved sword source, atlas and animation are unchanged. Existing assets are composed directly; no new image generation was needed.

`earthsplitter_eruption.mp4` is actual Godot Lab playback at real speed, with existing hit pauses and audio. Nine headings (eight facings plus 17 degrees), near/far aiming, three-target damage and a width-aware terrain stop are included. Capture uses deterministic input, a fixed review camera and disabled enemy AI; this is an effect review, not a boss-balance demonstration. `earthsplitter_eruption.gif` is a silent opening excerpt.

The camera pulse now resolves the Lab feedback service correctly. Initial contact gets a 2.2px pulse and lower-pitched slam; the endpoint gets a 1.4px pulse and quieter higher crack. Feedback still uses the shared camera tween. No per-stamp sound stacking.

Damage is unchanged: one 165% weapon hit per target with flinch/push and no stun, 17px damage radius, fixed 164px nominal reach, .36s base commitment and .25s released travel. Visual endpoint spice is not an upgraded damaging explosion. Terrain, equipment, mastery, cooldown and saved-loadout restoration remain authoritative.

Earthsplitter 116 checks passed. Gameplay checks do not establish owner approval of the artwork. F7 > KING REVIEW > SKILL 1: EARTHSPLITTER; press 1, aim, left-click to confirm, right-click/Esc to cancel. Campaign replacement, upgrade forms and Skill 2 remain pending.

Source atlases: `assets/vfx/abilities/king/earthsplitter/rupture.png` and `pressure_v2.png`. Runtime composition: `gameplay/abilities/king/earthsplitter_ground_visual.gd`; capture: `tools/capture_earthsplitter_eruption.gd`. Original source/prompts remain under `art_source/generated/vfx/king/earthsplitter/`. Earlier pressure-only video remains available in the adjacent review folder.
