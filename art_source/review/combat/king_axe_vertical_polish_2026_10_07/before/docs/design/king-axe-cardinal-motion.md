# Iron Beard axe: five-hit combo and head-led thrust

**Latest cadence (2026-10-07):** Loading/recovery shorten3.52→3.19s (9.4% shorter), while contact windows/shapes/damage/body/gait/steel/white FX/audio stay. Mean15×6.15/3.19=28.9 nominal base DPS. Wind0.21/0.17/0.17/0.32/0.25, contact0.18/0.16/0.18/0.20/0.30, recovery0.19/0.17/0.17/0.24/0.28s. Held LMB loops ordinary full combos. Native closure217/0 and held46/0 pass; owner cadence feel remains pending. Earlier3.52s/26.2 values below are the previous baseline.

**Current role/UI/audio closure (2026-10-06):** Owner passes this motion. Basic rolls are now14–16 physical, Skill Power25, base knockback60 and0.12s flinch. Same five-hit3.52s phases/contact/art give86.1–98.4 nominal chain damage and26.2 base DPS. Bag icon/inspection/descriptions and CC0 body impacts are installed; Greatsword is frozen. [Closure rules and proof](king-weapon-closure.md). Effective encounter balance and owner audio feel remain pending.

2026-10-06. The owner clarifies that a third thrust belongs between the upward cut and jump. Current normal equipment plays **chop → rising axe cut → axe-head thrust → hop slam → whirlwind** in all four facings. The thrust pushes the cutting head forward; the shaft butt remains behind the hand. The previous four-cut slice omitted this move. The older handle-led jab remains rejected history.

Chop, rise, hop slam and spin reuse accepted native body cels and the canonical Iron Beard axe. The third move reuses retained body-only push cels; its rejected weapon orientation is discarded. Offline registration uses the real pale cutting-edge texel (8,30), the drawn glove grip and the weapon's reflected shaft basis. Each contact key projects the cutting edge straight along committed aim, while the butt trails behind. The second hand anchor is an orientation guide for these one-hand poses. King's installed head, body scale, soles, carry and gait are preserved.

The five axe_flow/{side,up,down}/ clips contain thirteen keys each: four wind-up, three contact, three released recovery and three queued recovery. Queued endpoints inherit body, foreground glove, grip, depth and lift into the next opening without a guard flash. Two wind-up keys prepare the axe for the push. Released input returns to the accepted held idle. The existing presenter preserves the actual rendered entry for standalone/late inputs.

First, second and fourth hits use72px forward fans. The third uses a78px frontal head-push lane, with maximum40px width near its center. Only the fifth whirlwind is radial, at68px, with outward knockback. Every contact hits an enemy at most once. Large white energy edges are presentation and cannot award rear/off-axis/out-of-range damage.

A new built-in imagegen sheet supplies four broad white/silver thrust impact cels. Original chop/rise/slam/spin raster rows remain pixel-identical at their new row indices. All five effects use complete padded128px cels at1.1 world pixels per texel. The thrust origin is(44,64); the other rows use(64,64). Its source is ingested through real transparent gutters because the generated third tip crosses the nominal equal-column split. All four source tips align to one point before a shared union crop/scale; faint alpha noise is removed, and nearest sampling preserves sharp frames. Source artwork and exact prompt are retained. Other families keep their existing contact clipping.

| Hit | Wind-up | Contact | Recovery | Damage | Knockback |
| --- | ---: | ---: | ---: | ---: | ---: |
| Chop | .24s | .18s | .22s |115% |130% |
| Rising axe cut | .20s | .16s | .20s |110% |110% |
| Axe-head thrust | .20s | .18s | .20s |105% |140% |
| Hop slam | .36s | .20s | .28s |150% |180% |
| Whirlwind | .28s | .30s | .32s |135% |150% |

Nominal chain:3.52s and6.15 base-hit units (approximately1.747 units/s). Current14–16 physical rolls give86.1–98.4 unempowered chain damage and26.2 base DPS, before defenses/buffs/criticals/hitstop/speed gear. This is uninterrupted-chain arithmetic, not measured effective DPS or final campaign balance. Attack-speed bonuses scale phases. Skill Power25, item/save IDs and session F9 access remain; no crafting recipe or milestone gate is added.

Walking remains25% wind-up,0% contact,60% recovery/full idle. Incoming knockback and dodge retain independent authority; hop lift is cosmetic. Accepted carry, four-second back stow/retrieval and eight-cel resolved-travel gait remain untouched. Blocked movement freezes gait. Skills/dash/reactions keep existing action sprites and return to the family afterward.

Play: stop the running game; restart F5 → F9 → Tab → Iron Beard Axe → Equip, then F7 Combat Lab. WASD walks; left click attacks; SPACE dodges. tools/launch_king_axe_training.ps1 opens the real Lab with the axe equipped and normal controls/Bag, isolated storage and suppressed saving. The older side-review launcher follows the same five-cut data.

Builder: tools/build_king_axe_flow.gd. Runtime data: data/weapons/families/iron_beard/{combo,presentation}.tres. [Source/prompt/rebuild](../../art_source/generated/characters/king/axe_head_thrust_2026_10_06/README.md), [native preview/gameplay proof](../../art_source/review/combat/king_axe_head_thrust_2026_10_06/README.md). The previous four-cut runtime/builder/data snapshots are archived under king_axe_four_cut_before_thrust_2026_10_06; axe_rise_2026_10_06 is historical proof. Owner motion judgment, comparative balance, campaign crafting, bespoke family skills/reactions and device profiling remain open. Existing harness teardown diagnostics are documented separately from gameplay results.
