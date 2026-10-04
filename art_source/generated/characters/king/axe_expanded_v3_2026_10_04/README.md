# Iron Beard V3 expanded review sources

Generated on2026-10-04 with the built-in imagegen skill. Exact prompts are in prompts.json. Original outputs are copied unchanged into carry_source.png, actions_source.png and trail_source.png; SHA256/source paths are in manifest.json. References are approved compact Light Leather King and the previous axe V2 body sheet. This is an implementation candidate; final axe balance/design acceptance and normal equipment integration remain open.

## Registration and runtime

- tools/build_king_axe_expanded.gd registers the sources into assets/characters/playable/king/axe_proof_v3/. Run after the existing V2 build/import, then import the new assets. Alpha threshold0.65 and nearest-neighbor resizing give binary-alpha textures; no per-pose resizing.
- Carry source uses one0.13 scale, side/spin source one0.22 scale. Foot anchoring matches the existing192x128 Body canvas, actor scale0.5 and position(0,-16). Side pose4 has a wider source crop because its fist crosses the nominal cell boundary.
- The axe is the exact unchanged55x64 canonical V2 texture with grip(39,33), shaft(4,10) and shaft-axis reflection. One-hand frames use a virtual secondary direction anchor rather than claiming a second grip. Stowed frames use back anchors(91,78)/(97,81), no hand mask and behind-body local ordering.
- Eight carry/transition frames use relaxed generated poses; final two stowed frames reuse the relaxed source body with back attachment, rather than leaving King holding the axe above his head. Four seconds without attacking starts a0.48s transition. Timer/tweens pause and stop on cancellation/detachment; reattachment restores carry observation.
- Root side clip plus rising/down/hop/spin leaves supply40 attack frames; carry/rest adds8. Root/down/rising/hop reuses V2 body/art and the canonical weapon. No new locomotion or full directional action set is claimed.
- FX atlas is512x640: four128px cells per row; side/rise/down/hop/spin rows. The side/spin drawings are new; other rows reuse V2 drawings at one larger registration scale. Cropping10px border removes generated sheet dividers. World scale1.4px/texel, actor-foot-relative origin(0,-16), row anchors(64,64)/(64,85.333)/(64,64)/(64,64)/(64,64). Convex/circle contact shapes clip every drawing; art cannot issue damage.

## Play and scope

From the project root: powershell -ExecutionPolicy Bypass -File .\tools\launch_king_axe_grip_review.ps1. This now opens launch_king_axe_expanded_review.gd; the previous V2 GDScript remains replayable.

SPACE/click ground advances one cut with one follow-up buffer. Play five-move combo runs side sweep → rising cut → down cut → hop slam → whirlwind. Try whirlwind alone and Surround King with targets demonstrate rear contacts/outward knockback. Place distant target puts a real training target60px away. ESC pauses; Cancel clears pending attacks; Reset rebuilds. Default actor is stationary and safe. Rootlings retain genuine AI; all spawned enemies are rewardless and storage/autosave are isolated/suppressed. Normal F5 equipment/skills/recipes/profile are unchanged.

Review-only forward reach72px (doubled from36), side width108px, spin radius68px. Physical multiplier sequence100/110/115/150/135%; knockback100/110/130/180/150%. Hop is only visual anticipation, grounded before ACTIVE, with no gameplay movement or invulnerability. The spin uses existing radial hitbox authority and normal one-hit-per-target deduplication.

## Evidence

See art_source/review/combat/king_axe_expanded_v3_2026_10_04/: native.log, controls.png, rest.png, full gallery.png,190 captured frames, motion_timeline.json, motion.gif and regression logs. GIF uses actual elapsed frame times and verified WPF decoding. Capture is presentation evidence, not a campaign/device benchmark. Run tests/king_axe_expanded_review_smoke.gd with native rendering for V3 checks; old grip/combo and melee/style tests cover existing behavior.

Next: owner feel/visual review, genuine walking and all directions, skill/equipment switching and save-compatible family selection before crafted collection promotion.

## Edge correction follow-up

The native clip polygon caused straight bright cuts even with transparent atlas padding. V3 now fades3px inward through a cached four-frame vertex-color mesh. The fully bright interior and original contact geometry remain; no extra damage reach or skill behavior is added. Native tests/axe_trail_edge_smoke.gd passes25 pixel/margin/clear checks, and the expanded review passes492 checks. Original generated PNGs/registration stay unchanged. Skill-equipped-weapon routing remains a recommendation, not implemented.
