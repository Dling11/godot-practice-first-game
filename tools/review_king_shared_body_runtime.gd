extends "res://tests/sanctuary_test_base.gd"

## Actual equipped Player render, followed by each of the shared gait keys.
const PLAYER = preload("res://entities/player/player.tscn")
const ITEMS := [preload("res://data/items/equipment/king_signature_sword.tres"),preload("res://data/items/equipment/king_iron_beard_axe.tres"),preload("res://data/items/equipment/king_royal_greatsword_v2.tres"),preload("res://data/items/equipment/king_twinsteel.tres")]
const OUT := "res://art_source/review/combat/king_body_consistency_2026_10_11/"
const REFERENCE := "res://art_source/reference/characters/king/body_library_v1/"
const LIB := "res://assets/characters/playable/king/body_library/v1/"
const DIRECTIONS := [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]
const NAMES := ["left","right","up","down"]
var actors: Array[Player] = []

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://king_body_runtime_proof.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	root.size=Vector2i(1360,1100); root.content_scale_size=root.size
	RenderingServer.set_default_clear_color(Color("243038"))
	_title("SAME KING / EQUIPPED IN THE REAL PLAYER\nSword - Axe - Greatsword - Dual swords; identical camera scale",Vector2(25,12))
	for row in 4:
		for column in 4:
			var actor: Player = PLAYER.instantiate()
			actor.position=Vector2(170+340*column,240+260*row)
			actor.scale=Vector2.ONE*2
			root.add_child(actor)
			actor.apply_debug_testing_preset()
			actor.set_physics_process(false); actor.set_process_unhandled_input(false)
			check(actor.equip_owned_weapon(ITEMS[row]),"Actual Player cannot equip "+ITEMS[row].display_name)
			actor._set_facing_direction(DIRECTIONS[column])
			var body: AnimatedSprite2D = actor.get_node("VisualRoot/Body")
			body.pause()
			check(body.scale==Vector2(.5,.5) and body.position==Vector2(0,-16),"Base body changes scale/origin")
			var family := actor.get_node("WeaponFamilyPresentation")
			if family.presenter!=null:
				check(family.presenter.scale.abs()==Vector2(.5,.5) and family.presenter.position==body.position,"Family body changes scale/origin")
				family.presenter._rest_timer.stop()
			else:
				check(body.material==null,"Sword has a second outline around its canonical body")
				body.animation=&"hurt_down"
				check(body.material!=null,"Untouched sword reaction lost its legacy outline")
				body.animation=StringName("idle_"+NAMES[column]); body.frame=0; body.pause()
			actors.append(actor)
			_title(ITEMS[row].display_name+" / "+NAMES[column],Vector2(340*column+20,260*row+92))
	await process_frame
	await _capture(OUT+"equipped_ready.png")
	for key in 8:
		for index in actors.size():
			var actor: Player = actors[index]
			var family := actor.get_node("WeaponFamilyPresentation")
			if family.presenter!=null:
				family.presenter.select_clip(ITEMS[index/4].weapon_definition.family_presentation.run_for(DIRECTIONS[index%4]))
				family.presenter.set_pose(key)
			else:
				var body: AnimatedSprite2D = actor.get_node("VisualRoot/Body")
				body.animation=StringName("walk_"+NAMES[index%4]); body.frame=key; body.pause()
		await _capture(OUT+"equipped_walk_"+str(key)+".png")
	for actor in actors: actor.queue_free()
	await process_frame
	for child in root.get_children():
		if child is Label: child.queue_free()
	await process_frame
	_title("KING / COMPLETE BODY REFERENCE V1\nFrozen native pixels; weapons and effects excluded; 192 x 128 cells / half-scale in game",Vector2(25,12))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REFERENCE))
	FileAccess.open(REFERENCE+".gdignore",FileAccess.WRITE).store_string("")
	for column in 4:
		var view: String = "side" if column<2 else NAMES[column]
		var ready: Image = load(LIB+view+"_ready_body.png").get_image().get_region(Rect2i(0,0,192,128))
		if column==0: ready.flip_x()
		_title(NAMES[column].to_upper()+" / ready",Vector2(340*column+25,106))
		_sprite(ready,Vector2(340*column+170,260),3)
		ready.save_png(REFERENCE+NAMES[column]+"_ready.png")
		for key in 8:
			var walk: Image = load(LIB+view+"_run_body.png").get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
			if column==0: walk.flip_x()
			var spot := Vector2(340*column+85+170*(key%2),470+165*(key/2))
			_sprite(walk,spot,2)
			_title("walk "+str(key+1),spot+Vector2(-50,56))
	await _capture(REFERENCE+"turnaround_and_walk.png")
	FileAccess.open(OUT+"runtime_body_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"Actual Player equip/scale/origin and canonical outline, four-facing native standing and gait captures"},"\t")+"\n")
	print("KING_BODY_RUNTIME checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _title(value: String,spot: Vector2) -> void:
	var label := Label.new(); label.text=value; label.position=spot; root.add_child(label)

func _sprite(body: Image,spot: Vector2,zoom: float) -> void:
	var sprite := Sprite2D.new(); sprite.texture=ImageTexture.create_from_image(body)
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position=spot; sprite.scale=Vector2.ONE*zoom; root.add_child(sprite)

func _capture(path: String) -> void:
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(path)==OK,"Native body capture failed: "+path)
