# Retired Sanctuary material — 2026-10-02

Recovery archive for Decision165. This folder is excluded from Godot importing through .gdignore. The renewed town is now the single normal-play baseline under levels/sanctuary/town/.

- retired/ retains obsolete code, assets, tests, builders and UID/import sidecars at their original relative paths.
- snapshots/ retains pre-closeout town/NPC code, asset-builder revisions and complete prior project/design/handoff documents, including earlier conflicting iterations.
- retired_paths.json lists paths that must stay absent from live folders.
- file_manifest.json records preserved file sizes and SHA256 hashes. The old hub smoke is recoverable under retired/tests/sanctuary_hub_smoke.gd; its live filename now belongs to the new normal-town regression.
- closeout.ps1 records the initial migration procedure for provenance; it is not a repeatable runtime command.

Current source art/prompts and useful evidence/builders stay outside this archive. No gameplay/save migration or archive-based runtime fallback exists. Recovery requires restoring matching consumers and resources together in an isolated checkout, importing and testing before adoption. Do not restore old visuals merely because a source file still exists here.

Current documentation: docs/design/sanctuary-closeout.md and CONTINUE_SANCTUARY.md.
