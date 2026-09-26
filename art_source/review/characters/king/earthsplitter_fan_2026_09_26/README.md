# Earthsplitter Advanced Fan - September 26, 2026

Actual Godot Compatibility playback at 60fps, with reused skill audio. Foundation appears first, followed by Fan in eight compass directions plus 17-degree aim, damage targets and terrain. Targets have AI paused for deterministic capture; this is not a boss-balance or phone-performance test.

One smash releases center and +/-20-degree lanes from the same contact 34px ahead. Center reach 196px; each branch travels 162px from contact, with 19px radius. Terrain independently shortens each branch. One 185% weapon hit per enemy across all lanes prevents overlap damage multiplication. No stun. Cast .36s, travel .25s after .20s contact, cooldown 5s; accepted-hit pauses still apply. Approved sword/ground artwork remains intact.

F7 -> KING REVIEW -> SKILL 1: EARTHSPLITTER -> FORM: FAN. Press 1, aim, left-click to cast. FORM cycles Foundation -> Fan -> Cascade. Direct --earthsplitter-advanced-review opens Fan. Cascade is preserved unchanged as a later-form candidate; campaign promotion/unlock saves remain pending.

Validation: Fan 98, Foundation 116, Cascade 49, rendered atlas 29, targeted Riftbreak 28, Spellward 232 and mastery 385 checks passed (937 total). Fan checks cover all main headings and intermediate aim, fixed range/common contact, simultaneous release, center/side targets, overlap accounting, source movement/stat snapshots, branch-specific wall stops, no stun, recovery, source defeat, loadout binding and restoration. UI screenshot verifies the actual three-form button. The new capture tool is tools/capture_earthsplitter_fan.gd; the earlier Cascade capture is retained separately.

Owner feel review and actual phone profiling remain pending. No new raster/audio assets were generated or downloaded.
