# Player vitality, growth and bag readability

2026-10-02. Owner provisionally passed Eira, described Nema as clear/accurate, and requested a Nema double-check followed by HP, level and bag improvements with generated artwork. The shared HUD/bag pass is implemented; owner visual/usability judgment and phone profiling remain open. King, accepted skills, workshop scale and F-required entry remain the baseline.

## Nema audit and correction

Verified existing recipe previews, material counts, gold fees, seal/category gates, exact crafting, unique-output rejection, result text, bag appearance and equip behavior. No recipe/cost/economy redesign.

A presentation shortcut classified every sealed no-save test session as F9's all-owned preset. It incorrectly showed ALREADY OWNED for an unowned, funded recipe during review. Removed that shortcut: CraftingService.get_recipe_status alone decides readiness/ownership. Actual F9-owned outputs remain uncraftable. Rootforge now observes RunSession currency changes while open, so a changed gold balance refreshes the fee and action. Normal atomic save/reload is covered by crafting_service_smoke; review crafting works in memory without writing its profile.

## Vitality and growth

CombatHUD uses a compact generated midnight-slate, aged-gold, ivory/amethyst frame. HP numbers and red fill update immediately from HealthComponent. A gold trail holds for .25s and settles over .55s after loss; healing/max-HP changes snap the trail to the authoritative value. Critical health at 25% or below has red styling and CRITICAL text; it does not depend on color alone. Tooltip reads regeneration delay from vitality data.

Vow retains its real shield/duration readout, now below the bag button. Shield-only damage leaves HP unchanged. A separate finite level-up notice sits below that readout and names newly eligible Eira training. No perpetual flashing or new per-frame gameplay observer is introduced.

HUD and CharacterMenu share progression_readout.gd: XP into this level, exact XP remaining and next level; STAGE CAP names the current level and a tooltip names the actual stage/cap requirement; MAX LEVEL is distinct. ProgressionDefinition adds display names and next_cap_requirement without changing XP thresholds, earned levels, growth, caps or rewards. Legacy earned levels above old story gates receive the next higher cap requirement. XP still stops at the ceiling while gold/loot continue.

Current curve: 0/150/400/750/1200/1750/2400/3150/4000/4950 cumulative XP. Base HP remains140 +12 per level, cap10, before gear. Stages I/II/III/IV/V unlock caps4/5/6/7/10.

## Character and bag

The 840x490 modal fits960x540. Approved character body/equipment preview remains. Existing 12-column grid fills its available width, keeps icons bounded to24px and has a bounded focus-following scroll body. Search matches owned item name, slot/family or rarity, case-insensitively; native clear control removes the query.

All, Equipment, Materials and Sort remain working controls. Unimplemented Consumables/Key bag filters are hidden; their future functionality is not fabricated. Milestone seals retain StoryState/crafting authority. SHOWING counts the actual filtered results. Footer separately reports total owned equipment and material types; materials still consume no equipment bag space. The old24-slot number was display capacity/minimum cells, not a newly enforced transaction limit; no ownership or capacity rules change.

Selection, explicit equip, drag equip, quantities/rarity/equipped markers and sorting remain. Empty searches show an honest empty detail state with no unrelated equip action. Search keeps typing focus; inventory rebuilds restore focused item by stable identity. Equipment/material/weapon events update the visible menu. HUD click and Tab remain entry routes; Esc resumes gameplay.

## Ownership and assets

- ui/hud/player_status_presenter.gd composes finite HUD feedback; existing CombatHUD health/progression fields stay live, including unique HealthBar ownership.
- ui/hud/progression_readout.gd formats authoritative progression data for both views.
- CharacterMenu selects/filters/sorts; Player and inventory services still own equip/ownership/save.
- Generated originals and exact built-in imagegen prompts: art_source/generated/ui/player_readability_2026_10_02/.
- Runtime assets: assets/ui/player_readability/vitality.png (288x104) and satchel.png (24x24). Alpha is binary, sampling nearest, mipmaps disabled. tools/build_player_readability_art.gd normalizes alpha before tight cropping/resizing and records normalization.json. Original prior art remains preserved.
- Native evidence: art_source/review/ui/player_readability_2026_10_02/.

This new HP frame/bag presentation applies in normal play. The broader Sanctuary environment and generated modal theme remain optional-study presentation; no town-art promotion is implied.

## Immediate test

Normal F5/Continue loads the shared HP/bag changes. For a safe interactive fixture:

`powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_sanctuary_study.ps1 -InterfaceDemo`

Starts beside Nema with temporary100 XP,750 gold,8 of every authored material and one owned glove. Saving is suppressed before fixture mutation for the entire process. UI TEST controls: +75 XP triggers real growth/level notices; Lose35 HP exercises actual damage with a1HP floor; Heal restores current maximum; Next stage cap applies the next authored story gate. They hide with other review controls while menus are open. F/dialogue opens Nema, Tab/HUD opens bag. Closing discards this test session; normal saves remain untouched. Existing -Eira/-TrainingDemo routes remain available.

## Verification and limits

66 rendered interface checks: immediate HP/trail/critical/heal, actual level-up/HP growth, stage/max/legacy cap copy, shield-only hits and overlap exclusion, real F/Nema crafting and exact spends, preview ownership fix, currency refresh, profile checksum preservation, actual HUD bag click, all owned items/counts, arrow navigation, sorting, case-insensitive search/focus, empty-state actions and real equip.

14 rendered launcher checks exercise actual demo buttons, native bounds/map separation, XP cap/unlock, critical/heal, seeded Nema readiness and bag items. CharacterMenu, player/run progression, atomic crafting and UI-icon smoke pass; existing Sanctuary interface52 and Eira flow73 headless checks and combined Vow/Worldsplitter49 pass. Editor import and git diff --check pass. Existing GPU shutdown texture warnings remain; automated results do not establish subjective feel or phone readability.

Next: owner play check of this pass, then expedition objective/reward feedback and a full fight/loot/craft/equip/train loop check. Umi only needs targeted observed usability corrections, not an automatic service rewrite. Further houses/interiors remain deferred.