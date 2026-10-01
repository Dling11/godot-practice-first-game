# Sanctuary renewal — staged environment and NPC work

**2026-10-02 NPC usability priority:** Owner deferred further houses/interiors and requested NPC function, layout and skill arrangement. Current Eira work-corner and shared training/loadout corrections are in sanctuary-npc-usability.md. Earlier interior-first recommendations are superseded.

**2026-10-02 current interior status:** Orren now has one walkable optional interior, documented in sanctuary-workshop-interior.md. Eira/Nema/Umi interiors remain planned. Earlier descriptions of all Doorway markers as planning-only are historical for Orren. Current house/interface state is in sanctuary-interface-renewal.md.

**Latest continuation (2026-10-01):** The owner rejected the courier's sliding feel and lectern placement, then authorized Nema and Umi. Their working sprites/portraits and angled houses are now integrated, alongside distance-driven courier poses, an off-road teaching nook, foliage wind, swallows and Rowan dialogue. Current layout, sources and verification are in `sanctuary-courtyard-renewal.md`. Earlier sections below describe prior iterations where positions or pending status differ.

Updated 2026-10-01. Owner direction: a richer inhabited fantasy RPG settlement, cohesive trees/walls/workstations, discoverable reactive NPCs, walking civilians, finer tiles, useful buildings with future interiors, and all service NPCs refreshed to match current King. Keep accepted workshop/lodge and King Skills1–5; preserve service functionality and stage major service-character replacements individually.

## First playable study — implemented, direction accepted

Run `tools/launch_sanctuary_study.ps1`, or F5 → Continue → F10 → **SANCTUARY REVIEW · NO SAVES**. It loads/composes the actual Sanctuary services with autosaving suppressed and adds one optional `levels/sanctuary/review/refuge_study.gd` overlay. Both entries start beside Orren. The default campaign map is not promoted; saving resumes only after restarting normal play.

- 32px ground tiles over the same 1152x768 footprint; quiet meadow, earth, irregular stone and sixteen cardinal paving transitions.
- A new blue-roof trainer lodge with a measured doorway anchor, authored collision and rear overlap fade to keep King visible.
- Modular lanterns, planters, benches and connected intact limestone garden boundaries with separate ground footprints. Lantern presentation animates independently of collision; scattered broken review walls are removed.
- Compare old/new, Visit Orren, Visit Eira, Overview/walk and Town map buttons. Existing NPCs and service menus remain available with F; launcher starts beside Orren.
- Current generated concept is a direction study, not a baked production map or an exact promise of the first slice. Runtime assets are individual tiles/props.

Originals and prompts: `art_source/generated/environment/sanctuary/refuge_review_2026_09_27/`. Builder: `tools/build_sanctuary_refuge_review.gd`. Runtime candidate assets: `assets/environment/sanctuary/refuge_review/`. Native captures: `art_source/review/environment/sanctuary_redesign/`.

## Orren and workshop — implemented study, retained scale reference

- Newly generated mature artisan identity: short brown hair/silver streak, trimmed beard, charcoal rolled sleeves and russet apron; eight blade-inspection poses, clear hands and a matching 96px dialogue portrait. Initial stockier sheet is preserved as rejected provenance.
- Current readability V2 uses one shared source scale for60px bodies, presented at half scale beside King's28px body. Larger head, broader shoulders and stronger dark outline address the first candidate's small/faint appearance. Eight padded96px cells use foot baseline80 and named `idle_down` playback at5fps with endpoint holds. New art moves hands/head/chest; the old whole-body bob is disabled. Dialogue holds his attentive pose; closing resumes his work. First55–56px candidate and rejected sources remain preserved.
- Generated charcoal-roof workshop with warm forge, sheltered tools, separate footprint/roof fade and five small forge particles. The original NPC node moves to the clear courtyard at992,438 without replacing its interaction/body shapes or dialogue authority. A short paving branch connects it to the main route.
- Old/new comparison restores original Orren position, portrait, frames, idle helper and workshop collision. Orren remains dialogue-only. Workshop Doorway/Approach/ReturnPoint reserve future entry at928,390; `interior_status=planned`, no enter action.
- Source/prompts/manifest: `art_source/generated/environment/sanctuary/orren_workshop_2026_09_30/`. Builder: `tools/build_orren_workshop_review.gd`. Presentation: `levels/sanctuary/review/orren_workshop_review.gd`. New captures: `art_source/review/environment/orren_workshop_2026_09_30/`.

## Eira and trainer lodge — implemented candidate, awaiting visual review

- Plum-violet hood/coat, chestnut hair, restrained gold edging, cream collar and connected arms holding a teaching book preserve the scholar role while replacing the old floating-prop body. Eight generated poses read/look down, reach, lift/turn/smooth a page and return to attentive book hold.
- `idle_read.png` uses eight96px cells, one source scale for60–61px bodies, y80 foot baseline and .5 runtime presentation. `idle_down` plays at4fps with endpoint holds. Portrait is96px, both assets binary-alpha/nearest. No whole-body translation helper or old floating aura runs in the study.
- Existing Skillkeeper node moves to288,438 with a paved approach at288,474. The original body/trigger shapes, dialogue lines, service routing and training authority are preserved. F holds frame0 and opens the matching portrait; cancel resumes reading, complete opens the existing skill menu, closing the menu resumes simulation. Old/new comparison restores original Eira presentation and position.
- Adapter `levels/sanctuary/review/eira_renewal_review.gd`; builder `tools/build_eira_renewal.gd`; sources/exact prompts/manifest `art_source/generated/characters/npcs/eira/renewal_2026_10_01/`; assets `assets/characters/npcs/skillkeeper/renewal/`. Built-in imagegen referenced current King, Orren V2 and Eira's old violet scholar identity.

## Town life and discovery — implemented review, Decision163

- The old red merchant cart and six old tree nodes are hidden and disabled in the new view. Old comparison restores their visibility, processing and collision. Generated linden/cedar assets use small trunk footprints, planted stone bases and canopy reveal; east tree placement leaves Orren's station readable.
- A low anvil/tool station at1038,430 supports Orren's courtyard; Eira has a lectern at248,414 with the doorway approach kept clear. A noticeboard at438,658 opens the town map with F. Intact wall runs with terminal/corner pillars define garden edges and deliberate portal/service openings.
- All four service NPCs receive subtle role-colored foot ellipses and identity labels. Proximity triggers a brief speech line at most once per20seconds; Orren/Eira look up for1.1seconds and then return to authored work. Dialogue suppresses ambient speech and retains existing portrait/service flow.
- M or the map button opens a compact map above the action tray. It shows King, paths, major landmarks and four services plus the gate. Selecting a row highlights that NPC and displays a directional cue or F at close range. This is directional discovery, not autowalk/pathfinding; clearing/old comparison removes selection. Dialogue and service/pause menus hide the overlay immediately.
- One teal courier uses sixteen walking drawings plus four directional standing poses. It follows a collision-checked loop, pauses near Orren/Eira, yields within28px of King and cannot physically block him. Ambient actor only; no rewards, dialogue, service or save ownership. Native gameplay feel is still an owner review item.
- Sources/prompts: `art_source/generated/environment/sanctuary/inhabited_2026_10_01/` and `art_source/generated/characters/npcs/courier/inhabited_2026_10_01/`; builder `tools/build_sanctuary_life_art.gd`. All new raster art uses built-in imagegen and binary-alpha nearest runtime normalization.

## Next passes

1. Owner judges town composition, work corners, new trees/walls, map/markers, approach greetings, courier gait/pacing and Eira's reading identity. Refine before producing more service NPCs; Orren V2 remains the family reference.
2. Refresh Nema with her crafting garden and Umi with her arcane study individually. Both still use their old art. Preserve each service, match current King density, and review each identity/portrait/idle before advancing.
3. Complete the town composition and implement one complete doorway/interior/return proof before adding more interiors. Lodge and workshop expose Doorway, Approach and ReturnPoint markers with service identity and `interior_status=planned`; they have NO enter action or room yet. Future entry should reuse transition authority, preserve progression and health, return to a safe door approach, and avoid duplicating NPC service ownership.
4. Review the whole NPC family for consistent human scale, planted poses, clear silhouettes, interaction facing and collision. Any additional NPCs introduced later should follow the accepted density and portrait family.
5. Promote accepted assets/layout into authored production scenes, audit obsolete references, then resume Eira's campaign skill-upgrade work.

## Verified and remaining

Decision163 verification: `tests/sanctuary_life_smoke.gd` passes91 rendered/82 headless checks, including real F10/button entry, reuse without duplicate overlays, legacy prop/collision restoration, courtyard access, all sixteen walk drawings, complete courier circuit/yield/rest, M/map-button clicks, NPC greeting/hold/resume, noticeboard F, canopy fade, modal hiding, map bounds and save suppression. The existing108-check rendered review and production hub smoke also pass. Native captures share `art_source/review/environment/sanctuary_life_2026_10_01/`.

On 2026-10-01 the expanded study passed108 GPU checks (94 non-rendered): terrain coverage, full original/new comparison, both buildings' approaches/collision/roof fade, routes to all services/gate, both NPCs' eight unique registered frames/full playback, unchanged body/trigger shapes, real F interaction, canceled/completed Eira dialogue, portrait/skill menu, talk/work transitions, other services and save suppression. Fourteen native captures include Eira/Orren dialogue and explicitly2x detail views beside King. Production Sanctuary hub smoke passes. The earlier extra guardian collision polygon crossing the portal doorway was removed; smoke expectations cover six authored stages plus one future route and report blocking collision owners.

Shared GPU teardown texture warnings remain. Full interiors, remaining buildings, Nema/Umi replacements, final layout/navigation, mobile profiling, Eira visual acceptance and campaign promotion remain unfinished. The optional study is not the full Sanctuary renovation.
