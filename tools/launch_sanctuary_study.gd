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
	root.title = "Battle of Gods — Sanctuary Environment Study"
