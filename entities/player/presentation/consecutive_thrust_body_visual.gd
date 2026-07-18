class_name ConsecutiveThrustBodyVisual
extends Sprite2D

## Shows a separate action-owned body sheet for Consecutive Thrust while the
## normal AnimatedSprite2D keeps ownership of locomotion and ordinary attacks.

const CELL_SIZE := Vector2(48.0, 32.0)
const STRIKE_COLUMNS := [1, 2, 3, 4, 5, 6, 7]
const STRIKE_FORWARD_OFFSETS := [0.0, -1.0, 1.0, -1.0, 1.0, 0.0, 2.0]

@export var ability_component: AbilityComponent
@export var body_visual: AnimatedSprite2D

var _direction := Vector2.DOWN
var _base_position := Vector2.ZERO


func _ready() -> void:
	hide()


func play_phase(phase: AbilityComponent.Phase, _duration_seconds: float) -> void:
	if ability_component == null:
		return
	if phase == AbilityComponent.Phase.WIND_UP:
		_direction = ability_component.get_cast_direction()
		_base_position = body_visual.position if body_visual != null else position
		_show_pose(0, _base_position - _direction)
		return
	if phase == AbilityComponent.Phase.ACTIVE:
		_show_pose(1, _base_position)
		return
	if phase == AbilityComponent.Phase.RECOVERY:
		_show_pose(7, _base_position)


func play_strike(strike_index: int, _strike_count: int, _duration_seconds: float) -> void:
	var frame_index := clampi(strike_index, 0, STRIKE_COLUMNS.size() - 1)
	_show_pose(
		STRIKE_COLUMNS[frame_index],
		_base_position + _direction * STRIKE_FORWARD_OFFSETS[frame_index]
	)


func hide_visual() -> void:
	hide()
	if body_visual != null:
		body_visual.show()


func _show_pose(column: int, next_position: Vector2) -> void:
	if body_visual != null:
		body_visual.hide()
	position = next_position.round()
	region_rect = Rect2(
		Vector2(column, _direction_row()) * CELL_SIZE,
		CELL_SIZE
	)
	show()


func _direction_row() -> int:
	if absf(_direction.x) > absf(_direction.y):
		return 2 if _direction.x > 0.0 else 1
	return 0 if _direction.y > 0.0 else 3
