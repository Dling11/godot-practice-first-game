class_name SummonEffect
extends Node2D

@export var rune: Node2D
@export var lightning: Line2D
@export var flash: Polygon2D
@export_range(0.2, 2.0, 0.05, "suffix:s") var duration := 0.7


func _ready() -> void:
	_build_lightning()
	rune.scale = Vector2(0.25, 0.25)
	rune.modulate.a = 0.0
	lightning.modulate.a = 0.0
	flash.scale = Vector2(0.2, 0.2)
	flash.modulate.a = 0.0

	var rune_tween := create_tween()
	rune_tween.tween_property(rune, "modulate:a", 0.9, duration * 0.2)
	rune_tween.parallel().tween_property(rune, "scale", Vector2.ONE, duration * 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	rune_tween.tween_interval(duration * 0.3)
	rune_tween.tween_property(rune, "scale", Vector2(1.25, 1.25), duration * 0.25)
	rune_tween.parallel().tween_property(rune, "modulate:a", 0.0, duration * 0.25)

	var strike_tween := create_tween()
	strike_tween.tween_interval(duration * 0.18)
	strike_tween.tween_property(lightning, "modulate:a", 1.0, 0.03)
	strike_tween.parallel().tween_property(flash, "modulate:a", 0.9, 0.03)
	strike_tween.parallel().tween_property(flash, "scale", Vector2.ONE, 0.08).set_trans(Tween.TRANS_BACK)
	strike_tween.tween_property(lightning, "modulate:a", 0.0, duration * 0.2)
	strike_tween.parallel().tween_property(flash, "modulate:a", 0.0, duration * 0.22)

	_spawn_inward_sparks()
	get_tree().create_timer(duration + 0.1).timeout.connect(queue_free)


func _build_lightning() -> void:
	var points := PackedVector2Array()
	for index in range(7):
		var progress := float(index) / 6.0
		var x_offset := 0.0 if index == 0 or index == 6 else randf_range(-5.0, 5.0)
		points.append(Vector2(x_offset, lerpf(-64.0, 0.0, progress)))
	lightning.points = points


func _spawn_inward_sparks() -> void:
	for index in range(8):
		var spark := Polygon2D.new()
		spark.polygon = PackedVector2Array([Vector2(-1, 0), Vector2(0, -2), Vector2(1, 0), Vector2(0, 2)])
		spark.color = Color(0.72, 0.5, 1.0, 0.9)
		spark.position = Vector2.RIGHT.rotated(TAU * float(index) / 8.0) * 26.0
		add_child(spark)
		var tween := create_tween()
		tween.tween_interval(duration * 0.12)
		tween.tween_property(spark, "position", Vector2.ZERO, duration * 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(spark, "modulate:a", 0.0, duration * 0.55)
