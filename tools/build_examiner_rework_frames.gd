extends SceneTree

const OUTPUT := "res://assets/characters/enemies/examiner/examiner_sprite_frames.tres"
const CELL := Vector2(192, 160)
const DIRECTIONS := ["down", "right", "left", "up"]
# Half-open source spans. Contact frames never occur in a wind-up clip.
const CLIPS := {
	"idle": ["locomotion", 0, 2, 3.0, true],
	"walk": ["walk", 0, 4, 7.0, true],
	"thrust": ["thrust", 0, 3, 8.0, false],
	"thrust_strike": ["thrust", 3, 5, 16.0, false],
	"thrust_recovery": ["thrust", 5, 8, 8.0, false],
	"sweep_wind_up": ["sweep", 0, 3, 7.0, false],
	"sweep_strike": ["sweep", 3, 6, 14.0, false],
	"sweep_recovery": ["sweep", 6, 8, 6.0, false],
	"charge_wind_up": ["judgment_charge", 0, 3, 6.0, false],
	"charge_travel": ["judgment_charge", 3, 5, 14.0, false],
	"charge_recovery": ["judgment_charge", 5, 8, 8.0, false],
	"slam_wind_up": ["ground_judgment", 0, 3, 5.0, false],
	"slam_contact": ["ground_judgment", 3, 5, 14.0, false],
	"slam_recovery": ["ground_judgment", 5, 8, 6.0, false],
	"refutation_wind_up": ["refutation", 0, 3, 8.0, false],
	"refutation_active": ["refutation", 3, 5, 12.0, false],
	"refutation_recovery": ["refutation", 5, 8, 7.0, false],
	"hurt": ["reaction_withdraw", 0, 3, 12.0, false],
	"withdrawal": ["reaction_withdraw", 3, 8, 5.0, false],
	"axiom_wind_up": ["axiom_divide", 0, 2, 6.0, false],
	"axiom_cut_one": ["axiom_divide", 2, 4, 9.0, false],
	"axiom_cut_two": ["axiom_divide", 4, 6, 9.0, false],
	"axiom_dash": ["judgment_charge", 3, 5, 14.0, false],
	"axiom_recovery": ["axiom_divide", 6, 8, 6.0, false],
	"descent_prepare": ["divine_descent_launch", 0, 3, 6.0, false],
	"descent_launch": ["divine_descent_launch", 3, 8, 24.0, false],
	"descent_fall": ["divine_descent_land", 0, 2, 14.0, false],
	"descent_impact": ["divine_descent_land", 2, 4, 8.0, false],
	"descent_recovery": ["divine_descent_land", 4, 8, 6.0, false],
}


func _initialize() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for row in DIRECTIONS.size():
		for prefix: String in CLIPS:
			var spec: Array = CLIPS[prefix]
			var texture := load("res://assets/characters/enemies/examiner/examiner_%s_sheet_192x160.png" % spec[0]) as Texture2D
			if texture == null:
				quit(1)
				return
			var key := StringName(prefix + "_" + DIRECTIONS[row])
			frames.add_animation(key)
			frames.set_animation_speed(key, spec[3])
			frames.set_animation_loop(key, spec[4])
			for column in range(spec[1], spec[2]):
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(Vector2(column, row) * CELL, CELL)
				frames.add_frame(key, atlas)
	var result := ResourceSaver.save(frames, OUTPUT)
	print("Examiner rework: %d named clips, 336 source cells including dedicated gait; save=%s" % [frames.get_animation_names().size(), error_string(result)])
	quit(0 if result == OK else 1)
