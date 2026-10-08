extends "res://tests/king_axe_cardinal_smoke.gd"

const Identity = preload("res://tools/king_native_identity.gd")
const TARGETS := [preload("res://assets/characters/playable/king/axe_identity_lock/presentation.tres"),preload("res://assets/characters/playable/king/dual_identity_lock/presentation.tres")]
const GREAT_GAIT = preload("res://assets/characters/playable/king/greatsword_readability/side/run.tres")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var identity := Identity.new()
	var measured: Array[Dictionary] = []
	for profile in TARGETS:
		check(profile.is_valid_profile(),"Identity-lock family cannot be selected")
		for direction in [Vector2.UP,Vector2.DOWN,Vector2.RIGHT]:
			var base: Resource = profile.attack_for(direction)
			var clips: Array = [base]+Array(base.follow_up_clips)+[profile.idle_for(direction),profile.run_for(direction)]
			for clip in clips:
				if not clip.resource_path.contains("identity_lock/"): continue
				for key in clip.pose_count:
					var body: Image = clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
					var head := Rect2i(clip.identity_regions[key])
					var used := body.get_used_rect()
					check(used.position.x>15 and used.position.y>5 and used.end.x<177 and used.end.y<120,"Body or foreign source fragment reaches cell edge")
					check(anatomy_connected(body,Vector2i(head.get_center()),head),"Disconnected head/arms/torso in "+clip.resource_path+"/"+str(key))
					var leaked_guide := false
					for y in range(used.position.y,used.end.y):
						for x in range(used.position.x,used.end.x):
							leaked_guide=leaked_guide or identity.guide(body.get_pixel(x,y))
					check(not leaked_guide,"Technical guide color escaped into game")
					var palms := [clip.primary_hands[key]]
					if clip.offhand!=null and clip.offhand.visible_poses[key]>0: palms.append(clip.offhand.hands[key])
					if clip.released_poses[key]==0 and clip.stowed_poses[key]==0 and not clip.hands_are_occluded(key):
						for palm in palms:
							var c := body.get_pixelv(Vector2i(palm.round()))
							check(c.a>.65 and c.r>.18 and c.r<.8 and c.r>c.g*1.35 and c.g>c.b*1.25,"Visible weapon grip misses a real leather palm: "+clip.resource_path+"/"+str(key))
					measured.append({"path":clip.resource_path,"key":key,"body":var_to_str(used),"head":var_to_str(head)})
	var dual_side: Resource = TARGETS[1].run_for(Vector2.RIGHT)
	check(same_opaque(dual_side.body_atlas.get_image(),GREAT_GAIT.body_atlas.get_image()),"Dual side gait differs from accepted Greatsword body frames")
	for profile in TARGETS:
		var view := "down"
		var ready: Resource = profile.idle_for(Vector2.DOWN)
		var expected := identity.native_ref(view)
		var ref_head: Rect2i = expected.head
		var body: Image = ready.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		var head := Rect2i(ready.identity_regions[0])
		var exact := 0
		var tested := 0
		for y in range(4,18):
			for x in ref_head.size.x:
				var c: Color = expected.image.get_pixelv(ref_head.position+Vector2i(x,y))
				if c.a<.65: continue
				tested+=1
				if body.get_pixelv(head.position+Vector2i(x,y))==c: exact+=1
		check(tested>200 and exact==tested,"Front ready crown has changed native pixels or grown")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://art_source/review/combat/king_dual_identity_lock_2026_10_08/"))
	FileAccess.open("res://art_source/review/combat/king_dual_identity_lock_2026_10_08/anatomy_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"poses":measured},"\t")+"\n")
	print("KING_IDENTITY_LOCK checks=%d failures=%d poses=%d"%[checks,failures,measured.size()])
	quit(1 if failures else 0)
