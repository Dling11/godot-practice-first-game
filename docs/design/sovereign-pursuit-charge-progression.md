# Sovereign Pursuit: proposed range and charge progression

Status: owner idea recorded 2026-09-26; numeric balance, unlock stages and charge implementation remain open. Current runtime has one 220px cast and an 8.5-second cooldown. Decision 157 promoted the blade-cut art to normal play; art promotion does not grant any charge upgrade.

Pursuit is King's precise, aggressive movement skill. Its upgrades should let the player choose more entries and escapes, while each landing stays one compact hit. The player aims and commits each use separately; three charges never fire as one automatic triple attack.

| Proposed rank | Maximum aim range | Stored charges | What changes |
| --- | ---: | ---: | --- |
| Foundation | 220px | 1 | Current targeted leap and single landing hit. |
| Advanced | 240px | 1 | Longer route choice without extra damage or area. |
| Awakened | 260px | 2 | One additional stored use for repositioning or a second deliberate entry. |
| Mature | 280px | 3 | Three deliberately aimed uses at full stock; still one contact per cast. |

Start balance testing with **one charge restored every 8.5 seconds, sequentially**, up to the rank's maximum. Using a charge must never reset the recharge already in progress. A fully spent Mature stock would therefore take 25.5 seconds to refill. The HUD should show charge pips plus progress to the *next* charge; targeting should display the active rank's maximum reach. Unused stock does not grant passive damage.

Keep the current .14-second windup, .28-second collision-safe travel, .24-second recovery, 52px landing radius and 125% weapon hit **per cast** for the first balance prototype. Invulnerability applies only during each actual traversal, never between charges or during recovery. Each accepted input spends exactly one charge and produces exactly one landing hit. If a cast is blocked or canceled before commitment, it must not consume a charge. The existing 1.2-second Pursuit-to-Skill-2 +15% link should be refreshed by a landed cast, not stacked additively by repeated Pursuits. Existing Resolve, mastery, equipment and ten-slot rules still apply.

Before campaign promotion, measure sustained damage, three-charge burst damage, terrain-obstructed travel, input buffering, enemy pressure between leaps, the Skill-2 link and phone performance. Decide which milestones award the ranks and how rank/charge state persists only after those tests. Range values and recharge are starting numbers, not locked balance.
