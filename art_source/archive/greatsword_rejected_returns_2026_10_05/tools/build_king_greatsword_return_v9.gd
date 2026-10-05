extends SceneTree

## Registration only: copy accepted cells verbatim; never repaint or rescale King.
const DEST := "res://assets/characters/playable/king/greatsword_return_v9/"
const PROVENANCE := "res://art_source/registration/characters/king/greatsword_return_v9_2026_10_04/"
const TURN = preload("res://assets/characters/playable/king/huge_greatsword_proof/turn.tres")
const RISE = preload("res://assets/characters/playable/king/huge_greatsword_proof/rise.tres")
const IDLE = preload("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
const Definition = preload("res://data/weapons/weapon_family_pose_definition.gd")
const KEYS := [7,6,5,4,3,3,5,0]

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PROVENANCE))
	var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var masks := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var clip := Definition.new()
	clip.weapon_texture = TURN.weapon_texture
	clip.weapon_primary_grip = TURN.weapon_primary_grip
	clip.weapon_tip = Vector2(15,0)
	clip.mirror_cutting_edge = false
	clip.phase_windows = PackedVector2Array([Vector2(0,1),Vector2(2,4),Vector2(5,7)])
	var records: Array[Dictionary] = []
	for index in 8:
		var accepted: Resource = TURN if index<5 else RISE if index<7 else IDLE
		var key: int = KEYS[index]
		var cell := Rect2i(Vector2i(key%4,key/4)*Vector2i(192,128),Vector2i(192,128))
		var body: Image = accepted.body_atlas.get_image().get_region(cell)
		var hand: Image = accepted.hand_atlas.get_image().get_region(cell)
		var primary: Vector2 = accepted.primary_hands[key]
		var secondary: Vector2 = accepted.secondary_hands[key]
		clip.single_hand_poses[index] = accepted.single_hand_poses[key]
		clip.weapon_behind_body[index] = accepted.weapon_behind_body[key]
		if index in [5,6]:
			# Upper glove carries the follow-through one-handed toward the shoulder.
			# The other hand remains visible in the original body; it is not a grip.
			secondary = primary+(Vector2(-7,4) if index==5 else Vector2(2,8))
			clip.single_hand_poses[index] = 1
			hand = Image.create(192,128,false,Image.FORMAT_RGBA8)
			var glove := Rect2i(Vector2i(primary)-Vector2i(3,3),Vector2i(7,7))
			hand.blit_rect(body,glove,glove.position)
		clip.primary_hands.append(primary)
		clip.secondary_hands.append(secondary)
		var destination := Vector2i(index%4,index/4)*Vector2i(192,128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),destination)
		masks.blit_rect(hand,Rect2i(0,0,192,128),destination)
		records.append({"pose":index,"accepted_clip":accepted.resource_path,"accepted_body":accepted.body_atlas.resource_path,"accepted_cell":key,"verbatim_body_pixels":true,"primary":[primary.x,primary.y],"secondary":[secondary.x,secondary.y],"single_hand":clip.single_hand_poses[index]>0})
	assert(atlas.save_png(DEST+"return_body.png")==OK)
	assert(masks.save_png(DEST+"return_hands.png")==OK)
	clip.body_atlas = ImageTexture.create_from_image(atlas)
	clip.hand_atlas = ImageTexture.create_from_image(masks)
	assert(clip.has_valid_layout())
	var text := "[gd_resource type=\"Resource\" load_steps=5 format=3]\n\n[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_family_pose_definition.gd\" id=\"1\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+DEST+"return_body.png\" id=\"2\"]\n[ext_resource type=\"Texture2D\" path=\""+DEST+"return_hands.png\" id=\"3\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+TURN.weapon_texture.resource_path+"\" id=\"4\"]\n\n[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	text += "primary_hands = "+_points(clip.primary_hands)+"\nsecondary_hands = "+_points(clip.secondary_hands)+"\nweapon_primary_grip = Vector2(15,113)\nweapon_handle_axis = Vector2(0,1)\nweapon_tip = Vector2(15,0)\nmirror_cutting_edge = false\nphase_windows = PackedVector2Array(0,1,2,4,5,7)\nsingle_hand_poses = PackedByteArray(0,0,0,0,0,1,1,1)\n"
	FileAccess.open(DEST+"return.tres",FileAccess.WRITE).store_string(text)
	FileAccess.open(PROVENANCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print("GREATSWORD_RETURN_V9 eight verbatim accepted King cells / original palette / no generated body dependency")
	quit()

func _points(points: PackedVector2Array) -> String:
	var values := PackedStringArray()
	for point in points:
		values.append(str(point.x))
		values.append(str(point.y))
	return "PackedVector2Array("+", ".join(values)+")"
