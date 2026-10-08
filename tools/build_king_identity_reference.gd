extends "res://tools/build_king_axe_cardinal.gd"

## Freeze accepted rasters and anatomy once; future builds read this reference.
const REF := "res://art_source/reference/characters/king/native_identity_v1/"
const SPECS := {
	"right":{"path":"res://assets/characters/playable/king/axe_proof_v3/carry.tres","head":Rect2i(85,40,27,27)},
	"up":{"path":"res://assets/characters/playable/king/dual_v2/up/idle.tres","head":Rect2i()},
	"down":{"path":"res://assets/characters/playable/king/dual_v2/down/idle.tres","head":Rect2i()}
}

func _initialize() -> void:
	if FileAccess.file_exists(REF+"reference.json"):
		push_error("Frozen King reference already exists; do not derive it from later edits"); quit(1); return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REF))
	FileAccess.open(REF+".gdignore",FileAccess.WRITE).store_string("")
	var records := {}
	for view in SPECS:
		var source: Resource = load(SPECS[view].path)
		var body: Image = source.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		var head: Rect2i = SPECS[view].head if view=="right" else Rect2i(source.identity_regions[0])
		var shift := 94-body.get_used_rect().end.y+1
		var placed := Image.create(192,128,false,Image.FORMAT_RGBA8)
		placed.blit_rect(body,Rect2i(0,0,192,128),Vector2i(0,shift))
		head.position.y+=shift
		placed.save_png(REF+view+"_body.png")
		placed.get_region(head).save_png(REF+view+"_head.png")
		records[view]={"source":SPECS[view].path,"head":[head.position.x,head.position.y,head.size.x,head.size.y],"height":placed.get_used_rect().size.y,"foot":94,"hair":var_to_str(hair_bounds(placed,head.end.y)),"ready_primary":var_to_str(source.primary_hands[0]+Vector2(0,shift))}
		if view=="right":
			var left: Image = placed.duplicate()
			left.flip_x()
			left.save_png(REF+"left_body.png")
			var mirrored := Rect2i(192-head.end.x,head.position.y,head.size.x,head.size.y)
			left.get_region(mirrored).save_png(REF+"left_head.png")
			records.left={"source":SPECS[view].path,"head":[mirrored.position.x,mirrored.position.y,mirrored.size.x,mirrored.size.y],"height":placed.get_used_rect().size.y,"foot":94,"mirrored_from":"right"}
	var contract := {"version":1,"cell":[192,128],"runtime_scale":0.5,"foot":94,"standing_height":[54,57],"views":records,"rule":"Freeze native head pixels; calibrate torso density once per sheet. Never resize individual poses or anchor X to the lowest boot."}
	FileAccess.open(REF+"reference.json",FileAccess.WRITE).store_string(JSON.stringify(contract,"\t")+"\n")
	var board := Image.create(768,256,false,Image.FORMAT_RGBA8)
	for index in 4:
		var view: String = ["left","right","up","down"][index]
		var body := Image.load_from_file(REF+view+"_body.png")
		board.blit_rect(body,Rect2i(0,0,192,128),Vector2i(index*192,0))
		var color := Color("677d84")
		for x in range(index*192+60,index*192+135): board.set_pixel(x,94,color)
		for y in range(32,108): board.set_pixel(index*192+96,y,color)
		board.blit_rect(body,Rect2i(0,0,192,128),Vector2i(index*192,128))
	board.resize(1536,512,Image.INTERPOLATE_NEAREST)
	board.save_png(REF+"trace_board.png")
	print("KING_IDENTITY_REFERENCE frozen four views / native head pixels / sole94")
	quit()
