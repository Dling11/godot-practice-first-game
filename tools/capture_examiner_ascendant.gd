extends SceneTree

const LabScene = preload("res://levels/combat_lab/combat_lab.tscn")
const OUT := "res://art_source/review/characters/disciples/examiner/ascendant_2026_09_12/"
var lab: Node
var boss: Examiner
var drive := false

func _initialize() -> void:
	call_deferred("_run")

func _process(delta: float) -> bool:
	if drive and is_instance_valid(boss) and boss.state != Examiner.State.APPROACH:
		boss._physics_process(delta)
	return false

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	lab = LabScene.instantiate()
	root.add_child(lab)
	current_scene = lab
	await create_timer(.9).timeout
	boss = lab._active_enemies[0] as Examiner
	boss.set_physics_process(false)
	lab.player.set_physics_process(false)
	boss._deactivate_hitboxes()
	boss.global_position = Vector2(365,310)
	lab.player.global_position = Vector2(365,385)
	boss._enter(Examiner.State.APPROACH,0)
	drive = true
	# Real guard hits; their raw values are a review fixture, not a player buff.
	boss._begin_trial()
	await create_timer(1.4).timeout
	await capture("01_seal_charge")
	for hit in 4:
		lab.player.request_directional_primary_attack(boss.global_position)
		boss.health_component.apply_damage(DamageInfo.new(90,lab.player,Vector2.UP))
		await create_timer(.5).timeout
	await capture("02_guard_shattered")
	await create_timer(2).timeout
	boss._begin_orb()
	await create_timer(4.6).timeout
	await capture("03_borrowed_sun")
	await create_timer(1.1).timeout
	var route := create_tween()
	route.tween_property(lab.player,"global_position",Vector2(525,385),.9)
	await create_timer(.6).timeout
	await capture("04_sun_in_flight")
	await create_timer(.5).timeout
	await capture("05_sun_impact")
	await create_timer(1).timeout
	boss._phase_transition_requested = true
	boss._phase_two = true
	boss.health_component.set_current_health(630)
	lab.player.global_position = Vector2(365,380)
	boss._try_phase_transition()
	await create_timer(.8).timeout
	await capture("06_unbound")
	await create_timer(1.2).timeout
	await capture("07_crownfall_warning")
	route = create_tween()
	route.tween_property(lab.player,"global_position",Vector2(555,260),.8)
	await create_timer(1.5).timeout
	await capture("08_crownfall_impact")
	await create_timer(1.2).timeout
	boss._begin_orb()
	await create_timer(4.8).timeout
	await capture("09_berserk_sun")
	boss.health_component.apply_damage(DamageInfo.new(400,lab.player,Vector2.LEFT))
	await create_timer(.5).timeout
	await capture("10_berserk_interrupted")
	await create_timer(1.2).timeout
	drive = false
	lab.clear_simulation()
	lab.queue_free()
	lab = null
	boss = null
	await process_frame
	await process_frame
	for shape in range(DisplayServer.CURSOR_MAX):
		DisplayServer.cursor_set_custom_image(null,shape)
	await process_frame
	print("Examiner Ascendant rendered review complete")
	quit()

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + label + ".png")
	print("Captured ", label)
