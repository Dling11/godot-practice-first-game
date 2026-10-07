# Greatsword V2 polish: actual game proof

Godot4.7.2 Compatibility native renderer. tests/king_greatsword_v2_gameplay_smoke.gd -- --record completed184 checks/0 failures using the real Player and normal F9/F7/Bag equipment routes. Includes frontal/rear/outside contacts, new82px spin hitting an80px rear target once, all-facing buffering, world-fixed landing, collision steps, cancels, original V1 and Stage I carry.

[Right combo GIF](motion.gif), [left](left/motion.gif), [up](up/motion.gif), [down](down/motion.gif):55 actual captured frames per sequence, camera enlarged2.5x only. Timeline files store actual elapsed timestamps. This is gameplay-clock footage, not offline art playback. PNG encoding and GIF centisecond quantization affect recording; these files are not FPS/performance evidence.

[Native equipment tab](weapons_tab.png), [Bag](bag_v2.png), [jump load](jump_rear_load.png), [airborne](jump_airborne.png), [ground impact](jump_landing.png), [UP contact](up/contact.png), [DOWN contact](down/contact.png), [Stage I](stage_1_v2.png).

Related current validation:

- tools/review_greatsword_v2_cardinal.gd:1190/0 native checks, including all16-key directional clips, glove texels, vertical head/neck/chest connections, exact queued endpoints, atlas bounds and effect margins. [Contact gallery/checks](../king_greatsword_v2_polish_2026_10_07/cardinal_contacts.png).
- tests/player_held_attack_smoke.gd:46/0 native checks, injected world/UI mouse presses, all six full combos plus wraparound, release, single click, Weapons UI, paused release, focus loss, cinematic/NPC/dodge/skill cancellation and preservation of other queued intent.
- Side anatomy456/0, V1 gameplay146/0, native sword/axe/dual closure217/0, Lab sidebar26/0.
-38 runtime PNG/TRES outputs reproduce byte-identically;26 lossless/no-mipmap/no-alpha-border imports pass. All679 original archive copies match; no original V1 asset/data change. Shared Player/profile/adapter/presenter code and docs intentionally advance.

Recording fixture still reported60 ObjectDB/2-resource warnings at exit. These assertion passes do not establish clean teardown, exported builds, device performance, owner feel or final balance. Current verbose diagnostics are retained separately. [Latest source and exact built-in imagegen prompts](../../../generated/characters/king/greatsword_v2_polish_2026_10_07/README.md), [current guide](../../../../docs/design/king-greatsword-front-combo.md).
