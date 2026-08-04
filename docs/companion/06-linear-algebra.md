# Chapter 6: Explorations in Linear Algebra

Linear algebra is the mathematics of flat things: lines, planes, and the
transformations that carry them onto one another. Its habitat on Free85 is
small, matrices at most 3 by 3 and vectors of two or three components, small
enough that every number in every register can be looked at. Chapter 2
(Explorations in Business Mathematics) used the matrix editor as a
bookkeeper; this chapter uses it as a laboratory: one system solved two
ways, elimination watched move by move, condition numbers, orthogonality,
eigenvectors, and the `LU` factorisation. The editors and their registers
are the Guidebook, chapter 13; the simultaneous editor is the Guidebook,
chapter 14. Every key sequence and every quoted number in this chapter was
run in the emulator on a fresh machine, and each exploration ends with a
"Try it" block whose answers stay on the calculator.

Three habits carry the chapter. The editors keep three registers: `A` and
`B` hold the operands you type, and `R` holds the result of whichever key
you press, read-only. One selection cursor is shared by all three, so
wherever a walk through one register leaves it, that is where the next view
opens. And nothing carries forward on its own: feeding a result into the
next operation means retyping it into `A` by hand.

## 6.1 One system, two tools

A system of two linear equations is a pair of lines, and solving it is
finding their crossing. Design the answer first: through the point (2, 3)
run the pair x + 2y = 8 and 3x - y = 3. Free85 has two tools that recover
the crossing from the coefficients alone, and they explain themselves
differently: one names the point, the other rewrites the system until it
names itself.

1. Press [2nd] [STAT] (the `SIMULT` legend) for the simultaneous editor of
   Chapter 2, section 2.1: a fresh machine shows `SIZE 2`. Each row takes
   its coefficients and then its right-hand side, so type [1] [ENTER] [2]
   [ENTER] [8] [ENTER] for the first line, then [3] [ENTER] [(-)] [1]
   [ENTER] [3] [ENTER] for the second.

2. Press [F1], `SOLVE`. The result screen answers `UNIQUE SOLUTION` with
   `X 2` and `Y 3`: the crossing, named in one press.

3. Now the same system as a tableau. Press [EXIT]. The home screen keeps a
   stale `= 3` from the result screen, and this one does not wipe: nothing
   was handed back to the entry line, so [CLEAR] answers `ENTRY EMPTY`
   rather than sweeping the old result away. Leave it where it sits and
   press [2nd] [7] (the `MATRX` legend) for the matrix editor of the
   Guidebook, chapter 13, and [x-VAR] [+] to grow the columns: `SIZE 2X3`.
   Type the same six values, [1] [ENTER] [2] [ENTER] [8] [ENTER] [3]
   [ENTER] [(-)] [1] [ENTER] [3] [ENTER], and press [F5], `RREF`. Register
   `R` opens on `CELL 1 1` reading `1`, and two presses of [▶] read `0` and
   then `2`: the first equation has become 1x + 0y = 2, and `CELL 1 3`
   holds the value of x:

   ![The reduced tableau naming x](images/co06-rref-solution.png)

   Three more presses read the second row, `0`, `1`, `3`, which says y = 3,
   and a sixth wraps the selection home.

4. One number certifies that the crossing had to be unique. Press [ALPHA]
   twice to come back to `A`, then [-]: the resize keys still point at
   columns from the earlier [x-VAR], so the tableau narrows to `SIZE 2X2`,
   dealing its leftover values into the smaller square. Retype the
   coefficients from the top, [1] [ENTER] [2] [ENTER] [3] [ENTER] [(-)] [1]
   [ENTER], and press [F1], `DET`: `-7`. A nonzero determinant means the
   lines are not parallel, so they cross exactly once; `0` would have
   promised one of the two degenerate verdicts instead.

The simultaneous editor scales to four unknowns and names its verdicts in
words, the tool when only the answer matters; the tableau shows the
structure behind the verdict. An augmented tableau fits the 3 by 3 matrix
world only up to two unknowns, so three unknowns belong to the simultaneous
editor, or to the matrix `SOLVE` key with coefficients in `A` and right-hand
sides down `B`'s first column (section 2.3).

**Try it.**

1. Enter the tableau 1, 2, 4, then 1, 2, 5: parallel lines. What impossible
   equation does `RREF`'s bottom row spell? Check that the simultaneous
   editor answers `NO SOLUTION` for the same six values.
2. Design your own pair of lines through (3, 1), solve with both tools, and
   check the answers agree.
3. Compute `DET` for the coefficients 2, 4, 1, 2. Which verdicts remain
   possible for systems built on them, and which is ruled out?

## 6.2 Row operations as algebra you can watch

Elimination rewrites a system again and again, and the licence is that no
row operation moves the solution set: adding a multiple of one equation to
another, rescaling, and swapping each replace the system with a different
description of the same crossing, and each is reversible, which is the whole
proof. Section 2.3 taught the choreography, the scale in `B`'s top-left
cell, results landing in `R`, one selection cursor shared by the three
registers; here it serves the geometry. The specimen is x + 2y = 5 and 3x +
4y = 11, two lines designed to cross at (1, 2).

1. Press [2nd] [7], then [x-VAR] [+] for `SIZE 2X3`, and type the tableau:
   [1] [ENTER] [2] [ENTER] [5] [ENTER] [3] [ENTER] [4] [ENTER] [1] [1]
   [ENTER]. The entry wraps home, and [MORE] [MORE] brings back the
   row-operation page `REF SWAP RADD RMUL` of section 2.3.

2. First move: subtract three copies of row 1 from row 2. Press [ALPHA] for
   `B`, type [(-)] [3] [ENTER], and press [ALPHA] again for `A`, where the
   trip has stepped the shared selection to `CELL 1 2`. Press [▼] three
   times for `CELL 2 2`, any cell of row 2, and press [F3], `RADD`. Stepping
   through `R` reads `1`, `2`, `5`, then `0`, `-2`, `-4`. The new second row
   says -2y = -4, a horizontal line, and it still passes through (1, 2): the
   pair of lines changed, the crossing did not.

3. Carry the result forward as section 2.3 taught: the fifth [▶] left the
   selection at `CELL 2 3`, one more wraps it home, [ALPHA] twice returns
   the view to `A`, and retyping [1] [ENTER] [2] [ENTER] [5] [ENTER] [0]
   [ENTER] [(-)] [2] [ENTER] [(-)] [4] [ENTER] copies the new tableau in.

4. Second move: rescale the new row so its surviving coefficient is 1. Press
   [ALPHA], type [(-)] [.] [5] [ENTER], press [ALPHA], then [▼] three times
   for row 2, and press [F4], `RMUL`. Row 2 of `R` reads `0`, `1`, `2`: the
   line y = 2, the same horizontal line wearing its plainest equation.

5. Carry forward again (wrap home, [ALPHA] twice, retype 1, 2, 5, 0, 1, 2),
   then make the last move: subtract two copies of row 2 from row 1. Store
   [(-)] [2] [ENTER] in `B` as before; back in `A` the selection sits at
   `CELL 1 2`, already in row 1, so press [F3], `RADD`. `R` reads `1`, `0`,
   `1`, then `0`, `1`, `2`: the lines are now x = 1 and y = 2, a vertical
   and a horizontal whose crossing can be read without solving anything.

6. The claim that nothing ever moved deserves a test. `A` still holds the
   half-finished tableau 1, 2, 5, 0, 1, 2 from step 5. Press [EXIT], then
   [2nd] [7]: re-entry always brings back the first soft-key page. Press
   [F5], `RREF`: `R` reads the same `1`, `0`, `1`, `0`, `1`, `2`. Machine
   elimination, started half-way, lands exactly where the watched one did:
   every stage described the same crossing.

The copying between moves is the price of watching them separately, as in
section 2.3; what it buys is the geometry, three different pairs of lines on
the way down and one unmoving point beneath.

**Try it.**

1. Rerun the elimination after a [F2], `SWAP`, so the 3, 4, 11 row is on
   top. The moves need different scales; does the finished tableau differ?
2. Rescale row 1 of the original tableau by 10 with `RMUL`, carry the result
   to `A`, and apply `RREF`. Why was the answer never in doubt?
3. Enter 0, 2, 6, then 1, 1, 4. Which single row operation lets elimination
   start, and what does the finished tableau read?

## 6.3 Norms and the condition number

A norm is a size for a matrix, and sizes feed a more useful number: how much
a solve can amplify small errors in its data. Real data always carries small
errors, and a matrix sits between data and answer like a lever; the
condition number measures the lever. This exploration builds one comfortable
matrix and one designed trap with the fourth soft-key page, whose legend
overruns the screen edge (the Guidebook, chapter 13).

1. Press [2nd] [7], then [+] [x-VAR] [+] [x-VAR] for `SIZE 3X3`, and type
   the comfortable specimen row by row: 1, 4, 0, then 2, 1, 1, then 0, 1, 3,
   with [ENTER] after each value. Press [MORE] [MORE] [MORE] for the page
   reading `NORM RNORM CNORM COND`.

2. Press [F1], `NORM`: `5.744562646538`, the square root of 33, the sum of
   the nine squared cells. Press [F2], `RNORM`: `5`, the largest row sum of
   absolute values, from the row 1, 4, 0. Press [F3], `CNORM`: `6`, the
   largest column sum, from the middle column 4, 1, 1.

3. Press [F4], `COND`: `4.242640687119`, the square root of 18. `COND`
   multiplies the Frobenius norm of `A` by the Frobenius norm of its
   inverse, the forward stretch times the return stretch, and a value this
   small is a promise: answers move on the same scale as the data.

4. Hold the promise to account. This coefficient matrix with right-hand
   sides 5, 4, 4 was designed to solve as x = y = z = 1. Press [ALPHA] for
   `B`, resize it to a column with [+] [x-VAR] [-] [x-VAR] (`SIZE 3X1`),
   type 5, 4, 4 with [ENTER] after each, and press [ALPHA] to return to `A`.
   Press [EXIT], [2nd] [7], then [MORE] for the page
   `ADD SUB MUL SCL SOLVE`, and press [F5], `SOLVE`. Stepping through the
   `SIZE 3X1` result reads `0.9999999999998`, `1`, `1.0000000000001`: three
   ones under a grain of fourteen-digit dust.

5. Now nudge the data. One more [▶] wraps the selection home; press [ALPHA]
   for `B`, type [5] [.] [0] [0] [1] [ENTER] over the first entry, press
   [ALPHA], and press [F5] again. `R` reads `0.9999090909089`,
   `1.0002727272727`, `0.9999090909091`. A change of one part in five
   thousand moved no answer by more than three parts in ten thousand: the
   comfortable matrix keeps its word.

6. The trap is three rows that nearly repeat each other. Wrap the selection
   home with [▶], press [ALPHA] twice for `A`, and retype it as 1, 1, 1,
   then 1, 1.001, 1, then 1, 1, 1.001, with [ENTER] after each value. Press
   [MORE] [MORE] for the norms page and press [F4], `COND`:

   ![COND warning of a near-dependent matrix](images/co06-cond-ill.png)

   `9490.8400582879`. Nothing has gone wrong yet; the number is a forecast,
   and it forecasts trouble on the order of ten thousand to one.

7. Watch the forecast come true. Press [ALPHA] for `B` and type the designed
   right-hand sides [3] [ENTER] [3] [.] [0] [0] [1] [ENTER] [3] [.] [0] [0]
   [1] [ENTER]; press [ALPHA], then [EXIT], [2nd] [7], [MORE], and [F5],
   `SOLVE`. Stepping through `R` reads `1`, `1`, `1`, exact to every digit:
   for perfect data the trap stays politely shut.

8. Give it imperfect data. One more [▶] wraps home; press [ALPHA], type [3]
   [.] [0] [0] [1] [ENTER] over the first entry, press [ALPHA], and press
   [F5]:

   ![The solution after a small nudge](images/co06-perturbed-solve.png)

   `R` now reads `3.001`, `0`, `0`. The same one-thousandth nudge that step
   5 shrugged off has tripled x and thrown y and z from 1 to 0: an
   amplification of roughly two thousand, squarely in `COND`'s warned range.
   Nearly repeated rows force differences of nearly equal numbers, and tiny
   data errors decide them outright.

The lesson travels: before trusting a solve, ask `COND` first. A few is
comfortable, thousands is a warning, and exactly dependent rows end the
story at the `SINGULAR MATRIX` notice, the same guard `INV` raises (the
Guidebook, chapter 13).

**Try it.**

1. Type the 3 by 3 identity into `A` and ask `COND`. Why can no 3 by 3
   matrix answer less?
2. Return to the trap system of step 7 and nudge the third right-hand side
   to 3.002 instead. Which unknowns jump this time, and by how much?
3. Soften the trap: retype the near-repeats as 1.01 and ask `COND` again.
   How much smaller is the warning, and how big is step 8's jump now?

## 6.4 Orthogonality by arithmetic

Two directions are orthogonal when they meet at a right angle, and the dot
product turns that geometry into one number: zero exactly when the angle is
right. This exploration measures a designed pair of arrows, straightens one
against the other, and finishes with three mutually perpendicular
directions, inside the vector editor of the Guidebook, chapter 13.

1. Press [2nd] [8] (the `VECTR` legend): a fresh machine shows `SIZE 3` with
   the `RECTV` tag. Type the first arrow, [5] [ENTER] [2] [ENTER] [0]
   [ENTER], press [ALPHA] for `B`, type the second, [1] [ENTER] [2] [ENTER]
   [2] [ENTER], and press [ALPHA] to return to `A`.

2. Press [F1], `MAG`: `5.3851648071345`, the square root of 29 and the
   length of the first arrow; the second's is 3 on paper, since 1 + 4 + 4
   is 9.

3. Press [F3], `DOT`: `9`, not zero, so the pair is not orthogonal. Press
   [F5], `ANG`: `0.9799235766495`, the angle between them in the fresh
   machine's `RAD` mode, a little over 56 degrees.

4. Straightening is one designed subtraction. The shadow of the first arrow
   along the second has length dot product over length squared, and 9 over 9
   is exactly one copy of `B`. Press [MORE] for the page
   `ADD SUB SCL 2D 3D`, then [F2], `SUB`: `R` reads `4`, `0`, `-2`, the
   first arrow with its shadow removed.

5. Carry the result into `A`: two presses of [▶] read the remaining
   components, one more wraps the selection home, [ALPHA] twice returns to
   `A`, and retyping [4] [ENTER] [0] [ENTER] [(-)] [2] [ENTER] stores it.
   Press [EXIT], then [2nd] [8], and the first soft-key page is back. Press
   [F3], `DOT`: `0`, exactly. Press [F5], `ANG`:

   ![A right angle earned by subtraction](images/co06-right-angle.png)

   `1.5707963267949`: half of `PI` to fourteen digits, the right angle
   confirmed twice over.

6. Press [F2], `NRM`: `R` reads `0.89442719099991`, `0`,
   `-0.44721359549996`, the same direction rescaled to length one. A unit
   vector is direction with the length divided out: the first component
   stays twice the size of the last, bar the final digit.

7. One key completes the set. Press [F4], `CRS`: `R` reads `4`, `-10`, `8`,
   the cross product of `A` and `B`, perpendicular to both by construction.
   With `B`, the straightened `A`, and this result, you hold three
   directions at mutual right angles: an axis frame of your own making.

The vector world has two or three components: the plane and space are its
whole territory, and `CRS` insists on all three, since the cross product
only lives in three dimensions (two-component vectors stop at
`DIMENSION ERROR`, the Guidebook, chapter 13); longer columns of numbers are
data, and belong to the list editor.

**Try it.**

1. Straighten your own pair: with 3, 1, 2 in `A` and 1, 1, 1 in `B`, the
   shadow is two copies of `B`. Build it with `SCL`, carry registers as
   needed, subtract, and confirm with `DOT`.
2. Check step 7's claim: carry `R` into `A` and ask `DOT` against `B`, then
   rebuild and test it against the straightened arrow too.
3. Ask `ANG` for 2, 4, 4 against 1, 2, 2, then `NRM` for each. What do the
   answers, taken together, say about the two arrows?

## 6.5 Eigenvalues and eigenvectors

Multiply a vector by a matrix and its direction usually turns. The
directions a matrix keeps are its eigenvectors, the stretch it applies along
each is the eigenvalue, and between them they are the matrix's character in
summary. This exploration catches a kept direction by multiplication, then
lets the machine find the full set, in two sizes and one complex surprise.

1. Press [2nd] [7] and type the specimen 5, 2, then 2, 2, with [ENTER] after
   each value. Give `B` a test arrow: press [ALPHA], resize to a column with
   [x-VAR] [-] [x-VAR] (`SIZE 2X1`), type [1] [ENTER] [0] [ENTER], and press
   [ALPHA] to return to `A`. Press [MORE] for the arithmetic page, then
   [F3], `MUL`: `R` reads `5` and, one [▶] later, `2`. The direction east
   went out east-north-east: turned.

2. Try the arrow the matrix was designed around. One more [▶] wraps the
   two-cell result home; press [ALPHA], type [2] [ENTER] [1] [ENTER], press
   [ALPHA], and press [F3] again: `R` reads `12` and then `6`, which is six
   copies of 2, 1. Direction kept, length stretched sixfold: 2, 1 is an
   eigenvector with eigenvalue 6.

3. The machine finds the whole set in one press. Press [▶] to wrap home,
   then [MORE] [MORE] [MORE] for the page `LU EVAL EVEC DIM FILL`, and press
   [F2], `EVAL`: a `SIZE 1X2` result reading `6` and, one [▶] later, `1`.
   Press [F3], `EVEC`: a `SIZE 2X2` result, one normalised eigenvector per
   column, and stepping through reads `0.89442719099991`,
   `0.44721359549996`, `0.44721359549996`, `-0.89442719099991`. The first
   column is 2, 1 divided by its length; the second, 1, -2 over the same
   root 5, is the direction stretched by 1.

4. A 3 by 3 next, chosen triangular so the answers are visible in advance:
   zeros above the diagonal mean the diagonal itself lists the eigenvalues.
   One more [▶] wraps the selection home; press [ALPHA] twice for `A`, grow
   it with [+] [x-VAR] [+] [x-VAR] (`SIZE 3X3`), and type 2, 0, 0, then 1,
   3, 0, then 4, 5, 6, with [ENTER] after each. Press [F2], `EVAL`, and give
   it time: a 3 by 3's roots take the machine far longer than a 2 by 2's
   (the Guidebook, chapter 13). The `SIZE 1X3` result reads
   `6.0000000000007`, then `2.0000000000007`, then `3`. The diagonal
   promised 2, 3, 6; the iterative hunt delivers them a whisker off in the
   final digits.

5. Press [F3], `EVEC`, and give it time again. Stepping through the
   `SIZE 3X3` result, the first column occupies the first, fourth, and
   seventh cells: `0`, then `-1.4E-13`, then `-1`. That is the third axis
   direction times minus one, dust included; any rescaling of an eigenvector
   is the same eigenvector.

6. Check it by multiplying, where the arithmetic is exact. Step [▶] three
   times more to wrap home, press [ALPHA] for `B`, grow it to `SIZE 3X1`
   with [+], and type [0] [ENTER] [0] [ENTER] [1] [ENTER]. Press [ALPHA],
   then [EXIT], [2nd] [7], [MORE], and [F3], `MUL`: `R` reads `0`, `0`, `6`,
   exactly six copies of the third axis. The dusty search and the clean
   multiplication agree.

7. Last, a matrix that keeps no direction at all. Press [▶] once to wrap
   home, press [ALPHA] twice for `A`, shrink it with [-] [x-VAR] [-] [x-VAR]
   (`SIZE 2X2`), and type 1, -2, then 2, 1, using [(-)] for the sign. This
   matrix turns every arrow by the same angle and stretches it by root 5;
   nothing real can be kept. Press [MORE] [MORE] [MORE] for the eigensystem
   page and press [F2], `EVAL`: both cells read `1`. The real parts are only
   half the story, and the other half lives on the final soft-key page:
   press [MORE], and an `IM` line appears under the selected cell:

   ![A complex eigenvalue's IM line](images/co06-eigen-complex.png)

   `IM -2` beneath the first cell, and after [▶], `IM 2` beneath the second:
   the eigenvalues are 1 - 2i and 1 + 2i. A conjugate pair is how a real
   matrix says "I rotate", and the pair's shared size, root 5, is the
   stretch.

**Try it.**

1. Predict the eigenvalues and eigenvectors of 3, 1, 1, 3 from its symmetry,
   then let `EVAL` and `EVEC` grade the prediction.
2. On the section's first specimen 5, 2, 2, 2, check that the two
   eigenvalues add up to the diagonal sum and multiply to `DET`'s answer.
3. Ask `EVAL` about 0, -3, 3, 0, a quarter-turn with stretch. What do the
   cells read, and what does the final page add?

## 6.6 LU as elimination's ledger

Elimination does work worth keeping: the multipliers used on the way down
and the triangle left at the bottom record the entire sweep, and with both
in hand any new right-hand side costs only two short substitution passes,
which is why solving many systems with one matrix is cheap everywhere in
computing. Free85's `LU` key shows the ledger whole: `U` on and above the
diagonal, the multipliers of the unit lower triangle `L` below.

1. Press [2nd] [7], then [+] [x-VAR] [+] [x-VAR] for `SIZE 3X3`, and type
   the designed specimen 2, 1, 1, then 4, 5, 4, then 2, 10, 11, with [ENTER]
   after each value. Press [F1], `DET`, first: `24`, a figure to keep in
   mind.

2. Press [MORE] four times for the page `LU EVAL EVEC DIM FILL`, and press
   [F1], `LU`. Stepping through the `SIZE 3X3` result reads `2`, `1`, `1`,
   then `2`, `3`, `2`, then `1`, `3`, `4`. Read it in two layers: on and
   above the diagonal sits `U`, rows 2, 1, 1 and 0, 3, 2 and 0, 0, 4; below
   sit the multipliers 2, 1, and 3. The ledger replays on paper: row 2 of
   the specimen is 2 times (2, 1, 1) plus (0, 3, 2), and row 3 rebuilds the
   same way from its multipliers 1 and 3. Nothing about the elimination is
   hidden or lost.

3. The diagonal of `U` reads 2, 3, 4, and their product is 24: the
   determinant is elimination's by-product, which is why `DET` and `LU` sit
   in the same toolbox. Step 1's answer was on the ledger all along.

4. Elimination cannot start on a zero, and the ledger records the repair
   too. Press [▶] once to wrap the selection home, press [ALPHA] twice for
   `A`, and retype it as 0, 2, 1, then 2, 4, 6, then 1, 1, 1, with [ENTER]
   after each value. Press [EXIT], then [2nd] [7] for the first page, and
   press [F1], `DET`: `6`. Now press [MORE] four times and press [F1], `LU`:

   ![The ledger of a swapped elimination](images/co06-lu-pivot.png)

   Stepping through reads `2`, `4`, `6`, then `0`, `2`, `1`, then `0.5`,
   `-0.5`, `-1.5`. The top row is the *second* row of the matrix: the
   factorisation swapped rows before starting, exactly as a hand elimination
   would.

5. The swap shows up in step 3's shortcut. The diagonal now reads 2, 2,
   -1.5, whose product is -6, while `DET` answered `6`: each row swap flips
   the determinant's sign, and the ledger keeps the flip. The row order
   itself, 2 then 1 then 3, lands in the vector editor's result register as
   the factorisation runs, overwriting whatever was there (the Guidebook,
   chapter 13), so keep nothing precious in that register when `LU` runs.

On a machine whose world is 3 by 3 the saving is a lesson rather than a
speed-up, but it is the right one: `SOLVE`, `INV`, and `DET` all begin with
this sweep, and `LU` is the receipt showing their common core.

**Try it.**

1. Run `LU` on 3, 1, 0, then 6, 4, 1, then 0, 2, 5, and read off the
   multipliers and `U`. Check the diagonal's product against `DET`.
2. Rebuild the third row of step 1's specimen on paper from the ledger's
   multipliers 1 and 3, without looking at `A`.
3. Design a matrix whose elimination needs a swap, and predict the sign
   relation between `DET` and the `LU` diagonal's product before pressing
   either key.
