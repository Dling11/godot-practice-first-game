extends CanvasLayer

const LOADING_PORTAL_SHEET_PATH := (
	"res://assets/environment/portals/generated/stage_vortex_portal_8x_128x96.png"
)

signal transition_started(target_scene: String)
signal transition_finished(target_scene: String)

var _overlay: ColorRect
var _loading_label: Label
var _loading_portal: Sprite2D
var _loading_animation: Tween
var _transitioning := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color.BLACK
	_overlay.modulate.a = 0.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	_loading_portal = Sprite2D.new()
	_loading_portal.texture = ResourceLoader.load(LOADING_PORTAL_SHEET_PATH) as Texture2D
	_loading_portal.hframes = 8
	_loading_portal.frame = 0
	_loading_portal.scale = Vector2(0.62, 0.62)
	_loading_portal.modulate.a = 0.0
	add_child(_loading_portal)
	_loading_label = Label.new()
	_loading_label.set_anchors_preset(Control.PRESET_CENTER)
	_loading_label.position = Vector2(-70, 22)
	_loading_label.size = Vector2(140, 24)
	_loading_label.text = "ENTERING THE VEIL..."
	_loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_loading_label.modulate.a = 0.0
	_loading_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_loading_label)


func transition_to(target_scene: String) -> bool:
	if _transitioning or target_scene.is_empty() or not ResourceLoader.exists(target_scene):
		return false
	_transitioning = true
	_loading_portal.position = get_viewport().get_visible_rect().size * 0.5 - Vector2(0.0, 12.0)
	_loading_label.text = _get_loading_message(target_scene)
	_start_loading_animation()
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	get_tree().paused = true
	transition_started.emit(target_scene)
	var fade_out := create_tween()
	fade_out.tween_property(_overlay, "modulate:a", 1.0, 0.35)
	fade_out.parallel().tween_property(_loading_label, "modulate:a", 1.0, 0.25)
	fade_out.parallel().tween_property(_loading_portal, "modulate:a", 1.0, 0.25)
	await fade_out.finished
	var error := get_tree().change_scene_to_file(target_scene)
	if error != OK:
		push_error("Scene transition failed for %s with error %s." % [target_scene, error])
		_transitioning = false
		_overlay.modulate.a = 0.0
		_loading_label.modulate.a = 0.0
		_loading_portal.modulate.a = 0.0
		_stop_loading_animation()
		_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		get_tree().paused = false
		return false
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().paused = false
	var fade_in := create_tween()
	fade_in.tween_property(_loading_label, "modulate:a", 0.0, 0.15)
	fade_in.parallel().tween_property(_loading_portal, "modulate:a", 0.0, 0.18)
	fade_in.parallel().tween_property(_overlay, "modulate:a", 0.0, 0.4)
	await fade_in.finished
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transitioning = false
	_stop_loading_animation()
	transition_finished.emit(target_scene)
	return true


func _start_loading_animation() -> void:
	_stop_loading_animation()
	_loading_animation = create_tween().set_loops()
	for next_frame in range(8):
		_loading_animation.tween_callback(func() -> void: _loading_portal.frame = next_frame)
		_loading_animation.tween_interval(0.14)


func _stop_loading_animation() -> void:
	if _loading_animation != null and _loading_animation.is_valid():
		_loading_animation.kill()
	_loading_animation = null


func _get_loading_message(target_scene: String) -> String:
	if target_scene.ends_with("/sanctuary.tscn"):
		return "RETURNING TO SANCTUARY..."
	var scene_name := target_scene.get_file().get_basename().replace("_", " ").to_upper()
	return "ENTERING %s..." % scene_name


func is_input_blocking() -> bool:
	return _overlay != null and _overlay.mouse_filter == Control.MOUSE_FILTER_STOP
