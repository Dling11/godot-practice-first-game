extends "res://tests/sanctuary_refuge_review_smoke.gd"

const EVIDENCE := "res://art_source/review/ui/sanctuary_theme_2026_10_01/"

func _run() -> void:
	root.size = Vector2i(960,540)
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var hub: Node = HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	var study := Study.new()
	study.hub = hub
	hub.add_child(study)
	study.visit_nema()
	await create_timer(.2).timeout
	check(study.dressing.buildings[0].get_node("Art").texture.resource_path.ends_with("orthographic/nema.png"),"Nema still uses rejected perspective")
	check(study.dressing.buildings[1].get_node("Art").texture.resource_path.ends_with("orthographic/umi.png"),"Umi still uses rejected perspective")
	for building in study.dressing.buildings:
		var approach: Vector2 = building.get_node("Approach").global_position
		check(not _blocked(building.get_world_2d().direct_space_state,approach),"Corrected house approach is blocked")
		check(study.ground._route_distance(approach) <= 8,"Corrected house entrance is disconnected from its garden path")
	var hud: CombatHUD = hub.combat_hud
	var frame: Control = hud.get_node("CompactSanctuaryFrame")
	var slot := hud.get_skill_slot(1)
	check(frame.visible and frame.size.y <= 68 and not hud.get_node("EclipseFrame").visible,"Action frame did not get smaller")
	check(slot.size == Vector2(46,44) and slot.ability_icon.size == Vector2(22,22),"Compact action bar shrinks readable skill controls")
	check(frame.get_global_rect().encloses(hud.get_node("ActionTray").get_global_rect()),"Compact frame does not enclose live controls")
	check(study.town_map.mini.visible and not study.town_map.panel.visible,"Persistent minimap is absent")
	var mini_rect: Rect2 = study.town_map.mini.get_global_rect()
	check(mini_rect.position.x >= 740 and mini_rect.end.x <= 960 and mini_rect.position.y >= 44 and mini_rect.end.y < 230,"Minimap is not safely docked top-right")
	await capture("nema_native.png")
	study.visit_umi()
	await create_timer(.2).timeout
	await capture("umi_native.png")
	await click_at(study.town_map.mini.get_global_rect().get_center())
	check(study.town_map.panel.visible and not study.town_map.mini.visible,"Clicking minimap does not expand directory")
	check(study.town_map.panel.get_global_rect().end.y < frame.get_global_rect().position.y,"Directory covers action controls")
	await capture("map_directory.png")
	var point: Vector2 = study.town_map.drawing.map_point(study.eira_review.npc.global_position)
	await click_at(study.town_map.drawing.global_position+point)
	check(study.town_map.selected_id == "eira" and study.town_map.mini.visible and study.beacons[1].selected,"Map landmark click failed to guide to Eira")
	study.visit_eira()
	await create_timer(.2).timeout
	var interact := InputEventAction.new()
	interact.action = &"player_interact"
	interact.pressed = true
	root.push_input(interact)
	await process_frame
	check(hub.dialogue_panel.visible and not study.town_map.mini.visible and not study._panel.visible,"Review overlays obscure dialogue")
	_check_modal(hub.dialogue_panel)
	await capture("eira_dialogue.png")
	hub.dialogue_panel.close_dialogue(true)
	await process_frame
	check(hub.character_menu.visible,"Eira no longer opens skills")
	_check_modal(hub.character_menu)
	await capture("eira_skills.png")
	hub.character_menu.close_menu()
	hub.character_menu._show_page(&"gear",false)
	hub.character_menu.open_menu()
	await process_frame
	_check_modal(hub.character_menu)
	check(not study._panel.visible,"Study controls cover inventory header")
	await capture("inventory.png")
	hub.character_menu.close_menu()
	for recipe in [[hub.rootforge_menu,"nema_crafting.png"],[hub.umi_exchange_menu,"umi_exchange.png"],[hub.expedition_menu,"expeditions.png"],[hub.get_node("UI/PauseMenu"),"pause.png"]]:
		recipe[0].open_menu()
		await process_frame
		_check_modal(recipe[0])
		if recipe[0] == hub.rootforge_menu:
			var scroll: ScrollContainer = hub.rootforge_menu.get_node("Panel/Margin/Root/BodyScroll")
			scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
			await process_frame
			check(scroll.get_global_rect().encloses(hub.rootforge_menu.primary_action_button.get_global_rect()),"Craft action is unreachable in scrolling recipe body")
			hub.rootforge_menu.recipe_buttons.back().grab_focus()
			await process_frame
			check(scroll.get_global_rect().encloses(hub.rootforge_menu.recipe_buttons.back().get_global_rect()),"Last recipe cannot be reached by keyboard")
		check(not study.town_map.mini.visible and not study._panel.visible,"A map/control overlay covers a service modal")
		await capture(recipe[1])
		recipe[0].close_menu()
	await create_timer(.2).timeout
	check(study.town_map.mini.visible,"Map did not return before direct collection opening")
	var library: Node = hub.get_node("World/Actors/Player/KingSkillLibrary")
	library.open_collection(true)
	await process_frame
	var collection_panel: PanelContainer
	for child in library._collection.get_children():
		if child is PanelContainer: collection_panel = child
	check(collection_panel != null and collection_panel.get_theme_stylebox("panel") is StyleBoxTexture,"Technique collection escaped shared generated theme")
	check(not study._panel.visible and not study.town_map.mini.visible,"Study controls or minimap cover technique collection")
	await capture("technique_collection.png")
	library._collection._close()
	collection_panel = null
	await process_frame
	await create_timer(.2).timeout
	check(study.town_map.mini.visible and study._panel.visible,"Closing modals fails to restore map/review controls")
	# Verify the compact frame did not consume actual HUD mouse input.
	var player: Player = hub.get_node("World/Actors/Player")
	player.position = Vector2(576,688)
	await click_at(hud.dash_slot.activation_button.get_global_rect().get_center())
	check(player.evade_component.is_dashing(),"Compact HUD breaks real dash clicking")
	player.evade_component.cancel_evade()
	study.set_review_enabled(false)
	check(hud.get_node("EclipseFrame").visible and not frame.visible and hud.get_node("ActionTray").offset_top == -75,"Comparison fails to restore original HUD")
	for record in study.interface_review._modals:
		check(record.node.theme == record.theme,"Comparison leaves a new modal theme behind")
	check(not study.town_map.mini.visible,"Comparison retains study minimap")
	study.set_review_enabled(true)
	study.set_overview(true)
	await create_timer(.2).timeout
	await capture("town_overview.png")
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"UI review permits saves")
	interact = null
	hub.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("SANCTUARY_INTERFACE: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _check_modal(modal: Control) -> void:
	var panel: Control = modal.get_node("Panel")
	check(panel.get_theme_stylebox("panel") is StyleBoxTexture,"Modal lacks generated frame: "+modal.name)
	check(Rect2(Vector2.ZERO,Vector2(960,540)).encloses(panel.get_global_rect()),"Modal extends past viewport: "+modal.name)

func click_at(point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(EVIDENCE)
	check(root.get_texture().get_image().save_png(EVIDENCE+file) == OK,"Capture failed")
