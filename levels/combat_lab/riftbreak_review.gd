extends Node

## Explicit, reversible Lab tuning comparison; no campaign resource mutation.
var actor: Player
var enabled := false
var _definition: RiftbreakDefinition
var _frames: SpriteFrames
var _scale: Vector2
var _slots: Array = []


func set_enabled(value: bool) -> bool:
	var library: KingSkillLibrary = actor.get_node("KingSkillLibrary")
	if enabled == value:
		return true
	if not library.can_edit():
		return false
	var component := actor.ability_2_component as RiftbreakComponent
	var visual: RiftbreakVisual = actor.get_node("AbilityPivot/RiftbreakVisual")
	visual._clear_visual()
	if value:
		_definition = component.definition
		_frames = visual.effect_sprite.sprite_frames
		_scale = visual.effect_sprite.scale
		_slots = library.current_ids()
		var tuning := _definition.duplicate(true) as RiftbreakDefinition
		tuning.activation_mode = AbilityDefinition.ActivationMode.GROUND_TARGETED
		tuning.target_range_pixels = 180.0
		tuning.effect_radius_pixels = 68.0
		tuning.stun_core_radius_pixels = 30.0
		tuning.outer_damage_ratio = .65
		tuning.wind_up_seconds = .18
		tuning.active_seconds = .07
		tuning.recovery_seconds = .13
		tuning.dash_cancelable = true
		tuning.ground_center_offset_y = 0.0
		tuning.hitbox_shape = CircleShape2D.new()
		tuning.hitbox_shape.radius = tuning.effect_radius_pixels
		tuning.description = "LAB REVIEW: Aim a ground rupture. Only the 30px center stuns; the wider 68px blast flinches and pushes. Movement returns after 0.38s."
		component.definition = tuning
		visual.effect_sprite.sprite_frames = load("res://assets/vfx/abilities/king/riftbreak_review/rupture_frames.tres")
		visual.effect_sprite.scale = Vector2.ONE * tuning.effect_radius_pixels / 105.0
		library.equip("riftbreak", 2)
	else:
		component.definition = _definition
		visual.effect_sprite.sprite_frames = _frames
		visual.effect_sprite.scale = _scale
		library._apply_slots(_slots)
	enabled = value
	return true
