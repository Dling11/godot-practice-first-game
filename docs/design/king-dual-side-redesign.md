# Twinsteel V2 side combo study

**Promoted (2026-10-07, Decision190):** Owner accepts this side study and requests installation plus cardinal/gait/proud idle. Normal Twinsteel now uses this combo with new front/back cuts and movement. The original study and its185-file preservation proof remain historical read-only references. [Current installed guide, controls and proof](king-dual-v2-cardinal.md). The side-only statements below record the original delivery.

2026-10-07. The owner selects **A: Iron Reaper** as the future scythe silhouette, then prioritizes a fresh dual-sword attack pass inspired by the accepted Greatsword V2 procedure. Start with LEFT/RIGHT, remove the first thrust, and replace the mismatched slash style. This document owns the new study; the installed four-direction Twinsteel remains the preceding version until this motion is reviewed and promoted.

## Review and proposed pattern

Run `tools/launch_king_dual_side_redesign.ps1`. The dedicated Godot window displays LEFT and RIGHT simultaneously. Space replays the full chain; 1–5 isolate a cut, P pauses, H selects half speed, Escape closes. This is a presentation review with no Player, damage, reward, equipment grant or save mutation. F5/F9/F7 still use installed Twinsteel.

The new sequence is near-hand diagonal cut → far-hand returning cut → rising crosscut → compact hopping full spin → springing crossing finisher. Both side attacks keep the target in front. The opening is a sweep, with a broad curved release. Two swords continue to represent one weapon family; eventual gameplay must retain one deduplicated contact per target/input.

| Cut | Load | Contact | Recovery |
|---|---:|---:|---:|
| Diagonal | 0.14s | 0.08s | 0.16s |
| Return | 0.12s | 0.08s | 0.14s |
| Rising cross | 0.15s | 0.10s | 0.15s |
| Hop spin | 0.16s | 0.22s | 0.15s |
| Crossing finish | 0.23s | 0.10s | 0.22s |

These are proposed presentation budgets totaling 2.20s, not installed combat tuning. Short contacts concentrate the sweep; loading and settling retain the legible body movement. No damage/DPS/reach change is claimed from these images. Before promotion, replace the first narrow thrust shape with the intended fan and validate live contacts, queue/release/cancel, held input, collision travel and real enemies through existing Melee authority.

## Source and registration

Built-in imagegen produced 40 complete body-only source cels (five rows of eight) and 20 original white/silver/dark-slate raster effects (five rows of four). The approved King identity, accepted dual carry/run and canonical 16×62 outlined steel remain the references. Both blades register independently to real drawn glove pixels, with foreground finger masks and pose-owned depth. Native head/scarf socket attachment uses existing full-body ingestion helpers. Spin turns the whole body and uses the native front/back/left identity; ordinary cuts stay side-facing.

One fixed density applies to all 40 source bodies. Downsampling retains opaque source coverage where nearest sampling would drop a thin forearm; it uses existing source colors, followed by the installed palette, binary alpha and native head attachment. Original neutral sleeve/outline pixels beside raised fists are restored where head attachment erased them, outside the central face and without overwriting retained head pixels. There is no invented runtime arm or head layer. Each authored back-left spin cel hides its far arm; the far blade is explicitly hidden there too, rather than attached to cloth. All other visible grips require actual drawn palms connected to the body.

The five sixteen-key clips include independent release and queued recovery branches. Queued end cels, both grip transforms and complete body/hand images are copied into the following opening. Released cuts settle to accepted idle. Only the spin/finish have small authored lift, never a body-scale tween.

Effects use real transparent row bands and whole connected-ribbon ownership in padded source cels, then one density per row with generous192px output-cell margins. Nominal equal-row/column slicing was rejected because the generated rows differ in height and some complete ribbons cross a nominal gutter. Binary alpha, nearest/lossless imports, no mipmaps/alpha-border processing and clipped AtlasTextures remain. The new crescents, rising pair, spin ellipse and crossed finisher share the approved heavy-family palette, while retaining lighter twin-blade silhouettes. No runtime vector ring or contact-shape clipping is used in this preview.

Source/prompts/registration: [generated source](../../art_source/generated/characters/king/dual_side_redesign_2026_10_07/README.md). Native captures, GIF and checks: [review proof](../../art_source/review/combat/king_dual_side_redesign_2026_10_07/README.md). Before-work rollback: [185-file snapshot](../../art_source/archive/dual_before_side_redesign_2026_10_07/README.md).

## Scope and next step

Native rendered verification passes6209/0, with210 captures and a105-frame30FPS GIF. Head/neck/arms and both visible grip connections, exact queued/released boundaries, full FX padding, both rendered directions and review controls are checked. Teardown is clean. All185 installed baseline/rollback files remain identical; the16 PNG/TRES study outputs reproduce. Technical checks are not owner animation approval.

Owner motion/identity/slash judgment is pending. UP/DOWN attacks are not newly authored by this side study, and no new Twinsteel item, save ID, recipe, sound or production combat behavior is introduced. Installed axe/Greatsword/sword and accepted dual locomotion remain untouched. After side acceptance: generate true compatible vertical cels, integrate the selected sequence, rerun actual contact/held/weapon-swap and enemy-role comparison, then return to the selected Iron Reaper scythe. Prior enemy/audio closure evidence describes the installed weapons, not this proposed combo.
