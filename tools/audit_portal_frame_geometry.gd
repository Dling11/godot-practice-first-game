extends SceneTree

const OUTPUT := "res://art_source/review/ui/portal_stability_2026_10_03/"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var report: Dictionary = {}
	for key: String in ["calm","ominous","grasp","maw","divine","unknowable"]:
		var sheet := Image.load_from_file(ProjectSettings.globalize_path("res://assets/environment/portals/threat_family/"+key+".png"))
		var first := sheet.get_region(Rect2i(0,0,192,160))
		var frames: Array[Dictionary] = []
		for index in 8:
			var frame := sheet.get_region(Rect2i(index*192,0,192,160))
			var count := 0
			var weighted := Vector2.ZERO
			var changed_alpha := 0
			for y in 160:
				for x in 192:
					if frame.get_pixel(x,y).a != first.get_pixel(x,y).a: changed_alpha += 1
					if frame.get_pixel(x,y).a > .9 and x >= 50 and x < 145 and y >= 35 and y < 140:
						count += 1
						weighted += Vector2(x,y)
			frames.append({"frame":index,"used":str(frame.get_used_rect()),"solid_center":str(weighted/maxi(count,1)),"alpha_pixels_changed":changed_alpha})
		report[key] = frames
		print(key, ": ", JSON.stringify(frames))
	FileAccess.open(OUTPUT+"source_geometry.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	quit()
