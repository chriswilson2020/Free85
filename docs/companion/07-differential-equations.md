# Chapter 7: Explorations in Differential Equations

Most of the equations in this book say what a quantity *is*. A differential
equation says only how fast it is changing and leaves you to reconstruct
the quantity from that. Free85 reconstructs it the plainest way there is:
it starts at a known point and walks forward in small straight steps, which
is Euler's method and the whole of the machine's numerical story. That
plainness is the opportunity, because every choice the method makes is
visible, its error can be measured against solutions you work out yourself,
and the program environment of Chapter 4 (Explorations in Calculus I) can
be pointed at the same equation to see whether a cleverer step does better.
The mode is the Guidebook, chapter 7; programs are the Guidebook, chapter
16. Every key sequence and every quoted number here was run in the emulator
on a fresh machine, and each exploration ends with a "Try it" block whose
answers stay on the calculator.

Three habits carry the chapter. The initial value is seeded from the
ordinary variable `Y` when the mode is first entered, so store it *before*
switching modes. The entry line never clears itself: the home screen hands
the stored slope back whenever you leave the plot, and [GRAPH] stores
whatever the line holds, so an empty line pressed into [GRAPH] wipes the
equation. And every plot must be left to draw to its end, since integrating
one column at a time is slow work and presses arriving mid-draw are dropped.

## 7.1 Slope thinking

A differential equation is a rule for the tangent. Write dy/dx = f(x, y)
and you have been handed, at every point of the plane, the direction a
solution through it must set off in. Nothing has been solved; a direction
has been posted at every address, and reading those directions before
touching the machine is most of the skill.

The model for this chapter is a mixing tank of my own design. A 500-litre
tank has been dosed to 9 grams of tracer dye per litre; clean water runs in
at 75 litres a minute and the stirred mixture runs out at the same rate, so
each minute the tank loses 75/500, or 15 per cent, of the dye it happens to
hold. With y for the concentration in grams per litre and x for the time in
minutes, the rule is dy/dx = -0.15y.

1. Read the rule before solving it. Type [(-)] [.] [1] [5] [×] [9] and
   press [ENTER]: `= -1.35`, the rate of fall at the moment of dosing.
   Press [CLEAR] and ask the same at a third of the dose, [(-)] [.] [1] [5]
   [×] [3] [ENTER]: `= -0.45`. The slope shrinks in exact proportion to
   what is left, which already gives the shape: a steep drop flattening
   into a long tail, never reaching zero, because the rule stops pushing
   when nothing is left to push.

2. Seed the initial value. Press [CLEAR], type [9] [STO▶] [ALPHA] [0] (the
   letter `Y`), and press [ENTER]: `= 9`.

3. Press [CLEAR], then [GRAPH] for the graph screen, then [2nd] [MORE] for
   the format page and [MORE] twice more for the page reading
   `FN POL PAR DEQ GC`. Press [F4], `DEQ`, and let the replot finish. A
   flat line sits high in the window: with no slope stored the mode carries
   the seeded 9 straight across, which is the receipt for the seeding. That
   value is now the frozen initial condition, and storing a new number into
   `Y` changes nothing; section 7.6 has the lever that resets it.

4. Press [EXIT] for the home screen, where the entry line is empty. Type
   [(-)] [.] [1] [5] [×] [ALPHA] [0] so the line reads `-.15*Y`, and press
   [GRAPH]:

   ![The tank's dye concentration falling across the window](images/co07-tank-decay.png)

   Let the plot finish. The solution starts at the left window edge and
   walks right, which fixes the arithmetic of the whole chapter: the tank
   is dosed at `XMIN`, so elapsed time is x + 10 in the standard window.

5. Read the story off the curve. Press [▶] once: `X=0.236220472438` with
   `Y=1.9028746602579`, so ten and a bit minutes after dosing a fifth of
   the dye is left. Press [◀] once, letting the readout settle:
   `X=0.078740157478` with `Y=1.9489119504254`. A column is worth about a
   twentieth of a gram per litre here, a fifth of its worth at the left
   edge where the walk begins.

Slots 2 and 3 exist here but the plot ignores them (the Guidebook, chapter
7): one first-order equation is what the mode integrates, so the habit of
stacking a family three at a time, learned in Chapter 1 (Explorations in
Precalculus), does not travel to this mode.

**Try it.**

1. Work out on paper how long the tank takes to fall to half its dose, then
   find the same half-way point on the plot with [◀] and [▶] and compare.
2. Store `-.3*Y` instead (press [EXIT], then [CLEAR], then retype) and
   replot. Where on the new curve does the solution reach the value the old
   one reached at x = 0?
3. Predict the plot of `.15*Y` before pressing [GRAPH], then draw it. Which
   edge of the window does the curve leave by, and why does the initial
   condition make that inevitable?

## 7.2 The window is the step

Euler's method needs a step size and Free85 never asks for one. It takes
the step from the window: the solution is sampled once per plotted column,
so the step is the window's width divided by 127. No setting overrides it
and no tolerance tightens it (the Guidebook, chapter 7), which makes the
zoom keys this mode's numerical controls.

1. With the tank's solution plotted, press [MORE] for the table. The `Y1`
   column holds the integrated solution: `X=0` reads `1.972`, then `1.694`,
   `1.455`, `1.250`, `1.074`, `0.923` at `X=5`. Press [▲] to page back five
   rows: `X=-5` reads `4.213`, and the page runs down to `1.972` again.

2. Press [EXIT] to leave the table and let the plot redraw, then [EXIT]
   again for the home screen. It hands `-.15*Y` back to the entry line and
   publishes `= 1.9724874982123`, the last value the table worked out: the
   fourteen-digit face of the `1.972` cell, whose five-character column
   truncated the rest away.

3. Press [CLEAR] and measure the step: [2] [0] [÷] [1] [2] [7] [ENTER]
   gives `= 0.15748031496063`, twenty units of x across 127 intervals. A
   quantity falling at 15 per cent of itself per minute is 9 times e to the
   power -0.15t after t minutes, and the `X=0` row is t = 10, so press
   [CLEAR] and type [9] [×] [2nd] [LN] (which inserts `EXP(`) [(-)] [1] [.]
   [5] [)] [ENTER]: `= 2.0081714413361`. Euler is low by about 0.036, or
   1.8 per cent, because each straight step leaves along the tangent and
   the tangent falls away below a curve bending upwards.

4. Halve the step by halving the window. Press [CLEAR], retype
   [(-)] [.] [1] [5] [×] [ALPHA] [0], and press [GRAPH] to store the
   equation back and replot. Then press [+] once and let the replot finish:

   ![The same equation in the halved window](images/co07-narrow-window.png)

5. Press [MORE] for the table. The `X=0` row now reads `4.232`, not
   `1.972`. Nothing about the tank has changed; the *experiment* has. Press
   [▲] to page back: `X=-5` reads `9`, the initial condition itself, and
   every row above reads `UNDEF`. Narrowing the window did not zoom in on
   the old solution, it re-based the run, so `X=0` is now five minutes
   after the dose rather than ten.

6. Press [EXIT] twice for the home screen and press [CLEAR]. Type [1] [0]
   [÷] [1] [2] [7] [ENTER]: `= 0.078740157480315`, exactly half the old
   step. Press [CLEAR], retype the equation, press [GRAPH], then [2nd] [+]
   for the standard window, and let the replot finish.

Two things moved between step 3 and step 5, and only one was the step size:
the run got shorter as well as finer, so the comparison proves nothing on
its own. Section 7.3 turns it into a controlled measurement.

**Try it.**

1. From the standard window press [-] once for the doubled window and read
   the `X=0` row. What is the step now, and how far from the truth at
   twenty minutes does the reading fall?
2. Work out from step 3's figure which column of the standard window lands
   closest to five minutes after the dose, trace to it, and compare with
   the exact value that `9*EXP(-.75)` gives.
3. The `Y2` and `Y3` columns read `-` throughout. Store something in slot 2
   with [2nd] [2], see what the column does, and explain it from the note
   closing section 7.1.

## 7.3 Step-size experiments

To measure how a method converges you hold the question still and vary only
the step. Here the question is "what is the concentration 3.5 minutes after
dosing", and the step halves when the window does. The complication is that
halving the window moves the dosing point too, so 3.5 minutes after the
dose sits at a different `X` in each: -6.5 in the standard window, -1.5 in
the halved one, 1 in the one after that.

1. In the standard window press [MORE] for the table, which opens where
   section 7.2 left it, at `X=-10` in steps of 1. Press [-] once to halve
   the table step to 0.5, then press [▼] once to page down five rows:

   ![The 3.5-minute reading in the standard window](images/co07-step-table.png)

   The rows run `-7.5` to `-5`, and the `X=-6.5` row reads `5.290`.

2. Press [EXIT] to leave the table and press [+] for the halved window,
   letting each replot finish. Press [MORE]: the table opens on rows now
   outside the window, reading `UNDEF` down to `X=-5`, where `9` sits.
   Press [▼] twice, letting each page settle: the `X=-1.5` row reads
   `5.307`.

3. Press [EXIT] and press [+] again. The plot comes up empty: the vertical
   zoom has come down to -2.5 to 2.5 and the solution spends the whole run
   above it. The table does not mind. Press [MORE], then [▼] once: the
   `X=1` row reads `5.315`.

4. Press [EXIT], press [2nd] [+] to restore the standard window, and let
   the replot finish. Press [EXIT] for the home screen and [CLEAR]. Type
   [5] [÷] [1] [2] [7] [ENTER] for the third step, `= 0.039370078740157`,
   press [CLEAR], and ask for the truth at 3.5 minutes, [9] [×] [2nd] [LN]
   [(-)] [.] [5] [2] [5] [)] [ENTER]: `= 5.3239982793029`.

| Window | Step | Reading at 3.5 minutes | Gap |
| --- | --- | --- | --- |
| -10 to 10 | `0.15748031496063` | `5.290` at `X=-6.5` | 0.034 |
| -5 to 5 | `0.078740157480315` | `5.307` at `X=-1.5` | 0.017 |
| -2.5 to 2.5 | `0.039370078740157` | `5.315` at `X=1` | 0.009 |

Halve the step and the error halves. That is Euler's signature and its
disappointment: the method is first order, so one more decimal place costs
ten times the work, where the midpoint rule of Chapter 4 quartered its
error per halving. Two boundaries showed themselves. Table rows outside the
window read `UNDEF`, because the run *is* the window; and the zoom keys
move both axes, so a window narrow enough to refine the step may be too
short to show the curve at all, leaving the table as the whole instrument.

**Try it.**

1. Press [+] a third time and hunt for the 3.5-minute reading: work out
   which `X` it needs from the new bounds, look that row up, and say what
   the answer tells you about refining a step by zooming.
2. The gaps above are roughly 0.21 times the step. Use that to predict the
   step needed for a gap under 0.001, and say how many halvings that is.
3. Take the doubled window ([-] from standard) and repeat the measurement.
   Does the gap double, as the pattern says it should?

## 7.4 An Euler program

The window is symmetric, so section 7.3 could not hold the interval fixed
while the step shrank. A program has no such trouble, because the step
becomes a number in a memory. This one walks the same equation with the
step in `H` and the number of steps in `N`.

The program never names the model: `EVAL(` reads the stored slope, so the
calculus command does the modelling and the program the arithmetic. Press
[CLEAR] and spell `EVAL(0)` letter by letter ([ALPHA] then the key carrying
each letter, brackets and digits typed directly), then press [ENTER]:
`= -0.064835852069246`. Press [CLEAR] and ask `EVAL(5)`: the same answer,
because the stored slope has no `X` in it. What it does contain is `Y`, an
ordinary variable the mode uses as scratch while integrating; press [CLEAR]
and ask [ALPHA] [0] [ENTER] for `= 0.43223901379497`, left there by the
last plot at the right-hand window edge. The program must therefore seed
`Y` itself.

1. Press [CLEAR], then [PRGM] and [F1], `NEW`: the editor opens on
   `EDIT P1`. Type the eight lines, [ENTER] after each; letters are
   [ALPHA] plus the key carrying the letter, spaces are [2nd] [0] in this
   editor, and [STO▶] types the `->` arrow.

   | Line | Text | Keys |
   | --- | --- | --- |
   | 1 | `9->Y` | [9] [STO▶] [Y] |
   | 2 | `.5->H` | [.] [5] [STO▶] [H] |
   | 3 | `7->N` | [7] [STO▶] [N] |
   | 4 | `WHILE N` | [W] [H] [I] [L] [E] [2nd] [0] [N] |
   | 5 | `Y+H*EVAL(0)->Y` | [Y] [+] [H] [×] [E] [V] [A] [L] [(] [0] [)] [STO▶] [Y] |
   | 6 | `N-1->N` | [N] [-] [1] [STO▶] [N] |
   | 7 | `END` | [E] [N] [D] |
   | 8 | `DISP Y` | [D] [I] [S] [P] [2nd] [0] [Y] |

   Line 5 is Euler's method entire: the new y is the old y plus the step
   times the slope at the old y. Seven steps of 0.5 carry the walk 3.5
   minutes from the dose, section 7.3's question a second way.

2. Press [F2], `RUN`:

   ![Seven Euler steps of 0.5 landing short of the truth](images/co07-euler-run.png)

   The run screen answers `RUN P1` over `LINE 9`, the output line shows
   `5.2147637585268`, the status reads `DONE`, and against
   `5.3239982793029` the walk is low by 0.109.

3. Halve the step. Press [PRGM] for the list and [F1] to reopen `EDIT P1`
   at line 1, press [▼] for line 2, press [CLEAR], and type `.25->H`;
   [ENTER] moves to line 3, where [CLEAR] and `14->N` doubles the count.
   Press [F2]: `5.2705124549462`. Repeat, [CLEAR] before each retype, for
   `.125->H` and `28->N`.

   | `H` | `N` | Run screen | Gap |
   | --- | --- | --- | --- |
   | `.5` | `7` | `5.2147637585268` | 0.109 |
   | `.25` | `14` | `5.2705124549462` | 0.053 |
   | `.125` | `28` | `5.2975280205725` | 0.026 |

   The interval never moved and the errors still halve, which is the clean
   version of section 7.3's measurement. The two tables agree on the
   constant as well: gap over step sits near 0.21 in all six rows.

4. Set the program to the mode's own step. Reopen the editor the same way
   and, [CLEAR] before each retype, put `20/127->H` on line 2 and `64->N`
   on line 3. Press [F2]: `1.9489119504254`, digit for digit the trace
   readout of section 7.1, step 5. Plot and program are one walk.

The environment shaped two decisions. `FOR` bounds are single digits (the
Guidebook, chapter 16), so a counted loop cannot reach fourteen passes, and
the countdown in `N` is what buys arbitrary step counts. And `EVAL(` takes
the slope at the current `Y` but at a typed `X`, so a model containing `X`
would need the running x stepped alongside `Y`, a ninth line the slot has
not got; this equation does not mention x, which is why eight lines
suffice.

**Try it.**

1. Run the program at `.0625->H` with `56->N` and check that the gap halves
   once more.
2. Change line 1 to `18->Y`, run at `.5` and `7` again, and say from the
   gap how the error scales with the size of the solution.
3. Store `-.3*Y` as the equation and rerun the program untouched. Work out
   the true value at 3.5 minutes and say whether the same gap-over-step
   constant holds for the faster tank.

## 7.5 Improved Euler

Euler takes the slope at the start of a step and trusts it for the whole
step, which is why it lags a bending curve. The improved method, Heun's,
takes the slope at the start, guesses where the step ends, takes the slope
there too, and steps with the average of the two. Written so the predictor
is reused: k is the slope at y, y becomes y + hk, and then y becomes y plus
h times half the difference between the new slope and k.

That is three statements inside a loop that already needs a test, a
countdown, and an `END`; with three setup lines and the `DISP`, an
eight-line slot is two short. The Guidebook, chapter 16 has the way out:
`CALL` runs another slot and comes back, and variables are shared, so the
step can live in its own program. That is the better design anyway, since
swapping the called slot makes one driver run any method.

1. Press [PRGM] for the list, press [▼] to select the second slot, and
   press [F1] to open `EDIT P2`. Type the driver:

   | Line | Text | Keys |
   | --- | --- | --- |
   | 1 | `9->Y` | [9] [STO▶] [Y] |
   | 2 | `.5->H` | [.] [5] [STO▶] [H] |
   | 3 | `7->N` | [7] [STO▶] [N] |
   | 4 | `WHILE N` | [W] [H] [I] [L] [E] [2nd] [0] [N] |
   | 5 | `CALL 3` | [C] [A] [L] [L] [2nd] [0] [3] |
   | 6 | `N-1->N` | [N] [-] [1] [STO▶] [N] |
   | 7 | `END` | [E] [N] [D] |
   | 8 | `DISP Y` | [D] [I] [S] [P] [2nd] [0] [Y] |

2. Press [EXIT] to save and return to the list, press [▼] for the third
   slot, and press [F1] for `EDIT P3`. Type the step itself:

   | Line | Text | Keys |
   | --- | --- | --- |
   | 1 | `EVAL(0)->K` | [E] [V] [A] [L] [(] [0] [)] [STO▶] [K] |
   | 2 | `Y+H*K->Y` | [Y] [+] [H] [×] [K] [STO▶] [Y] |
   | 3 | `Y+H*(EVAL(0)-K)/2->Y` | [Y] [+] [H] [×] [(] [E] [V] [A] [L] [(] [0] [)] [-] [K] [)] [÷] [2] [STO▶] [Y] |
   | 4 | `RETURN` | [R] [E] [T] [U] [R] [N] |

   Line 1 keeps the slope where the step begins and line 2 makes the Euler
   guess, leaving `Y` at the predicted end, so line 3's `EVAL(0)` reads the
   slope *there*; half the difference of the two slopes, stepped, turns the
   predictor into the average-slope step.

3. Press [EXIT] for the list, press [▲] to select `P2`, and press [F3],
   `RUN`. The pair takes noticeably longer than section 7.4's single slot;
   let it finish:

   ![Improved Euler landing on the far side of the truth](images/co07-heun-run.png)

   The run screen answers `5.3267712168309`. Euler at the same step landed
   at `5.2147637585268` against a truth of `5.3239982793029`, so seven
   improved steps miss by 0.0028 where seven plain ones missed by 0.109.

4. Halve twice more. Press [PRGM] for the list, which returns with `P2`
   selected, press [F1], and edit lines 2 and 3 as in section 7.4, [CLEAR]
   before each retype: `.25->H` with `14->N`, then `.125->H` with `28->N`.

| `H` | `N` | Run screen | Gap |
| --- | --- | --- | --- |
| `.5` | `7` | `5.3267712168309` | 0.0028 above |
| `.25` | `14` | `5.3246721242446` | 0.00067 above |
| `.125` | `28` | `5.3241643775915` | 0.00017 above |

Two things changed at once. The gaps now quarter per halving rather than
halve, which is what second order means, and they sit on the far side of
the truth, because averaging the two slopes overcorrects a curve of this
shape where the single slope undercorrected it. Seven improved steps beat
twenty-eight plain ones by nearly ten to one, and they ask `EVAL(` half as
many times to do it.

**Try it.**

1. Change `P2`'s line 5 back to `Y+H*EVAL(0)->Y` and delete `P3`. Confirm
   that the driver alone reproduces section 7.4's numbers, and say what
   that proves about where the improvement lives.
2. Write a midpoint step into the fourth slot: slope at the start, half a
   step forward, slope there, then a whole step from the original point
   with that slope. Mind the line that must remember the original `Y`.
3. Run the improved pair at `20/127->H` with `64->N`. How far apart are the
   plot and the better method by the middle of the window?

## 7.6 Qualitative behaviour

Change one thing in the tank and a whole family appears. Suppose the
incoming water carries dye of its own, so the concentration is pulled
towards a level A rather than towards nothing: dy/dx = k(A - y). The sign
of the bracket does the thinking. Above A it is negative and the solution
falls, below A it is positive and the solution rises, and at A it is zero
and nothing moves; that last line is a solution in its own right, the
constant one, called an equilibrium. This section takes A = 3 with k = 0.4
and needs the initial value to change, which section 7.1 said the mode will
not allow. The lever exists, and it is deliberately stiff.

1. The seed is still 9, above A, so the first member of the family costs
   nothing. Press [PRGM] to leave the run screen for the list, press [EXIT]
   for the home screen, and press [CLEAR]. Type [.] [4] [×] [(] [3] [-]
   [ALPHA] [0] [)] so the line reads `.4*(3-Y)`, press [GRAPH], and let the
   plot finish: the curve drops steeply and then flattens.

2. Press [MORE] for the table, which opens at `X=0` in steps of 0.5:
   `3.096`, `3.078`, `3.063`, `3.051`, `3.042`, `3.034`. Press [▲] three
   times, letting each page settle, and the rows from `X=-7.5` read
   `5.136`, `4.737`, `4.413`, `4.149`, `3.935`, `3.760`. The solution is
   squeezing onto 3 and never arriving: an asymptote seen from above.

3. Now the reset. The mode writes its saved state to the store object
   `GDEQ` when you leave it, and deleting that object is the only way to
   make it seed itself again (the Guidebook, chapter 7). Press [EXIT] to
   leave the table, then [2nd] [MORE] and [MORE] twice for the graph mode
   page, and press [F1], `FN`, which is what writes `GDEQ`, letting each
   plot finish before the next press. Press [EXIT] for home.

4. Press [2nd] [+] for the memory browser of the Guidebook, chapter 18,
   which opens on `A`. Press [▼] until the name reads `GDEQ`: it is the
   last entry, and the selection stops there rather than wrapping. The line
   beneath reads `TYPE GRAPH DB`, confirming the right object. Press [DEL]:
   the selection moves to `GFUNC`, the mode's memory gone.

5. Press [EXIT] for the home screen and seed the new value: [(-)] [6]
   [STO▶] [ALPHA] [0] [ENTER] answers `= -6`. Press [CLEAR], press [GRAPH],
   then [2nd] [MORE], [MORE], [MORE], and [F4] for `DEQ`. Let the replot
   finish: the flat line now sits low in the window, the receipt for -6,
   and the equation slot is empty, because deleting `GDEQ` cleared the
   mode's equations too.

6. Press [EXIT], retype [.] [4] [×] [(] [3] [-] [ALPHA] [0] [)], and press
   [GRAPH]:

   ![The same equilibrium approached from below](images/co07-equilibrium.png)

   Let the plot finish. The curve climbs out of the bottom of the window
   and flattens along the same level as before. Press [MORE] for the table,
   which the reset returned to steps of 1: `X=0` reads `2.855`, then
   `2.904`, `2.936`, `2.958`, `2.972`, `2.981`. The equilibrium is
   approached from below just as it was from above, and neither solution
   crosses it, since crossing means passing through a point where the rule
   says do not move.

7. One sign turns the picture over. Press [EXIT] to leave the table, let
   the plot redraw, press [EXIT] for the home screen, and press [CLEAR].
   Type [(-)] [.] [3] [×] [(] [3] [-] [ALPHA] [0] [)] so the line reads
   `-.3*(3-Y)`, and press [GRAPH]. Let it finish: the solution leaves
   through the bottom of the window almost at once. Press [MORE] for the
   table: `X=0` reads `-165.`, then `-223.`, `-300.`, `-403.`, `-542.`,
   `-727.`. The equilibrium at 3 is still a solution, but every neighbour
   now flees it. Stable and unstable equilibria differ by nothing more than
   the sign of k.

The honest scope of the mode ends here. Free85 integrates one first-order
equation from one initial condition, so the questions this chapter can ask
are the questions a single curve can answer. A predator and its prey, a
mass on a spring, any pair of quantities that drive each other: those are
systems of two equations whose natural picture is the phase plane, one
quantity against the other rather than against x. Neither is available, and
no arrangement of the slots produces them, because the plot follows slot 1
alone. What travels is the thinking: the sign of the right-hand side, the
equilibria where it vanishes, and whether neighbours join or leave them.

**Try it.**

1. Predict, without the machine, what `.4*(3-Y)` does when it is seeded at
   exactly 3, then run the reset of steps 3 to 5 with `3->Y` and see.
2. Find the equilibrium of `.2*(8-Y)-.5` by hand, then plot it from a seed
   above and a seed below and confirm the level from the table.
3. On paper, sketch the directions of the pair dx/dt = y, dy/dt = -x at
   eight points around the origin and say what shape a solution must
   follow. Then say which single Free85 equation, if any, would show you
   the same thing.
