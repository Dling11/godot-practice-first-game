extends "res://tests/sanctuary_test_base.gd"

const PLAYER = preload("res://entities/player/player.tscn")
const ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const OUT := "res://art_source/review/combat/king_back_attachment_2026_10_05/"

func _run() -> void:
	if DisplayServer.get_name()=="headless": quit(1); return
	root.size = Vector2i(1200,1000)
	root.content_scale_size = root.size
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("WeaponInventory").acquire_weapon(ITEM)
	var bg := ColorRect.new()
	bg.size = root.size
	bg.color = Color("202b30")
	root.add_child(bg)
	var actors: Array[Player] = []
	for index in 4:
		var actor: Player = PLAYER.instantiate()
		actor.position = [Vector2(280,300),Vector2(880,300),Vector2(280,800),Vector2(880,800)][index]
		actor.scale = Vector2.ONE*4
		root.add_child(actor)
		actor.set_physics_process(false)
		actor.set_process_unhandled_input(false)
		check(actor.equip_owned_weapon(ITEM),"Cannot equip carry review")
		actor._set_facing_direction([Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN][index])
		actors.append(actor)
	paused = true
	var reports: Array[Dictionary] = []
	for key in 8:
		for index in 4:
			var family := actors[index].get_node("WeaponFamilyPresentation")
			family.presenter.select_clip(family.profile.run_for(actors[index].facing_direction))
			family.presenter.set_pose(key)
			var clip: Resource = family.presenter.definition
			var image: Image = family.presenter.body_sprite.texture.get_image()
			var p := Vector2i(clip.primary_hands[key])
			reports.append({"direction":index,"pose":key,"primary":var_to_str(p),"grip_color":var_to_str(image.get_pixelv(p)),"stowed":clip.stowed_poses[key]>0,"weapon_behind_body":clip.weapon_behind_body[key]>0})
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OUT+"carry_%d.png"%key)
	FileAccess.open(OUT+"carry_inspection.json",FileAccess.WRITE).store_string(JSON.stringify(reports,"\t")+"\n")
	print("DIRECTIONAL_CARRY captured8 native poses")
	quit(1 if failures else 0)
