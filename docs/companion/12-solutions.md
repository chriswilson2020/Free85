# Chapter 12: Solutions

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
same answer, as section 6.6 found.

## 12.1 Solutions for Chapter 4

### 4.1 Functions and their windows

**1.** The three crossings of `X^3-4*X` and `X` are where x cubed minus
four x equals x, so x cubed equals five x, so x is 0 or plus or minus the
square root of five.

Section 4.1 found the negative one at `= -2.2360679774997`. For the other
two, trace to the neighbourhood first: the search reads the traced position,
so trace near the origin and press [2nd] [F1] for `= 0`, then trace right of
2 and press [2nd] [F1] again for the positive root.

Check it: press [CLEAR] and type [2nd] [x²] [5] [)] for `SQRT(5)`:
`= 2.2360679774998`.

Notice the last digit. The intersection search answered `2.2360679774997`
and the square root answers `...98`. Neither is wrong; the search stops when
its bracket is tight, and the root is computed. Section 7.4 has more on why
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
`-2.5`, `-1.25`, `-0.625`, `-0.3125`. Each press halves it, as section 4.1
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
answer as a global one, which is the whole reason section 4.1 comes first.

### 4.2 Families of curves three at a time

**1.** All three lines have slope 1, so they are parallel. They cross the y
axis at 4, 0 and -3, which are the constants themselves.

The table makes it plain: at `X=0` the row reads `4`, `0`, `-3`. Adding a
constant to a function moves its graph vertically by that constant, which is
section 4.3's rule arriving early.

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

### 4.3 Symmetry and transformations

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

### 4.4 Rational functions and the lines they approach

**1.** `(X^2-4)/(X-2)` divides out exactly: it is (x - 2)(x + 2) over
(x - 2), which is x + 2 for every x except 2.

The table reads `UNDEF` at `X=2`, exactly as the pole did. But this is a
completely different situation. Probe either side and you see it: with the
equation stored, `EVAL(1.9)` answers `= 3.9` and `EVAL(2.1)` answers
`= 4.1`, and `EVAL(2)` stops at `DIVIDE BY ZERO`, which names exactly what
it met there.

The values from both sides are heading for 4, which is what x + 2 gives at
x = 2. The function has a *hole*, not a pole: one point missing from an
otherwise perfectly ordinary line. Chapter 7's `SIN(X)/X` is the same shape
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

That is a much faster convergence than section 4.4's slant case, where the
gap was 2/(x - 1) and you had to go out to 2001. Squaring the denominator
squares how quickly the curve settles.

### 4.5 Exponential and logarithmic functions

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

**5.** All three work. What differs is the route each one takes, and
therefore whether the answer is exact.

`1.06^-3` and `1.06^10` have whole-number exponents, so both go by repeated
squaring and both are exact: `= 0.8396192830323` and `= 1.7908476965428`.
`1.06^0.5` does not, so it goes through the logarithm and the exponential,
and answers `= 1.0295630140986`.

Checking with the identity is the test, and it separates the two routes
cleanly. `EXP(10*LN(1.06))` answers `= 1.7908476965481` against the key's
`= 1.7908476965428`: the identity took the long way round for an exponent
that did not need it, and the last three digits paid for it.
`EXP(0.5*LN(1.06))` answers `= 1.0295630140986`, agreeing with `1.06^0.5`
to every digit, because for a fractional exponent the identity is not an
alternative to what the key does. It is a description of it.

### 4.6 Trigonometric functions

**1.** `SIN(X)+2` lifts the whole wave two units, keeping its shape.
`SIN(X+2)` slides it two units to the *left*, keeping its height. The first
is a change outside the sine, the second is inside it, which is section
4.3's rule again.

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
It is section 4.6's opening complaint all over again, and the fix is the
same: zoom in vertically until the wave fills the screen.

What the standard window hides is not the shape but the *scale*. Both towns
have a sine of period twelve months. Only the amplitude differs, and
amplitude is exactly what a badly chosen vertical range destroys.

**4.** Sine is 0, 1, 0, -1 at x = 0, π/2, π and 3π/2. Cosine at those four
places is 1, 0, -1, 0: it does the same thing a quarter turn earlier, which
is what section 4.6 step 4 showed.

Check them. Press [CLEAR] and spell `COS(0)`: `= 1`. Then `COS(PI/2)`:
`= -6.51527649229E-11`. Then `COS(PI)`: `= -1.0000041678092`. Then
`COS(3*PI/2)`: `= -6.51527649229E-11`.

The last three are 0, -1 and 0 under the machine's fourteen-digit `PI`,
which is not quite pi. Read `-6.5E-11` as zero and `-1.0000042` as minus
one. That dust appears in section 8.4's cardioid too, and it is worth
learning to recognise rather than chase.

**5.** Six hours thirteen minutes is 6.2166666666666 hours. A sine repeats
every 2 pi, so you want the bracket to reach 2 pi when x reaches the period:
the model is `SIN(2*PI*X/6.2167)`, or equivalently `SIN(1.0107*X)` since
press [CLEAR] and spelling `2*PI/(6+13/60)` answers `= 1.0107000494123`.

Two days is 48 hours, which is a little under eight periods. The standard
window's -10 to 10 shows barely three, so you want a window several times
wider in x and much narrower in y. Press [-] twice for x and zoom in
vertically, or accept the trig window and read only part of the picture.

### 4.7 Inverse functions by parametric pair

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

## 12.2 Solutions for Chapter 5

### 5.1 Prices from receipts

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

The two are one keystroke apart, which is the point of section 5.1 step 5.

**4.** Any third receipt whose coefficients are a combination of the first
two but whose takings are not. The first two are 3, 2 and 2, 3; their sum
is 5, 5, and the takings should then be 12.30 plus 10.70, which is 23.00.
So the receipt 5, 5, 23 is consistent and 5, 5, 24 is not.

Grow the editor to `3X3` and enter all three: with 23 the answer is still
`X 2.7`, `Y 2.1`; with 24 it is `NO SOLUTION`. A third receipt cannot add
information, only agreement or contradiction.

### 5.2 When the answer will not stay still

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
have guessed from looking at it. Section 9.3 puts a number on that with
`COND`, and this system is worth running through it when you get there.

### 5.3 The best plan on a graph

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

### 5.4 Elimination as bookkeeping

**1.** The tableau is 2, 5, 7.9 then 4, 5, 12.3, and no swap is needed
because the top-left is already nonzero.

There are four scales. First -2, to clear the 4 below the pivot, which
leaves row 2 as 0, -5, -3.5. Then -0.2, to turn that -5 into a 1, leaving
0, 1, 0.7. Then -5, to clear the 5 above it. Then 0.5, to turn the leading
2 into a 1.

The finished tableau reads 1, 0, 2.2 and 0, 1, 0.7: coffee 2.20, pastry
0.70, which is section 5.1's answer arrived at the slow way.

**2.** Put the coefficients 2, 1, 1, 3 in a 2 by 2 `A` and the takings 110,
130 in a 2 by 1 `B`, then press `AUG`.

The result lands in `R`, as every result does. Before row operations can
touch it you must carry it into `A` by hand, which is the same cost section
5.4 charges everywhere: the row-operation keys read `A` and nothing else.

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

The work grows like the cube of the size, which is the thing worth taking
away. Twelve updates against twenty-five for one extra row and column, and
a 3 by 6 tableau costs more again. That growth, not the size of the
register, is what limits elimination by hand: the register holds three rows
by six columns, and by the time you have filled it you will not want to
audit every step anyway.

### 5.5 The mathematics of money

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
equation whose other letter is `G`. Section 5.5's closing note is about
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

### 5.6 Loyalty in the long run

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

## 12.3 Solutions for Chapter 6

### 6.1 A week of small data

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
line of section 6.1 step 5, which sat a whisker under its true value; that
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

### 6.2 Random numbers that repeat

**1.** From a fresh machine, `RANDI(1,6)` ten times gives 3, 5, 3, 5, 6, 4,
6, 1, 1, 4.

Tally them: 1 twice, 3 twice, 4 twice, 5 twice, 6 twice, and 2 never.

That is as close to uniform as ten rolls of a six-sided die can be while
missing a face: five faces with exactly two each. It looks like strong
evidence of something and it is evidence of nothing at all. With ten rolls
and six faces, the chance that some face is missing is better than sixty
per cent, so a missing face is the *expected* outcome rather than a
surprise.

Small samples are like this. Section 6.3's thirty-six rolls produce eight
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

### 6.3 Simulation by program

**1.** Line 1 changes, from `36->N` to `99->N`. Nothing else: the tally, the
test and the display are all independent of the count, which is what makes
this program worth having.

Expect around 99 over 6, which is 16 or 17. Run it and you will get
something in the low tens to low twenties.

The wobble is proportionally smaller than at 36 rolls and still visible.
The spread of a count grows like the square root of the number of trials
while the count itself grows like the number, so the two pull apart slowly.

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

### 6.4 Two columns and a family of models

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
6.4's central point arriving from the other direction: a wrong model shows
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
0.69314718..., which is section 6.4's `B` to every digit.

They agree because taking logarithms turns the exponential model into a
linear one. If y is A e^(Bx) then ln y is ln A plus Bx, a straight line of
slope B. So `EXPR` and this hand-built `LIN` are the same fit computed two
ways, and that is exactly how `EXPR` works inside.

### 6.5 What "best fit" actually means

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

### 6.6 Forecasting the full pond

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

### 6.7 Four pictures of one week

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

So the bars are 6, 1, 0, 1, which is what section 6.7 step 6 shows.

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

## 12.4 Solutions for Chapter 7

### 7.1 Limits by table and zoom

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
before section 7.2 or nothing there will work.

### 7.2 A limit that is not there

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

**5.** The supported range is one million radians, so `SIN(1/X)` should
answer while one over x stays inside it: x down to 1E-6 and no further.

That is what happens. `EVAL(1E-6)` asks for the sine of exactly a million
and answers `-0.3499934460541`. `EVAL(9E-7)` asks for about 1.11 million
and answers `PRECISION LOST`.

The two need not agree to the last digit, and the reason is worth having.
One million is where the firmware stops *guaranteeing* about 1E-7; it is a
promise about accuracy, not a wall the arithmetic runs into. A limit
quoted as a round number is nearly always a promise rather than a
mechanism, and it is worth knowing which kind of number you are reading.

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

### 7.3 The derivative as a limit

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

### 7.4 Extrema by search

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

### 7.5 The definite integral as an average

**1.** The model is `17-3*COS(PI*X/12)`, on the pattern of step 1 with 17
for the centre and 3 for the swing.

Predict 17: the cosine averages zero over a whole period, so the average is
the centre line.

Check: press [CLEAR] and spell `FNINT(0,24)/24`: `= 17.00000073816`. The
trailing digits are the machine's `PI`, as before.

**2.** The model reaches its average where the cosine is zero, which is at
`PI*X/12` equal to π/2 and 3π/2, so x = 6 and x = 18.

Check both with `EVAL(`. Six in the morning and six in the evening, which
is what section 7.5 step 6 found for the harbour and is true for any model
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
That theorem is the same statement section 7.5 step 6 made about the
harbour, and it holds for every continuous function on every interval.

### 7.6 Riemann sums by program

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

The eight-line slot could not run it when this was written. `FOR` bounds
were single digits and
even the `WHILE` countdown would need the loop to run a thousand times,
which on this machine is minutes of work for a number `FNINT(` gives you in
a second. That is the honest limit of doing numerical integration by hand
here, and it is why `FNINT(` exists.

### 7.7 Areas between curves

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
section 7.5's sign convention arriving exactly where nobody wants it, for
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

## 12.5 Solutions for Chapter 8

### 8.1 Zeros of functions two ways

**1.** Multiply, say, x² - 3 by x² - 4x + 1 to get
x⁴ - 4x³ - 2x² + 12x - 3, whose roots are plus and minus root 3 and
2 plus or minus root 3.

Enter the coefficients 1, -4, -2, 12, -3 and press `SOLV`. The browser
returns all four, each carrying a digit or two of dust in the last places.

You get eleven or twelve good digits out of fourteen, which is what an
iterative root hunt on a quartic costs. Designing the roots first is the
only way to know that.

**2.** `POLY` on x² + 2x + 3 returns a conjugate pair: `RE -1` with `IM 1`
and `RE -1` with `IM -1`, since the roots are -1 ± i.

The solver stops at a notice instead, because it hunts for a sign change
along the real line and there is none: the parabola never touches the axis.

Each tool is telling you the truth about the question it was asked. `POLY`
solves the polynomial; the solver looks for a real crossing. The failure is
informative, not a defect, and the pair of answers together says "no real
root, two complex ones" more clearly than either alone.

**3.** With bounds -5 and 0 and a guess of 3, the guess is outside the
bounds. The workspace tries the guess first, then scans within the fence,
and reports the negative root it finds: minus root 2, about
-1.4142134785654.

To fence in the other negative root, 1 minus root 3 at about -0.732, set
bounds -1 and 0. The two negative roots need separate fences because the
scan stops at the first sign change it meets.

**4.** `RES` is the value of the equation at the reported root. A perfect
root gives exactly zero; anything else reports how far from zero the
expression still is.

Handing it the exact root produces zero because the expression really does
vanish there and the arithmetic happens to confirm it in fourteen digits.
That is a check on the *root*, not on the hunt: it says the number you
supplied satisfies the equation, which is what you wanted to know.

### 8.2 Newton's method

**1.** Predict: 3 is further from the root than 2, so it should take at
least as many steps.

Starting at 3, three steps give `2.0951360369349` and four give
`2.0945516738243`. Starting at 2, four steps gave `2.0945514815424`, which
is the settled answer.

So from 3 it is one step behind: it needs five to settle where 2 needed
four. That is what quadratic convergence looks like from further out. The
first step does the coarse work and the doubling only takes over once you
are close.

**2.** At 0.8 the cubic's slope is 3(0.64) - 2, which is -0.08: almost
flat. A nearly flat tangent runs an enormous distance before it meets the
axis.

Predict a long throw, then run one step: `-75.3`.

Seventy-five units away from a root at 2.09, from a start two thirds of the
way there. A second step brings it back to `-50.205609036075`, still
nowhere. The size of that first throw is exactly f(0.8) divided by 0.08,
and small denominators are how Newton's method goes wrong.

**3.** Store `X^2-2` and run from 1. Three steps give `1.414215686276` and
four give `1.4142135623747`, which is root 2 to twelve digits.

Line 4 becomes R - (R² - 2)/(2R), which simplifies to (R + 2/R)/2: the
average of your guess and 2 divided by your guess. That is the Babylonian
method for square roots, known for three and a half thousand years, and you
have just derived it from Newton's method in one line of algebra.

**4.** Store `COS(X)-X` and run from 1. Three steps give `0.7390851333854`
and four give `0.7390851332152`.

Section 8.1's solver gave `0.7390856742858` for the same root. The two
disagree in the seventh digit, and Newton is the one that is right: the
true root is 0.73908513321516.

The solver stopped because its residual passed the `1E-6` tolerance, which
is what it was asked to do. Newton kept doubling its digits and ran out of
machine before it ran out of accuracy. Neither is broken; they were asked
different questions.

**5.** Four Newton steps cost eight evaluations of the stored equation, two
per step for `EVAL(` and `NDER(`. In fact `NDER(` is itself a central
difference and evaluates twice, so the true count is nearer twelve.

Bisection to fourteen digits needs about 47 halvings and one evaluation
each. So Newton wins by a factor of four on this problem, and would win by
far more on a harder one, provided it converges at all. That proviso is the
whole trade: bisection is slow and cannot fail, Newton is fast and can end
up at -75.3.

### 8.3 Conic sections by parametric pair

**1.** A basin 8 across and 8 deep is a circle of radius 4, so the pair is
`4*COS(X)` and `4*SIN(X)`.

In the square window it draws a circle rather than an ellipse, which is the
visual check. Trace a point and test it against x² + y² = 16: the sum should
come back as 16 to all fourteen digits, exactly as section 8.3's ellipse
did.

**2.** Swapping to `2.5*COS(X)` and `5*SIN(X)` gives the same ellipse
standing on end: half-width 2.5 and half-height 5, so twice as tall as
wide.

Predicting that is easier than it looks if you remember which slot is which:
slot 1 is x, slot 2 is y, so the number in slot 1 controls the width.

**3.** Two presses of [+] halve the bounds twice, so the window runs -2.5 to
2.5. The pond is 5 wide and no longer fits, so you see the middle of it
only.

But the window is also the sweep, so t now runs from -2.5 to 2.5, which is
less than one full revolution. So you get *part* of the rim, drawn at
higher resolution, rather than the whole rim magnified. Both things happened
at once and only one of them was what you wanted.

**4.** A circle of radius 3 centred at (4, 1) is `4+3*COS(X)` and
`1+3*SIN(X)`: the constant moves the centre and the coefficient sets the
radius.

Trace any point and check that (x - 4)² + (y - 1)² comes back as 9.

### 8.4 Polar curves

**1.** `4*SIN(3X)` draws three petals, not six. Predict three: with an odd
multiplier the negative half of each cycle retraces petals that the
positive half already drew, so half of them coincide.

Doubling gave four petals from two cycles because even multipliers put the
negative lobes in the gaps. That is the rule: `SIN(nX)` gives n petals for
odd n and 2n for even n, which is worth checking with `4*SIN(4X)`.

**2.** `2.5*(1-COS(X))` faces the other way from section 8.4's cardioid:
its cusp is at angle 0 rather than at pi, because the radius now vanishes
when the cosine is 1.

Press [CLEAR] and ask `EVAL(0)`: `= 0`. Exactly zero this time, with no
dust at all, because 1 - cos 0 is 1 - 1 and the machine's cosine of exactly
zero is exactly one. The dust in section 8.4 came from `PI` not being pi;
here the awkward angle never appears.

**3.** The half-the-angle rule holds at every stop, because the slot text
`X/2` says so directly: the polar readout's first line is the radius and its
second is the angle, and the radius is computed as half the angle.

What you are checking is not the mathematics but that you have read the
screen correctly, which is worth doing once because the labels both say `X=`
and `Y=` whatever the coordinate mode.

**4.** Between pi/2 and pi, the angle 2X runs from pi to 2pi, where sine is
negative. So the radius is negative, and a negative radius plots in the
*opposite* direction from the angle.

The result is that the petal drawn during that stretch appears in the third
quadrant rather than the second. Working out which petal gets drawn when is
the whole trick of reading a rose, and the answer is that consecutive
quarter-turns of the parameter draw petals on opposite diagonals.

### 8.5 Parametric motion

**1.** On paper: the pebble lands when 12t - 5t² is zero again, at
t = 12/5 = 2.4 seconds, and the range is 2 times 2.4, which is 4.8 metres.
The apex is at half the flight, t = 1.2, where the height is
12(1.2) - 5(1.44) = 7.2 metres.

Store `2*X` and `12*X-5*X^2`. `FMAX(0,3)` gives a whisker under 1.2, and
`EVAL(1.2)` answers `= 7.2`. For the landing, put `12*X-5*X^2` in the
solver with a guess of 2 and bounds 1 and 4: the root comes back at
essentially 2.4.

**2.** `FMAX(` stops a whisker short because the curve is flat at its apex,
so a wide range of t values all look equally like the top. That is section
7.4's story exactly, and it is why the section reaches for `EVAL(.9)` at
the exact value rather than at the search's answer.

**3.** With `2*X` and `2+9*X-5*X^2`, the pebble starts 2 metres up and
lands when 5t² - 9t - 2 is zero, at t = 2 exactly. The range is 4 metres.

Trace says the landing is somewhere between the samples either side of
t = 2. For the solver, a guess of 2 with bounds 1 and 3 works; a guess of 0
would find the *negative* root at -0.2, which is the pre-launch fiction
again.

**4.** The root hunt scans from the window's left edge, so it finds the
launch at t = 0 because the standard window starts at -10 and the first
sign change going right is at the origin.

Zoom or shift so the window starts after t = 0. Two presses of [+] leave
the window at -2.5 to 2.5, which still contains the launch. What works is
narrowing until the left edge is past 0 while the landing at 1.8 is still
inside, which the zoom keys alone cannot quite do, since they always centre
on the origin. That is a real limitation and the solver is the answer.

### 8.6 Functions defined by integrals

**1.** Predict from the first two probes. `FNINT(0,1)` on `3*X^2` gives 1
and `FNINT(0,2)` gives `8`.

1 and 8 are 1 cubed and 2 cubed, so the accumulator is x³. Check at 3 and 4
and you get 27 and 64.

That is the fundamental theorem again: the accumulator of 3x² is x³ because
3x² is the derivative of x³.

**2.** Predict equality: the area from 1 to 8 is the area from 1 to 2 plus
the area from 2 to 8, so `FNINT(2,8)` should be `FNINT(1,8)` minus
`FNINT(1,2)`.

Compute all three: `FNINT(1,8)` is `2.0794461816072`, `FNINT(1,2)` is
`0.6931471824209`, and `FNINT(2,8)` is `1.3862945205893`.

Now subtract the first two: press [CLEAR] and type
`2.0794461816072-0.6931471824209`: `= 1.3862989991863`.

That is *not* `1.3862945205893`. They differ by about four and a half
millionths.

The mathematics is exact and the arithmetic is not. `FNINT(` fits its
panels to whatever interval it is given, so the 1-to-8 integral used panels
seven times wider than the 1-to-2 one, and the three answers were computed
at three different resolutions. Comparing coarse and fine estimates catches
an estimate that is not converging at all; it does not make two converged
estimates on different intervals add up exactly. Additivity holds for
integrals and only approximately for their estimates.

**3.** Any pair in the ratio 2 works: 5 to 10, 7 to 14, 100 to 200. Each
gives about 0.693, because the logarithm turns ratios into differences and
every doubling is the same difference.

**4.** `8*FNINT(0,.5)` on `1/(1+X^2)` answers `= 3.7091808726128`.

That is 8 times the arctangent of a half, and it is not pi because the
arctangent of a half is not pi/8. Pi/8 is the angle whose tangent is 0.4142,
not 0.5.

The step 6 trick worked because the arctangent of *1* is exactly pi/4. Half
the interval does not give half the angle: the arctangent is not linear, and
this is a good way to feel that.

**5.** The accumulator of 1/t from 2 is ln x minus ln 2, so it is the same
function shifted down by 0.6931.

So `FNINT(2,6)` should be ln 3, since 6 over 2 is 3. Check it:
`FNINT(2,6)` answers `= 1.0986123199908` and `LN(3)` answers
`= 1.0986122886693`, agreeing to seven digits.

You can predict it from step 5's answer without computing anything: 2 to 6
is a tripling, and every tripling accumulates ln 3.

### 8.7 Indeterminate forms by table

**1.** Predict from the cosine series. cos x is 1 - x²/2 + x⁴/24, so
1 - cos x is x²/2 - x⁴/24, and dividing by x² leaves 1/2 - x²/24.

The limit is a half. Probe it: `EVAL(.001)` on `(1-COS(X))/X^2` answers
`= 0.5`.

Halved steps from both sides give the same values, because the function is
even.

**2.** The leading coefficients are 2 and 5, so the limit is 2/5, which is
0.4.

Probe with growing arguments: at 100 the value is `0.3939921201576` and at
1000 it is `0.39939992012002`.

At 100 the second decimal is already right and the third is not; at 1000 the
third is right. Each tenfold increase buys about one more decimal, because
the neglected term falls like one over x. Two cells in a row agreeing to
three decimals needs steps out beyond 1000.

**3.** Build it backwards. You want a quotient heading for 7, so take
7x over x, and disguise it: `(EXP(7*X)-1)/X` heads for 7, by exactly the
argument section 8.7 used for the 2.

Probe at .01 and .001 and watch it approach 7 from above.

**4.** Press [CLEAR] and spell `EXP(LN(1+.06/12)*12)`: `= 1.0616778118669`,
against `1.06`.

The question you have answered is what six per cent a year compounded
*monthly* actually pays: 6.168 per cent, not 6. Monthly compounding is
bigger, and it is bigger for the same reason the table in step 5 climbs: you
earn interest on interest twelve times instead of once.

The limit of that process, compounding continuously, is `EXP(.06)`, which is
1.0618365465453. So all the extra compounding in the world buys less than
two hundredths of a per cent beyond monthly.

**5.** The table converges like h, so ten correct digits needs h around
1E-10.

The arithmetic would not survive it. At h = 1E-10, computing 1 + h loses ten
of the fourteen digits immediately, so `LN(1+h)` is working with four
significant figures and the answer is worthless. This is chapter 7's
cancellation cliff in a new costume, and it is why nobody computes e this
way.

### 8.8 Improper integrals

**1.** Predict a quartering: each octave out multiplies x by 2, and 1/x³
falls by 8, while the interval width doubles, so the slab falls by 4.

Check: `FNINT(1,2)` gives `0.37500001953353`, `FNINT(2,4)` gives
`0.09375000488339`, and `FNINT(4,8)` gives `0.023437501220829`.

Each is a quarter of the one before. The running totals are 0.375, 0.469,
0.492, climbing the geometric staircase whose top is 0.5, which is the
paper answer.

**2.** `FNINT(1,1000)` on `1/X^3` answers `= 5.2083129209853`.

The truth is just under 0.5, so the single long probe is out by a factor of
ten. Trust the octave walk. The reason is exactly section 8.8's: sixty-four
panels across a thousand units puts each panel fifteen units wide, and
nearly all of this integral lives in the first unit.

A wrong answer that is ten times too big rather than ten times too small is
worth noticing, incidentally. Starving a spike overestimates, because the
one panel that lands near it counts its enormous height across the whole
panel width.

**3.** `1/X^(2/3)` cannot be typed directly, because `^` takes whole
exponents. Route it through the identity: store `EXP(LN(X)*(-2/3))`.

The plot will fail, because the standard window includes negative x and
there is no logarithm of a negative number. The equation is stored all the
same, and `FNINT(` works. Be patient with it: a logarithm and an
exponential at every panel is slow, and there are at least 96 panels
between the coarse estimate and the one it is checked against.

On paper the integral from a to 1 is 3(1 - a^(1/3)), so it climbs to 3.

`FNINT(.25,1)` gives `1.1101184746881`, against the paper value
`1.1101184251563` from `3-3*EXP(LN(.25)/3)`: seven digits.
`FNINT(.0625,1)` gives `1.8094670776981` against `1.8094492110232`: five
digits. `FNINT(.01,1)` gives `2.3589135473003` against about 2.3537: three.

It converges to 3, and the panels lose a digit or two every time you push
the lower bound closer to the singularity. Same disease as `1/SQRT(X)`,
milder because the spike is milder.

**4.** For `1/SQRT(X)`, substituting x = u² gives dx = 2u du and the
integrand 1/u, so the whole thing becomes 2 du: a constant, integrating to
2(1 - root a), which is the paper answer.

For `1/X^(2/3)`, substitute x = u³: dx = 3u² du and the integrand is
1/u², so it becomes 3 du, integrating to 3(1 - a^(1/3)).

In both cases the substitution that works is the one that clears the
fractional power, and what it buys is an integrand with no spike at all.
That is the general trick and it is worth more than any number in this
section.

**5.** Put the singularity at the right-hand end: `1/SQRT(1-X)` on 0 to 1.

Predict the same failure mode, and you get it: `FNINT(0,.75)` is fine,
`FNINT(0,.99)` starts to drift, and pushing the upper bound to 1 gives
nonsense. `FNINT(` has no idea which end its trouble is at, because it
treats the interval symmetrically.

### 8.9 Polynomial approximation

**1.** The plain line `X` differs from the sine by about x³/6, so it stays
within 0.01 while x³ is under 0.06, which is x under about 0.39.

Check with the home screen rather than the table, which is too coarse:
`SIN(.1)-.1` answers `= -0.00016658335317`, comfortably inside, and
`SIN(.5)-.5` answers `= -0.02057446139581`, outside.

So the crossover is between 0.1 and 0.5, and the cube-root estimate of 0.39
is about right. Read that as: the line is good to a hundredth for angles up
to about 22 degrees, which is a genuinely useful rule of thumb in physics.

**2.** Build `1-X^2/2` in `Y2` and `1-X^2/2+X^4/24` in `Y3` against
`COS(X)` in `Y1`, in the trigonometric window.

The quadratic parts company around x = 1, the quartic holds to about 2, and
by x = 3 both are hopeless. The pattern is the same as sine's and for the
same reason: each new term buys roughly one more unit of agreement, and the
interval widens without bound.

**3.** Adding `-X^7/5040` gives the degree-7 impersonator. At 2 radians it
is right to about four decimals where the quintic was out by 0.024; at 3
radians it is out by about 0.05 where the quintic was out by 0.4.

Check with `EVAL(` against `SIN(`. Each new term roughly divides the error
at a fixed x by the square of that x over the next factorial, which is why
the improvement is dramatic near the origin and slow far from it.

**4.** At x = -0.9 the series still converges, because -0.9 is inside the
interval, but slowly: the terms fall like 0.9 to the power n, so you lose
only about one twentieth per term.

`EVAL(-.9)` on `1/(1+X)` answers `= 10`, and `1/.1` answers `= 10` too.

For two decimals you need 0.9ⁿ below about 0.005, which is n around 50. So
fifty terms at x = -0.9 against three or four at x = 0.25. Convergence
inside the interval is not the same as *useful* convergence.

**5.** `1/(1+X^2)` has no trouble anywhere on the real line, so the
question is where else a function can misbehave, and the answer is in the
complex plane: 1 + x² vanishes at x = i and x = -i.

Those are distance 1 from the origin, so the interval of convergence is
again -1 to 1.

Test it by table: the impersonators `1-X^2+X^4` and `1-X^2+X^4-X^6+X^8`
agree with the function inside 1 and diverge outside it, with the longer one
worse, exactly as the geometric series did. A real function with no real
trouble at all, fenced in by a pair of complex numbers, is one of the better
surprises in the subject.

## 12.6 Solutions for Chapter 9

### 9.1 One system, two tools

**1.** Predict: the two lines x + 2y = 4 and x + 2y = 5 are parallel and
distinct, so nothing satisfies both.

`RREF` reduces the tableau to `1`, `2`, `0` on the top row and `0`, `0`, `1`
underneath. That bottom row reads 0x + 0y = 1, which is the impossible
equation, and it is `RREF`'s way of saying so.

The simultaneous editor answers `NO SOLUTION` for the same six values. Two
tools, one verdict, and the tableau shows you *where* the contradiction
lives rather than only that there is one.

**2.** Any pair through (3, 1) works: x + y = 4 and x - y = 2, say. Both
tools return `X 3` and `Y 1`, and the tableau reduces to the identity with
3 and 1 in the last column.

Designing the answer first is the habit this chapter keeps asking for, and
it is the only way to tell a right answer from a plausible one.

**3.** Press [2nd] [7], type 2, 4, 1, 2, and press [F1], `DET`: `0`.

A zero determinant rules out `UNIQUE SOLUTION`. The rows are proportional,
so depending on the right-hand sides you get either `NO SOLUTION` or
`UNDERDETERMINED`, and nothing else is possible.

**4.** Take 1, 1, 1, 1.001. Press `DET`: `= 0.001`.

Nonzero, so the system has a unique solution and `DET` is content. Now
solve it with right-hand sides 2 and 2.001, which gives x = y = 1, and then
nudge the second to 2.002: the answer jumps to x = 0, y = 2.

A thousandth of a nudge moved the answer by a whole unit, and `DET` gave no
warning at all. That is the lesson: a determinant tells you whether a matrix
is singular, and says almost nothing about whether it is *nearly* singular
in a way that matters. `COND` in section 9.3 is the number that does.

### 9.2 Row operations as algebra you can watch

**1.** After the swap ([F2], `SWP`) the tableau is 3, 4, 11 on top and
1, 2, 5 beneath. The
first move is now to subtract a third of the top row from the bottom, so the
scale is -1/3 rather than -3, and the numbers along the way are messier.

The finished tableau is identical: `1`, `0`, `1`, `0`, `1`, `2`. It has to
be, because row operations do not move the crossing and the crossing is what
the finished tableau names.

Predicting that before you start is the point. The route changes and the
destination does not.

**2.** Rescaling row 1 by 10 makes it 10, 20, 50, which is the same line
written ten times over. `RREF` reduces it straight back, and the answer is
unchanged.

It was never in doubt because rescaling a row is one of the three licensed
moves, and the licence is precisely that it does not change the solution
set.

**3.** Elimination cannot start with a zero in the pivot position, so the
single move needed is the swap ([F2], `SWP`), putting 1, 1, 4 on top.

Then subtract nothing (the new second row already has 0 in the first
column), rescale row 2 by a half to get 0, 1, 3, and clear the 1 above it.
The finished tableau reads `1`, `0`, `1`, `0`, `1`, `3`, so x = 1 and y = 3.

**4.** To undo the last move, add two copies of row 2 back to row 1: store
`2` in `B` rather than `-2` and press `RADD` again.

The tableau returns to 1, 2, 5, 0, 1, 2. Every row operation has an inverse
of the same kind, which is exactly why the solution set cannot move: an
operation that lost information could not be undone.

### 9.3 Norms and the condition number

**1.** Predict 3. The identity stretches nothing, so its Frobenius norm is
root 3 and its inverse is itself, and root 3 times root 3 is 3.

Press `COND` on the identity: `= 3.0000000000001`.

No 3 by 3 matrix can do better, because `COND` is a product of a matrix's
stretch and its inverse's, and for a 3 by 3 the Frobenius norm of a matrix
and of its inverse are each at least root 3. A condition number of 3 means
"as well behaved as this measure allows".

**2.** Nudging the third right-hand side to 3.002 instead of the first
throws the answers a different way: x stays near 1 while y and z take the
strain.

Which unknowns jump depends on which combination of rows the nudge disturbs,
and with near-repeated rows the answer is always that the *differences*
between unknowns absorb it. The size of the jump is the same order as
before, because `COND` is a property of the matrix and not of the
right-hand side.

**3.** Retype the near-repeats as 1.01 and press `COND`: `= 952.70410946948`.

Ten times softer than the 1.001 version's 9490, as you would expect: making
the rows ten times less alike makes the amplification ten times smaller.

Step 8's jump softens by the same factor. The relationship between how
nearly dependent the rows are and how badly the answer moves is linear, and
this is the cheapest way to see it.

**4.** Section 5.2's near-parallel pair was x + 2y = 8 with
1.01x + 2y = 8.05. As a matrix that is 1, 2, 1.01, 2, and its `COND` comes
back in the hundreds.

The well-behaved pair 1, 2, 3, -1 gives a `COND` of a few.

So yes, the number predicts what you saw. `COND` in the hundreds warned of
the two-hundred-per-cent swing, and `COND` of a few promised the one and a
half per cent. Running a system through `COND` before trusting it costs one
keystroke and would have saved section 5.2 a nasty surprise.

### 9.4 Building a frame of your own

**1.** Press [2nd] [8], type 3, 1, 2 into `A`, press [ALPHA], type 1, 1, 1
into `B`, press [ALPHA], and press [F3], `DOT`: `6`.

`MAG` of `B` is `1.7320508075689`, root 3, so its length squared is 3, and
the shadow is 6 over 3, which is 2 copies.

Build 2 copies with `SCL` and subtract with `SUB`, or just do the
arithmetic: (3, 1, 2) minus 2(1, 1, 1) is (1, -1, 0).

Confirm: type (1, -1, 0) into `A` against (1, 1, 1) in `B` and press `DOT`:
`0`, exactly.

**2.** `NRM` divides each vector by its own length, so all three come back
with `MAG` of 1.

An orthonormal frame is what you want whenever you need to express something
in coordinates that do not distort it: rotations, projections, changes of
basis. The dot product with each frame vector gives the component directly,
with no division, because the lengths are already 1.

**3.** Starting with (0, 1, 1) gives a *different* frame. The first vector
is kept as it is, so it fixes the whole construction, and choosing a
different first vector points the frame somewhere else.

It should be different. Gram-Schmidt does not find the frame; it finds *a*
frame, built around whichever direction you hand it first. Both frames span
the same space and neither is more correct.

**4.** (2, 1, 1) is the sum of (1, 1, 0) and (1, 0, 1), so the three are
not independent.

The first two straighten normally. At the third subtraction, removing both
shadows removes the whole vector: what is left is the zero vector, to within
the machine's dust.

Predicting that is the point. Gram-Schmidt on dependent vectors produces a
zero, and a zero vector cannot be normalised, so `NRM` will fail or return
nonsense. That failure is a *test* for independence, and it is how the
process is usually used in practice.

**5.** Both checks come out exactly zero when every number in the
construction terminates in decimal.

Take (1, 0, 0), (1, 1, 0) and (1, 1, 1). The shadows are all 1 over 1, so
every subtraction is exact, and the frame comes out as the three axes with
every dot product exactly 0.

What was special about section 9.4's numbers was the two thirds: a repeating
decimal typed as a rounded one. Choose data whose arithmetic terminates and
the dust never appears.

### 9.5 Eigenvalues and eigenvectors

**1.** By symmetry, 3, 1, 1, 3 keeps the directions (1, 1) and (1, -1): the
first is stretched by 3 + 1 = 4 and the second by 3 - 1 = 2.

Press `EVAL`: the cells read `4` and `2`, as predicted. `EVEC` returns the
two directions normalised, each component plus or minus
`0.70710678118655`, which is 1 over root 2.

Any matrix of the form a, b, b, a keeps those two directions, whatever a and
b are, which is worth knowing.

**2.** For 5, 2, 2, 2 the eigenvalues were 6 and 1. Their sum is 7, which is
the diagonal sum 5 + 2. Their product is 6, and `DET` on the same matrix
answers `= 6`.

Both facts hold for every square matrix: the eigenvalues sum to the trace
and multiply to the determinant. On the 3 by 3 of step 4, the eigenvalues
2, 3, 6 sum to 11, which is 2 + 3 + 6 down the diagonal, and multiply to 36,
which is what `DET` gives.

**3.** 0, -3, 3, 0 is a quarter-turn with a stretch of 3, so it keeps no
real direction at all and its eigenvalues must be a conjugate pair.

Press `EVAL` and both real parts read 0. Press [MORE] for the final
soft-key page and the `IM` lines read 3 and -3.

So the eigenvalues are plus and minus 3i, pure imaginary, which is exactly
what a pure rotation looks like: no real part means no stretching along any
real direction, and the size 3 is the stretch.

**4.** Take the first eigenvector column from step 3 of the section, which
is (0.894, 0.447), and multiply the matrix 5, 2, 2, 2 by it.

By hand: 5(0.894) + 2(0.447) is 5.366, and 2(0.894) + 2(0.447) is 2.683.
Those are 6 times 0.894 and 6 times 0.447.

The machine agrees to the dust the normalisation introduced. Multiplying is
exact arithmetic where the eigenvalue search was iterative, so this is the
right way round to check.

### 9.6 LU as elimination's ledger

**1.** Press `DET` on 3, 1, 0 / 6, 4, 1 / 0, 2, 5: `24`.

Now `LU`. Stepping through gives `3`, `1`, `0`, then `2`, `2`, `1`, then
`0`, `1`, `4`.

Read it in layers. `U` is 3, 1, 0 and 0, 2, 1 and 0, 0, 4. The multipliers
are 2, 0 and 1.

No swap happened, and you can tell before you look: the top-left entry is 3,
which is nonzero, so elimination could start where it stood.

Check the shortcut: the diagonal of `U` is 3, 2, 4, whose product is 24,
matching `DET` exactly with no sign flip.

**2.** From the ledger, row 3 of the original is 0 times row 1 of `U`, plus
1 times row 2 of `U`, plus row 3 of `U`.

That is 0(3, 1, 0) + 1(0, 2, 1) + (0, 0, 4), which is (0, 2, 5). The
original third row, rebuilt from the multipliers without looking at `A`.

**3.** Any matrix with a zero in the top-left needs a swap: 0, 1, 2 / 1, 0,
3 / 2, 1, 0 will do.

Predict the sign relation: one swap flips the determinant's sign, so the
product of the `LU` diagonal will be minus `DET`. Two swaps would put it
back.

Press both keys and check. Getting the prediction right requires counting
the swaps, which the ledger does not label, so you have to spot them by
noticing which original row ended up on top.

**4.** With `L` holding multipliers 2, 0, 1 and `U` as above, solve
Ly = (4, 14, 25) by forward substitution: y₁ = 4, then y₂ = 14 - 2(4) = 6,
then y₃ = 25 - 0(4) - 1(6) = 19.

Now Ux = y by back substitution: 4x₃ = 19 so x₃ = 4.75, then
2x₂ + 1(4.75) = 6 so x₂ = 0.625, then 3x₁ + 1(0.625) = 4 so x₁ = 1.125.

Check with `SOLVE`, putting the right-hand sides down `B`'s first column:
the same three numbers come back.

Two short passes and no elimination at all. That is what the ledger buys,
and doing it once by hand is worth more than any amount of description: the
second right-hand side would cost you the same two passes and no more.

## 12.7 Solutions for Chapter 10

### 10.1 Slope thinking

**1.** A quantity falling at 15 per cent of itself per minute halves after
ln 2 over 0.15 minutes. Press [CLEAR] and spell `LN(2)/.15`:
`= 4.6209812037415`, so about four minutes thirty-seven seconds.

The dose is at `XMIN`, which is -10, so the half-way point sits at
x = -10 + 4.62, which is about -5.38. Trace there and the readout should
show about 4.5, half of 9.

The plot will not put it exactly at 4.5, because Euler undershoots. That
gap is section 10.2's subject.

**2.** With `-.3*Y` the tank empties twice as fast, so it reaches any level
in half the time. Press [CLEAR] and spell `LN(2)/.3`:
`= 2.3104906018707`, exactly half of the previous answer.

The old curve's value at x = 0 was about 1.97. The new one reaches that
value at half the elapsed time, so at x = -5 rather than x = 0.

**3.** `.15*Y` has a positive slope wherever `Y` is positive, so the
solution grows rather than decays, and it grows faster the bigger it gets.

Seeded at 9 it leaves through the *top* of the window almost at once. The
initial condition makes that inevitable: 9 is positive, the rule says
positive quantities increase, and nothing in the equation ever turns that
round.

**4.** The slope depends only on `Y`, so every point at the same height has
the same slope. In the diagram, that means the slope marks are identical
along each horizontal row.

Two solutions started at different *times* are therefore the same curve slid
sideways. That is what an autonomous equation means, and it is why section
10.4's program can ignore x entirely.

**5.** Twice the volume with the same flow loses 7.5 per cent a minute, so
it takes twice as long: press [CLEAR] and spell `LN(2)/.075`:
`= 9.2419624074829`, exactly double the first answer.

Predicting that needs no arithmetic at all. Halving the rate constant
doubles every time in the problem, because the rate constant is the only
thing setting the clock.

### 10.2 The window is the step

**1.** [-] doubles the window to -20 to 20, so the step is 40 over 127.
Press [CLEAR] and type `40/127`: `= 0.31496062992126`, twice the old step.

At x = 0, twenty minutes have passed since the dose at -20. The truth is
9 times e to the minus 3: press [CLEAR] and spell `9*EXP(-3)`:
`= 0.4480836153109`.

The table reads noticeably below that. Predict the direction before you
look: Euler undershoots a curve bending upwards, always, and doubling the
step doubles the shortfall.

**2.** Five minutes after the dose is x = -5 in the standard window. The
step is 0.15748, so -5 is 31.75 steps from the left edge, and the nearest
column is the 32nd, at about x = -4.96.

Trace there and compare with `9*EXP(-.75)`, which answers
`= 4.2512989746699`. The trace will read a little low, by about 1.8 per
cent, which is section 10.2 step 3's figure.

**3.** Storing something in slot 2 changes nothing: the `Y2` column still
reads `-` throughout.

The mode integrates slot 1 alone, as the note at the end of section 10.1
says. Slots 2 and 3 exist because the graph screen has three slots in every
mode, not because this mode can use them.

**4.** Two presses of [+] from standard leave the window at -2.5 to 2.5, so
the dose is at -2.5 and x = 0 is two and a half minutes after it.

The truth there is 9 times e to the minus 0.375, which is about 6.19. So
the `X=0` row should read a little under that, and the value has gone *up*
from 1.972 to about 6.18 without anything about the tank changing at all.

### 10.3 Step-size experiments

**1.** A third press of [+] leaves the window at -1.25 to 1.25, so the dose
is at -1.25 and 3.5 minutes after it is at x = 2.25, which is outside the
window.

The row reads `UNDEF`, because the run is the window. So refining the step
by zooming eventually refines it out of the range you wanted to measure.
That is the trap: the zoom keys control the step and the interval together
and you cannot have one without the other. Section 10.4's program exists
precisely to separate them.

**2.** For a gap under 0.001 at 0.21 times the step, you need the step below
0.001 over 0.21. Press [CLEAR] and type `.001/.21`:
`= 0.0047619047619048`.

From the standard window's step of 0.15748, halving repeatedly:
press [CLEAR] and spell `LN(.15748/.00476)/LN(2)`: `= 5.0480632338422`.

So five halvings gets you close and six is needed to be sure. Six presses
of [+] leaves the window at about -0.16 to 0.16, which is a third of a
minute of tank. The measurement would be impossible.

**3.** Predict doubling: the gap is proportional to the step and the step
doubles, so the gap should go from 0.034 to about 0.068.

Take [-] from standard and look up the 3.5-minute row, remembering that the
dose has moved to -20 so you want x = -16.5. The reading falls further
short than any in the table, and the gap comes out around 0.068.

**4.** The exact solution is 9e^(-0.15t), whose second derivative is
9(0.15)²e^(-0.15t). At 3.5 minutes after the dose that is 0.0225 times
5.324, which is about 0.12, and half of it is 0.06.

That is not 0.21, and the reason is that the constant relates the *global*
error after many steps to the step size, not the local error of one step.
The global constant accumulates over the whole run, which is why it is
several times bigger. Working out which of the two you have measured is the
useful part of the exercise.

### 10.4 An Euler program

**1.** Predict half of 0.026, so about 0.013.

Run at `.0625->H` with `56->N`: `5.310830096248`, against a truth of
`5.3239982793029`. The gap is 0.0132.

Halved again, exactly as first order promises, and the constant gap over
step stays near 0.21 for a fourth time.

**2.** Change line 1 to `18->Y` and run at `.5` and `7`:
`10.429527517055`.

The truth is 18 times e to the minus 0.525: press [CLEAR] and spell
`18*EXP(-.525)`: `= 10.647996558606`. The gap is 0.2185.

That is exactly double the gap from a seed of 9, which was 0.109. So the
error scales with the size of the solution, and it was predictable from line
5: every term in the walk is proportional to `Y`, so doubling the initial
value doubles everything including the error.

The *relative* error is unchanged, which is the more useful way to say it.

**3.** Storing `-.3*Y` and rerunning gives a number well below the truth of
9e^(-1.05), which is about 3.15.

The gap-over-step constant does *not* hold: it roughly doubles, because the
constant depends on the second derivative of the solution, and doubling the
rate constant quadruples that while halving the time scale. Working out
which way those two effects combine is the exercise, and the answer is that
the constant scales with the rate constant.

**4.** Delete line 1 and run twice. The first run starts from whatever the
last plot left in `Y` and gives a wrong answer; the second starts from
wherever the *first run* finished, and gives a different wrong answer.

Two runs of the same program returning different numbers is the clearest
possible demonstration of why line 1 is there. A program that does not seed
its own state is not a program, it is a continuation of whatever happened
before.

### 10.5 Improved Euler

**1.** With line 5 back to `Y+H*EVAL(0)->Y` and `P3` deleted, the driver
alone reproduces `5.2147637585268` at `.5` and `7`, which is section 10.4's
plain Euler exactly.

That proves the improvement lives entirely in `P3`. The driver is
bookkeeping: seed, loop, count, display. Swapping the called slot swaps the
method and touches nothing else, which is the whole argument for splitting
them.

**2.** The midpoint step is: k is the slope at y, go half a step to y + hk/2,
take the slope there, then step a *whole* h from the original y with that
slope.

The line that must remember the original `Y` is the catch. Write it as
`EVAL(0)->K`, then `Y+H*K/2->Y`, then `Y+H*(EVAL(0)-K/2)->Y`... work it out
carefully: after the half step, `Y` holds y + hk/2, and you want to end at
y + h times the new slope. Since y is now y + hk/2, you need to add
h(new slope) minus hk/2, so the third line is
`Y+H*(EVAL(0)-K/2)->Y`.

Four lines again, and it fits.

**3.** At `20/127->H` with `64->N`, improved Euler lands very close to the
true value at the window's middle, while the plot's own walk landed at
`1.9489119504254`.

The difference is around a thousandth of a gram per litre, which on the
screen is a fifth of a pixel. So the plot and the better method are visually
identical and numerically a thousand times apart, which is worth knowing
before you trust a picture.

**4.** Euler undershot and Heun overshot because the tank's solution bends
upwards. For the reverse of both, take a solution that bends *downwards*:
`.15*Y` seeded at a small positive value grows, and its curve bends upward
too, so try `-.15*Y` seeded *negative*, or a rule like `.15*(9-Y)` seeded
above 9.

Test it and you should find Euler now overshoots and Heun undershoots. The
signs follow the curvature, always, and knowing which way a solution bends
tells you which way your integrator will be wrong before you run it.

### 10.6 Growth with a ceiling

**1.** Predict: seeded above the ceiling, the bracket 1 - y/10 is negative,
so the growth rate is negative and the population falls.

It falls towards 10 from above, flattening as it approaches, and it never
crosses. Seeded at 18 the curve drops steeply and then levels along the
same ceiling the rising solution approached from below.

The bracket is what makes it go that way: it is the only factor that can
change sign, and it changes sign exactly at the ceiling.

**2.** The inflection is at half the ceiling, which is 5. Press [CLEAR] and
type `10/2`: `= 5`.

From the table, the rows at `X=-6` and `X=-5` read `4.410` and `5.653`, so
the crossing of 5 sits between them. The steepest growth is in that
interval, which is where the largest difference in the table appeared.

**3.** Doubling k to 1 doubles every growth rate, so the curve reaches the
same shape in half the time: the S is compressed horizontally.

What does *not* move is the inflection *level*: it is still at y = 5,
because K/2 does not involve k at all. The inflection happens earlier and at
the same height.

Predicting which of those two moves is the point of the exercise, and the
answer comes from the formula rather than the picture.

**4.** Press [CLEAR] and spell `10/EXP(1)`: `= 3.6787944117154`, which is
the Gompertz inflection level, against the logistic's 5.

Seeded at exactly 10, `LN(10/Y)` is `LN(1)`, which is 0, so the growth rate
is 0 and the solution sits still forever. That is the ceiling as an
equilibrium, and it works.

Seeded at 0 the rule asks for `LN(10/0)`, and division by zero is where it
ends. The Gompertz model has no meaning at zero population, which is a real
limitation of it: unlike the logistic, it cannot start from nothing.

**5.** The logistic reads `9.439` at `X=0`. To make a Gompertz pass through
the same point, try values of k and watch the `X=0` row.

The two curves will agree at that one point and nowhere else, because they
are different functions. Matching one point of two different models tells
you nothing, and this exercise exists to make that concrete: two curves
through one point can disagree everywhere else, and choosing between models
needs the whole shape.

### 10.7 Equilibria, and the lever that resets them

**1.** Predict: seeded at exactly 3, the bracket 3 - Y is zero, so the rate
is zero and nothing moves. The solution is the constant 3.

Run the reset with `3->Y` and the plot is a flat line at 3, which is the
same flat line the mode drew before any equation was stored. The difference
is that this time it is a genuine solution rather than a receipt for the
seeding.

**2.** `.2*(8-Y)-.5` vanishes when 0.2(8 - y) = 0.5, so 8 - y = 2.5, so
y = 5.5.

Plot it from a seed of 9 and a seed of 2 and both flatten onto 5.5. The
table confirms the level from either side.

Note that the equilibrium is not 8: the constant -0.5 shifts it. An
equilibrium is where the whole right-hand side vanishes, not where the
obvious bracket does.

**3.** The logistic's rate is 0.5y(1 - y/10), which vanishes at y = 0 and
y = 10.

y = 10 is stable: below it the rate is positive and above it negative, so
neighbours come back. y = 0 is unstable: just above it the rate is positive,
so a population near zero grows away from zero.

Check by seeding near each. Seeded at 0.1 the solution climbs away from 0
and heads for 10; seeded at 10.5 it falls back to 10. Two equilibria of
opposite character in one equation, which is exactly what makes the logistic
worth teaching.

**4.** At the eight points around the origin the pair dx/dt = y,
dy/dt = -x gives a direction perpendicular to the position vector, and
always the same way round. So a solution must go round the origin in
circles.

Section 10.8 draws it. Put `Y` in slot 1 and `-X` in slot 2, press [F1]
(`SYS`), and the phase view plots exactly the circles you just deduced. The
deduction is still the valuable half: signs at eight points told you the
answer before the machine drew anything, and that reasoning carries to
systems of any size, which this machine still cannot integrate.

**5.** Take a rate like `.1*Y*(Y-3)*(Y-6)`, which vanishes at 0, 3 and 6.

Between 0 and 3 the product is positive times negative times negative, so
positive: solutions rise towards 3. Between 3 and 6 it is positive times
positive times negative, so negative: solutions fall back to 3. So 3 is
stable, and 0 and 6 are unstable.

Predicting the fate of a solution started in each gap needs only the sign of
the product, which you can do in your head. Checking them all costs three
keys each on the `DEQ SETUP` page: [F3], the [+] or [-] presses that move
`Y0` where you want it, and [F5]. Check every one of them.

### 10.8 Two equations at once, and the phase plane

**1.** The damping term takes energy out, so the ring must close inwards:
a spiral into the origin rather than a closed orbit. That is what you get.

The time trace shows a cosine whose height shrinks, which you could also
have guessed. What the phase picture adds is *where* it is going: every
orbit, from any start, ends at the same point. The origin is an attractor,
and one picture shows that for all starting conditions at once, which no
single time trace can.

**2.** A closed loop, and that is the whole answer. The populations cycle:
prey rise, predators follow, prey crash, predators starve, prey recover.
Because the curve closes rather than spiralling in or out, neither species
dies out and neither settles down. The system is *neutrally* stable, which
is a famous and slightly unrealistic property of this simplest model.

Watch the method here. Euler's outward drift will eventually push the
orbit into extinction and it will look like biology. It is arithmetic.
Check any conclusion against `RK4` before you believe it.

**3.** Euler shows a visible spiral within two or three revolutions. Heun
takes long enough that you will lose count, which is the point.

Section 10.5 measured the orders: halving the step divides Euler's error by
two and Heun's by four. Per revolution the same ratio applies, so if Euler
is obviously wrong after three turns, Heun should take roughly its square,
around nine, and `RK4` far more than you have patience for.

**4.** One revolution of dX/dT = y, dY/dT = -x takes 2 pi units of time.
The view takes 128 samples, so the step wanted is 2 pi over 128, which is
about `0.049`.

The table step halves from 1, so the reachable values are 0.5, 0.25, 0.125,
0.0625, 0.03125. Four halvings gives 0.0625, which draws about 1.27
revolutions; five gives 0.03125 and about 0.64 of one. Neither is exact,
and the near miss is the answer to the question: the step you want is not
a power of two, so you choose between a little more than one loop and a
little less.

## 12.8 Solutions for Chapter 11

### 11.1 The pendulum, and the integral that will not behave

**1.** Predict: a smaller amplitude puts the singularity closer to the lower
limit in relative terms but the interval is shorter, so the panels are
narrower and one of them still lands near the top. The nonsense should
persist and may well get worse, because the spike is just as infinite over a
shorter interval.

Store `PI/12->A` and run `FNINT(0,A)` again. It returns another large
meaningless number. Shrinking the amplitude does not rescue the method,
because the trouble is the shape of the integrand at the endpoint and not
the length of the interval.

**2.** Stopping short of the top keeps the integrand bounded, so the panels
have a fighting chance.

`FNINT(0,A-.01)` answers `= 2.0731870024371` and `FNINT(0,A-.001)` answers
`= 2.283248630129`.

They are climbing towards about 2.31, which is the true value of the
integral. Each step closer to the top adds the sliver you were missing, and
the answers converge from below because you keep leaving out the tallest
part.

**3.** Press [CLEAR] and spell `4*SQRT(2.5/19.6)`: `= 1.4285714285714`,
which is ten sevenths.

Multiply that by step 2's best value, 2.283248630129, and you get about
3.262. Section 11.1's transformed answer was `3.3003427304458`.

They are close and not equal, because the truncated integral is still
missing the sliver nearest the top. Push the cut to A - 0.0001 and the two
routes converge. Same physics, two integrals, one of which the machine can
actually do.

**4.** Press [CLEAR] and spell `COS(.3)-COS(PI/4)`: `= 0.24822970793901`.
Press [CLEAR] and spell `2*(SIN(PI/8)^2-SIN(.15)^2)`: `= 0.24822970793908`.

Twelve digits, which is as close as two different routes through fourteen
digits are going to get. The identity is confirmed numerically as well as
algebraically, and doing that once is worth more than trusting the algebra.

**5.** With `K` at 1 the integrand becomes 1 over the square root of
1 - sin²x, which is 1 over cos x. At x = pi/2 the cosine is zero and the
integrand is infinite again.

So the substitution did not save you from everything: it moved the
singularity from the amplitude to the top of the new range, and at
K = 1 exactly it comes back.

Physically, an amplitude of a half turn is the pendulum balanced exactly
upside down. It takes infinitely long to fall, so the period really is
infinite, and the integral is right to diverge. The mathematics and the
machine agree, and this is the one case in the section where the infinite
answer is the true one.

### 11.2 How wrong is the textbook formula?

**1.** With the corrected term, the rule is 1 plus A²/16 plus 11A⁴/3072.

At 10 degrees it gives `1.0019071814956` against the table's
`1.0019071881423`: agreement to eight decimals where the two-term rule
managed five.

At 30 degrees, `1.0174038622498` against `1.017408797595`: five decimals
where two terms gave three.

At 90 degrees, `1.1760122921022` against `1.1803405990146`: two decimals
where two terms gave none.

So it buys about three rows, not one. Each term roughly squares the range
over which the rule is usable, which is the usual behaviour of a series and
the reason people bother with the third term at all.

**2.** Interpolating between the 10-degree row (0.19 per cent) and the
30-degree row (1.71 per cent) puts one per cent at about 22 degrees.

The series route is sharper: solve 1 + A²/16 = 1.01, so A² = 0.16, so
A = 0.4 radians, which is 22.9 degrees.

They agree to within the interpolation's error, which is what you would
hope: the table is coarse and the series is exact for small angles, and one
per cent is small enough for the series to be trusted.

**3.** The amplitude at which the error reaches one per cent does *not*
depend on the length at all.

The ratio T over T0 involves only k, which is the sine of half the
amplitude. Length and gravity both cancel out of the ratio, appearing only
in the periods themselves. So a garden swing and a grandfather clock reach
one per cent of circular error at the same angle, which is a genuinely
useful thing to know and slightly surprising.

**4.** The table's ratios are climbing ever faster: 1.002, 1.017, 1.073,
1.180, 1.373, 1.762. Extrapolating that trend, a half turn should be well
beyond 2.

It is worse than that: it is infinite. At a half turn the pendulum is
balanced upside down, and it takes forever to start falling, so the period
has no finite value. The trend was heading for a vertical asymptote and the
table stops just short of it.

**5.** No. The integrand 1 over the square root of 1 - k²sin²x is at least
1 for every x, because the denominator is at most 1. So the integral is at
least pi/2, and the ratio is at least 1.

A real pendulum is always slower than its linearisation, never faster, and
that follows from the shape of the integrand without computing anything.

### 11.3 Series against closed forms

**1.** Predict: `1E6` instead of `1E4` stops when the term falls below a
millionth, which is when N passes 1000. So a hundred times as many terms.

The run takes a very long time indeed, and the answer lands near 1.6439,
still short of 1.6449 by about a thousandth. That is the arithmetic of the
gap being one over the term count: a thousand terms buys three decimals, and
you can see why nobody computes pi this way.

**2.** `1/(N*N+N)` is 1/(N(N+1)), which telescopes: it is 1/N - 1/(N+1), so
the sum to N terms is exactly 1 - 1/(N+1), and the closed form is 1.

Four decimals needs 1/(N+1) below 0.00005, so N above about 20000. That is
far worse than the reciprocal squares, and the reason is that the terms fall
like 1/N² but the *tail* falls like 1/N.

Do the paper first and you know the answer before the machine has finished
its first run.

**3.** For a third rather than a quarter, line 4 becomes `(1+S)/3->S`, and
the closed form is a half rather than a third: the sum of (1/3)ⁿ from n = 1
is 1/2.

Predict both from the geometric series formula r/(1-r) before you type
anything.

**4.** `1/N^3` at 10, 40 and 100 terms gives about 1.19753, 1.20196 and
1.20201.

Measure the shorter runs against the longest: the gaps are about 0.0045 and
0.00005. Going from 10 to 40 terms cut the gap by ninety, and 40 to 100 by
another ninety.

The gap falls like one over the *square* of the term count, where the
reciprocal squares fell like one over the count. One extra power in the
denominator buys one extra power in the convergence, which is the general
rule for these sums.

**5.** Summing `1/N` upwards and downwards to a hundred terms gives answers
differing in the tenth or eleventh digit, further apart than the reciprocal
squares managed.

The reason is that 1/N's terms are much bigger relative to the total. The
last term added upwards is 1/100 against a running total near 5, so it is
shifted only three places; but there are many more terms of comparable size
being shifted, so the accumulated loss is larger. The reciprocal squares
fall away so fast that only the first few terms matter at all.

### 11.4 Shooting at a boundary

**1.** Predict halving again: the coarse walk undershot by 0.0204, the
doubled one by 0.0102, so `20/508->H` with `508->N` should undershoot by
about 0.0051.

Run it and shoot again. The inlet lands around 10.13, halfway back to 10
from 10.265. Each halving of the step halves the distance from the true
answer of 10, exactly as a first-order method promises.

**2.** For a consent of 1.5, the closed form gives the inlet as 1.5 over
(1 - 0.6), which is 3.75. Press [CLEAR] and type `1.5/(1-.6)`: `= 3.75`.

Shoot for it with the program and you land near 3.8, high for the same
integrator reason as before.

For a consent of 3, the closed form asks for 3 over (1 - 1.2), which is
negative. There is no answer, and the physics says why: the outlet
concentration of this bed is at most 1 over 0.4, which is 2.5, however much
you feed it. Press [CLEAR] and type `1/.4`: `= 2.5`. A square-law decay over
20 metres cannot deliver more than 2.5 milligrams per litre no matter what
goes in, so a consent of 3 is met automatically and a consent of 3 is not a
constraint at all.

**3.** Aiming on length means line 2 becomes `L/127->H` for your chosen
length L, with `127->N` unchanged and `10->Y` on line 1.

The closed form becomes inlet over (1 + 0.02L times inlet), so with an inlet
of 10 you want 10/(1 + 0.2L) = 2, giving L = 20. That is the length the
section already used, so shooting on length with the original inlet should
return you to 20 metres, which is a useful check that both aiming
directions agree.

**4.** Aiming from one miss means guessing the slope of the miss-versus-seed
relationship rather than measuring it.

It costs more shots, typically two or three extra, and it can diverge if
your guessed slope has the wrong sign. What the second miss buys is exactly
that slope: two points determine the line, and the line is the whole method.

That is the secant method, and it is Newton's method of section 8.2 with the
derivative estimated from two points rather than computed. The connection is
worth noticing: chapter 8 hunted a root of an equation, and this hunts a
root of "the miss as a function of the seed", which is the same problem
wearing different clothes.

**5.** Separating dy/dx = -0.02y² gives -dy/y² = 0.02 dx, so 1/y = 0.02x + C.
With y(0) = c, C is 1/c, so 1/y = 0.02x + 1/c, and

y = c / (1 + 0.02xc).

At x = 20 that is c/(1 + 0.4c), which is step 12's expression exactly.

Deriving it takes two lines and confirms that the closed form the section
pulled out of the air is the honest solution of the equation rather than a
convenient fiction.

### 11.5 Vectors in the round

**1.** The third anchor is at bearing 240 and distance 9. Type 9, 240, 0
into `A` and press `CY>R`.

The components come back as about -4.5 and -7.794, mirroring the second
anchor's -4.5 and +7.794 as the geometry demands.

The guy from the mast top is then (-4.5, -7.794, -12), and its `MAG` is 15,
the same as the other two. It has to be: all three anchors are 9 metres out
and the mast is 12 tall, so all three cables are the hypotenuse of the same
right triangle.

**2.** Predict 10800, by symmetry: the three guys are identical apart from
their bearing, so each pulls the mast top with the same force at the same
distance, and a moment depends only on those.

Press `CRS` with the position (0, 0, 12) in `A` and the second tension
(-450, 779.42286341, -1200) in `B`. Stepping through `R` reads
`-9353.07436092`, `-5400`, `0`.

Different components from the first guy's `0`, `10800`, `0`, because the
moment points a different way. Press `MAG`: `10800.000000024`.

Same size, different direction. That is exactly what three-fold symmetry
means, and it is why the three moments can cancel.

**3.** Predict both before pressing anything. Anchors 6 metres out instead
of 9 make the guys steeper, so more of each tension pulls downward and less
pulls outward: the downward force *increases*.

And the angle between two guys *decreases*, because the tops are unchanged
while the anchors have moved closer together.

Check by rebuilding the vectors with 6 in place of 9 and 12 unchanged. The
cable length falls from 15 to about 13.4, the downward component of each
tension rises, and `ANG` returns less than 62.6 degrees.

**4.** Three coplanar vectors: (1, 0, 0), (0, 1, 0) and (1, 1, 0), all in
the xy plane.

Cross the first two to get (0, 0, 1), then dot with the third: zero. The box
they span is flat, so its volume is nothing.

Nudge the third to (1, 1, 0.001) and the triple product becomes 0.001. It
stops being zero immediately and in proportion to the nudge, which makes it
a usable test rather than a knife edge: a small triple product means nearly
coplanar, and how small tells you how nearly.

**5.** Two guys and the mast are (9, 0, -12), (-4.5, 7.794, -12) and
(0, 0, 12).

Cross the two guys and dot with the mast. The answer is the volume of the
box those three span, and it is large: the two guys are well separated in
direction and the mast is a long way from their plane.

A small answer would mean the three are nearly coplanar, which would mean
the mast lies nearly in the plane of two of its guys. That is exactly the
configuration in which the guying fails: a mast braced by wires that all
lie in one plane with it has no restraint at all perpendicular to that
plane. So the triple product is a bracing quality measure, and bigger is
better.
