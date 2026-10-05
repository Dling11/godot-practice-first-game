extends SceneTree

const TURN = preload("res://assets/characters/playable/king/huge_greatsword_proof/turn.tres")
const IDLE = preload("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
const OUT := "res://art_source/generated/characters/king/greatsword_low_return_2026_10_05/"
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for item in [{"name":"existing_fourth_body","clip":TURN,"key":5},{"name":"existing_carry_body","clip":IDLE,"key":0}]:
		var key: int = item.key
		var image: Image = item.clip.body_atlas.get_image().get_region(Rect2i(Vector2i(key%4,key/4)*Vector2i(192,128),Vector2i(192,128)))
		assert(image.save_png(OUT+item.name+".png")==OK)
		image.resize(768,512,Image.INTERPOLATE_NEAREST)
		assert(image.save_png(OUT+item.name+"_large.png")==OK)
	print("KING_LOW_RETURN_REFERENCE existing body pixels exported, no runtime edits")
	quit()
