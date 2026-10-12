# Known Issues

Updated 2026-10-13. Historical fixed bugs and rejected art trials were removed from this active list. Runtime code remains the authority.

- **Twinsteel carry motion:** current dual_carry_v3 is installed and technically checked, but owner motion approval remains pending. Steady upper anatomy is deliberately calmer than arm-swinging locomotion.
- **Weapon acquisition/balance:** debug equipment availability does not establish campaign crafting/unlock rules. Compare reach, damage, knockback, recovery and incoming pressure before retuning. Iron Reaper is selected but not implemented.
- **Performance:** prior short desktop samples are not phone/cold-load/stress guarantees. Keep event/phase-driven presentation; profile crowded fights and skill1 feedback on target devices.
- **Campaign completeness:** production route reaches VI. StagesVII onward, divine/domain rewards and Stage XX routing are not implemented; Examiner remains an isolated Lab trial.
- **Progression/economy:** later skill forms are Lab experiments; campaign unlock/persistence and Nema/Umi resource/gold pacing need full fresh-save measurements. Accessories and later gear remain incomplete.
- **Encounter feel:** Stage VI mixed Bear/Hog/Spitter composition, anti-stunlock breakouts and final boss survival need owner testing across no-armor/starter/crafted builds.
- **Presentation:** Sanctuary map is intentionally hidden. Portal tier dominance, actor occlusion and full moving-camera readability still need owner-scale review; cleanup changes no portal art/physics.
- **Regression fixtures:** 54 of 134 retained smoke scripts emit ObjectDB/resource exit warnings despite passing assertions. All134 currently pass assertions and all 868 resources load. Treat those passes and clean teardown separately; see cleanup verification for exact results.
- **Git history:** deleting old art from the working tree does not remove reachable blobs from earlier commits. Local/history storage can remain large until a separate shallow/fresh-repository or explicitly approved history-migration workflow.
- **Distribution:** the lightweight ZIP is a Godot source project. A standalone executable/export is not yet validated by this cleanup. Saves are local and excluded.

Current cleanup scope/results are recorded in docs/maintenance/repository-cleanup.md. No archive dependency should remain in supported tools/tests.
