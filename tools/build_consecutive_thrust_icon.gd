extends SceneTree

## Creates a compact readable icon for the three-lance Warrior technique.

const OUTPUT_PATH := "res://assets/ui/icons/skills/icon_skill_consecutive_thrust_24x24.png"


func _initialize() -> void:
	var image := Image.create_empty(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y in [6, 11, 16]:
		_draw_lance(image, y, 5, 19)
	image.set_pixel(3, 11, Color("f6c55a"))
	image.set_pixel(4, 11, Color("fff3bf"))
	var save_error := image.save_png(OUTPUT_PATH)
	if save_error != OK:
		push_error("Unable to save Consecutive Thrust icon: %s" % error_string(save_error))
		quit(1)
		return
	print("Built Consecutive Thrust icon: %s" % OUTPUT_PATH)
	quit(0)


func _draw_lance(image: Image, y: int, left: int, right: int) -> void:
	for x in range(left, right):
		var color := Color("fff5c2") if x < right - 2 else Color("f8c35d")
		image.set_pixel(x, y, color)
		if x > left + 2 and x < right - 3:
			image.set_pixel(x, y - 1, Color("83d7ff"))
			image.set_pixel(x, y + 1, Color("83d7ff"))
	image.set_pixel(right, y, Color("ffffff"))
	image.set_pixel(right - 1, y - 1, Color("f6c55a"))
	image.set_pixel(right - 1, y + 1, Color("f6c55a"))
