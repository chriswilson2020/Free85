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
All physical, printed shifted, and alpha surfaces either edit/navigate, invoke
a later-phase operation, or show an explicit planned-feature message.

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
