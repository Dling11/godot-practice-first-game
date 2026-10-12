# Before Twinsteel gait grip correction — 2026-10-12

Scoped snapshot of1097 complete King asset dependencies, the Twinsteel presentation selector and the shared-body builder, copied before the walking attachment change. Each copy's SHA256 was independently compared with its source; `manifest.json` retains relative paths and hashes. `.gdignore` excludes these rollback assets from runtime import.

The snapshot is not a full project/save backup. Archived resource selectors contain absolute `res://` paths; loading an archived profile can still resolve live resources. The native before viewer therefore loads the archived old gait clips explicitly and uses their still hash-protected old masks and immutable runtime body atlases. Never infer old contact pixels from a selector alone.

Current correction preserves1095 snapshotted King assets. Only `tools/build_king_shared_bodies.gd` and `data/weapons/families/twinsteel_v2/presentation.tres` may differ, with the selector limited to three running paths. New sibling gait assets contain metadata/masks and reference unchanged canonical body PNGs. [Current evidence and play](../../review/combat/king_dual_gait_2026_10_12/README.md).
