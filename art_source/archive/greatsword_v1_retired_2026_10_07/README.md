# Retired Greatsword V1

2026-10-07. Owner explicitly requests removing the old five-cut comparison item after accepting V2.

`manifest.json` preserves SHA256 for 18 moved item/weapon/family-resource and obsolete V1-only test/capture files, including script UID sidecars. `.gdignore` excludes this rollback/source archive from active project imports. Archived resources retain their historical paths and are not standalone playable content; restore their original locations to investigate an older delivery.

Shared approved steel, native walking/carry, proud idle and plant effects remain live dependencies of V2. The offline Oathbound helper remains the V2 source-registration base. The old confidence launcher now delegates to the actual approved Combat Lab shortcut, rather than exposing V1 again.

Saved V1 ownership/equipment is migrated to the existing V2 ID by WeaponInventory. [Current migration/audio/play rules](../../../docs/design/weapon-impact-closure.md).
