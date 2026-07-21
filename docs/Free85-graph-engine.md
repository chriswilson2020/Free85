# Free85 shared graph engine

Phase 14.3 completes the Cartesian graph-core, format, and zoom parity gaps on
one packed-decimal engine. Plotting, trace, table evaluation, roots, extrema,
derivatives, integrals, and later graph modes enter through the same evaluator
boundary. Cartesian mode is selected today; Phase 14.5 can add adapters without
forking the renderer or numerical tools.

## Controls

On a completed graph, `2ND+MORE` opens graph format. Its first page toggles
axes, coordinate display, labels, grid, and line/dot rendering. `MORE` opens the
second page, which selects simultaneous or sequential sampling and toggles Y1,
Y2, and Y3. The state persists across redraws. `EXIT` applies it and redraws.

`2ND+GRAPH` opens zoom. The pages provide:

- box, factor zoom-in, factor zoom-out, standard, and square;
- decimal, fit, integer, previous-window, and trigonometric presets;
- store window, recall window, factor 2, and factor 4.

Box zoom starts a movable cursor. Press `ENTER` at each corner. `UP` or `DOWN`
from an ordinary completed graph starts the free cursor; the arrow keys move it
and the coordinate footer reports the packed-decimal window coordinate.
`EXIT`, `CLEAR`, or `GRAPH` leaves cursor mode and redraws.

The home evaluator exposes `XMIN`, `XMAX`, `YMIN`, and `YMAX` as readable named
values. Window changes are made by the graph zoom controls; arbitrary assignment
syntax for multi-letter system names is outside the Phase 14.3 parser contract.

## Rendering contract

Line mode joins adjacent valid samples. A domain failure breaks only the
current equation's segment, so discontinuities never acquire an artificial
vertical bridge. Dot mode emits samples without connectors. Simultaneous mode
samples all enabled equations at each X coordinate; sequential mode completes
one enabled equation at a time. Both modes produce the same final framebuffer.

Every redraw remains incremental, so `EXIT` can cancel it and return home while
preserving the equation source. The format and zoom panels stop active drawing
before changing state.

## Validation

`test/free85/graph-phase14.test.js` verifies persistent flags, Y1/Y2/Y3
enablement, exact simultaneous/sequential framebuffer equality, free-cursor
movement, every zoom preset and history operation, factor selection, box-window
arithmetic, ZFit bounds, named window reads, and redraw cancellation.

The pre-existing sine, parabola, reciprocal, and square-root goldens remain
byte-for-byte unchanged. `phase14-dot-format.lcd` and its reviewed PNG cover
dot rendering with axes and grid disabled. The reciprocal test continues to
require a blank sample column at the discontinuity.
