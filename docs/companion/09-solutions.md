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
