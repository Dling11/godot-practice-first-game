extends "res://tools/launch_king_axe_run_review.gd"

var checks := 0
var failures := 0
var contacts := 0

func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	await super._run()
	var actor: Player = stage.player
	var origin := actor.global_position
	contact_target.position += Vector2(1000,0)
	horizontal_motion.set_direction(1)
	await create_timer(0.62).timeout
	check(actor.global_position.x>origin.x+45 and axe_presenter.definition==RUN_POSES,"Axe doesn't run")
	check(axe_presenter.weapon_rig.get_index()==0 and RUN_POSES.stowed_poses[axe_presenter.pose_index]==1,"Running axe not at back")
	check(axe_presenter.hand_sprite.texture.get_image().get_used_rect().size==Vector2i.ZERO,"Free hands falsely grip axe")
	var lowest_mount := -999.0
	for index in 8:
		axe_presenter.set_pose(index)
		var handle_end := axe_presenter.weapon_rig.transform*Vector2(8,29)
		lowest_mount = maxf(lowest_mount,handle_end.y)
		var shaft: Vector2 = axe_presenter.weapon_rig.transform.basis_xform(RUN_POSES.weapon_handle_axis).normalized()
		var head := axe_presenter.weapon_rig.transform*Vector2(-25,-13)
		check(shaft.y>0.95 and shaft.x<0 and handle_end.x<0 and head.x<-15,"Back axe points into face/front foot")
	check(lowest_mount<31,"Back axe handle reaches below foot plane")
	toggle_pause()
	var held := actor.global_position
	horizontal_motion.set_direction(0)
	await create_timer(0.1,true).timeout
	check(actor.global_position==held,"Axe moves while paused")
	toggle_pause()
	check(not horizontal_motion.is_physics_processing() and axe_presenter.definition==CARRY_POSES,"Release during pause leaves axe running")
	horizontal_motion.set_direction(-1)
	await create_timer(0.2).timeout
	horizontal_motion.stop_and_clear()
	check(actor.global_position.x<held.x and axe_presenter.scale.x<0,"Left axe run wrong")
	place_target()
	actor.attack_component.hit_landed.connect(func(_target: HurtboxComponent,_info: DamageInfo) -> void: contacts += 1)
	strike()
	await create_timer(0.7).timeout
	check(contacts==1 and actor.attack_component.get_attack_direction()==Vector2.LEFT,"Back axe can't draw/hit left")
	cancel_combo()
	var wall := StaticBody2D.new()
	wall.collision_layer = actor.collision_mask
	wall.position = actor.global_position+Vector2(20,0)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(2,80)
	collision.shape = shape
	wall.add_child(collision)
	stage.get_node("World").add_child(wall)
	await physics_frame
	origin = actor.global_position
	horizontal_motion.set_direction(1)
	await create_timer(0.5).timeout
	check(actor.global_position.x-origin.x<20,"Run crosses wall")
	var blocked_pose := axe_presenter.pose_index
	var blocked_distance := axe_presenter._locomotion_distance
	await create_timer(0.2).timeout
	check(axe_presenter.pose_index==blocked_pose and is_equal_approx(axe_presenter._locomotion_distance,blocked_distance),"Feet cycle while physically blocked")
	cancel_combo()
	check(not horizontal_motion.is_physics_processing(),"Cancel leaves run active")
	wall.queue_free()
	await reset_review()
	check(horizontal_motion.direction==0 and axe_presenter.definition==CARRY_POSES,"Reset retains run")
	stage.queue_free()
	await process_frame
	print("KING_AXE_RUN checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
