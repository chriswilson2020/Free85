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

## Phase 17.3 — 3.0.0-dev.3

DEQ retains its single-equation `dY/dX` behaviour by default. F1 `SYS` on the
setup page enables the coupled layout: graph slot 1 is `dX/dT`, graph slot 2
is `dY/dT`, and expressions may read `T`, `X`, and `Y`. F3 `NEXT` cycles the
directly editable `T0`, `X0`, and `Y0` fields. F2 `METH` retains Euler, Heun,
and RK4; both derivatives are evaluated from the same stage before either
state advances. Convergence tests use the oscillator `X'=Y`, `Y'=-X` and
measure first-, second-, and fourth-order behaviour for the complete state.

MORE switches the persisted system view. `TIME` uses the graph X interval as
the independent interval and plots state X; both state columns remain
available through the table. `PHASE` plots state X horizontally and state Y
vertically. In that view the direct graph window describes state-space bounds,
while the table step is the signed integration step for 128 samples starting
at T0. Phase trace reports the state X/Y pair, not time and state X.

GDEQ payload version 3 is 234 bytes. It adds a bounded system/view flag and a
second packed initial state. Existing 213-byte v1 and 224-byte v2 objects load
without mutation as single-state DEQ; a later save grows them transactionally.
EXIT and ON remain polled inside every integration step. Reviewed fixtures and
method, persistence, migration, cancellation, time-view, and phase-trace tests
are in `test/free85/phase17-deq-system.test.js` and
`test/free85/phase15-deq.test.js`.
