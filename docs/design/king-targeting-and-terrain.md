# King targeting and terrain

Implemented 2026-10-03, Decision177. This supersedes earlier terrain-clipped Earthsplitter/Worldsplitter and wall-stopped Pursuit descriptions.

| Action | Reach and obstacles |
|---|---|
| Basic sword | Existing 36px-forward/44px-wide physical fan. Scenery does not shorten it; each swing still deduplicates contacts. |
| Slot1 Earthsplitter | Full 164px Foundation lane; trained recipes retain 196/228px coverage and their existing hit ledgers/delays. World scenery neither clips the preview nor stops the released front. |
| Slot3 Pursuit | 220/250/280px aim by rank. Can fly over any obstacle to valid ground. Its real foot shape cannot land inside world collision, beyond movement bounds, or outside registered navigation ground. Occupied targets retreat toward King before a safe fallback. |
| Slot5 Worldsplitter | 260/280/300px target reach and 88/96/104px final radius by rank. Terrain does not clip the target or suppress radial contacts. Existing foot-distance check, plunge timing, damage shares and final-only stun remain. |

Pursuit disables world-mask bit1 only during ACTIVE flight. The previous bit is restored on landing/cancel/exit, including safe relocation if interrupted inside a prop. Preview resolves landing, acceptance resolves again and release revalidates after wind-up. Scenes without navigation regions use physical landing/bounds checks; registered scene navigation prevents treating a pit or absent ground as clear air to land on. Invulnerability remains travel-only; charges/refill/save rules stay unchanged.

Targeting measures every circle and lane from the same actor feet used by the cast, including data-owned offsets. Active ground aiming runs on render frames, skips unchanged input and stops when hidden. All hardware cursors use24px canvases: arrow/interaction/sword have at most20px content, aim16px. Hotspots: aim(12,12), arrow/sword(2,2), interaction(7,6). CursorService releases both custom hardware bindings before renderer teardown.

Owner rejects gold and then finds the silver ornamental frames oversized/distracting. Current AOE uses one1px boundary at44% opacity,2.5% fill, four4px cardinal ticks and a10px open center mark. Maximum range uses four short arcs at7% opacity,15% near90% of reach. Distinct inner cores use a16% segmented line; identical cores are skipped so opacity cannot compound. Lanes use40% outline/3.5% fill and one small chevron. Silver/slate/violet remains mandatory; skill ranges/radii are unchanged. No ring texture extends beyond the hit geometry and no visual easing delays aim.

Active assets: the four generated cursors in assets/ui/targeting/. Builders: tools/build_targeting_art.gd (aim) and build_muted_cursors.gd (other three). Ornate ring/glyph PNGs/imports are retired under art_source/archive/ornate_targeting_2026_10_03/; their builder also writes historical outputs there. Original alpha sources/prompts/rejected gold reference/crop manifests remain under art_source/generated/ui/targeting_2026_10_03/ and muted_cursors_2026_10_03/. Cursor normalization thresholds faint alpha before crop, then nearest samples with binary alpha/no mipmaps. Rings are exact native geometry with intentional overall blending.

Normal play: restart F5, enter a stage, press1/3/5, aim, left click to confirm; right click/Esc cancel. Test1 across a tree,3 beyond a wall to clear feet, and5 on enemies across scenery. Existing progression gates still apply; F7 Combat Lab provides isolated unlocked testing. No profile migration is needed.

Evidence: native33 terrain checks previously passed. Current subtle presentation passes39 native checks plus the current UI/icon smoke, with six Stage IV captures in art_source/review/ui/targeting_subtle_2026_10_03/. Previous45-check ornate captures remain historical. Current native39 run exits cleanly after hardware-binding cleanup; earlier two texture/RID and RenderingServer-null warnings are absent in this focused run. Headless Worldsplitter118 checks and Pursuit charge/explicit-target regressions pass; eight-target Fan/Cascade yield16/24 contacts without global pauses. A separate native first/repeated eight-target Foundation fixture yields8 contacts over7 physics ticks and zero global pauses each, physics peaks2.756/2.111ms. It disables enemy AI and is not a full cold campaign, phone GPU or representative combat benchmark. Prior five-target16.82ms spike remains a separate open investigation. Functional headless tests ran concurrently; their timing prints are not benchmark evidence.

Next: review owner feel/legibility, material hit/guard/interruption audio and four-direction contact readability, then representative cold/warm campaign/phone measurements. Do not rebuild loading or expand spawn sheets per body size.
