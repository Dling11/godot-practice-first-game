extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var lab := Lab.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	var actor: Player = lab.player
	var review: Node = lab.get_node("KingSpellwardReview")
	review.open_review()
	lab.clear_simulation()
	var impact := actor.get_node("AbilityPivot/SovereignPursuitVisual/EffectSprite") as AnimatedSprite2D
	var travel := actor.get_node("VisualRoot/SovereignPursuitTravelVisual/EffectSprite") as AnimatedSprite2D
	var visual := actor.get_node("AbilityPivot/SovereignPursuitVisual") as SovereignPursuitVisual
	var original_impact := impact.sprite_frames
	var original_travel := travel.sprite_frames
	var original_z := visual.z_index
	review.toggle_pursuit_review()
	_check(impact.sprite_frames != original_impact and travel.sprite_frames != original_travel, "Review did not install both animated sheets")
	_check(impact.sprite_frames.get_frame_count(&"impact") == 12 and impact.sprite_frames.get_frame_count(&"afterglow") == 2 and travel.sprite_frames.get_frame_count(&"travel") == 8, "Review sheets lack authored frames")
	_check(visual.z_index < original_z, "Ground impact should render behind King")
	actor.global_position = Vector2(330, 310)
	await physics_frame
	_check(actor.request_ability(3), "Skill 3 targeting rejected")
	actor.ground_point_targeting.update_aim(Vector2(470, 310), Vector2.ZERO)
	_check(actor.ground_point_targeting.confirm_targeting(), "Skill 3 target rejected")
	var ability := actor.ability_3_component as SovereignPursuitComponent
	for frame in 55:
		await physics_frame
		if not ability.is_casting():
			break
	_check(not ability.is_casting(), "Review altered Pursuit commitment")
	_check(visual.visible and impact.animation == &"impact", "Released impact disappeared when control returned")
	var contact := visual.global_position
	actor.global_position += Vector2(28, 0)
	await physics_frame
	_check(visual.global_position.distance_to(contact) < 0.1, "Review impact followed King after landing")
	review.toggle_pursuit_review()
	_check(impact.sprite_frames != original_impact, "Review changed frames while the released impact was visible")
	await create_timer(.4, false).timeout
	_check(impact.animation == &"afterglow" and visual.visible, "Review impact did not reach its world-fixed afterglow")
	await create_timer(.7, false).timeout
	_check(not visual.visible, "Review impact did not clean up")
	review.toggle_pursuit_review()
	_check(impact.sprite_frames == original_impact and travel.sprite_frames == original_travel and visual.z_index == original_z, "Original Skill 3 art was not restored")
	lab.queue_free()
	print("PURSUIT_REVIEW_SMOKE_FAILURES=", failures)
	quit(1 if failures else 0)


func _check(ok: bool, reason: String) -> void:
	if not ok:
		failures += 1
		push_error(reason)
