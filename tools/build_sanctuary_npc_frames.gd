extends SceneTree

## Current service poses, shared by standalone NPC scenes and the town.
func _initialize() -> void:
	for recipe in [
		["armskeeper", "idle_work_v2.png", "idle_down", 5.0],
		["skillkeeper", "idle_read.png", "idle_down", 4.0],
		["rootweaver", "idle_work.png", "artisan_work", 5.0],
		["umi", "idle_work.png", "artisan_work", 5.0],
	]:
		var folder := "res://assets/characters/npcs/%s/renewal/" % recipe[0]
		var frames := SpriteFrames.new()
		frames.remove_animation(&"default")
		var animation := StringName(recipe[2])
		frames.add_animation(animation)
		frames.set_animation_speed(animation, recipe[3])
		for index in 8:
			var texture := AtlasTexture.new()
			texture.atlas = load(folder + recipe[1])
			texture.region = Rect2(Vector2(index % 4, index / 4) * 96, Vector2(96, 96))
			texture.filter_clip = true
			var duration := 2.0 if index == 0 or index == 7 else 1.0
			if animation == &"artisan_work":
				duration = 5.0 if index == 0 else (3.0 if index == 7 else 1.0)
			frames.add_frame(animation, texture, duration)
		assert(ResourceSaver.save(frames, folder + "sprite_frames.tres") == OK)
	print("Current Sanctuary NPC frames built.")
	quit()
