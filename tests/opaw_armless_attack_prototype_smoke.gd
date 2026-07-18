extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const ArmlessAttackTexture = preload("res://assets/characters/playable/opaw/variants/armless/opaw_armless_attack_body_sheet_48x32.png")
const SmallFeetAttackTexture = preload("res://assets/characters/playable/opaw/variants/armless_small_feet/opaw_armless_small_feet_attack_body_sheet_48x32.png")


func _initialize() -> void:
	for texture: Texture2D in [ArmlessAttackTexture, SmallFeetAttackTexture]:
		if not _validate_candidate(texture):
			return

	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	await process_frame
	var active_body := player.get_node("VisualRoot/Body") as AnimatedSprite2D
	var active_attack := active_body.sprite_frames.get_frame_texture(&"attack_down", 0) as AtlasTexture
	if active_attack.atlas == ArmlessAttackTexture or active_attack.atlas == SmallFeetAttackTexture:
		_fail("The armless attack prototype replaced Opaw's active animation before review.")
		return
	print("Opaw armless attack prototypes smoke test passed.")
	quit(0)


func _validate_candidate(texture: Texture2D) -> bool:
	var image := texture.get_image()
	if image.get_size() != Vector2i(144, 128):
		_fail("Armless Opaw attack prototype does not preserve the 3x4 48x32 grid.")
		return false
	for y in image.get_height():
		for x in image.get_width():
			var alpha := image.get_pixel(x, y).a
			if not is_zero_approx(alpha) and not is_equal_approx(alpha, 1.0):
				_fail("Armless Opaw attack prototype contains non-binary alpha.")
				return false
	for row in 4:
		for column in 3:
			var opaque_pixels := 0
			for y in range(row * 32, row * 32 + 32):
				for x in range(column * 48, column * 48 + 48):
					if image.get_pixel(x, y).a > 0.5:
						opaque_pixels += 1
			if opaque_pixels < 50:
				_fail("Armless Opaw attack cell %s,%s is empty or fragmented." % [column, row])
				return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
