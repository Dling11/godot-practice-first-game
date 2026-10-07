extends SceneTree

## Owner drawing reference: assemble installed cels through the real presenter.
## No gameplay resources, save data or runtime artwork are written.
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const PROFILE = preload("res://data/weapons/families/twinsteel_prototype/presentation.tres")
const OUT := "res://art_source/review/combat/king_dual_combo_drawing_2026_10_06/"
const CANVAS := Vector2i(320,256)
const ENLARGEMENT := 2
const VIEWS := [
	["right",Vector2.RIGHT,"R"], ["left",Vector2.LEFT,"L"],
	["up",Vector2.UP,"U"], ["down",Vector2.DOWN,"D"]]
const CUTS := ["double_thrust","crosscut","return_cut","hopping_spin","springing_x"]
var evidence_path := OUT

func _initialize() -> void:
	call_deferred("export_frames")

func export_frames() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("Use native rendering for the assembled Twinsteel frames")
		quit(1)
		return
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://art_source/review/"):
			evidence_path=argument.trim_prefix("--output=").trim_suffix("/")+"/"
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size=Vector2i(640,240)
	root.content_scale_size=root.size
	var status := Label.new()
	status.text="Exporting installed Twinsteel poses for drawing..."
	status.position=Vector2(20,20)
	root.add_child(status)
	var attack := MeleeAttackComponent.new()
	root.add_child(attack)
	var viewport := SubViewport.new()
	viewport.size=CANVAS
	viewport.transparent_bg=true
	viewport.disable_3d=true
	viewport.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var records: Array[Dictionary] = []
	var captures: Array[Image] = []
	var union := Rect2i()
	for spec in VIEWS:
		var facing: Vector2 = spec[1]
		var first: Resource = PROFILE.attack_for(facing)
		var clips: Array[Resource] = [first]
		clips.append_array(first.follow_up_clips)
		assert(clips.size()==5)
		for cut in clips.size():
			var clip: Resource = clips[cut]
			assert(clip.has_valid_layout() and clip.pose_count==13)
			var presenter := Presenter.new()
			presenter.position=Vector2(CANVAS)*.5
			assert(presenter.configure(clip,attack,false))
			viewport.add_child(presenter)
			presenter.face_horizontal(-1.0 if facing==Vector2.LEFT else 1.0)
			for key in clip.pose_count:
				presenter.set_pose(key)
				await process_frame
				await RenderingServer.frame_post_draw
				var frame := viewport.get_texture().get_image()
				frame.convert(Image.FORMAT_RGBA8)
				var bounds := frame.get_used_rect()
				assert(bounds.has_area() and bounds.position.x>8 and bounds.position.y>8 and bounds.end.x<CANVAS.x-8 and bounds.end.y<CANVAS.y-8,"Frame is empty or touches the capture edge")
				union=bounds if captures.is_empty() else union.merge(bounds)
				captures.append(frame)
				records.append({
					"id":"%s-A%d-F%02d"%[spec[2],cut+1,key+1],
					"facing":spec[0],"attack_number":cut+1,"attack_name":CUTS[cut],
					"frame_number":key+1,"clip_pose_index":key,"phase":phase_for(clip,key),
					"lift_logical":clip.lift_pixels[key],"source_resource":clip.resource_path,
					"file":"frames/%s/attack_%02d_%s/F%02d.png"%[spec[0],cut+1,CUTS[cut],key+1]})
			presenter.queue_free()
			await process_frame
	# One union crop for the complete pack preserves anchors and relative motion.
	var crop := union.grow(12)
	assert(Rect2i(Vector2i.ZERO,CANVAS).encloses(crop))
	for index in captures.size():
		var frame := captures[index].get_region(crop)
		frame.resize(crop.size.x*ENLARGEMENT,crop.size.y*ENLARGEMENT,Image.INTERPOLATE_NEAREST)
		var destination: String = evidence_path+records[index].file
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(destination.get_base_dir()))
		assert(frame.save_png(destination)==OK)
	var manifest := {
		"date":"2026-10-06","family":"Twinsteel","source_profile":PROFILE.resource_path,
		"renderer":"native Compatibility / installed WeaponFamilyPosePresenter",
		"frames":records,"frame_count":records.size(),"facings":4,"attacks":5,"poses_per_attack":13,
		"native_canvas":[CANVAS.x,CANVAS.y],"uniform_crop":[crop.position.x,crop.position.y,crop.size.x,crop.size.y],
		"export_size":[crop.size.x*ENLARGEMENT,crop.size.y*ENLARGEMENT],
		"nearest_enlargement":ENLARGEMENT,"scale_relative_to_game":4,
		"effects_in_pose_images":false,"runtime_modified":false,
		"continuous_chain_frames":[1,2,3,4,5,6,7,11,12,13],
		"release_frames":[1,2,3,4,5,6,7,8,9,10],
		"limitation":"Authored pose keys, not every interpolated playback image. F01 is the resource opening; actual standalone entry can inherit the preceding rendered idle/run pose."}
	assert(records.size()==260)
	FileAccess.open(evidence_path+"manifest.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	print("TWINSTEEL_DRAWING_FRAMES: ",records.size()," complete native poses / uniform crop ",crop," / export size ",crop.size*ENLARGEMENT)
	viewport.queue_free()
	attack.queue_free()
	await process_frame
	quit()

func phase_for(clip: Resource,key: int) -> String:
	for index in clip.phase_windows.size():
		var window: Vector2 = clip.phase_windows[index]
		if key>=window.x and key<=window.y:
			return ["wind_up","strike","stop_recovery"][index]
	assert(key>=clip.queued_recovery_window.x and key<=clip.queued_recovery_window.y)
	return "combo_link"
