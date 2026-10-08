# Frozen King anatomy v1

Captured from owner-approved art on 2026-10-07. These PNGs are immutable offline references, ignored by Godot imports. `tools/build_king_identity_reference.gd` deliberately refuses to overwrite an existing reference. Read `reference.json` and `trace_board.png` before future weapon generation; a replacement needs a new reference version.

- 192×128 body cells; presentation scale 0.5; grounded sole y94. Upright native bodies occupy 54–57 pixels. Crouching, airborne or turning poses may change occupied bounds without changing anatomical scale.
- LEFT/RIGHT preserve the accepted axe carry body and the complete side crown. UP/DOWN preserve the approved cardinal identity. The side head ROI is 27×27, rear 25×24 and front 27×29; ROI padding is not visible head size. The front's actual hair is 21×19. Do not enlarge it to fill a 27×29 box.
- Keep exact native head pixels and consistent shoulder/armor/leg density. Calibrate one torso scale per source sheet from collar-to-sole length and armor width. Never resize each pose separately.
- Register the torso using the actual crown/collar, not the midpoint of an extended boot or a flying scarf. Foot y owns grounding; explicit lift owns jumping.
- Retain complete connected drawings. Transparent gutters own guide sheets. For body-only sources with overlapping row bands, use complete scarf-labelled components. Nominal equal cells can capture a neighboring limb.
- Source weapons and wrists must form one intelligible hold. Technical colored guides stay offline; runtime blades use the real palm and canonical rigid weapon. Preserve natural rear occlusion and foreground source gloves.

`tools/king_native_identity.gd` implements offline ingestion. `tests/king_identity_lock_smoke.gd` verifies native crown pixels, connected body/palms, cell safety and exact accepted Greatsword side gait reuse. Native playback and owner feel review remain required beyond these checks.
