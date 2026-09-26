# Combat Lab tab review — 2026-09-27

Four actual Godot GPU captures at 960x540: AI, upgrade selectors, scrolled King diagnostics, and buff activation. Reproduce with:

```powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --path . --resolution 960x540 --script res://tests/combat_lab_sidebar_smoke.gd
```

The same script headlessly performs 26 assertions; GPU mode adds four successful-image-write checks. It verifies a sparse campaign loadout remains untouched, actual F9 keyboard handling restores the complete kit, upgrade bindings survive, and switching tabs cleans up active preview state. This fixture selects later forms for demonstration and never saves.

The existing two 5460-byte texture leaks / RenderingServer-null warnings still occur at GPU shutdown, as previously reproduced at the title screen. Headless checks exit cleanly. These screenshots validate desktop layout, not phone performance or subjective combat feel.
