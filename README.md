# Battle of Gods

Battle of Gods is a planned 2D top-down pixel action game for Godot 4.x. The player survives relentless dark-fantasy enemies through precise movement, positioning, dodging, weapon mastery, and divine or demonic abilities.

The setting centers on gods, demons, forgotten civilizations, and **The One Above**, the primordial creator whose existence shaped reality. The intended tone is ancient, mysterious, and epic, with simple pixel art, strong silhouettes, limited palettes, and highly readable combat effects.

## Current Status

Pre-alpha playable-level prototype. The expanded 30x18 world uses a pixel-stable following camera, varied bright terrain, deliberate tree/statue landmarks, staged Mireling/Thrall encounters, strict sprite animation, navigation, and the existing combat/defeat loop.

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
- `ROADMAP.md`: delivery status and priorities
- `CHANGELOG.md`: completed changes
- `KNOWN_ISSUES.md`: confirmed limitations and unresolved questions
- `DECISIONS.md`: compact ADR index with detailed history under `docs/decisions/`

## Setup

1. Install Godot 4.7 stable. The standard build is sufficient; .NET is not required.
2. Import `project.godot` from this repository in the Godot Project Manager.
3. Open the project and press **F6** for the current scene or **F5** for the project.

The current main scene is `res://levels/test_arena/test_arena.tscn`.

Command-line validation on this workstation:

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe' --headless --editor --path . --quit
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe' --headless --path . --quit-after 3
```

## Folder Structure

Current runtime content:

```text
res://
  levels/
    test_arena/
      test_arena.tscn
  project.godot
```

Prototype environment raster assets live in `res://assets/environment/prototype/`. Active character sheets and generated `SpriteFrames` live in `res://assets/characters/sprites_24x32/`. Reusable prop scenes live under `res://environment/props/`. Source atlases are retained for provenance; exact-grid sheets are the runtime assets.

The longer-term proposed structure is documented in `ARCHITECTURE.md`. Directories are created only with their first real asset.

## Controls

The active prototype controls are:

| Action | Keyboard/Mouse | Gamepad |
|---|---|---|
| Move | W/A/S/D | Left stick |
| Aim/facing | Mouse | Right stick |
| Primary attack | Left mouse | Right trigger |
| Dodge | Space | South face button |
| Ability 1 | Q | Left shoulder |
| Ability 2 | E | Right shoulder |
| Interact / enter portal | F | West face button |
| Pause | Escape | Start |
| Rise after defeat | R | North face button |

Movement, aim/facing, primary attack, dash, portal interaction, and arena restart after defeat are active. Ability actions are reserved and currently do nothing.

## Verification

Run the current headless movement smoke test with:

```powershell
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe' --headless --path . --script 'res://tests/player_movement_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe' --headless --path . --script 'res://tests/melee_combat_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe' --headless --path . --script 'res://tests/player_evade_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe' --headless --path . --script 'res://tests/forsaken_thrall_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe' --headless --path . --script 'res://tests/player_defeat_flow_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe' --headless --path . --script 'res://tests/character_animation_smoke.gd'
```

## Build and Export

Build targets and export presets have not been selected.
