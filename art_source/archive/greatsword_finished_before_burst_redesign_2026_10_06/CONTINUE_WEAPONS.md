# Continue Battle of Gods weapon work

Start with PROJECT_CONTEXT.md, ROADMAP.md and KNOWN_ISSUES.md, then ARCHITECTURE.md/STYLE_GUIDE.md/GAME_DESIGN.md and [current closure](docs/design/king-weapon-closure.md). Runtime scenes/data are truth. Preserve the dirty tree; user commits/pushes manually.

**Owner restriction: do not touch Royal Greatsword.** They have a fresh idea pending. Preserve its data,30×140 steel, accepted motion/idle/run, icon/description and old audio. Shared changes must remain opt-in/backward-compatible. The closure proof records730 protected original files unchanged.

Current sword/axe/dual: base rolls10–12/14–16/9–11, Skill Power25, nominal chains1.91/3.52/2.20s, base DPS21.9/26.2/24.1. Axe has60 base knockback and0.12s flinch. All existing body/steel/FX, phase timings, shapes and gait remain accepted. Do not regenerate the approved walking/grip/head/body pipeline to change an item icon. Twinsteel icon now visibly shows two blades; it remains one equipment slot and one contact per enemy per input.

Normal basic hits use the CC0 qubodup body-impact layer with three static variants and family pitch/gain. Source pack/page/processing/hashes are retained; original synthesis is archived and no longer has a runtime builder. Existing swing/skill/incoming-damage cues remain. Never replace the shared legacy sword_hit.wav while Greatsword is frozen.

Test F5 → F9 → Tab → equip → F7. Builders are tools/build_weapon_bag_icons.gd and tools/build_weapon_contact_audio.gd. Godot console path D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe currently reports4.7.2; use --audio-driver Dummy for automation, real audio for owner play. Native closure test: tests/weapon_finalize_smoke.gd. [Proof/limits](art_source/review/combat/weapon_finalize_2026_10_06/README.md). The catalog smoke's old4-item expectation is corrected to5. F9 remains non-saving; acquisition/recipes are not implemented.

Next: owner checks these three in actual play. Then create **scythe weapon design samples first**, preserving King anatomy/palette/outline and existing art density. Proposed role to discuss: slower sweeping reach/control between fast dual and heavy axe, with a readable hooked blade. Do not build attack frames until the weapon silhouette/grip is accepted; owner previously rejected axe/scythe silhouettes. Follow existing architecture: one canonical rigid steel, complete body cels/real grips/masks, contact authority separate from FX, four directions, connected queue/release branches and real travel-driven gait. Scythe is planned, not present in the catalog.

Remaining: owner audio/feel approval, comparative encounter/campaign balance, acquisition recipes/stages, optional family-specific skill/reaction art and device profiling. No broad cleanup of assets still consumed by approved motion builders.
