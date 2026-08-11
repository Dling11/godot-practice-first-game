# Battle of Gods

Battle of Gods is a planned 2D top-down pixel action game for Godot 4.x. The player survives relentless dark-fantasy enemies through precise movement, positioning, dodging, weapon mastery, and divine or demonic abilities.

The setting centers on gods, demons, forgotten civilizations, and **The One Above**, the primordial creator whose existence shaped reality. The intended tone is ancient, mysterious, and epic, with simple pixel art, strong silhouettes, limited palettes, and highly readable combat effects.

## Current Status

Pre-alpha title-to-Sanctuary-to-three-stage prototype. F5 opens a mouse/keyboard/gamepad-ready Battle of Gods title screen with Continue, guarded New Journey, and session-audio settings. King is temporarily the active combat proof with simple four-direction locomotion, an integrated signature sword, one directional basic slash, the owner-approved Echoing Sever Skill 1, and Riftbreak's temporary-presentation Skill 2 self-AOE proof; Skills 3-4 remain visibly sealed. Opaw's complete compact character and skills remain preserved as benched supported content. Stages I-III form one continuous forest arc ending with the Rootbound Husk mini-boss and a return portal to Sanctuary. The five current enemies roll sparse illustrated Forest materials as hopping, hovering, magnetic world pickups. Stages I-II bank collected materials and open their portals directly; Stage III adds guaranteed Husk materials and a distinct colliding Rootbound Reliquary payout. In Sanctuary, Rootweaver Nema's Living Rootforge previews the four current recipes and owned/required materials without consuming anything. Crafting transactions/outputs, Hunts, roster switching, King Skills 3-4, and per-character saves are not yet playable.

## Intended Technology

- Engine: Godot 4.7 stable
- Language: GDScript unless a measured performance need justifies another option
- Game format: 2D top-down pixel action
- Initial development target: desktop; release platform priorities are not yet decided

The prototype uses a 960x540 logical viewport displayed at 1920x1080 for exact 2x pixel scaling. GL Compatibility rendering, nearest-neighbor filtering, and pixel snapping remain enabled.

## Repository Documents

- `GAME_DESIGN.md`: game vision, rules, world, and planned content
- `PROJECT_CONTEXT.md`: compact current-state entry point and task-based documentation router
- `ARCHITECTURE.md`: technical boundaries and proposed project structure
- `STYLE_GUIDE.md`: code, scene, signal, and asset conventions
- `ART_DIRECTION.md`: visual theme, palette roles, pixel baselines, and replaceable-art rules
- `ASSET_CATALOG.md`: canonical asset identities, paths, status, dimensions, and runtime owners
- `ROADMAP.md`: delivery status and priorities
- `CHANGELOG.md`: completed changes
- `KNOWN_ISSUES.md`: confirmed limitations and unresolved questions
- `DECISIONS.md`: compact ADR index with detailed history under `docs/decisions/`

## Setup

1. Install Godot 4.7 stable. The standard build is sufficient; .NET is not required.
2. Import `project.godot` from this repository in the Godot Project Manager.
3. Open the project and press **F6** for the current scene or **F5** for the project.

The current main scene is `res://ui/screens/title/title_screen.tscn`. Stage 1 remains `res://levels/test_arena/test_arena.tscn`.

The game maintains one autosave at `user://battle_of_gods_profile.json` with a `.bak` recovery copy. Continue always resumes in Sanctuary. Autosaves occur on Sanctuary entry, Sanctuary purchase/equip/awakening actions, and stage clear after direct banking or a milestone chest claim—not during active combat. The profile includes versioned material quantities, recipe discoveries, first-clear claims, and drop-protection counters; older version-1 saves whose reserved extension sections are empty remain compatible. The exact operating-system location of `user://` is shown by Godot's **Open User Data Folder** command.

Stages I-III use authored Godot `TileMapLayer` cells rather than runtime-random ground. Shared forest and Rootbound Hollow atlases live under `assets/environment/forest/`; diffable map layouts live under `data/environment/layouts/`. Edit baked cells directly in Godot for local adjustments, or update a layout resource and regenerate the owning scene with `tools/bake_authored_ground.gd` for a whole-map revision.

### Isolated 2D Asset Preview

Supported Sanctuary prop and NPC scenes include an `EditorPreviewBackdrop` child. When one of those asset scenes is opened directly, Godot displays a subtle green checker behind transparent sprites and dark shadows. The backdrop automatically disappears when the asset is instanced in a level and never draws during F5/F6 or an exported game. Select the backdrop node to adjust its preview size, center, checker scale, or colors for that scene.

Current Sanctuary houses use `Polygon2D` for visual shadows and `CollisionPolygon2D` for editable physics footprints. Select the house's `Collision` child in the 2D editor to drag or add collision vertices; editing `Shadow` changes only presentation and never blocks the player.

Command-line validation on this workstation:

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --editor --path . --quit
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --quit-after 3
```

## Folder Structure

Current runtime content:

```text
res://
  levels/
    test_arena/
      test_arena.tscn
    stage_2/
      stage_2.tscn
    sanctuary/
      sanctuary.tscn
  ui/
    equipment/
      equipment_slot_card.tscn
      equipment_detail_panel.tscn
    inventory/
      inventory_slot_button.tscn
    skills/
      skill_bar_slot.tscn
      skill_slot_card.tscn
    screens/title/
      title_screen.tscn
  data/
    expeditions/
      forgotten_grove.tres
      rootbound_hollow.tres
      drowned_bells.tres
    items/
      opaw_weapon_catalog.tres
      materials/
        material_catalog.tres
        forest/
    loot/
      forest/
        enemies/
        stages/
    crafting/recipes/
      recipe_catalog.tres
      forest/
    skills/
      opaw_starting_loadout.tres
    weapons/
      ashwood_blade.tres
      iron_sword.tres
      attack_styles/
  assets/
    characters/playable/opaw/
      compact_armless/
        opaw_compact_armless_*_sheet_*.png
        opaw_compact_armless_sprite_frames.tres
      variants/wayfarer_original/
        opaw_wayfarer_original_*_sheet_*.png
        opaw_wayfarer_original_sprite_frames.tres
    characters/npcs/
      skillkeeper/skillkeeper_idle_sheet_48x48.png
      armskeeper/armskeeper_idle_sheet_48x48.png
    environment/sanctuary/
      buildings/skillkeeper_lodge_128x192.png
      buildings/armskeeper_workshop_176x192.png
      shops/armskeeper_cart_128x96.png
    items/weapons/
      world/ashwood_blade_16x24.png
      world/iron_sword_16x24.png
      icons/ashwood_blade_64x64.png
      icons/iron_sword_64x64.png
    items/materials/forest/
      *_24x24.png
    gameplay/loot/stage_clear_chest/
      forest_stage_clear_chest_closed_64x48.png
      forest_stage_clear_chest_open_64x48.png
      rootbound_reliquary_closed_72x64.png
      rootbound_reliquary_open_72x64.png
  autoload/
    run_session.gd
    story_state.gd
    weapon_inventory.gd
    material_inventory.gd
    recipe_discovery.gd
    loot_state.gd
    loot_service.gd
    save_service.gd
  project.godot
```

King's active proof art lives under `res://assets/characters/playable/king/simple_reboot/`. Opaw's benched compact art remains under `res://assets/characters/playable/opaw/compact_armless/`, with the complete Wayfarer rollback under `variants/wayfarer_original/`. Superseded/rejected experiments are organized under Godot-ignored `art_source/archive/`. All current enemy runtime art lives in named domains under `res://assets/characters/enemies/`. Exact-grid sheets under `assets/` are active or explicitly supported runtime files.

King's active proof, Opaw's supported bench package, Ashwood Blade, current Sanctuary assets, Rootling's runtime atlases, and the original level-up chime can be regenerated from their active sources with:

```powershell
& 'C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'tools/process_king_simple_locomotion.py'
& 'C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'tools/generate_riftbreak_sfx.py'
& 'C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'tools/process_riftbreak_vfx.py'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/apply_opaw_attack_vertical_revision.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_opaw_compact_armless_assets.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_opaw_modular_assets.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_iron_sword.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/build_character_sprite_frames.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_mireling_walk_assets.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_mireling_action_assets.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/build_mireling_sprite_frames.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_sanctuary_direction_board.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_sanctuary_individual_assets.gd'
& 'C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools/process_rootling_atlas.py art_source/generated/characters/enemies/rootling/final/rootling_walk_board_clean.png assets/characters/enemies/rootling/rootling_walk_sheet_32x32.png --columns 4 --rows 4 --cell-width 32 --cell-height 32 --content-width 27 --content-height 26 --preserve-first-row-height
& 'C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools/process_rootling_atlas.py art_source/generated/characters/enemies/rootling/final/rootling_reaction_board_clean.png assets/characters/enemies/rootling/rootling_reaction_sheet_32x32.png --columns 4 --rows 4 --cell-width 32 --cell-height 32 --content-width 27 --content-height 28
& 'C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools/process_rootling_atlas.py art_source/generated/characters/enemies/rootling/final/rootling_root_jab_vfx_board_clean.png assets/characters/enemies/rootling/rootling_root_jab_vfx_sheet_48x48.png --columns 4 --rows 4 --cell-width 48 --cell-height 48 --content-width 44 --content-height 44
& 'C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools/build_level_up_sfx.py
```

The longer-term proposed structure is documented in `ARCHITECTURE.md`. Directories are created only with their first real asset.

## Controls

The active prototype controls are:

| Action | Keyboard/Mouse | Gamepad |
|---|---|---|
| Move | W/A/S/D | Left stick |
| Combat facing | W/A/S/D movement direction; last direction is retained while standing | Left stick movement direction |
| Primary attack: equipped sword | Left mouse | Right trigger |
| Dodge | Space | South face button |
| Skill 1: Echoing Sever targeting | 1 or click its HUD slot | Left shoulder |
| Confirm Echoing Sever | Left mouse | Right trigger |
| Cancel Echoing Sever | Right mouse or Escape | UI Cancel |
| Skill 2: Riftbreak self-AOE | 2 or click its HUD slot | Reserved |
| Skill slots 3-4 | 3 / 4 (reserved) | Reserved |
| Open character / gear / skills | Tab or click the HUD satchel button | Not assigned |
| Interact / claim reward chest / enter portal | F | West face button |
| Close / cancel modal | Escape or visible mouse button | UI Cancel |
| Open Menu | Escape/Start or top-right Menu button | Start |
| Rise after defeat | R | North face button |
| Debug test loadout | F9 (debug builds: level 10, 999 coins, authored skills/gear, material UI samples) | Not assigned |

Movement, movement-owned facing, left-click primary attack, dash, portal interaction, and arena restart after defeat are active for the temporary King proof. Pressing basic attack during dash movement queues one normal slash for dash completion; pressing it during vulnerable recovery cancels that recovery into the attack. Balanced Slash currently supplies the tested 58-pixel-forward by 96-pixel-wide contact fan, while King's integrated sword and white-blue trail present the hit. Echoing Sever is active in Skill 1: press `1`, aim its smooth exact-angle wedge while continuing to move, then left-click/right-trigger to commit; repeating `1` does not cast, right-click/Esc cancels freely, and dash cancels the preview before moving. Riftbreak is active in Skill 2: press `2` to immediately slam one 84-pixel circle around King's feet for 150% weapon damage and outward knockback; its expanding fracture ring is mechanics-proof presentation. Skills 3-4 remain sealed, and Opaw's preserved Piercing Rush and Consecutive Thrust are not silently attached to King. The shared proof vitality still begins at 140, gains 12 per level, retains health across stages, and regenerates 1 HP/s after five damage-free seconds. F9 grants level, coins, gear, and material samples without changing King's skill loadout.

During normal stage play, an ordinary defeated enemy rolls its authored sparse common and secondary material chances; sixth/twelfth-attempt protection prevents an unlimited drought, while the Rootbound Husk always drops its two signature materials. A successful stack hops from the death point, gently hovers for half a second, and then flies to Opaw automatically; touching it sooner also collects it. The upper-right toast identifies the material and quantity. After the final wave, Stages I-II bank collected materials and open their portals directly. Stage III instead summons the larger solid, Y-sorted Rootbound Reliquary through a rune reveal; press F to claim its guaranteed pool of ordinary Forest materials, release its collision, and open the return portal. The Reliquary grants no recipe unlock. Defeat, restart, or Return to Sanctuary before direct clear or chest claim removes that expedition's uncommitted materials.

In Sanctuary, approach Skillkeeper Eira or Armskeeper Orren and press F. The character surface opens from Tab or the HUD satchel. Its Character & Bag page surrounds the live King preview with seven equipment positions and a compact 24-slot filtered grid; the detached equipment sword preview is hidden because King already carries his signature sword. Equipment still supplies compatibility stats during this proof. Eira cannot awaken Opaw's Skill 2 for King; the Skills page presents Echoing Sever and Riftbreak as equipped while Skills 3-4 remain in development. Orren still sells Iron Sword for 90 coins as compatibility equipment. HUD buttons consume their own pointer clicks, so clicking dash or a sealed skill never also triggers basic attack.

## Verification

Run the current headless movement smoke test with:

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/player_movement_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/player_control_scheme_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/dash_attack_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/melee_combat_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/player_evade_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/forsaken_thrall_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/rootling_behavior_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/player_defeat_flow_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/character_animation_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/opaw_model_backup_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/piercing_rush_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/consecutive_thrust_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/enemy_crowd_control_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/sweeping_cut_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/player_progression_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/run_session_progression_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/save_profile_snapshot_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/save_disk_persistence_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/safe_milestone_autosave_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/title_continue_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/expedition_unlock_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/character_menu_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/equipment_preview_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/sword_attack_style_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/runtime_archive_boundary_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/audio_director_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/combat_audio_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/ui_theme_icon_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/title_screen_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/sanctuary_hub_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/skill_awakening_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/hud_action_controls_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/editor_preview_backdrop_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/loot_resolution_smoke.gd'
```

## Build and Export

Build targets and export presets have not been selected.
