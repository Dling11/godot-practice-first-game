extends SceneTree

const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const WEAPON = preload("res://data/weapons/king_royal_greatsword_v2.tres")
const EdgeAudit = preload("res://tools/audit_greatsword_v2_source_edges.gd")
const OUT := "res://art_source/review/combat/king_greatsword_v2_vertical_impact_2026_10_07/"
var checks := 0
var failures := 0
var scene: Node2D

func _initialize() -> void:
	_run.call_deferred()

func check(value: bool,message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _run() -> void:
	root.size = Vector2i(1280,1200)
	root.content_scale_size = root.size
	RenderingServer.set_default_clear_color(Color("202c32"))
	scene = Node2D.new()
	root.add_child(scene)
	var profile := WEAPON.family_presentation
	var facing_index := 0
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		var entry: Resource = profile.attack_for(direction)
		var clips: Array[Resource] = [entry]
		clips.append_array(entry.follow_up_clips)
		for cut in 4:
			var clip: Resource = clips[cut]
			check(clip.has_valid_layout(),"Invalid cardinal layout")
			check(clip.pose_count==16,"Legacy vertical attack still installed")
			check(clip.weapon_texture.get_size()==Vector2(30,140),"Steel changed")
			var body: Image = clip.body_atlas.get_image()
			var hand: Image = clip.hand_atlas.get_image()
			for key in 16:
				var cel := body.get_region(Rect2i(key%4*192,key/4*128,192,128))
				var mask := hand.get_region(Rect2i(key%4*192,key/4*128,192,128))
				var bounds := cel.get_used_rect()
				check(bounds.position.x>20 and bounds.end.x<172 and bounds.position.y>3 and bounds.end.y<125,"Neighbor body fragment or crop")
				check(cel.get_pixelv(Vector2i(clip.primary_hands[key].round())).a>.65,"Primary grip not on drawn body: "+str(direction)+" / "+str(cut)+" / "+str(key)+" / "+str(clip.primary_hands[key]))
				if clip.single_hand_poses[key]==0:
					var palm := Vector2i(clip.secondary_hands[key].round())
					var c := (mask if clip.hands_are_occluded(key) else cel).get_pixelv(palm)
					check(c.a>.65 and c.r>c.g*1.3 and c.g>c.b*1.2,"Offhand not on drawn glove")
				if direction==Vector2.UP and cut==3:
					var occluded := key in [4,5,6,7,8,9,10,11,13,14]
					check(clip.hands_are_occluded(key)==occluded,"Rear hand occlusion leaks into load/carry")
					if occluded:
						var p := Vector2i(clip.primary_hands[key].round())
						var c := cel.get_pixelv(p)
						check(c.a>.65 and c.r<c.g*1.3,"Front glove still painted over rear torso")
						var source_glove := mask.get_pixelv(p)
						check(source_glove.a>.65 and source_glove.r>source_glove.g*1.3,"Occluded grip lost its real source palm")
				check(mask.get_used_rect().size.x<60 and mask.get_used_rect().size.y<65,"Unrelated image in hand overlay")
				if cut!=2 and absf(direction.y)>0 and key not in [0,12,15]:
					_check_connected_head(cel,clip,key)
			if cut<3:
				var final_cel := body.get_region(Rect2i(576,384,192,128))
				var next_cel: Image = clips[cut+1].body_atlas.get_image().get_region(Rect2i(0,0,192,128))
				check(final_cel.get_data()==next_cel.get_data(),"Queued body endpoint jumps")
			var node := Node2D.new()
			node.position = Vector2(160+cut*320,160+facing_index*300)
			scene.add_child(node)
			var attack := MeleeAttackComponent.new()
			node.add_child(attack)
			var presenter := Presenter.new()
			presenter.configure(clip,attack,false)
			presenter.scale = Vector2(-1.4 if direction==Vector2.LEFT else 1.4,1.4)
			node.add_child(presenter)
			for key in 16:
				presenter.set_pose(key)
				check(presenter.hand_sprite.visible==(not clip.hands_are_occluded(key)),"Renderer ignores rear hand occlusion")
			presenter.set_pose(4 if cut==3 else 6)
			var bounds := _rendered_bounds(presenter.body_sprite).merge(_rendered_bounds(presenter.weapon_sprite))
			node.position += Vector2(160+cut*320,160+facing_index*300)-bounds.get_center()
			check(presenter._body_frame.filter_clip and presenter._hand_frame.filter_clip,"Atlas sampler can bleed into neighbors")
			var label := Label.new()
			label.position = Vector2(20+cut*320,12+facing_index*300)
			label.add_theme_font_size_override("font_size",13)
			label.text = ["RIGHT","LEFT","UP / BACK","DOWN / FRONT"][facing_index]+" · "+["FRONT","RETURN","SPIN","LAND"][cut]
			scene.add_child(label)
		facing_index += 1
	var atlas: Image = profile.swing_atlas.get_image()
	for row in 4:
		for frame in 4:
			var cell := atlas.get_region(Rect2i(frame*192,row*192,192,192))
			var bounds := cell.get_used_rect()
			check(bounds.position.x>=16 and bounds.position.y>=16 and bounds.end.x<=176 and bounds.end.y<=176,"White slash crosses its source cell")
	check(is_equal_approx(WEAPON.combo.hitbox_shapes[2].radius,82),"Spin authority did not expand")
	check(is_equal_approx(WEAPON.combo.contacts[2],.28),"Spin contact not slowed")
	for path in ["vertical_slash.png","vertical_landing.png"]:
		var vertical: Texture2D = load("res://assets/characters/playable/king/greatsword_front_combo_preview/"+path)
		check(vertical.get_size()==Vector2(768,384),"Incomplete directional impact atlas")
		for row in 2:
			for key in 4:
				var cel := vertical.get_image().get_region(Rect2i(key*192,row*192,192,192))
				var bounds := cel.get_used_rect()
				check(bounds.position.x>=15 and bounds.position.y>=15 and bounds.end.x<=177 and bounds.end.y<=177,"Vertical impact frame cropped or contaminated")
				var magenta := 0
				for y in bounds.size.y:
					for x in bounds.size.x:
						var c := cel.get_pixelv(bounds.position+Vector2i(x,y))
						if c.a>.65 and c.r>.65 and c.b>.4 and c.g<.45: magenta += 1
				check(magenta==0,"Vertical registration guide leaked into gameplay")
	var jump_release := atlas.get_region(Rect2i(384,576,192,192))
	for part in EdgeAudit.components(jump_release):
		var bounds: Rect2i = str_to_var(part.bounds)
		check(bounds.position.x>=36,"Neighboring jump ribbon tip still appears as a left-edge shard")
	# A neighboring boot used to survive as a bridge in return-load key2.
	var side: Resource = profile.attack_for(Vector2.RIGHT).follow_up_clips[0]
	for key in [0,1,2,3]:
		var cel: Image = side.body_atlas.get_image().get_region(Rect2i(key%4*192,0,192,128))
		var bounds := cel.get_used_rect()
		var first := -1
		for y in range(bounds.position.y,bounds.end.y):
			if cel.get_pixel(bounds.position.x,y).a>.65: first = y; break
		check(first>bounds.position.y+24,"Return load still has a tall neighboring boot edge")
	if DisplayServer.get_name()!="headless":
		await process_frame
		await RenderingServer.frame_post_draw
		DirAccess.make_dir_recursive_absolute(OUT)
		root.get_texture().get_image().save_png(OUT+"cardinal_contacts.png")
		await _capture_rear_comparison()
	FileAccess.open(OUT+"cardinal_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"all directional runtime clips, real palms, isolated atlas regions, exact queue boundaries, padded independent white FX, native renderer contact gallery"},"\t"))
	print("V2_CARDINAL checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)

func _capture_rear_comparison() -> void:
	scene.hide()
	root.size = Vector2i(640,300)
	root.content_scale_size = root.size
	var current: Resource = WEAPON.family_presentation.attack_for(Vector2.UP).follow_up_clips[2]
	var snapshot := "res://art_source/archive/greatsword_v2_before_rear_cleanup_2026_10_07/assets/characters/playable/king/greatsword_front_combo_preview/up/"
	var previous: Resource = load(snapshot+"jump.tres").duplicate()
	var old_body := Image.new()
	old_body.load_png_from_buffer(FileAccess.get_file_as_bytes(snapshot+"jump_body.png"))
	var old_hand := Image.new()
	old_hand.load_png_from_buffer(FileAccess.get_file_as_bytes(snapshot+"jump_hands.png"))
	previous.body_atlas = ImageTexture.create_from_image(old_body)
	previous.hand_atlas = ImageTexture.create_from_image(old_hand)
	for index in 2:
		var node := Node2D.new()
		node.position = Vector2(160+index*320,148)
		root.add_child(node)
		var attack := MeleeAttackComponent.new()
		node.add_child(attack)
		var presenter := Presenter.new()
		presenter.configure(previous if index==0 else current,attack,false)
		presenter.scale = Vector2.ONE*3.5
		node.add_child(presenter)
		presenter.set_pose(6)
		presenter.weapon_rig.hide() # Body-only comparison isolates rear anatomy.
		var label := Label.new()
		label.position = Vector2(38+index*320,20)
		label.text = "PREVIOUS LANDING" if index==0 else "CORRECTED REAR LANDING"
		label.add_theme_font_size_override("font_size",15)
		root.add_child(label)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"rear_landing_before_after.png")

func _rendered_bounds(sprite: Sprite2D) -> Rect2:
	var rectangle := Rect2(sprite.texture.get_image().get_used_rect())
	if sprite.centered: rectangle.position -= sprite.texture.get_size()*.5
	var result := Rect2(sprite.global_transform*rectangle.position,Vector2.ZERO)
	for point in [Vector2(rectangle.end.x,rectangle.position.y),rectangle.end,Vector2(rectangle.position.x,rectangle.end.y)]:
		result = result.expand(sprite.global_transform*point)
	return result

func _check_connected_head(body: Image,clip: Resource,key: int) -> void:
	var seed := Vector2i(clip.primary_hands[key].round())
	var seen := PackedByteArray()
	seen.resize(192*128)
	seen[seed.y*192+seed.x] = 1
	var todo := PackedInt32Array([seed.y*192+seed.x])
	var cursor := 0
	while cursor<todo.size():
		var id := todo[cursor]
		cursor += 1
		for dy in range(-1,2):
			for dx in range(-1,2):
				var point := Vector2i(id%192+dx,id/192+dy)
				if point.x<0 or point.y<0 or point.x>=192 or point.y>=128: continue
				var next := point.y*192+point.x
				if seen[next] or body.get_pixelv(point).a<.65: continue
				seen[next] = 1
				todo.append(next)
	var head := Rect2i(clip.identity_regions[key])
	var total := 0
	var connected := 0
	for y in range(head.position.y,head.end.y):
		for x in range(head.position.x,head.end.x):
			if body.get_pixel(x,y).a<.65: continue
			total += 1
			if seen[y*192+x]: connected += 1
	check(total>30 and float(connected)/maxi(total,1)>.9,"Vertical head/neck is disconnected at "+str(key))
	var second := Vector2i(clip.secondary_hands[key].round())
	check(seen[second.y*192+second.x]>0,"Vertical rear glove disconnected from chest")
