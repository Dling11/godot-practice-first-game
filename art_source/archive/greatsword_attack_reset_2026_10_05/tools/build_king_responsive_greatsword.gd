extends SceneTree

## Reuse complete installed raster poses. No generated torso or detached arms.
const Definition = preload("res://data/weapons/weapon_family_pose_definition.gd")
const DEST := "res://assets/characters/playable/king/greatsword_responsive/"
const STEEL = preload("res://assets/characters/playable/king/huge_greatsword_proof/greatsword.png")
const NAMES := ["sweep","rise","slam","turn","return"]
const SIDE := [
	"res://assets/characters/playable/king/greatsword_confidence_v2/opening.tres",
	"res://assets/characters/playable/king/huge_greatsword_proof/rise.tres",
	"res://assets/characters/playable/king/huge_greatsword_proof/meteor.tres",
	"res://data/weapons/families/royal_greatsword/linked_turn.tres",
	"res://assets/characters/playable/king/greatsword_low_return/return.tres"
]
const SIDE_KEYS := [
	[0,1,2,3,3,4,5,6,7,0,5,0],
	[0,0,0,2,3,4,5,6,7,0,5,0],
	[1,2,4,5,5,6,6,6,7,0,6,0],
	[0,1,2,3,4,5,5,6,7,0,5,0],
	[1,1,2,3,4,5,6,8,11,15,8,15]
]
const VERTICAL_KEYS := [0,1,2,3,4,5,5,6,7,0,5,0]
var audit: Array[Dictionary] = []

func _initialize() -> void:
	for direction in ["side","up","down"]: _direction(direction)
	FileAccess.open(DEST+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	print("RESPONSIVE_GREATSWORD fifteen full-body clips / twelve keys / original steel")
	quit()

func _direction(direction: String) -> void:
	var folder := DEST+direction+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var idle: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres" if direction=="side" else "res://assets/characters/playable/king/greatsword_cardinal/"+direction+"/idle.tres")
	var originals: Array[Resource] = []
	for cut in 5: originals.append(load(SIDE[cut] if direction=="side" else "res://assets/characters/playable/king/greatsword_cardinal/"+direction+"/"+NAMES[cut]+".tres"))
	var clips: Array[Resource] = []
	var bodies: Array[Image] = []
	var hands: Array[Image] = []
	for cut in 5:
		var source: Resource = originals[cut]
		var clip := Definition.new()
		clip.pose_count = 12
		clip.weapon_texture = STEEL
		clip.weapon_primary_grip = Vector2(15,113)
		clip.weapon_tip = Vector2(15,0)
		clip.mirror_cutting_edge = false
		clip.phase_windows = PackedVector2Array([Vector2(0,2),Vector2(3,6),Vector2(7,9)])
		clip.queued_recovery_window = Vector2(10,11)
		clip.maximum_lift_pixels = 48
		clip.pose_order.clear()
		clip.lift_pixels.clear()
		clip.weapon_behind_body.clear()
		clip.single_hand_poses.clear()
		clip.stowed_poses.clear()
		clip.released_poses.clear()
		clip.ground_clipped_poses.clear()
		var atlas := Image.create(768,384,false,Image.FORMAT_RGBA8)
		var mask := Image.create(768,384,false,Image.FORMAT_RGBA8)
		for key in 12:
			var pose: int = SIDE_KEYS[cut][key] if direction=="side" else VERTICAL_KEYS[key]
			_copy_pose(clip,atlas,mask,key,source,pose)
			clip.pose_weights.append([.3,.8,1.0,.5,.7,1.0,1.0,.6,.6,1.0,.35,1.0][key])
		# Release returns through complete drawn recoveries to the existing carry.
		_replace_pose(clip,atlas,mask,9,idle,0)
		# A buffered recovery moves into a complete next chamber, not a guard
		# reset or an independently moved sword over frozen anatomy.
		var next: Resource = originals[cut+1] if cut<4 else idle
		var chamber: int = [0,1,0,1,0][cut] if direction=="side" else (1 if cut<4 else 0)
		_replace_pose(clip,atlas,mask,11,next,chamber)
		if cut==0: _replace_pose(clip,atlas,mask,0,idle,0)
		else:
			var previous: Resource = clips[cut-1]
			for property in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses"]:
				var values = clip.get(property)
				values[0] = previous.get(property)[11]
				clip.set(property,values)
			atlas.blit_rect(bodies[cut-1],Rect2i(3*192,2*128,192,128),Vector2i.ZERO)
			mask.blit_rect(hands[cut-1],Rect2i(3*192,2*128,192,128),Vector2i.ZERO)
		# The slam lands at ACTIVE. Its original raised/jump poses only run
		# during anticipation, avoiding airborne damage and a sideways blade.
		if cut==2:
			for key in range(3,9):
				clip.lift_pixels[key] = 0
				if direction=="side": clip.secondary_hands[key] = clip.primary_hands[key]+Vector2(0,-7)
		clips.append(clip)
		bodies.append(atlas)
		hands.append(mask)
		assert(atlas.save_png(folder+NAMES[cut]+"_body.png")==OK)
		assert(mask.save_png(folder+NAMES[cut]+"_hands.png")==OK)
		audit.append({"direction":direction,"cut":cut,"source":source.resource_path,"source_keys":SIDE_KEYS[cut] if direction=="side" else VERTICAL_KEYS,"chamber_source":next.resource_path,"chamber_key":chamber,"modular_arms":false})
	for cut in 5: _write(folder,NAMES[cut],clips[cut],NAMES.slice(1) if cut==0 else [])

func _copy_pose(clip: Resource, body: Image, hand: Image, key: int, source: Resource, pose: int) -> void:
	clip.pose_order.append(key)
	for property in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]:
		var values = clip.get(property)
		values.append(source.get(property)[pose])
		clip.set(property,values)
	_blit(body,hand,key,source,pose)

func _replace_pose(clip: Resource, body: Image, hand: Image, key: int, source: Resource, pose: int) -> void:
	for property in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]:
		var values = clip.get(property)
		values[key] = source.get(property)[pose]
		clip.set(property,values)
	_blit(body,hand,key,source,pose)

func _blit(body: Image, hand: Image, key: int, source: Resource, pose: int) -> void:
	var cell: int = source.pose_order[pose]
	var rectangle := Rect2i(cell%4*192,cell/4*128,192,128)
	var position := Vector2i(key%4*192,key/4*128)
	body.fill_rect(Rect2i(position,Vector2i(192,128)),Color.TRANSPARENT)
	hand.fill_rect(Rect2i(position,Vector2i(192,128)),Color.TRANSPARENT)
	body.blit_rect(source.body_atlas.get_image(),rectangle,position)
	hand.blit_rect(source.hand_atlas.get_image(),rectangle,position)

func _write(folder: String, label: String, clip: Resource, followups: Array) -> void:
	var text := "[gd_resource type=\"Resource\" load_steps="+str(5+followups.size())+" format=3]\n"
	var paths := ["res://data/weapons/weapon_family_pose_definition.gd",folder+label+"_body.png",folder+label+"_hands.png",STEEL.resource_path]
	for index in paths.size(): text += "[ext_resource type=\""+("Script" if index==0 else "Texture2D")+"\" path=\""+paths[index]+"\" id=\""+str(index+1)+"\"]\n"
	for index in followups.size(): text += "[ext_resource type=\"Resource\" path=\""+folder+followups[index]+".tres\" id=\""+str(index+5)+"\"]\n"
	text += "[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	for property in ["pose_count","pose_order","primary_hands","secondary_hands","weapon_primary_grip","weapon_tip","mirror_cutting_edge","phase_windows","queued_recovery_window","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses","lift_pixels","maximum_lift_pixels","pose_weights"]:
		text += property+" = "+var_to_str(clip.get(property))+"\n"
	if not followups.is_empty():
		text += "follow_up_clips = Array[Resource](["
		for index in followups.size(): text += ("," if index>0 else "")+"ExtResource(\""+str(index+5)+"\")"
		text += "])\n"
	FileAccess.open(folder+label+".tres",FileAccess.WRITE).store_string(text)
	if folder.ends_with("side/") and label=="sweep": FileAccess.open("res://data/weapons/families/royal_greatsword/poses.tres",FileAccess.WRITE).store_string(text)
