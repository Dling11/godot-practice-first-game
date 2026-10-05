# Upward Greatsword slash correction — 2026-10-05

**Historical, owner-rejected and removed.** The owner clarified that the real upper defect was sideways head/torso placement and disliked this upward-only smaller white scale. Current hair-only correction/shared effects: [current proof](../king_back_attachment_2026_10_05/README.md). Calibration/test scripts and former resource field are archived under `art_source/archive/upward_slash_fit_rejected_2026_10_05/`. The results below record the earlier experiment, not current gameplay or owner acceptance.

Owner approves movement and reports upper attack artwork clipping. Live native inspection found ordinary white slash tips/ends truncated by the contact mesh. Body/sword resources are unchanged. The installed upward row maps fit complete raster envelopes inside the original contacts. They use the real elevated SwordPivot, with separate meteor frame mapping taking precedence.

`comparison.png`: first/fourth ACTIVE examples; **before left, corrected right**. `before/` and `after/` contain real Player native captures at4× actor scale and queued-chain timelines. Each captures46 distinct phase/pose states; unobserved slots in galleries are not missing sprites. Both use fixed60Hz native rendering. Corrected white art is fitted, so its entire shape is visible at a smaller drawing scale.

`slash_registration.json` records full opaque envelopes, old out-of-contact texel counts, fixed scales/placements and4px contact clearance. Row2 is metadata only; meteor registration overrides it. `upward_swing_samples.txt` is the exact generated resource field installed in Royal Greatsword presentation. No new image generation or runtime image modification was used.

`anatomy_inspection.json` and anatomy galleries are offline raw/registered/head-composited comparisons. The old inspection did not investigate the sideways head/collar graft correctly; complete alpha bounds did not prove anatomical alignment. The current correction changes that up composition and preserves the original moving collar.

Native Godot4.7.2 Compatibility validation:

- `slash_validation.json` / `slash_native.log`:48/0. Actual Player trail compared with an unclipped source Sprite in separate transparent viewports; all16 ordinary upward frames have zero missing reference pixels. Every opaque source texel fits inside the original damage polygon with at least4px clearance. Slam retains four blade-registered samples.
- `motion_native.log`:2771/0, full five-hit/all-facing/axe motion authority and complete body anatomy, without the130 capture-file checks.
- `readability_native.log`:158/0, actual phase walking, knockback/dodge and upward body visibility.
- `atlas_native.log`:6/0, neighbor-cell fencing/cancellation.
- `gameplay_native.log`:151/0, actual Sanctuary/Bag weapon routing and gameplay.
- `practice_native.log`:17/0, visible practice Bag/Tab/Esc, movement/attack and F9.
- `preservation_validation.json`:55 original body/hand/clip files remain byte-identical; calibration field exactly matches the installed profile.

Practice behavior passes, while its transition fixture still reports the existing57 ObjectDB instances at process exit. That diagnostic debt remains recorded in `KNOWN_ISSUES.md`; it is separate from the confirmed slash coverage and input results. Import reports no script/resource errors.

An early fitted-preview used King's feet rather than the elevated contact pivot. Its discarded comparison PNGs are labelled in `diagnostic_initial_fit/`; they are not final proof. Final ordinary frame comparisons lose zero pixels. No runtime asset uses that discarded placement.

These are retained historical files. The calibration/test are no longer active commands and depend on the removed profile schema. The capture tool now writes to the new anatomy review directory so it cannot overwrite these before/after samples. Use the current proof README for reproduction and testing.
