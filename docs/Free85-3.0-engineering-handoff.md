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

## Phase 17.4 — 3.0.0-dev.4

Matrix A, B, R, and the private work register now live in a versioned workspace
and accept up to three rows by six columns in both real and imaginary planes.
The editor grows columns through six. Rectangular addition, subtraction,
multiplication, row operations, augmentation, RREF, and ENTER USE R process
the complete active dimensions. Square-only determinant, inverse, identity,
solve, LU, and eigensystem operations remain bounded to 3x3. A transpose whose
result would require more than three rows reports DIMENSION ERROR without
changing R.

Reset migrates persistent schema 13/object-store schema 1 to schema 14/store
schema 2. It first proves that the existing heap ends below the new workspace,
then copies all four legacy 3x3 real and imaginary registers, validates the
descriptor, and publishes the new schemas last. If capacity is insufficient,
the old schemas, heap, and matrices remain byte-for-byte intact; matrix entry
reports MATRIX WORKSPACE FULL so objects can be removed before retrying reset.
Schema 12 follows its existing migration before the same workspace step.

Exact migration, rollback, editor, 3x6 row/RREF, augmentation, rectangular
multiplication, complex-plane chaining, and transpose-boundary coverage is in
`test/free85/object-store.test.js` and
`test/free85/phase17-matrix-3x6.test.js`. The reviewed editor fixture is
`test/free85/goldens/graphs/phase17-matrix-3x6-editor.lcd`.

## Phase 17.5 — 3.0.0

This package removes the development suffix without adding another calculator
surface. It freezes persistent RAM schema 14, object-store schema 2, graph
database version 3, and the four Phase 17 capabilities as the Free85 3.0
release contract. The release gate includes the complete public suite, seeded
rectangular-matrix arithmetic, corrupt and capacity-failed migration rollback,
reviewed LCD fixtures, measured performance, 10,000 key events, a 9,000-frame
soak, two independent ROM and Pages builds, and the optional private oracle
lane. The private oracle remains an optional external check and is not a source
of public fixtures or Free85 bytes.

The exact final ROM and Pages hashes are recorded in
`spec/free85/release.json` and `spec/free85/reproducibility.json`. Editorial
work should consume `spec/free85/v3-book-impact.yaml` only from this frozen
3.0 baseline; the implementation release does not modify book sources.
