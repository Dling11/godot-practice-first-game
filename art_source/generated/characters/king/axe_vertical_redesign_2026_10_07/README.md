# Fresh Iron Beard vertical attack sources

2026-10-07. The owner rejected Decision192 as a sufficient redesign: changing proportions left the old vertical attack, spin and impact choreography. These are new generated body and effect sources, rather than a re-fit of the old attack rasters.

`down_source.png` and corrected `up_source.png` contain five rows of eight body studies: chop, rising cut, head push, jump slam and full turn. `up_jump_source.png` replaces the rear jump row with eight newly generated overhead loading/airborne/forward-landing poses; the original rear landing placed the striking arm behind the hips. Its source grip now reaches ahead above the crown, matching the UP impact. The complete eight-pose turn from the front sheet is shared with a half-turn phase offset for UP, retaining actual front/side/back anatomy. Of88 selected source studies,64 distinct generated poses enter the compiled attacks; unused opening guards and the superseded UP spin/jump studies remain source history. Source opening guards are replaced by exact installed ready/previous queued endpoints. The native front/rear/side heads and palette come from the accepted Twinsteel/Greatsword baseline, while complete generated torsos, arms, scarf and legs provide the new motion. Canonical Iron Beard steel remains independent and registers at actual source gloves.

The two effect sheets each supply five four-frame sequences. They depict white/silver energy across the ground plane, with broad directional cuts, head-push burst, flattened landing burst and elliptical spin. Transparent projection gutters, rather than equal nominal grid cuts, isolate whole effects; fixed column anchors and shared row density retain registration. Native capture caught neighboring-frame fragments in the first grid extraction, now corrected in the builder. Faint alpha noise and blue fringe are removed before nearest ingestion. No vector replacement or runtime effect generation is used.

`registration.json` records raw assembled source-key anatomy before the ready/queued endpoint copies, plus final effect gutters. The compiled TRES arrays contain the final installed endpoint coordinates; native tests validate those arrays and images together. Do not mistake a discarded source opening guard record for the selected runtime opening.

`up_initial_rejected.png` is historical: it showed front heads in rear motion. The initial old-reference effect attempts remained outside the runtime build because they copied tall side crescents. `prompts.json` records those generation instructions; `final_effect_prompts.json` records the independent ground-plane prompts. Original tool outputs are retained separately by the generator. See `generation_manifest.json` for selected inputs and `registration.json` for source bounds, actual grips, head views, lift and extraction gutters.

Rebuild from the repository with Godot4.7.2:

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_axe_vertical_v2.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --editor --path . --import --quit
```

The builder reads `presentation_baseline.tres`, not its own output or the installed profile. It writes33 PNG/TRES files under `assets/characters/playable/king/axe_vertical_v2/`, including the candidate profile. It never overwrites accepted side attacks, older carry/gait, canonical steel or another family. The stock profile is selected separately after native review. The old flow builder remains responsible for its retained side/carry inputs; it cannot select the new runtime motion automatically.

Native source sleeves erased by the rectangular head transplant must be restored from original source pixels, outside the central native face. Do not synthesize arms, scale each cel separately or loosen connected-anatomy checks to hide cropping. Attack soles remain on94; hop lift is metadata, while ACTIVE begins with grounded contact. Effects only draw presentation; the existing melee component owns all damage, shapes, cadence and knockback.

[Current guide](../../../../../docs/design/king-axe-cardinal-motion.md), [native preview and protected-file proof](../../../../review/combat/king_axe_vertical_redesign_2026_10_07/README.md).
