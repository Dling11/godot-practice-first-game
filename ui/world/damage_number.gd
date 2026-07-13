class_name DamageNumber
extends Node2D

## Short-lived world-space number for accepted damage only.

@export var lifetime_seconds := 0.55

@onready var label: Label = %Label

var _amount := 0.0
var _tint := Color.WHITE
var _rise_pixels := 18.0


func configure(amount: float, tint: Color, rise_pixels := 18.0) -> void:
	_amount = amount
	_tint = tint
	_rise_pixels = rise_pixels


func _ready() -> void:
	label.text = str(roundi(_amount))
	label.modulate = _tint
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - _rise_pixels, lifetime_seconds)
	tween.tween_property(label, "modulate:a", 0.0, lifetime_seconds * 0.6).set_delay(lifetime_seconds * 0.4)
	get_tree().create_timer(lifetime_seconds).timeout.connect(queue_free)
