extends SceneTree
const OUTPUT := "res://art_source/review/combat/king_dual_polish_2026_10_05/"
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var records: Array[Dictionary] = []
	var specs := [
		["axe_side","res://assets/characters/playable/king/axe_proof_v3/carry.tres"],
		["greatsword_side","res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres"],
		["greatsword_up","res://assets/characters/playable/king/greatsword_readability/up/idle.tres"],
		["greatsword_down","res://assets/characters/playable/king/greatsword_readability/down/idle.tres"],
		["dual_side","res://assets/characters/playable/king/dual_twinsteel/idle.tres"],
		["dual_up","res://assets/characters/playable/king/dual_twinsteel/up/idle.tres"],
		["dual_down","res://assets/characters/playable/king/dual_twinsteel/down/idle.tres"],
		["dual_run_side","res://assets/characters/playable/king/dual_twinsteel/run.tres"],
		["dual_run_up","res://assets/characters/playable/king/dual_twinsteel/up/run.tres"],
		["dual_run_down","res://assets/characters/playable/king/dual_twinsteel/down/run.tres"]]
	for spec in specs:
		if not ResourceLoader.exists(spec[1]): continue
		var clip: Resource = load(spec[1])
		var poses: Array[Dictionary] = []
		for key in clip.pose_count:
			var cell := Rect2i(key%clip.columns*clip.cell_size.x,key/clip.columns*clip.cell_size.y,clip.cell_size.x,clip.cell_size.y)
			var image: Image = clip.body_atlas.get_image().get_region(cell)
			var rect := image.get_used_rect()
			poses.append({"key":key,"used":var_to_str(rect),"height":rect.size.y,"world_height":rect.size.y*.5,"head":var_to_str(clip.identity_regions[key]) if clip.identity_regions.size()>key else "unregistered","main_hand":var_to_str(clip.primary_hands[key])})
		records.append({"label":spec[0],"path":spec[1],"poses":poses})
		print(spec[0],": ",poses[0])
	var filename := "scale_after.json" if "--after" in OS.get_cmdline_user_args() else "scale_before.json"
	FileAccess.open(OUTPUT+filename,FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	quit()
