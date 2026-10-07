extends "res://tests/sanctuary_test_base.gd"

## Native production trails retain the same raster density in every facing.
const ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const PLAYER = preload("res://entities/player/player.tscn")
const OUT := "res://art_source/review/combat/king_back_attachment_2026_10_05/"

func _run() -> void:
	if DisplayServer.get_name()=="headless": quit(1); return
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("WeaponInventory").acquire_weapon(ITEM)
	var actors: Array[Player] = []
	var views: Array[SubViewport] = []
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		var view := SubViewport.new()
		view.size = Vector2i(1024,1024)
		view.transparent_bg = true
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var actor: Player = PLAYER.instantiate()
		actor.position = Vector2(512,576)
		actor.scale = Vector2.ONE*4
		actor.movement_bounds = Rect2(0,0,4000,4000)
		view.add_child(actor)
		actor.set_physics_process(false)
		actor.set_process_unhandled_input(false)
		check(actor.equip_owned_weapon(ITEM),"Cannot equip directional style player")
		actor._set_facing_direction(direction)
		actors.append(actor)
		views.append(view)
	var reports: Array[Dictionary] = []
	for cut in [0,1,3,4]:
		for actor in actors:
			actor.attack_component._next_combo_step = cut
			check(actor.request_primary_attack(),"Directional style strike refused")
		while actors[0].attack_component.phase!=MeleeAttackComponent.Phase.ACTIVE: await physics_frame
		paused = true
		for actor in actors:
			var trail = actor.get_node("WeaponFamilyPresentation").trail
			for child in actor.get_children():
				if child is CanvasItem and child!=trail: child.hide()
			trail._tween.kill()
		for frame in 4:
			for actor in actors: actor.get_node("WeaponFamilyPresentation").trail._set_frame(frame)
			await RenderingServer.frame_post_draw
			var coverage := PackedInt32Array()
			for view in views:
				var image := view.get_texture().get_image()
				var bounds := image.get_used_rect()
				var count := 0
				for y in range(bounds.position.y,bounds.end.y):
					for x in range(bounds.position.x,bounds.end.x):
						if image.get_pixel(x,y).a>.7: count += 1
				coverage.append(count)
			check(coverage[0]>100,"Ordinary reference slash disappeared")
			for direction in range(1,4):
				check(absf(coverage[direction]-coverage[0])<=coverage[0]*.02,"Facing changes slash density/size: %d/%d direction%d %s"%[cut,frame,direction,str(coverage)])
			reports.append({"cut":cut,"frame":frame,"opaque_pixels_right_left_up_down":Array(coverage)})
		paused = false
		for actor in actors: actor.attack_component.cancel_attack()
	for view in views: view.queue_free()
	await process_frame
	FileAccess.open(OUT+"slash_style_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"native":true,"frames":reports},"\t")+"\n")
	print("DIRECTIONAL_SLASH_STYLE checks=",checks," failures=",failures)
	quit(1 if failures else 0)
