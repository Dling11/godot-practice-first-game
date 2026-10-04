# Huge steel greatsword source and review

2026-10-04. Built-in image_gen, weapon-only design shown before body/effect generation. This is a playable right-facing candidate, not a selected campaign replacement.

- [Exact prompts](prompts.json), [unchanged source SHA256/provenance](manifest.json), [registration](registration.json). All five original PNGs are preserved byte-for-byte.
- weapon_source.png: one rigid broad steel blade with long two-hand grip; runtime30x140 logical pixels, primary grip(15,113), shaft axis down. World scale0.5 gives15x70; standing King remains roughly27px.
- body_1_source.png/body_2_source.png:32 distinct torso/foot/knee poses across four moves. Generated silhouettes cross nominal cells. Offline eight-neighbor components isolate whole bodies, all use0.20 source scale, and support feet register to(96,96) in192x128 cells. Reviewed hand-edge corrections are explicit in the builder; no per-pose body fitting. Foreground masks cover gloves.
- slash_source.png:16 white/grey crescents, registered as four4-frame rows in256px cells. Source aspect ratio preserved; contact clips/fades3px inward.
- impact_source.png:4 metal-contact plus4 ground-slam frames in192px cells. Contact origin(96,96), ground seam(96,148); grounded actor-space blade contact(46,32) lies inside the slam fan.

Rebuild with tools/build_king_huge_greatsword.gd, then Godot editor import. Launch tools/launch_king_greatsword_review.ps1. [Native gallery](../../../../review/combat/king_huge_greatsword_2026_10_04/gallery.png), [real-clock110-frame GIF](../../../../review/combat/king_huge_greatsword_2026_10_04/motion.gif), [implemented scope](../../../../../docs/design/king-huge-greatsword-review.md). No normal equipment/crafting/skills/saves change.
