# Worldsplitter: shattered light and extraction

Built-in image-generation mode, 2026-09-27. Reference: the detailed Worldsplitter sword source from the prior approved art family. Original 16-frame impact and 16-frame extraction/restrike outputs are preserved here; `tools/build_worldsplitter_light.gd` packs them into padded binary-alpha atlases under `assets/vfx/abilities/king/worldsplitter/light/`. Existing detailed sword frames remain for formation and final dissolution. Forty-eight distinct source drawings are available across these three action layers; frames are deliberately revisited for the repeated plunge cycle.

Runtime motion adds physically timed lift/descent and clips only the buried tip against the target ground plane. Crimson coloring uses one per-instance shader, preserving white edges and dark blade detail. No King body regeneration. The previous ground atlas remains historical and is no longer used by this skill.

## Impact prompt

Generate a production VFX sprite sheet for a top-down pixel-art RPG: a heavy spectral sword SHATTERS LIGHT upon hitting the ground. Attached sword atlas is STYLE reference ONLY for dark cobalt interior, sharp white beveled borders and deliberate pixel fragments. DO NOT include the sword, character, large rocks or crater. This is a GROUND CONTACT EFFECT ONLY, transparent PNG alpha.
Exact 4x4 grid of16 equal square cells,2048x2048. Each cell has same ground origin x256,y300; max width360px and height180px, at least64px padding. Effect is low and broad on floor with a few sharp angular light shards springing upward. No tall energy pillar, no ring or rune, no big star or X-shaped spokes. Ground is almost empty, just a shallow dark slit at the center and a little gray grit/dust. The impact material is glass-like LIGHT: distinct cobalt-bordered shards with white beveled edges, dark blue planes, a compact bright contact core. Narrow low pressure ripple along floor, irregular and broken, not circular magical graphics. Keep much negative space between angular shards. Crisp hard-pixel clusters, nearest-neighbor style, no blur/gradient/fuzzy glow/dithering.
16 unique consecutive frames in reading order: 0 compressed tiny contact slit;1 short sharp compressed white core;2 light shell fractures into 4 wedge-like pieces;3 6 shards push outward;4 peak bloom of6-8 angular shards low above floor;5 shards separate outward;6 widest footprint few flakes;7 pressure fades as shards fall;8 shards hit floor and break small;9 few bright splinters slide outward;10 dark slit with little fading light;11 faint edge glints;12 thin scar with 3 flecks;13 scar fading;14 tiny scar and one fleck;15 nearly empty tiny faint scar. No stone bed, no boulders, no dirt mountain, no giant starburst. Every frame different. It should look detailed and forceful without filling its bounding area with solid bright pixels.

## Extraction/restrike prompt

Create a NEW motion atlas using the attached Worldsplitter sword as EXACT visual identity reference. Preserve its blade length/width, dark blue inner plane, white double beveled edges, guard, grip and pommel. This sheet is a spectral upright sword EXTRACTING AFTER A HEAVY PLUNGE AND STRIKING AGAIN. All frames keep ONE intact sword, always vertical with point DOWN. No rotation, no angled sword, no characters, no rocks or crater.
4x4 grid,16 equal square cells,2048x2048 transparent alpha PNG. Same sword dimensions in every cell, blade/hilt overall300px tall, central axisx256. For runtime registration draw the actual complete sword point at y420 in every cell; its physical upward/downward displacement will be driven in-engine. DO NOT shorten the blade to show burial; engine clips buried tip. At least48px padding. Changes in drawn LIGHT TENSION, EDGE SHARDS and SPEED TRAILS must communicate stages even with a fixed tip anchor.
16 distinct drawings in reading order:
0 intact sword braced at impact, short light compression at tip;
1 deeper tension, fuller brightens with narrow stress streaks;
2 small upward clinging slivers along lower blade;
3 extraction starts, thin energy threads stretched downward from near tip;
4 pulling free, attached threads stretch and start breaking;
5 sharp white fragments peel from lower edge;
6 tip clean of threads with small shards trailing below;
7 withdrawn sword with white edge held bright, tiny trailing motes;
8 raised anticipation, concentrated white rim near guard;
9 downward acceleration begins with narrow vertical streaks ABOVE blade;
10 faster downward straight streaks with intact sharp blade;
11 strongest downward streaks, still same blade proportions;
12 contact compression at tip, intact sword;
13 impact stress traveling up fuller with few detached small shards;
14 held embed, rim light quiets;
15 quiet intact buried-ready hold with two small motes.
Use crisp hard-edged pixel art exactly in reference family. No fuzzy halo, dither or smooth shading. At most12-16 deliberate colors from charcoal/navy/cobalt/lavender/icewhite. All motion accents must fit cell and stay secondary to blade. No dissolve frames here, no missing blade chunks: this sheet must support repeated physical extraction and plunge before the separate final dissolution animation.
