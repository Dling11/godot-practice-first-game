extends SceneTree

const ACTIVE_PATHS := [
"res://levels/sanctuary/town/sanctuary_town.gd",
"res://assets/characters/npcs/armskeeper/renewal/sprite_frames.tres",
"res://assets/characters/npcs/skillkeeper/renewal/sprite_frames.tres",
"res://assets/characters/npcs/rootweaver/renewal/sprite_frames.tres",
"res://assets/characters/npcs/umi/renewal/sprite_frames.tres",
	"res://assets/characters/playable/king/simple_reboot/king_simple_sprite_frames.tres",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_sprite_frames.tres",
	"res://assets/characters/enemies/rootbound_husk/rootbound_husk_root_spear_vfx_sprite_frames.tres",
]

const RETIRED_RUNTIME_PATHS := [
	"res://assets/characters/awakened",
	"res://assets/characters/prototype",
	"res://assets/characters/sprites_24x32",
	"res://assets/characters/playable/opaw",
	"res://assets/skills/opaw",
	"res://data/abilities/opaw",
	"res://data/items/opaw_weapon_catalog.tres",
	"res://data/progression/opaw_path.tres",
	"res://data/progression/opaw_vitality.tres",
	"res://gameplay/abilities/opaw",
	"res://ui/shops",
	"res://entities/npcs/weapon_merchant",
	"res://environment/props/sanctuary/mushroom_dwelling.tscn",
	"res://environment/props/sanctuary/merchant_hall.tscn",
	"res://environment/props/sanctuary/weapon_stall.tscn",
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
	var closeout := "res://art_source/archive/sanctuary_retired_2026_10_02/"
	var retired: Array = JSON.parse_string(FileAccess.get_file_as_string(closeout+"retired_paths.json"))
	for relative: String in retired:
		if FileAccess.file_exists("res://"+relative) or not FileAccess.file_exists(closeout+"retired/"+relative):
			_fail("Sanctuary archive is incomplete or retired content is active: "+relative)
			return
	if not FileAccess.file_exists(closeout+".gdignore"):
		_fail("Sanctuary recovery archive lacks its Godot import exclusion.")
		return
	print("Runtime/archive boundary smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
