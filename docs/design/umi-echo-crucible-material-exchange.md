# Umi's Echo Crucible

## Player flow

Umi stands east of Sanctuary's center avenue, facing left toward a narrow Echo Crucible. Speak to her and complete the short introduction to open a compact two-tab surface.

- **Sell Materials:** choose an owned, sellable material, set quantity, preview exact gold, and confirm.
- **Reconstruct Echo:** choose any catalog target, inspect source-memory progress, click owned fuels to add one unit, right-click to remove one, or use Auto Fill. Confirm only when meld, gold, source memory, catalysts, and any boss-memory charge are valid.

Both operations save at the Sanctuary safe point. A failed spend, output grant, or save restores the material, coin, and boss-memory snapshots.

## Automatic material contract

Umi never owns a material list. `material_catalog.tres` is canonical and each `MaterialDefinition` supplies:

- stable identity, region, rarity, family, icon, and description;
- stable source enemy ID and display name;
- optional overrides for sell value, meld value, reconstruction meld/gold cost, required defeats, and same-region Rare catalysts;
- explicit sell, fuel, and reconstruction permission flags.

Rarity defaults provide usable behavior for new content, while overrides handle exceptional materials. Boss rarity defaults to protected sale/fuel values and the four-Rare-catalyst reconstruction rule; authored boss resources also disable sale and fuel explicitly.

## Balance defaults

| Rarity | Sell | Meld per unit | Target meld | Target gold | Source defeats |
|---|---:|---:|---:|---:|---:|
| Common | 1 | 1 | 25 | 10 | 1 |
| Uncommon | 5 | 10 | 100 | 75 | 10 |
| Rare | 18 | 35 | 400 | 200 | 20 |
| Boss | Protected | Protected | 1500 | 1000 | 10, override per boss |

Boss reconstruction additionally consumes four Rare materials from the same region and one boss-memory charge. A charge is earned every ten recorded victories. Rootbound Core unlocks at ten Rootbound Husk victories; Varkuun Core unlocks at twenty Varkuun victories.

Auto Fill reserves required Rare catalysts first, then consumes the lowest meld-value owned materials until the target threshold is met. It does not select the target itself, protected Boss materials, or unavailable quantities.
