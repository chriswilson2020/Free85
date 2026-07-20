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
were. Unless an entry below says otherwise, every message in this
appendix presents and dismisses exactly this way.

A few screens carry their messages themselves rather than raising the
dialog: the simultaneous solver's verdicts, the program run screen's
stop and error reports, and the catalog's assignment confirmation. Their
entries below describe their own mechanics.

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
  show: [▼] beyond the blank line at the newest end, or either key on a
  fresh machine with no history yet. Chapter 1 covers both recall
  routes, [2nd] [ENTER] and the arrow keys, along with this release's
  caution about stepping back past the oldest entry.
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
  and 4).
- **`DIVIDE BY ZERO`**: division by zero, chapter 1's specimen error.
  `1/0` answers it, so do `MOD(5,0)` (chapter 3) and dividing by a
  complex zero in the complex editor (chapter 11).
- **`DOMAIN ERROR`**: an argument outside a function's domain. Chapter
  3 collects the home-screen causes (`LN(0)`, `ASIN(2)`, `ACOSH(0.5)`,
  `ROOT(-8,3)`, `FACT(-1)` and kin), chapter 11 adds `SQRT(-9)` on the
  real line, and chapter 10 adds the word-model violations such as
  `ROL(1,16)` and `AND(2.5,1)`.
- **`NUMERIC OVERFLOW`**: a result beyond the numeric range, whose
  exponents run to 127: `FACT(70)` (chapter 3), `1E99*1E99`, or a base
  literal beyond sixteen bits such as `0x10000` (chapter 10).
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

## Solver messages

- **`NO NUMERIC RESULT`**: a numeric search found nothing to report:
  the general solver on an expression with no real root (`X^2+1`) or
  with an empty entry line (chapter 14), and the graph screen's
  root-finding soft keys when the search fails (chapter 4).
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
produces. `NEED TWO SAMPLES` and `ZERO VARIANCE` belong to the
statistics tools, but the editor keeps its two columns the same length
and the degenerate cases answer result screens of zeros instead
(chapter 15 shows a constant column answering `R 0`), so neither
message reaches the screen. `NO OBJECTS` is the memory browser's answer
to an empty store, and the store is never empty (chapter 18).
`EVALUATOR NEXT`, `NO ALPHA MAP`, and `FEATURE PLANNED` round out the
set; we found no key sequence that shows any of them. If one of these
ever greets you, treat it as this book's cue for an update.
