extends SceneTree

const ACTIVE_PATHS := [
	"res://assets/characters/playable/opaw/compact_armless/opaw_compact_armless_sprite_frames.tres",
	"res://assets/characters/playable/opaw/variants/wayfarer_original/opaw_wayfarer_original_sprite_frames.tres",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_sprite_frames.tres",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_root_spear_vfx_sprite_frames.tres",
	"res://assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x48.png",
	"res://assets/characters/npcs/armskeeper/armskeeper_idle_sheet_48x48.png",
	"res://environment/props/sanctuary/skillkeeper_lodge.tscn",
	"res://environment/props/sanctuary/armskeeper_workshop.tscn",
	"res://environment/props/sanctuary/armskeeper_cart.tscn",
]

const RETIRED_RUNTIME_PATHS := [
	"res://assets/characters/awakened",
	"res://assets/characters/playable/opaw/variants/handless",
	"res://assets/characters/playable/opaw/variants/armless",
	"res://assets/characters/playable/opaw/variants/armless_small_feet",
	"res://entities/npcs/weapon_merchant",
	"res://environment/props/sanctuary/mushroom_dwelling.tscn",
	"res://environment/props/sanctuary/merchant_hall.tscn",
	"res://environment/props/sanctuary/weapon_stall.tscn",
	"res://tools/build_opaw_handless_variant.gd",
	"res://tools/build_opaw_armless_attack_prototype.gd",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_attack_sheet_96x64_from_scratch.png",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_attack_sheet_96x64_v2.png",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_walk_sheet_72x64_from_scratch.png",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_walk_sheet_72x64_passing_v2.png",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_walk_sheet_72x64_v2.png",
]


func _initialize() -> void:
	for path in ACTIVE_PATHS:
		if not ResourceLoader.exists(path):
			_fail("Required active or supported rollback resource is missing: %s" % path)
			return
	for path in RETIRED_RUNTIME_PATHS:
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path) or DirAccess.dir_exists_absolute(absolute_path):
			_fail("Retired material leaked back into Godot runtime folders: %s" % path)
			return
	var archive_root := ProjectSettings.globalize_path("res://art_source/archive")
	if not DirAccess.dir_exists_absolute(archive_root):
		_fail("The Godot-ignored archive root is missing.")
		return
	print("Runtime/archive boundary smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
