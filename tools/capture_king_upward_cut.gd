extends "res://tests/sanctuary_test_base.gd"

## Native production-player captures, including wind-up and queued recovery.
const ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const PLAYER = preload("res://entities/player/player.tscn")
const OUT := "res://art_source/review/combat/king_upward_centering_2026_10_05/attacks/"

func _run() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("Upward capture requires native rendering")
		quit(1)
		return
	root.size = Vector2i(800,800)
	root.content_scale_size = root.size
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("WeaponInventory").acquire_weapon(ITEM)
	var backdrop := ColorRect.new()
	backdrop.color = Color("202b30")
	backdrop.size = root.size
	root.add_child(backdrop)
	var actor: Player = PLAYER.instantiate()
	actor.position = Vector2(400,500)
	actor.scale = Vector2.ONE*4
	actor.movement_bounds = Rect2(0,0,2000,2000)
	root.add_child(actor)
	actor.set_physics_process(false)
	actor.set_process_unhandled_input(false)
	check(actor.equip_owned_weapon(ITEM),"Cannot equip greatsword")
	actor._set_facing_direction(Vector2.UP)
	actor.attack_component.phase_changed.connect(func(phase: int,_duration: float) -> void:
		if phase==MeleeAttackComponent.Phase.ACTIVE and actor.attack_component.combo_step<4:
			actor.request_primary_attack()
	)
	var family := actor.get_node("WeaponFamilyPresentation")
	var presenter: Node2D = family.presenter
	var prefix := "after" if OS.get_cmdline_user_args().has("--after") else "before"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT+prefix+"/"))
	var records: Array[Dictionary] = []
	var galleries: Array[Image] = []
	var captured := {}
	for cut in 5:
		var gallery := Image.create(1280,1280,false,Image.FORMAT_RGBA8)
		gallery.fill(backdrop.color)
		galleries.append(gallery)
	check(actor.request_primary_attack(),"Upward chain refused")
	for tick in 215:
		await physics_frame
		await RenderingServer.frame_post_draw
		var cut := actor.attack_component.combo_step
		var pose: int = presenter.pose_index
		var key := "%d_%d"%[cut,pose]
		if actor.attack_component.phase==MeleeAttackComponent.Phase.IDLE: break
		if captured.has(key): continue
		captured[key] = true
		var rendered := root.get_texture().get_image()
		var filename := "cut_%d_pose_%02d.png"%[cut,pose]
		rendered.save_png(OUT+prefix+"/"+filename)
		var tile := rendered.duplicate()
		tile.resize(320,320,Image.INTERPOLATE_NEAREST)
		galleries[cut].blit_rect(tile,Rect2i(0,0,320,320),Vector2i(pose%4*320,pose/4*320))
		records.append({"cut":cut,"pose":pose,"phase":actor.attack_component.phase,"trail_frame":family.trail._frame,"file":prefix+"/"+filename})
	for cut in 5: galleries[cut].save_png(OUT+prefix+"/cut_%d_gallery.png"%cut)
	if prefix=="after" and FileAccess.file_exists(OUT+"before/cut_0_pose_06.png") and FileAccess.file_exists(OUT+"before/cut_3_pose_06.png"):
		var comparison := Image.create(1200,1200,false,Image.FORMAT_RGBA8)
		for row in 2:
			var cut: int = [0,3][row]
			for column in 2:
				var sample := Image.load_from_file(OUT+["before/","after/"][column]+"cut_%d_pose_06.png"%cut)
				sample.resize(600,600,Image.INTERPOLATE_NEAREST)
				comparison.blit_rect(sample,Rect2i(0,0,600,600),Vector2i(column*600,row*600))
		comparison.save_png(OUT+"comparison.png")
	FileAccess.open(OUT+prefix+"/timeline.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print("UPWARD_CAPTURE ",prefix," poses ",records.size())
	quit(1 if failures else 0)
