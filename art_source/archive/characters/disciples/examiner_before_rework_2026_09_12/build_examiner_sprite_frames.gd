extends SceneTree

const OUTPUT_PATH := "res://assets/characters/enemies/examiner/examiner_sprite_frames.tres"

const LOCOMOTION_TEXTURE := preload("res://assets/characters/enemies/examiner/examiner_locomotion_sheet_192x128.png")
const THRUST_TEXTURE := preload("res://assets/characters/enemies/examiner/examiner_thrust_sheet_192x128.png")
const SWEEP_TEXTURE := preload("res://assets/characters/enemies/examiner/examiner_sweep_sheet_192x128.png")
const JUDGMENT_CHARGE_TEXTURE := preload("res://assets/characters/enemies/examiner/examiner_judgment_charge_sheet_192x128.png")
const GROUND_JUDGMENT_TEXTURE := preload("res://assets/characters/enemies/examiner/examiner_ground_judgment_sheet_192x128.png")
const AXIOM_TEXTURE := preload("res://assets/characters/enemies/examiner/examiner_axiom_divide_sheet_192x128.png")
const REFUTATION_TEXTURE := preload("res://assets/characters/enemies/examiner/examiner_refutation_sheet_192x128.png")
const REACTION_TEXTURE := preload("res://assets/characters/enemies/examiner/examiner_reaction_withdraw_sheet_192x128.png")
const DESCENT_LAUNCH_TEXTURE := preload("res://assets/characters/enemies/examiner/examiner_divine_descent_launch_sheet_192x128.png")
const DESCENT_LAND_TEXTURE := preload("res://assets/characters/enemies/examiner/examiner_divine_descent_land_sheet_192x128.png")

const CELL_SIZE := Vector2i(192, 128)
const ACTION_DIRECTIONS := [&"down", &"right", &"left", &"up"]
# The approved locomotion board was authored down/left/right/up. The later
# action boards were authored down/right/left/up, so locomotion needs its own
# explicit row mapping instead of sharing an assumption with combat frames.
const LOCOMOTION_ROWS := [0, 2, 1, 3]


func _initialize() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for action_row in range(ACTION_DIRECTIONS.size()):
		var direction := String(ACTION_DIRECTIONS[action_row])
		var locomotion_row: int = LOCOMOTION_ROWS[action_row]
		_add_range(frames, "idle_" + direction, LOCOMOTION_TEXTURE, 6, locomotion_row, 0, 2, 3.0, true)
		_add_range(frames, "walk_" + direction, LOCOMOTION_TEXTURE, 6, locomotion_row, 2, 6, 7.0, true)
		_add_range(frames, "thrust_" + direction, THRUST_TEXTURE, 6, action_row, 0, 5, 9.0, false)
		_add_range(frames, "thrust_recovery_" + direction, THRUST_TEXTURE, 6, action_row, 4, 6, 8.0, false)
		_add_range(frames, "sweep_wind_up_" + direction, SWEEP_TEXTURE, 6, action_row, 0, 4, 8.0, false)
		_add_range(frames, "sweep_strike_" + direction, SWEEP_TEXTURE, 6, action_row, 3, 6, 11.0, false)
		_add_reverse_range(frames, "sweep_recovery_" + direction, SWEEP_TEXTURE, 6, action_row, 4, 6, 7.0)
		_add_range(frames, "charge_wind_up_" + direction, JUDGMENT_CHARGE_TEXTURE, 6, action_row, 0, 4, 7.0, false)
		_add_range(frames, "charge_travel_" + direction, JUDGMENT_CHARGE_TEXTURE, 6, action_row, 3, 6, 14.0, false)
		_add_range(frames, "charge_recovery_" + direction, JUDGMENT_CHARGE_TEXTURE, 6, action_row, 5, 6, 5.0, false)
		_add_range(frames, "slam_wind_up_" + direction, GROUND_JUDGMENT_TEXTURE, 6, action_row, 0, 4, 6.0, false)
		_add_range(frames, "slam_contact_" + direction, GROUND_JUDGMENT_TEXTURE, 6, action_row, 4, 5, 1.0, false)
		_add_range(frames, "slam_recovery_" + direction, GROUND_JUDGMENT_TEXTURE, 6, action_row, 4, 6, 5.0, false)
		_add_range(frames, "refutation_wind_up_" + direction, REFUTATION_TEXTURE, 5, action_row, 0, 2, 7.0, false)
		_add_range(frames, "refutation_active_" + direction, REFUTATION_TEXTURE, 5, action_row, 1, 4, 10.0, false)
		_add_range(frames, "refutation_recovery_" + direction, REFUTATION_TEXTURE, 5, action_row, 3, 5, 7.0, false)
		_add_range(frames, "hurt_" + direction, REACTION_TEXTURE, 6, action_row, 0, 3, 12.0, false)
		_add_range(frames, "withdrawal_" + direction, REACTION_TEXTURE, 6, action_row, 3, 6, 4.5, false)
		_add_range(frames, "axiom_wind_up_" + direction, AXIOM_TEXTURE, 6, action_row, 0, 2, 7.0, false)
		_add_range(frames, "axiom_cut_one_" + direction, AXIOM_TEXTURE, 6, action_row, 2, 4, 8.0, false)
		_add_range(frames, "axiom_cut_two_" + direction, AXIOM_TEXTURE, 6, action_row, 4, 6, 8.0, false)
		_add_range(frames, "axiom_dash_" + direction, JUDGMENT_CHARGE_TEXTURE, 6, action_row, 2, 6, 13.0, false)
		_add_range(frames, "axiom_recovery_" + direction, AXIOM_TEXTURE, 6, action_row, 5, 6, 5.0, false)
		_add_range(frames, "descent_prepare_" + direction, DESCENT_LAUNCH_TEXTURE, 6, action_row, 0, 3, 8.0, false)
		_add_range(frames, "descent_launch_" + direction, DESCENT_LAUNCH_TEXTURE, 6, action_row, 3, 6, 12.0, false)
		_add_range(frames, "descent_fall_" + direction, DESCENT_LAND_TEXTURE, 6, action_row, 0, 2, 15.0, false)
		_add_range(frames, "descent_impact_" + direction, DESCENT_LAND_TEXTURE, 6, action_row, 2, 4, 7.0, false)
		_add_range(frames, "descent_recovery_" + direction, DESCENT_LAND_TEXTURE, 6, action_row, 3, 6, 6.0, false)

	var error := ResourceSaver.save(frames, OUTPUT_PATH)
	if error != OK:
		push_error("Could not save Examiner SpriteFrames: %s" % error_string(error))
		quit(1)
		return
	print("Saved %d Examiner animations to %s" % [frames.get_animation_names().size(), OUTPUT_PATH])
	quit()


func _add_range(
	frames: SpriteFrames,
	animation_name: String,
	texture: Texture2D,
	columns: int,
	row: int,
	start: int,
	end: int,
	speed: float,
	loop: bool
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, speed)
	frames.set_animation_loop(animation_name, loop)
	for column in range(start, mini(end, columns)):
		frames.add_frame(animation_name, _atlas_frame(texture, column, row))


func _add_reverse_range(
	frames: SpriteFrames,
	animation_name: String,
	texture: Texture2D,
	columns: int,
	row: int,
	start: int,
	end: int,
	speed: float
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, speed)
	frames.set_animation_loop(animation_name, false)
	for column in range(mini(end, columns) - 1, start - 1, -1):
		frames.add_frame(animation_name, _atlas_frame(texture, column, row))


func _atlas_frame(texture: Texture2D, column: int, row: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(Vector2i(column, row) * CELL_SIZE, CELL_SIZE)
	return atlas
