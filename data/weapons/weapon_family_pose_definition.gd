extends Resource

const PlantingDefinition = preload("res://data/weapons/weapon_planting_definition.gd")

## Presentation data only. MeleeAttackComponent owns contact and timing.
@export var body_atlas: Texture2D
@export var hand_atlas: Texture2D
@export var weapon_texture: Texture2D
@export var cell_size := Vector2i(192, 128)
@export var columns := 4
@export var primary_hands := PackedVector2Array()
@export var secondary_hands := PackedVector2Array()
@export var weapon_primary_grip := Vector2.ZERO
@export var weapon_handle_axis := Vector2.DOWN
## Tip landmark is weapon-specific; the shared action uses it to solve burial.
@export var weapon_tip := Vector2(-1,-1)
@export var planting: PlantingDefinition
## Handedness is independent of shaft alignment: the edge must lead the cut.
@export var mirror_cutting_edge := true
@export var lift_pixels := PackedFloat32Array([0,0,0,0,0,0,0,0])
@export_range(0,96) var maximum_lift_pixels := 24.0
@export var weapon_behind_body := PackedByteArray([0,0,0,0,0,0,0,0])
## In a one-hand pose the secondary anchor gives shaft direction, not a grip.
@export var single_hand_poses := PackedByteArray([0,0,0,0,0,0,0,0])
## Stowed frames use back attachment anchors and no foreground hand mask.
@export var stowed_poses := PackedByteArray([0,0,0,0,0,0,0,0])
## Detached planted weapon: anchors belong to its ground attachment, not hands.
@export var released_poses := PackedByteArray([0,0,0,0,0,0,0,0])
## Planted poses hide steel below the registered foot plane; no weapon rescaling.
@export var ground_clipped_poses := PackedByteArray([0,0,0,0,0,0,0,0])
@export var follow_up_clips: Array[Resource] = []
@export var phase_windows := PackedVector2Array([Vector2(0, 3), Vector2(4, 5), Vector2(6, 7)])

func has_valid_layout() -> bool:
	if body_atlas == null or hand_atlas == null or weapon_texture == null:
		return false
	# This first proof explicitly uses eight poses in a 4x2 atlas.
	if columns != 4 or cell_size.x <= 0 or cell_size.y <= 0 or primary_hands.size() != 8 or secondary_hands.size() != 8 or phase_windows.size() != 3 or lift_pixels.size() != 8 or weapon_behind_body.size()!=8 or single_hand_poses.size()!=8 or stowed_poses.size()!=8 or released_poses.size()!=8:
		return false
	if not weapon_handle_axis.is_finite() or weapon_handle_axis.is_zero_approx() or not Rect2(Vector2.ZERO,weapon_texture.get_size()).has_point(weapon_primary_grip):
		return false
	if ground_clipped_poses.size()!=8: return false
	if planting!=null:
		if not planting.is_valid(cell_size) or not Rect2(Vector2.ZERO,weapon_texture.get_size()).has_point(weapon_tip) or weapon_tip.distance_to(weapon_primary_grip)<=planting.burial_depth_pixels: return false
	var first := 0
	if not is_finite(maximum_lift_pixels) or maximum_lift_pixels<0 or maximum_lift_pixels>96: return false
	for window in phase_windows:
		if not window.is_finite() or window.x != first or window.y != floorf(window.y) or window.y < window.x or window.y > 7:
			return false
		first = int(window.y)+1
	if first != 8: return false
	for index in 8:
		if not is_finite(lift_pixels[index]) or lift_pixels[index]>0 or lift_pixels[index]<-maximum_lift_pixels:
			return false
		if not Rect2(Vector2.ZERO,Vector2(cell_size)).has_point(primary_hands[index]) or not Rect2(Vector2.ZERO,Vector2(cell_size)).has_point(secondary_hands[index]) or primary_hands[index].distance_to(secondary_hands[index]) < 1.0:
			return false
	for clip in follow_up_clips:
		if clip == null or clip.get_script()!=get_script() or not clip.follow_up_clips.is_empty() or not clip.has_valid_layout(): return false
	return body_atlas.get_size() == Vector2(cell_size.x * columns, cell_size.y * 2) and hand_atlas.get_size() == body_atlas.get_size()
