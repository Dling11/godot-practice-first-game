# Molten Crash upgrade review

Recorded in Godot 4.7 Compatibility at 60 FPS. `molten_crash_upgrades.mp4` includes sound; the GIF gives a quick silent comparison. `form_0..3_contact.png`, `form_0..3_center.png` and `form_0..3_after.png` show the four stages in game. `playable_lab.png` shows the actual review controls.

Open Combat Lab, press F7, enter KING REVIEW, turn on SKILL 2: MOLTEN CRASH and press the adjacent FORM button to cycle Foundation, Advanced, Awakened and Mature. Skill 2 remains on key 2. The direct `--molten-crash-review` launch starts at Foundation while Skill 1 Fan is also active. The old Skill 2 returns when the review is disabled; no saved loadout grant is made.

Foundation: blue stone and white-cyan light, 72px contact, 200% weapon. Advanced: approved orange molten, 80px contact, 230%. Awakened: 84px contact for 192%, then one outward 86px world-fixed heat wave for 48% after .34s. Mature: a compact animated basalt uplift over the 48px damage core, 86px initial radius, 216% in the core and 72% of that initial value at the rim, then the same 86px heat wave for 54%. Initial contact owns the .55s authored stun, subject to target resistance; the pulse never stuns. All forms keep the .36s player action and 8s normal cooldown. Percentages are before mitigation and exclude critical hits and existing modifiers.

The playable capture proves visual timing, scale and early movement. The 38 upgrade and 40 Foundation assertions separately check radii, damage, stun, wall/foot rules, Mature's visible center, defeat/review-exit cancellation and original skill restoration. This capture does not establish phone frame rate or campaign unlock balance. Skill 3 planning is next.
