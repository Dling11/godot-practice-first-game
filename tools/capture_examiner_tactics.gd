extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
const OUT := "res://art_source/review/characters/disciples/examiner/tactics_2026_09_12/"
var lab: Node
var boss: Examiner
var drive := false

func _initialize() -> void:
	call_deferred("run")

func _process(delta: float) -> bool:
	if drive and not paused and is_instance_valid(boss) and boss.state != Examiner.State.APPROACH:
		boss._physics_process(delta)
	return false

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	lab = Lab.instantiate()
	root.add_child(lab)
	current_scene = lab
	await create_timer(.8).timeout
	boss = lab._active_enemies[0] as Examiner
	boss.set_physics_process(false)
	lab.player.set_physics_process(false)
	boss._deactivate_hitboxes()
	boss.global_position = Vector2(300,280)
	lab.player.global_position = Vector2(480,280)
	boss._phase_transition_requested = true
	boss._phase_two = true
	boss._set_facing(Vector2.RIGHT)
	drive = true
	boss._begin_axiom(lab.player.global_position - boss.global_position)
	await create_timer(.8).timeout
	await capture("01_axiom")
	await create_timer(3).timeout
	boss._cancel_suns()
	boss._berserk = true
	boss.health_component.set_current_health(620)
	boss.global_position = Vector2(365,280)
	lab.player.global_position = Vector2(530,350)
	boss._begin_firmament()
	await create_timer(3).timeout
	await capture("02_crimson_charge")
	await create_timer(1).timeout
	var route := create_tween()
	route.tween_property(lab.player,"global_position",Vector2(220,350),2.4)
	route.tween_property(lab.player,"global_position",Vector2(300,460),1.3)
	route.tween_property(lab.player,"global_position",Vector2(490,390),1.5)
	await create_timer(1.6).timeout
	await capture("03_random_rain")
	await create_timer(1.9).timeout
	await capture("04_late_rain")
	await create_timer(2).timeout
	boss._begin_orb()
	await create_timer(1.8).timeout
	boss.health_component.apply_damage(DamageInfo.new(400,lab.player,Vector2.UP))
	await create_timer(.4).timeout
	await capture("05_seal_reaction")
	await create_timer(1).timeout
	drive = false
	boss.health_component.apply_damage(DamageInfo.new(5000,lab.player,Vector2.UP))
	await create_timer(.4).timeout
	await capture("06_victory_kneel")
	await create_timer(1.4).timeout
	await capture("07_acknowledgment")
	for line_index in 4:
		await create_timer(1.5).timeout
		lab.examiner_director.dialogue.advance()
	await create_timer(.6).timeout
	await capture("08_trial_complete")
	await create_timer(1.2).timeout
	lab.clear_simulation()
	lab.queue_free()
	boss = null
	lab = null
	await process_frame
	await process_frame
	for shape in range(DisplayServer.CURSOR_MAX):
		DisplayServer.cursor_set_custom_image(null,shape)
	await process_frame
	print("Examiner tactics rendered review complete")
	quit()

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+label+".png")
	print("Captured ",label)
