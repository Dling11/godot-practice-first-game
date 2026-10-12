extends "res://tests/sanctuary_test_base.gd"

## Native equipped poses; this viewer never issues attacks or writes game saves.
const PLAYER = preload("res://entities/player/player.tscn")
const ITEMS := [preload("res://data/items/equipment/king_iron_beard_axe.tres"),preload("res://data/items/equipment/king_twinsteel.tres")]
const OUT := "res://art_source/review/combat/king_down_body_polish_2026_10_11/"
const KEYS := [0,1,2,4,5,6,8,9]
var suffix := "before"

func _initialize() -> void:
	if "--after" in OS.get_cmdline_user_args(): suffix="after"
	super._initialize()

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://king_down_body_proof.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size=Vector2i(1280,1040); root.content_scale_size=root.size
	RenderingServer.set_default_clear_color(Color("243038"))
	for item in ITEMS:
		_label(item.display_name+" / DOWN / "+suffix+" / complete equipped actor",Vector2(18,12))
		var profile: Resource = item.weapon_definition.family_presentation
		var first: Resource = profile.attack_for(Vector2.DOWN)
		var clips: Array = [first]+Array(first.follow_up_clips)
		var actors: Array[Player] = []
		for step in 5:
			for column in KEYS.size():
				var actor: Player = PLAYER.instantiate()
				actor.position=Vector2(80+160*column,175+180*step)
				actor.scale=Vector2.ONE*3
				root.add_child(actor)
				actor.set_physics_process(false); actor.set_process_unhandled_input(false)
				check(actor.set_weapon_definition(item.weapon_definition),"Cannot equip native actor")
				actor._set_facing_direction(Vector2.DOWN)
				var rig: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
				rig._rest_timer.stop()
				rig.select_clip(clips[step]); rig.set_pose(KEYS[column])
				actors.append(actor)
				_label("A%d / F%d"%[step+1,KEYS[column]+1],Vector2(160*column+12,65+180*step))
		await _capture(OUT+("axe" if item==ITEMS[0] else "dual")+"_"+suffix+".png")
		for actor in actors: actor.queue_free()
		for child in root.get_children():
			if child is Label: child.queue_free()
		await process_frame
	var idle: Resource = ITEMS[0].weapon_definition.family_presentation.idle_for(Vector2.DOWN)
	root.size=Vector2i(1280,360); root.content_scale_size=root.size
	_label("AXE / DOWN STAND -> REST / "+suffix,Vector2(18,12))
	for key in 8:
		var actor: Player = PLAYER.instantiate()
		actor.position=Vector2(80+160*key,250); actor.scale=Vector2.ONE*4
		root.add_child(actor); actor.set_physics_process(false); actor.set_process_unhandled_input(false)
		actor.set_weapon_definition(ITEMS[0].weapon_definition); actor._set_facing_direction(Vector2.DOWN)
		var rig: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
		rig._rest_timer.stop(); rig.select_clip(idle); rig.set_pose(key)
		_label("F%d"%[key+1],Vector2(160*key+12,65))
	await _capture(OUT+"axe_idle_"+suffix+".png")
	if suffix=="after": await _idle_comparison(idle)
	print("KING_DOWN_NATIVE checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _idle_comparison(current: Resource) -> void:
	for child in root.get_children():
		if child is Player or child is Label: child.queue_free()
	await process_frame
	root.size=Vector2i(800,310); root.content_scale_size=root.size
	var archive := "res://art_source/archive/king_down_body_before_2026_10_11/"
	var previous: Resource = load(archive+"assets/characters/playable/king/shared_bodies/axe/down/idle.tres").duplicate(true)
	for field in ["body_atlas","hand_atlas"]:
		var source_path: String = previous.get(field).resource_path
		previous.set(field,ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(archive+source_path.trim_prefix("res://")))))
	for column in 4:
		var actor: Player = PLAYER.instantiate()
		actor.position=Vector2(100+200*column,235); actor.scale=Vector2.ONE*4
		root.add_child(actor); actor.set_physics_process(false); actor.set_process_unhandled_input(false)
		actor.set_weapon_definition(ITEMS[0].weapon_definition); actor._set_facing_direction(Vector2.DOWN)
		var rig: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
		rig._rest_timer.stop(); rig.select_clip(previous if column<2 else current); rig.set_pose(0 if column%2==0 else 4)
		_label(["Before / stand","Before / rest","Now / stand","Now / rest"][column],Vector2(18+200*column,28))
	await _capture(OUT+"axe_idle_comparison.png")

func _label(value: String,spot: Vector2) -> void:
	var label := Label.new(); label.text=value; label.position=spot; root.add_child(label)

func _capture(path: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(path)==OK,"Native capture failed: "+path)
