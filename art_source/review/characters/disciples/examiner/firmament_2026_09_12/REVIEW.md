# Living charge and Crimson Firmament

[Rendered Godot review](firmament.mp4): continuous gathering/growth, faster Sun impact, persistent Unbound aura, crimson charge, successive red meteor waves, open corridor and interrupted cast.

The charge uses sixteen distinct energy frames at 18 fps, continuous scaling/pulses, counter-rotating seals and inward streams. Approved body textures and SpriteFrames remain unchanged; bracing rotates around the feet and the new barrage reuses strike, rise and channel poses. Crimson effects retain hot ivory cores for contrast. Three new original synthesized cues add accelerating charge pulses and a weighted release.

**Play:** F7 or `Play Examiner.cmd`; King starts invincible. Borrowed Sun now throws in 0.24s and flies in 0.72s, or 0.62s in berserk, with 84/116px impact radii. Its modest movement prediction locks before flight. Ground warnings begin during release.

**Crimson Firmament:** berserk only, 180-point seal over 3.8s. Break it for the existing stun; failure starts four waves of three red meteors. Each warns for 0.85s, impacts once and leaves one whole column clear for that cast. The column changes on the next completed cast. Ordinary dodge remains effective. The actor commits through the barrage and recovery; it does not add melee on top of these waves.

**Validation:** nine clean Godot checks: Firmament, Ascendant, Worth, Trial, rework, effects, boss HUD, Combat Lab and runtime/archive boundary. Includes real damage, guard cancellation, all twelve meteors, clear-corridor geometry, bounded prediction, dodge, pause and death cleanup. Source processing checks sixteen distinct padded frames. Body hashes are compared with the approved baseline. Final Stage XX loadout balance and owner feel-testing remain pending.

The video uses a scripted review path and explicit phase/guard hits to demonstrate mechanics; it is not evidence of a normal loadout clear.

**Art:** generated using built-in ImageGen with the approved Sun as reference. Runtime atlas: `assets/vfx/divine_order/examiner/sun_loop.png`. [Exact prompt and method](../../../../../generated/characters/disciples/examiner/firmament_2026_09_12/prompt.md); immutable source and import report are beside it. Pack with `tools/process_examiner_firmament.py`; synthesize cues with `tools/generate_examiner_firmament_sfx.py`; capture with `tools/capture_examiner_firmament.gd`.
