extends SceneTree

## Fit the complete four-frame raster envelope inside its unchanged contact.
## One transform per row prevents frame-to-frame size or placement wobble.
const ART = preload("res://assets/characters/playable/king/huge_greatsword_proof/swing.png")
const COMBO = preload("res://data/weapons/families/royal_greatsword/combo.tres")
const OUT := "res://art_source/review/combat/king_upward_cut_2026_10_05/"

func _initialize() -> void:
	var image: Image = ART.get_image()
	var records: Array[Dictionary] = []
	var samples := PackedStringArray()
	for row in [0,1,2,3]:
		var support := PackedVector2Array()
		for frame in 4:
			for y in 256:
				for x in 256:
					if image.get_pixel(frame*256+x,row*256+y).a>.5: support.append(Vector2(x+.5,y+.5))
		var envelope := Geometry2D.convex_hull(support)
		assert(not envelope.is_empty(),"Slash row has no opaque artwork")
		var bounds := Rect2(envelope[0],Vector2.ZERO)
		for point in envelope: bounds = bounds.expand(point)
		var origin := bounds.get_center()
		var polygon: PackedVector2Array = COMBO.hitbox_shapes[row].points
		var legacy_cropped := 0
		for point in support:
			if not Geometry2D.is_point_in_polygon(point-Vector2(128,128),polygon): legacy_cropped += 1
		var planes: Array[Vector3] = []
		var extent := PackedFloat32Array()
		for index in polygon.size():
			var edge := polygon[(index+1)%polygon.size()]-polygon[index]
			var normal := Vector2(edge.y,-edge.x).normalized()
			planes.append(Vector3(normal.x,normal.y,normal.dot(polygon[index])-4.0))
			var maximum := -INF
			for point in envelope: maximum = maxf(maximum,normal.dot(point-origin))
			extent.append(maximum)
		var best := 0.0
		var center := Vector2.ZERO
		for x in range(3,105):
			for y in range(-58,59):
				var candidate := Vector2(x,y)
				var ratio := 1.0
				for index in planes.size():
					var plane := planes[index]
					ratio = minf(ratio,(plane.z-Vector2(plane.x,plane.y).dot(candidate))/extent[index])
				if ratio>best+.00001 or (absf(ratio-best)<.00001 and candidate.distance_squared_to(Vector2(60,-16))<center.distance_squared_to(Vector2(60,-16))):
					best = ratio
					center = candidate
		best = floorf(best*1000)/1000
		assert(best>0,"Slash envelope cannot fit its contact polygon")
		var transform := Transform2D(Vector2(1.0/best,0),Vector2(0,1.0/best),origin-center/best)
		samples.append(var_to_str(transform))
		records.append({"row":row,"source_origin":[origin.x,origin.y],"world_center":[center.x,center.y],"scale":best,"contact_margin":4,"opaque_texels":support.size(),"legacy_cropped_texels":legacy_cropped,"source_bounds":var_to_str(bounds),"blade_registered_override":row==2})
		print("VERTICAL_SLASH row ",row," origin ",origin," center ",center," scale ",best)
	FileAccess.open(OUT+"slash_registration.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	FileAccess.open(OUT+"upward_swing_samples.txt",FileAccess.WRITE).store_string("upward_swing_samples = Array[Transform2D](["+", ".join(samples)+"])\n")
	quit()
