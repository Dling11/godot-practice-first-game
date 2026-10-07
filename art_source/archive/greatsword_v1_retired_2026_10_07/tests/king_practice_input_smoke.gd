extends "res://tools/launch_king_greatsword_confidence_review.gd"

const LAB_PATH := "res://levels/combat_lab/combat_lab.tscn"
const ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const OUT := "res://art_source/review/combat/king_practice_input_2026_10_05/"
var checks := 0
var failures := 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	await super._run()
	root.size = Vector2i(960,540)
	check(not stage.character_menu.is_processing_input(),"Hidden review Bag still listens for input")
	await key(KEY_TAB)
	var deadline := Time.get_ticks_msec()+5000
	while (current_scene==null or current_scene.scene_file_path!=LAB_PATH) and Time.get_ticks_msec()<deadline:
		await process_frame
	while root.get_node("SceneTransition")._transitioning and Time.get_ticks_msec()<deadline:
		await process_frame
	check(current_scene.scene_file_path==LAB_PATH,"Review Tab did not enter playable practice")
	if current_scene.scene_file_path!=LAB_PATH:
		if stage.character_menu.visible: stage.character_menu.close_menu()
		paused = false
		stage.queue_free()
		await process_frame
		var fallback: Node = load(LAB_PATH).instantiate()
		root.add_child(fallback)
		current_scene = fallback
		await process_frame
	var lab := current_scene
	lab.clear_simulation()
	var menu := lab.get_node_or_null("UI/CharacterMenu") as CharacterMenu
	check(menu!=null,"Combat Lab has no Bag despite the HUD/Tab control")
	if menu!=null:
		check(menu.is_visible_in_tree() and paused,"Review Tab opened an invisible pause instead of the playable Bag")
		await capture("practice_bag.png")
		await key(KEY_ESCAPE)
		check(not paused,"Practice did not resume after closing the initial Bag")
		check(lab.player.get_equipped_weapon_item()==ITEM,"Playable practice lost the accepted greatsword")
		await key(KEY_TAB)
		check(menu.is_visible_in_tree() and paused,"Physical Tab did not open a visible practice Bag")
		await key(KEY_ESCAPE)
		check(not menu.visible and not paused,"Closing practice Bag left controls paused")
		await key(KEY_F9)
		check(root.get_node("WeaponInventory").owns_weapon(ITEM.item_id),"Practice F9 did not expose greatsword")
		await key(KEY_TAB)
		menu.equipment_detail_panel.equip_requested.emit(ITEM)
		check(lab.player.attack_component.weapon==ITEM.weapon_definition,"Practice Bag cannot equip accepted weapon")
		await key(KEY_ESCAPE)
		var before: Vector2 = lab.player.global_position
		Input.action_press("player_move_right")
		await create_timer(.3).timeout
		Input.action_release("player_move_right")
		check(lab.player.global_position.distance_to(before)>10,"Practice movement remains disabled after closing Bag")
		await capture("practice_controls.png")
		check(lab.player.request_primary_attack(),"Practice primary attack remains disabled")
		await create_timer(.4).timeout
		check(lab.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE,"Production attack never entered live phases")
		lab.player.attack_component.cancel_attack()
		lab.combat_hud.character_menu_requested.emit()
		check(menu.is_visible_in_tree() and paused,"Practice HUD Bag button is disconnected")
		menu.close_menu()
		check(not paused and not root.get_node("SceneTransition").is_input_blocking(),"Input overlay/pause was not released")
		lab.queue_free()
		await process_frame
		await process_frame
	print("Practice input smoke: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame

func capture(file: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	check(root.get_texture().get_image().save_png(OUT+file)==OK,"Practice capture failed")
