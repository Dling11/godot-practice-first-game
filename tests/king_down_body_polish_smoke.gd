extends "res://tests/king_shared_body_smoke.gd"

## Regression against whole authored cels: no head, torso or grip may drift alone.
const BEFORE := "res://art_source/archive/king_down_body_before_2026_10_11/"
const OUTPUT := "res://art_source/review/combat/king_down_body_polish_2026_10_11/"

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	for family in ["axe","dual"]:
		var path: String = AXE_PROFILE if family=="axe" else DUAL_PROFILE
		var current: Resource = load(path)
		# Archived selectors contain absolute runtime paths. Read the unchanged
		# original contact atlases, not the mutable shared DOWN outputs again.
		var previous: Resource = load(OLD_AXE_PROFILE if family=="axe" else OLD_AXE_PROFILE.replace("iron_beard/","twinsteel_v2/"))
		var old: Resource = previous.attack_for(Vector2.DOWN)
		var first: Resource = current.attack_for(Vector2.DOWN)
		var clips: Array = [first]+Array(first.follow_up_clips)
		var old_clips: Array = [old]+Array(old.follow_up_clips)
		for step in 5:
			var clip: Resource = clips[step]
			var source: Resource = old_clips[step]
			check(clip.has_valid_layout(),"Registered DOWN layout invalid")
			for field in ["phase_windows","queued_recovery_window","pose_weights","lift_pixels","weapon_texture","weapon_primary_grip","weapon_handle_axis"]:
				check(clip.get(field)==source.get(field),"DOWN polish changes phase/lift/steel: "+field)
			for key in 13:
				var endpoint: bool = key==9 or (step==0 and key==0) or (step==4 and key==12)
				var expected_source: Resource = current.idle_for(Vector2.DOWN) if endpoint else (clips[step-1] if key==0 else source)
				var source_key: int = 0 if endpoint else (12 if key==0 else key)
				var shift := Vector2i.ZERO if endpoint or key==0 else DownRegistration.offset(family,step,key)
				var box := Rect2i(key%4*192,key/4*128,192,128)
				var source_box := Rect2i(source_key%4*192,source_key/4*128,192,128)
				for field in ["body_atlas","hand_atlas"]:
					var actual: Image = clip.get(field).get_image().get_region(box)
					var expected: Image = expected_source.get(field).get_image().get_region(source_box)
					check(same_opaque(actual,_translate_cel(expected,shift)),"DOWN polish changed body/mask pixels instead of moving a complete cel: "+family+"/"+str(step)+"/"+str(key)+"/"+field)
				for field in ["primary_hands","secondary_hands"]:
					check(clip.get(field)[key]==expected_source.get(field)[source_key]+Vector2(shift),"DOWN hand axis moves independently of its body")
				var head: Rect2 = clip.identity_regions[key]
				var expected_head: Rect2 = expected_source.identity_regions[source_key]
				expected_head.position+=Vector2(shift)
				check(head==expected_head,"DOWN head changes independently of its complete body")
				var body: Image = clip.body_atlas.get_image().get_region(box)
				check(body.get_used_rect().end.y==95,"DOWN registration lifts soles off their ground plane")
				check(anatomy_connected(body,Vector2i(head.get_center()),Rect2i(head)),"DOWN head/chest/hips disconnect")
				var palms: Array = [clip.primary_hands[key]]
				if family=="dual":
					palms.append(clip.offhand.hands[key])
					for field in ["hands","axes"]: check(clip.offhand.get(field)[key]==expected_source.offhand.get(field)[source_key]+Vector2(shift),"Far blade fails to follow complete body")
				for grip in palms:
					var c := body.get_pixelv(Vector2i(grip.round()))
					check(c.a>.65 and c.r>.18 and c.r>c.g*1.35 and c.g>c.b*1.25,"DOWN blade floats away from its actual glove")
		var master: Resource = load(LIBRARY+"down_relaxed.tres")
		if family=="axe":
			var idle: Resource = current.idle_for(Vector2.DOWN)
			for key in 8:
				var source_key: int = 0 if key<4 else key
				var expected: Image = master.body_atlas.get_image().get_region(Rect2i(source_key%4*192,source_key/4*128,192,128))
				check(same_opaque(idle.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128)),expected),"DOWN axe idle does not reuse the complete relaxed pose")
				check(idle.identity_regions[key]==master.identity_regions[source_key],"DOWN axe idle shifts the head separately")
			check(absf(idle.identity_regions[4].position.y-idle.identity_regions[0].position.y)<=1,"DOWN axe grows when entering folded rest")
	# Every pre-existing asset outside the scoped DOWN siblings/selectors stays exact.
	var protected_count := 0
	var manifest: Array = JSON.parse_string(FileAccess.get_file_as_string(BEFORE+"manifest.json"))
	for record in manifest:
		var path: String = record.path
		if path in [AXE_PROFILE.trim_prefix("res://"),DUAL_PROFILE.trim_prefix("res://"),"tools/build_king_shared_bodies.gd","tests/king_shared_body_smoke.gd"] or path.begins_with("assets/characters/playable/king/shared_bodies/axe/down/"): continue
		check(FileAccess.get_sha256("res://"+path)==record.sha256,"Approved other-direction/reference asset changed: "+path)
		protected_count+=1
	FileAccess.open(OUTPUT+"down_body_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"protected_files":protected_count,"scope":"Complete DOWN cels and both grips shift together without resizing/redrawing; exact ready/queue/release; fixed soles; immutable other views/Greatsword/gaits; axe relaxed rest"},"\t")+"\n")
	print("KING_DOWN_BODY checks=",checks," failures=",failures," protected=",protected_count)
	quit(1 if failures else 0)
