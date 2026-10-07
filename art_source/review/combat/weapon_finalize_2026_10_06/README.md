# Weapon closure: native proof and auditions

2026-10-06, Godot4.7.2.stable.official.ed1daf0bf, native OpenGL compatibility renderer on AMD Radeon, Dummy audio driver for automation. The focused test checks real audio players/streams/bus/pitch/gain, not physical speaker output or owner sound preference.

## Delivered

Sword/axe/dual have approved-raster icons,64px Bag inspection, accurate role descriptions, per-cut damage and base DPS. Initial normal damage rolls10–12 /14–16 /9–11;25 Skill Power and all existing animation/timing/reach remain. Axe base knockback60/0.12s flinch. Recorded CC0 body impacts play once per accepted swing with family pitch/gain. Greatsword is frozen.

## Native checks

| Check | Result | Evidence |
|---|---|---|
| Focused real Lab/Bag/health/contact/audio |217 /0|native_final.log, validation.json|
| Existing equipped Twinsteel/Bag/skills/dash/swap/Stage I |244 /0|twinsteel_gameplay.log, twinsteel/validation.json|
| Existing equipped axe/Bag/contacts/swaps |138 /0|axe_gameplay.log, axe/validation.json|
| Typed damage/armor regression |50 /0|typed_damage.log|
| Combat audio bindings |pass|combat_audio.log|
| Equipment catalog / preserved Varkuun stats |pass|equipment_catalog.log|
| Repeat icon + audio build |6 byte-identical outputs|runtime_hashes.json, rebuild_result.json|
| Original actor art/audio + Greatsword files |730 /730 unchanged|protected_before.json, protection_result.json|

649 counted gameplay assertions pass, plus two pass/fail smoke scripts. Fresh editor import finishes without parse/resource errors in import_closure.log. The first new-asset import log records expected pre-import load errors; subsequent fresh imports resolve them. Do not confuse the historical first scan with the final result.

Focused assertions exercise both target contacts per cut, no duplicated paired-blade damage, actual health loss within displayed ranges, physical typing and armor mitigation, committed knockback, exact authored phase durations, silent misses, one shared native impact per cleave,64px Bag previews, close/resume, sorting, legacy Greatsword42px inspection/stats and exact old sound stream/pitch/gain fallback. Damage/DPS figures in validation.json are nominal unbuffed per-target arithmetic.

Known harness limits: the existing axe test reports57 ObjectDB instances at teardown; the typed-damage fixture reports7 instances/3 resources. Both return successful gameplay checks. Focused closure and Twinsteel runs exit without those diagnostics. They are not claimed fixed here. Builders load source PNGs offline and emit Godot's ordinary export warning; they are not runtime/export code.

## Review in game

Restart F5 → F9 → Tab → equip sword/axe/dual → F7. F9 suppresses saving. Test several full combos and misses, then swap between weapons. Owner ear/feel approval, actual speaker playback, final campaign balance, acquisition and device performance remain open.

Native screenshots: [sword Bag](sword_bag.png), [axe Bag](axe_bag.png), [dual Bag](dual_bag.png). Actual paper-doll presentation is retained; dual item preview displays both blades.

Audio auditions render the three installed recordings at each actual profile's pitch/gain, separated by gaps: [sword](sword_impacts.wav), [axe](axe_impacts.wav), [dual](dual_impacts.wav). The source is [Impact by qubodup, CC0](https://opengameart.org/content/impact); processing/hashes/levels/durations are in audio_manifest.json and [credit/source record](../../../../assets/audio/ATTRIBUTION.md).

Rebuild from project root using the existing Godot console:

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --audio-driver Dummy --path . --script res://tools/build_weapon_contact_audio.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_weapon_bag_icons.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility --audio-driver Dummy --fixed-fps 60 --script res://tests/weapon_finalize_smoke.gd
```

[Current rules](../../../../docs/design/king-weapon-closure.md), [continue handoff](../../../../CONTINUE_WEAPONS.md). Preserve the Greatsword freeze before starting scythe samples.
