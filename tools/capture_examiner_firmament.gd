extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
const OUT := "res://art_source/review/characters/disciples/examiner/firmament_2026_09_12/"
var lab: Node
var boss: Examiner
var drive := false

func _initialize() -> void:
	call_deferred("run")

func _process(delta: float) -> bool:
	if drive and is_instance_valid(boss) and boss.state != Examiner.State.APPROACH:
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
	boss.global_position = Vector2(365,325)
	lab.player.global_position = Vector2(460,395)
	drive = true
	boss._begin_orb()
	await create_timer(1.1).timeout
	await capture("01_gathering")
	await create_timer(2).timeout
	await capture("02_growing")
	await create_timer(1.9).timeout
	await capture("03_overcharged")
	await create_timer(.6).timeout
	var route := create_tween()
	route.tween_property(lab.player,"global_position",Vector2(595,390),.7)
	await create_timer(.8).timeout
	await capture("04_fast_impact")
	await create_timer(1).timeout
	boss._phase_transition_requested = true
	boss._phase_two = true
	boss.health_component.set_current_health(620)
	boss._try_phase_transition()
	await create_timer(.8).timeout
	await capture("05_enrage")
	await create_timer(3.5).timeout
	boss._begin_firmament()
	await create_timer(2.6).timeout
	await capture("06_crimson_charge")
	await create_timer(1.5).timeout
	await capture("07_rain_first_wave")
	route = create_tween()
	route.tween_property(lab.player,"global_position",Vector2(125,370),2.2)
	await create_timer(1.8).timeout
	await capture("08_rain_midway")
	await create_timer(1.3).timeout
	await capture("09_open_corridor")
	await create_timer(.8).timeout
	boss._begin_firmament()
	await create_timer(2.3).timeout
	boss.health_component.apply_damage(DamageInfo.new(300,lab.player,Vector2.RIGHT))
	await create_timer(.4).timeout
	await capture("10_interrupted")
	await create_timer(.8).timeout
	drive = false
	lab.clear_simulation()
	lab.queue_free()
	boss = null
	lab = null
	await process_frame
	await process_frame
	for shape in range(DisplayServer.CURSOR_MAX):
		DisplayServer.cursor_set_custom_image(null,shape)
	await process_frame
	print("Examiner Firmament rendered review complete")
	quit()

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+label+".png")
	print("Captured ",label)
