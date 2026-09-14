extends AbilityDefinition

## Foundation values; presentation reads these same distances and timings.
@export var range_pixels := 164.0
@export var lane_radius := 17.0
@export var contact_offset := 34.0
@export var travel_seconds := .25
@export var segment_spacing := 18.0
@export var advanced_form := false

func configure_form(advanced: bool) -> void:
	advanced_form = advanced
	range_pixels = 228.0 if advanced else 164.0
	lane_radius = 21.0 if advanced else 17.0
	weapon_damage_multiplier = 2.25 if advanced else 1.65
	display_name = "Cascading Rupture (Advanced Review)" if advanced else "Earthsplitter (Foundation Review)"
	hud_name = "CASCADE" if advanced else "EARTHSPLIT"
	hitbox_shape = CircleShape2D.new()
	hitbox_shape.radius = lane_radius
	description = "One quick smash releases three waves: 164 / 196 / 228 reach. The third hits hardest. No stun; control returns after 0.36s." if advanced else "Aim a quick summoned sword smash. Each enemy is hit once. No stun; control returns after 0.36s."

func build_waves() -> Array[Dictionary]:
	if not advanced_form:
		return [{"tuning": duplicate(true), "delay": 0.0, "strength": 1.0, "aftermath_speed": 1.0}]
	var result: Array[Dictionary] = []
	for index in 3:
		var wave: AbilityDefinition = duplicate(true)
		wave.range_pixels = [164.0,196.0,228.0][index]
		wave.lane_radius = [17.0,19.0,21.0][index]
		# Shares sum to one: overlapping waves never multiply the cast budget.
		wave.weapon_damage_multiplier = weapon_damage_multiplier * [.20,.25,.55][index]
		wave.knockback_strength = [12.0,18.0,55.0][index]
		wave.stagger_seconds = [.035,.045,.10][index]
		result.append({"tuning": wave, "delay": index*.16, "strength": [.85,1.0,1.12][index], "aftermath_speed": 1.35 if index<2 else 1.0})
	return result
