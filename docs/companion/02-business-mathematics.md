# Chapter 2: Explorations in business mathematics

Business mathematics runs on a few small machines: linear systems that
turn receipts into price lists, inequalities that turn scarce resources
into best plans, exponentials that turn interest rates into balances, and
transition tables that turn this week's customers into next year's market
shares. Free85 has a tool for each, and this chapter visits them in turn:
the simultaneous editor, the graph screen, the matrix editor's row
operations, the solver workspace, and matrix multiplication. Chapter 1
(Explorations in precalculus) ended section 1.4 with money growing at six
percent; this chapter picks that thread up and follows it. Every key
sequence and every quoted number in this chapter was run in the emulator
on a fresh machine, and each exploration ends with a "Try it" block whose
answers stay on the calculator.

## 2.1 Prices from receipts

A receipt is a linear equation. Two coffees and five pastries for 7.90
says 2c + 5p = 7.9, and one more receipt with different quantities pins
both prices down. Recovering a price list from receipts is solving a
linear system, and Free85 keeps a dedicated editor for exactly that.

1. Press [2nd] [STAT] (the `SIMULT` legend) to open the simultaneous
   editor, described in full in the Guidebook, chapter 14. A fresh
   machine shows `SIZE 2`, two equations in two unknowns. Each row takes
   its coefficients left to right and then its right-hand side, so the
   morning's two receipts, 2 coffees and 5 pastries for 7.90, then 4
   coffees and 5 pastries for 12.30, are typed as [2] [ENTER] [5]
   [ENTER] [7] [.] [9] [ENTER] [4] [ENTER] [5] [ENTER] [1] [2] [.] [3]
   [ENTER].

2. Press [F1], the `SOLVE` key. The result screen answers
   `UNIQUE SOLUTION` with `X 2.2` and `Y 0.7`: coffee is 2.20 and a
   pastry 0.70. The second receipt doubled the coffees but kept the
   pastries, which is what made the system solvable at a glance: the
   difference of the receipts is two coffees for 4.40.

3. Three unknowns work the same way. A tea merchant blends three leaves
   costing 12, 9, and 6 per kilogram into a 10 kilogram batch worth
   84, with twice as much of the cheapest leaf as the dearest. The first
   two conditions are equations already; the proportion becomes one by
   writing z = 2x as -2x + 0y + z = 0. Press [EXIT] (the result screen
   answers only to it), then [2nd] [STAT] to reopen the editor, and
   press [F3] for `3X3`. Enter the three rows: 1, 1, 1, 10, then 12, 9,
   6, 84, then -2, 0, 1, 0, using [(-)] for the minus sign. `SOLVE`
   answers `X 2`, `Y 4`, and `Z 4`: two kilograms of the dear leaf and
   four of each of the others.

   ![The tea blend solved in three unknowns](images/co02-simult-blend.png)

4. Not every pair of receipts is bookkeeping in good order. Press
   [EXIT], reopen the editor, press [F2] for `2X2`, and enter 2, 1, 5,
   then 4, 2, 9: two coffees and a bun for 5.00, then exactly double the
   order for 9.00. `SOLVE` answers `NO SOLUTION`. No price list can
   explain those two receipts, because doubling an order must double its
   price, and the machine has spotted the discrepancy.

5. Now repair the till roll. Reopen the editor and step to the last
   cell: the cells keep their values, and five presses of [▼] bring the
   selection to row 2's right-hand side, still holding `9`. (The `CELL`
   line's first figure is the row you are in; its second always reads
   `3` in this release, so keep count as you step.) Type [1] [0]
   [ENTER], and `SOLVE` now answers `UNDERDETERMINED`: with the second
   receipt exactly double the first, every price list that explains one
   explains both, and a single figure on the till roll separated
   impossible from unhelpfully many.

The editor reaches `4X4`, four equations in four unknowns, through [F4]
or the [+] key; that ceiling, and the way the two degenerate verdicts
mirror the matrix editor's `SINGULAR MATRIX` guard, are in the
Guidebook, chapter 14.

**Try it.**

1. A juice stand's till roll shows 3 juices and 2 flapjacks for 12.30,
   then 2 juices and 3 flapjacks for 10.70. Price both items.
2. The tea merchant scales up: a 12 kilogram batch worth 105, still
   with twice as much of the cheapest leaf as the dearest. Re-solve, and
   check the answer's cost by hand on the home screen.
3. Invent two receipts of your own that no price list can explain, and
   two that infinitely many price lists explain, and check that the
   machine names each verdict correctly.

## 2.2 The best plan on a graph

A joinery makes bookcases and benches. A bookcase uses one sheet of
timber and three workshop hours; a bench uses two sheets and two hours;
the week holds 16 sheets and 24 hours. With x bookcases and y benches,
the constraints are x + 2y at most 16 and 3x + 2y at most 24, and the
profit to maximise is 30x + 40y. The feasible plans fill a region of the
plane, the best plan sits at a corner of it, and the graph screen can
find every corner.

1. Solve each constraint's boundary for y and store the lines: type
   [(] [1] [6] [-] [x-VAR] [)] [/] [2] and press [GRAPH] to put
   `(16-X)/2`, the timber line, in `Y1`; then press [2nd] [2] on the
   graph screen, type `(24-3*X)/2`, the labour line, and press [GRAPH].
   In the standard window the feasible region is the four-sided patch
   above both axes and below both lines.

2. One corner is where labour runs out along the bottom edge. Press
   [F1], the root key: it reads the active slot, the labour line stored
   last, and answers `= 8` with `R=0`. The corner is (8, 0), eight
   bookcases and no benches.

3. Two more corners hide in the table. Press [EXIT], then [GRAPH] to
   redraw the plot, then [MORE] for the table. The `X=0` row reads `8`
   and `12` under `Y1` and `Y2`: the two intercepts, of which only the
   lower is feasible, the corner (0, 8). And the `X=4` row reads `6`
   and `6`, the two lines agreeing, which is the remaining corner caught
   red-handed. [EXIT] returns to the plot.

4. Ask for that crossing properly. Press [▶] twenty-five times, taking
   the trace to `X=4.015748031496` with `Y=5.976377952756` on the
   labour line, and press [2nd] [F1], the intersection search of the
   Guidebook, chapter 4. It answers `= 3.9999999999999` with `R=5E-13`,
   the corner's x under a grain of dust. Its height is the timber line
   there: press [CLEAR], type `(16-4)/2`, and [ENTER] answers `= 6`.
   The crossing corner is (4, 6).

5. The profit has lines of its own. Every plan earning 240 sits on
   30x + 40y = 240, which solves to `(240-30*X)/40`. Press [CLEAR],
   then [GRAPH] to return to the plot, then [2nd] [3], type the line,
   and press [GRAPH]: it cuts straight through the middle of the
   region, so plenty of feasible plans earn 240. Now press [2nd] [3],
   [CLEAR], type `(360-30*X)/40`, and press [GRAPH]: the 360 line
   settles onto the region's outermost corner, touching it at (4, 6)
   alone. Sliding the profit line out until it last touches the region
   is the whole of linear programming in one picture.

   ![The 360 profit line resting on the corner](images/co02-lp-profit.png)

6. The corners settle it numerically. Press [EXIT] for the home screen
   and evaluate the profit at each corner with stored letters: [4]
   [STO▶] [ALPHA] [A] [ENTER], [CLEAR], [6] [STO▶] [ALPHA] [B]
   [ENTER], [CLEAR], then `30*A+40*B` and [ENTER], which answers
   `= 360`. Store 0 and 8 the same way and replay the profit entry with
   three presses of [2nd] [ENTER] (the entry recall of the Guidebook,
   chapter 1) and [ENTER]: `= 320`. Store 8 and 0 and recall again:
   `= 240`. The best week is four bookcases and six benches for 360.

The intersection key reads slots `Y1` and `Y2` only, so the pair of
lines you ask about must live in those two slots; the third slot is
where the profit line visits without disturbing the question. Three
slots also bound the constraints a single plot can carry: a fourth
constraint means swapping a line in and out, or testing its corner
candidates on the home screen as in step 6.

**Try it.**

1. Prices shift: the profit moves to 60 per bookcase and 30 per bench.
   Evaluate the corners again with stored letters. Which corner wins
   now, and what does that say about the shape of the profit line?
2. A delivery contract caps benches at five a week. Put `5` in `Y3`,
   find the new corner where the cap meets the timber line, and notice
   that the best corner of the smaller region no longer has whole
   coordinates. What whole-number plans deserve a check?
3. Design a third resource of your own (glue, varnish, van hours) whose
   boundary line passes exactly through (4, 6), and show that adding it
   leaves the best plan unchanged.

## 2.3 Elimination as bookkeeping

Section 2.1's `SOLVE` answers in one press, which is convenient and
opaque. The matrix editor's row operations let you watch the same
arithmetic done slowly, receipt by receipt, the way a clerk would
cross-check a ledger. A picture framer sells prints and frames: two
prints and a frame for 110, one print and three frames for 130. As a
tableau, coefficients beside takings, that is a 2 by 3 matrix, and it
fits the matrix editor exactly.

1. Press [2nd] [7] (the `MATRX` legend) for the matrix editor of the
   Guidebook, chapter 13, then [x-VAR] [+] to grow the columns:
   `SIZE 2X3`. Type the tableau row by row, [2] [ENTER] [1] [ENTER]
   [1] [1] [0] [ENTER] [1] [ENTER] [3] [ENTER] [1] [3] [0] [ENTER],
   and the entry wraps back to `CELL 1 1`, leaving row 1 selected.

2. Press [MORE] [MORE] for the row-operation page `REF SWAP RADD RMUL`
   (its fifth name overruns the screen). Elimination is easiest when
   the pivot is a 1, and the second receipt starts with one: press
   [F2], `SWAP`. The banner's register letter changes to `R`, where
   every result lands, and stepping through with [▶] reads `1`, `3`,
   `130`, `2`, `1`, `110`: the receipts in the friendlier order.

3. The row operations read register `A`, so the result must be carried
   forward by hand. The fifth [▶] left the selection at `CELL 2 3`;
   one more wraps it home to `CELL 1 1`. Press [ALPHA] twice, cycling
   the view from `R` through `B` back to `A`, and retype the six
   values in their new order: 1, 3, 130, 2, 1, 110. This copying is
   the price of watching each move separately, and the editor keeps
   the original safe in `R` until the next operation overwrites it.

4. Now the clerk's move: subtract twice receipt 1 from receipt 2. The
   scale rides in `B`'s top-left cell, so press [ALPHA] to show `B`,
   type [(-)] [2] [ENTER], and press [ALPHA] again to return to `A`,
   where the trip has stepped the selection to `CELL 1 2`. Press [▼]
   three times to reach `CELL 2 2`, any cell of row 2, and press
   [F3], `RADD`: the selected row gains the scale times the following
   row, wrapping to row 1. Stepping through `R` reads `1`, `3`, `130`,
   `0`, `-5`, `-150`: the prints have cancelled out of the second row,
   which now says that minus five frames cost minus 150.

5. Tidy the pivot. Wrap the selection home, press [ALPHA] twice, and
   retype 1, 3, 130, 0, -5, -150 into `A`. Store the scale -0.2, the
   reciprocal of -5, in `B`'s top-left cell as before, return to `A`,
   press [▼] three times for row 2, and press [F4], `RMUL`: row 2 of
   `R` becomes `0`, `1`, `30`. One frame costs 30.

6. One move remains: clear the frames out of receipt 1. Carry the
   result forward once more, store the scale -3 in `B`, and return to
   `A`, where the selection already sits in row 1 at `CELL 1 2`. Press
   [F3], `RADD`, and `R` reads `1`, `0`, `40`, `0`, `1`, `30`: a print
   is 40 and a frame is 30, each row of the finished tableau naming
   one price.

   ![The finished tableau naming the prices](images/co02-tableau-solved.png)

7. The machine will also do the whole dance in one key. Retype the
   original tableau, 2, 1, 110, 1, 3, 130, into `A`, press [EXIT] and
   [2nd] [7] to bring back the first soft-key page, and press [F5],
   `RREF`: the same `1`, `0`, `40`, `0`, `1`, `30` in one step, the
   Guidebook, chapter 13's reduced row-echelon form doing steps 2
   through 6 unwatched.

The tableau register is the design to work within: a matrix holds at
most `SIZE 3X3`, so a two-unknown system's 2 by 3 tableau fits, but a
three-unknown system needs 3 by 4, which does not. Three unknowns and
their takings belong to the simultaneous editor of section 2.1, or to
the matrix editor's `SOLVE` key, which reads the coefficients from `A`
and the right-hand sides from `B`'s first column.

**Try it.**

1. Rework the café receipts of section 2.1 as a tableau: 2, 5, 7.9 and
   4, 5, 12.3. No swap is needed; four row operations reach the
   identity. Which scales do you store along the way?
2. The `AUG` key on the same page appends `B`'s columns to `A`. Build
   the framer's tableau a second way: coefficients in a 2 by 2 `A`,
   takings in a 2 by 1 `B`, then `AUG`. Where does the result land,
   and what must you do before row operations can touch it?
3. Swap the rows of the finished tableau, 0, 1, 30 above 1, 0, 40, and
   run `RREF` on it. Why does the answer come back with the print row
   on top?

## 2.4 The mathematics of money

Section 1.4 left money compounding through `EXP(` and `LN(`, because
`^` takes whole exponents from -9 to 9 only and the identity b to the
x equals e to the x ln b carries the fractional cases. The solver
workspace turns that identity from a formula you evaluate into an
equation you can interrogate from any side: the same line answers what
rate, how long, and how much, depending only on which letter you name
as the unknown.

1. First the reconciliation. On the home screen, `500*EXP(8*LN(1.06))`
   (with `EXP(` on [2nd] [LN] and `LN(` on [LN]) answers
   `= 796.92403726725`, exactly the figure section 1.4 promised for
   500 invested at six percent for eight years.

2. Now the general equation. The solver hunts for a zero, so write the
   savings story as a difference: growth minus balance. Store the
   knowns first, [8] [STO▶] [ALPHA] [Y] [ENTER] for the years, then
   [CLEAR] and `900->Z` for a target balance. Type
   `500*EXP(Y*LN(1+X))-Z` and press [2nd] [GRAPH]: the `SOLVER`
   workspace of the Guidebook, chapter 14 opens with the equation
   stored (the `F=` line clips at the screen's right edge; the tail is
   kept), and `VAR X` names the unknown: the rate.

3. What rate turns 500 into 900 in eight years? Rates live between
   zero and one, so fence the search: press [F5], the `>` key, three
   times to reach the `LOWER` page, and store `0` and then `1`. Press
   [F1], `SOLV`, and after a moment the field area answers a `ROOT` of
   `0.07623983640223` with `RES 5.327E-7`: a little over 7.6 percent,
   with the residual line reporting how nearly the equation balances
   there.

4. How long to double money at six percent? Press [EXIT], [CLEAR],
   store `.06->X` and `1000->Z`, and press [2nd] [GRAPH] with the
   entry line empty: the workspace reopens with everything kept. Press
   [F3], `VAR`, once, turning `VAR X` into `VAR Y`, page to the
   bounds, and store `0` and `50`. `SOLV` answers a `ROOT` of
   `11.895661056043`: money at six percent doubles in just under
   twelve years, whatever the starting sum.

5. And the balance itself? Store `8->Y` again, reopen the workspace,
   press `VAR` once more for `VAR Z`, set the bounds to `0` and
   `1000`, and `SOLV` answers a `ROOT` of `796.9240378587` with
   `RES -5.9145E-7`. Compare step 1: the workspace bisects until the
   residual passes the `1E-6` tolerance, so its root carries the home
   screen's exact figure to within a millionth, and the `RES` line names
   that gap.

6. Loans are the same equation read in reverse: the debt grows while
   payments shrink it. For 10000 borrowed at one percent a month with
   payment A over B months, store `24->B`, type
   `10000*EXP(B*LN(1.01))-A*(EXP(B*LN(1.01))-1)/.01`, and press
   [2nd] [GRAPH]. Press `VAR` once for `VAR A`, and try the bounds a
   hopeful borrower would: `0` and `300`. `SOLV` stops at the
   `NO BOUNDED ROOT` notice: no payment up to 300 clears this loan in
   24 months. That screen is an answer, not a failure.

   ![No payment under 300 clears the loan](images/co02-solver-no-root.png)

7. Press [CLEAR] (the notice dismisses to the home screen with the
   workspace kept), reopen with [2nd] [GRAPH], page to `UPPER`, and
   raise it to `1000`. `SOLV` answers a `ROOT` of `470.73472221384`:
   the true monthly payment.

   ![The loan payment found by the solver](images/co02-solver-payment.png)

8. If 300 a month is all there is, ask for the term instead. Press
   [EXIT], [CLEAR], store `300->A`, reopen, press `VAR` once for
   `VAR B`, page to `UPPER`, store `100`, and `SOLV` answers a `ROOT`
   of `40.748907154197`: nearly 41 months, the price of the smaller
   payment. Then store `100->A`, exactly the monthly interest on
   10000, reopen, and `SOLV`: `NO BOUNDED ROOT` again, because a
   payment that only covers the interest never ends the loan, and no
   term between the bounds can make the equation balance.

One design habit makes the workspace pleasant: `VAR` steps forward
through the alphabet, one letter per press, wrapping from `Z` to `A`.
Equations whose letters march forward, `X`, `Y`, `Z` for the savings
account, then `A` and `B` for the loan, keep every change of unknown
to a single press.

**Try it.**

1. How long does money take to treble at six percent? Store the target
   in `Z`, widen the bounds if you must, and compare the answer with
   `LN(3)/LN(1.06)` on the home screen.
2. A car loan of 8000 at 0.8 percent a month runs for 36 months. Adapt
   the loan equation, mind which letters you reuse, and find the
   payment.
3. Store the exact payment from step 7 into `A` and solve for the term
   `B`. How close to 24 does the root come, and what does the residual
   line say about the last penny?

## 2.5 Loyalty in the long run

Three coffee shops share a harbour town: the Harbour, the Mill, and
the Station. Each Saturday, 80 percent of the Harbour's customers
return and ten percent defect to each rival; the Mill keeps 70
percent, losing 20 to the Harbour and 10 to the Station; the Station
keeps 60, losing 20 to each. A table of switching fractions is a
transition matrix, its powers are forecasts, and the matrix editor can
raise them and find where the switching settles.

1. Press [2nd] [7], then [+] [x-VAR] [+] [x-VAR] to reach `SIZE 3X3`,
   and type the matrix row by row, one row per shop: .8, .1, .1, then
   .2, .7, .1, then .2, .2, .6. Each row lists where one shop's
   customers stand next Saturday, and each row sums to one, because
   customers go somewhere.

2. The editor's `MUL` multiplies `A` by `B`, so the square of P needs
   P in both. Press [ALPHA] for `B`, grow it to `SIZE 3X3` the same
   way, retype the nine values, and press [ALPHA] to return to `A`.

3. Press [MORE] [F3], `MUL`, and give the 3 by 3 product a moment.
   The banner switches to `R` holding the two-week forecast: the
   selection sits at `CELL 1 1` reading `0.68`, and stepping right
   reads `0.17` and `0.15` across row 1. Two Saturdays out, a Harbour
   regular is at the Harbour with probability 0.68: the 0.8 loyalty
   has already eroded.

4. Forecasts further out are more of the same. Step through the rest
   of `R` (row 3 ends at `0.4` in `CELL 3 3`), press [▶] once more to
   wrap home, then [ALPHA] twice to return to `A`, and retype the
   nine two-week values: .68, .17, .15, .32, .53, .15, .32, .28, .4.
   `MUL` again answers three weeks, row 1 reading `0.608`, `0.217`,
   `0.175`. Carry that forward the same way and `MUL` once more: four
   weeks out, the first column reads `0.5648`, `0.4352`, `0.4352`
   down the three rows, and row 3 ends at `0.25`. The rows are
   converging on one another: where a customer started is washing out
   of the forecast.

5. Where is it all heading? A share-out that no Saturday changes
   satisfies a linear system built from the columns of P (the flows
   into each shop) minus one on the diagonal. Retype `A` as that
   matrix: -.2, .2, .2, then .1, -.3, .2, then .1, .1, -.4. Press
   [EXIT] and [2nd] [7] to bring back the first soft-key page, and
   press [F5], `RREF`. Stepping through `R` reads `1`, `0`, `-2.5`,
   then `0`, `1`, `-1.5`, then a row of zeros: the shares stand in
   proportion 2.5 to 1.5 to 1, and dividing by their sum, 5, gives
   0.5, 0.3, and 0.2.

   ![The steady-state proportions in register R](images/co02-markov-steady.png)

6. The claim deserves its own check. Wrap the selection home, press
   [ALPHA] twice for `A`, and press [-] twice: `SIZE 1X3`, a single
   row. Type .5, .3, .2, and press [MORE] [F3]: `B` still holds P,
   and the product of a share-out with the transition matrix is next
   Saturday's share-out. `R` answers `SIZE 1X3` reading `0.5`, `0.3`,
   `0.2`, unchanged to the last digit. Half the town ends at the
   Harbour, three tenths at the Mill, a fifth at the Station, and no
   further Saturday moves the needle.

Every result landing in `R` is the register design of the Guidebook,
chapter 13, and the copying forward in steps 4 and 5 is the honest
cost of iterating inside one editor; a fourth power arrives in three
multiplications and four retypings. The reward is that nothing is
hidden: every forecast you quote is one you watched being made.

**Try it.**

1. Start the whole town at the Station: a `SIZE 1X3` row holding 0, 0,
   1 in `A`, with P in `B`. Multiply repeatedly, carrying each result
   back into `A`. After how many Saturdays does the Harbour's share
   first pass 0.45?
2. The `TRN` key transposes `A` into `R`. Rebuild step 5 without
   arithmetic on paper: transpose P, carry it to `A`, put an identity
   in `B`, and subtract with `SUB` before `RREF`. Which registers did
   the answer pass through?
3. The Station renovates and its loyalty rises to 0.8, losing 0.1 to
   each rival. Rebuild the steady state. Does the smallest shop's new
   loyalty reorder the long-run shares?
