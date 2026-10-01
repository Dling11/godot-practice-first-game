# Orren workshop interior - built-in imagegen

Reference: assets/environment/sanctuary/refuge_review/orren_workshop.png.

## Kit generation

Use case: stylized-concept
Asset type: production pixel-art environment kit for a Godot overhead RPG workshop interior.
Use the supplied Orren workshop exterior ONLY as the material, pixel outline, warm lighting and medieval fantasy style reference. Create a NEW interior kit with four clearly separate panels on a transparent background, no labels, characters, interface, grid lines or text.
Layout: image 1536x1024. TOP HALF (y0-512): a wide EMPTY rectangular workshop room shell centered, approximately 1440x480. It has a visible north/back stone wall with timber beams and two warm windows, narrow stone side walls, and a broad clear plank floor. Horizontal foundation and facade lines; vertical side walls; standard 3/4 overhead RPG camera, identical to the exterior reference, NOT isometric or diagonal. Bottom/south edge is cut away, no front wall, so the player can enter at its center. No furniture in the shell. Floor mostly quiet brown boards with a few muted stone slabs near north-east; no rug.
BOTTOM HALF: three separate sprite props, each isolated with generous transparent padding in its own third: LEFT is a compact STONE FORGE, flame glowing in a dark iron aperture, hood/flue at top and a small copper bucket at base (tall sprite); CENTER is a timber WORKBENCH, seen with visible top and front edge, sword laid flat, small tongs, leather tools and drawers (wide sprite); RIGHT is a vertical timber WEAPON RACK with three swords and a round dark shield (wide sprite). These are separate objects, not scenes.
Style: crisp hard-edged pixel art, dark one/two pixel contours, restrained medieval stone/timber/charcoal/amber palette matching reference. Rich hand-authored sprite texture without photographic rendering, bloom, blur, smooth gradients or perspective drift. Illumination from upper left, forge amber. No plants, NPCs, landscape or roof. Preserve actual alpha outside room/props. The room shell will be downsampled to 640x224 and props to roughly 80x96 /112x64 /96x80; details must stay readable there.

## Alpha extraction

Use case: background-extraction. Edit ONLY the background of this exact pixel-art workshop kit. Remove the entire black/brown blurred gradient presentation backdrop outside the room shell and three furniture objects, replacing it with genuine transparent alpha. Preserve every opaque pixel of the room's floor, all stone/timber wall pieces, forge, bucket/anvil, table/tools, and sword/shield rack. Preserve dimensions 1536x1024, positions, colors, hard pixel outlines, layout and scale exactly. Do not alter, redraw, resize or add anything. No glow, shadow haze or opaque gradient may remain outside the silhouettes. The inside of the room and the forge flame remain opaque. No labels or text.
