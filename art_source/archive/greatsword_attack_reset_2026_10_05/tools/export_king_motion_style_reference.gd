extends SceneTree
const OUT := "res://art_source/generated/characters/king/greatsword_connected_2026_10_05/"
func _initialize() -> void:
	var board := Image.create(768,512,false,Image.FORMAT_RGBA8)
	var rows := [
		[["greatsword_confidence_v2/idle",0],["greatsword_confidence_v2/opening",2],["huge_greatsword_proof/sweep",4],["greatsword_low_return/return",8]],
		[["greatsword_cardinal/down/sweep",0],["greatsword_cardinal/down/sweep",2],["greatsword_cardinal/down/turn",4],["greatsword_cardinal/down/return",4]],
		[["greatsword_cardinal/up/sweep",0],["greatsword_cardinal/up/sweep",2],["greatsword_cardinal/up/turn",4],["greatsword_cardinal/up/return",4]]
	]
	for row in 3:
		for column in 4:
			var entry: Array = rows[row][column]
			var image: Image = load("res://assets/characters/playable/king/"+entry[0]+"_body.png").get_image()
			var key: int = entry[1]
			board.blit_rect(image,Rect2i(key%4*192,key/4*128,192,128),Vector2i(column*192,row*128))
	assert(board.save_png(OUT+"protected_body_reference.png")==OK)
	board.resize(1536,1024,Image.INTERPOLATE_NEAREST)
	assert(board.save_png(OUT+"existing_style_reference.png")==OK)
	print("EXISTING_STYLE_REFERENCE verbatim King cels; 2x nearest reference")
	quit()
