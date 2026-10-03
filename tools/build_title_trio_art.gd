extends SceneTree

func _initialize() -> void:
	for key: String in ["a", "b", "c"]:
		var image := Image.load_from_file(ProjectSettings.globalize_path("res://art_source/generated/ui/title_trio_2026_10_03/" + key + "_source.png"))
		image.resize(960, 540, Image.INTERPOLATE_NEAREST)
		assert(image.save_png("res://assets/ui/title/trio/" + key + ".png") == OK)
	print("TITLE_TRIO_ART: three 960x540 still illustrations; native controls remain separate")
	quit()
