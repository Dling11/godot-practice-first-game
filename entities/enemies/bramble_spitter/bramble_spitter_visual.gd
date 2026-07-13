extends Node2D

@export var body: AnimatedSprite2D
@export var target_marker: Node2D
@export var target_ring: Line2D
@export var muzzle_flash: Polygon2D
@export var muzzle_sparks: CPUParticles2D

var _direction := "down"
var _telegraph_tween: Tween
var _body_tween: Tween
var _flash_tween: Tween


func _ready() -> void:
	target_marker.top_level = true
	target_marker.hide()
	muzzle_flash.hide()


func set_facing(direction: Vector2) -> void:
	_direction = ("right" if direction.x > 0.0 else "left") if absf(direction.x) > absf(direction.y) else ("down" if direction.y > 0.0 else "up")


func play_state(state: BrambleSpitter.State, duration: float) -> void:
	match state:
		BrambleSpitter.State.SPAWNING:
			body.play("idle_down")
			body.modulate.a = 0.0
			body.scale = Vector2(0.35, 0.15)
			var tween := create_tween().set_parallel(true)
			tween.tween_property(body, "modulate:a", 1.0, duration)
			tween.tween_property(body, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_BACK)
		BrambleSpitter.State.POSITIONING:
			_hide_telegraph()
			body.modulate = Color.WHITE
			body.scale = Vector2.ONE
			body.position = Vector2(0.0, -17.0)
			body.play("walk_" + _direction)
		BrambleSpitter.State.WIND_UP:
			body.play("attack_" + _direction)
			if _body_tween != null and _body_tween.is_valid():
				_body_tween.kill()
			_body_tween = create_tween().set_parallel(true)
			_body_tween.tween_property(body, "scale", Vector2(1.18, 0.86), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			_body_tween.tween_property(body, "modulate", Color(1.28, 1.2, 0.72, 1.0), duration)
		BrambleSpitter.State.RECOVERY:
			_hide_telegraph()
			body.play("idle_" + _direction)
		BrambleSpitter.State.DEAD:
			_hide_telegraph()
			body.play("dead_" + _direction)
			create_tween().tween_property(body, "modulate:a", 0.0, duration)


func show_shot_telegraph(global_target: Vector2, duration: float) -> void:
	if _telegraph_tween != null and _telegraph_tween.is_valid():
		_telegraph_tween.kill()
	target_marker.global_position = global_target
	target_marker.scale = Vector2(0.65, 0.65)
	target_marker.modulate.a = 0.35
	target_ring.width = 1.0
	target_marker.show()
	_telegraph_tween = create_tween().set_parallel(true)
	_telegraph_tween.tween_property(target_marker, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_telegraph_tween.tween_property(target_marker, "modulate:a", 1.0, duration)
	_telegraph_tween.tween_property(target_ring, "width", 3.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func play_firing_feedback(direction: Vector2) -> void:
	_hide_telegraph()
	if _body_tween != null and _body_tween.is_valid():
		_body_tween.kill()
	body.scale = Vector2.ONE
	body.modulate = Color.WHITE
	var recoil_offset := -direction * 2.0
	_body_tween = create_tween()
	_body_tween.tween_property(body, "position", Vector2(0.0, -17.0) + recoil_offset, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_body_tween.tween_property(body, "position", Vector2(0.0, -17.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var muzzle_position := Vector2(0.0, -13.0) + direction * 12.0
	muzzle_flash.position = muzzle_position
	muzzle_flash.rotation = direction.angle()
	muzzle_flash.scale = Vector2(0.35, 0.35)
	muzzle_flash.modulate.a = 1.0
	muzzle_flash.show()
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = create_tween().set_parallel(true)
	_flash_tween.tween_property(muzzle_flash, "scale", Vector2(1.5, 1.5), 0.12)
	_flash_tween.tween_property(muzzle_flash, "modulate:a", 0.0, 0.12)
	_flash_tween.chain().tween_callback(muzzle_flash.hide)
	muzzle_sparks.position = muzzle_position
	muzzle_sparks.rotation = direction.angle()
	muzzle_sparks.restart()


func _hide_telegraph() -> void:
	target_marker.hide()
