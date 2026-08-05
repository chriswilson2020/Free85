# Explorations with Free85

*Explorations with Free85* is a workbook. Its eight chapters follow the
order of a mathematics course, from precalculus through to engineering
mathematics. Each section asks a question about the mathematics, works it
through on the machine keystroke by keystroke, and then hands you exercises
to carry on with on your own.

It is a companion to the two books that already exist, and it does not
re-teach them. The Free85 Getting Started Manual gets you running, from the
first key press to storing your own work. The Free85 Guidebook is the
reference for every command and every key, subject by subject. This book
puts the two of them to work. It assumes the calculator is in your hand and
asks what you can actually find out with it.

## Who is writing this

I wrote the firmware.

That is worth saying because it changes what this book can tell you. Free85
is a clean-room calculator ROM built from scratch, and I have spent long
enough inside its arithmetic to know why it does most of what it does. So
when you hit an edge in these chapters, and you will hit plenty, I can
usually tell you what is behind it instead of leaving you to conclude that
the machine is simply badly made.

Some of those edges have good reasons and some of them are things I would
do differently now. Both are more useful to you than silence. Where I am
guessing, or where the answer is "it was the cheapest thing that worked", I
say so.

I have tried to do this without turning the book into a tour of the
firmware. When a limit shapes the mathematics you are doing, it gets
explained. When it does not, it stays out of the way.

## An original work, and what that does and does not mean

This book was written for Free85 from scratch. Its prose, its screens and
its numbers are its own. Every key sequence in it was pressed on the
emulator and every quoted result was copied from the screen at full
precision.

The mathematics is not its own, and does not pretend to be. The quotient
sin x over x for limits, Newton's method for roots, the logistic equation
for growth, the pendulum and its elliptic integral: these are the standard
examples of their subjects. They are taught everywhere, they belong to
nobody, and a workbook that avoided them in order to look original would
simply be a worse workbook. You are better served by the example you will
meet again in your course.

Where this book does have something of its own, it is in what a small
machine does to those examples. That is a question nobody else has had to
answer, and it turns out to be a better one than I expected.

Free85 is open source under the MIT License. See the `LICENSE` file for the
licence text and `NOTICE.md` for the project notices. It is not affiliated
with, derived from, or endorsed by any calculator manufacturer or
publisher.

## How to read it

The conventions belong to the Guidebook and this book inherits them:

- **Keys** appear in brackets using their keycap labels: [ENTER], [2nd],
  [ALPHA], [GRAPH], [F1] through [F5], and the cursor keys [▲] [▼] [◀] [▶].
  A sequence such as [2nd] [F1] means press and release [2nd], then press
  [F1]. A bracketed letter such as [H] means the key carrying that letter
  legend, with [ALPHA] supplied where the context needs it.
- **On-screen text and typed expressions** appear in code spans: the status
  line shows `RAD AUTO`, and the entry line holds `X^3-4*X`. Command, mode
  and variable names are set the same way.
- **Screenshots** are exact captures of the emulated 128 by 64 pixel screen.
  They are made by booting a fresh machine, pressing the listed keys and
  photographing the result, so they cannot drift away from the firmware
  without somebody noticing.
- **Diagrams** are the pictures the calculator did not draw. They are set
  plain, without the calculator's bezel around them, so a glance tells you
  which figures came off the machine and which are explaining the
  mathematics behind it.

Every section closes with a **Try it** block of exercises. The answers are
not printed, because the machine is the answer key: nearly every exercise is
answerable with the technique the section has just shown. Where one is not,
the chapter says so and sends you to paper.

Some exercises ask you to predict or sketch something **before** you press a
key, and tell you to write the guess down. Please do. Being wrong on paper
and then finding out why is most of what these exercises are for, and it
does not work if you look first.

## Getting back to a known state

You will get lost. Everybody does, and the machine is not always
forthcoming about where you are. These are the ways back.

- **The entry line never clears itself.** Whatever you typed last is still
  sitting there, and new typing gets added to the end of it. Press [CLEAR]
  before typing at the home screen. Always.
- **After an error screen, press [CLEAR] twice.** The first press dismisses
  the message; the second empties the line the message left behind. One
  press looks like it worked and then your next expression comes out
  mangled.
- **[2nd] [+] restores the standard window**, -10 to 10 on both axes,
  whenever an experiment has taken the graph somewhere unhelpful.
- **A plot must be allowed to finish.** Presses that arrive while the
  machine is still drawing are dropped, not queued. If a key seems dead,
  that is usually why. Let the curve reach the right-hand edge.
- **[GRAPH] stores whatever is on the entry line into the active slot**,
  including nothing. Returning to the plot from an empty line wipes the
  equation, so go back with the equation on the line.
- **The DifEq mode freezes its initial value** when the mode is first
  entered, and storing a new one into `Y` afterwards changes nothing.
  Section 7.6 has the deliberately stiff lever that resets it.

If all else fails, the memory browser at [2nd] [+] and the Guidebook,
chapter 18 will show you what the machine is actually holding.

## A word on the machine's limits

Free85 keeps three graph slots, lists of eight samples, matrices no larger
than 3 by 3, vectors of three components, polynomials to degree 4, whole
exponents from -9 to 9, and four program slots of eight lines each.

Those numbers are not accidents and they are not apologies. Each of them is
a decision I made, mostly about how much of a very small machine to spend on
one feature, and each of them shapes what an exploration can be. So the
explorations here are designed inside the limits rather than around them.

A family of curves is studied three members at a time. A data set is eight
numbers you can hold in your head. An elimination is small enough to watch
every entry change, and a program is short enough to be an argument about
what its algorithm really is.

Where a limit closes a door, this book says so, tells you why the door is
there, and goes round. That turns out to be the most useful thing in it.

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
   repeat, simulation by program, least squares built by hand, regression
   families, forecasting, and the four statistical plots.
4. [Explorations in Calculus I](04-calculus-1.md): limits by table and
   zoom, limits that do not exist, the derivative built from difference
   quotients, extrema by search, the definite integral as an average,
   Riemann sums by program, and areas between curves.
5. [Explorations in Calculus II](05-calculus-2.md): zeros two ways,
   Newton's method, conics by parametric pair, polar curves, parametric
   motion, functions defined by integrals, indeterminate forms, improper
   integrals, and polynomial approximation.
6. [Explorations in Linear Algebra](06-linear-algebra.md): one system
   solved two ways, row operations watched move by move, norms and
   conditioning, orthogonality and an axis frame of your own, eigenvalues
   and eigenvectors, and `LU` as elimination's ledger.
7. [Explorations in Differential Equations](07-differential-equations.md):
   slope thinking in the DifEq mode, the window as the step size,
   step-size experiments, an Euler program and its improvement, the
   logistic and Gompertz models, and the qualitative behaviour of
   solution families.
8. [Explorations in Engineering Mathematics](08-engineering-mathematics.md):
   the pendulum and elliptic integrals, series summed against closed
   forms, a shooting method for a boundary-value problem, and vectors in
   the round.

[Afterword: after the last exploration](09-afterword.md): what a bounded
instrument is for.
