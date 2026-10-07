**Rejected/superseded on2026-10-06:** Owner rejected the handle-led jab. This retained source/proof describes that historical edition; current game uses a rising blade cut and complete slashes. See the matching axe_rise_2026_10_06 folder and docs/design/king-axe-cardinal-motion.md.

# Iron Beard connected exchange: retained source

2026-10-06. Owner requests old third chop first, a grounded straight second thrust, jumping/spinning follow-ups and less sliding. Built-in imagegen generated one transparent three-row ten-column body-only jab sheet from the approved King cardinal board and canonical Iron Beard reference. Exact prompt: `jab_prompt.txt`; unmodified tool result: `jab_source.png`. Original output also remains at `C:/Users/Administrator/.codex/generated_images/01a0eed4-5878-7032-a315-e493f92ce97a/exec-5416397e-453d-4aa2-9824-86cc711079a6.png`.

`side_identity.png`, `down_identity.png` and `up_identity.png` copy native carry/idle cel0 for inspection. `registration.json` records fixed density, actual head/sole/glove landmarks and30 new jab cels. No weapon or slash is baked into these bodies.

`tools/build_king_axe_flow.gd` registers jabs to native King head/palette and sole94 using retained offline cardinal anatomy helpers. Other cuts copy accepted chop/hop/spin into a13-key release/queue layout. Four cuts x13 keys x3 authored views =156 delivered pose slots, including reused/repeated cels, not156 new generations. Left mirrors side. Exact queued endpoints are inherited; release returns to existing guard. The same canonical axe registers to brown gloves and its handle butt leads the jab. Full reflected rigid bases retain handedness; angle-only interpolation is disabled for this exchange.

Output: `assets/characters/playable/king/axe_flow/`,36 body/mask/resource files plus one four-row effect atlas. Chop/slam/spin copy old FX rows2/3/4; four jab pulses reuse generated Twinsteel row0 in the real narrow contact lane. The builder writes only this new folder and its registration manifest. Accepted originals, idle and gait remain intact. Normal profile/contact/timing/movement data are deliberate separate edits.

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_axe_flow.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import
```

Use nearest filtering, lossless imports, no mipmaps and `process/fix_alpha_border=false`. `protected_before.json`/`protection_result.json` distinguish intentional Iron Beard combo/profile edits from395 unchanged protected files. `runtime_hashes.json`/`generation_manifest.json` retain rebuild evidence. Native proof and limits are in the matching review README. Static atlases alone do not prove runtime weapon orientation or visible effects.
