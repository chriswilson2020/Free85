# Free85 Firmware

Free85 is an original open-source firmware for the repository's
TI-85-compatible machine layer. It is not TI firmware and does not promise
compatibility with TI programs, files, ROM calls, or internal data structures.

The Phase 1 diagnostic firmware boots, initializes interrupts and the LCD,
shows an original Free85 splash, and then reports every physical key press.
The product and keypad/feature contracts live under `spec/free85/`.

## Phase 2 UI kernel

The current ROM enters a standalone Free85 home screen after the splash. It
provides an interrupt-fed key event queue, a 48-character multi-row editor,
cursor movement and blinking, delete, clear, insert/overwrite mode, one-shot
2ND, one-shot and locked ALPHA, two soft-menu pages, and dismissible dialogs.
All physical, printed shifted, and alpha surfaces now edit, navigate, or invoke
a completed operation; Phase 11 removes the development placeholders.

## Phase 3 numeric core

Free85 numbers use an original nine-byte representation: a sign byte, signed
decimal exponent, and fourteen packed BCD significant digits. Results are
rounded half-up to fourteen digits. The normal exponent range is -128 through
127; a result outside that range reports a recoverable numeric-range error
rather than wrapping or exposing internal rounding digits. Underflow is
reported as a range error rather than silently flushed to zero. Domain and
divide-by-zero errors are also recoverable.

The numeric layer is independent of expression syntax and is shared by the
Phase 4 evaluator. Integer powers currently accept exponents from -9 through
9; general real powers belong with the Phase 5 logarithm and exponential work.

## Phase 4 expression engine

The home screen now uses a real tokenizer and bounded recursive-descent parser.
It supports nested parentheses, unary signs, right-associative power, implicit
multiplication, scientific notation, and the normal arithmetic precedence
levels. `SQRT(...)` accepts a parsed subexpression rather than raw text.

The 26 single-letter variables store the same packed-BCD objects as calculator
results. The physical store key writes postfix assignments such as `5->A`.
`ANS` reads the previous successful result. Four expression-history slots are
navigated with UP and DOWN; restored entries remain editable and can be
reevaluated. Token capacity is 48 and evaluation-stack depth is eight, matching
the bounded 48-character editor. Malformed or excessively nested expressions
return a syntax dialog without modifying the editor.

## Phase 5 scientific functions

The expression engine now evaluates `EXP`, `LN`, `LOG`, `TEN` (10^x), circular
and inverse trigonometric functions, hyperbolic and inverse-hyperbolic
functions, `ABS`, `FACT`, `NPR`, and `NCR`. `PI`, `E`, `LIGHT`, `GRAV`,
`PLANCK`, `BOLTZ`, and `AVOG` are built-in packed-decimal constants.
`RAD(x)` converts degrees to radians and `DEG(x)` converts radians to degrees.
The faceplate LOG, LN, SIN, COS, and TAN keys insert callable
expressions; their printed inverse, exponential, 10^x, and pi second-functions
do the same.

`2ND` + `MORE` toggles the persistent calculation mode between radians and
degrees. The status line reports `RAD` or `DEG`; circular inputs and inverse
outputs honor that mode. Explicit `RAD`/`DEG` conversions do not depend on it.

All routines operate through the fourteen-digit decimal core. Exponential and
trigonometric functions use bounded range reduction and Taylor series; `LN`
uses repeated square-root reduction and an atanh series. Independent test
vectors use a relative tolerance of 1e-10 (with an absolute scale floor of 1)
over the documented test range. Factorial accepts integers 0–69. `NPR` and
`NCR` require integer arguments satisfying 0 <= r <= n. Invalid domains and
incorrect function arity produce recoverable dialogs.

Bidirectional conversion functions cover every required category. Their names
are `CMIN`/`INCM` (length), `SQMFT`/`SQFTM` (area), `LGAL`/`GALL` (volume),
`KGLB`/`LBKG` (mass), `CTOF`/`FTOC` (temperature), `MINS`/`SMIN` (time),
`KMHMPH`/`MPHKMH` (speed), `BARPSI`/`PSIBAR` (pressure), `JCAL`/`CALJ`
(energy), `WHP`/`HPW` (power), and `RAD`/`DEG` (angle). Conversion factors
are packed-BCD source tables adjacent to the routines and are independently
tested in both affine and multiplicative cases.

## Phase 6 graphing and numerical tools

`GRAPH` stores the home expression in the active equation slot and opens a
Cartesian graph. Three 48-character equation slots are available; from the
graph use `2ND+1`, `2ND+2`, or `2ND+3` to select a slot and return to the home
editor. Saving an empty slot disables it. All enabled equations are evaluated
through the Phase 4 parser, so graphing and home calculations share syntax,
variables, angle mode, decimal arithmetic, and domain behavior.

The default window is -10 through 10 on both axes. `+` and `-` zoom in and out,
`2ND++` restores the standard window, `2ND+-` selects a square-aspect preset,
`.` toggles the grid, and `GRAPH` redraws. Plotting advances one column at a
time and `EXIT` or `CLEAR` cancels an incomplete redraw. LEFT and RIGHT move
the trace position and show packed-decimal X/Y values. `MORE` opens a scrolling
table for all enabled equations; UP/DOWN move its start by five steps, `+`/`-`
change the step by a factor of two, and GRAPH/EXIT returns to the plot.

On the graph screen F1–F5 run zero, minimum, maximum, derivative-at-trace, and
definite-integral operations. `2ND+F1` finds an intersection of Y1 and Y2.
`2ND+GRAPH` runs the general solver directly from the home editor, using the
trace value (zero initially) as its estimate and the graph window as optional
bounds. Root finding combines an estimate test, bounded interval scan,
bisection, and a safeguarded secant refinement; it displays the residual and
rejects discontinuity sign changes that do not meet tolerance. Extrema use 22
bounded ternary refinements, derivatives use a central difference with h=1e-5,
and integration uses the composite Simpson rule with 64 panels. `2ND+CLEAR`
cycles tolerance through 1e-6, 1e-8, and 1e-10. Numerical failure is a
recoverable dialog.

Phase 6 code occupies bank 1 and calls the fixed packed-BCD/parser kernel in
bank 0. This keeps graph-domain failures local to individual samples and leaves
later ROM banks available for subsequent application phases.

## Phase 7 collection and complex applications

`2ND+9`, `2ND+-`, `2ND+7`, and `2ND+8` open the complex, list, matrix, and
vector editors. The second home soft-menu page also opens the list, matrix, and
vector applications. `ALPHA` switches between operands A and B, arrow keys
select elements, and decimal values are committed with `ENTER`. `+` and `-`
resize bounded collections; `X-VAR` chooses the matrix row or column dimension.

Complex values store rectangular real/imaginary components and provide polar
conversion, component access, magnitude, argument, conjugate, arithmetic,
squaring, and principal square roots, including negative-real roots. Lists hold
at most eight packed-decimal elements and provide element-wise editing, sum,
product, minimum, maximum, mean, median, population standard deviation, sort,
cumulative sum, and sequence generation.

Matrices are limited to 3x3 and support rectangular dimensions, indexing,
addition, subtraction, scalar and matrix multiplication, transpose,
determinant, identity, inverse with row pivoting, reduced row-echelon form, and
linear-system solving using the first column of matrix B as the right-hand
side. Vectors contain two or three components and provide addition,
subtraction, scalar multiplication, magnitude, normalisation, dot product,
3D cross product, and angle. Dimension, singular-matrix, and zero-vector
failures are recoverable dialogs. Phase 7 occupies ROM bank 2; its total RAM
reservation, including the framebuffer and stack, is 4,608 bytes, leaving
28,160 bytes free.

## Phase 8 statistics and specialist solvers

`STAT` opens paired editable X/Y data columns backed by the eight-element list
storage; `ALPHA` changes columns and `+`/`-` resize both columns together.
One-variable summaries provide mean, median, minimum, maximum, Tukey-hinge
quartiles, sample variance and standard deviation (denominator `n-1`), and
population variance and standard deviation (denominator `n`). Two-variable
statistics provide both means, least-squares linear regression
`y = intercept + slope*x`, and Pearson correlation. Scatter, four-bin
histogram, and box plots are rendered directly into the exact LCD framebuffer.

`2ND+STAT` opens an augmented-matrix editor for simultaneous linear equations.
It solves 2x2, 3x3, and 4x4 systems with pivoted Gauss-Jordan elimination and
reports unique, inconsistent, and underdetermined systems separately.
`2ND+PRGM` opens the polynomial editor. Degrees 2 through 4 are supported;
simultaneous complex Durand-Kerner iteration returns real/imaginary root pairs,
including non-real quadratic and quartic roots. Zero leading coefficients and
invalid statistical samples produce recoverable notices.

Phase 8 occupies ROM bank 3. Its full RAM reservation, including framebuffer
and stack, is 6,144 bytes, leaving 26,624 bytes free. Statistical columns remain
bounded at eight values, simultaneous systems at 4x4, and polynomials at degree
four.

## Phase 9 strings, catalog, and custom menu

`2ND+6` opens a native string workspace with independent A and B values plus a
result value. Strings are length-prefixed, NUL-terminated for display, and
bounded to 31 characters. `ALPHA` enters letters, `X-VAR` changes the active
value, `2ND+0` opens the character palette, and the arrow keys select the
one-based substring start and length. The two soft-key pages provide
concatenation, length, substring, character extraction, lexical comparison,
number-to-string, string-to-number, copy, swap, and clear operations. Numeric
conversions use the same packed-decimal objects as the home evaluator.

`2ND+CUSTOM` opens an alphabetically ordered catalog of 56 callable functions,
constants, and application commands. `ENTER` invokes the selected entry; F1-F5
assign it to the corresponding custom slot. `CUSTOM` opens those five slots,
and `MORE` returns to the catalog. Assignments live in versioned RAM and survive
ordinary machine resets. `2ND+0` also opens a 26-character punctuation palette
from home and inserts the selected character into the calling editor.

Phase 9 occupies ROM bank 4. Its full RAM reservation, including framebuffer
and stack, is 6,656 bytes, leaving 26,112 bytes free. Exact framebuffer goldens
cover all four new screens, while behavioral tests cover every catalog entry,
all string operations and conversions, character insertion, and custom-slot
persistence.

## Phase 10 programming environment

`PRGM` opens a persistent four-slot program manager. Each program has a
seven-character name and eight source lines, with the same 48-character bound
as the home editor. F1-F5 create, edit, run, rename, and delete the selected
program. In the source editor, `ALPHA` enters commands and identifiers,
`2ND+0` inserts a space, `ENTER` or F3 saves and advances, and the remaining
soft keys save, run, delete a line, or return to the list. `2ND+PRGM` remains
the polynomial solver.

The compact Free85 language is line based and uses uppercase commands:

```text
expression or value->V
DISP expression
INPUT V
IF expression / ELSE / END
WHILE expression / END
FOR V,start,end / END
CALL 1..4
RETURN
STOP
GRAPH expression
LSET index,expression
LGET index,V
MSET row,column,expression
MGET row,column,V
```

Expressions and assignments are evaluated by the same packed-decimal parser,
variables, functions, constants, and angle mode as the home screen. Conditions
treat zero as false and all other numeric values as true. `FOR` is an ascending
integer loop with one-digit inclusive bounds; list indices are 1-8 and matrix
rows/columns are 1-3. `GRAPH` stores and opens the expression through the normal
graph engine.

Execution advances by one source statement per firmware tick. Consequently an
infinite `WHILE` remains responsive: `ON`, `EXIT`, or `CLEAR` stops it without
deleting source. Control nesting is bounded to eight frames and program calls
to four frames. Syntax, stack, input, and missing-program failures preserve the
one-based source line in RAM and display it on the run screen.

Phase 10 occupies ROM bank 5. Its complete RAM reservation, including stack and
framebuffer, is 8,704 bytes, leaving 24,064 bytes free. Tests cover lifecycle
and reset persistence, expressions, all control forms, input, calls,
list/matrix access, graph launch, runaway interruption, exact error lines, and
reviewed LCD framebuffers.

## Phase 11 complete parity

Phase 11 completes every registered physical, shifted, alpha, menu, and
application surface. The first home soft-key page opens math, graph, variables,
memory, and system screens; the second opens lists, matrices, vectors,
statistics, and programs. The shifted menu keys expose callable math,
constants, unit conversions, comparisons, number-base display, variable
browsing, memory management, and native link diagnostics.

`2ND+F1` through `2ND+F5` store the current evaluated entry in five independent
packed-decimal memories, or recall a slot when the editor is empty. These slots,
variables, programs, custom-menu assignments, and settings survive ordinary
machine resets. The memory screen can clear variables or programs, restore
settings, or perform an intentional full reset.

The system screen switches radians/degrees and automatic/scientific display,
adjusts hardware contrast, and links to memory management. `2ND+ALPHA` toggles
lowercase alpha, `2ND+ENTER` restores the previous entry, and `2ND+ON` disables
the LCD and timer until a subsequent ON interrupt wakes the calculator.
Comparison operators produce numeric `1` or `0` and are available to both the
home evaluator and program conditions.

Phase 11 occupies ROM bank 6. Its full RAM reservation, including stack and
framebuffer, is 8,960 bytes, leaving 23,808 bytes free. The parity suite tests
every new surface, persistence, settings and reset behavior, all six comparison
operators, base conversion, link-line I/O, and the off/wake path. The generated
coverage report requires every feature to be complete and test-backed.

## Phase 12 optimisation and release

Free85 1.0 avoids redundant bank-port writes, packs Phase 11 state without
alignment gaps, skips transparent-space glyph work, caches parsed graph tokens,
and precomputes the graph window's Y scale once per redraw. Transcendental
series stop as soon as another term can no longer change the fourteen-digit
packed result. These changes preserve exact graph framebuffers and numerical
vectors while reducing deterministic emulated work.

Against the checked-in Phase 11 baseline, EXP is over 43% faster, LN is over
34% faster, a linear graph is 47.52% faster, and a quadratic graph is 28.33%
faster. Ordinary key input remains
visible within one 50 Hz display frame. Exact results and current limits live
in `spec/free85/performance.json`.

Release RAM, including stack and framebuffer, is 8,816 bytes, leaving 23,952
bytes free. Versioned state is now schema 12. `FREE85.ROM`, source, build
instructions, licences/notices, complete feature coverage, performance report,
known limitations, and browser-default integration are recorded by
`spec/free85/release.json`. Release validation includes the full public suite,
exact framebuffer goldens, a 10,000-key-event stress run, the 180-second soak,
and the static GitHub Pages build.

## Phase 14.1 typed object store

Schema 13 uses bank 7 for a 64-entry typed directory and compacting payload
heap. Eleven public object kinds cover real and complex numbers, lists,
matrices, vectors, strings, equations, programs, constants, graph databases,
and pictures. Existing A-Z packed values are registered as external, reserved
real objects, so migration does not relocate or reinterpret them.

The public jump table supports validation, create, type-and-name lookup,
deletion, grow/shrink, and compaction. Moving a payload updates every affected
directory address. Warm reset preserves the directory and heap; schema-12
migration writes schema 13 only after rebuilding adapters, making interruption
retryable. The memory browser shows name, type, and size, selects with arrows,
and deletes with `DEL`. The complete layout and API are documented in
`docs/Free85-object-store.md`.

## Phase 14.3 shared graph engine

Phase 14.3 routes Cartesian plot, trace, table, and numerical analysis through
a mode-neutral evaluator for later polar and parametric adapters. Persistent
format bits control axes, coordinates, labels, grid, line/dot drawing,
simultaneous/sequential sampling, and the three named equation slots.

`2ND+MORE` opens graph format and `2ND+GRAPH` opens zoom. Zoom includes box,
factor in/out, standard, square, decimal, fit, integer, previous, trig, and
stored-window recall operations. `UP` or `DOWN` on a completed graph starts a
free cursor. `XMIN`, `XMAX`, `YMIN`, and `YMAX` are readable named values.
Redraws remain incremental and cancellable, and the graph suite checks exact
legacy framebuffers, discontinuity isolation, render-mode equivalence, window
arithmetic, and a reviewed dot-mode golden.

## Phase 14.4 graph drawing and persistence

`CUSTOM` on the graph opens a four-page drawing panel with line, vertical,
circle, tangent, point on/off/change, shade, function, inverse, freehand pen,
and clear operations. Cursor tools use pixel coordinates; longer operations
run incrementally and remain cancellable. Fixed-bank trampolines let bank 1
create and find graph objects in bank 7 and let programs in bank 5 invoke the
same drawing ABI.

`StPic`/`RcPic` round-trip the complete 1,024-byte LCD as the typed `PIC1`
object. `StGDB`/`RcGDB` round-trip a versioned 215-byte `GDB1` payload containing
the graph configuration and equation slots. See
`docs/Free85-graph-drawing-persistence.md` for menus, program codes, layout,
and validation evidence.

## Clean-room rules

- Do not copy or translate code, fonts, tables, layouts, or other data from a
  TI ROM or disassembly.
- Do not place a TI ROM in this directory or in generated artifacts.
- Public Free85 tests must run without a TI ROM.
- Use the physical faceplate labels, public user-facing behavior, private
  black-box observations, and independent mathematical results as validation
  sources.

## Build output

`npm run build:free85` will assemble eight independent 16 KiB banks, reject an
oversize bank, pad unused bytes deterministically, and write the exact 128 KiB
image to `ROM/FREE85.ROM`. Map, symbol, and bank-usage reports will be emitted
under `firmware/free85/generated/`.

## Building

Install `sjasmplus` v1.21.1 or newer, then run:

```sh
npm run build:free85
npm run test:free85
```

If the assembler is not on `PATH`, provide its absolute location without
copying it into the repository:

```sh
SJASMPLUS=/path/to/sjasmplus npm run build:free85
```

The checked-in `ROM/FREE85.ROM` lets the normal Free85 tests run without an
assembler. Use `npm run run:free85 -- GRAPH` for a headless framebuffer preview
or `npm run test:free85:soak` for the three-minute emulated stability check.
`npm run release:free85` rebuilds and validates the complete release bundle.
