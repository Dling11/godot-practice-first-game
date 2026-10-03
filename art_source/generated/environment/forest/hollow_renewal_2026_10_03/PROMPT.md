# Stage III prop source

Generated 2026-10-03 with the built-in image generator. Source: props_source.png, transparent1536x1024 atlas. Eight independent props, overhead three-quarter pixel-art perspective, upper-left lighting, outlined forms and subdued olive/plum/old-stone palette matching the approved Stage I/II quality baseline.

Top row: twisted blighted ash, living root elm, low carved ritual seal, small memory tablet. Bottom row: horizontal fallen root, compact root mound, violet mushroom/fern cluster, collapsed stone pillar section. No text, actors, backdrop or combat telegraphs. Foliage remains at the top of rooted trunks; obstacles use compact physical bases, not full painted silhouette collision.

tools/build_stage_3_renewal.gd performs documented custom crops, alpha threshold0.7 and nearest-neighbor fit to native caps. normalization.json records resulting sizes. Ground derives the existing Rootbound64px atlas at half resolution and combines it with approved living32px Grove terrain through an offline, jagged mixed atlas. No image generation occurs at runtime.
