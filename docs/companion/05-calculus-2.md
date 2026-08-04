# Chapter 5: Explorations in Calculus II

The second course in calculus widens the field of play: equations whose
roots must be hunted rather than factored, curves that refuse to be the
graph of any function, motion through time, functions built out of
integrals, and polynomials impersonating transcendental functions. Free85
keeps a tool for each: the polynomial editor and solver workspace of the
Guidebook, chapter 14, the polar and parametric modes of the Guidebook,
chapters 5 and 6, and the calculus commands of the Guidebook, chapter 3. The
habit from Chapter 4 (Explorations in calculus I) still governs: the
calculus commands read the active stored equation after one completed plot,
so store with [GRAPH], let the plot draw to the end, and press [CLEAR] at
home before typing a command, because the graph hands its equation back to
the entry line. Every key sequence and every quoted number in this chapter
was run in the emulator on a fresh machine, and each exploration ends with a
"Try it" block whose answers stay on the calculator.

## 5.1 Zeros of functions two ways

Factoring finds the roots the algebra teacher chose; most polynomials met in
the wild need a hunter. Free85 keeps two: the polynomial editor, answering
every root of a polynomial at once, and the solver workspace, hunting one
root of any equation whatever. The specimen is designed on paper:
multiplying x^2 - 2 by x^2 - 2x - 2 gives the quartic x^4 - 2x^3 - 4x^2 + 4x
+ 4, whose roots are knowable in advance, plus and minus the square root of
2 and 1 plus or minus the square root of 3.

1. Press [2nd] [PRGM], the `POLY` legend, and the polynomial editor opens on
   a fresh `DEGREE 2`. Press [F4], `QRT`, for degree 4, and type the
   coefficients highest power first, [ENTER] after each: [1] [ENTER], [(-)]
   [2] [ENTER], [(-)] [4] [ENTER], [4] [ENTER], [4] [ENTER]. The `COEFF`
   line steps down a power per entry.

2. Press [F1], `SOLV`, and give the search a few seconds. The root browser
   replaces the editor:

   ![The quartic's root browser opening on 1 plus root 3](images/co05-poly-roots.png)

   `ROOT 1` shows `RE 2.7320508075688` with `IM 0`: the root 1 plus root 3,
   one digit of dust short of the paper value. Press [▶] three times for the
   rest: `ROOT 2` is `RE -0.73205080756887`, `ROOT 3` is
   `RE -1.4142135623731`, and `ROOT 4` is `RE 1.4142135623731`, every `IM`
   line reading `0`. Four roots, one press of `SOLV`.

3. Now the same roots one at a time. Press [EXIT] for the home screen, type
   `X^4-2*X^3-4*X^2+4*X+4` (the [x²] key types `^2`), and press [2nd]
   [GRAPH]: the solver workspace opens with the equation stored, the `F=`
   line clipping at the screen's edge with the tail kept. Press [F1],
   `SOLV`, and let it work: a `ROOT` of `-1.4142134785654` with `RES`
   `-6.704614E-7`. From the fresh guess 0 and bounds -10 to 10, the scan
   stops at the first sign change from the left: minus root 2.

4. The bounds are the fence that picks a root. Press [F5], the `>` key,
   three times to reach the `LOWER` page, and store bounds 0 and 2: [0]
   [ENTER], [2] [ENTER]. `SOLV` answers a `ROOT` of `1.4142136573793`.
   Re-fence at 2 and 5 the same way and `SOLV` answers a `ROOT` of
   `2.7320508360865` with `RES` `5.39787E-7`, the browser's first root
   re-found by hunt. The guess is tried before any scanning, so it picks
   roots too: page to `GUESS`, type the browser's own `1.4142135623731`,
   press [ENTER], and `SOLV` answers it back with `RES` `0`.

5. What the editor cannot do is leave polynomials. Press [EXIT] and [CLEAR],
   type `COS(X)-X`, and press [2nd] [GRAPH]: `SOLV` answers a `ROOT` of
   `0.7390856742858`, the one crossing of cosine and the line, a number no
   polynomial tool can reach. So: `POLY` for polynomials of degree 2 to 4,
   the release ceiling, all roots at once with no guessing; the solver for
   everything else, one root per hunt, steered by guess and bounds.

**Try it.**

1. Design your own quartic by multiplying two quadratics on paper, expand
   it, and let `POLY` recover the roots you built in.
2. Give `POLY` the quadratic x^2 + 2x + 3, then give the solver the same
   equation. One answers a conjugate pair, the other stops at a notice: what
   is each tool telling you?
3. Aim the solver at the quartic with bounds -5 and 0 and guess 3. Which
   negative root does the scan report, and how do you fence in the other?

## 5.2 Conic sections by parametric pair

A circle fails the vertical line test, so no function slot can draw one; the
parametric mode of the Guidebook, chapter 6 can, because it plots any pair
x(t), y(t). The pair A*COS(t), B*SIN(t) sweeps an ellipse with half-width A
and half-height B, and this section's story is a garden design, an
ornamental pond 10 metres by 5 at one metre per unit: A is 5, B is 2.5.

1. Switch modes: on the graph screen press [2nd] [MORE], then [MORE] twice
   to the `GRAPH MODE` page, press [F3] for parametric, and [EXIT]. Slot 1
   is x(t), slot 2 is y(t), and [x-VAR] types the parameter, shown as `X`.
   Type [5] [×] [COS] [x-VAR] [)] so the entry line reads `5*COS(X)`, and
   press [GRAPH]; nothing draws yet, because a pair needs both slots. Press
   [2nd] [2], type `2.5*SIN(X)`, and press [GRAPH] again. Both slots
   evaluate at every sample, roughly doubling the plot time; let it run to
   the end. The pond appears squashed: the pixels are not square.

2. Press [2nd] [-], the square window, and let the replot finish; now one
   unit is the same length on both axes and the ellipse shows its true
   proportions, twice as wide as tall:

   ![The 10 by 5 pond ellipse in the square window](images/co05-pond-ellipse.png)

3. Press [▶] once and the readout gives `X=4.861147193253` and
   `Y=0.58507434688468`: a rim point one sample past the sweep's centre. The
   rim's equation says (x/5)^2 + (y/2.5)^2 must be 1, so put the readout on
   trial: press [EXIT], press [CLEAR], type
   `(4.861147193253/5)^2+(.58507434688468/2.5)^2`, and press [ENTER]. The
   answer is `= 1`, exactly: the traced point sits on the designed ellipse
   to all fourteen digits.

4. Where did the sweep come from? Parametric mode has no angle settings: t
   runs from `XMIN` to `XMAX` in 128 samples, so the window doubles as the
   parameter range. The standard window sweeps t from -10 to 10, over three
   revolutions of the rim (the square window kept those bounds); a window
   narrower than one full turn leaves the rim partly drawn.

The mode holds one pair, so a pond and its path are two plots. One more
boundary of this release is worth designing around: the polar and parametric
plotters drop any point landing in the rightmost fifth of the screen, past
about x = 5.8 in the standard window. A 12 by 6 pond, stored as `6*COS(X)`
and `3*SIN(X)`, plots with its rightmost arc missing. Keep A within 5 in the
standard window and every point is drawn.

**Try it.**

1. Retype the pair as a fountain basin 8 metres across and 8 deep, plot it
   in the square window, and check a traced point against the circle's
   equation the way step 3 did.
2. Swap the pond's pair, `2.5*COS(X)` and `5*SIN(X)`. Predict the picture
   before the plot finishes.
3. From the square window press [+] twice, letting each replot settle, and
   explain what changed, remembering that the window is also the sweep and
   that the rightmost columns are off limits.

## 5.3 Polar curves

Some curves are unwieldy in x and y but a single line in polar form, where
each point is named by its distance r from the origin at angle theta.
Free85's polar mode stores r as a function of the angle, typed with [x-VAR],
and always sweeps exactly one revolution, 0 to 2 pi in `RAD` mode in 128
samples, whatever the window shows. This section draws a rose, a cardioid,
and a spiral, then reads an equation off the trace.

1. On the graph screen press [2nd] [MORE], then [MORE] twice, then [F2] for
   polar mode, and [EXIT]. Type [4] [×] [SIN] [2] [x-VAR] [)] so the entry
   line reads `4*SIN(2X)`, and press [GRAPH]; trigonometry makes this a slow
   plot, so let it sweep to the end. Then press [2nd] [-] for the square
   window and let the replot finish:

   ![The four-petal rose of 4*SIN(2X)](images/co05-polar-rose.png)

   Doubling the angle folds the revolution into four petals on the
   diagonals.

2. The cardioid. Press [EXIT] (the graph hands `4*SIN(2X)` back to the entry
   line), press [CLEAR], type `2.5*(1+COS(X))`, and press [GRAPH]: a heart
   lying on its side, cusp at the origin, in the kept square window. The
   design says the radius is 5 at angle 0 and 0 at angle pi. Press [EXIT],
   press [CLEAR], and ask `EVAL(0)`: `= 5`. Ask `EVAL(PI)` (the `π` legend
   on [2nd] [^]): `= -0.000010419523`, the cusp under the machine's
   fourteen-digit trigonometric dust (the `SIN(PI/2)` small print of the
   Guidebook, chapter 3).

3. The spiral. Press [CLEAR], type `X/2`, and press [GRAPH]:

   ![The spiral X/2 stopping after one revolution](images/co05-polar-spiral.png)

   The radius grows with the angle, half a unit per radian, and the curve
   winds outward until the single revolution is spent, stopping mid-air at
   radius pi on the positive x axis. The abrupt end is the design boundary
   stated plainly: the sweep is one revolution, always, so a spiral of many
   turns is beyond the mode; what there is of it is exact.

4. Read the spiral's equation off the screen. Press [▶] once: the readout
   shows `X=-1.6034808029742` and `Y=-0.1192134330108`, the Cartesian point
   just past the sweep's centre. Now press [2nd] [MORE], then [MORE] twice,
   and press [F5], the coordinate toggle, flipping the mode page's
   `GRAPH COORD` line from `RECT` to `POLAR`. Press [EXIT] and let the
   replot run to the end before touching the arrows; presses that arrive
   mid-draw are dropped. Press [▶] once: the same position now reads
   `X=1.6079017518373` and `Y=3.2158035036746`, the radius in the `X=` line
   and the angle in the `Y=` line, labels unchanged (the Guidebook, chapter
   5). The radius is exactly half the angle, to all fourteen digits: the
   trace has recited `r = theta/2`, the equation the slot was given.

**Try it.**

1. Replot the rose as `4*SIN(3X)` and count petals. What does tripling the
   angle do that doubling did not?
2. Predict which way the cardioid `2.5*(1-COS(X))` faces, plot it, and
   confirm its cusp with `EVAL(` at the angle where you expect it.
3. With the polar readout still on, trace the spiral onward and check the
   half-the-angle rule at each stop.

## 5.4 Parametric motion

A parametric pair is a motion, not just a shape: t is time, and the trace
key becomes a slow-motion replay. This section's projectile is a pebble from
a garden sling, launched from level ground at 3 metres per second
horizontally and 9 vertically, with gravity rounded to 10: x(t) = 3t and
y(t) = 9t - 5t^2. On paper the pebble lands when y is 0 again, at t = 1.8
seconds, 5.4 metres out.

1. In parametric mode (section 5.2's mode switch), store the motion: `3*X`
   in slot 1, then [2nd] [2] and `9*X-5*X^2` in slot 2. Let the plot finish:

   ![The pebble's flight from 3*X and 9*X-5*X^2](images/co05-projectile.png)

   The arc rises from the origin and returns to the axis. The tail diving
   off the lower left is not a mistake: the standard window sweeps t from
   -10 to 10, so the machine also plots the model's pre-launch fiction. The
   window is the time range; it does not know when the story starts.

2. Trace is time, each press one sample of t, about 0.16 seconds. Press [▶]
   five times, one press at a time: `X=2.598425196849` and
   `Y=4.044268088536`, the pebble near the top of its arc. Continue to the
   tenth press, `X=4.960629921261` and `Y=1.210862421722`, and the eleventh,
   `X=5.433070866141` and `Y=-0.099820199638`. Between those samples the
   `Y=` line changes sign, so the pebble lands between 4.96 and 5.43 metres
   out, and finer answers need finer tools.

3. The apex, exactly. The analysis keys and commands read the active slot as
   a function of t, and slot 2, stored last, is active. Press [F1], the root
   hunt: it answers `= 3E-21` with `R=2.7E-20`, the launch, not the landing.
   Press [CLEAR] and ask `FMAX(0,2)` instead: `= 0.8999585312886`, the apex
   time, a search's whisker under the paper answer 0.9. Press [CLEAR] and
   ask `EVAL(.9)`: `= 4.05`, the apex height in metres.

4. The landing, exactly, from the solver. Press [CLEAR], type `9*X-5*X^2`,
   and press [2nd] [GRAPH]. The fresh guess 0 already solves the equation
   and would hand back the launch, so move it: press [F5] twice to the
   `GUESS` page, store 2, then bounds 1 and 3. `SOLV` answers a `ROOT` of
   `1.7999999523165`: the flight lasts 1.8 seconds. Press [EXIT], press
   [CLEAR], and type `3*1.8`: `= 5.4` metres, the range the paper predicted.

The mode holds one pair, so two pebbles cannot fly together; and zooming
reframes time as well as space. The window is the clock.

**Try it.**

1. Sling a pebble at 2 metres per second horizontally and 12 vertically.
   Find its apex and landing point with the tools of steps 3 and 4, checking
   the landing against paper.
2. The apex time 0.9 is exact on paper. Why does `FMAX(` stop a whisker
   short? (Chapter 4's extremum searches told the story.)
3. Launch from a 2-metre wall at 2 metres per second horizontally: the pair
   is `2*X` and `2+9*X-5*X^2`. Where does the trace say the pebble lands,
   and what guess and bounds make the solver agree?

## 5.5 Functions defined by integrals

An integral with a variable upper limit is a function: A(x), the area
accumulated under a curve from a fixed start out to x. The machine has no
accumulator button, but `FNINT(` probed at several x is exactly that
function, one value per call; the second specimen below is chosen so the
accumulator turns out to be an old acquaintance.

1. Accumulate under f(t) = 2t first. Type [2] [×] [x-VAR], press [GRAPH],
   and let the plot finish; press [EXIT], then [CLEAR]. Spell `FNINT(0,1)`
   (letters are [ALPHA] plus the key carrying each letter) and press
   [ENTER]: `= 1`. Pressing [CLEAR] before each, ask `FNINT(0,2)`,
   `FNINT(0,3)`, and `FNINT(0,2.5)`: the answers are `= 4`, `= 9`, and
   `= 6.25`. The pattern names itself: the accumulator of 2t is x squared.

2. Now the interesting curve: press [CLEAR], type `1/X`, press [GRAPH], and
   let the plot finish. The accumulator starts at 1, where the curve is
   friendly: press [EXIT], press [CLEAR], and ask `FNINT(1,2)`:
   `= 0.6931471824209`.

3. That number has a famous face. Press [CLEAR] and ask `LN(2)`:
   `= 0.69314718056122`. The area probe matches the logarithm to eight
   decimals, the difference being `FNINT('s` 64-panel dust (the Guidebook,
   chapter 3). The accumulator of 1/t is the natural logarithm.

4. Watch the logarithm's law appear. Pressing [CLEAR] between probes, ask
   `FNINT(1,4)` and `FNINT(1,8)`: the answers are `= 1.3862945205897` and
   `= 2.0794461816072`. Each doubling of the upper limit added the same
   0.6931 again: equal ratios accumulate equal areas, the whole personality
   of a logarithm.

5. The sharpest form of that claim: the area from 3 to 6 should equal the
   area from 1 to 2, both being doublings. Press [CLEAR] and ask
   `FNINT(3,6)`:

   ![The area from 3 to 6 matching the area from 1 to 2](images/co05-accumulator.png)

   The answer is `= 0.69314718242103`, agreeing with step 2's probe in every
   displayed digit: two differently shaped slabs, equal because both are
   doublings.

One route is closed, and knowing it saves a reset: a graph slot cannot hold
`FNINT(`. In this release a slot storing `FNINT(0,X)` stops the plot at the
`NO NUMERIC RESULT` notice, the notice returns with every repaint, and no
key recovers the machine short of a reset. Programs are no way around: they
may call `FNINT(` freely, but the run screen shows only the most recent
`DISP` (the Guidebook, chapter 16). The hand-built table is the design to
work within.

**Try it.**

1. Tabulate the accumulator of `3*X^2` from 0 at x = 1, 2, 3, 4 and name the
   function you have built.
2. From your probes of 1/X, check that `FNINT(2,8)` equals `FNINT(1,8)`
   minus `FNINT(1,2)` before asking the machine, then ask it.
3. Find another pair of intervals with the ratio 2, nowhere near this
   section's, and confirm the equal-area rule with two probes.

## 5.6 Indeterminate forms by table

When the top and bottom of a fraction both head for 0, the quotient's fate
is genuinely undecided: 0/0 can settle anywhere, and only the route taken
decides where. The same holds when both head for infinity. Chapter 4 probed
limits with the table; here the same tool takes on the two indeterminate
forms, one specimen of each.

1. The 0/0 specimen divides e to the 2x minus 1 by x, undefined at 0, where
   top and bottom both vanish. Type it as `(EXP(2X)-1)/X` ([2nd] [LN] types
   `EXP(`; the exponential makes this a slow plot, so let it finish), and
   press [MORE] on the graph screen for the table. The `X=0` row reads
   `UNDEF`, and the unit-step rows below grow ferociously: `6.389`, `26.79`,
   `134.1`, `744.9`, `4405.` in the five-character cells. Far from 0 the
   exponential simply runs away.

2. Press [-] four times, halving the step to 0.0625. The rows now read
   `2.130`, `2.272`, `2.426`, `2.594`, `2.778` beneath the unmoved `UNDEF`:
   from the right, the quotient slides down towards 2. Press [▲] once for
   the left side: from `X=-0.31` the rows read `1.487`, `1.573`, `1.667`,
   `1.769`, `1.880`, climbing towards the same 2 from below. Both roads
   point at the derivative of e to the 2x at 0, wearing a disguise. Press
   [▼] to bring the table back to its 0 anchor before moving on.

3. The infinity-over-infinity specimen is (3x^2 + 5x)/(x^2 + 4), where top
   and bottom both blow up. Press [EXIT] and let the plot redraw, then
   [EXIT] again and [CLEAR], type `(3*X^2+5*X)/(X^2+4)`, and press [GRAPH].
   Press [MORE]: the table reopens with the step still 0.0625, position and
   step being kept across equations. Press [+] four times for step 1, and
   the rows read `0`, `1.6`, `2.75`, `3.230`, `3.4`, `3.448`: the quotient
   climbs through 3 and keeps going, overshooting.

4. Growing steps are the zoom-out this form needs. Press [+] eight more
   times, doubling the step out to 256: the rows read `3.019` at 256,
   `3.009` at 512, `3.006` at 768, `3.004` at 1024, and `3.003` at 1280. The
   overshoot has drained away and the far right of the table settles onto 3,
   the ratio of the leading coefficients. As in chapter 4, the probes point
   and the algebra pins: dividing top and bottom by x^2 proves it.

**Try it.**

1. Probe `(1-COS(X))/X^2` at 0 with halved steps from both sides. This 0/0
   settles somewhere new: where?
2. Probe `(2*X^2-3*X)/(5*X^2+1)` with doubled steps. What limit do the
   leading coefficients predict, and how far out must the table go before
   two cells in a row agree with it?
3. Build a 0/0 quotient of your own design that settles at exactly 7, and
   verify it by table.

## 5.7 Improper integrals

An integral to infinity is a limit in disguise: the area out to b, as b
grows without bound. Some settle, some do not, and a machine confined to
finite bounds can still gather the decisive evidence. The convergent
specimen is 1/x^2 from 1 onward, whose area out to b is 1 - 1/b: it should
settle on 1.

1. Store `1/X^2`, press [GRAPH], let the plot finish, press [EXIT], and
   press [CLEAR]. Probe with growing bounds, [CLEAR] between probes:
   `FNINT(1,10)` answers `= 0.90004882475237`, close to the paper value 0.9.
   But `FNINT(1,100)` answers `= 1.0990950153906` where paper says 0.99, and
   `FNINT(1,1000)` answers `= 5.313753753657` where paper says 0.999. The
   probes did not fail; they were stretched. `FNINT(` spreads 64 panels
   across any interval (the Guidebook, chapter 3), and a thousand-unit
   interval starves the spike near 1 that holds nearly all the area.

2. The honest route keeps every probe short: walk to infinity in octaves.
   Pressing [CLEAR] between probes, ask `FNINT(1,2)`, `FNINT(2,4)`,
   `FNINT(4,8)`, and `FNINT(8,16)`: the answers are `= 0.50000000769193`,
   `= 0.2500000038458`, `= 0.12500000192296`, and `= 0.062500000961443`.
   Each doubling of distance halves the slab, and the running totals, 0.5,
   0.75, 0.875, 0.9375, climb the geometric staircase whose top is 1: the
   integral converges.

3. Now the contrast. Press [CLEAR], store `1/X`, let the plot finish, press
   [EXIT], and press [CLEAR]. The same octave walk answers
   `= 0.6931471824209` for `FNINT(1,2)`, `= 0.6931471824212` for
   `FNINT(2,4)`, and `= 0.69314718242097` for `FNINT(4,8)`: section 5.5's
   logarithm constant, every octave the same. The slabs refuse to shrink,
   the total climbs by 0.693 per octave forever, and the integral diverges.
   Convergence was never about the curve heading to zero; 1/x heads to zero
   too. It is about how fast the slabs thin out.

**Try it.**

1. Octave-walk `1/X^3` from 1. By what factor does each slab shrink, and
   what total do the running sums point at?
2. Ask `FNINT(1,1000)` on `1/X^3` and compare it with the octave story.
   Which evidence do you trust, and why?
3. The other kind of trouble sits at the near end: probe `1/SQRT(X)` with
   `FNINT(.25,1)`, then shrinking lower bounds. Do the areas settle, and
   where?

## 5.8 Polynomial approximation

Polynomials are the only functions arithmetic can touch directly, so every
machine's sine is secretly a polynomial's impersonation of one. The
impersonators are built from a function's derivatives at one point; for sine
at 0 the recipe gives x, then x - x^3/6, then x - x^3/6 + x^5/120, each new
term paying for a wider stretch of agreement. Free85's three slots hold a
target and two impersonators side by side.

1. Store `SIN(X)` and let the slow plot finish. The standard window flattens
   a sine: press [2nd] [GRAPH] on the graph screen for the zoom panel, press
   [MORE], then [F5], the trigonometric window, and let the replot run to
   the end.

2. Press [2nd] [2], type `X-X^3/6`, and press [GRAPH]; then [2nd] [3], type
   `X-X^3/6+X^5/120`, and press [GRAPH], letting each replot finish (whole
   powers, inside `^`'s range; the factorials typed as divisors):

   ![The sine with its degree-3 and degree-5 impersonators](images/co05-taylor-slots.png)

   Near the origin three curves travel as one. The cubic peels off first,
   diving where the sine turns; the quintic holds the pose almost a full
   half-wave longer before shooting skyward.

3. The table says where the company parts. Press [MORE] and read the rows:
   at `X=1` the columns `Y1 Y2 Y3` read `0.841`, `0.833`, `0.841`, the
   quintic already faithful to the cell's precision. At `X=2` they read
   `0.909`, `0.666`, `0.933`; at `X=3` the cubic has left the stage at
   `-1.5` against the true `0.141`, while the quintic still offers `0.525`.
   By `X=5` the pretence is over everywhere: `-0.95`, `-15.8`, `10.20`.

4. The commands put numbers on the parting. Press [EXIT] to leave the table
   and let the plot redraw to the end, then press [EXIT] again and [CLEAR]
   (slot 3, stored last, is the active equation): `EVAL(2)` answers
   `= 0.93333333333337`, and typing `SIN(2)` answers `= 0.90929742646148`.
   At 2 radians the quintic is generous by 0.024. Every impersonator is
   local: agreement near 0, bought at any price elsewhere.

Three slots shape the comparison: a target and two rivals at a time. The
degree-1 impersonator, the plain line `X`, sat this plot out; swapping it in
is a one-slot edit, the family growing three at a time as in Chapter 1
(Explorations in Precalculus).

**Try it.**

1. Replace the cubic with the line `X` and read from the table how far the
   plainest impersonator stays within 0.01 of the sine.
2. Build the cosine's impersonators `1-X^2/2` and `1-X^2/2+X^4/24` against
   `COS(X)` and find where each parts company by table.
3. Extend the recipe one more term, `X-X^3/6+X^5/120-X^7/5040`, in slot 2,
   and measure with `EVAL(` and `SIN(` how much further the degree-7
   impersonation holds at 2 and at 3 radians.