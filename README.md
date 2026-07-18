# Battle of Gods

Battle of Gods is a planned 2D top-down pixel action game for Godot 4.x. The player survives relentless dark-fantasy enemies through precise movement, positioning, dodging, weapon mastery, and divine or demonic abilities.

The setting centers on gods, demons, forgotten civilizations, and **The One Above**, the primordial creator whose existence shaped reality. The intended tone is ancient, mysterious, and epic, with simple pixel art, strong silhouettes, limited palettes, and highly readable combat effects.

## Current Status

Pre-alpha title-to-Sanctuary-to-two-stage prototype. F5 opens a mouse/keyboard/gamepad-ready Battle of Gods title screen with session-audio settings; Begin the Awakening fades into a safe generated-pixel Sanctuary with a separate divine fountain, walk-in angel portal, Skillkeeper Eira, and Armskeeper Orren. The active mortal player is Opaw, a compact armless Novice Warrior whose stable-scale body uses a detached equippable sword; his complete previous Wayfarer model is preserved as a runtime backup. Stage 1 teaches Mireling and Thrall combat; Stage 2, `Thorns of the Forgotten Grove`, introduces the Bramble Spitter and returns to Sanctuary when cleared. An in-memory level-10 XP/coin run, reusable four-slot skills, class-gated owned weapon inventory, Orren shop, and Ashwood/Iron switching are active. Disk saving, drops, armor bonuses, character switching, and additional skills are not yet implemented.

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
      equipment_item_card.tscn
      equipment_slot_card.tscn
      equipment_detail_panel.tscn
    skills/
      skill_bar_slot.tscn
      skill_slot_card.tscn
    screens/title/
      title_screen.tscn
  data/
    expeditions/
      forgotten_grove.tres
      ashen_pilgrimage.tres
      drowned_bells.tres
    items/
      opaw_weapon_catalog.tres
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
  autoload/
    run_session.gd
    story_state.gd
    weapon_inventory.gd
  project.godot
```

Prototype environment raster assets live in `res://assets/environment/prototype/`. Opaw's active compact armless runtime art lives under `res://assets/characters/playable/opaw/compact_armless/`; the complete previous Wayfarer model remains the only supported runtime rollback under `variants/wayfarer_original/`. Superseded Awakened art, rejected Opaw experiments, and replaced Sanctuary service assets/scenes/code are organized under Godot-ignored `art_source/archive/`. All current enemy runtime art lives in named domains under `res://assets/characters/enemies/`. The shared UI theme and individually replaceable named icons live under `res://assets/ui/`. Reusable prop scenes live under `res://environment/props/`. Exact-grid sheets under `assets/` are active or explicitly supported runtime files.

Opaw's active compact armless sheets, the earlier Wayfarer pipeline, Ashwood Blade, and current Sanctuary assets can be regenerated from their active sources with:

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/apply_opaw_attack_vertical_revision.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_opaw_compact_armless_assets.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_opaw_modular_assets.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_iron_sword.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/build_character_sprite_frames.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_sanctuary_direction_board.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_sanctuary_individual_assets.gd'
```

The longer-term proposed structure is documented in `ARCHITECTURE.md`. Directories are created only with their first real asset.

## Controls

The active prototype controls are:

| Action | Keyboard/Mouse | Gamepad |
|---|---|---|
| Move | W/A/S/D | Left stick |
| Aim/facing | Mouse | Right stick |
| Primary attack: equipped sword | Left mouse | Right trigger |
| Dodge | Space | South face button |
| Skill 1: Sweeping Cut | 1 (Q legacy fallback) | Left shoulder |
| Skill slots 2-4 | 2 / 3 / 4 (reserved) | Reserved |
| Open character / gear / skills | Tab or click the HUD satchel button | Not assigned |
| Interact / enter portal | F | West face button |
| Close / cancel modal | Escape or visible mouse button | UI Cancel |
| Rise after defeat | R | North face button |

Movement, aim/facing, primary attack, dash, Sweeping Cut, portal interaction, and arena restart after defeat are active. Slots 2-4 are visibly sealed and currently do nothing. XP and coins survive portal transitions within the running game; defeat restart begins a new run.

In Sanctuary, approach Skillkeeper Eira or Armskeeper Orren and press F. To use the angel portal, walk around either side of the standalone fountain, cross the open courtyard, and ascend the portal's center stairs; its prompt appears only at the doorway threshold. The character surface opens from physical Tab or the clickable top-left satchel button. Dialogue and menu controls support mouse click or arrow-key focus plus Enter; Escape cancels the active modal, and the character surface also has a top-right close button. Its Gear tab lists owned weapons; clicking a compatible sword equips it immediately. Ashwood is Opaw's permanent fallback, while Orren sells the Warrior-only Iron Sword for 18 coins. Skills are never sold: future level-eligible skills will be awakened through Eira. The portal builds its routes from expedition data: Forgotten Grove opens after Sanctuary awakening, while later routes display real unmet level/story/boss/discovery/key-item requirements and remain sealed until their scenes exist.

## Verification

Run the current headless movement smoke test with:

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/player_movement_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/melee_combat_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/player_evade_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/forsaken_thrall_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/player_defeat_flow_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/character_animation_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/opaw_model_backup_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/sweeping_cut_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/player_progression_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/run_session_progression_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/expedition_unlock_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/character_menu_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/equipment_preview_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/sword_attack_style_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/runtime_archive_boundary_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/audio_director_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/ui_theme_icon_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/title_screen_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/sanctuary_hub_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/editor_preview_backdrop_smoke.gd'
```

## Build and Export

Build targets and export presets have not been selected.
