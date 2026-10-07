# Greatsword V2 — enlarged art study

Deterministic presentation inspection, separate from gameplay evidence. Native Godot4.7.2 Compatibility passes1713 checks/0 failures in each facing. Each213-frame timeline/GIF includes accepted gait and four moves at3× normal world scale, with current pose weights and2.24s phase budgets.

[Right GIF](motion.gif), [left GIF](left/motion.gif), [right checks](checks.json), [left checks](left/checks.json), [real Player and UI](../king_greatsword_v2_gameplay_2026_10_07/README.md).

Checks verify canonical30×140 steel, native unobscured head, both glove/body/head paths,7-texel hilt spacing, padded bodies, exact queued copies, opposed120° sweeps,360° spin, takeoff/contact-ground timing, blade tip at sole95, forward cleave angle and uncropped rendered steel/FX. Four landing frames finish across recovery. All38 runtime PNG/TRES outputs reproduce; hashes are retained with generation sources.

tools/review_king_front_combo.gd supports -- --capture [--left]; -- --validate runs456 static art/layout checks. The public launch_king_heavy_burst_review.ps1 shortcut now opens actual training. Historical207-frame proofs remain in the earlier two-hand folder.

[Current rules and unfinished vertical art](../../../../docs/design/king-greatsword-front-combo.md).
