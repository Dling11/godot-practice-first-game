# Sanctuary renewal — staged environment and NPC work

**Latest owner review:** Workshop/house and fantasy theme are enthusiastically accepted. First Orren was too small-headed and faint beside King's bolder edges. V2 generated edit now uses a60px source body at half scale, larger head/broader silhouette and stronger dark outlines, plus an outlined Orren/Armskeeper nameplate. All eight frames retain foot baseline80. Current atlas `idle_work_v2.png`; source `idle_readable_source.png`; exact edit prompt `READABILITY_PROMPT.md`. Latest evidence: `art_source/review/environment/orren_readability_2026_09_30/`;78 rendered checks pass (68 non-rendered). Previous76-check/55–56px figures below describe the first candidate. Revised NPC acceptance remains pending. New-chat handoff: `CONTINUE_SANCTUARY.md`.

Updated 2026-09-30. Owner direction: a richer fantasy RPG settlement, finer tiles, useful buildings with future interiors, and all NPCs refreshed to match current King. The owner accepted the first environment direction and explicitly brought NPC remodeling into the next building pass. Proceed gradually: Orren and workshop together first, then individual NPC/building pairs, portraits and genuine idle animation. Preserve service functionality. King Skills 1–5 remain accepted.

## First playable study — implemented, direction accepted

Run `tools/launch_sanctuary_study.ps1`. It loads the actual Sanctuary services with autosaving suppressed and adds the optional `levels/sanctuary/review/refuge_study.gd` environment overlay. The default campaign map is not promoted to this candidate yet.

- 32px ground tiles over the same 1152x768 footprint; quiet meadow, earth, irregular stone and sixteen cardinal paving transitions.
- A new blue-roof trainer lodge with a measured doorway anchor, authored collision and rear overlap fade to keep King visible.
- Modular lanterns, planters, benches and broken wall sections with separate ground footprints. Lantern presentation animates independently of collision.
- Compare old/new, Visit Orren, Visit lodge and Overview/walk buttons. Existing NPCs and service menus remain available with F.
- Current generated concept is a direction study, not a baked production map or an exact promise of the first slice. Runtime assets are individual tiles/props.

Originals and prompts: `art_source/generated/environment/sanctuary/refuge_review_2026_09_27/`. Builder: `tools/build_sanctuary_refuge_review.gd`. Runtime candidate assets: `assets/environment/sanctuary/refuge_review/`. Native captures: `art_source/review/environment/sanctuary_redesign/`.

## Orren and workshop — implemented candidate, awaiting owner review

- Newly generated mature artisan identity: short brown hair/silver streak, trimmed beard, charcoal rolled sleeves and russet apron; eight blade-inspection poses, clear hands and a matching 96px dialogue portrait. Initial stockier sheet is preserved as rejected provenance.
- One shared source scale produces 55–56px bodies, presented at half scale beside King's 28px body. Eight padded 96px cells use foot baseline80 and named `idle_down` playback at5fps with endpoint holds. New art moves hands/head/chest; the old whole-body bob is disabled. Dialogue holds his attentive pose; closing resumes his work.
- Generated charcoal-roof workshop with warm forge, sheltered tools, separate footprint/roof fade and five small forge particles. The original NPC node moves to the clear courtyard at992,438 without replacing its interaction/body shapes or dialogue authority. A short paving branch connects it to the main route.
- Old/new comparison restores original Orren position, portrait, frames, idle helper and workshop collision. Orren remains dialogue-only. Workshop Doorway/Approach/ReturnPoint reserve future entry at928,390; `interior_status=planned`, no enter action.
- Source/prompts/manifest: `art_source/generated/environment/sanctuary/orren_workshop_2026_09_30/`. Builder: `tools/build_orren_workshop_review.gd`. Presentation: `levels/sanctuary/review/orren_workshop_review.gd`. New captures: `art_source/review/environment/orren_workshop_2026_09_30/`.

## Next passes

1. Owner judges Orren's identity, scale, idle loop, portrait and workshop in the live study. Refine before producing more NPCs.
2. Refresh Eira to accompany the existing lodge; then Nema with her crafting garden and Umi with her arcane study. All three still use their old art today. Preserve each service, match current King density, and review each identity/portrait/idle before advancing.
3. Complete the town composition and implement one complete doorway/interior/return proof before adding more interiors. Lodge and workshop expose Doorway, Approach and ReturnPoint markers with service identity and `interior_status=planned`; they have NO enter action or room yet. Future entry should reuse transition authority, preserve progression and health, return to a safe door approach, and avoid duplicating NPC service ownership.
4. Review the whole NPC family for consistent human scale, planted poses, clear silhouettes, interaction facing and collision. Any additional NPCs introduced later should follow the accepted density and portrait family.
5. Promote accepted assets/layout into authored production scenes, audit obsolete references, then resume Eira's campaign skill-upgrade work.

## Verified and remaining

On 2026-09-30 the expanded study passed 76 GPU checks (66 non-rendered checks): terrain coverage, full original/new comparison, both buildings' approach/collision and roof fade, routes to all services/gate, eight unique registered frames, full idle playback, unchanged NPC body shape, real F interaction, talk/work transition, matching portrait, retained other services and save suppression. Ten native captures include Orren's dialogue and a labeled2x detail view beside King. Production Sanctuary hub smoke also passes. The earlier extra guardian collision polygon crossing the portal doorway was removed; smoke expectations now cover six authored stages plus one future route and report blocking collision owners.

Shared GPU teardown texture warnings remain. Full interiors, remaining buildings, Eira/Nema/Umi art/idle/portrait replacements, final layout/navigation, mobile profiling, Orren owner acceptance and campaign promotion remain unfinished. This document deliberately separates the optional study from the full Sanctuary renovation.
