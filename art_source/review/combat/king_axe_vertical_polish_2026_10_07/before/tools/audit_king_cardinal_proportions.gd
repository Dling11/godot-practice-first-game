extends SceneTree

## Compare body pixels without steel/FX hiding the silhouette; never writes art.
const PROFILES := [preload("res://data/weapons/families/twinsteel_v2/presentation.tres"),preload("res://data/weapons/families/royal_greatsword_v2/presentation.tres")]
var output := "res://art_source/review/combat/king_cardinal_proportions_2026_10_07/"
var tag := "before"
var records: Array[Dictionary] = []

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--tag="): tag = arg.trim_prefix("--tag=")
	_run.call_deferred()

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	root.size = Vector2i(1360,740)
	root.content_scale_size = root.size
	RenderingServer.set_default_clear_color(Color("202b30"))
	for family_index in 2:
		var scene := Node2D.new()
		root.add_child(scene)
		var profile: Resource = PROFILES[family_index]
		var family: String = ["dual","greatsword"][family_index]
		label(scene,Vector2(18,10),family.to_upper()+" · "+tag.to_upper()+" · BODY ONLY / SAME PIXEL SCALE")
		for view in 3:
			var direction: Vector2 = [Vector2.RIGHT,Vector2.UP,Vector2.DOWN][view]
			var view_name: String = ["side","up","down"][view]
			var base: Resource = profile.attack_for(direction)
			var clips: Array[Resource] = [profile.idle_for(direction),profile.run_for(direction),base]
			clips.append_array(base.follow_up_clips)
			var column := 0
			for clip_index in clips.size():
				var clip: Resource = clips[clip_index]
				for key in clip.pose_count:
					var image: Image = clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
					var head: Rect2 = clip.identity_regions[key] if clip.identity_regions.size()>key else clip.identity_source_region
					var bounds := image.get_used_rect()
					var mass := 0
					var torso := 0
					for y in 128:
						for x in 192:
							var color := image.get_pixel(x,y)
							if color.a<.65: continue
							mass += 1
							if y>=head.end.y and y<head.end.y+18 and color.r<=color.g*1.2: torso += 1
					var name: String = "ready" if clip_index==0 else ("run" if clip_index==1 else "cut"+str(clip_index-1))
					records.append({"family":family,"view":view_name,"clip":name,"key":key,"height":bounds.size.y,"width":bounds.size.x,"pixels":mass,"torso_pixels":torso,"head":var_to_str(head),"path":clip.resource_path})
				var keys := [0] if clip_index==0 else ([3] if clip_index==1 else ([2,5] if clip_index==2 else [5]))
				for key in keys:
					var sprite := Sprite2D.new()
					var atlas := AtlasTexture.new()
					atlas.atlas = clip.body_atlas
					atlas.region = Rect2(key%4*192,key/4*128,192,128)
					atlas.filter_clip = true
					sprite.texture = atlas
					sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
					sprite.scale = Vector2.ONE*2
					sprite.position = Vector2(90+column*165,160+view*235)
					scene.add_child(sprite)
					label(scene,Vector2(20+column*165,50+view*235),view_name+" · "+("ready" if clip_index==0 else ("run" if clip_index==1 else "cut"+str(clip_index-1)))+" / "+str(key))
					column += 1
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output+family+"_"+tag+".png")
		scene.queue_free()
		await process_frame
	FileAccess.open(output+"measurements_"+tag+".json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print("CARDINAL_PROPORTIONS samples=",records.size()," tag=",tag)
	quit()

func label(parent: Node,position: Vector2,value: String) -> void:
	var node := Label.new()
	node.position = position
	node.text = value
	node.add_theme_font_size_override("font_size",13)
	parent.add_child(node)
