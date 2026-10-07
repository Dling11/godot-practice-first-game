extends SceneTree

const PROFILES := [preload("res://data/weapons/families/twinsteel_v2/presentation.tres"),preload("res://data/weapons/families/royal_greatsword_v2/presentation.tres")]
const OUT := "res://art_source/review/combat/king_cardinal_proportions_2026_10_07/"
var checks := 0
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(value: bool,message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _run() -> void:
	for family in 2:
		var profile: Resource = PROFILES[family]
		for direction in [Vector2.UP,Vector2.DOWN]:
			var entry: Resource = profile.attack_for(direction)
			var clips: Array[Resource] = [profile.idle_for(direction),profile.run_for(direction),entry]
			clips.append_array(entry.follow_up_clips)
			for index in clips.size():
				var clip: Resource = clips[index]
				check(clip.has_valid_layout(),"Invalid cardinal body/landmarks")
				for key in clip.pose_count:
					var image: Image = clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
					var rect := image.get_used_rect()
					var head := Rect2i(clip.identity_regions[key])
					check(rect.position.x>15 and rect.end.x<177 and rect.position.y>3 and rect.end.y<120,"Cardinal body clipped")
					check(head.size.x in [25,27] and head.size.y in [24,29],"Head density changes within cardinal motion")
					if index==0 and key==0: check(absi(rect.size.y-54)<=1,"Vertical ready differs from approved54px side body height")
					if index==1 and key==0: check(absi(rect.size.y-(51 if family==0 else 56))<=1,"Vertical run baseline changes actor size")
					var head_count := 0
					var linked := connected(image,Vector2i(clip.primary_hands[key].round()) if clip.released_poses[key]==0 else Vector2i(head.get_center()))
					var head_linked := 0
					for y in range(head.position.y,head.end.y):
						for x in range(head.position.x,head.end.x):
							if image.get_pixel(x,y).a<.65: continue
							head_count += 1
							if linked[y*192+x]>0: head_linked += 1
					check(head_count>30 and float(head_linked)/maxi(1,head_count)>.90,"Head/neck disconnects: "+str(family)+" "+str(direction)+" "+str(index)+"/"+str(key))
					if clip.released_poses[key]==0 and not clip.hands_are_occluded(key):
						check(image.get_pixelv(Vector2i(clip.primary_hands[key].round())).a>.65,"Main grip floats off body")
						if clip.offhand!=null and clip.offhand.visible_poses[key]>0:
							var palm := Vector2i(clip.offhand.hands[key].round())
							check(image.get_pixelv(palm).a>.65 and linked[palm.y*192+palm.x]>0,"Far palm detaches from torso")
	FileAccess.open(OUT+"proportion_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"Installed vertical height, fixed head density, complete body, connected palms/head"},"\t")+"\n")
	print("CARDINAL_PROPORTIONS checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func connected(image: Image,seed: Vector2i) -> PackedByteArray:
	var seen := PackedByteArray()
	seen.resize(192*128)
	if not Rect2i(0,0,192,128).has_point(seed) or image.get_pixelv(seed).a<.65: return seen
	var queue := PackedVector2Array([Vector2(seed)])
	seen[seed.y*192+seed.x] = 1
	var cursor := 0
	while cursor<queue.size():
		var point := Vector2i(queue[cursor])
		cursor += 1
		for dy in range(-1,2):
			for dx in range(-1,2):
				var next := point+Vector2i(dx,dy)
				if not Rect2i(0,0,192,128).has_point(next): continue
				if seen[next.y*192+next.x]>0 or image.get_pixelv(next).a<.65: continue
				seen[next.y*192+next.x] = 1
				queue.append(Vector2(next))
	return seen
