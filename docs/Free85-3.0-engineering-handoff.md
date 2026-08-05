# Free85 3.0 engineering handoff

This file records implementation facts for the later, separate book process.
It is not book prose and does not authorize edits to the manual, guidebook,
companion, screenshots, or typeset editions.

## Phase 17.1 — 3.0.0-dev.1

The third zoom page now reads `STO RCL F2 F4 WIN`. `WIN` opens `GRAPH WINDOW`
with four packed-decimal drafts. F1-F4 select XMIN, XMAX, YMIN, and YMAX. A
normal or shifted calculator expression is evaluated by ENTER. F5 SAVE accepts
the complete draft only when XMIN is strictly below XMAX and YMIN is strictly
below YMAX. It then records the previous window and starts one normal redraw.

An expression error remains in the panel with its precise diagnostic. An
unordered or zero-width interval reports DOMAIN ERROR. Neither case changes
the live window. EXIT cancels an active expression; a subsequent EXIT returns
to zoom page three with every uncommitted draft discarded.

The authoritative editorial mapping is
`spec/free85/v3-book-impact.yaml`. The reviewed LCD source is
`test/free85/goldens/graphs/phase17-window-editor.lcd`; regenerate rather than
editing its PNG derivative.

## Phase 17.2 — 3.0.0-dev.2

The fourth drawing-menu page now reads `RCG OVR OFF`. `OVR` validates and
recalls the existing `PIC1` picture object, then arms exactly one graph start.
That start skips the normal framebuffer clear but otherwise draws the selected
grid, axes, and graph samples through the ordinary OR pixel path. The flag is
consumed before plotting, so the following redraw clears normally.

`OFF` cancels an armed underlay. Returning to Home also cancels it. If `PIC1`
does not exist, OVR remains disarmed and displays `NO PICTURE`; it never
creates an empty object. The 1,024 stored bytes are read-only throughout the
recall and overlay workflow. Exact superset, immutability, one-shot,
cancellation, missing-object, and menu-framebuffer tests live in
`test/free85/phase17-overlay.test.js`.
