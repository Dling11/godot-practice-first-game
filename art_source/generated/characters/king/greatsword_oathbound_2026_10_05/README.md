# Oathbound body sources — 2026-10-05

Generated with the **built-in imagegen tool** using exported installed King carry art. No external model override or local image model was used.

| Runtime source | Exact prompt | Generation output |
| --- | --- | --- |
| side_body_source.png | side_prompt.txt | exec-006b33ba-91ad-4a50-9acd-36ef0da630b5.png |
| up_body_source.png | up_prompt.txt | exec-e8451beb-6163-4150-9b6a-d0a8aa1ba40d.png |
| down_body_source.png | down_final_prompt.txt | exec-9b52c427-7cd3-40ac-bb0e-7ec695962b7d.png |
| REJECTED: rejected_side_facing_front.png | down_prompt.txt | exec-bc23174a-5122-44a7-b47b-868bb52191f8.png |

Original tool outputs were saved under `C:/Users/Administrator/.codex/generated_images/01a0eed4-5878-7032-a315-e493f92ce97a/` and copied here without modifying the raw PNGs. Repository copies are the persistent sources. The rejected front attempt faces sideways; the builder never loads it.

Reference exports come from installed side/cardinal carry resources via `tools/export_king_oathbound_reference.gd`; combined enlarged board: `installed_identity_reference.png`. These are references, not replacement runtime bodies.

The builder selects50 complete source poses per direction, composes original identity offline and quantizes body colors to installed carry art. Side/down retain crimson neck registration. Up attacks attach hair only to the drawn scalp center/bottom; the older larger idle reference included scarf/shoulders and created a sideways transplant. No raw PNG is edited. Original source collar/torso and raised foreground fists remain intact. Opaque unoccluded identity stays exact; transparent edges blend. Carry and queued-entry overrides reduce distinct generated cels to44 per view. `registration.json` records source scalp/bounds, density, reference/placed/installed identity regions, grips and overrides. `provenance.json` retains unchanged raw source dimensions, prompts and hashes. `rebuild_manifest.json` records current derived runtime hashes, verified by deterministic rebuild.

Current runtime and limitations: [Oathbound motion](../../../../../docs/design/king-greatsword-oathbound-motion.md). These sources replace owner-rejected basic attack artwork; they do not establish new armor, gait or skills. Owner animation judgement remains open.

Owner-requested centering follow-up: after back hair attachment, the upper body/head move halfway toward carry center with a4-logical-texel cap. Lossless integer row shifts taper to zero at the lowest four boot rows; the foreground mask follows the same transform. Final gloves/steel anchors are registered afterward. `registration.json` records center_shift/neck_line/boot_line as pre-endpoint-override source registration landmarks. Head/torso retain their actual pixel art; raw source PNGs are unchanged. Current native proof: `art_source/review/combat/king_upward_centering_2026_10_05/`.
