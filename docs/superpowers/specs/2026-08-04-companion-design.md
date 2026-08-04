# Explorations with Free85 — Companion Book Design

Date: 2026-08-04
Status: approved (Chris, 2026-08-03: "keep the same structure and then
completely rewrite it especially for Free85")

## Goal

An original companion workbook, *Explorations with Free85*, in the tradition
of early-1990s graphing-calculator exploration books: course-organized
chapters of guided mathematical explorations that teach with the machine in
hand. It shares only the genre's structural conventions with its
inspiration (an eight-chapter course progression; numbered sections of
explorations; prose interleaved with keystroke walkthroughs, screen
captures, and reader exercises). Every example, function, data set,
exercise, and sentence is written fresh for Free85 2.10 and verified on the
emulator.

## Originality rules (hard)

- Chapter writers and reviewers never see the inspiration text. They work
  from this spec's topic outline and the Free85 documentation only.
- No worked example, data set, or exercise may be taken from any external
  book. Writers invent their own functions and data, chosen to suit
  Free85's numeric ranges and limits.
- The book's front matter states it is an original work for Free85 and is
  not affiliated with or derived from any calculator manufacturer's or
  publisher's materials.
- The coordinator performs a final independence check comparing the
  finished book against the inspiration's sampled examples.

## The book

Title: **Explorations with Free85**. Audience: a student or teacher who has
read the Getting Started Manual and wants to use Free85 in real course
work; the Guidebook remains the reference companion (cross-referenced by
chapter, never duplicated).

Eight chapters, each 10-16 typeset A5 pages, in course order:

1. **Explorations in precalculus** — function graphing and windows; families
   of curves three at a time (Free85 keeps three function slots); zeros and
   intersections from the graph screen; symmetry and transformations;
   exponential and logarithmic growth (compound interest teaser);
   trigonometric graphs and angle modes; inverse functions via the
   parametric pair.
2. **Explorations in business mathematics** — linear systems with `SIMULT`
   (up to four unknowns); two-variable linear programming on the graph
   screen (corner points by intersection); small tableaux with the matrix
   row operations (`REF`, `SWAP`, `RADD`, `RMUL`); the mathematics of
   finance in the solver workspace (compound interest, annuities, loan
   payments as stored equations); Markov chains with 3x3 transition
   matrices and repeated multiplication.
3. **Explorations in probability and statistics** — descriptive statistics
   on eight-sample columns (Free85's list length; small-data statistics as
   a theme, not an apology); random numbers with `RAND` and `RANDI`;
   simulation programs within the four-slot program environment;
   regression families (`LIN` through `P4`) with designed exact-fit and
   noisy data sets; forecasting with `FCX`/`FCY`; the four statistical
   plots.
4. **Explorations in calculus I** — limits by table and zoom; the
   derivative as a limit of difference quotients (typed by hand, then
   `NDER`); slope at a point from the graph screen; extrema with
   `FMIN`/`FMAX` and the analysis keys; the definite integral as area and
   as average value (`FNINT`, graph [F5]); Riemann-sum programs (left,
   right, midpoint) against `FNINT`; areas between curves.
5. **Explorations in calculus II** — zeros of functions (solver workspace
   and `POLY` to degree four); conic sections by parametric pair; polar
   curves (roses, cardioids, spirals within the fixed one-revolution
   sweep); parametric motion; functions defined by integrals (accumulator
   via `EVAL`/`FNINT`); indeterminate forms probed by table; improper
   integrals probed numerically; polynomial approximation of functions
   (Taylor polynomials plotted against their targets, integer powers
   within the `^` range).
6. **Explorations in linear algebra** — the 3x3 matrix world; systems by
   `RREF` and by `SIMULT`; the row operations as algebra you can watch;
   norms and the condition number (well- and ill-conditioned 3x3
   examples); orthogonality with `DOT`, `NORM`, `UNITV`; eigenvalues and
   eigenvectors with `EVAL`/`EVEC` (2x2 and 3x3, including a rotation
   matrix's complex pair); `LU` as bookkeeping of elimination.
7. **Explorations in differential equations** — slope thinking with the
   DifEq mode (Euler built in; the window sets the step); initial
   conditions (seeding `Y`, resetting via the `GDEQ` object); step-size
   experiments by narrowing the window; an Euler program stepping a
   solution into a list; improved Euler as a program refinement;
   qualitative behaviour (equilibria, growth/decay families). Honest
   scope: Free85 integrates one first-order equation; systems and phase
   planes are named as beyond the machine and left to exercises on paper.
8. **Explorations in engineering mathematics** — the pendulum and elliptic
   integrals (`FNINT` with parameters in the solver); series summed by
   program against closed forms; a shooting-method boundary-value
   exploration (solver + DifEq together); vectors in the round
   (`DOT`, `CRS`, coordinate conversions `RECTV`/`CYLV`/`SPHEREV`,
   work and moment examples).

Closing: a short afterword, "After the last exploration", set as its own
section with opener furniture and a contents entry. It began as a coda at
the foot of chapter 8 and was promoted during design QA, which found that a
reader meeting an unnumbered heading in chapter 8's running head takes it
for a fifth section rather than the end of the book.

Front matter: title page, original-work notice, how-to-read key (inherits
the Guidebook's conventions by reference), contents. No appendix
duplicating the calculator introduction: the Manual and Guidebook are the
companion volumes and are cross-referenced instead.

## Exploration format (each section)

- A short motivating paragraph (the mathematics, not the machine).
- A worked exploration: numbered keystroke walkthroughs in the book's
  bracket notation, quoted screen results, and LCD captures at the payoff
  moments.
- Free85 boundary notes where the machine shapes the mathematics (three
  slots, eight-sample lists, 3x3 matrices, degree-4 polynomials, integer
  `^` exponents, the typeable program subset), written in the Guidebook's
  design-boundary register: plain statements, never apologies.
- A "Try it" block closing the section: 2-4 reader exercises, answerable
  on the machine, with answers NOT printed (kept for a possible answer
  key later).

## Firmware truth constraints (writers must design within these)

Three graph slots; one parametric pair; polar sweeps one revolution in 128
samples; lists cap at 8, matrices 3x3, vectors 3 components; `POLY` degree
2-4; `SIMULT` 2-4; `^` takes whole exponents -9..9 (use multiplication,
`ROOT(`, or logarithms otherwise); programs are 4 slots x 8 lines x 48
chars with `=` and `<` untypeable (use `REPEAT` countdowns, `IS>`, `FOR`,
`WHILE` with arithmetic tests); the solver workspace holds one equation
with selectable unknown, guess, and bounds; DifEq is first-order Euler
with the initial y seeded at mode creation. Every keystroke and quoted
value in the book must be verified on the emulator before it is written.

## House style

Identical to the Guidebook (no em dashes; British spelling; sentence-case
headings; keys in brackets; screen text in code spans; quoted verified
results; per-chapter assurance line; cross-refs "Chapter N (Title)" first
mention). Cross-references to the Guidebook name it as "the Guidebook,
chapter N".

## Files and pipeline

- Sources: `docs/companion/00-front-matter.md`, `01-precalculus.md` ...
  `08-engineering-mathematics.md`, images in `docs/companion/images/`.
- Screenshots: `scripts/companion-screens.js` (same deterministic
  harness-capture approach as the guidebook's, same helpers).
- Typeset: `scripts/build-guidebook-typeset.js` gains a third book,
  `Free85-Companion-typeset.pdf`, reusing the design system (same page
  masters, keycaps, callouts, bezels, openers, TOC; companion cover in
  the family style). Plain pipeline gains it too if cheap.
- No traceability gate (no ledger contract); the typeset build's link and
  image verification applies.

## Delivery

Branch `docs/companion`; chapter batches with the established
writer -> emulator-verifying spec review -> editorial review cycle; final
design QA of the typeset book; PDFs attached to releases alongside the
other two books; PR to main at the end.

## Independence check (coordinator, 2026-08-04)

Performed after the eight chapters and front matter were finished, as the
originality rules require. No chapter writer or reviewer was ever shown the
inspiration; they worked from this spec's topic outline, the Free85
documentation, and the emulator. The coordinator sampled three chapters of
the inspiration (business mathematics, calculus I, differential equations)
and compared every worked example, data set and exercise against the
finished book.

Result: no overlap of any kind. The inspiration's business chapter works
abstract matrices named C, D, S, M and W, a maximisation of 2x + 3y under
4x + y <= 6 and x + 2y <= 5, and systems such as x + y + z = 6. The
companion's works café receipts, a three-leaf tea blend, a joinery
maximising 30x + 40y under a timber and a labour constraint, a picture
framer's tableau and a three-shop Markov chain. The inspiration's calculus
chapter works sin(x)/x through epsilon-delta rectangles, sin(cos x) at
x = 15 and 100, and 63-entry difference lists; the companion works a
parabola with a hole, difference quotients on a designed cubic, a dip
parabola whose signed areas cancel, a harbour temperature model and
Riemann-sum programs. The inspiration's differential-equations chapter works
q' = q^2, dQ/dt = sin^2(t - Q), falling-body resistance models and the
logistic and Gompertz equations; the companion works a mixing tank and an
equilibrium family, with Euler and Heun as typed programs.

The machines diverge as much as the examples. Several of the inspiration's
methods cannot exist on Free85: 63-entry lists (Free85 caps at 8), nine
differential-equation slots with separate initial conditions and picture
compositing (Free85 holds one first-order equation with a frozen seed), and
function-call syntax such as mRAdd(-2, S, 1, 2) (Free85 uses soft keys and
register operands). The companion's designs follow from its own machine.
