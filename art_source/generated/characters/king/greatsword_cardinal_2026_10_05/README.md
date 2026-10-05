# King greatsword front/back body sources — 2026-10-05

Generated with Codex's built-in imagegen tool, then registered offline in Godot. These are body/hand sources for the existing huge greatsword, not new weapon designs or replacements for the accepted side-facing King.

**Current retained scope:** Oathbound replaces all basic attacks. This builder now emits only up/down carry/run from source key7 and keys40–47 (18 selected keys total). Superseded cardinal attack assets and a copy of the old builder are archived under `art_source/archive/greatsword_back_attachment_cleanup_2026_10_05/`. Raw PNGs/prompts/hashes remain unchanged. All12 retained carry/run files reproduce byte-identically after cleanup.

## Sources and exact prompts

- down_body_source.png: front/down, 1448×1086, 8 columns × 6 rows. Exact prompt: down_prompt.txt. References: original Spellward idle identity sheet and the accepted low-return key gallery for body/equipment scale.
- up_body_source.png: back/up, 1448×1086, matching 8×6 grid. Exact prompt: up_prompt.txt. References: original Spellward idle sheet and the generated front/down sheet.
- provenance.json records SHA256 hashes and reference roles. Original PNGs remain unmodified; generated alpha/pixel clusters are normalized only in derived runtime atlases.
- down_registration.json and up_registration.json now record the retained source keys/anchors/bounds. Raw generated rows remain sweep, rise, hop slam, turning cleave, low return and walk, eight keys each:96 source poses total, with18 retained for current carry/run derivation.
- missing_glove.png retains an initial ingestion diagnostic; it is not a runtime cel. Final build.log and import.log record the successful rebuilt assets.

## Rebuild and registration

From the repository root, run the installed Godot console with:

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/build_king_greatsword_cardinal.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import --quit
```

The shared extractor keeps whole sprite components before registration. Both directions use one density 54/136, nearest sampling and binary alpha at a 0.65 threshold. Logical cells are 192×128 with feet at Y95; runtime presentation uses the family's existing scale. Visible brown gloves determine the primary grip. The original rigid 30×140 steel, grip (15,113), tip (15,0) and neutral cutting-edge orientation are reused; no sword is painted into body cels.

Derived assets: `assets/characters/playable/king/greatsword_cardinal/{down,up}/`. Each direction retains shared carry and eight-key run only. Cardinal carry is an input to the newer readability idle builder, while the run remains current. Run uses alternating support/passing feet, authored back-mounted steel, no foreground holding mask and actual collision-checked travel. It deliberately differs from the side shoulder-held run. Source pose count does not set runtime phase duration. Attack entries/queue boundaries belong to the Oathbound builder.

Original huge blade and shallow planted/crossed-arm side idle remain. Current attacks use Oathbound; front/back proud AFK now comes from the readability idle builder, rather than this older source's carry clip. Skills, evade, reactions and Iron Beard's vertical bodies retain legacy artwork. No armor, campaign acquisition, default gear or new skill art is implied by this ingestion.

## Verification

Current native four-direction carry inspection and rebuild/hash verification are in `art_source/review/combat/king_back_attachment_2026_10_05/`. Earlier complete-cardinal gameplay/motion evidence remains historical in `king_greatsword_final_motion_2026_10_05/`. Owner animation feel and phone performance are separate from automated checks.
