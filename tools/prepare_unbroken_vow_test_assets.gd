extends SceneTree

const REVIEW := "res://art_source/review/characters/king/unbroken_vow_activation_2026_09_27/"
const BARRIER := "res://art_source/review/characters/king/unbroken_vow_v2_2026_09_27/"
const OUT := "res://assets/vfx/abilities/king/unbroken_vow_test/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var body := Image.load_from_file(REVIEW + "activation_body_down_4x2.png")
	assert(body.save_png(OUT + "body_down.png") == OK)
	_pack(REVIEW, "pressure_%02d.png", 8, 4, Vector2i(144, 112), "pressure.png")
	_pack(BARRIER, "frame_%02d.png", 6, 3, Vector2i(112, 112), "barrier.png")
	assert(DirAccess.copy_absolute(REVIEW + "pressure_contact.wav", OUT + "pressure_contact.wav") == OK)
	print("UNBROKEN_VOW_TEST_ASSETS: three padded atlases and contact WAV packed")
	quit()

func _pack(folder: String, pattern: String, count: int, columns: int, cell: Vector2i, name: String) -> void:
	var atlas := Image.create_empty(columns * cell.x, ceili(float(count) / columns) * cell.y, false, Image.FORMAT_RGBA8)
	for index in count:
		var frame := Image.load_from_file(folder + pattern % (index + 1))
		assert(frame.get_size() == cell)
		atlas.blit_rect(frame, Rect2i(Vector2i.ZERO, cell), Vector2i(index % columns, index / columns) * cell)
	assert(atlas.save_png(OUT + name) == OK)
