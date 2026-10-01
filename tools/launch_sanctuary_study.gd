extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var hub: Node = load("res://levels/sanctuary/sanctuary.tscn").instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	await process_frame
	var study: Node = load("res://levels/sanctuary/review/refuge_study.gd").new()
	study.hub = hub
	hub.add_child(study)
	if "--training-demo" in OS.get_cmdline_user_args():
		root.get_node("StoryState").remember_story(&"forest_stage_5_cleared")
		root.get_node("RunSession").update_progression(4950,0)
	if "--workshop-door" in OS.get_cmdline_user_args(): study.visit_workshop()
	elif "--eira" in OS.get_cmdline_user_args(): study.visit_eira()
	else: study.visit_orren()
	root.title = "Battle of Gods — Living Sanctuary Review"
