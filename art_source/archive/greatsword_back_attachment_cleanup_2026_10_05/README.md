# Superseded Greatsword paths — 2026-10-05

Oathbound owns all five basic attacks in every facing. Live GDScript/TRES/scene references were checked before removing these unused paths:

- Ten original cardinal up/down attack sets,50 resource/atlas/import files.
- Superseded low-return resource/atlases/imports,5 files.
- Low-return builder/export and old upward anatomy inspector,3 tool/UID pairs (6 files).
- A **copy** of the cardinal builder before cleanup; its live path remains and now generates carry/run only.

`manifest.json` records62 original paths and SHA256 values;61 files were moved and one builder copied. `.gdignore` excludes archive code/assets from import and export. Raw source generation and historical review evidence remain in their original source folders. The retained12 cardinal carry/run runtime files reproduce byte-identically after cleanup. Do not restore old attacks into the active build without a new owner decision.
