extends SceneTree

const ATLAS_PATH := "res://assets/environment/prototype/ground_atlas.png"
const OUTPUT_PATH := "res://assets/environment/prototype/ground_tileset.tres"


func _initialize() -> void:
	var texture := load(ATLAS_PATH) as Texture2D
	if texture == null:
		push_error("Could not load prototype ground atlas.")
		quit(1)
		return

	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(64, 64)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = Vector2i(64, 64)
	for y in range(2):
		for x in range(2):
			atlas.create_tile(Vector2i(x, y))
	tile_set.add_source(atlas, 0)

	var error := ResourceSaver.save(tile_set, OUTPUT_PATH)
	if error != OK:
		push_error("Could not save prototype ground TileSet: %s" % error)
		quit(1)
		return
	print("Prototype ground TileSet built.")
	quit(0)
