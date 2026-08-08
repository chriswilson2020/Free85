# Appendix C: System Variables and Error Messages

The first half of this appendix collects in one place the names the
calculator keeps for you; the second half is the error reference promised
in chapter 1: every message the calculator can answer with, what causes
it, and the way back. Every screen quoted below was produced on the
machine by pressing the keys described.

## System variables

- **`ANS`** ([2nd] [(-)]) always names the most recent numeric result.
  It is maintained by the calculator and cannot be stored to: `5->ANS`
  answers `SYNTAX ERROR`. Chapters 1 and 2 cover it.
- **`A` through `Z`** are the twenty-six named variables, present from
  first boot with the value `0`. They can be cleared but never removed,
  and every one you have never stored to reads as `0`. Chapter 2 covers
  storing and recalling; chapter 18 covers clearing.
- **`x` and `X`** are one variable, the graph variable: the [x-VAR] key
  types `X` in one press, both spellings read and store the same value,
  and `x` is the only lowercase letter accepted in a name. Chapters 2
  and 4 cover it.
- **`M1` through `M5`** are the five numeric memories on [2nd] [F1]
  through [2nd] [F5]: with an expression on the entry line the key
  stores, with an empty line it recalls. Chapter 2 covers them.
- **`Y1` through `Y3`** are the three graph function slots: [GRAPH]
  saves the home entry line into the active slot, `Y1` is active on a
  fresh boot, and the stored equations persist between plots. Chapter 4
  covers the slots and switching between them.
- **The editor registers `A`, `B`, and `R`** belong to the string,
  complex, list, matrix, and vector editors: each editor keeps its own
  pair of working registers and a result register, separate from the
  named variables, and their contents survive leaving the editor.
  Chapters 9, 11, 12, and 13 cover them, and chapter 15's statistics
  editor keeps its `X` and `Y` data columns the same way.

## How errors present

Errors and confirmations share one full-screen dialog, introduced in
chapter 1. The status line stays put, and the body shows three lines:
the message name, the hint `CLEAR OR EXIT` beneath it, and `EXIT BACK`
at the bottom. Pressing [CLEAR] or [EXIT] returns you to the home
screen. When the error came from evaluating the home entry line, the
entry is preserved with the cursor at the end, so you can fix the
mistake instead of retyping it; when it came from inside an editor, the
editor keeps its contents, and reopening it puts you back where you
were. The statistics screens of chapter 15 deserve one extra sentence
here: their result screens leave with [EXIT] for the home screen and
[CLEAR] for the editor, but their guard dialogs dismiss to the home
screen with either key, so press [STAT] to return to the data. Unless
an entry below says otherwise, every message in this appendix presents
and dismisses exactly this way.

A few screens carry their messages themselves rather than raising the
dialog: the simultaneous solver's verdicts, the program run screen's
stop and error reports, and the catalog's assignment confirmation. Their
entries below describe their own mechanics. The link screen belongs to
this family too: `STATUS ERROR` and `STATUS CANCELLED` are readings of
its `STATUS` line, not dialogs, and chapter 19 walks that line's whole
vocabulary, so they get no entries of their own here.

## Entry and editing notices

These guard the home entry line and cost you nothing: dismiss them and
your entry is exactly as you left it.

- **`ENTRY FULL`**: the entry line holds 48 characters, and the press
  that would add a 49th answers this instead. Chapter 1 covers the
  entry line.
- **`ENTRY EMPTY`**: [CLEAR] with nothing on the entry line.
- **`START OF ENTRY`**: [◀] or [DEL] with the cursor at the start of
  the entry.
- **`END OF ENTRY`**: [▶] with the cursor at the end.
- **`NO MORE HISTORY`**: [▲] and [▼] step through the previous entries
  on the home screen, and the notice answers a step with nothing to
  show: [▲] past the oldest entry, [▼] beyond the blank line at the
  newest end, or either key on a fresh machine with no history yet.
  Chapter 1 covers both recall routes, [2nd] [ENTER] and the arrow
  keys.
- **`ALREADY AT HOME`**: [EXIT] pressed on the home screen, where there
  is nowhere further up to go.
- **`ALREADY AWAKE`**: [ON] pressed while the calculator is already
  running; chapter 1 notes it does no harm.

## Arithmetic and evaluation errors

- **`SYNTAX ERROR`**: the expression could not be read. The causes are
  as varied as typing: a malformed or incomplete expression, a chained
  comparison such as `2<3<1` (chapter 3), a function given the wrong
  number of arguments such as `MIN(1,2,3)` (chapter 3), storing to an
  invalid name such as `AB` or `ANS` (chapter 2), or a calculus command
  such as `EVAL(` before a plot has run through once (chapters 3
  and 4). It means the expression could not be *read*; a value that
  cannot be *computed* has its own message below, and the two should not
  be confused when reading an old listing.
- **`DIVIDE BY ZERO`**: division by zero, chapter 1's specimen error.
  `1/0` answers it, so do `MOD(5,0)` (chapter 3) and dividing by a
  complex zero in the complex editor (chapter 11).
- **`DOMAIN ERROR`**: an argument outside a function's domain. Chapter
  3 collects the home-screen causes (`LN(0)`, `ASIN(2)`, `ACOSH(0.5)`,
  `ROOT(-8,3)`, `FACT(-1)` and kin), chapter 11 adds `SQRT(-9)` on the
  real line, chapter 10 adds the word-model violations such as
  `ROL(1,16)` and `AND(2.5,1)`, and chapter 16 adds a `FOR` bound that is
  not a whole number, is outside the signed 16-bit range, or a step of
  zero.
- **`NUMERIC OVERFLOW`**: a result beyond the numeric range, whose
  exponents run to 127: `FACT(70)` (chapter 3), `1E99*1E99`, or a base
  literal beyond sixteen bits such as `0x10000` (chapter 10).
- **`PRECISION LOST`**: the argument is too large for its phase to be
  worth reporting. `SIN`, `COS` and `TAN` are supported through one
  million radians or one hundred million degrees; past that a
  fourteen-digit input no longer pins the angle down, so `SIN(1.1E6)`
  stops here rather than returning a plausible number (chapter 3).
- **`NO CONVERGENCE`**: the work ran out before successive estimates
  agreed, or a search finished with nothing to report. `FNINT(` compares
  32-, 64- and 128-panel Simpson estimates and stops here when they will
  not settle (chapter 3); differential-equation mode reports it when a
  solution runs away faster than the window can follow (chapter 7); and
  the graph screen's root key [F1] and intersection search [2nd] [F1]
  report it when they scan the window without bracketing a crossing.
  That last case covers a function that never reaches zero, such as
  `X^2+1`, one that touches zero without changing sign, such as
  `X^2-4*X+4` (chapter 4), a polar radius that never crosses zero
  (chapter 5), and a differential-equation slope that never crosses zero
  (chapter 7).
- **`RECURSION ERROR`**: a graph slot reached itself. One nested graph
  evaluation is available, so a slot may read another slot, but
  `NDER(1,X)` stored in slot 1, or a cycle between two slots, stops here
  while the unrelated slots plot as usual (chapter 4).
- **`SIGNED 16-BIT INT`**: the number-base screen asked to display a
  value the 16-bit word cannot hold; `2.5` and `32768` both stop here.
  Chapter 10 covers the word model.

## Data and editor errors

- **`INVALID NUMBER`**: a number was needed and not found. The editors
  answer it for an entry that does not parse (a bare [.], say, in the
  polynomial, simultaneous, or statistics editors; chapters 14 and 15),
  the string tools answer it for `S2N` on text that is not a number
  (chapter 9), and the list editor answers it for `DIV` where list `B`
  holds a zero (chapter 12).
- **`STRING TOO LONG`**: a string register holds up to 31 characters;
  typing a 32nd answers this, and so does a `CAT` concatenation whose
  combined length would not fit. Chapter 9 covers the registers.
- **`DIMENSION ERROR`**: shapes that do not fit together: lists of
  different sizes combined element by element (chapter 12), matrix
  shapes that do not match the operation (chapter 13), or the vector
  cross product `CRS` with two-component vectors (chapter 13).
- **`SINGULAR MATRIX`**: inverting or solving with a matrix whose
  determinant is zero, such as the matrix 1, 2, 2, 4. Chapter 13
  covers it, and chapter 14's simultaneous solver reports the same
  situation with the two messages below.
- **`ZERO VECTOR`**: normalising a vector of zeros, which has no
  direction to keep. Chapter 13 covers the vector tools.
- **`CONSTANT ERROR`**: the user-constants screen's refusal (chapter
  8): confirming an empty name with [ENTER], saving a value under a
  name that is not one to seven letters, or renaming onto a name
  already taken. Dismissal leaves for the home screen.

## Solver messages

- **`ENTER EQUATION HOME`**, **`LOWER MUST BE < UPP`**,
  **`EQUATION DOMAIN ERR`**, and **`NO BOUNDED ROOT`**: the four
  notices guarding `SOLV` in chapter 14's general solver. The first
  answers `SOLV` with no stored equation; type one on the home entry
  line and press [2nd] [GRAPH] to store it. The second answers bounds
  out of order, its last letters clipped by the screen; read it as
  lower must be less than upper. The third answers a stored equation
  that cannot be evaluated across the bounds, such as `LN(X)-1` over
  the default `-10` to `10`, clipped the same way from equation domain
  error. The fourth answers an equation with no sign change between
  the bounds, such as `X^2+1`. Each shows the usual dialog and
  dismisses to the home screen with the workspace kept, so
  [2nd] [GRAPH] reopens it where you left off.
- **`LEADING COEFF ZERO`**: the polynomial solver run with a zero
  leading coefficient, which would really be a polynomial of lower
  degree. Chapter 14 covers the editor.
- **`UNIQUE SOLUTION`**, **`NO SOLUTION`**, and **`UNDERDETERMINED`**:
  the simultaneous solver's three verdicts, shown on its own result
  screen under the `SIMULTANEOUS` banner with `EXIT BACK` as the only
  footer; the screen answers only to [EXIT], and the editor reopens
  with every cell kept. `UNIQUE SOLUTION` heads the list of unknowns,
  contradictory equations answer `NO SOLUTION`, and dependent
  equations answer `UNDERDETERMINED`. Chapter 14 covers all three.

## Statistics messages

These guard chapter 15's fitting and forecasting keys. Each shows the
usual dialog, and either key dismisses to the home screen with the
data kept, so press [STAT] to return to the editor.

- **`NEED TWO SAMPLES`**: a polynomial regression fit with fewer pairs
  than it needs, one per coefficient; the wording stays the same
  however many samples the model really wanted. Chapter 15 covers the
  regression families.
- **`POSITIVE DATA NEEDE`**: a logarithmic, exponential, or power fit
  over data its transform cannot take the logarithm of: `LNR` with a
  zero or negative `X` entry, `EXPR` with one in `Y`, or `PWR` with
  either. The final letter of positive data needed falls off the
  21-column screen.
- **`ZERO VARIANCE`**: a polynomial fit (`P2` through `P4`) over a
  constant `X` column, which gives the least-squares system nothing
  to work with. The other families answer a coefficient screen rather
  than the notice: chapter 15 shows a constant column answering `A 0`
  and `B 0` under `LIN`.
- **`FCSTX NEEDS 2-COEFF`**: an inverse forecast (`FCX`) on a
  polynomial model when no x between the data's smallest and largest
  `X` produces the target y; an inverse forecast outside the data's
  range needs the two-coefficient families.

## Programming messages

- **`NO PROGRAM`**: `RUN` on an empty program slot. Chapter 16 covers
  the program list.
- **`BAD NAME`**: a rename to an empty or overlong name; program names
  hold up to seven characters. Chapter 16 covers renaming.
- **`ERROR LINE`**: shown on the program run screen, not the dialog,
  with the failing line's number after it, as in `ERROR LINE  2`: a
  line the runner cannot make sense of, an `INPUT` entry that does not
  parse, a `CALL` to an empty slot, or a nesting bound exceeded. Fix
  the line in the editor and run again; a failed run never alters the
  source. Chapter 16 covers running and its limits.
- **`STOPPED LINE`**: the run screen's report that you stopped the
  program, with the line it was on, as in `STOPPED LINE1`; [ON],
  [EXIT], and [CLEAR] all stop a run this way. Chapter 16 covers
  stopping.

Two program screens look like interruptions but are suspensions, not
errors: a run waiting on you, not a run gone wrong. A `MENU` line
suspends the run on a chooser whose banner reads `PROGRAM MENU` and
whose footer reads `F1-F5 SELECT`, and a `PAUSE` line suspends it on a
screen reading `PAUSED` over `PRESS A KEY`. A soft key picks a menu
entry and any key resumes a pause, except [ON], [EXIT], and [CLEAR],
which stop the run from either screen. Chapter 16 covers both, along
with the `INPUT`, `PROMPT`, and `INPST` entry screens that suspend a
run the same way.

## Confirmations

Good news arrives in the same dialog as bad:

- **`MEMORY STORED`**: a numeric memory key ([2nd] [F1] through [2nd]
  [F5]) evaluated your entry and stored the result; the entry is intact
  after dismissal. If the entry does not evaluate, the answer is
  **`MEMORY ERROR`** and nothing is stored. Chapter 2 covers the
  memories.
- **`VARIABLES CLEARED`**: the memory browser's `VAR` key cleared `A`
  through `Z` to `0`. Chapter 18 covers the bulk clears.
- **`PROGRAMS CLEARED`**: the browser's `PGM` key emptied the program
  storage. Chapter 18 again.
- **`TOLERANCE CHANGED`**: [2nd] [CLEAR] cycled the numeric tolerance
  through `1E-6`, `1E-8`, and `1E-10`, confirming each press. Chapter 3
  covers the tolerance.
- **`ASSIGNED F2`** and its siblings `ASSIGNED F1` through
  `ASSIGNED F5`: the catalog's confirmation that a function was
  assigned to a custom-menu slot, shown on the catalog screen itself
  rather than as a dialog. Chapter 1 covers the custom menu.

## Messages you are unlikely to meet

The calculator defines a few messages that no ordinary key sequence
produces. `NO OBJECTS` is the memory browser's answer to an empty
store, and the store is never empty (chapter 18). `EVALUATOR NEXT`,
`NO ALPHA MAP`, and `FEATURE PLANNED` round out the set; we found no
key sequence that shows any of them. Earlier editions listed
`ZERO VARIANCE` here too; the 2.10 polynomial fits made it reachable,
and it now has its entry among the statistics messages above. If one
of the remaining four ever greets you, treat it as this book's cue for
an update.
