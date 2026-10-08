extends "res://tools/build_king_axe_cardinal.gd"

## Offline/native inspection: never mutates production art or profile data.
const OUT := "res://art_source/review/combat/king_axe_identity_lock_2026_10_07/"
const SPECS := [
	["side ready","res://assets/characters/playable/king/axe_proof_v3/carry.tres",0],
	["side strike","res://assets/characters/playable/king/axe_flow/side/chop.tres",5],
	["axe DOWN ready","res://assets/characters/playable/king/axe_flow/down/idle.tres",0],
	["axe DOWN strike","res://assets/characters/playable/king/axe_vertical_v2/down/chop.tres",5],
	["axe UP ready","res://assets/characters/playable/king/axe_flow/up/idle.tres",0],
	["axe UP strike","res://assets/characters/playable/king/axe_vertical_v2/up/chop.tres",5],
	["dual DOWN ready","res://assets/characters/playable/king/dual_v2/down/idle.tres",0],
	["great DOWN ready","res://assets/characters/playable/king/greatsword_v2_cardinal_carry/down/idle.tres",0]
]
var records: Array[Dictionary] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size=Vector2i(1360,650)
	root.content_scale_size=root.size
	RenderingServer.set_default_clear_color(Color("243037"))
	for index in SPECS.size():
		var spec: Array = SPECS[index]
		var clip: Resource = load(spec[1])
		var cel: Image = clip.body_atlas.get_image().get_region(Rect2i(int(spec[2])%4*192,int(spec[2])/4*128,192,128))
		var head := hair_bounds(cel,red_center_y(cel)-2)
		var stored: Rect2 = clip.identity_regions[spec[2]] if not clip.identity_regions.is_empty() else Rect2(87,41,25,24)
		var stored_pixels := cel.get_region(Rect2i(stored)).get_used_rect()
		var label := Label.new()
		label.position=Vector2(15+index%4*335,10+index/4*315)
		label.text=spec[0]+"\nhair "+str(head.size)+" / visible head "+str(stored_pixels.size)
		root.add_child(label)
		var sprite := Sprite2D.new()
		sprite.texture=ImageTexture.create_from_image(cel)
		sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.scale=Vector2.ONE*4
		sprite.position=Vector2(165+index%4*335,185+index/4*315)
		root.add_child(sprite)
		records.append({"name":spec[0],"body":var_to_str(cel.get_used_rect()),"hair":var_to_str(head),"head_region":var_to_str(stored),"visible_head":var_to_str(stored_pixels)})
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"identity_before.png")
	FileAccess.open(OUT+"identity_before.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print(JSON.stringify(records))
	quit()
