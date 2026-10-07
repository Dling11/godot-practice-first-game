extends SceneTree

## Native anatomy comparison, without changing body or weapon assets.
const FRONT = preload("res://assets/characters/playable/king/dual_twinsteel/down/idle.tres")
const RUN = preload("res://assets/characters/playable/king/dual_twinsteel/down/run.tres")
const SOURCE = preload("res://assets/characters/playable/king/greatsword_cardinal/down/run.tres")
const OUT := "res://art_source/review/combat/king_dual_front_gait_2026_10_06/"
var phase := "before"
var facing := "down"
var evidence_path := OUT

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="): phase=arg.trim_prefix("--phase=")
		elif arg=="--facing=up": facing="up"
		elif arg=="--facing=side": facing="side"
		elif arg.begins_with("--output=res://art_source/review/"):
			evidence_path=arg.trim_prefix("--output=").trim_suffix("/")+"/"
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var idle: Resource = FRONT
	var run: Resource = RUN
	var source: Resource = SOURCE
	if facing=="up":
		idle=load("res://assets/characters/playable/king/dual_twinsteel/up/idle.tres")
		run=load("res://assets/characters/playable/king/dual_twinsteel/up/run.tres")
		source=load("res://assets/characters/playable/king/greatsword_cardinal/up/run.tres")
	elif facing=="side":
		idle=load("res://assets/characters/playable/king/dual_twinsteel/idle.tres")
		run=load("res://assets/characters/playable/king/dual_twinsteel/run.tres")
		source=load("res://assets/characters/playable/king/greatsword_confidence_v2/axe_run.tres")
	var view_name := "BACK" if facing=="up" else ("SIDE" if facing=="side" else "FRONT")
	root.size=Vector2i(1100,680)
	root.content_scale_size=root.size
	var bg := ColorRect.new()
	bg.color=Color("263339")
	bg.size=Vector2(root.size)
	root.add_child(bg)
	label("TWINSTEEL / "+view_name+" WALK / "+phase.to_upper(),Vector2(20,15))
	label("Current directional idle",Vector2(225,90))
	cel(idle,0,Vector2(120,120))
	label(view_name+" walking / eight actual installed body cels / 3x nearest",Vector2(20,215))
	label("Native "+view_name+" gait reference / complete original anatomy",Vector2(20,440))
	var metrics: Array[Dictionary] = []
	for key in 8:
		cel(run,key,Vector2(120+120*key,300))
		cel(source,key,Vector2(120+120*key,525))
		label(str(key+1),Vector2(110+120*key,408))
		var body: Image = run.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
		var rows: Array[Dictionary] = []
		for y in range(76,96):
			var low := 192
			var high := -1
			for x in range(70,125):
				if body.get_pixel(x,y).a>.65: low=mini(low,x); high=maxi(high,x)
			if high>=low: rows.append({"y":y,"left":low,"right":high,"center":(low+high)*.5})
		metrics.append({"key":key,"rows":rows})
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(evidence_path))
	root.get_texture().get_image().save_png(evidence_path+phase+".png")
	FileAccess.open(evidence_path+phase+"_registration.json",FileAccess.WRITE).store_string(JSON.stringify({"idle_head":var_to_str(idle.identity_regions[0]),"walk_head":var_to_str(run.identity_regions[0]),"primary":var_to_str(run.primary_hands[0]),"offhand":var_to_str(run.offhand.hands[0]),"leg_rows":metrics},"\t")+"\n")
	print("FRONT_GAIT_REVIEW ",phase)
	quit()

func label(value: String,point: Vector2) -> void:
	var text := Label.new()
	text.text=value
	text.position=point
	root.add_child(text)

func cel(clip: Resource,key: int,point: Vector2) -> void:
	var sprite := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas=clip.body_atlas
	atlas.region=Rect2(key%4*192,key/4*128,192,128)
	sprite.texture=atlas
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position=point
	sprite.scale=Vector2.ONE*3
	root.add_child(sprite)
