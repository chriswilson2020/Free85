# Second-edition plan for Explorations with Free85

Answering the brief at `REWRITE-BRIEF.md`. Nothing in the book has been
changed yet. This is the proposal to agree before eight chapters get
written in a voice nobody has signed off.

## 1. Where the first edition stands, measured

The baseline build, run today from a clean tree:

```
companion: 1818 keycaps, 49 framed screenshots, 1 maths diagram,
           8 chapters, 47 numbered sections, 47 Try it panels
wrote dist/guidebook/Free85-Companion-typeset.pdf (114 pages)
```

So: 114 pages, one figure per section and a rounding error, one diagram.

## 2. What changes, and how much, per chapter

Five kinds of work. Not every chapter needs all five in equal measure.

- **V** voice: kill the over-long sentences, break keystroke narration
  into steps, drop the literary register.
- **M** mathematics: push each exploration past its first example, and
  swap in the standard example of the field where it teaches better than
  the invented one.
- **H** hand-holding: what to expect before the key press, what it means
  if the screen differs, how to get back to a known state.
- **L** listings: complete programs, the editor screen, the run screen.
- **F** figures: captures where a reader could doubt their screen, and
  diagrams for the mathematics behind them.

| Ch | Subject | Work | Sections | Notes |
| --- | --- | --- | --- | --- |
| Front | Front matter | V H | n/a | Opening sentence deleted. New "getting back to a known state" page. Listings and diagrams added to the conventions. |
| 1 | Precalculus | V M H F | 6 → 6 | Depth, not new sections. The unit circle arrives as a diagram behind 1.5. |
| 2 | Business | V M H F | 5 → 5 | LP gets its feasible region drawn properly; Markov gets a transition diagram. |
| 3 | Probability | V M H L F | 6 → 6 | Both programs get full listings and editor screens. Residuals get a diagram. |
| 4 | Calculus I | V M H L F | 6 → 7 | Largest mathematical change: see section 3 below. |
| 5 | Calculus II | V M H L F | 8 → 9 | New section: Newton's method by program. |
| 6 | Linear algebra | V M H F | 6 → 6 | Row operations get the geometry drawn alongside the arithmetic. |
| 7 | Differential eqns | V M H L F | 6 → 7 | The logistic and Gompertz equations arrive. Slope field diagram. |
| 8 | Engineering | V M H L F | 4 → 5 | Worst prose in the book (12 sentences over 45 words). Shooting method gets its geometry. |
| After | Afterword | V | n/a | Light edit only. It is the one page that already earns its length. |

Section count goes 47 → 51. Every new section brings its own Try it
panel, so the build's `tryits >= 40` assertion stays satisfied and rises
to 51.

## 3. The standard examples, and what they displace

Per section 1 of the brief. In each case the invented example was chosen
to be different rather than to teach, and the standard one is what the
reader will meet again in their course.

| Where | First edition | Second edition |
| --- | --- | --- |
| 4.1 limits | `(X^3+X^2)/X`, a removable hole | `SIN(X)/X`, with the squeeze, the series, and the degree-mode surprise |
| 4.5 Riemann sums | left, right, midpoint at 4 and 8 slices | keeps those, adds the trapezoid and the error orders measured, not asserted |
| new 5.x | (absent) | Newton's method, built as a program, watched converging and then watched failing |
| 7.1–7.6 | one linear tank, `dy/dx = -0.15y` | tank stays as the warm-up; the logistic equation becomes the chapter's spine, with Gompertz as its rival |
| 8.1 pendulum | already the standard example | kept, deepened with the series' second term |
| 1.5 trigonometry | daylight model | kept: it is a genuinely good model and it survives |
| 2.1–2.2 receipts, joinery | café receipts, timber budget | kept: these are the standard shapes of the field wearing local clothes |

The café, the joinery and the lighthouse keeper stay. They are charming
and they are not the reason the book is thin.

## 4. Figure budget

Current: 49 captures, 1 diagram, allocated one per section.

Proposed, allocated per section by whether a reader could be unsure their
screen matches, or whether the mathematics needs a picture the calculator
cannot draw:

| Ch | Captures | Diagrams | Diagrams proposed |
| --- | --- | --- | --- |
| 1 | 14 | 3 | the unit circle behind sine and cosine; a window as a frame over a curve; the even/odd reflection test |
| 2 | 12 | 3 | the feasible region with its corner points; the profit line sliding out to its last touch; the three-shop transition diagram |
| 3 | 13 | 3 | the five-number summary as box-plot anatomy; residuals under a straight fit and under a curved one; how four equal-width bins fall on the keeper's week |
| 4 | 15 | 4 | the squeeze sandwich for sine over x; secants collapsing onto a tangent; left, right and midpoint rectangles over the same curve; the region between two curves |
| 5 | 16 | 4 | Newton's tangent stepping to the root; the same tangent overshooting on a bad start; polar r and theta; the projectile's path with its apex marked |
| 6 | 13 | 3 | two lines, three row operations, one unmoving crossing; the shadow of one arrow on another; a direction the matrix keeps |
| 7 | 14 | 4 | a slope field with one solution threaded through it; Euler's step falling below a bending curve; Heun's two slopes and their average; the logistic S-curve with both equilibria |
| 8 | 12 | 4 | the pendulum (exists); the shooting method's two misses bracketing the target; the guyed mast in three dimensions; the damper's rebounds as a geometric staircase |
| Total | **109** | **28** | |

Roughly 2.1 captures per section, plus a diagram roughly every other
section. Diagrams are authored as SVG at
`docs/companion/images/fig-NN-slug.svg`, on `fig-08-pendulum.svg`'s
palette: navy `#1a3a6b` and ink, no gradients, nothing carrying meaning
in colour alone.

Captures that specifically did not exist before and should: the program
editor mid-listing, the run screen with `DONE`, soft-key pages before the
press that uses them, every zoom and window change the prose currently
describes, and each error screen the reader is warned about.

## 5. Consequences for the build

- `render("Free85-Companion-typeset", doc, { minPages: 90, maxPages: 200 })`
  will need raising. The estimate is 190 to 215 pages, so `maxPages: 260`
  with `minPages` left alone.
- Every new capture is declared in `scripts/companion-screens.js` and
  generated with `npm run build:companion:screens`. Settle frames are
  guessed and then checked by looking at the PNG, every one, because a
  half-drawn screen throws nothing.
- `npm run build:guidebook:web` writes under `public/`, so the run ends
  with `SJASMPLUS=<path> npm run update:free85:reproducibility`. sjasmplus
  is not installed here; it will be built first from
  `github.com/z00m128/sjasmplus` at v1.23.1 with `make USE_LUA=0`.
- Page-break check on every touched spread, since a framed capture cannot
  break and drags its lead-in with it.
- `npm test` stays at 194 green throughout.

## 6. The voice, for judgement

What follows is section 4.1 rewritten. It is the sample to accept or
reject before anything else is written. Every number and every screen in
it was run on the emulator today; the figure captions name captures that
do not exist yet.

Against the first edition's 4.1 it is about two and a half times as long,
has four figures instead of one, tells you what to do when the screen is
wrong, works the limit three further ways after the first answer, and
does not once congratulate itself.

---

## 4.1 Limits by table and zoom

A limit asks what value a function is heading for. What value it has
there is a different question. The two come apart most clearly where a
function has no value at all.

The specimen is the one every calculus course meets: sine of x, divided
by x. At every x but one it is an ordinary, well-behaved function. At
x = 0 the top and the bottom are both zero and the division has nothing
to say. That single missing point is the whole subject.

It is worth the trouble for a second reason. The fact that the derivative
of sine comes out as cosine rests entirely on this limit, so the answer
this section arrives at is one the rest of the chapter spends.

Four instruments get pointed at the same hole: the plot, the table, the
calculus commands, and paper. They do not agree, and where they disagree
is the lesson.

### Storing the function

1. Press [CLEAR] to empty the entry line.

2. Press [SIN]. The line reads `SIN(`: the key brings its own opening
   bracket. Press [x-VAR], then [)], then [÷], then [x-VAR].

   The entry line should now read `SIN(X)/X`. If it reads `SIN((X)/X` you
   pressed [(] as well; press [CLEAR] and type the line again.

3. Press [GRAPH]. The line is stored into slot `Y1` and plotted in the
   standard window, -10 to 10 on both axes. Trigonometry is slow work for
   this machine, so let the curve reach the right-hand edge of the screen
   before you press anything else. Presses that arrive during a draw are
   thrown away.

   ![A low bump over the origin, flattened by the standard window](images/co04-sinx-standard.png)

### What the plot is worth

The curve is a bump over the origin with small ripples either side, and
the whole of it is squashed into a band a few pixels tall. Section 1.1's
warning is at work: the window allows for heights from -10 to 10, and
this function never leaves -0.3 to 1.

Nothing on the screen suggests a missing point, and nothing could. The
plot samples 128 columns across the window and 0 is not one of them.

4. Press [+] three times, letting each replot finish. Each press halves
   every bound, so the window is now -1.25 to 1.25 on both axes and the
   bump fills the screen.

5. Press [▶] twice. The readout gives `X=0.0492125984252` and
   `Y=0.99959640223576`: a sample column a twentieth of a unit right of
   centre, where the function is within half a thousandth of 1.

   ![The zoomed bump, traced two columns right of centre](images/co04-sinx-zoom-trace.png)

Zoom as far as you like and the arc stays smooth. No zoom ever lands a
sample column exactly on 0, so a hole one point wide stays invisible to
an instrument that looks in 128 places at a time. The plot is not lying.
It is answering a question about columns, and the hole is not in a
column.

### What the table catches

6. Press [2nd] [+] for the standard window, let the replot finish, and
   press [MORE] for the table.

   ![The table reading UNDEF at X=0](images/co04-sinx-table.png)

   The `X=0` row reads `UNDEF`. Below it the rows read `0.841`, `0.454`,
   `0.047`, `-0.18`, `-0.19`. The table asked at 0 itself, which the plot
   never did, and got nothing back.

   Those five values are the ripples, not the limit. At `X=1` the
   function is already 0.841 and falling. Whatever is happening at 0
   happens closer in than the table can currently see.

7. Press [-] four times to halve the table step four times, from 1 down
   to 0.0625. Let each redraw settle before the next press.

   ![The same table at step 0.0625, the rows climbing towards 1](images/co04-sinx-table-fine.png)

   The rows below the hole now read `0.999`, `0.997`, `0.994`, `0.989`,
   `0.983` reading down, so upward towards the hole they climb 0.983,
   0.989, 0.994, 0.997, 0.999. The `X=0` row still reads `UNDEF`.

8. Press [▲] to page up to the other side. The rows from `X=-0.31` read
   `0.983`, `0.989`, `0.994`, `0.997`, `0.999`, and then `UNDEF`. The two
   sides are the same five numbers in the same order.

   They have to be. Sine is odd, so sin(-x) over -x is sin(x) over x, and
   the function is even: a mirror in the y axis with one point missing
   from the middle. Both sides climb to the same place.

The table has done what the plot could not, twice. It reported the hole,
and it showed the values either side of it converging. Neither fact was
visible in a picture.

### What the commands say

The calculus commands read the stored equation, so `SIN(X)/X` is still
what they are talking about.

9. Press [EXIT] to leave the table, [EXIT] again for the home screen, and
   [CLEAR] to empty the entry line the graph handed back.

10. Spell `EVAL(.1)`, letter by letter with [ALPHA] and the key carrying
    each letter, and press [ENTER]: `= 0.99833416646834`.

11. Pressing [CLEAR] before each, ask four more:

    | Probe | Answer |
    | --- | --- |
    | `EVAL(.01)` | `0.99998333341673` |
    | `EVAL(.001)` | `0.9999998333334` |
    | `EVAL(-.001)` | `0.9999998333334` |
    | `EVAL(.0001)` | `0.9999999983334` |

    Each tenfold shrink in x buys two more nines. That is a rate worth
    noticing, and step 15 explains it.

    The two probes at .001 agree to the last digit, which is the evenness
    of step 8 stated to fourteen places.

12. Push harder. Press [CLEAR] and ask `EVAL(1E-6)`, the `E` typed with
    [EE]: `= 0.9999999999999`. Press [CLEAR] and ask `EVAL(1E-9)`:
    `= 1`, exactly.

    Read that last answer carefully. It does not mean the function equals
    1 at a billionth. It means sine of a billionth and a billionth agree
    in every one of the fourteen digits the machine keeps, so the
    quotient rounds to 1. The machine has run out of room to show the
    difference, which is not the same as there being none.

13. Ask for the point itself. Press [CLEAR] and spell `EVAL(0)`:

    ![EVAL at the hole stopping at SYNTAX ERROR](images/co04-sinx-eval-error.png)

    The screen reads `SYNTAX ERROR` over `CLEAR OR EXIT`. That is how the
    calculus commands report an evaluation that fails at the point asked
    for. Press [CLEAR] to dismiss it. The entry line keeps `EVAL(0)`, so
    press [CLEAR] a second time to empty it.

    Two presses of [CLEAR] after any error screen is the habit to build:
    the first dismisses the notice, the second clears the line.

### Why it is 1, which no probe proved

Every probe pointed at 1 and not one of them proved it. The machine tests
finitely many points; a limit is a claim about all of them. Two routes
close the gap, and both are checkable here.

The first is the squeeze. For a small positive x, draw the unit circle
and compare three areas: the triangle inside the sector, the sector
itself, and the triangle outside it.

![The unit circle sector between its inner and outer triangles, the areas that squeeze sine over x](images/fig-04-squeeze.svg)

The three areas are sin x over 2, then x over 2, then tan x over 2. Divide
through and turn the inequality over, and cos x is below sin x over x,
which is below 1. Cosine heads for 1 as x heads for 0, so the quotient is
trapped and has nowhere else to go.

14. Test the sandwich on the machine. Press [CLEAR] and ask `COS(.1)`:
    `= 0.99500416527802`. Step 10 gave `0.99833416646834` for the
    quotient at the same x. The quotient sits between cosine and 1, as
    the squeeze says, and the gap it has to live in is five thousandths
    wide.

    Press [CLEAR] and ask `COS(.01)`: `= 0.99995000041666`, against the
    quotient's `0.99998333341673`. The gap has narrowed to five
    hundred-thousandths. Squeeze the walls together and the thing between
    them has no choice.

The second route is the series. Sine of x is x minus x cubed over 6 plus
smaller terms, so sine of x over x is 1 minus x squared over 6 plus
smaller terms still. That predicts the rate of step 11 exactly: shrink x
tenfold and the error falls a hundredfold, which is two more nines.

15. Check the prediction. Press [CLEAR] and type `1-.1^2/6`:
    `= 0.9983333333334`, against the quotient's `0.99833416646834`. They
    agree to six decimals. Press [CLEAR] and type `1-.01^2/6`:
    `= 0.9999833333334`, against `0.99998333341673`. They agree to nine.

    The rule of thumb earns one extra correct decimal for every three the
    argument sheds, which is why it is worth carrying.

### The limit that changes with the mode

The answer 1 is not a fact about sine. It is a fact about sine measured
in radians, and the machine will show you that in about ten key presses.

16. Press [2nd] [MORE] for the mode screen, press [F1] once so the second
    line reads `ANGLE DEG`, and press [EXIT].

17. Press [CLEAR], retype `SIN(X)/X` as in steps 1 and 2, and press
    [GRAPH] to store it again. Let the plot finish. It is a flat line on
    the axis now, which is the first clue.

18. Press [EXIT], press [CLEAR], and ask `EVAL(.1)`:
    `= 0.017453283658983`. Press [CLEAR] and ask `EVAL(.001)`:
    `= 0.017453292519057`.

    The probes still converge, and they converge on something else. Press
    [CLEAR] and type `PI/180`, the `π` legend on [2nd] [^]:
    `= 0.017453292519943`. That is the number the probes are walking
    towards, to nine decimal places at x = .001.

The reason is the chain rule wearing a disguise. One degree is pi over
180 radians, so measuring in degrees multiplies the angle by that factor
before the sine ever sees it, and the whole limit is scaled by the same
amount. Radians are the unit in which the constant is 1, and that is the
entire reason calculus insists on them.

19. Press [2nd] [MORE], press [F1] once to return to `ANGLE RAD`, and
    press [EXIT]. Leaving the machine in `DEG` will quietly spoil every
    trigonometric result in the rest of the chapter.

**Try it.**

1. Store `(1-COS(X))/X` and probe it at .1, .01, and .001 with `EVAL(`.
   Where is it heading? Now do the same for `(1-COS(X))/X^2`, and say
   what dividing by the extra x changed.
2. The table at step 7 climbed to 0.999 next to the hole. Halve the step
   four more times and read the same row. How many nines does the cell
   show, and what stops it showing more?
3. `EVAL(1E-9)` answered exactly 1 in step 12. Find the largest power of
   ten at which the answer is still short of 1, and say what that number
   measures about the machine rather than about the mathematics.
4. Store `SIN(2*X)/X` and probe it at .01 and .001. The limit is not 1.
   Predict it from the series of step 15 before you press a key, then
   check it.
5. Store `X/SIN(X)`, the same specimen upside down, and probe it from
   both sides. Why must its limit be 1 as well, and what would go wrong
   if you tried to argue that from the squeeze of step 14 unchanged?

---

## 7. What is being asked

Three things, before writing starts.

1. **The voice above.** It is plainer, it counts steps, it stops to say
   what to do when the screen disagrees, and it has no sentence over 35
   words. If it is still wrong, it is cheaper to say so now.
2. **The figure budget of section 4.**  109 captures and 28 diagrams is
   roughly a doubling and then some. It is the largest single cost in the
   job, mostly in generating and then eyeballing every PNG.
3. **The section count going 47 to 51**, and `maxPages` going 200 to 260.

Then the order of work: front matter and chapter 4 first as the pilot,
built and shown; then chapters 7, 8, 5, 3, 1, 2, 6 in that order, worst
prose and thinnest mathematics first.
