# Accepted Greatsword snapshot — 2026-10-06

Created before the owner's new heavy-burst attack study. Contains679 independently verified files (6,107,292 bytes) with original project-relative paths. `manifest.json` records each path, byte count and SHA256. `.gdignore` prevents duplicate scripts/resources from becoming project content.

The snapshot includes accepted King art, Greatsword audio/tuning/items/family resources, player/movement/presentation dependencies, relevant Greatsword tooling/tests, design decisions and the previous weapon handoff. Shared King dependencies also include other weapon art. This is a scoped source snapshot, not a whole-project or engine/user-save backup.

The study leaves the installed implementation intact. To restore a future rejected Greatsword change, first identify affected paths from this manifest and restore only those matching paths; do not overwrite unrelated later shared-system work. Reimport restored assets with the project's Godot version and verify actual play. Native imports/caches are regenerated, not authoritative backup content.

All679 snapshot copies and original files matched the manifest after prototype generation/rendering. Subsequent project documentation intentionally records the new study; runtime code/art remain preserved. [Study and handoff](../../../docs/design/king-heavy-burst-study.md).
