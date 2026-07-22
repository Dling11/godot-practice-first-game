extends SceneTree

const ForgottenGrove = preload("res://data/expeditions/forgotten_grove.tres")
const GroveThorns = preload("res://data/expeditions/thorns_of_the_forgotten_grove.tres")
const AshenPilgrimage = preload("res://data/expeditions/ashen_pilgrimage.tres")
const DrownedBells = preload("res://data/expeditions/drowned_bells.tres")
const Progression = preload("res://data/progression/opaw_path.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var story_state := root.get_node("StoryState")
	var run_session := root.get_node("RunSession")
	story_state.reset_story()
	run_session.reset_run()

	for definition: ExpeditionDefinition in [ForgottenGrove, GroveThorns, AshenPilgrimage, DrownedBells]:
		if not definition.is_valid_definition():
			_fail("An expedition definition is missing its stable identity or display metadata.")
			return

	if ForgottenGrove.is_available(story_state, 1):
		_fail("The Forgotten Grove opened before the new soul awakened in Sanctuary.")
		return
	story_state.remember_story(&"awakened_in_sanctuary")
	if not ForgottenGrove.is_available(story_state, 1):
		_fail("The introductory route did not open after Sanctuary awakening.")
		return
	if GroveThorns.is_available(story_state, 1):
		_fail("Stage 2 opened before Stage 1's clear flag.")
		return
	story_state.remember_story(&"forgotten_grove_stage_1_cleared")
	if not GroveThorns.is_available(story_state, 1):
		_fail("Stage 2 did not open after Stage 1's clear flag.")
		return

	var ashen_requirement := AshenPilgrimage.requirement
	var initial_unmet := ashen_requirement.get_unmet_requirements(story_state, 1)
	for expected in [
		"REACH LEVEL 3",
		"STORY: Forgotten Grove Completed",
		"BOSS: Thornbound Warden",
		"KEY ITEM: Cinder Sigil",
	]:
		if expected not in initial_unmet:
			_fail("Ashen Pilgrimage omitted an authored requirement: %s" % expected)
			return

	run_session.update_progression(50, 0)
	var player_level := Progression.get_level_for_total_experience(run_session.total_experience)
	story_state.remember_story(&"forgotten_grove_completed")
	story_state.record_boss_victory(&"thornbound_warden")
	story_state.grant_key_item(&"cinder_sigil")
	if player_level != 3 or not ashen_requirement.is_satisfied(story_state, player_level):
		_fail("Combined level, story, boss, and key-item requirements did not resolve.")
		return
	if not AshenPilgrimage.is_available(story_state, player_level):
		_fail("Stage 3 did not open after its authored requirements were met.")
		return

	story_state.record_discovery(&"remembered_thorn_shrine")
	var snapshot: Dictionary = story_state.create_snapshot()
	story_state.reset_story()
	if story_state.has_boss_victory(&"thornbound_warden"):
		_fail("Resetting story memory retained an old boss victory.")
		return
	if not story_state.restore_snapshot(snapshot):
		_fail("The versioned story snapshot could not be restored.")
		return
	if (
		not story_state.has_story_flag(&"forgotten_grove_completed")
		or not story_state.has_boss_victory(&"thornbound_warden")
		or not story_state.has_key_item(&"cinder_sigil")
		or not story_state.has_discovery(&"remembered_thorn_shrine")
	):
		_fail("Story snapshot restoration lost authored memory categories.")
		return
	if story_state.restore_snapshot({"version": 999}):
		_fail("Story memory accepted an unsupported snapshot version.")
		return

	print("Expedition unlock smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
