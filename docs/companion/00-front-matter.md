# Explorations with Free85

A question worth asking about the mathematics, worked through on the
machine keystroke by keystroke, and then handed over as exercises for you
to carry on with: that is an exploration, and this is a book of them.
*Explorations with Free85* is a workbook whose eight chapters follow the
order of a mathematics course, from precalculus through to engineering
mathematics.

It is a companion to the two books that already exist, and it does not
re-teach them. The Free85 Getting Started Manual gets you running, from
the first key press to storing your own work. The Free85 Guidebook is the
reference for every command and every key, subject by subject. This book
puts the two of them to work: it assumes the calculator is in your hand
and asks what you can find out with it. Every key sequence and every
quoted number in these chapters was run on the emulator.

## An original work

This book, like the firmware and like the two books before it, was
written from scratch for Free85. Its explorations, worked examples, data
sets, and exercises are its own, invented for this machine and chosen to
suit its ranges and limits. It is not affiliated with, derived from, or
endorsed by any calculator manufacturer or publisher.

Free85 is open source under the MIT License. See the `LICENSE` file for
the licence text and `NOTICE.md` for the project notices.

## How to read it

The conventions belong to the Guidebook, and this book inherits them:

- **Keys** appear in brackets using their keycap labels: [ENTER], [2nd],
  [ALPHA], [GRAPH], [F1] through [F5], and the cursor keys
  [▲] [▼] [◀] [▶]. A sequence such as [2nd] [F1] means press and release
  [2nd], then press [F1]. A bracketed letter such as [H] means the key
  carrying that letter legend, with [ALPHA] supplied where the context
  needs it.
- **On-screen text and typed expressions** appear in code spans: the
  status line shows `RAD AUTO`, and the entry line holds `X^3-4*X`.
  Command, mode, and variable names are set the same way.
- **Screenshots** are exact captures of the emulated 128 by 64 pixel LCD,
  made by booting a fresh machine, pressing the listed keys, and
  photographing the result.

One convention is this book's own. Every section closes with a **Try it**
block of exercises. The answers are not printed, because the machine is
the answer key: nearly every exercise is answerable with the technique
the section has just shown, and where one is not, the chapter says so and
sends you to paper, as Chapter 7 (Explorations in Differential Equations)
does at the edge of what the machine will integrate.

The explorations assume you can already drive the calculator, which is
chapter 1 of the Getting Started Manual, and that you will reach for the
Guidebook when a command needs its full reference. Each chapter names the
Guidebook chapters it leans on in its opening paragraph.

## A word on the machine's limits

Free85 keeps three graph slots, lists of eight samples, matrices no
larger than 3 by 3, polynomials to degree 4, and four program slots of
eight lines each. Those numbers shape what an exploration can be, so the
explorations are designed inside them rather than around them: a family
of curves is studied three members at a time, a data set is eight numbers
you can hold in your head, an elimination is small enough to watch every
entry change. The limits are part of the mathematics here, and the
chapters treat them that way.

## Contents

1. [Explorations in Precalculus](01-precalculus.md): windows and what
   they hide, families of curves three at a time, zeros and
   intersections, transformations, growth, and the trigonometric graphs.
2. [Explorations in Business Mathematics](02-business-mathematics.md):
   prices from receipts by simultaneous solving, linear programming on
   the graph screen, elimination as bookkeeping, the mathematics of
   money, and Markov chains run to their long-run state.
3. [Explorations in Probability and Statistics](03-probability-statistics.md):
   descriptive statistics on eight-sample columns, random numbers that
   repeat, simulation by program, regression families, forecasting, and
   the four statistical plots.
4. [Explorations in Calculus I](04-calculus-1.md): limits by table and
   zoom, the derivative built from difference quotients, extrema by
   search, the definite integral as area and as average, Riemann sums by
   program, and areas between curves.
5. [Explorations in Calculus II](05-calculus-2.md): zeros two ways,
   conics by parametric pair, polar curves, parametric motion, functions
   defined by integrals, indeterminate forms, improper integrals, and
   polynomial approximation.
6. [Explorations in Linear Algebra](06-linear-algebra.md): one system
   solved two ways, row operations watched move by move, norms and
   conditioning, orthogonality, eigenvalues and eigenvectors, and `LU`
   as elimination's ledger.
7. [Explorations in Differential Equations](07-differential-equations.md):
   slope thinking in the DifEq mode, the window as the step size,
   step-size experiments, an Euler program and its improvement, and the
   qualitative behaviour of solution families.
8. [Explorations in Engineering Mathematics](08-engineering-mathematics.md):
   the pendulum and elliptic integrals, series summed against closed
   forms, a shooting method for a boundary-value problem, and vectors in
   the round.

[Afterword: after the last exploration](09-afterword.md): what a bounded
instrument is for.
