extends SceneTree

const OUT := "res://art_source/review/combat/king_dual_close_hilt_2026_10_05/"
const ROOT := "res://assets/characters/playable/king/"
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
var output_name := "before.png"

func _initialize() -> void:
	if "--after" in OS.get_cmdline_user_args(): output_name="after.png"
	call_deferred("render_review")

func render_review() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size=Vector2i(1280,900)
	root.content_scale_size=root.size
	var bg := ColorRect.new()
	bg.color=Color("263339")
	bg.size=Vector2(root.size)
	root.add_child(bg)
	var attack := MeleeAttackComponent.new()
	root.add_child(attack)
	var source: Resource = load(ROOT+"greatsword_confidence_v2/axe_run.tres")
	var dual: Resource = load(ROOT+"dual_twinsteel/run.tres")
	label_at(Vector2(12,8),"SOURCE / original axe gait body, 3x")
	label_at(Vector2(12,230),"TWINSTEEL / side grips closer to the guards, same 3x")
	for key in 8:
		var at := Vector2(78+key*160,100)
		body_at(source,key,at,3)
		var p := Presenter.new()
		p.configure(dual,attack,false)
		p.position=at+Vector2(0,220)
		p.scale=Vector2.ONE*3
		root.add_child(p)
		p.set_pose(key)
	label_at(Vector2(12,450),"FRONT / unchanged native upper body + two planted boots, 4x / no weapons")
	var front: Resource = load(ROOT+"greatsword_cardinal/down/run.tres")
	var idle: Resource = load(ROOT+"dual_twinsteel/down/idle.tres")
	for entry in [[front,0,"Native front 0"],[front,3,"Native front 3"],[idle,0,"Twinsteel front idle"]]:
		var index: int = [[front,0,"Native front 0"],[front,3,"Native front 3"],[idle,0,"Twinsteel front idle"]].find(entry)
		var point := Vector2(180+index*370,600)
		body_at(entry[0],entry[1],point,4)
		var image: Image = entry[0].body_atlas.get_image().get_region(Rect2i(entry[1]%4*192,entry[1]/4*128,192,128))
		label_at(Vector2(point.x-120,750),"%s: %s"%[entry[2],image.get_used_rect().size])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+output_name)==OK)
	print("DUAL_ATTACHMENT_REVIEW "+output_name)
	quit()

func body_at(clip: Resource,key: int,at: Vector2,magnification: float) -> void:
	var frame := AtlasTexture.new()
	frame.atlas=clip.body_atlas
	frame.region=Rect2(key%4*192,key/4*128,192,128)
	var sprite := Sprite2D.new()
	sprite.texture=frame
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position=at
	sprite.scale=Vector2.ONE*magnification
	root.add_child(sprite)

func label_at(at: Vector2,value: String) -> void:
	var label := Label.new()
	label.position=at
	label.text=value
	label.add_theme_font_size_override("font_size",15)
	root.add_child(label)
