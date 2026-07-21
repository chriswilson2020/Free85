# Free85 graph drawing and persistence

Phase 14.4 completes Cartesian drawing and graph-object persistence on the
Phase 14.3 shared engine. The implementation is original Free85 firmware and
does not use TI object formats or ROM entry points.

## Drawing panel

Press `CUSTOM` on a completed graph. `MORE` cycles four pages; `EXIT` restores
the graph footer without changing the drawing.

| Page | F1 | F2 | F3 | F4 | F5 |
| --- | --- | --- | --- | --- | --- |
| 1 | Line | Vert | Circ | TanLn | Shade |
| 2 | PtOn | PtOff | PtChg | DrawF | DrInv |
| 3 | Pen | ClDrw | StPic | RcPic | StGDB |
| 4 | RcGDB | — | — | — | — |

Cursor tools begin at LCD coordinate `(64,32)`. Move with the arrow keys.
`Line` and `Circ` take two `ENTER` presses; the first fixes the start or
centre, and the second draws. `Vert`, `TanLn`, and point tools draw on one
`ENTER`. Pen mode draws continuously while the cursor moves. `EXIT` or `CLEAR`
leaves a cursor tool. Shade, DrawF, and DrInv render incrementally and accept
cancellation while active.

`ClDrw` redraws the graph from its equations and current window. Drawing uses
integer Bresenham segments and clipped LCD coordinates, so connected output
does not depend on the browser display scale.

## Native objects

`StPic` stores the full 128×64 monochrome framebuffer as a 1,024-byte typed
picture named `PIC1`; `RcPic` restores those bytes exactly. `StGDB` stores a
versioned 215-byte graph database named `GDB1`; `RcGDB` restores and redraws it.
The graph database contains format and mode bytes, the enabled-equation mask,
active slot, four window values, zoom factor, table start and step, and all
three equation buffers.

Re-storing either name replaces its payload rather than allocating duplicate
objects. Both types therefore participate in normal heap capacity accounting,
memory browsing, compaction, and warm-reset persistence.

## Program access

Programs use `DRAW n`, where `n` is one hexadecimal digit. Coordinate-bearing
operations read integer variables `A` through `D`.

| Code | Operation | Variables |
| --- | --- | --- |
| 0 | Line | `A=x0`, `B=y0`, `C=x1`, `D=y1` |
| 1 | Vert | `A=x` |
| 2 | Circ | `A=cx`, `B=cy`, `C=radius` |
| 3 | TanLn | `A=x` |
| 4 / 5 / 6 | PtOn / PtOff / PtChg | `A=x`, `B=y` |
| 7 | Pen segment | `A=x0`, `B=y0`, `C=x1`, `D=y1` |
| 8 / 9 / A | Shade / DrawF / DrInv | active equations and window |
| B | ClDrw | none |
| C / D | StPic / RcPic | none |
| E / F | StGDB / RcGDB | none |

Pixel coordinates are unsigned integers. Invalid, negative, fractional, or
out-of-range program operands report the ordinary program syntax/runtime
failure instead of writing outside the framebuffer.

## Validation contract

`test/free85/graph-phase15.test.js` exercises every menu operation, responsive
cancellation, program access, exact picture payloads, exact graph-database
serialization, recall, and overwrite-without-leak behaviour. Each of the
twelve drawing operations has paired `.lcd` and lossless `.png` fixtures under
`test/free85/goldens/graphs/`. Regenerate only for intentional visual changes
with `npm run update:free85:phase15-goldens`, inspect every PNG, and then commit
both raw and rendered fixtures.
