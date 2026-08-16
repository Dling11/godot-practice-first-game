# Roadmap

This file records current production progress. Historical implementation detail belongs in `CHANGELOG.md`; major superseded choices remain in `docs/decisions/`.

## Completed

- Godot 4.7 top-down production foundation with 960x540 logical rendering, keyboard/mouse/controller input, pause flow, scene transitions, and reusable data-owned combat authority.
- King is the sole production player with four-direction locomotion/basic attack, dash/backstep, hit reactions, defeat, persistent vitality/progression, equipment aggregation, and four active skills: Echoing Sever, Riftbreak, Sovereign Pursuit, and Worldsplitter.
- Basic attacks and skills use committed direction, authored hit shapes, damage, knockback, stagger, hitstop, camera response, audio, and world-space feedback without moving authority into animation.
- Contextual controls through Decision 112: right-click ground movement/enemy engagement; left-click movement cancellation and directional air swing; single enemy left-click selection; double-click pursuit/attack; right-click/`Esc` targeted-skill cancellation; optional `AUTO ALL` and `AUTO SKILL`.
- Size-aware enemy footprints drive movement collision, navigation radius, crowd separation, readable tier auras, foot-circle selection, and assisted approach distance. Hurtboxes and attack shapes remain separate.
- One six-cell generated combat-action atlas supplies King Skills 1-4, Basic Attack, and Dodge/Dash through reusable `AtlasTexture` resources.
- Sanctuary with Eira skill information, Orren lore dialogue, Nema's read-only Living Rootforge, expedition selection, debug-only Combat Lab access, and safe-point autosave.
- Forest Stages 1-5, including authored TileMaps, bounded live-enemy pressure, sparse/protected loot, Stage III Rootbound Husk, Stage IV Armored Hog pressure, and Stage V Varkuun encounter/reward flow.
- Versioned disk save/Continue with temporary write, rotating backup, story/progression/health, King weapon/gear, materials, recipes, and reward claims.
- Opaw, the retired weapon shop/awakening flow, unused equipment showcase, obsolete processors/tests, and 30 unreferenced images moved into recoverable Godot-ignored archives. The post-cleanup runtime image audit reports no unreferenced images under `assets/`.

## In Progress

- Owner feel-test Decision 112 in the normal game: click priority, single-versus-double selection clarity, footprint picking, pursuit around obstacles, moving targets, large bosses, and manual WASD override.
- Owner feel-test the taller enemy roster, target panel, tier foot auras, target chevron, generated cursors, six-cell action atlas, and Stage IV eight-enemy readability at 960x540.
- Feel-test King's attack timing and the complete four-skill kit, especially Riftbreak impact readability, Sovereign Pursuit anchoring, and Worldsplitter commitment/damage/cooldown against crowds and bosses.
- Validate Stage V pacing, Varkuun audio/telegraphs, reward cadence, and saved return flow in a complete non-debug playthrough.
- Keep documentation aligned with King-only runtime truth and classify any newly discovered dead asset before moving it to the archive.

## Planned

### Forest Production

1. Implement atomic Rootforge crafting: validate recipe/unlock/material state, spend once, grant once, persist once, and recover safely on invalid input.
2. Add replayable Hunts for completed stages with explicit reward families and modifiers.
3. Continue authored Forest content from Stage 6 through Stage 10 using distinct enemy roles, readable telegraphs, regional materials, and bounded live-enemy caps.
4. Finish the regional gear/accessory/relic progression and bounded Mastery contract.
5. Define the Stage 11 seam before starting another region.

### Release Readiness

- Decide target-platform priority and set measurable desktop/web/mobile budgets.
- Add accessibility, localization readiness, settings persistence, export validation, compatibility testing, and performance profiling.
- Finish onboarding, balance passes, campaign pacing, and production-quality owner review at the logical viewport.

## Deferred

- Ultimate and Reality Breaking gameplay; both are presentation-only reserved tiers.
- Additional playable characters. New roster work begins only after King and the release slice are stable.
- Multiplayer, branching routes, challenge modes, and mod support.
- Divine-weapon immunity and other high-tier rules that currently have no production content.

## Technical Debt

- The combat action buffer, assisted targeting, and auto-combat are structurally tested but still need long-session feel/profiling in obstacle-heavy Stage IV/V encounters.
- Some historical ADRs and `CHANGELOG.md` intentionally mention retired Opaw systems. They are records, not current instructions.
- Audio settings remain session-only.
- Sanctuary expedition previews still expose sealed future routes whose content is not implemented.

## Next Decision Gate

Approve the Decision 112 control feel in the running game. If pursuit reliably reaches and damages normal, Elite, and Boss footprints without fighting manual input, retain the size-aware approach contract and proceed to crafting. If it fails, adjust approach padding/navigation steering from recorded cases; do not add a second movement or damage authority.
