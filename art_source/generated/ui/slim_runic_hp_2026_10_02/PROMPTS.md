# Slim Runic production HP frame

2026-10-02. Built-in imagegen edit, transparent background. Owner selected A Slim Runic for its simplicity. Reference: ../hp_choices_2026_10_02/A_slim_runic.png. Source copied without altering the original generated output.

## Exact prompt

Edit the selected A SLIM RUNIC concept into ONE production-ready empty health HUD frame for Battle of Gods, a readable fantasy pixel-art game. Preserve the FIRST upper full-health widget's restrained visual design: very slim horizontal aged-gold rectangular border, tiny angular violet rune crystal tabs at the two ends, a SMALL raised centered charcoal label plaque above the bar. Remove the entire presentation card, all text, all numbers, all captions, second example and red health fill. Only the SINGLE empty HUD frame on true transparent background. Long low silhouette, overall aspect ratio about 5.4:1; intended native size 248x46 pixels. Main horizontal bar interior has a solid near-black charcoal backing, clean straight edges and absolutely no ornament inside its rectangular fill slot; bar slot runs from roughly 6.5% to 93.5% of frame width and roughly 64% to 88% of frame height. Small raised central plaque takes about 58% of total width, first 44% of height, blank dark slate face for game-rendered HP numbers. Delicate gold 1-2 native-pixel rim and dark outer outline; minimal violet end accents. No wings, feathers, swords, crest, hearts, circles, flowers, extra border, shadows cast outside asset, glow, blur, lettering or gradient. Crisp cohesive pixel clusters, quiet ivory highlights only upper-left, no antialiasing; precisely symmetrical usable UI geometry. Output asset centered and large with transparent padding. This is a functioning layered game UI asset, not a poster or a new mockup.

## Runtime normalization

tools/build_slim_runic_hp.gd thresholds alpha at .65 before tight cropping, resizes with nearest sampling to 248x38, and writes normalization.json. Game controls own HP text, health fill, damage trail and critical text.
