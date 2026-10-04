extends SceneTree
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const IDLE = preload("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
var checks := 0
var failures := 0
func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var view := SubViewport.new()
	view.size = Vector2i(192,192)
	view.transparent_bg = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var attack := MeleeAttackComponent.new()
	root.add_child(attack)
	var rig := Presenter.new()
	check(rig.configure(IDLE,attack,false),"Cannot configure plant proof")
	rig.position = Vector2(96,120)
	rig.scale = Vector2.ONE*0.5
	view.add_child(rig)
	rig.body_sprite.hide()
	rig.hand_sprite.hide()
	for facing in [1,-1]:
		rig.face_horizontal(facing)
		rig.set_pose(7)
		await process_frame
		await RenderingServer.frame_post_draw
		var image := view.get_texture().get_image()
		var bounds := image.get_used_rect()
		check(bounds.size.y>55 and bounds.end.y<=137,"Shallow planted sword disappears or renders below feet")
		var seam := image.get_region(Rect2i(0,130,192,7)).get_used_rect()
		check(seam.size.x>0 and (seam.end.x<96 if facing==1 else seam.position.x>96),"Emerging steel not beside mirrored foot")
		rig._ground_material.set_shader_parameter("buried",false)
		await process_frame
		await RenderingServer.frame_post_draw
		var unburied := view.get_texture().get_image().get_used_rect()
		check(unburied.end.y>137 and unburied.end.y<=142 and unburied.size.y-bounds.size.y<=6,"Tip is buried too deeply or only short art is used")
		var shaded := view.get_texture().get_image()
		rig.weapon_sprite.material = null
		await process_frame
		await RenderingServer.frame_post_draw
		check(shaded.get_data()==view.get_texture().get_image().get_data(),"Default plant shader changes blade palette/alpha")
		rig.weapon_sprite.material = rig._ground_material
		check(rig.weapon_sprite.texture==IDLE.weapon_texture and rig.weapon_sprite.scale==Vector2.ONE,"Plant deforms rigid sword")
	for grip_height in [75,145]:
		# Geometric fixtures with distinct blade/handle proportions, not game art.
		var variant = IDLE.duplicate(true)
		var pixels := Image.create(30,grip_height+27,false,Image.FORMAT_RGBA8)
		pixels.fill_rect(Rect2i(12,0,7,grip_height),Color.SILVER)
		pixels.fill_rect(Rect2i(13,grip_height,4,27),Color.SADDLE_BROWN)
		variant.weapon_texture = ImageTexture.create_from_image(pixels)
		variant.weapon_primary_grip = Vector2(15,grip_height)
		check(variant.has_valid_layout(),"Reusable stance rejects compatible blade length")
		rig.select_clip(variant)
		rig.face_horizontal(1)
		rig._advance_pose(4.999)
		var hand: Vector2 = variant.primary_hands[4]-Vector2(96,64)+rig.hand_sprite.position
		check(rig.weapon_rig.transform.origin.distance_to(hand)<0.001,"Plant preparation loses actual hand grip")
		check(rig.body_sprite.position.y<0 and rig.position==Vector2(96,120),"Preparation cannot reach huge hilt or moves collision root")
		rig.set_pose(7)
		await process_frame
		await RenderingServer.frame_post_draw
		var bounds := view.get_texture().get_image().get_used_rect()
		check(bounds.end.y<=137 and bounds.size.y>35,"Variant isn't shallow planted at same ground plane")
		rig._ground_material.set_shader_parameter("buried",false)
		await process_frame
		await RenderingServer.frame_post_draw
		check(view.get_texture().get_image().get_used_rect().end.y<=142,"Variant length changes burial depth")
	view.queue_free()
	attack.queue_free()
	await process_frame
	print("KING_PLANTED_WEAPON checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
