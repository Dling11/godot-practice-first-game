# Iron Beard five-hit/head-thrust source

2026-10-06. Current chain: chop → rise → head thrust → hop slam → spin. No new body generation is used. The retained body-only push PNGs and body_registration.json in side/up/down reuse the earlier generated pushing poses while discarding the rejected handle-first weapon axes. The other twelve native cut clips supply accepted chop/rise/slam/spin. Each of fifteen clips delivers thirteen release/queue keys, including repeats/inherited entries:195 runtime pose slots.

The canonical Iron Beard texture is unchanged. The real pale cutting-edge texel(8,30), drawn primary grip(39,33) and source shaft(4,10) solve the third hit's rigid basis. Reflection follows side handedness. Head-forward contact is checked against actual rendered Player transforms in all four directions; the butt trails more than20 world pixels behind the cutting edge. The second one-hand anchor is orientation only. Two preparation keys turn the axe from the inherited rising-cut endpoint into the push.

Built-in imagegen generated thrust_source.png using thrust_style_reference.png, copied from the accepted four-row slash atlas. Exact prompt: [thrust_prompt.txt](thrust_prompt.txt). Original tool output remains at C:/Users/Administrator/.codex/generated_images/01a0eed4-5878-7032-a315-e493f92ce97a/exec-adc4fe6d-b832-4772-908d-85d73b4d9f63.png. The unmodified source is2172x724 RGBA with four chronological pressure-wave cels. No character/weapon is baked into this effect.

Offline ingestion removes alpha below16/255, uses actual empty-column gutters rather than assuming equal columns, and aligns each leading tip to(720,512) in a temporary canvas. The third source tip crosses the nominal1629 separator, so its real safe gutter is1637. Then one union crop and nearest scale gives104x80 raster content inside every padded128x128 runtime cel. The same transform/density applies across ignition, full impact, trailing pressure and breakup. Runtime thrust row2 uses origin(44,64) and1.1 texel scale. Original slash rows0/1/2/3 map unchanged to0/1/3/4; slash_preservation.json verifies every pixel, including alpha.

Runtime output is assets/characters/playable/king/axe_flow/:45 body/hand/resource files plus one512x640 five-row effect atlas. All31 PNG imports use lossless/no-mipmap settings and disabled alpha-border fixing; runtime presentation uses nearest filtering. Runtime frame count is20 effects, not20 independent hits.

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_axe_flow.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import
```

registration.json records source paths, rigid orientation and safe-gutter/tip/common-scale mapping. protected_before.json / protection_result.json verify328 untouched native/other-family art files and sidecars. runtime_hashes.json / generation_manifest.json record46 identical rebuild outputs and generated-source provenance. The former four-hit runtime/builder/data snapshots are kept in [the ignored archive](../../../../archive/king_axe_four_cut_before_thrust_2026_10_06/README.md); the handle-led weapon pose remains rejected.

[Native playback and actual contacts](../../../../review/combat/king_axe_head_thrust_2026_10_06/README.md), [rules/playtest](../../../../../docs/design/king-axe-cardinal-motion.md). Owner visual/motion judgment, measured balance, campaign crafting and device profiling remain open.
