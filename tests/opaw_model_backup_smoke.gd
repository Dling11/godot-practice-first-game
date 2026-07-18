extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const CompactFrames = preload("res://assets/characters/playable/opaw/compact_armless/opaw_compact_armless_sprite_frames.tres")
const WayfarerBackupFrames = preload("res://assets/characters/playable/opaw/variants/wayfarer_original/opaw_wayfarer_original_sprite_frames.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	await process_frame
	var body := player.get_node("VisualRoot/Body") as AnimatedSprite2D
	if body.sprite_frames != CompactFrames:
		_fail("Playable Opaw is not using the compact armless model.")
		return
	if body.sprite_frames == WayfarerBackupFrames:
		_fail("Playable Opaw still points at the archived Wayfarer model.")
		return
	for animation_name: StringName in CompactFrames.get_animation_names():
		if not WayfarerBackupFrames.has_animation(animation_name):
			_fail("Wayfarer backup is missing animation %s." % animation_name)
			return
		if WayfarerBackupFrames.get_frame_count(animation_name) != CompactFrames.get_frame_count(animation_name):
			_fail("Wayfarer backup changed the frame count for %s." % animation_name)
			return
	var backup_frame := WayfarerBackupFrames.get_frame_texture(&"idle_down", 0) as AtlasTexture
	var active_frame := CompactFrames.get_frame_texture(&"idle_down", 0) as AtlasTexture
	if backup_frame == null or active_frame == null or backup_frame.atlas == active_frame.atlas:
		_fail("Opaw's active and archived models do not have independent textures.")
		return
	print("Opaw compact model and complete Wayfarer backup smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
