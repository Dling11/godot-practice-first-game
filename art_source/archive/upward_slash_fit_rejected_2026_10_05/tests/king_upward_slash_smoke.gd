extends "res://tests/sanctuary_test_base.gd"

## Real Player + native readbacks against the complete, unclipped source cel.
const ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const PLAYER = preload("res://entities/player/player.tscn")
const OUT := "res://art_source/review/combat/king_upward_cut_2026_10_05/"

func _run() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("Full-raster comparison requires native rendering")
		quit(1)
		return
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("WeaponInventory").acquire_weapon(ITEM)
	var actual_view := _viewport()
	var reference_view := _viewport()
	var actor: Player = PLAYER.instantiate()
	actor.position = Vector2(400,500)
	actor.scale = Vector2.ONE*4
	actor.movement_bounds = Rect2(0,0,2000,2000)
	actual_view.add_child(actor)
	actor.set_physics_process(false)
	actor.set_process_unhandled_input(false)
	check(actor.equip_owned_weapon(ITEM),"Cannot equip real Player")
	actor._set_facing_direction(Vector2.UP)
	var family := actor.get_node("WeaponFamilyPresentation")
	var profile: Resource = ITEM.weapon_definition.family_presentation
	check(profile.is_valid_profile(),"Upward registration profile invalid")
	var art: Image = profile.swing_atlas.get_image()
	var reference := Sprite2D.new()
	reference.centered = false
	reference.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	reference.modulate.a = .85*.92
	reference_view.add_child(reference)
	var reports: Array[Dictionary] = []
	for cut in [0,1,3,4]:
		actor.attack_component._next_combo_step = cut
		check(actor.request_primary_attack(),"Upward strike refused")
		while actor.attack_component.phase!=MeleeAttackComponent.Phase.ACTIVE: await physics_frame
		paused = true
		for child in actor.get_children():
			if child is CanvasItem and child!=family.trail: child.hide()
		if family.trail._tween!=null: family.trail._tween.kill()
		var row := mini(cut,3)
		var mapping: Transform2D = profile.upward_swing_samples[row]
		var from_source := mapping.affine_inverse()
		var polygon: PackedVector2Array = ITEM.weapon_definition.combo.hitbox_shapes[cut].points
		var opaque := 0
		var cropped := 0
		var minimum_margin := INF
		for frame in 4:
			for y in 256:
				for x in 256:
					if art.get_pixel(frame*256+x,row*256+y).a<.5: continue
					opaque += 1
					var point: Vector2 = from_source*Vector2(x+.5,y+.5)
					if not Geometry2D.is_point_in_polygon(point,polygon): cropped += 1
					for edge in polygon.size():
						var normal := Vector2((polygon[(edge+1)%polygon.size()]-polygon[edge]).y,-(polygon[(edge+1)%polygon.size()]-polygon[edge]).x).normalized()
						minimum_margin = minf(minimum_margin,normal.dot(polygon[edge]-point))
		check(opaque>1000 and cropped==0,"Complete upward raster extends past damage shape: "+str(cut))
		check(minimum_margin>=3.99,"Upward raster still intersects the contact feather: "+str(cut))
		for frame in 4:
			family.trail._set_frame(frame)
			var cel := AtlasTexture.new()
			cel.atlas = profile.swing_atlas
			cel.region = Rect2(frame*256,row*256,256,256)
			reference.texture = cel
			reference.transform = actor.transform*Transform2D(-PI/2,Vector2(0,-16))*from_source
			await RenderingServer.frame_post_draw
			var expected := reference_view.get_texture().get_image()
			var rendered := actual_view.get_texture().get_image()
			var samples := 0
			var lost := 0
			var difference := rendered.duplicate()
			for y in 800:
				for x in 800:
					if expected.get_pixel(x,y).a<.7: continue
					samples += 1
					if rendered.get_pixel(x,y).a<.7:
						lost += 1
						difference.set_pixel(x,y,Color.RED)
			if lost>2:
				difference.save_png(OUT+"slash_difference_%d_%d.png"%[cut,frame])
				expected.save_png(OUT+"slash_reference_%d_%d.png"%[cut,frame])
			check(samples>100,"Complete slash reference has too few pixels")
			check(lost<=maxi(2,roundi(samples*.002)),"Native contact clips upward cel %d/%d: %d of %d"%[cut,frame,lost,samples])
			reports.append({"cut":cut,"frame":frame,"reference_pixels":samples,"lost_pixels":lost,"source_texels":opaque,"minimum_contact_margin":minimum_margin})
		paused = false
		actor.attack_component.cancel_attack()
	# Slam must retain its individual blade-registered frames, rather than
	# consuming the ordinary whole-row fit. Verify through the real adapter.
	actor.attack_component._next_combo_step = 2
	check(actor.request_primary_attack(),"Slam refused")
	while actor.attack_component.phase!=MeleeAttackComponent.Phase.ACTIVE: await physics_frame
	check(family.trail.frame_sample_transforms.size()==4,"Slam lost blade registration")
	actor.attack_component.cancel_attack()
	actual_view.queue_free()
	reference_view.queue_free()
	await process_frame
	FileAccess.open(OUT+"slash_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"native":true,"frames":reports},"\t")+"\n")
	print("UPWARD_SLASH checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _viewport() -> SubViewport:
	var view := SubViewport.new()
	view.size = Vector2i(800,800)
	view.transparent_bg = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	return view
