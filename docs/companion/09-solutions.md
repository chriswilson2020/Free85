# Chapter 9: Solutions

Every Try it exercise in the book, worked through.

Where an exercise asks you to predict something first, the solution says
what the right prediction was and, more usefully, what makes it right. Where
it asks you to press keys, the keys and the numbers that come back are
here. Where the interesting part of an exercise turned out to be somewhere
other than the question, the solution says so and goes there.

A word on the numbers. Every one below came off the emulator, so if yours
differ in the last digit or two, check the angle mode first and the stored
equation second: those two account for almost every discrepancy. A
difference in the last digit alone is usually just a different route to the
same answer, as section 3.6 found.

## 9.1 Solutions for Chapter 1

### 1.1 Functions and their windows

**1.** The three crossings of `X^3-4*X` and `X` are where x cubed minus
four x equals x, so x cubed equals five x, so x is 0 or plus or minus the
square root of five.

Section 1.1 found the negative one at `= -2.2360679774997`. For the other
two, trace to the neighbourhood first: the search reads the traced position,
so trace near the origin and press [2nd] [F1] for `= 0`, then trace right of
2 and press [2nd] [F1] again for the positive root.

Check it: press [CLEAR] and type [2nd] [x²] [5] [)] for `SQRT(5)`:
`= 2.2360679774998`.

Notice the last digit. The intersection search answered `2.2360679774997`
and the square root answers `...98`. Neither is wrong; the search stops when
its bracket is tight, and the root is computed. Section 4.4 has more on why
searches stop where they do.

**2.** `X^3-4*X+3` factors as (x - 1)(x² + x - 3), so its zeros are 1 and
the two roots of x² + x - 3, which are about 1.303 and -2.303.

The zero at 1 is the one you could have read from the table, because the
table steps in whole numbers by default and lands exactly on it. The other
two fall between rows and need the search.

That is worth generalising: the table finds a zero only when it happens to
step on one, so a zero at a whole number is visible and a zero anywhere else
is not.

**3.** Near the origin the cube term is negligible against the linear one,
so `X^3-4*X` behaves like `-4*X`. The curve comes to resemble the line
y = -4x.

Reading `XMIN` after each press of [+], from the standard window: `-5`,
`-2.5`, `-1.25`, `-0.625`, `-0.3125`. Each press halves it, as section 1.1
said.

By four or five presses the curve is straight to the eye. Check the slope
while you are there: trace two columns from the origin and divide the `Y=`
readout by the `X=` readout, and you should get something very close to -4.

**4.** For one zero, zoom in until only the origin is in view: three or four
presses of [+] leaves the window at -1.25 to 1.25, which contains only the
zero at 0. For none, trace away from the origin first and then zoom, or use
a window that sits entirely to the right of 2.

Neither window is lying. Each is answering the question "what does this
function do *here*", and the answer genuinely is "it has one zero" or "it
has none" on that interval. The mistake is only ever in reading a local
answer as a global one, which is the whole reason section 1.1 comes first.

### 1.2 Families of curves three at a time

**1.** All three lines have slope 1, so they are parallel. They cross the y
axis at 4, 0 and -3, which are the constants themselves.

The table makes it plain: at `X=0` the row reads `4`, `0`, `-3`. Adding a
constant to a function moves its graph vertically by that constant, which is
section 1.3's rule arriving early.

**2.** Store `X^2` in `Y1`, `-X^2` in `Y2` and `-4*X^2` in `Y3`, using
[(-)] for the signs.

The negative members open downwards. In the table the `X=2` row reads `4`,
`-4`, `-16`: the sign of a flips the bowl, and the size of a decides how
narrow it is. The two effects are independent, which is why one family can
show both.

**3.** `(X+2)^2-5` has its vertex where the bracket vanishes, at x = -2, and
its value there is -5.

Confirm with the table: the `X=-2` row reads `-5`, and the rows either side
read `-4`, so the curve is symmetric about -2 and turns there.

For a vertex at (1, 7) the slot text is `(X-1)^2+7`. Test it the same way:
the `X=1` row should read `7` with `8` either side. Mind the sign inside the
bracket, which is the part everybody gets backwards once.

**4.** Any five-member family works. The point of the exercise is the
choice of anchor, and the answer is that the anchor should be the member you
most want the others measured against, usually the middle one or the
simplest one.

For `X^2/4`, `X^2/2`, `X^2`, `2*X^2`, `4*X^2`, keep `X^2` in both plots. It
is the one whose shape you already know, so both pictures are read against
the same reference, and the two halves of the family can be compared even
though they were never on screen together.

Choose a different anchor and the two plots have nothing in common, which
makes them two experiments rather than one.

### 1.3 Symmetry and transformations

**1.** `X^2-6` is even: replacing x by -x changes nothing, because the
square kills the sign. `X^3+1` is neither: f(-x) is -x³ + 1, which is
neither f(x) nor -f(x).

On screen, the even test shows two curves rather than three, because `Y1`
and `Y2` coincide. The neither test shows all three curves separately.

In the table, evenness is `Y1` and `Y2` agreeing down every row; oddness is
`Y2` and `Y3` agreeing; neither is no two columns agreeing anywhere. Reading
*which* pair matched is the skill, not just noticing that something did.

**2.** They give the same picture because `2*ABS(X)` and `ABS(2*X)` are the
same function: the absolute value of 2x is twice the absolute value of x.

The table confirms it, both columns reading `0`, `2`, `4`, `6` at `X` = 0,
1, 2, 3.

They differ for any function that is not homogeneous of degree one. Try
`2*X^2` against `(2*X)^2`: the first doubles heights, the second quadruples
them, and the table separates them at once.

**3.** Anything with a small odd part added to a large even part will do.
`X^2+X/100` looks symmetric in the standard window, because the `X/100`
contributes at most a tenth over the visible range and the plot cannot
resolve it.

The table exposes it immediately: at `X=5` the value is `25.05` and at
`X=-5` it is `24.95`. The picture cannot show a twentieth of a unit; the
table can show fourteen digits.

**4.** Yes, and exactly one: the zero function. Even means f(-x) = f(x) and
odd means f(-x) = -f(x). Both together give f(x) = -f(x), so 2f(x) = 0, so
f is zero everywhere.

Store `0*X` in all three slots and the three-slot test shows a single line
along the axis, with the table reading `0` across every row. It is a
degenerate answer and it is the only one, which is what makes the question
worth asking.

### 1.4 Rational functions and the lines they approach

**1.** `(X^2-4)/(X-2)` divides out exactly: it is (x - 2)(x + 2) over
(x - 2), which is x + 2 for every x except 2.

The table reads `UNDEF` at `X=2`, exactly as the pole did. But this is a
completely different situation. Probe either side and you see it: with the
equation stored, `EVAL(1.9)` answers `= 3.9` and `EVAL(2.1)` answers
`= 4.1`, and `EVAL(2)` stops at `SYNTAX ERROR`.

The values from both sides are heading for 4, which is what x + 2 gives at
x = 2. The function has a *hole*, not a pole: one point missing from an
otherwise perfectly ordinary line. Chapter 4's `SIN(X)/X` is the same shape
of trouble.

So `UNDEF` in a table means only that the machine could not compute a value.
The neighbouring rows tell you which kind of nothing you are looking at.

**2.** Dividing 2x² - x + 3 by x + 1 gives 2x - 3 with a remainder of 6, so
the function is 2x - 3 plus 6/(x + 1), and the slant asymptote is
y = 2x - 3.

Put `(2*X^2-X+3)/(X+1)` in `Y1` and `2*X-3` in `Y2`. At `X=10` the formula
predicts a gap of 6/11.

Check all three: press [CLEAR] and spell `EVAL(10)`: `= 17.545454545455`.
Press [CLEAR] and type `2*10-3`: `= 17`. Press [CLEAR] and type `6/11`:
`= 0.54545454545455`.

17 plus 0.5454... is 17.5454..., to every digit. The division was right.

**3.** The gap between `(X^2+1)/(X-1)` and its asymptote is 2/(x - 1),
which is never zero for any finite x, because 2 is not zero. So the curve
approaches the line and never meets it.

To make one that *does* cross, you need a remainder that changes sign, which
means a remainder with a zero in it. `(X^3+1)/X^2` is x plus 1/x², whose
remainder never changes sign either; better is `(X^3-X)/(X^2+1)`, which is
x minus 2x/(x² + 1). That remainder is zero at x = 0, so the curve crosses
its asymptote y = x at the origin. Plot both and look.

Crossing an asymptote is not misbehaviour. An asymptote says where a curve
*ends up*, not where it is forbidden to go.

**4.** `(X^2+1)/(X^2-1)` is 1 plus 2/(x² - 1), so its horizontal asymptote
is y = 1 and the gap is 2/(x² - 1). For that to be under a thousandth you
need x² - 1 above 2000, so x² above 2001, so x above 44.73.

Check both sides of the boundary. Press [CLEAR] and spell `EVAL(44.73)`:
`= 1.0010001135629`, a gap of 0.0010001, just over. Press [CLEAR] and spell
`EVAL(45)`: `= 1.0009881422925`, a gap of 0.00098814, just under.

And press [CLEAR] and type `2/(45^2-1)`: `= 0.00098814229249012`, which is
the gap the algebra predicted, to eleven digits.

That is a much faster convergence than section 1.4's slant case, where the
gap was 2/(x - 1) and you had to go out to 2001. Squaring the denominator
squares how quickly the curve settles.

### 1.5 Exponential and logarithmic functions

**1.** The mirror symmetry is still true and stops *looking* true. `EXP(X)`
and `LN(X)` are reflections of each other in y = x whatever window you use,
but a reflection in a forty-five degree line only looks like one when the
two axes are drawn at the same scale.

The standard window is wider than it is tall in real distance on the screen,
so the line y = x does not sit at forty-five degrees, and the reflection is
sheared with it. The window carries the blame because the mathematics has
not changed at all: only the drawing has.

**2.** Base two passes 8 at x = 3, because 2 cubed is 8. Predict that from
the powers of two rather than from the plot.

Check it: press [CLEAR] and spell `LN(8)/LN(2)`: `= 2.9999999999965`. With
`EXP(X*LN(2))` stored and the plot allowed to finish, press [CLEAR] and
spell `EVAL(3)`: `= 8.0000000000261`.

Both answers carry dust in the last digits, and from opposite directions.
That is two logarithms and an exponential each rounded to fourteen places;
the mathematics is exact and the arithmetic is not.

**3.** Halving every unit means a base of a half, so the slot text is
`EXP(X*LN(.5))`.

After five units, a half to the fifth is one thirty-second. Press [CLEAR]
and spell `EVAL(5)`: `= 0.031250000000139`. Press [CLEAR] and type `1/32`:
`= 0.03125`.

The read from the table agrees to four decimals in its five-character cell.

**4.** Press [CLEAR] and type `1.06^9`: `= 1.6894789590028`. Press [CLEAR]
and spell `EXP(9*LN(1.06))`: `= 1.6894789590072`.

They agree to eleven digits and differ in the last three.

Trust the power key. It is nine exact multiplications of a stored number,
and the only error is the rounding at each step. The identity route takes a
logarithm, multiplies, and takes an exponential, each of which rounds, and
the exponential magnifies whatever error the logarithm made.

The identity is not less accurate because it is cleverer. It is less
accurate because it goes the long way round, and it exists for the cases
where the short way is not available at all.

**5.** `1.06^-3` works and answers `= 0.8396192830323`, because -3 is a
whole number inside the range -9 to 9.

`1.06^10` fails, because 10 is a whole number *outside* it. The counter in
the multiply loop is one packed-decimal digit and a one-digit counter counts
to nine.

So the limit is not about fractions, as the section's `1.06^2.5` might
suggest. It is about the size of the exponent as well, and both come from
the same digit. For 10 you want `EXP(10*LN(1.06))`.

### 1.6 Trigonometric functions

**1.** `SIN(X)+2` lifts the whole wave two units, keeping its shape.
`SIN(X+2)` slides it two units to the *left*, keeping its height. The first
is a change outside the sine, the second is inside it, which is section
1.3's rule again.

The table settles it: at `X=0` the three columns read `0`, `2` and `0.909`.
The second is 2 above the first. The third is the value the plain sine has
at x = 2, arriving two units early.

**2.** In `DEG` mode a full wave is 360 degrees wide, so you need `XMAX` of
at least 180 to fit a half-wave either side of the origin, and 360 to be
comfortable.

Pressing [-] from the standard window doubles the bounds each time, so
`XMAX` reads 20, 40, 80, 160, 320, 640. The first window wide enough for a
whole period is the one at 320, since the visible range is then -320 to 320,
which is 640 degrees.

You could have predicted it: 360 lies between 160 and 320, so it is the
sixth press. Doubling gets you anywhere quickly and never lands where you
would have chosen.

**3.** A one-hour swing gives `1*SIN(PI*X/6)`, or just `SIN(PI*X/6)`.

The standard window hides it almost entirely: the curve never leaves -1 to
1 while the window allows for -10 to 10, so it is a flat ripple on the axis.
It is section 1.6's opening complaint all over again, and the fix is the
same: zoom in vertically until the wave fills the screen.

What the standard window hides is not the shape but the *scale*. Both towns
have a sine of period twelve months. Only the amplitude differs, and
amplitude is exactly what a badly chosen vertical range destroys.

**4.** Sine is 0, 1, 0, -1 at x = 0, π/2, π and 3π/2. Cosine at those four
places is 1, 0, -1, 0: it does the same thing a quarter turn earlier, which
is what section 1.6 step 4 showed.

Check them. Press [CLEAR] and spell `COS(0)`: `= 1`. Then `COS(PI/2)`:
`= -6.51527649229E-11`. Then `COS(PI)`: `= -1.0000041678092`. Then
`COS(3*PI/2)`: `= -6.51527649229E-11`.

The last three are 0, -1 and 0 under the machine's fourteen-digit `PI`,
which is not quite pi. Read `-6.5E-11` as zero and `-1.0000042` as minus
one. That dust appears in section 5.4's cardioid too, and it is worth
learning to recognise rather than chase.

**5.** Six hours thirteen minutes is 6.2166666666666 hours. A sine repeats
every 2 pi, so you want the bracket to reach 2 pi when x reaches the period:
the model is `SIN(2*PI*X/6.2167)`, or equivalently `SIN(1.0107*X)` since
press [CLEAR] and spelling `2*PI/(6+13/60)` answers `= 1.0107000494123`.

Two days is 48 hours, which is a little under eight periods. The standard
window's -10 to 10 shows barely three, so you want a window several times
wider in x and much narrower in y. Press [-] twice for x and zoom in
vertically, or accept the trig window and read only part of the picture.

### 1.7 Inverse functions by parametric pair

**1.** The inverse crosses the x axis where the original crossed the *y*
axis, because the coordinates have been swapped. The original line 2t - 6
crosses the y axis at -6, so the inverse crosses the x axis at -6.

Store `2*X-6` in slot 1 and `X` in slot 2 for the inverse pair, plot it, and
trace to where the `Y=` readout passes through zero: the `X=` readout there
is -6.

That is the whole content of "swap the coordinates", and it is worth
checking on a line before trusting it on a curve.

**2.** They must agree because the exponential and the logarithm *are*
inverses. Drawing `EXP(t)`, `t` as a parametric pair plots the points
(e^t, t), and the graph of `LN(x)` is the set of points (x, ln x). Put
x = e^t and ln x = t and those are the same points.

The two pictures are the same curve computed two different ways, so any
disagreement between them would be an arithmetic error rather than a
mathematical one.

**3.** The pair `X^2`, `X` plots the points (t², t), which is a sideways
parabola: two y values for most x, and therefore not a function.

A function slot computes y from x and can only ever produce one y per x. The
parametric sweep does not: it walks t from `XMIN` to `XMAX` and puts a point
wherever the pair says, with no rule against visiting the same x twice. That
is exactly the freedom that lets it draw an inverse.

Trace it and watch the `X=` readout come *down* to zero and go back up while
the `Y=` readout climbs steadily. A function slot could never produce that
trace.

**4.** Any function that is its own inverse works, and there are more than
you would guess. Two of different shape:

The line y = x itself, trivially, and more interestingly y = -x, whose
swapped pair draws the same line. And the hyperbola y = 1/x: swapping gives
x = 1/y, which is the same relation.

`6-X` works too, and so does any line of slope -1. The general fact is that
a function is its own inverse exactly when its graph is symmetric about the
line y = x, which is a nice thing to be able to spot by eye.

## 9.2 Solutions for Chapter 2

### 2.1 Prices from receipts

**1.** Press [2nd] [STAT] and enter 3, 2, 12.3, then 2, 3, 10.7. `SOLVE`
answers `X 2.7` and `Y 2.1`: juices are 2.70 and flapjacks 2.10.

Check both receipts by hand, which is the habit worth keeping: three juices
and two flapjacks is 8.10 plus 4.20, which is 12.30. Two and three is 5.40
plus 6.30, which is 10.70. Both right.

**2.** Predict first. The batch is bigger and dearer per kilogram, 105 over
12 rather than 84 over 10, so 8.75 a kilogram against 8.40. You might
reasonably expect more of the dear leaf.

Enter 1, 1, 1, 12, then 12, 9, 6, 105, then -2, 0, 1, 0. `SOLVE` answers
`X 1`, `Y 9` and `Z 2`.

One kilogram of the dear leaf, not two. The proportions have not scaled at
all: the first batch was 2, 4, 4 and this one is 1, 9, 2. The mix has
swung almost entirely into the middle leaf.

If that surprises you, it should. The proportion condition z = 2x ties the
cheapest leaf to the dearest, so the only free direction left is the middle
one, and it absorbs the whole change. Two constraints and three unknowns
leave much less freedom than it looks.

**3.** For no solution, make the coefficients proportional but the takings
not: 2, 4, 10 then 1, 2, 6. Doubling the order must double the price and
here it does not, so `SOLVE` answers `NO SOLUTION`.

For infinitely many, make everything proportional: 2, 4, 10 then 1, 2, 5.
`SOLVE` answers `UNDERDETERMINED`.

The two are one keystroke apart, which is the point of section 2.1 step 5.

**4.** Any third receipt whose coefficients are a combination of the first
two but whose takings are not. The first two are 3, 2 and 2, 3; their sum
is 5, 5, and the takings should then be 12.30 plus 10.70, which is 23.00.
So the receipt 5, 5, 23 is consistent and 5, 5, 24 is not.

Grow the editor to `3X3` and enter all three: with 23 the answer is still
`X 2.7`, `Y 2.1`; with 24 it is `NO SOLUTION`. A third receipt cannot add
information, only agreement or contradiction.

### 2.2 When the answer will not stay still

**1.** Predict: the two lines are ten times closer to parallel, so the
trouble should be about ten times worse.

Enter 1, 2, 8, then 1.001, 2, 8.05. `SOLVE` answers `X 50` and `Y -21`.
Now nudge the 8 to 8.1: `X -50` and `Y 29.05`.

x has swung from plus fifty to minus fifty, where the 1.01 pair swung from
plus five to minus five. Ten times closer to parallel, ten times the
amplification, exactly as predicted. And note that the *unnudged* answer is
already absurd: minus twenty-one pastries.

**2.** Perpendicular means the coefficient vectors have zero dot product,
so take x + 2y = 8 with 2x - y = 1.

`SOLVE` answers `X 2` and `Y 3`. Nudge the 8 to 8.1 and it answers `X 2.02`
and `Y 3.04`.

A one and a quarter per cent change moved the answers by one and a half.
That is as good as it gets, and the moral for planning measurements is
direct: arrange your observations to be as unlike each other as possible.
Two nearly identical experiments tell you nearly nothing twice.

**3.** With the coefficient exactly 1 the two left-hand sides are
identical, so the equations read x + 2y = 8 and x + 2y = 8.05. Those
contradict each other, and `SOLVE` answers `NO SOLUTION`.

That is the honest end of the road. As the coefficient slides from 1.01 to
1.001 to 1, the answer runs off to infinity and then stops existing. The
ill-conditioned case is not a separate phenomenon from the impossible one;
it is the impossible one seen from very close up.

**4.** Nudge the batch value 84 by one per cent to 84.84 and re-solve.

The original answer was `X 2`, `Y 4`, `Z 4`. The nudged one is `X 1.72`,
`Y 4.84` and `Z 3.44`.

A one per cent change in one number has moved the dear leaf by fourteen per
cent and the middle leaf by twenty-one. So the tea blend is moderately
ill-conditioned too, amplifying by fifteen or twenty, which nobody would
have guessed from looking at it. Section 6.3 puts a number on that with
`COND`, and this system is worth running through it when you get there.

### 2.3 The best plan on a graph

**1.** Predict from the slope. The profit line 60x + 30y = k solves to
y = (k - 60x)/30, a slope of -2, which is steeper than either constraint
line. A steep profit line slides out to the corner furthest right.

Evaluate the corners: `60*4+30*6` answers `= 420`, `60*8+30*0` answers
`= 480`, and `60*0+30*8` answers `= 240`.

So (8, 0) wins with 480, where the old profit chose (4, 6). Making
bookcases twice as profitable as benches moves the whole plan to bookcases
only, and it is the *slope* of the profit line that decided it, not its
height.

**2.** Careful here, because the exercise points you at the wrong line.

The cap y = 5 meets the timber line x + 2y = 16 at x = 6, so (6, 5). But
check it against labour before you trust it: `3*6+2*5` answers `= 28`, and
only 24 hours exist. The point is not feasible.

The cap meets the *labour* line 3x + 2y = 24 at 3x = 14, so x = 14/3.
Press [CLEAR] and type `14/3`: `= 4.6666666666667`. Check timber there:
14/3 plus 10 is about 14.67, under 16, so this one is feasible.

Profit: press [CLEAR] and type `30*(14/3)+40*5`: `= 340`.

The whole-number plans worth checking are (4, 5) and (5, 5). Neither is the
rounded corner rounded blindly: (5, 5) needs 25 labour hours and fails, so
(4, 5) at 320 is the best whole plan. Integer answers are a genuinely
harder problem than the corner method solves, and this is the cheapest
possible demonstration of why.

**3.** Raise labour from 24 to 26 and re-solve the crossing: enter 1, 2, 16
then 3, 2, 26. `SOLVE` answers `X 5` and `Y 5.5`.

Profit there: `30*5+40*5.5` answers `= 370`, against 360 before. Ten pounds
for two extra hours, so an hour is worth 5.

Timber was worth 15 a sheet. So buy timber first, and it is not close.

**4.** As timber rises the best corner slides up the labour line towards
its y intercept, which is at y = 12. Getting there needs timber of
2 times 12, which is 24 sheets.

At 24 sheets the timber constraint passes exactly through the labour line's
intercept, and beyond that it is no longer binding: more timber buys
nothing and its shadow price drops to zero. Profit there is 40 times 12,
which is 480, and it stays 480 however much timber you buy.

**5.** Any line through (4, 6) works. Glue at 2 units a bookcase and 1 a
bench, with 14 pots a week, gives 2x + y = 14, which passes through (4, 6)
exactly.

Adding it leaves the best plan unchanged because it touches the region at
the corner that was already best and cuts nothing off. Its shadow price is
zero: raise the glue to 15 pots and re-solve, and the answer does not move,
because the constraint was never the thing holding you back.

A constraint that is satisfied exactly at the optimum but has zero shadow
price is called degenerate, and it is a genuinely awkward case in real
linear programming. You have just built one on purpose.

### 2.4 Elimination as bookkeeping

**1.** The tableau is 2, 5, 7.9 then 4, 5, 12.3, and no swap is needed
because the top-left is already nonzero.

The four scales are: -2 to clear the 4 below the pivot (row 2 becomes
0, -5, -3.5), then -0.2 to make that -5 into a 1 (row 2 becomes 0, 1, 0.7),
then -5 to clear the 5 above it, then 0.5 to turn the leading 2 into a 1.

The finished tableau reads 1, 0, 2.2 and 0, 1, 0.7: coffee 2.20, pastry
0.70, which is section 2.1's answer arrived at the slow way.

**2.** Put the coefficients 2, 1, 1, 3 in a 2 by 2 `A` and the takings 110,
130 in a 2 by 1 `B`, then press `AUG`.

The result lands in `R`, as every result does. Before row operations can
touch it you must carry it into `A` by hand, which is the same cost section
2.4 charges everywhere: the row-operation keys read `A` and nothing else.

**3.** Predict first: `RREF` sorts the rows into echelon form, and the row
starting with a 1 in the first column must end up on top. So the print row
comes back above the frame row whatever order you feed them in.

Enter 0, 1, 30 then 1, 0, 40 and press `RREF`: `R` reads `1`, `0`, `40`,
then `0`, `1`, `30`. The answer is unchanged and the rows have swapped
back.

**4.** From steps 2 to 6 the framer's 2 by 3 tableau took one swap and
three row operations, each of which touches three cells: about a dozen cell
updates.

A 3 by 4 tableau needs to clear two entries below the first pivot, then one
below the second, then two above, then three rescalings: six operations of
four cells each, so around twenty-five updates, plus the swaps.

The work grows like the cube of the size, which is why the 3 by 3 ceiling
bites harder than it looks: it is not that you have lost one row, it is
that everything a machine could usefully do with elimination lives on the
other side of it.

### 2.5 The mathematics of money

**1.** Predict from the doubling. Trebling needs ln 3 over ln 2 as many
years as doubling, which is about 1.585 times 11.9, so about nineteen.

Store `1500->Z` for the target and solve with `VAR Y`: the root is about
18.85 years. Check on the home screen: press [CLEAR] and spell
`LN(3)/LN(1.06)`: `= 18.854176679022`.

Note that the starting sum cancels again, exactly as it did for doubling.
Ratios do not care how much you began with.

**2.** The adaptation is 8000 in place of 10000, 1.008 in place of 1.01,
and 36 in place of 24. So the equation is

`8000*EXP(B*LN(1.008))-A*(EXP(B*LN(1.008))-1)/.008`

and it will not fit. That string is 49 characters and the entry line holds
48.

This is worth knowing rather than fighting. Since `B` is known here, work
out the growth factor once and store it: press [CLEAR], spell
`EXP(36*LN(1.008))`, press [STO▶] [ALPHA] [EE] for the letter `G`, and
press [ENTER]: `= 1.3322298368266`.

Now the equation is `8000*G-A*(G-1)/.008`, which is nineteen characters.

Press [2nd] [GRAPH]. The workspace opens on `VAR X`, so press [F3], `VAR`,
three times to step X, Y, Z, A. Fence the search at 0 and 1000 and press
[F1], `SOLV`: a `ROOT` of `256.6377251642` with `RES 2.56E-7`.

Three presses of `VAR` is the price of naming the unknown `A` in an
equation whose other letter is `G`. Section 2.5's closing note is about
exactly this: choose letters that march forward from X and you pay one
press instead of three.

**3.** Store `470.73472221384->A`, reopen the workspace, press `VAR` for
`VAR B`, set the upper bound to 100, and `SOLV`.

The root comes back at essentially 24, a few millionths off. The residual
line reports the gap, and what it is telling you is that the payment was
itself found by bisection to a tolerance, so feeding it back can only
recover the term to the same tolerance. Errors do not shrink when you run a
calculation backwards through them.

**4.** For a term of 100 months, solve with `VAR A` and `B` stored as 100:
the payment falls to about 158. For 1000 months it falls to about 100.03.

They are converging on 100, which is exactly the monthly interest on 10000
at one per cent. That is step 9's trap seen from the other side: 100 is the
payment that never repays anything, so any payment above it clears the loan
eventually, and any payment at or below it never does.

The curve of payment against term has a horizontal asymptote, and the
asymptote is the interest.

### 2.6 Loyalty in the long run

**1.** Start with 0, 0, 1 in a `SIZE 1X3` `A`, keep P in `B`, and multiply,
carrying each result back into `A`.

The Harbour's share runs 0.2, 0.32, 0.392, 0.4352, 0.4611. It first passes
0.45 on the fifth Saturday.

Guessing beforehand is instructive: the steady state is 0.5 and the first
step gives 0.2, so you are covering about half the remaining distance each
week, which puts 0.45 at around week five. That estimate is worth making
because it is how you check a long iteration without running it.

**2.** Transpose P into `R`, carry it to `A`, put the 3 by 3 identity in
`B` with the `ID` key, and press `SUB` to get P transpose minus I. Carry
that result to `A` and press `RREF`.

The answer passes through `R` three times and `A` twice, which is four
retypings to avoid one piece of paper arithmetic. Whether that is a good
trade is a fair question, and the answer is usually no: this route exists
to show that the balance equations are exactly P transpose minus I, not
because it is quicker.

**3.** Predict first. The Station's loyalty rising from 0.6 to 0.8 is the
biggest single change in the table, so expect it to gain, but the Harbour
still collects 0.2 from both rivals and starts from 0.8 itself.

The new matrix is .8, .1, .1 then .2, .7, .1 then .1, .1, .8. The balance
system is -.2, .2, .1 then .1, -.3, .1 then .1, .1, -.2, and `RREF` gives
rows 1, 0, -1.25 and 0, 1, -0.75.

So the shares stand as 1.25 : 0.75 : 1, which is 5 : 3 : 4, and dividing by
12 gives 0.41667, 0.25 and 0.33333.

Yes, it reorders them. The Station climbs from a fifth to a third and
overtakes the Mill, which drops from 0.3 to 0.25. The Harbour still leads
but has lost eight points. Loyalty is worth more in the long run than any
single week's switching suggests.

**4.** Starting at the steady state and multiplying once returns the same
share-out, because that is what steady state means.

Starting at the *old* steady state with the *new* matrix does not: the town
begins moving towards the new equilibrium, and the first step shows you the
direction and the initial speed of that move.

The difference between those two runs is how quickly a change in service
shows up. It is fast at first and then slows, because each week closes a
fixed fraction of the remaining gap. Most of the effect of the Station's
renovation appears within a month; the last of it never quite arrives.

## 9.3 Solutions for Chapter 3

### 3.1 A week of small data

**1.** The eight values total 132, so the mean is 16.5. Ordered, the middle
two are 16 and 17, so the median is 16.5 as well.

Press `1V` and the screen answers `MEAN 16.5`, `MED 16.5`,
`S SD 3.5456210417118` and `P SD 3.3166247903554`.

The two land not just close but exactly together, and the reason is that
this week is symmetric: pair the values from the outside in and each pair
averages 16.5. The keeper's week had one value dragging the mean four
points away from the median, and this one has nothing dragging at all.

**2.** The sorted week is 12, 15, 15, 17, 18, 19, 21, 43. Shrinking with
[-] drops the *last* entry, so 43 leaves.

That is the outlier, so the quartiles ought to move very little. `Q1` stays
at 15 and `Q3` drops from 20 to 19, because with seven values the upper
quartile now falls on 19 rather than between 19 and 21.

The quartile that moved is the one on the side the value left from. `Q1`
never noticed, which is exactly why quartiles are worth having.

**3.** 658 over 8 is 82.25. Press [CLEAR] and type `658/8`: `= 82.25`.

Now square the `P SD` figure: press [CLEAR] and type
`9.0691785736085^2`: `= 82.25`.

Exact, and it should be. The `P SD` line is the square root of the
population variance, so squaring it undoes the root, and the machine keeps
enough digits that nothing is lost on the round trip. Compare the `S SD`
line of section 3.1 step 5, which sat a whisker under its true value; that
one lost a digit because 94 has no exact square root and 82.25 does not
need one.

**4.** Predict: the mean falls, the standard deviations fall a great deal,
`MAX` falls, and `MED`, `MIN` and `Q1` do not move at all.

Enter 15, 12, 17, 15, 19, 21, 18, 19 and press `1V`: `MEAN 17`,
`MED 17.5`, `S SD 2.8784916685157`, `P SD 2.6925824035673`.

The mean fell from 20 to 17 and the spread nearly collapsed, from 9.7 to
2.9. The median moved not at all, from 17.5 to 17.5.

That is one number changing three of the eight figures and leaving the rest
untouched, which is the sharpest possible statement of what "resistant to
outliers" means.

**5.** Yes, and it is easier than it sounds. You need the mean and median
equal while the two halves are shaped differently.

Try 10, 16, 16, 17, 18, 19, 19, 25. The mean is 140 over 8, which is 17.5,
and the middle two are 17 and 18, so the median is 17.5 as well. But the
lower half spreads from 10 to 17 and the upper only from 18 to 25 in a
different pattern, so the box plot's whiskers and box are not symmetric.

The lesson is that equal mean and median rules out gross skew and does not
rule out asymmetry. Two numbers cannot describe a shape.

### 3.2 Random numbers that repeat

**1.** From a fresh machine, `RANDI(1,6)` ten times gives 3, 5, 3, 5, 6, 4,
6, 1, 1, 4.

Tally them: 1 twice, 3 twice, 4 twice, 5 twice, 6 twice, and 2 never.

That is as close to uniform as ten rolls of a six-sided die can be while
missing a face: five faces with exactly two each. It looks like strong
evidence of something and it is evidence of nothing at all. With ten rolls
and six faces, the chance that some face is missing is better than sixty
per cent, so a missing face is the *expected* outcome rather than a
surprise.

Small samples are like this. Section 3.3's thirty-six rolls produce eight
sixes and then thirteen, and neither is news either.

**2.** 1 is impossible because the smallest each die can show is 1, so the
smallest sum is 2. Every sum from 2 to 12 is possible and they are not
equally likely: there is one way to make 2 and six ways to make 7, so 7 is
six times as likely.

Eight sums from a fresh machine give 8, 8, 10, 7, 5, 8, 5, 5. All of them
land in the middle of the range, which is what the counting predicts.

**3.** Three calls to `RANDI(0,9)` advance the stream three draws. One call
to `RANDI(0,999)` advances it one.

For most purposes it does not matter, and for one purpose it matters a
great deal: if you want two experiments to be comparable, they must consume
the stream the same way. Change how many draws a simulation takes and you
have changed the experiment, not just its length.

**4.** Predict: it must return 1 every time, since 1 through 1 has one
member. The interesting question is whether it still consumes a draw.

It does. Call `RANDI(1,1)` three times and you get `1`, `1`, `1`. Then
press [CLEAR] and ask `RANDI(1,6)`: `= 5`.

A fresh machine's first die is `3`. This one gives 5, which is the fourth
value in the stream, so the three pointless calls each took a draw.

The generator does not know that the answer was foregone. It draws, then
maps the draw onto the range you asked for, and a range of one maps
everything to the same place.

### 3.3 Simulation by program

**1.** Line 1 changes, from `36->N` to `99->N`. Nothing else: the tally, the
test and the display are all independent of the count, which is what makes
this program worth having.

Expect around 99 over 6, which is 16 or 17. Run it and you will get
something in the low tens to low twenties; the wobble is proportionally
smaller than at 36 rolls but it is still visible, because the spread of a
count grows like the square root of the number of trials while the count
itself grows like the number.

**2.** Adding `DISP 9-S` after the existing `DISP S` leaves the *tails* on
show, because the run screen shows only the most recent `DISP`.

If you want the heads, put the new line first. That is worth knowing before
you write anything longer: on this machine a program communicates one
number, and the last one wins.

**3.** `REPEAT` tests before every pass, so the body runs while the test is
nonzero. Starting from `9->N` and decrementing inside the body, the test
`REPEAT N` runs the body nine times, on `N` equal to 9 down to 1.

The catch is where you put the decrement. Put `N-1->N` before the tally and
you count 8 down to 0 and lose a pass; put it after and you get all nine.
Count the passes on paper before you run it, because an off-by-one here
looks exactly like a bad random stream.

**4.** With `INT(`: an even roll is one where the roll divided by 2 is a
whole number, so `INT(RANDI(1,6)/2)*2` equals the roll exactly when it is
even. Comparing those needs a subtraction, which makes the line long.

Simpler with `INT(`: `S+1-INT((RANDI(1,6)+1)/2)+INT(RANDI(1,6)/2)` is worse
still, because it draws twice.

The clean way without `INT(` is to use the fractional part directly. Store
the roll first, then test `2*(R/2-INT(R/2))`, which is 0 for even and 1 for
odd, so `S+1-2*(R/2-INT(R/2))->S` tallies evens. That needs two lines, one
to store the roll and one to tally it, which is the real lesson: without
comparison operators, anything that uses a value twice has to store it
first.

### 3.4 Two columns and a family of models

**1.** Predict `R` of exactly 1: the data is a straight line with no noise
at all, and correlation measures how nearly the points sit on a line.

Enter days 1 to 6 against 6, 8, 10, 12, 14, 16 and press `2V`:
`MEANX 3.5`, `MEANY 11`, and `R 1`.

Not 0.9999 but 1, to every digit the screen will show. Noiseless
correlation is exactly 1, and this is worth seeing once because it
calibrates everything else: the real bean data's 0.9726 is what a small
amount of noise does, not what a good fit looks like.

**2.** Fit `EXPR` to the bean heights and it returns a model of the form
A e^(Bx). It predicts too low at both ends and too high in the middle, or
the other way about, because an exponential curves and the data does not.

The residuals drift in a pattern rather than scattering, which is section
3.4's central point arriving from the other direction: a wrong model shows
itself in the *shape* of its errors, not their size. A drift means the
model is missing something systematic.

**3.** Take y = 2x³, so A is 2 and B is 3, and tabulate it at x = 1 to 5:
2, 16, 54, 128, 250.

Enter those five pairs, press [MORE] three times to the
`LNR EXPR PWR P2 P3` page, and press [F3], `PWR`. The machine returns `A 2`
and `B 3`, recovering exactly the constants you built in.

A power law is a straight line in log-log coordinates, which is how the fit
finds it, and that is also why it recovers exact constants from exact data.

**4.** The duckweed areas are 6, 12, 24, 48, 96. Ask the machine for their
natural logarithms one at a time: `1.7917594692291`, `2.4849066497888`,
`3.1780538303494`, `3.8712010109087` and `4.5643481914678`.

Notice the differences between consecutive values before you go on: each is
`0.6931471805597`, which is ln 2. The logarithms of a doubling sequence are
an arithmetic one.

Enter those against weeks 1 to 5 and fit `LIN`. The slope comes back as
0.69314718..., which is section 3.4's `B` to every digit.

They agree because taking logarithms turns the exponential model into a
linear one. If y is A e^(Bx) then ln y is ln A plus Bx, a straight line of
slope B. So `EXPR` and this hand-built `LIN` are the same fit computed two
ways, and that is exactly how `EXPR` works inside.

### 3.5 What "best fit" actually means

**1.** Predict 0. The line y = 4 + 2x passes through every one of the
points 6, 8, 10, 12, 14, 16 exactly, so every residual is zero and so is
their total.

Edit lines 2 to 4 to use the new heights and run: `0`.

That is the only time the score is zero, and it is worth having as the
bottom of the scale. Every other line on every other data set scores
something positive.

**2.** Nudging the intercept moves every prediction by the same amount, so
the six residuals all shift by the same amount, and the total of their
squares depends only on the size of the shift and not its direction. Up and
down cost the same.

Nudging the slope moves the predictions by different amounts, more at the
far end than the near one, so there is no such symmetry in general. It
happens to be symmetric here because the days are evenly spaced about their
own mean.

Test it: `1.9->M` scores `4.91`, exactly as `2.1->M` did. So the symmetry
holds for this data, and would not for days spaced 1, 2, 3, 4, 5, 10.

**3.** The least-squares line does pass through (3.5, 11): substitute 3.5
into 4 + 2x and you get 11, which is the mean of the heights.

It has to. Setting the derivative of the score with respect to the
intercept to zero gives exactly the condition that the residuals sum to
zero, and residuals summing to zero says the line's average prediction
equals the data's average value. That is the same statement as passing
through the two means.

So every least-squares line passes through the centre of gravity of its
data, which is a useful thing to check a fit against in one line of
arithmetic.

**4.** Store `11->B` and `0->M` and run: `74`.

That is the score of the best line you could draw *without using x at all*,
so the difference between 74 and 4 is what knowing the day buys you. The
trend explains 70 of the 74, so the fraction left unexplained is 4 over 74.

Press [CLEAR] and type `1-4/74`: `= 0.945945945946`. Press [CLEAR] and type
`0.9725975251592^2`: `= 0.9459459459458`.

The same number to eleven digits. That is what `R` squared *is*: the
fraction of the variation the model accounts for, and now you have computed
it from first principles rather than read it off a screen.

**5.** The duckweed has five pairs, not six, so lines 2 to 4 become
`S+(B+M*1-6)^2+(B+M*2-12)^2->S`, then the same with 3 and 24 then 4 and 48,
then a line with just 5 and 96.

Score the straight line with `-27.6->B` and `21.6->M`: `691.2`.

Now score the doubling model by hand: its predictions at weeks 1 to 5 are
6, 12, 24, 48, 96 against data of exactly those values, so the residuals
are essentially zero and the score is essentially zero.

The straight line scores 691.2 against essentially nothing. `R` said 0.933
for that line, which sounded respectable, and the score says it is
hopeless.
When two models are on the table, compare their scores rather than their
correlations.

### 3.6 Forecasting the full pond

**1.** Predict from the doubling: week 5 is 96, so week 6 is 192 and week 7
is 384. Press [CLEAR] and type `3*128`: `= 384`.

The pond holds 100. Week 7 would need nearly four ponds, which is the model
telling you loudly that it stopped being true two weeks ago.

**2.** Store 50 as a `Y` target and forecast with `FCX`: about 4.0589.

Press [CLEAR] and spell `LN(50/3)/LN(2)`: `= 4.0588936890459`, against the
full-pond answer of `5.0588936890553`.

Exactly one week earlier, to ten digits. It must be, because the model
doubles every week, so whatever the pond's level, half of it happened one
week before. The difference of the two logarithms is ln 2 over ln 2, which
is 1 exactly.

**3.** Store 3 as a `Y` target and `FCX` answers 0.

The model is 3 times 2 to the power x, so at x = 0 it gives 3. The fitted
`A` was 3.0000000000031, which is the coefficient the fit recovered, and
week zero is where that coefficient lives.

Week zero is a week before the first observation, so the model is telling
you where the duckweed would have been the week before anybody looked. That
is extrapolation backwards, and it is exactly as trustworthy as
extrapolation forwards: fine for one step, nonsense for ten.

**4.** Press [CLEAR] and spell `LN(200/3)/LN(2)`: `= 6.0588936890418`, so
the machine says the pond holds 200 square metres in week six.

What is wrong with it, in a sentence for a report: *the model predicts 200
square metres of cover in a pond of 100 square metres, so the prediction is
outside the range in which the model can be true and should not be quoted.*

The arithmetic is correct and the answer is meaningless. Knowing the
difference is the whole job.

### 3.7 Four pictures of one week

**1.** `BOX` reads the `X` column, sorts it internally to find the
quartiles, and draws five numbers. Sorting the column first therefore
changes nothing at all.

The plot that would have changed is `XYLN`, which joins the pairs in entry
order and is the only one of the four that trusts your ordering. `SCAT`
would not change either, and `HIST` would not, for the same reason as
`BOX`: they read values, not sequence.

**2.** `SY` sorts on the `Y` column, so the pairs come out in order of
visitor count rather than day. `XYLN` then joins them in that order, which
draws a line climbing steadily from 12 to 43 while the days jump about
underneath.

The question that answers is "what is the distribution of counts", which
`BOX` and `HIST` answer better. What it destroys is the time order, which
was the only thing `XYLN` was good for. It is a picture that looks like a
trend and contains none.

**3.** The counts run 12 to 43, so the range is 31 and each of the four
bins is 7.75 wide: 12 to 19.75, 19.75 to 27.5, 27.5 to 35.25, 35.25 to 43.

Sorting the eight counts into those: 12, 15, 15, 17, 18, 19 fall in the
first, 21 in the second, nothing in the third, 43 in the fourth.

So the bars are 6, 1, 0, 1, which is what section 3.7 step 6 shows.

**4.** `HIST` would show it as a bar one taller than it should be, which
you would only notice if you knew the right answer.

`BOX` might not show it at all: a repeated middle value barely moves the
quartiles.

`SCAT` would not show it either, because two identical pairs plot as one
dot. That is worth pausing on: a scatter plot silently hides duplicates.

`XYLN` is the one that shows it, and clearly: a repeated pair draws a line
that goes out and comes straight back, leaving a visible spike or a
doubled-back segment.

So the answer is `XYLN`, and the reason is the same property that made it
untrustworthy in step 2. A plot that respects entry order is the only one
that can show you something about entry order.

## 9.4 Solutions for Chapter 4

### 4.1 Limits by table and zoom

**1.** Store `(1-COS(X))/X` and probe, pressing [CLEAR] before each:
`EVAL(.1)` gives `0.04995834722`, `EVAL(.01)` gives `0.00499995834`, and
`EVAL(.001)` gives `0.0005`.

The limit is 0, and the values are shrinking in proportion to x, so the
quotient behaves like x over 2 near the origin.

Now `(1-COS(X))/X^2`: `EVAL(.1)` gives `0.4995834722`, `EVAL(.01)` gives
`0.499995834`, `EVAL(.001)` gives `0.5`.

Dividing by the extra x changed a limit of 0 into a limit of a half. That
is the whole idea of the *rate* at which something vanishes: 1 - cos x goes
to zero like x squared over 2, so dividing by x leaves something going to
zero, and dividing by x squared leaves a half.

Compare with the series: cos x is 1 - x²/2 + ..., so 1 - cos x is
x²/2 - ..., and the two answers fall straight out.

**2.** Halving four more times takes the step to 0.00390625. The row next
to the hole reads `0.999` still, because the cell holds five characters and
`0.9999` needs six.

What stops it showing more is the cell width, not the mathematics. The
value really is closer to 1; the table simply cannot say so. That is what
step 10's `EVAL(` probes are for, and it is why the section moves to them.

**3.** From the series in step 15, sin 2x over x is 2 minus (2x)² over 6
times 2... work it out properly: sin 2x is 2x - (2x)³/6, so sin 2x over x
is 2 - 8x²/6, which is 2 - 4x²/3. The limit is 2.

Check: store `SIN(2*X)/X`. `EVAL(.01)` gives `1.9998666693333` and
`EVAL(.001)` gives `1.9999986666669`.

At .01 the predicted shortfall is 4(0.0001)/3, which is 0.000133, and
2 - 0.000133 is 1.999867. The machine says 1.9998667. The series was right
to seven digits.

The general rule is that sin(kx)/x heads for k, which is worth knowing
because it turns up constantly.

**4.** `EVAL(1E-9)` gave exactly 1. Working down: `EVAL(1E-6)` gave
`0.9999999999999`, which is still visibly short.

So somewhere between a millionth and a billionth the difference stops
fitting. The function is 1 - x²/6, so the shortfall at 1E-7 is about
1.7E-15, which is just below the fourteenth digit. That is the answer: the
crossover is around 1E-7, and the number it measures is the machine's
precision, not anything about sine.

**5.** Store `X/SIN(X)` and probe: `EVAL(.01)` gives `1.000016666861` and
`EVAL(-.01)` gives the same, because the function is even for the same
reason `SIN(X)/X` was.

Its limit is 1 because it is the reciprocal of a quantity heading for 1, and
the reciprocal of a limit is the limit of the reciprocal provided the limit
is not zero. That proviso is doing real work here and it is satisfied.

The squeeze of step 14 does not transfer unchanged. Taking reciprocals
*reverses* the inequality, so cos x < sin x / x < 1 becomes
1 < x / sin x < 1/cos x. The two-line fix is to say exactly that, and then
note that 1/cos x heads for 1 as well, so the sandwich still closes. What
goes wrong if you skip that step is that you end up claiming the quantity is
squeezed between two things in the wrong order.

**6.** In `DEG` mode every angle is scaled by π/180 before the sine sees it,
so sin(2x)/x picks up that factor once: the limit becomes 2 times π/180,
which is π/90, about 0.0349.

Predict it, then check with `EVAL(.001)`, and set the machine back to `RAD`
before section 4.2 or nothing there will work.

### 4.2 A limit that is not there

**1.** Far from the origin, one over x is small and changing slowly, so the
sine's argument barely moves and the curve is nearly flat. At x = 10 the
argument is 0.1; going out to x = 11 changes it to about 0.09. The whole
stretch from 10 to 20 covers an argument range of only 0.05.

Near nought the same amount of x covers an enormous range of argument. That
is the entire asymmetry: the trouble is not that the sine is violent, it is
that one over x compresses infinitely much argument into a finite stretch of
x.

**2.** Sine of one over x is 1 when one over x is π/2, 2π + π/2, 4π + π/2
and so on, so x is 2/π, then 2/(5π), then 2/(9π): about 0.6366, 0.1273,
0.0707.

They bunch up like one over the count, so the gaps shrink but never
stop. Check one with `EVAL(.6366)`, which should be very close to 1.

**3.** Predict `X^2` and `-X^2` as the walls, since the sine is still
bounded by 1 either way and the multiplier is now x squared.

Put all three in the slots and zoom in. The funnel is narrower and closes
faster, because x squared shrinks quicker than x. The limit is still 0 and
the squeeze is tighter.

**4.** Predict: dividing by x rather than multiplying makes the amplitude
*grow* as x shrinks, so it should oscillate worse and worse without
settling or blowing up cleanly.

Probe it at .1, .05 and .02: the values swing to roughly -5.4, 18.3 and
-13.1, growing in size and refusing to settle in sign. It has no limit, and
unlike `SIN(1/X)` it is not even bounded. Both of those are ways of failing
to have a limit, and they are different failures.

**5.** Sine gives up when the angle needs more than 63 subtractions of 2π,
which is at about 395.84. One over x reaches that when x is about
1/395.84, which is 0.002526.

The section found the edge from the other side: `SIN(398)` answers and
`SIN(399)` does not, so the exact stopping point depends on where the angle
falls relative to π. Anywhere below about x = 0.0025 you are asking for
trouble, and `EVAL(.0025)` needs sin(400) and stops.

**6.** Start from the standard window and pick a tolerance, say 0.1. The
curve of `X*SIN(1/X)` is inside a band of ±0.1 once |x| is below 0.1, and
three presses of [+] gets the window to -1.25 to 1.25, which is not yet
enough; a fourth reaches 0.625 and a seventh reaches about 0.078.

Halve the tolerance to 0.05 and you need one more press, because the
bound is |x| and the window halves each time.

So the presses grow like the logarithm of the tolerance: each halving of
the tolerance costs one press. That is a prediction you could have made
from the walls being straight lines, and it is exactly why this squeeze is
easy while `SIN(1/X)`'s is impossible.

### 4.3 The derivative as a limit

**1.** Predict: the quotient of `X^2` at step .01 is (x + .01)² - x² over
.01, which is 2x + .01. So it sits exactly 0.01 above `2*X` everywhere, and
the gap does *not* grow.

Build both slots and the table confirms it: every row differs by 0.01.

That is a sharper result than the cubic's, where the gap grew, and the
reason is that a parabola's second derivative is constant while a cubic's
is not. The chord error depends on the curvature, and here the curvature is
the same everywhere.

**2.** At a = 0, f(0) is 0, so the quotient is just f(h)/h, which is
h² - 2. The chords head for -2.

`NDER(0)` answers `-1.9999999999`, which is -2 with a whisker missing. That
whisker is worth a thought: `NDER(` uses a central difference with a fixed
small step, and the cubic's third derivative is not zero, so a small error
survives. At x = 1 and 2 the answers came out exactly 1 and 10, because the
error term happens to cancel there.

**3.** The backward chord `(EVAL(1.5)-EVAL(1.5-.01))/.01` answers `4.7051`.
The forward one answered `4.7951`.

The forward chord is above 4.75 and the backward one below, because the
curve bends upwards: a chord to the right overshoots the tangent and a
chord to the left undershoots.

Average them: press [CLEAR] and type `(4.7951+4.7051)/2`: `= 4.7501`.

That is out by a ten-thousandth where each chord was out by a twentieth.
Averaging a forward and a backward chord *is* the central difference, which
is what `NDER(` does, and this is why it is so much better.

**4.** `NDER(0)` is `-1.9999999999`, `NDER(1)` is `1` and `NDER(2)` is
`10`, against 3x² - 2 giving -2, 1 and 10.

Only the first is dusty. The error in a central difference depends on the
third derivative and the step, and for a cubic the third derivative is a
constant 6, so the error is the same size everywhere. It shows at 0 because
the answer there is small enough for a fixed error to be visible in the
last digits, and hides at 10 because the same error is far below the
fourteenth digit of a bigger number.

Absolute error constant, relative error shrinking with the size of the
answer: that is the usual arrangement and it is why small answers look
worse.

**5.** Compute the forward chord at 1.5 with steps 1E-4 through 1E-8. The
errors fall as the step shrinks, reach their smallest around 1E-6 to 1E-7,
and then grow again as cancellation takes over.

The best is around 1E-6, where the answer was `4.7500045`. That is the
sweet spot for a one-sided chord on this machine: small enough that the
method error is tiny, large enough that the subtraction still has digits to
work with. Every fixed-precision machine has one and its position depends
only on how many digits it keeps.

### 4.4 Extrema by search

**1.** `X^2*(X^2-4)/4` is even, so its graph is symmetric about the y axis
and its two minima must be at plus and minus the same number.

The derivative is x³ - 2x over... work it out: the function is
(x⁴ - 4x²)/4, whose derivative is x³ - 2x, which vanishes at 0 and at plus
or minus root 2.

`FMIN(0,3)` gives about 1.414 and `FMIN(-3,0)` gives about -1.414,
symmetric as predicted, and both a few digits short of root 2 for the usual
reason.

**2.** There is no turning maximum in (0, 4), so the largest value of the
cubic on that interval is at an endpoint. The search reports a value near
4, the right-hand end.

`EVAL(` at the answer gives about 5.33, and `EVAL(-2)` gives
`= 5.3333333333333`. They are nearly the same, which is a coincidence of
this cubic: x³/3 - 4x takes the value 16/3 both at its hill and again out
at x = 4.

The lesson is that a search with bounds reports the largest value it found,
which is not the same as a turning point. Always ask whether the answer
sits at an end.

**3.** After two presses of [+] the window is -2.5 to 2.5, which still
contains the maximum at -2 but samples it four times as finely.

The answer comes back closer to -2 than the whole-window search did,
because the bracket the search starts from is narrower. You could have
predicted that: the search's accuracy depends on how many samples span the
flat region near the top, and zooming in buys you more of them.

**4.** `EVAL(-2)` gives `= 5.3333333333333` and `EVAL(-1.99)` gives
`= 5.3332333333333`, a change of one ten-thousandth for a hundredth of
movement.

Either side of x = 0 the same movement costs much more: `EVAL(0)` is 0 and
`EVAL(.01)` is about -0.04, four hundred times the change.

Flat means small change for given movement, which is precisely why locating
a maximum precisely is hard and locating a steep crossing is easy. Root
finders are accurate; extremum finders are not; and it is the same fact
seen twice.

### 4.5 The definite integral as an average

**1.** The model is `17-3*COS(PI*X/12)`, on the pattern of step 1 with 17
for the centre and 3 for the swing.

Predict 17: the cosine averages zero over a whole period, so the average is
the centre line.

Check: press [CLEAR] and spell `FNINT(0,24)/24`: `= 17.00000073816`. The
trailing digits are the machine's `PI`, as before.

**2.** The model reaches its average where the cosine is zero, which is at
`PI*X/12` equal to π/2 and 3π/2, so x = 6 and x = 18.

Check both with `EVAL(`. Six in the morning and six in the evening, which
is what section 4.5 step 6 found for the harbour and is true for any model
of this shape.

**3.** `FNINT(-1,1)` answers `= -5.3333333333333` and `FNINT(1,3)` answers
`= -5.3333333333333`.

They add to -10.666666666667, which is step 9's answer for the whole dip,
so the splitting rule holds. That the two halves are equal is a symmetry of
this particular parabola about x = 1, not a general fact.

**4.** On paper, the integral of x² - 2x - 3 from -5 to 5 is
[x³/3 - x² - 3x] evaluated between, which gives 250/3 - 30 minus
(-250/3 - 30 + ... ). Work it through and you get 500/3 - 30, which is
about 136.67.

Press [+] once on the plot and use [F5] on the halved window: the machine
reports the same figure. The window is the interval, so halving the window
halved the interval, and the answer is the -5 to 5 integral rather than the
-10 to 10 one.

**5.** The average over -1 to 3 is the integral divided by the width:
press [CLEAR] and spell `FNINT(-1,3)/4`: `= -2.6666666666668`, which is
-8/3.

The curve takes that value where x² - 2x - 3 equals -8/3, which solves to
x = 1 plus or minus root(4 - 8/3), so about 1 ± 1.155: at -0.155 and 2.155.

Both sit inside (-1, 3), as the mean value theorem for integrals promises.
That theorem is the same statement section 4.5 step 6 made about the
harbour, and it holds for every continuous function on every interval.

### 4.6 Riemann sums by program

**1.** Predict from step 5's relation. At eight slices the width is 0.25,
so the gap between the left and right sums is (f(2) - f(0)) times 0.25,
which is 4 times 0.25, which is 1. The two sums straddle 4.6667 and their
average is the trapezoid, so left is about 4.1875 and right about 5.1875.

Edit `P1` to count 0 to 7, sample `A/4` and display `S/4`. The run screen
answers `4.1875`. The prediction was exact.

**2.** Run left and right at eight slices: `4.1875` and `5.1875`. Their
difference is exactly 1, which is (5 - 1) times the new slice width of
0.25.

The relation holds at every slice count, which makes it a genuinely useful
check on a program you have just typed: if the two sums do not differ by
that amount, you have mistyped a bound.

**3.** Store `X^2+1` and rerun `P4` untouched and it still measures the
same integral, because `EVAL(` reads whatever is stored. Store `X^3+1`
instead and it measures that one.

What you have to be careful about is the *interval*. The program's sample
points `(2*A-1)/8` are hard-wired to 0 to 2, so storing a new equation
changes the function and not the range. Check any answer against `FNINT(`
with bounds 0 and 2, not against whatever bounds you had in mind.

**4.** From the eight-slice numbers: the trapezoid is (4.1875 + 5.1875)/2,
which is 4.6875, and the midpoint was 4.65625. Simpson is
(2 times 4.65625 + 4.6875)/3, which is 4.6666666..., exactly 14/3 again.

On `X^3+1` from 0 to 2 the exact integral is 6, and Simpson returns 6 as
well, because Simpson is exact on cubics too. That surprises people: fitting
a parabola through three points integrates a cubic exactly, because the
error terms cancel by symmetry.

On `1/X` from 1 to 2 it stops being exact. Simpson gives about 0.694 against
the true 0.6931, so three decimals rather than fourteen. Exactness stops as
soon as the function is not a polynomial of degree three or less.

**5.** The midpoint error quarters per doubling, so from 1/24 at four slices
you need the error below about 1E-6, which is a factor of 40000, which is
seven or eight doublings: around 512 to 1024 slices.

The eight-line slot could never run it. `FOR` bounds are single digits and
even the `WHILE` countdown would need the loop to run a thousand times,
which on this machine is minutes of work for a number `FNINT(` gives you in
a second. That is the honest limit of doing numerical integration by hand
here, and it is why `FNINT(` exists.

### 4.7 Areas between curves

**1.** Predict -2.25. The difference has been turned upside down, so every
height changes sign and so does the integral.

Retype `Y3` as `X/2+1-(2-X^2/2)` and integrate from -2 to 1: `= -2.25`.

What changed is the sign. What did not is the size, the crossings, or the
region itself: 2.25 square units of area sit between those curves whichever
way you subtract, and only the bookkeeping moved.

**2.** With `Y2` as `X/2` the crossings solve 2 - x²/2 = x/2, which is
x² + x - 4 = 0, so x = (-1 ± root 17)/2: about 1.5616 and -2.5616.

The residual lines no longer read `R=0`. They report small nonzero values,
because the search stops when the residual passes the tolerance rather than
when it hits zero, and an irrational root can never be hit exactly. A
residual of 1E-13 means the search got as close as fourteen digits allow.

**3.** The line is above the arch beyond x = 1, so from 1 to 4 the
difference function is negative. `FNINT(-2,4)` therefore mixes a positive
contribution from -2 to 1 with a negative one from 1 to 4, and reports the
net.

For the total enclosed area on both sides, integrate the two pieces
separately and add their sizes: `FNINT(-2,1)` gives 2.25 and `FNINT(1,4)`
gives a negative number whose size you add rather than subtract. That is
section 4.5's sign convention arriving exactly where nobody wants it, for
the second time.

**4.** Pick the crossings first: to cross at -1 and 3, the difference must
vanish there, so it is a multiple of (x + 1)(x - 3), which is x² - 2x - 3.

Take the difference as -(x² - 2x - 3), so the region is positive between
the crossings, and split it into two curves however you like: the arch
`3+2*X-X^2` and the line `0`, or more interestingly `4+2*X-X^2` against the
constant `1`.

Check with [2nd] [F1] and you should find -1 and 3 to the usual dust.
Designing backwards from the answer is how every exercise in this book was
built, and it is a good habit for building your own.
