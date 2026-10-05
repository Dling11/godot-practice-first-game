extends SceneTree

## Offline connected-component extraction shared by approved raster builders.
var _foot_heights := PackedInt32Array()
var _face_centers := PackedVector2Array()

func _extract_frames(sheet: Image,columns := 4,rows := 5) -> Array[Image]:
	var frames: Array[Image] = []
	var count := columns*rows
	var cell_size := Vector2i(roundi(sheet.get_width()/float(columns)),roundi(sheet.get_height()/float(rows)))
	const PADDING := 96
	for index in count:
		frames.append(Image.create(cell_size.x+PADDING*2,cell_size.y+PADDING*2,false,Image.FORMAT_RGBA8))
	sheet.convert(Image.FORMAT_RGBA8)
	var bytes := sheet.get_data()
	var width := sheet.get_width()
	var height := sheet.get_height()
	var visited := PackedByteArray()
	visited.resize(width*height)
	var bodies := PackedInt32Array()
	bodies.resize(count)
	_foot_heights.resize(count)
	_foot_heights.fill(-1)
	_face_centers.resize(count)
	_face_centers.fill(Vector2(-1,-1))
	for seed in width*height:
		if visited[seed] or bytes[seed*4+3]<=20: continue
		visited[seed] = 1
		var pixels := PackedInt32Array([seed])
		var head := 0
		var low := Vector2i(seed%width,seed/width)
		var high := low
		var votes := PackedInt32Array()
		votes.resize(count)
		while head<pixels.size():
			var current := pixels[head]
			head += 1
			var point := Vector2i(current%width,current/width)
			low = low.min(point)
			high = high.max(point)
			# A red scarf identifies the BODY's cell even when steel crosses it.
			var red: float = bytes[current*4]
			var green: float = bytes[current*4+1]
			var blue: float = bytes[current*4+2]
			if red>76 and green<red*0.35 and blue<red*0.6 and blue>green*1.1:
				var scarf_cell := clampi(int(point.y/(height/float(rows))),0,rows-1)*columns+clampi(int(point.x/(width/float(columns))),0,columns-1)
				votes[scarf_cell] += 1
			for dy in range(-1,2):
				for dx in range(-1,2):
					var next := point+Vector2i(dx,dy)
					if next.x<0 or next.y<0 or next.x>=width or next.y>=height: continue
					var id := next.y*width+next.x
					if visited[id] or bytes[id*4+3]<=20: continue
					visited[id] = 1
					pixels.append(id)
		var center := (Vector2(low)+Vector2(high))*0.5
		var frame_id := clampi(int(center.y/(height/float(rows))),0,rows-1)*columns+clampi(int(center.x/(width/float(columns))),0,columns-1)
		var maximum := 0
		for index in count:
			if votes[index]>maximum:
				maximum = votes[index]
				frame_id = index
		if maximum>20:
			bodies[frame_id] += 1
			for index in count:
				assert(index==frame_id or votes[index]<maxi(20,maximum/5),"Two bodies overlap in the generated sheet")
			# Feet, not the longest slash, define the planted floor. Preserve x and
			# authored body lean; only y is registered, with explicit jump metadata.
			var boot_rows := {}
			var face_sum := Vector2.ZERO
			var face_count := 0
			for pixel in pixels:
				var red: float = bytes[pixel*4]
				var green: float = bytes[pixel*4+1]
				var blue: float = bytes[pixel*4+2]
				if red>45 and green>20 and red>green*1.2 and green>blue*1.15:
					var y := int(pixel/width)
					boot_rows[y] = boot_rows.get(y,0)+1
				if red>190 and green>130 and blue>55 and blue<175 and red-green>15 and green-blue>20:
					face_sum += Vector2(pixel%width,int(pixel/width))
					face_count += 1
			var foot := -1
			for y in boot_rows:
				if boot_rows[y]>=4: foot = maxi(foot,y+2)
			assert(foot>=0,"Unable to register boots")
			_foot_heights[frame_id] = foot-roundi(frame_id/columns*height/float(rows))+PADDING
			if face_count>0:
				_face_centers[frame_id] = face_sum/face_count-Vector2(roundi(frame_id%columns*width/float(columns)),roundi(frame_id/columns*height/float(rows)))+Vector2(PADDING,PADDING)
		# Tiny isolated alpha specks are generation noise, not blade artwork.
		if pixels.size()<6: continue
		var origin := Vector2i(roundi(frame_id%columns*width/float(columns)),roundi(frame_id/columns*height/float(rows)))
		for pixel in pixels:
			var point := Vector2i(pixel%width,pixel/width)
			var target := point-origin+Vector2i(PADDING,PADDING)
			assert(Rect2i(Vector2i.ZERO,frames[frame_id].get_size()).has_point(target),"Component exceeds registration padding")
			frames[frame_id].set_pixelv(target,sheet.get_pixelv(point))
	for body_count in bodies: assert(body_count>=1,"Missing body after full-component extraction")
	for foot in _foot_heights: assert(foot>=0,"Missing planted-foot registration")
	return frames

