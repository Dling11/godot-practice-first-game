class_name MaterialPickup
extends Area2D

## Presentation and contact collection for one already-resolved enemy drop.

@export var icon_sprite: Sprite2D
@export var quantity_label: Label
@export var glow: Polygon2D

var material_definition: MaterialDefinition
var quantity := 0
var _collecting := false


func configure(definition: MaterialDefinition, amount: int) -> void:
	material_definition = definition
	quantity = amount


func _ready() -> void:
	if (
		material_definition == null
		or not material_definition.is_valid()
		or quantity <= 0
		or icon_sprite == null
		or quantity_label == null
		or glow == null
	):
		push_error("MaterialPickup requires valid material data and presentation nodes.")
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	monitoring = false
	icon_sprite.texture = material_definition.icon
	quantity_label.text = "×%d" % quantity
	quantity_label.visible = quantity > 1
	glow.color = material_definition.get_rarity_color()
	glow.modulate.a = 0.22
	scale = Vector2(0.6, 0.6)


func begin_pop(direction: Vector2) -> void:
	if not is_inside_tree():
		return
	var launch_direction := direction.normalized()
	if launch_direction.is_zero_approx():
		launch_direction = Vector2.UP
	var start := position
	var destination := start + launch_direction * 18.0
	var pop := create_tween().set_parallel()
	pop.tween_property(self, "position", destination, 0.24).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_OUT)
	pop.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	pop.chain().tween_callback(_enable_collection)

	var pulse := create_tween().set_loops()
	pulse.tween_property(glow, "scale", Vector2(1.18, 1.18), 0.65).set_trans(
		Tween.TRANS_SINE
	)
	pulse.tween_property(glow, "scale", Vector2.ONE, 0.65).set_trans(
		Tween.TRANS_SINE
	)


func _enable_collection() -> void:
	if not is_inside_tree():
		return
	monitoring = true
	await get_tree().physics_frame
	for body: Node2D in get_overlapping_bodies():
		if body is Player:
			_collect()
			return


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_collect()


func _collect() -> void:
	if _collecting:
		return
	_collecting = true
	set_deferred("monitoring", false)
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service == null or not loot_service.grant_material(
		material_definition,
		quantity,
		&"enemy_drop"
	):
		_collecting = false
		set_deferred("monitoring", true)
		return
	var collect := create_tween().set_parallel()
	collect.tween_property(self, "scale", Vector2(1.35, 1.35), 0.12)
	collect.tween_property(self, "modulate:a", 0.0, 0.12)
	collect.chain().tween_callback(queue_free)
