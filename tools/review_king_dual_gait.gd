extends "res://tests/sanctuary_test_base.gd"

## Native equipped walking cels and the immutable anatomy used to author grips.
const PLAYER = preload("res://entities/player/player.tscn")
const ITEM = preload("res://data/items/equipment/king_twinsteel.tres")
const LIB := "res://assets/characters/playable/king/body_library/v1/"
const BEFORE := "res://art_source/archive/king_dual_gait_before_2026_10_12/assets/characters/playable/king/shared_bodies/dual/"
const OUT := "res://art_source/review/combat/king_dual_gait_2026_10_12/"
const DIRECTIONS := [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]
const NAMES := ["left","right","up","down"]
var label := "before"

func _run() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--label="): label=argument.trim_prefix("--label=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	FileAccess.open(OUT+".gdignore",FileAccess.WRITE).store_string("")
	root.get_node("SaveService").configure_storage_path_for_testing("user://king_dual_gait_review.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	root.size=Vector2i(1792,900); root.content_scale_size=root.size
	RenderingServer.set_default_clear_color(Color("243038"))
	_title("TWINSTEEL / "+label.to_upper()+" / ACTUAL EQUIPPED WALKING FRAMES",Vector2(20,10))
	var actors: Array[Player] = []
	for row in 4:
		for key in 8:
			var actor: Player = PLAYER.instantiate()
			actor.position=Vector2(112+224*key,155+215*row)
			actor.scale=Vector2.ONE*3
			root.add_child(actor)
			actor.apply_debug_testing_preset()
			actor.set_physics_process(false); actor.set_process_unhandled_input(false)
			check(actor.equip_owned_weapon(ITEM),"Cannot equip Twinsteel")
			actor._set_facing_direction(DIRECTIONS[row])
			var family := actor.get_node("WeaponFamilyPresentation")
			family.presenter._rest_timer.stop()
			var gait: Resource=ITEM.weapon_definition.family_presentation.run_for(DIRECTIONS[row])
			if label.begins_with("before"):
				# These pre-correction dependencies are hash-protected by the
				# gait test; archived selectors themselves point at live paths.
				gait=load(BEFORE+("side" if row<2 else NAMES[row])+"/run.tres")
			family.presenter.select_clip(gait)
			family.presenter.set_pose(key)
			actors.append(actor)
			_title(NAMES[row].to_upper()+" / "+str(key+1),Vector2(12+224*key,58+215*row))
	await _capture(OUT+label+".png")
	for actor in actors: actor.queue_free()
	await process_frame
	_clear_labels()
	root.size=Vector2i(1536,590); root.content_scale_size=root.size
	for view in ["side","up","down"]:
		var clip: Resource = load(LIB+view+"_run.tres")
		_title("FROZEN COMPLETE GAIT / "+view.to_upper()+" / SOURCE PIXELS x 3",Vector2(20,8))
		for key in 8:
			var frame := AtlasTexture.new()
			frame.atlas=clip.body_atlas; frame.region=Rect2(key%4*192,key/4*128,192,128); frame.filter_clip=true
			var sprite := Sprite2D.new(); sprite.texture=frame
			sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST; sprite.scale=Vector2.ONE*3
			sprite.position=Vector2(192+384*(key%4),145+270*(key/4))
			root.add_child(sprite)
			_title("KEY "+str(key)+" / original whole body",Vector2(20+384*(key%4),50+270*(key/4)))
		await _capture(OUT+"source_"+view+".png")
		for child in root.get_children():
			if child is Sprite2D: child.queue_free()
		_clear_labels()
		await process_frame
	print("KING_DUAL_GAIT_REVIEW checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _title(value: String,spot: Vector2) -> void:
	var title := Label.new(); title.text=value; title.position=spot; root.add_child(title)

func _clear_labels() -> void:
	for child in root.get_children():
		if child is Label: child.queue_free()

func _capture(path: String) -> void:
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(path)==OK,"Capture failed: "+path)
