# Battle of Gods

**Current grip/idle previews (2026-10-04):** Existing tools/launch_king_greatsword_review.ps1 opens **Greatsword V4 GRIP / SHALLOW PRIDE**; tools/launch_king_axe_grip_review.ps1 opens **Axe V6 BACK MOUNT**. A/D runs, SPACE/click attacks, ESC pauses. After4s AFK or **Plant sword / proud idle**, King plants an upright sword beside him with only its tip buried; draw precedes the next action. Current GIFs: art_source/review/combat/king_grip_loop_v4_2026_10_04/motion.gif and king_grip_plant_v4_2026_10_04/motion.gif. Build confidence, then gait repair, then import; capture tools retain their names, GIF switches are -GripLoop / -GripPlant. These remain separate weapon reviews, not F5 equipment promotion. Older version notes below are historical.

**Current weapon previews (2026-10-04):** Run tools/launch_king_greatsword_review.ps1 for **Greatsword V3 GAIT / BURIED PRIDE**, or tools/launch_king_axe_grip_review.ps1 for **Axe V5 STABLE GAIT**. A/D moves, SPACE/click attacks, ESC pauses. Greatsword plants beside King after4s AFK or via **Plant sword / proud idle**; drawing it back out precedes an action. Current previews: art_source/review/combat/king_gait_loop_v3_2026_10_04/motion.gif and king_gait_repair_v3_2026_10_04/motion.gif. Build confidence assets, then tools/build_king_gait_repair.gd, then import. Isolated previews; normal F5 equipment promotion remains pending. Older version/cadence notes below are historical.

**Updated run/pride tests (2026-10-04):** Existing `tools/launch_king_greatsword_review.ps1` opens V2; `tools/launch_king_axe_grip_review.ps1` opens axe V4. **A/D runs left/right**, SPACE/click attacks, ESC pauses. Axe runs with weapon at back/free hands; greatsword runs with one-hand shoulder carry. Greatsword **Plant sword / proud idle** (also4s AFK) drives the sword into ground and folds arms; a0.28s retrieval precedes attack/run. Stronger opening torsion and blade-bound slam trail are included. [New moving preview](art_source/review/combat/king_confidence_v2_2026_10_04/motion.gif), [art/prompt index](art_source/generated/characters/king/greatsword_confidence_v2_2026_10_04/README.md). Side directions only; normal F5 skills/equipment/recipes remain unchanged. Earlier stationary/right-only notes below are historical.

**Huge greatsword playable review (2026-10-04):** Run `powershell -ExecutionPolicy Bypass -File .\tools\launch_king_greatsword_review.ps1`. SPACE/click attacks; **Play four-move combo** previews stepping sweep, rise, meteor jump slam and turning cleave. **Try meteor slam** isolates the jump; target/crowd/Rootling buttons test real contact; ESC pause, cancel and reset. Huge rigid15x70 world blade,32 body poses,16 slash and8 impact drawings; actual collision-checked steps. Native447 checks pass. [Moving preview](art_source/review/combat/king_huge_greatsword_2026_10_04/motion.gif), [scope/validation](docs/design/king-huge-greatsword-review.md), [sources/prompts](art_source/generated/characters/king/huge_greatsword_2026_10_04/README.md). Right-facing isolated review; normal F5 equipment/skills/crafting remain unchanged.

**Updated axe V3 test (2026-10-04):** Run `powershell -ExecutionPolicy Bypass -File .\tools\launch_king_axe_grip_review.ps1`. **Play five-move combo** previews side/rising/down/hop/spin with real72px reach,68px radial spin and20 white FX frames. SPACE/click advances one cut with one buffered follow-up; **Try whirlwind alone** and **Surround King with targets** test rear contact. Default low carry becomes arms-down back stow after4s inactivity. Cancel clears pending cuts; ESC pauses; Reset rebuilds. [Moving preview](art_source/review/combat/king_axe_expanded_v3_2026_10_04/motion.gif), [gallery](art_source/review/combat/king_axe_expanded_v3_2026_10_04/gallery.png), [sources/scope](art_source/generated/characters/king/axe_expanded_v3_2026_10_04/README.md). Native496 checks and melee/style regressions pass. This remains an isolated stationary axe review; normal F5 equipment/recipes are unchanged. Older launcher descriptions below are historical.

**Playable Iron Beard axe proof (2026-10-04):** From this folder run `powershell -ExecutionPolicy Bypass -File .\tools\launch_king_axe_grip_review.ps1`. SPACE/click ground chops right; buttons place a target, spawn a real Rootling and explicitly reposition the stationary rig near it. ESC pauses; Reset rebuilds the fixture. This is a one-direction grip/contact prototype with isolated storage, suppressed saving and no enemy rewards. Normal F5 equipment and crafting are unchanged. See the [source/prompt and scope](art_source/generated/characters/king/iron_beard_motion_proof_2026_10_04/README.md), [moving preview](art_source/review/combat/king_axe_grip_2026_10_04/motion.gif) and [pose gallery](art_source/review/combat/king_axe_grip_2026_10_04/poses.png). Native62 assertions pass.

**Compact equipment V2 previews (2026-10-04):** Open the [new armor/weapon design index](art_source/generated/characters/king/equipment_design_v2_2026_10_04/README.md) for simpler armor on King and weapon-only axe/scythe choices. Native-size comparison images show the candidates beside current King. These are design previews, not F5 equipment or new recipes.

**King equipment samples (2026-10-04):** Open the [weapon/armor study index](art_source/generated/characters/king/equipment_families_2026_10_04/README.md) for Sword, GreatSword, Dual sword, Axe, Scythe and armor/open-helmet concepts. Each folder contains the unchanged generated image and exact prompt. These are samples, not new F5 equipment; [the production plan](docs/design/king-weapon-family-and-basic-hit-redesign.md) documents registration, walking, combat timing and save-compatible integration still to do.

**Combat update (2026-10-04):** Restart F5 for the four-frame red critical burst, larger centered CRIT digits and physical/magic skill labels. Sword, Skill1 and Skill3 are physical; Skill2 and Skill5 are magic; Skill4 is a self buff. Starter critical chance remains0%, Varkuun Edge8%. For a playable50%-crit comparison, run `powershell -ExecutionPolicy Bypass -File .\tools\launch_combat_impact_review.ps1` from this folder. Its buttons compare types, defenses,36/42px sword reach and a perfect-dodge counter, with1/8 real enemies. WASD, left-click attack,1/2/3/5 skills and Space dodge; Tab bag, Esc pause. The counter earns one0.75s pure sword opportunity after an enemy strike is evaded in the first0.12s of a dash. Reach/counter are review-only. Review storage is isolated, saving suppressed and enemy rewards removed. See docs/design/king-impact-and-counter-proposal.md.

**Targeting correction (2026-10-04):** Restart F5 for clearer2px translucent AOE rings and corrected outdoor Sanctuary Skill3 landings. Press3, aim at clear ground, left click to jump; right click/Esc cancels. Existing skill animation, reach, damage radii and24px cursors stay unchanged. Current screenshots/checks: art_source/review/ui/targeting_recovery_2026_10_04/.

**2026-10-03 gameplay update:** Restart F5 to load the shared four-drawing enemy arrival and silver/violet targeting/cursors. In a stage use1/3/5, aim and left click to confirm; right click/Esc cancel. Skill1 and5 retain range across scenery; Skill3 can fly over any obstacle to clear valid ground. Existing progression gates still apply; F7 Combat Lab offers isolated skill testing. Details and verification: docs/design/king-targeting-and-terrain.md.

**Universal spawn prototype:** Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\launch_generic_spawn_review.ps1`. Pick Rootling, Thrall, Crag Bear or Husk, then **Spawn selected foe** or **Replay**: all use the same four-drawing ground effect.1/3/8 batches, Reset, grass/dark, normal movement/skills/bag/pause remain. Saves are isolated/suppressed; trial enemies grant no rewards. This is a prototype, not normal F5 campaign promotion. [Generated art/prompt](art_source/generated/vfx/generic_spawn_2026_10_03/README.md) · [Native review evidence](art_source/review/encounters/generic_spawn_2026_10_03/README.md).

**Choose spawn art in-game:** Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\launch_enemy_arrival_art_review.ps1`. A/B/C switch and replay six-frame raster candidates beside King; choose1/3/8 enemies, Reset between batch sizes, Replay, or grass/dark ground. WASD/attack/skills/Tab/Esc work normally. Separate profile, suppressed saves and rewardless enemies protect campaign progress. This is a choice preview; normal F5 has not adopted a family. [Art, prompts and verification](art_source/review/encounters/arrival_art_2026_10_03/README.md).

**Enemy arrival updated:** F5 encounter stages now show a small ground warning before foes emerge, with restrained spawn sound and safe placement. For quick1/3/8 testing run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\launch_enemy_arrival_review.ps1`; reset between batches, toggle King safety, or open normal Stage IV. Trial enemies grant no rewards and saving is isolated/suppressed. [Details and profile evidence](docs/design/enemy-arrival-and-horde-profiling.md). Existing loading screen is implemented; further re-art is optional.

**Homepage updated:** Normal **F5** now opens one of A/B/C (breach, seated campfire, clash), picked randomly without consecutive repeats across launches. King stays still. Normal Continue/New Journey/Settings/Quit remain. [Native captures](art_source/review/ui/title_trio_2026_10_03/README.md).

**Selected campfire title preview:** `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_campfire_title_preview.ps1` opens King/fire/walking-watchers with actual menu controls and isolated review storage. [Native motion GIF](art_source/review/ui/campfire_title_2026_10_03/campfire_native.gif). This is a prototype; normal F5 uses the current production title. [Direction and next work](docs/design/campfire-title-direction.md).

**Homepage/loading wobble fixed:** Restart playtest to reload fixed gold engravings with moving light and fading title specks. [Homepage GIF](art_source/review/ui/quiet_ui_stability_2026_10_03/title_native.gif) / [loading GIF](art_source/review/ui/quiet_ui_stability_2026_10_03/loading_native.gif); loading clip is a labelled37% rehearsal. Native195 stability and55 integration checks pass.

**Portal wobble correction:** Restart the playtest to load the stable doorway outlines and smoother inner currents. [Native before/after GIF](art_source/review/ui/portal_stability_2026_10_03/comparison_native.gif) shows raw frames on the left and the corrected material on the right; diagnostic lightning is hidden. All six variants pass144 rendered stability checks.

**2026-10-03 stage presentation review:** Run `powershell -ExecutionPolicy Bypass -File .\tools\launch_stage_presentation.ps1` for all six animated threat gates, new closed/open chests, loading motion, actual StageI loading and the refreshed title. Review uses an isolated profile; Esc closes its motion preview. F5 starts the normal refreshed title and ordinary Continue. Campaign exits still require stage clear/F and required III/V chest claims. Handoff: [CONTINUE_PROGRESS.md](CONTINUE_PROGRESS.md). Implementation/captures/next work: [stage presentation](docs/design/stage-exits-and-quiet-transitions.md).

**Stage V Dead Forest and campaign Rotcaller:** `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_stage_5_renewal.ps1` opens the renewed dead woodland with no saves and safe King. **Start six sentries** runs five Rootlings plus one Rotcaller, at most five alive. Clear them before entering Varkuun's basin; the solo boss, required F chest and Stage VI unlock remain intact. Arrival/approach/basin/Overview inspect the new layout; **King safe** permits vulnerable combat; **Reset Stage V** restores full HP. The Stage IV shortcut also exposes the isolated caster trial. WASD/attack/skills work normally; Tab opens the bag and Esc closes it or opens pause. New forest music separates expeditions from Sanctuary. See [current implementation and next work](docs/design/stage-5-renewal-and-combat-polish.md).

**Stage IV and Rotcaller test:** `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_stage_4_renewal.ps1` opens renewed Eastern Rot with no saves. **Start normal waves** runs five waves of 8/10/12/14/16 enemies (60 total, eight alive maximum), including campaign Rotcallers. **Try Rotcaller → Start trial** isolates one caster plus two Rootlings with vulnerable King and no rewards. Hit during **INTERRUPT CAST**, or leave the marked ground. **Reset trial** restores full health; **Spitter** starts a four-enemy comparison; **King safe** toggles immunity. The dedicated trial remains separate from F7. Normal campaign play saves and grants ordinary enemy rewards.

**Stage III Hollow & pressure review:** `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_stage_3_renewal.ps1` opens the renewed III with no saves and safe King. Select the normal 13 Rootlings plus one Rotcaller/five-live approach or the optional 18 Rootlings plus one Rotcaller/six-live comparison, then **Start chosen waves**. Restart to compare. Both retain the portrait dialogue, solo Husk and required F Reliquary claim. Normal F5 uses the first option with ordinary saving. See docs/design/stage-3-hollow-and-enemy-pressure.md.

**Stage II bramble & sound review:** `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_stage_2_renewal.ps1` opens the new normal Stage II peacefully with no saves and safe King. WASD explores; view shortcuts and Overview inspect the layout; **Start normal waves** tests combat. **Music / Outdoor sound**, **Local bird call** and **Music handoff demo** let you hear the layers. Normal Stage II uses the same new art with ordinary combat/saving. Stage I also has quiet outdoor audio. Pause menu **MUSIC & AMBIENCE** controls atmosphere; **COMBAT SOUND** remains separate. See docs/design/stage-2-bramble-and-biome-audio.md.

**Stage I woodland review:** `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_stage_1_renewal.ps1` opens the renewed Forgotten Grove peacefully with no saving and safe King. WASD explores; Entrance/Glade/Old shrine visit the main views; Overview/gameplay changes scale; Start normal waves runs the real encounter. Normal F5/Stage I uses the same new environment with ordinary saving/combat. This is the accepted density/style reference for later biomes. See docs/design/stage-1-woodland-renewal.md.

**Expedition objectives and rewards:** Current Stages I–VI show wave progress and the exit condition. After clear/required F chest claim, click **VIEW REWARDS** for actual XP/gold, materials and unlocks. **KEEP EXPLORING** resumes collection; **RETURN TO SANCTUARY** uses normal hub travel. Forward portals still use **F**. **Esc/Tab** closes; **PageUp/Down/Home/End** scrolls rewards.

Quick no-save review: `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_expedition_review.ps1`. Click **Finish encounter**, continue/skip dialogue, **Visit reward chest** after it appears, **F**, then **VIEW REWARDS**. King is safe in this review. Add `-Stage5` for Varkuun (enter the clearing and finish the intro first). Restart normal F5 to resume normal saving. Design/verification: docs/design/expedition-objectives-and-receipts.md.

Sanctuary is temporarily complete for this pass. **F5 -> Continue** loads the renewed town directly with normal saving and compact Portrait Link HUD. **F** talks to NPCs; finish Eira's dialogue for Training, Nema's for crafting and Umi's for exchange. The map/minimap/directory, **M** shortcut and noticeboard map interaction are temporarily hidden during layout iteration. **Tab** opens the searchable Character & Bag; **Esc** closes menus. Approach Orren's workshop door and press **F** to enter; F inspects or leaves indoors. Walking alone does not enter.

Eira's free manual training gates: Earth2, Molten3/6/9, Pursuit5/8, Vow7/10, World8/10. Training improves ranks; Loadout arranges ten keys. XP/caps/rewards remain unchanged. Current HUD has immediate HP, damage trail, critical text and exact XP/stage help.

For a no-save fixture: `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_sanctuary_study.ps1 -InterfaceDemo` (Nema materials/gold plus XP/damage/heal/cap controls), or `-TrainingDemo` (Level10 at Eira). **F10 -> SANCTUARY TEST · NO SAVES** enables visit/overview controls on the same town. Test mode suppresses saving until process restart. Old/new comparison is removed.

Runtime town modules: `levels/sanctuary/town/`. Recovery archive: `art_source/archive/sanctuary_retired_2026_10_02/` (Godot-ignored, manifest and README included). Read `CONTINUE_SANCTUARY.md` and `docs/design/sanctuary-closeout.md` for current status, tests and deferred work. No commit or push is performed by the agent.

**Worldsplitter summoned-sword review:** Run `tools/launch_king_skills.ps1` for three fresh crimson blades that bury and detonate across the target area. Press **5**, aim/click, then move or dodge. **F7 -> Skills -> Worldsplitter** compares one/two/three swords; F9 refills the kit. The selected rank is a session-only preview. Current design: `docs/design/worldsplitter-fractured-light.md`.

**Worldsplitter review:** Run `tools/launch_king_skills.ps1`; press **5**, aim and click, then move/dodge while the upright sword finishes. F7 -> **Skills ->5 WORLDSPLITTER** selects all three upgrades; F9 restores the test kit. Eira trains Advanced at Level8 and Mature at Level10. New in-engine captures: `art_source/review/characters/king/worldsplitter_upright_2026_09_27/`.

**Combat Lab controls (2026-09-27):** F7 opens the lab with all five authored combat skills equipped and unlimited reuse. The right sidebar separates **AI** (spawn, pause, invincibility, Examiner phase) from **Skills** (upgrade dropdowns, buff animation rehearsal, loadout, and scroll-down King diagnostics). F9 applies the existing full debug preset, restores the complete kit, retains selected upgrade definitions and opens Skills. REFILL / EQUIP ALL SKILLS restores just the skill test kit. Switching to AI closes any buff rehearsal and restores its temporary settings. Lab forms/loadouts never overwrite campaign training or saved slots. Run `tests/combat_lab_sidebar_smoke.gd` headlessly, or with `--resolution 960x540` for four GPU captures under `art_source/review/ui/combat_lab_tabs_2026_09_27/`.

**King buff / finisher testing:** F7 -> Skills tab. Press **4** for the real Unbroken Vow buff; select its Foundation/Advanced/Mature rank in the scrollable Skills tab. Press **5**, aim, then left-click for Worldsplitter. Disable KING INVINCIBLE under AI to see shield absorption and break. F9 restores the complete kit and unlimited reuse. The optional OLD POSE REHEARSAL button is only a slow-motion art inspector. Normal play trains Vow at Eira at Levels 7/10. Focused checks: `tests/king_vow_worldsplitter_smoke.gd`, `tests/unbroken_vow_training_smoke.gd`. GPU evidence: `art_source/review/characters/king/vow_worldsplitter_2026_09_27/`. Direct playable launcher: `tools/launch_king_skills.ps1`.

**Current King kit (Decision 157):** The approved detailed King C body now appears in normal play and in the character menu. Skills `1`–`3` are Earthsplitter Foundation (aim a fixed lane, then click), blue Molten Crash Foundation (press for a local stun impact), and Sovereign Pursuit with the blue-white blade-cut landing (aim a point, then click). Skill `4` is Unbroken Vow (self shield/damage buff); `5` is Worldsplitter (aim a point and confirm). The four Oath techniques and previous Echoing Sever/Riftbreak variants are archived. Legacy default loadouts migrate to the five-skill kit, preserving displaced/custom skills. F7 -> **Skills tab** shows the current character and permits session-only Skill 1/2 form comparisons; there is no old-art toggle. Later-form campaign unlocks for Skills 1/2 remain planned. Pursuit's [three-charge progression](docs/design/sovereign-pursuit-charge-progression.md) trains with Eira at Levels 5/8.

Battle of Gods is a planned 2D top-down pixel action game for Godot 4.x. The player survives relentless dark-fantasy enemies through precise movement, positioning, dodging, weapon mastery, and divine or demonic abilities.

The setting centers on gods, demons, forgotten civilizations, and a divine Game architected by the being titled **The One Above**. The title does not establish that he created reality or is the strongest being; the intended story slowly questions the hierarchy behind the Game. The tone is ancient, mysterious, and epic, with simple pixel art, strong silhouettes, limited palettes, and highly readable combat effects.

## Current Status

**King form review:** F7 -> Skills tab offers **SKILL 1: FOUNDATION/FAN/CASCADE TEST** and **SKILL 2: FOUNDATION/ADVANCED/AWAKENED/MATURE**. These changes last only for the Lab session and wait for targeting, casts and delayed attacks to finish. The normal campaign always begins at both Foundation forms. Historical [Earthsplitter Fan](art_source/review/characters/king/earthsplitter_fan_followup_2026_09_26/earthsplitter_fan_followup.mp4), [Molten forms](art_source/review/characters/king/molten_crash_upgrades_2026_09_26/molten_crash_upgrades.mp4) and [Pursuit blade cut](art_source/review/characters/king/sovereign_pursuit_2026_09_26/sovereign_pursuit.mp4) recordings remain for art review; their old toggle scripts were archived.

King C is the production player body. F7 -> Skills tab offers speed, view, hit/stun and reach diagnostics on the same body used in normal play; the LOOK toggle was retired. Historical locomotion recordings remain under `art_source/review/characters/king/`. Direct Lab launch accepts `--king-review`.

Pre-alpha title-to-Sanctuary-to-six-stage prototype. F5 opens a mouse/keyboard/gamepad-ready Battle of Gods title screen with Continue, guarded New Journey, and session-audio settings. King is the sole production player with four-direction locomotion, an integrated signature sword, a physical three-cut basic chain, and ten equipped slots currently drawing from five playable techniques; Ultimate and Reality Breaking remain locked future tiers. The implemented Forest route reaches Stage VI: after Varkuun, `The Elder Ascent` introduces the armored Crag Bear and its Crag Iron/Echo Claw drops through five production waves. In Sanctuary, Rootweaver Nema's Living Rootforge crafts the six Stage V core outputs, while Umi's Echo Crucible handles metadata-driven material selling/reconstruction. Stage V armor supports ownership, equipping, sorting, matching-slot drag, stat aggregation, and saving. F9 grants the complete debug equipment/crafting-readiness package without saving. Hunts are not yet playable. Retired Opaw content is recoverable only under `art_source/archive/retired_opaw_2026-08-16/` and is not imported by Godot.

## Intended Technology

- Engine: Godot 4.7.2 stable
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

1. Install Godot 4.7.2 stable. The standard build is sufficient; .NET is not required.
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
      spellward/
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

King's production art lives under `res://assets/characters/playable/king/spellward/`; `simple_reboot/` retains the complete supported visual rollback. Retired character packages and rejected experiments are organized under Godot-ignored `art_source/archive/`. All current enemy runtime art lives in named domains under `res://assets/characters/enemies/`. Exact-grid sheets under `assets/` are active runtime files.

King's production art, current Sanctuary assets, Rootling's runtime atlases, and the original level-up chime can be regenerated from their active sources with:

```powershell
& 'C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'tools/process_king_simple_locomotion.py'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/build_character_sprite_frames.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_mireling_walk_assets.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/process_mireling_action_assets.gd'
& 'D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/build_mireling_sprite_frames.gd'
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

Movement, mouse combat, dash, portal interaction and Sanctuary return after defeat remain active. One left click selects an enemy; a repeated same-enemy click engages. Right click moves and clears combat intent. Skills `1`-`4` are Earthsplitter, Molten Crash, Sovereign Pursuit and Worldsplitter. Skills 1 and 3 use a target preview confirmed with left click/right trigger and canceled with right click or `Esc`; Skill 2 casts locally. The latest valid attack, dash or skill input buffers for at most 0.8 seconds. King starts at 140 vitality, gains 12 per level and regenerates 1 HP/s after five damage-free seconds. F9 remains a session-only testing helper.

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

### King controls and current kit

Left-click/basic attack continues the three-cut chain. Three landed swings charge **Resolve** for +25% on the next skill; use it within eight seconds. Land **3 (Sovereign Pursuit)**, then use **2 (Molten Crash)** within 1.2 seconds for +15%. Current campaign level caps start at 3 and become 4/5/6/7/10 after Stages I–V; extra XP stops at the cap while coins and loot still accrue.

Open **Tab → Active Skills → Technique Collection** (also reachable through Eira). Equip the four current skills in ten available positions: **1 Earthsplitter** aims a fixed-length ground lane and releases a summoned-sword rupture; **2 Molten Crash** makes a quick blue local impact with an authored stun; **3 Sovereign Pursuit** is targeted protected mobility with a blade-cut landing; **4 Unbroken Vow** grants shielded offense; **5 Worldsplitter** targets a quick summoned-sword impact and released pressure follow-up. Left-click/right trigger confirms a target, and right-click/Esc cancels. Right-click a collection slot to clear it. Older Oath save selections migrate to their corresponding core family. D-pad left/right selects a slot and down activates it. Slots 6–9 and 0 are capacity for future earned powers, not extra skills already granted.

**Pursuit upgrades:** Speak with Eira and open her Technique Collection at Level 5 for two stored 250px uses, then at Level 8 for three 280px uses. Each leap is aimed separately; one use refills every 8.5 seconds. The skill bar shows available uses and refill progress. The normal Tab collection displays the requirement, while Eira performs and saves the upgrade. The existing stage level cap controls when those levels can be reached.

F7 Combat Lab uses the same King C body and current kit. The **Skills tab** can switch Earthsplitter between Foundation/Fan/Cascade, Molten Crash between Foundation/Advanced/Awakened/Mature, and Pursuit between one/two/three uses for this Lab session only. The campaign starts Skills 1/2 at Foundation; their higher-form unlock gates and persistence are future work. F9 remains a non-saving debug helper. Retired Oath skills, older King art and obsolete comparison scripts are preserved outside Godot's import path under `art_source/archive/king_retired_2026_09_26/`. See [Decisions 157–158](docs/decisions/158-pursuit-trained-charges.md) for the current King skill boundary.
