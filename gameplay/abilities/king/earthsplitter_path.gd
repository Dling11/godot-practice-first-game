extends RefCounted

## Shared preview/commit geometry. Pointer distance never shortens the lane.
static func resolve(actor: Player, point: Vector2, tuning: AbilityDefinition, start := Vector2.INF, reach := -1.0, contact_offset := -1.0) -> Dictionary:
	var origin := actor.global_position if start == Vector2.INF else start
	var direction := point - origin
	if direction.length_squared() < .01:
		direction = actor.facing_direction
	direction = direction.normalized()
	var distance: float = tuning.range_pixels if reach < 0.0 else reach
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = tuning.lane_radius
	query.shape = shape
	query.transform = Transform2D(0.0, origin)
	query.collision_mask = 1
	query.exclude = [actor.get_rid()]
	var space := actor.get_world_2d().direct_space_state
	var blocked := false
	if not space.intersect_shape(query, 1).is_empty():
		distance = 0.0
		blocked = true
	else:
		query.motion = direction * distance
		var sweep := space.cast_motion(query)
		if sweep[0] < 1.0:
			distance = maxf(0.0, distance * sweep[0] - .5)
			blocked = true
	return {
		"origin": origin,
		"direction": direction,
		"contact": origin + direction * minf(tuning.contact_offset if contact_offset < 0.0 else contact_offset, distance),
		"end": origin + direction * distance,
		"radius": tuning.lane_radius,
		"blocked": blocked,
	}

