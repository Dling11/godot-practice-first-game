# King Idle Down Integrated Source v1

- Date: 2026-08-02
- Status: approved for processing; source preserved unchanged
- Tool: built-in ImageGen
- Identity reference: `art_source/generated/characters/playable/king/greatsword_proofs/king_greatsword_turnaround_reference_v1.png`
- Output: `king_idle_down_integrated_source_v1.png`

## Processing

- Chroma extraction: built-in ImageGen workflow helper `remove_chroma_key.py` with border auto-key, soft matte, thresholds 12/220, and despill. The result is preserved at `art_source/cleaned/characters/playable/king/idle_down/king_idle_down_integrated_transparent_v1.png`.
- Runtime normalization: `tools/process_king_idle_down.py` retains the four large connected integrated character/weapon components, uses one shared nearest-neighbor scale, aligns feet to y=58 around x=31.5, emits binary alpha, applies a non-dithered 48-color shared palette, and writes `assets/characters/playable/king/idle/king_idle_down_sheet_64x64.png`.
- Review outputs: `king_idle_down_sheet_4x.png`, `king_idle_down_preview_8x.gif`, and `king_idle_down_metrics.json` under `art_source/review/characters/playable/king/idle_down/`.
- Scope: only `idle_down`; no other direction or action was generated or imported.

## Prompt

```text
Use case: identity-preserve
Asset type: one review-only pixel-art animation source sheet for a Godot top-down action RPG
Input image: use the visible King greatsword turnaround as the exact character, costume, palette, proportions, pixel density, and weapon-design authority.

Create ONE horizontal sprite sheet containing exactly FOUR equal, isolated frames of King in ONLY his front/down three-quarter idle view. These are four subtle phases of the same idle loop: calm breathing and tiny cloth/hair settling, with both boots planted. Keep the full integrated character and his greatsword together in every frame.

Preserve the reference's attractive coarse pixel-art design: young-prime chibi warrior, messy dark hair and headband mark, navy tunic, silver shoulder armor and bracers, dark boots, red cloth accents, and the same broad silver-edged dark greatsword resting over his shoulder. Preserve the sword's broad proportions and visual detail. The guard, short grip, hand, pommel/tassel, and blade must read as one continuous weapon; the hand must visibly hold the grip. Do not add a second detached hilt or floating weapon part.

Layout: one row of exactly four same-size cells, consistent character scale, identical foot baseline, identical center/pivot, generous equal gutters, no overlap, no cropped pixels. Perfectly flat solid #ff00ff chroma-key background. No gradient, shadow, floor, texture, labels, grid lines, text, watermark, extra poses, side views, back view, attack pose, motion trail, slash effect, or UI. Crisp hard-edged pixel art only; no antialiasing, blur, painterly shading, or smooth vector edges.

This is a single direction/action proof. Do not create any other sheet or animation.
```
