extends SceneTree

## Run with the Compatibility renderer, not --headless: this checks GPU pixels.
const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
const OUT := "res://art_source/review/characters/king/earthsplitter_bleed_2026_09_14/"
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Use --rendering-method gl_compatibility to validate rendered atlas edges.")
		quit(1)
		return
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	DirAccess.make_dir_recursive_absolute(OUT)
	var lab := Lab.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	var actor: Player = lab.player
	var review: Node = lab.get_node("KingSpellwardReview")
	review.open_review()
	review.toggle_earthsplitter_review()
	lab.clear_simulation()
	actor.set_physics_process(false)
	var ability: AbilityComponent = actor.ability_1_component
	ability.request_cast_at(actor.global_position+Vector2.UP*164.0,100)
	ability.set_physics_process(false)
	var visual: Node2D = ability._visual
	visual.set_physics_process(false)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1024,1024)
	viewport.transparent_bg = true
	viewport.snap_2d_transforms_to_pixel = true
	viewport.snap_2d_vertices_to_pixel = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var sword: Sprite2D = visual._sword
	sword.reparent(viewport,false)
	sword.position = Vector2(512,512)
	sword.scale = Vector2.ONE*.7
	sword.rotation = PI*.25
	sword.hide()
	var legacy := Sprite2D.new()
	legacy.texture = sword.texture
	legacy.hframes = 4
	legacy.vframes = 4
	legacy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	legacy.position = sword.position
	legacy.scale = sword.scale
	legacy.rotation = sword.rotation
	viewport.add_child(legacy)
	await process_frame
	await RenderingServer.frame_post_draw
	var before := viewport.get_texture().get_image()
	before.save_png(OUT+"before.png")
	_check(before.get_region(Rect2i(0,514,1024,510)).get_used_rect().has_area(), "Positive control failed to reproduce the distant lower-left atlas sliver")
	legacy.hide()
	sword.show()
	for zoom in [.7,.84]:
		for phase in [0.0,.51]:
			sword.position = Vector2(512,512)+Vector2.ONE*phase
			sword.scale = Vector2.ONE*zoom
			for index in 7:
				visual._set_sword_frame(index)
				await process_frame
				await RenderingServer.frame_post_draw
				var rendered := viewport.get_texture().get_image()
				# These seven drawings are entirely above the contact at this rotation.
				_check(not rendered.get_region(Rect2i(0,514,1024,510)).get_used_rect().has_area(), "Stray pixels below sword frame %s at scale %s / phase %s" % [index,zoom,phase])
				if index==0 and is_zero_approx(phase) and is_equal_approx(zoom,.7):
					rendered.save_png(OUT+"after.png")
	ability.cancel_cast()
	review.earthsplitter_review.set_enabled(false)
	viewport.queue_free()
	lab.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
	print("EARTHSPLITTER_ATLAS_RENDER_CHECKS=",checks," FAILURES=",failures)
	quit(0 if failures==0 else 1)
