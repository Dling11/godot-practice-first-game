# Battle of Gods

Battle of Gods is a planned 2D top-down pixel action game for Godot 4.x. The player survives relentless dark-fantasy enemies through precise movement, positioning, dodging, weapon mastery, and divine or demonic abilities.

The setting centers on gods, demons, forgotten civilizations, and a divine Game architected by the being titled **The One Above**. The title does not establish that he created reality or is the strongest being; the intended story slowly questions the hierarchy behind the Game. The tone is ancient, mysterious, and epic, with simple pixel art, strong silhouettes, limited palettes, and highly readable combat effects.

## Current Status

King C review (September 14): press **F7 -> KING REVIEW** for the isolated playable comparison. LOOK switches appearance; SPEED cycles gear/base/existing caps; VIEW changes magnification; HIT/STUN sample real control reactions with health restored; REACH outlines the real melee shape. Existing Lab controls spawn enemies and toggle AI/invincibility. [Latest idle/walk/outline review](art_source/review/characters/king/spellward_locomotion_2026_09_14/index.html) · [Initial full action review](art_source/review/characters/king/spellward_lab_2026_09_14/index.html). Restart an already-running review to load updated art. This is opt-in art review; campaign King and skill rules remain unchanged. Direct debug launch also accepts `res://levels/combat_lab/combat_lab.tscn -- --king-review`.

Pre-alpha title-to-Sanctuary-to-six-stage prototype. F5 opens a mouse/keyboard/gamepad-ready Battle of Gods title screen with Continue, guarded New Journey, and session-audio settings. King is the sole production player with four-direction locomotion, an integrated signature sword, a physical three-cut basic chain, and ten equipped slots drawn from eight playable techniques; Ultimate and Reality Breaking remain locked future tiers. The implemented Forest route reaches Stage VI: after Varkuun, `The Elder Ascent` introduces the armored Crag Bear and its Crag Iron/Echo Claw drops through five production waves. In Sanctuary, Rootweaver Nema's Living Rootforge crafts the six Stage V core outputs, while Umi's Echo Crucible handles metadata-driven material selling/reconstruction. Stage V armor supports ownership, equipping, sorting, matching-slot drag, stat aggregation, and saving. F9 grants the complete debug equipment/crafting-readiness package without saving. Hunts are not yet playable. Retired Opaw content is recoverable only under `art_source/archive/retired_opaw_2026-08-16/` and is not imported by Godot.

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

The game maintains one autosave at `user://battle_of_gods_profile.json` with a `.bak` recovery copy. Continue always resumes in Sanctuary, which restores King to his current maximum health before saving the recovered safe point. Autosaves occur on Sanctuary entry, equipment changes, and stage clear after direct banking or a milestone chest claim—not during active combat. The profile includes versioned material quantities, recipe discoveries, first-clear claims, and drop-protection counters; older version-1 saves whose reserved extension sections are empty remain compatible. The exact operating-system location of `user://` is shown by Godot's **Open User Data Folder** command.

Stages I-IV use authored Godot `TileMapLayer` cells rather than runtime-random ground. Shared forest and Rootbound Hollow atlases live under `assets/environment/forest/`; diffable map layouts live under `data/environment/layouts/`. Edit baked cells directly in Godot for local adjustments, or update a layout resource and regenerate the owning scene with `tools/bake_authored_ground.gd` for a whole-map revision.

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
      king_weapon_catalog.tres
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
      king_starting_loadout.tres
    weapons/
      king_signature_sword.tres
  assets/
    characters/playable/king/
      greatsword/
      simple_reboot/  # complete visual rollback
    characters/npcs/
      skillkeeper/skillkeeper_idle_sheet_48x48.png
      armskeeper/armskeeper_idle_sheet_48x48.png
    environment/sanctuary/
      buildings/skillkeeper_lodge_128x192.png
      buildings/armskeeper_workshop_176x192.png
      shops/armskeeper_cart_128x96.png
    ui/icons/combat/
      combat_action_atlas_bc_6x1_24.png
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

King's production art lives under `res://assets/characters/playable/king/greatsword/`; `simple_reboot/` retains the complete supported visual rollback. Retired character packages and rejected experiments are organized under Godot-ignored `art_source/archive/`. All current enemy runtime art lives in named domains under `res://assets/characters/enemies/`. Exact-grid sheets under `assets/` are active runtime files.

King's production art, current Sanctuary assets, Rootling's runtime atlases, and the original level-up chime can be regenerated from their active sources with:

```powershell
& 'C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'tools/process_king_simple_locomotion.py'
& 'C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'tools/generate_riftbreak_sfx.py'
& 'C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'tools/process_riftbreak_vfx.py'
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
| Move | Right-click ground; movement clears selection, pursuit, and automation | Not assigned |
| Primary attack | Left-click or click the far-right unnumbered HUD Attack button | Right trigger |
| Dodge | Space | South face button |
| Break Stage 5 root prison | Tap Space five times; skills/attacks are locked | Tap South face button five times; mobile uses the visible Dash slot |
| Skill 1: Echoing Sever targeting | 1 or click its HUD slot | Left shoulder |
| Confirm Echoing Sever | Left mouse | Right trigger |
| Cancel targeted skill | Right-click or Escape | UI Cancel |
| Skill 2: Riftbreak self-AOE | 2 or click its HUD slot | Reserved |
| Skill 3: Sovereign Pursuit ground leap | 3, aim, then left-click/right-trigger | Right trigger confirms |
| Skill 4: spirit-sword target and delayed AOE | 4, aim, then left-click/right-trigger | Right trigger confirms |
| Equipped skills 5–10 | 5–9, 0 or click the slot | D-pad left/right selects; D-pad down activates |
| Open character / gear / skills | Tab or click the HUD satchel button | Not assigned |
| Interact / claim reward chest / enter portal | F | West face button |
| Close / cancel modal | Escape or visible mouse button | UI Cancel |
| Open Menu | Escape/Start or top-right Menu button | Start |
| Return to Sanctuary after defeat | R | North face button |
| Debug test loadout | F9 (debug builds: level 10, 999 coins, unlimited skill cooldowns, authored skills/gear, reward-safe material stockpile, Admin review tools) | Not assigned |
| Toggle Admin Mode | F10 (debug builds only; reveals Sanctuary Admin Tools) | Not assigned |
| Stage VI direct debug route | F6 while Admin Mode is enabled | Not assigned |
| Open/close Combat Lab | F7 while Admin Mode is enabled | Not assigned |
| Stage 5 boss feel-test | F8 while Admin Mode is enabled; F8 returns from the isolated arena | Not assigned |

In a debug build, F9 enables the complete non-saving review preset, supplies Stage V memories needed to expose Stage VI in the expedition menu, and reveals Admin Tools; F10 remains the manual Admin Mode toggle. From Sanctuary, choose `STAGE VI — THE ELDER ASCENT` normally or use `STAGE VI LOOK [F6]`/F6 as a direct debug route. Use `COMBAT LAB [F7]` or F7 for the lab. The lab opens on the Examiner divine-trial proof and its Court of the First Measure arena; the selector still exposes every production mob, Elite, mini-boss, and Stage V boss. Normal actors support 1/4/8 spawning, while the unique Examiner is capped to one. The lab can pause enemy AI, toggle King invincibility, enable unlimited authored skills, force Divine Descent for rapid cover/audio review, clear, or reset. It removes enemy reward components before spawning and suppresses autosave, so lab combat cannot grant XP, coins, materials, story progress, or stage claims.

Movement, movement-owned facing, mouse combat, dash, portal interaction, and Sanctuary return after defeat are active for King. Right click always moves and clears combat intent; WASD also clears selection, pursuit, and automation. One left click on an enemy hurtbox or physical foot circle selects it without pursuit; a repeated same-enemy click engages approach-and-repeat basic attacks; clicking elsewhere performs a directional air swing. Basic Attack has no number key; left click, the far-right HUD Attack control, and controller right trigger are its manual inputs. One latest valid attack, dash, or equipped skill input is retained for at most 0.8 seconds and executes only at the first legal recovery or ability-finished boundary; it never waits through a cooldown. King's signature sword owns the tested contact fan while the integrated sword and white-blue trail present the hit. Echoing Sever is Skill 1 on `1`; Riftbreak is Skill 2 on `2`; Sovereign Pursuit is Skill 3 on `3`; Worldsplitter is Skill 4 on `4`. Targeted previews confirm with left click/right trigger and cancel with right click or `Esc`, consuming the command without moving. King begins at 140 vitality, gains 12 per level, retains health across stages, and regenerates 1 HP/s after five damage-free seconds. F9 grants level, coins, authored gear, a 10,000-unit reward-safe material stockpile, and session-only unlimited skill cooldowns without changing King's normal balance data or skill loadout.

The top-right enemy roster provides optional `AUTO ALL` and `AUTO SKILL` controls. It withholds invisible or distant enemies until they enter a 300-pixel discovery range, clips and scrolls only overflowing names, selects on one left click, and engages on a repeated click. Auto All cycles through living enemies using normal navigation and basic attacks; Auto Skill additionally commits ready equipped skills through their real targeting and cooldown rules. Right-click/WASD movement, `Esc` on a selected target, or turning Auto All off stops automation. The move destination uses a small two-frame four-arrow convergence mark. King Skills 1-4 use a generated B+C hybrid normalized to native 24x24 hard-pixel icons, with full-resolution sources under `art_source/generated/ui/king_skill_icons_bc_hybrid/`.

Defeat no longer reloads the current arena or resets the run. R/gamepad north returns King to Sanctuary, discards uncommitted expedition loot, preserves level and coins, restores full health at the hub, and writes the safe point there. Healing potions, buffs, and a possible rare revive are planned utility-item concepts, not implemented inventory promises.

During normal stage play, an ordinary defeated enemy rolls its authored sparse common and secondary material chances; sixth/twelfth-attempt protection prevents an unlimited drought, while the Rootbound Husk always drops its two signature materials. A successful stack hops from the death point, gently hovers for half a second, and then flies to King automatically; touching it sooner also collects it. The upper-right toast identifies the material and quantity. After the final wave, Stages I-II bank collected materials and open their portals directly. Stage III instead summons the larger solid, Y-sorted Rootbound Reliquary through a rune reveal; press F to claim its guaranteed pool of ordinary Forest materials, release its collision, and open the return portal. The Reliquary grants no recipe unlock. Defeat, restart, or Return to Sanctuary before direct clear or chest claim removes that expedition's uncommitted materials.

In Sanctuary, approach Skillkeeper Eira, Armskeeper Orren, Rootweaver Nema, or Echo Melder Umi and press F. Nema crafts discovered Forest equipment for exact material and gold costs. Umi's compact Echo Crucible sells ordinary surplus or reconstructs a discovered material echo: click fuel to add one, right-click to remove one, or use Auto Fill. Boss materials remain protected behind repeated victories and Rare regional catalysts. The character surface opens from Tab or the HUD satchel. Its compact Character & Bag page keeps the ten-position King loadout at upper left, selected-item information at upper right, and the 24-slot filterable/sortable inventory underneath. King carries his signature sword. Stage V armor can be selected and equipped or dragged into its matching slot; its live effects and equipped choices persist. Accessory positions remain future placeholders. Eira presents King's four equipped active skills without an awakening transaction. Orren is dialogue-only after retirement of the weapon shop. HUD buttons consume pointer clicks, so clicking dash or a skill never also triggers basic attack.

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
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/expedition_defeat_return_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/character_animation_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/enemy_crowd_control_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/stagger_resistance_smoke.gd'
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
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/hud_action_controls_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/combat_foot_aura_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/auto_combat_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/editor_preview_backdrop_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/loot_resolution_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/stage_5_boss_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/combat_lab_smoke.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tests/examiner_trial_smoke.gd'
```

## Build and Export

Build targets and export presets have not been selected.

## Examiner rework review (2026-09-12)

Double-click `Play Examiner.cmd` on this workstation, or press F7 during a debug game. The lab opens on the rebuilt Examiner with King invincible. Disable `KING INVINCIBLE` to test damage; `FORCE DIVINE DESCENT` exercises the interruptible seal trial. The lab grants no progression or saves.

Current prompts and import measurements: `art_source/generated/characters/disciples/examiner/rework_2026_09_12/`. Animation mapping: `assets/characters/enemies/examiner/FRAME_MANIFEST.md`. Run `tools/process_examiner_rework.py` and `tools/generate_examiner_rework_sfx.py` with the project's Python runtime, then Godot `--headless --path . --import`, followed by `--script res://tools/build_examiner_rework_frames.gd`. The older frame-builder entry point delegates to this builder.

Focused checks: `tests/examiner_trial_smoke.gd`, `tests/examiner_rework_smoke.gd`, `tests/combat_lab_smoke.gd`. `tools/capture_examiner_rework.gd` records a scripted in-engine presentation using real action-state methods; it is not an autonomous player skill assessment.

Examiner F7 follow-up adds alternating footsteps, repaired weapon tips, animated impacts, and crimson telegraphs (Decision 137). See `art_source/review/characters/disciples/examiner/polish_2026_09_12/REVIEW.md` for the video, source prompts, and rebuild commands.

### Examiner combat review (F7)

The rewardless Combat Lab tests the Stage XX Examiner proof. Reprisal punishes straight retreat; get behind the thrust or sidestep the advancing follow-up. The gold seal bar absorbs damage separately from HP: break it to cancel his charge and earn a 2.6-second kneeling stun. Trial of Worth requires 240 mitigated damage in 7 seconds; failure releases the 800 raw Verdict through dodge, with normal armor/ward. Borrowed Sun requires 210 seal damage in 5.5 seconds; failure throws a large orb at a fixed, warned landing point. His opening is calmer, Second Measure begins after the 60% trial, and 35% HP unlocks Unbound: faster movement, 1.65x ordinary damage, larger Suns and three-impact Crownfall. Disable KING INVINCIBLE to assess difficulty. Production Stage XX routing, gear balance, rewards and saving remain pending. See `art_source/review/characters/disciples/examiner/ascendant_2026_09_12/REVIEW.md` for the rendered review and source prompt.

### Examiner Crimson Firmament review

The accepted 35% Unbound phase now has a persistent flame aura and a second signature, Crimson Firmament. Break its 180-point seal during the 3.8s charge, or evade eight randomized waves of three red meteors, moving away from each fresh warning. Borrowed Sun has a continuous sixteen-frame energy cycle, stronger gathering/release and faster fixed flight. F7/Play Examiner.cmd launch the same rewardless proof; King starts invincible. Previous charge/aura review: `art_source/review/characters/disciples/examiner/firmament_2026_09_12/REVIEW.md`. The current Decision 141 pass adds varied attack choices, warned Axiom follow-ups, changing seal reactions and a skippable victory conversation. Current review: `art_source/review/characters/disciples/examiner/tactics_2026_09_12/REVIEW.md`.

### King greatsword controls and review

Left-click/basic attack continues the three-cut chain through the existing buffer. Three landed swings charge **Resolve** for +25% on the next skill; use it within eight seconds. Land **3 (Pursuit)**, then use **2 (Riftbreak)** within 1.2 seconds for +15%. The original four remain collection alternatives; ten equipped slots now use 1–0. The HUD shows Resolve and the link; Active Skills explains both and current level mastery.

Current campaign caps: start 3, then 4/5/6/7/10 after Stages I-V. Extra XP stops at the cap; coins/loot still accrue. Existing earned levels and F9's non-saving test mode are preserved.

Art rebuild: run `tools/build_king_greatsword_assets.gd`, Godot `--editor --import --quit`, then the same script with `-- --frames-only`. Effects/portrait use `tools/build_king_greatsword_effect_assets.gd`; original audio uses `tools/generate_king_greatsword_sfx.py`. Generation and correction prompts are in `art_source/generated/characters/king/greatsword_2026_09_12/`. Rendered review is in the matching `art_source/review/characters/king/` folder.

## Try King's evolving techniques

Open **Tab → Active Skills → Technique Collection** (also reachable through Eira). Select a technique and a slot; change loadouts while idle in Sanctuary. Ten slots can mix the original four skills with Crosscut Advance, Griefwake, Breakstep and Last Oath. Choose **Equip core kit** to assign learned core skills to 1–4; unlearned core skills leave empty slots. Griefwake unlocks after Stage II; Last Oath and Resonant forms after Stage V. Right-click a collection slot to clear it. Four-slot saves preserve their choices and add six empty positions.

For the complete spectacle now: **F7 Combat Lab → King · Technique Collection → choose a form → Equip all four Oath skills → Close**. In the core kit, **1** performs two cuts, **2** aims Griefwake (left-click/right trigger confirms; right-click/Esc cancels), **3** immediately Breaksteps in movement/aim direction, and **4** performs Last Oath. Griefwake returns control before the eruption lands. A real successful Breakstep evade primes one basic riposte for two seconds; completing the step links a rupture. Slots **5–9 and 0** accept any other learned techniques. On controller, D-pad left/right selects a slot and D-pad down activates it; the bar marks the selection. Ascendant and Unbound are future-milestone previews and do not change your save. F7/F9 retain the existing unlimited-skills helper. [Collection rules and lore](docs/design/king-unwritten-oath.md).

Current implementation and timing: [Decision 147](docs/decisions/147-responsive-king-core-and-ten-slots.md). Repeatable visual capture: `tools/capture_king_responsive_review.gd`; current review is under `art_source/review/characters/king/responsive_2026_09_13/`. Ten slots are capacity, not ten free powers: divine spells and future encounter rewards remain planned.
