class_name RiftbreakComponent
extends AbilityComponent

## Converts one ordinary ability window into a self-centered radial contact.
## MeleeHitbox still owns per-target deduplication and accepted damage delivery.


func _start_current_strike() -> void:
	var riftbreak_definition := definition as RiftbreakDefinition
	if riftbreak_definition == null:
		super._start_current_strike()
		return
	_current_strike_index = 0
	_strike_time_remaining = definition.active_seconds
	hitbox.position = Vector2(0.0, riftbreak_definition.ground_center_offset_y)
	hitbox.activate_radial(
		definition.resolve_strike_damage(_equipped_weapon_damage, 0),
		owner,
		hitbox.global_position,
		definition.resolve_strike_knockback(0),
		definition.resolve_strike_stagger(0)
	)
	strike_started.emit(0, 1, definition.active_seconds)


func cancel_cast() -> void:
	_reset_hitbox_position()
	super.cancel_cast()


func _advance_phase() -> void:
	var was_active := phase == Phase.ACTIVE
	super._advance_phase()
	if was_active:
		_reset_hitbox_position()


func _reset_hitbox_position() -> void:
	if hitbox != null:
		hitbox.position = Vector2.ZERO
