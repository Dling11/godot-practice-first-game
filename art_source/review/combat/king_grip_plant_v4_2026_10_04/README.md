# Grip and shallow planting V4 — 2026-10-04

Current sources are unchanged approved-family action_source.png and gait run/passing sources in art_source/generated/characters/king/. No new artwork generated for this pass: correction is registration, layering, mount geometry and reusable planting presentation.

Build tools/build_king_confidence_v2.gd, then tools/build_king_gait_repair.gd, then import. First tool builds the optional upright planting resource and released masks; second registers brown run gloves, exposed handle and rear axe mount. Runtime resources remain under assets/characters/playable/king/greatsword_confidence_v2/.

WeaponPlantingDefinition stores shared ground/depth/clearance/action data. Individual weapon clips store texture, primary grip, handle axis and tip. Compatible greatsword variants rebind those weapon landmarks while preserving body/action poses; geometry derives hilt height and shallow burial. New artwork still needs visual grip/proportion/facing checks. Normal equipment routing is not installed by this review.

Native checks and limits are in validation.txt. Capture tools/capture_king_confidence_motion.gd; encode tools/build_king_axe_motion_gif.ps1 -GripPlant. Separate running/all-keys evidence: ../king_grip_loop_v4_2026_10_04/ (capture_king_gait_repair.gd, -GripLoop).
