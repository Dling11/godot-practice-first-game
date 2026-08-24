# Disciples of The One Above — Visual and Animation Contract

## Status

Accepted high-level character direction and owner-approved Examiner compact-pixel V3 style lock: masculine, tall, long-legged, simplified ivory/gold, and deliberately free of the rejected realistic miniature detail. The Examiner is the priority for the planned Stage VII encounter; the Executioner is documented for later continuity only. The debug-only F7 proof now uses seven four-direction `192x128` action sheets, a 12-pixel movement footprint, fixed-scale/baseline normalization, fresh physical thrust/sweep/charge/slam poses, and controller-owned combat. Original action sound now exists for the proof; portrait, dialogue, portal flow, story outcomes, final mix, and the Executioner remain unimplemented.

`Examiner` and `Executioner` are accepted role titles. Personal names remain open.

## Reference Status

The owner reattached the `1536x1024` ChatGPT-generated two-Disciple concept on 2026-08-24. Its exact unedited bytes are preserved at:

`art_source/references/characters/disciples/the_one_above_disciples_concept_reference.png`

Its original filename, provenance, dimensions, checksum, and modification policy are recorded in the adjacent `reference_metadata.md`. It is a design reference, never a runtime texture. Do not import it under `assets/`, shrink it into a sprite, trace it pixel-for-pixel, or treat tiny illustration details as mandatory at gameplay scale.

The owner approved the compact-pixel V3 style lock preserved under `art_source/review/characters/disciples/examiner/` on 2026-08-24. It retains the deliberately tall, long-legged, masculine direction while replacing the rejected realistic miniature rendering with large pixel clusters, simplified ivory/charcoal/gold materials, a four-tick halo, and a bold readable Split Glaive. Earlier height/static boards and the realistic runtime prototype are archived outside Godot imports. The V3 board locks style and identity; the deterministic runtime processor owns actual scale and baseline.

## Live Scale Evidence — Comparison Only

The live measurements below exist only to make the future preview honest. They are **not** size caps and must not be converted into runtime cell contracts before owner visual approval:

| Actor | Locomotion cell | Measured opaque height across current locomotion frames |
|---|---:|---:|
| King | `48x32` | `26-28 px`, average `26.9 px` |
| Forsaken Thrall | `24x32` | `25-30 px`, average `28.8 px` |
| Bramble Spitter | `48x48` | `16-30 px`, average `25.4 px` |
| Armored Hog | `64x48` | `37-44 px`, average `39.5 px` |
| Crag Bear | `64x48` | `35-44 px`, average `38.7 px` |

These measurements include all nontransparent pixels in the existing locomotion cells. They are comparison evidence, not a command to make every direction occupy the maximum.

### Art-style and scale approval gate

The Examiner's current F7 proof uses `192x128` action cells, a root-relative `-56 px` visual origin, a source-to-runtime scale of `0.42`, a normalized cell baseline of `y=120`, and a 12-pixel movement footprint. These are concrete debug values for owner review, not locked production ceilings. The Executioner still has no numeric runtime contract.

The first generated deliverable was a **preview-only art-style concept**, not a production sprite sheet. It intentionally presented the Examiner as tall and imposing rather than matching King's compact scale. The same rule remains binding for the future Executioner. A large or even huge humanoid presentation is acceptable when it preserves the top-down perspective, readable anatomy, combat space, and environmental fit.

That completed preview gate required:

- the Examiner in the proposed Battle of Gods hard-pixel style;
- the Executioner as a secondary future visual reference, not a production asset;
- King, Armored Hog, and Crag Bear comparison silhouettes or an equivalent explicit same-baseline scale strip;
- both Disciples on one shared ground baseline with no perspective trick that makes them look taller only through placement;
- a close enough inset to judge mask, armor simplification, Split Glaive, fractured halo, and Execution Wheel;
- no animation grid, separated frames, runtime packing, or implementation claims.

Only after the owner approves that art style and relative scale may production define exact opaque height, cell size, foot baseline, navigation footprint, hitbox, portrait crop, and action canvases. Never shrink an approved tall design merely to fit a previously convenient cell.

## Shared Divine-Order Language

Both Disciples serve the same being without wearing identical uniforms. Their shared visual grammar is:

- full face coverage with smooth, unreadable masks;
- pale ivory, white-stone, or mineral armor as a recurring divine material;
- restrained warm-gold geometric inlays rather than ornamental clutter;
- a small repeated geometric mark associated with The One Above;
- a limited number of floating or physically impossible components;
- clean upper-left lighting and hard-pixel binary-alpha edges;
- constructed weapons whose separated pieces or impossible balance imply divine manufacture;
- beautiful, controlled divinity with subtle unease—not demon horns, skull armor, blood, generic red eyes, or explicit evil symbols.

The exact shared emblem remains open until the reference image is inspected. Do not invent and propagate a permanent symbol prematurely. Once approved, the motif may recur subtly on The One Above, divine weapons/materials, selected architecture, portals, later environments, and lore/UI elements so recognition can precede explanation.

The masks remain unexplained. Do not establish identity removal, mind control, punishment, species, or anatomy merely from their face coverage.

## Disciple I — The Examiner

### Identity

The Examiner has a masculine, tall, lean, athletic silhouette. He is calm, controlled, intimidating, and recognizably divine without looking obviously hostile. His presence comes from stillness, precision, and sudden speed rather than bulk.

Preserve these silhouette anchors:

- smooth fully enclosed mask with minimal facial information;
- pale ivory/white-stone armor with restrained gold geometry;
- long elegant cloth or segmented armor pieces that read in four directions;
- minimal visible skin;
- narrow athletic shoulders and controlled stance;
- one long Split Glaive whose construction cannot be mistaken for an ordinary spear.

Do not reduce the identity to a generic white knight. The mask construction, long controlled lines, impossible weapon, and shared divine geometry must survive simplification.

His spectacle ceiling is controlled divine technique. Axiom Divide expresses exact multi-lane measurement; Divine Descent expresses a severe but survivable arena test through authored launch/fall motion and reliable pylon cover. Neither may use the Executioner's future destruction language or The One Above's reality-scale rule breaking merely to look stronger.

### Palette direction

- deep navy/plum outline and deepest shadow rather than pure black everywhere;
- pale warm ivory as the principal armor plane;
- cool white-stone secondary planes;
- muted gray-violet cloth/shadow separation where needed;
- restrained warm gold for geometry and authority;
- tiny pale blue-white or violet-white energy accents only when the weapon separates;
- no dominant red, blood palette, demon glow, or noisy rainbow divinity.

Final colors must be sampled beside King and the Stage VII terrain so the ivory silhouette remains readable without appearing like a high-resolution illustration pasted into the scene.

## Examiner Weapon — Divine Split Glaive

The Split Glaive is a signature divine weapon, not an ordinary spear with decorative particles.

At rest it reads as one elegant long glaive. During authored attacks, a small number of blade pieces may separate along controlled geometric seams, remain aligned by divine energy, perform an impossible sweep or short ranged cut, and reconnect. The first implementation remains deliberately bounded:

1. one precise thrust-to-separately-warned-sweep basic sequence;
2. one accurately telegraphed Judgment Charge gap close;
3. one bounded parry/escape answer to spam;
4. one radial Ground Judgment slam;
5. one recognizable split-blade divine technique;
6. no large catalogue of weapon modes.

The shaft, hands, core blade, and body pose should be authored together where grip and silhouette matter. Separated blade pieces and energy cuts use synchronized secondary `AnimatedSprite2D` layers so they can move impossibly without disconnecting the Examiner's hands or changing weapon length accidentally. VFX may brighten seams and contact but cannot substitute for the physical thrust, sweep, separation, recoil, or reconnection poses.

## Examiner Animation Contract

The personality rhythm is:

`near stillness -> sudden explosive movement -> exact contact -> immediate control`

Every family uses `down/left/right/up` rows, exact-grid runtime sheets, one scale per direction row, stable feet, and named `SpriteFrames` on `AnimatedSprite2D`.

| Family | First-pass frame budget | Runtime cell | Required read |
|---|---:|---:|---|
| `idle_<direction>` | 2 debug / 3-4 target | `192x128` debug | Almost motionless observation; at most restrained cloth, breathing, or marking change |
| `walk_<direction>` | 4 debug | `192x128` debug | Contact/pass/opposite-contact/opposite-pass with deliberate stride |
| `combat_stance_<direction>` | Folded into transitions in debug | `192x128` debug | Quiet grip and weight set without bouncing |
| `attack_combo_<direction>` | 6 thrust + 6 sweep source poses | `192x128` debug | Preparation, precise thrust, separate sweep anticipation, body commitment, follow-through, reset |
| `judgment_charge_<direction>` | 6 source poses | `192x128` debug | Target point, compression, launch, directional travel silhouette, hard brake, controlled stance |
| `ground_judgment_<direction>` | 6 source poses | `192x128` debug | High overhead preparation, whole-body descent, planted contact, heavy recovery |
| `parry_<direction>` | 5 debug | `192x128` debug | Weapon intercept, body angle, accepted contact, deflection/escape, reset |
| `split_glaive_<direction>` | Composed sweep/dash debug | `192x128` body plus separate lane presentation | Guided physical cuts and final dash; lane energy never substitutes for body motion |
| `hurt_<direction>` | 3 debug | `192x128` debug | Minimal but unmistakable accepted impact; no immunity illusion |
| `recognition_withdraw_<direction>` | 3 debug / 5-6 target | `192x128` debug | Ends the Stage VII test without a death animation |

The Stage VII Examiner does not need a death family. Unexpected player dominance transitions into recognition, disengagement, or withdrawal. A true death animation remains deferred until the story explicitly permits this character to die.

Hit flash, hit pause, sparks, audio, and stagger resistance remain separate presentation/gameplay systems. High resistance may reduce reaction frequency or duration, but accepted hits must still communicate contact.

Decision 134 requires a no-VFX body test before presentation approval. Judgment Charge's red lane must match its captured endpoint; Ground Judgment's ring must match its 72-pixel radial hitbox. The current proof intentionally applies no zone slow. `DivineThreatAura` is reusable presentation language and must never be mistaken for collision.

## Disciple II — The Executioner

### Future identity

The Executioner has a feminine or subtly feminine armored silhouette, taller and broader than the Examiner. She is heavily armored, physically imposing, frightening through judgment and force, but still divine rather than demonic.

Preserve these anchors for later:

- fully covered face and mask related to the Examiner's construction;
- white/stone armor mixed with darker divine material;
- restrained purple or void-like accents compatible with the active palette;
- readable torn or flowing cloth only where it survives pixel simplification;
- four to six large broken halo fragments floating behind/around the head or upper torso;
- a broad, stable stance that contrasts with the Examiner's narrow stillness;
- one unmistakable broken circular Execution Wheel weapon.

Do not create dozens of tiny halo shards. The halo should read as a fractured divine circle from gameplay distance, with a small number of large separated pieces and stable spacing.

### Execution Wheel

The Execution Wheel is a large broken circular blade attached to a handle, with missing or divinely suspended segments. It is not a sword, axe, or hammer disguised by VFX. Its future motion language may support heavy wheel swings, ground impacts, rotating danger, a short throw/return, and an execution strike, but none of those actions is implemented or fully contracted yet.

Her combat identity is `power -> judgment -> punishment -> overwhelming force`. Every future attack must move shoulders, torso, planted legs, weapon mass, and recovery before shockwaves or debris are added.

## Reusable Ownership

Planned canonical ownership uses identity rather than introduction stage:

- `assets/characters/disciples/examiner/`
- `assets/characters/disciples/executioner/`
- `assets/characters/disciples/shared/`
- `assets/characters/disciples/portraits/`
- `assets/weapons/divine_order/split_glaive/`
- `assets/weapons/divine_order/execution_wheel/`
- `assets/vfx/divine_order/`
- `assets/audio/sfx/characters/disciples/examiner/`
- `assets/audio/sfx/characters/disciples/executioner/`
- `data/dialogue/disciples/`
- `art_source/references/characters/disciples/`
- `art_source/generated/characters/disciples/<identity>/`
- `art_source/review/characters/disciples/<identity>/`

Stage VII data may reference the Examiner scene, dialogue, and portal choice, but no reusable asset path may contain `stage_7`. Do not create empty runtime directories for the Executioner before production begins.

## Production Sequence

1. **Complete:** preserve the original concept reference outside `assets/` with provenance and checksum.
2. **Complete:** generate one preview-only art-style/same-baseline scale board showing both Disciples as deliberately tall original top-down pixel interpretations.
3. **Partial approval:** the owner approved the tall, long-legged height direction. The F7 proof now supplies exact debug dimensions for feel-testing; production values remain open.
4. **Complete:** owner approved the compact-pixel V3 style lock after rejecting the realistic miniature-like runtime pass.
5. **Complete for debug:** normalized six action-owned boards to `192x128` with one `0.42` scale, lower-body anchoring, `y=120` foot baseline, edge protection, and four true direction rows; captured idle, thrust, sweep, dash, and Axiom beside King in the Court.
6. **Current:** owner feel-test locomotion, thrust-to-sweep, Zero Interval, Refutation, and Axiom motion. Rejected malformed Axiom boards are not runtime sources; the proof composes the clean sweep/dash poses while lanes remain separate VFX.
7. Generate the portrait and dedicated audio only after the visual feel gate.
8. **Complete for debug:** implemented and verified the Examiner independently of the Executioner; production Stage VII integration remains separate.
9. Leave the Executioner as documentation until her own encounter and animation contract are approved.

## Rejection Conditions

- Pure front-view or side-view staging instead of top-down three-quarter cardinal poses.
- Examiner or Executioner shrunk toward King's compact body merely to reuse his cell size or simplify packing.
- Examiner reading as Hog/Bear mass, a generic knight, or an obvious demon.
- Executioner reading as a giant monster rather than an armored humanoid.
- Face exposed, generic red eyes, horns, skulls, blood, or explicit evil emblems.
- Split Glaive reduced to a normal spear with particles.
- Execution Wheel reduced to an ordinary axe/hammer silhouette.
- Static body plus VFX-only attack illusion.
- Per-frame scaling, shifting feet, changing armor proportions, changing weapon length, or disconnected hands.
- More tiny floating fragments than remain readable at 960x540.
- Any reusable folder or stable ID named after Stage VII.
