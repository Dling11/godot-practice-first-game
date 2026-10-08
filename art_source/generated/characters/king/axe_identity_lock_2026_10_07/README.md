# Axe identity-locked source art

Built-in image generation produced `down_source.png` and `up_source.png` on 2026-10-07. Exact final prompts are `down_prompt.txt` and `up_prompt.txt`. The input references were the frozen four-view King tracing board, the accepted side chop body atlas and the canonical Iron Beard axe. Original generated outputs remain in the Codex generated-image directory; selected sources are copied here.

Each source contains five rows and eight poses: chop, rising cut, head push, jump slam and complete turn. Magenta shaft/cyan head marks describe the real hold and orientation; their alpha haze/weapon pixels are removed offline. They are not gameplay effects. The actual steel texture remains unchanged and reskinnable through family data.

Rebuild with Godot `--headless --path . --script res://tools/build_king_axe_identity_lock.gd`, then `--headless --editor --path . --import --quit`. Outputs are sibling `assets/characters/playable/king/axe_identity_lock/{up,down}/` resources and `gameplay/presentation/axe_identity_lock_swing.tscn`. `registration.json` records source keys, density, native heads and actual guide/palm registration. Existing side motion is never written.

Thirteen exposed keys use the same 4/3/3/3 load/contact/release/queue structure as the accepted side. The front slam's source cel4 has an obscured/disconnected wrist after guide removal and is deliberately excluded; the complete compression cel5 supplies the grounded impact. Rear-hidden grips retain explicit occlusion. No arm bridge or per-frame actor scaling is introduced.

The generated rear slam landing turned toward the camera; keys4/5/10 instead use this same sheet's rear chop compression(row0,cel5). The front compression hides its collar, so its source socket is explicitly traced at(52,49) before applying the unchanged lane density. Crown-relative collar detection includes poses with raised arms; leather gloves cannot substitute for the red scarf. `registration.json` identifies the actual source row/key for each assembled pose. Exact ready/queue copies happen afterward, so final resources remain runtime truth for endpoints.

The existing camera FX are reused. Only the new vertical jump origin is registered to the rendered blade through an opt-in scene property. Side/non-landing effects retain the configured(0,-16) origin, original side atlas, scale and origins.

The previous Decision193 source/runtime folders remain historical inputs for the existing camera FX and rollback. This new pass supersedes its rejected body motion and oversized ready head; retaining sources is not owner approval.
