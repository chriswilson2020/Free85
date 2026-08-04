# Second-edition plan for Explorations with Free85

Answering the brief at `REWRITE-BRIEF.md`. Revised after reading the source
book in full: *Explorations with the Texas Instruments TI-85*, Harvey and
Kenelly (eds.), Academic Press, 1993, 374 pages, eight chapters by eight
authors. Nothing in the book has been changed yet.

The method is the one section 1 of the brief prescribes: read the source
for scope, depth and level; take structured notes on what mathematics to
cover and how far to push it; write from the notes in your own words with
your own screens and numbers. What follows is those notes turned into a
plan. No sentence of the source is reproduced anywhere in this book.

## 1. Where the first edition stands, measured

Baseline build from a clean tree:

```
companion: 1818 keycaps, 49 framed screenshots, 1 maths diagram,
           8 chapters, 47 numbered sections, 47 Try it panels
wrote dist/guidebook/Free85-Companion-typeset.pdf (114 pages)
```

## 2. What reading the source changed

The chapter list was already right. The first edition's eight subjects sit
in the same order as the source's, which is the order of a mathematics
course and belongs to nobody. What the reading changed is the *content of
the sections*, and the change is large.

Three things I got wrong in the first version of this plan:

**a. I under-counted the missing mathematics.** I had proposed "push each
section further". Reading the source turned that into a specific list of
about thirty named topics the first edition simply does not contain, most
of them standard. They are in section 4 below. Several are better than
anything I would have invented.

**b. I under-weighted the exercises.** The source closes each section with
around ten exercises; the first edition closes each with three. That ratio
is a large part of "lacking quite a lot" and I treated it as cosmetic. It
is not. More important than the count is the *kind*: the source repeatedly
asks the reader to **sketch or predict first, then check on the machine**.
The first edition almost never does. That single habit is the cheapest
available change that turns a demonstration into a lesson.

**c. I planned to fill gaps that are actually walls.** Several of the
source's best explorations cannot be done on Free85 at all: the simplex
method needs a 3 by 6 tableau against a 3 by 3 ceiling; phase planes and
second-order equations need two simultaneous state variables against one;
overlaying solution families needs a picture store Free85 has not got.
These are not omissions to repair. They are the book's own subject, and
the afterword's thesis. What changes is that I can now name them precisely
instead of gesturing.

**d. I set budgets, which was the same mistake in a new place.** The first
version of this plan promised so many captures, so many diagrams, so many
sections, so many exercises. The brief's complaint about the first edition
is precisely that its figures were allocated by quota rather than by need.
Answering that with a bigger quota answers nothing. Section 6 replaces
every number with a rule.

What does **not** change: the voice sample, which is still the one thing
needing agreement before writing starts.

## 3. Capability probes already run

Before promising any of this I ran the new candidates on the emulator.
Results that changed the plan:

| Probe | Result | Consequence |
| --- | --- | --- |
| `NCR(5,2)` | `10` | Free85 **has** combinations. Binomial probabilities by formula are open to chapter 3, which I had assumed were not. |
| `DET` of 1,2,3 / 4,5,6 / 7,8,9 | `0`, exactly | Free85 does **not** reproduce the classic singular-matrix round-off trap. I had this pencilled as a headline addition to chapter 6. Dropped: I will not print a failure the machine does not have. |
| `EXP(LN(1+.001)/.001)` | `2.7169239351903` | The 1-to-the-infinity indeterminate form is reachable, routed round `^`'s whole-exponent limit the way section 1.4 already routes compound interest. |
| `-Y*LN(Y/8)` at `Y=3` | `2.9424877590348` | The Gompertz slope evaluates, so it can go in the DifEq slot beside the logistic. |
| `X*SIN(1/X)` with `X` and `-X` in the other two slots | plots, but the interesting part is invisible in the standard window | The squeeze exploration works and needs three presses of [+] to see. That window hunt is the lesson, not an obstacle. |

The remaining feasibility questions (list arithmetic for first differences,
what the DifEq slope does with `X` in it, whether the parametric mode can
carry the unit circle and a sine together) get the same treatment before
the sections that depend on them are written.

## 4. The mathematics to add, by chapter

Every item below is a standard topic of its field, taken from the source
for *scope*, and every one has been checked against what Free85 can
actually do. Items marked **[wall]** are things the source does that Free85
cannot, which the chapter should say plainly and go round.

**Chapter 1, Precalculus.** Rational functions and asymptotes are missing
outright: the source ends its first section with a rational function
rewritten as a quadratic plus a remainder, then asks how far right you must
go before the curve and the quadratic differ by less than a thousandth.
That is a whole section's worth and Free85 can do all of it. Add also the
four-parameter wave `A*SIN(B*X+C)+D` taken one parameter at a time,
and damped harmonic motion. The unit circle becomes a diagram rather than a
plot, because parametric mode holds one pair **[wall]**.

**Chapter 2, Business Mathematics.** Sensitivity analysis: move one
constraint's constant, watch a single corner move and the optimum with it.
The source makes this a named idea in two separate sections and the first
edition has nothing like it. Add also the contrast between a well-behaved
system and a nearly-parallel one, which puts conditioning in chapter 2
where a business reader meets it, rather than only in chapter 6. The
simplex method **[wall]**: a 3 by 6 tableau does not fit a 3 by 3 world.

**Chapter 3, Probability and Statistics.** The biggest single addition in
the book: **fit a line by hand and watch the sum of squared residuals
fall**. Store a slope and an intercept, loop the eight pairs, accumulate
the squared deviations, display the total; try again with a better line;
then press `LIN` and see that the machine's answer is the smallest total
you could have reached. That is what least squares *means*, it fits an
eight-line program, and the first edition merely presses `LIN` and reads
off `A` and `B`. Add also residual plots and what their shapes diagnose,
relative frequency converging on theoretical probability as the trial count
grows, and binomial probabilities by formula now that `NCR(` is confirmed.

**Chapter 4, Calculus I.** The epsilon-delta rectangle: choose the window
as the box, and a limit exists when you can always shrink the box's width
to keep the curve inside its height. Free85's whole thesis is that the
window is an instrument, and this is the sharpest use of it in the source.
Add `SIN(1/X)`, where zooming shows a limit failing to exist, and
`X*SIN(1/X)` squeezed between `X` and `-X` in the other two slots, which is
exactly what three slots are for. Make **the integral an average first and
an area second**, which is how the source orders it and is the better way
round: the average survives a function crossing the axis, and negative area
is the awkwardness you invent to keep the other story consistent. Add the
trapezoid and Simpson estimates to the existing left, right and midpoint
sums, and check the exact bracket relation rather than asserting the error
orders. Inflection points and tangent-line drawing **[wall]**: the graph
analysis keys stop at root, minimum, maximum, derivative and integral.

**Chapter 5, Calculus II.** Newton's method, as planned. Then the interval
of convergence made visible, which is the point the first edition's Taylor
section misses entirely: `1/(1+X)` and its approximating polynomials agree
on a fixed interval that never widens, while sine's agree on an interval
that widens with every term. One picture each and the contrast does the
teaching. Add the error curve `abs(Y1-Y2)` plotted directly, pi recovered
as four times the integral of `1/(1+X^2)` from 0 to 1, the
1-to-the-infinity form now that the route round `^` is confirmed, and
improper integrals of the first kind, where the trouble is at the near end
and the integrand is infinite there. The last is currently one exercise.

**Chapter 6, Linear Algebra.** Gram-Schmidt on three vectors, rather than
the single projection-and-subtract the first edition stops at: Free85's
three-component vectors and its `SCL`, `SUB`, `NRM` and `DOT` keys are
exactly the toolkit, and the result is an orthonormal frame you built
yourself. Add back substitution as an act of its own, so elimination and
solving are two ideas rather than one key. The singular-matrix round-off
trap is **dropped**, per the probe above.

**Chapter 7, Differential Equations.** The logistic and Gompertz equations
become the chapter's spine, with the dye tank demoted to a warm-up, and the
comparison is where their inflection points sit and how each approaches its
ceiling. The slope field becomes a diagram, since the mode draws solutions
and not directions **[wall]**. Overlaying a family of solutions from
different initial conditions **[wall]**: no picture store, and the
existing section on the frozen initial condition already tells that story
honestly.

**Chapter 8, Engineering Mathematics.** The pendulum needs rebuilding, and
this is the chapter's biggest improvement. The first edition hands the
reader a finished integrand with no account of where it came from. The
honest order is the source's: write the period as the integral that
conservation of energy gives you, try it on the machine, watch it fail
because the integrand is infinite at the top of the range, then do the two
trigonometric identities and the substitution that turn it into a proper
integral the machine can take. **Do the mathematics so the machine can
succeed** is the lesson, and it is worth a section on its own. Add the
circular error as a percentage table and use the solver to find the
amplitude at which it reaches one per cent, which is currently only an
exercise. In the vector section add the scalar triple product as a volume,
the cross product's magnitude as a parallelogram's area, and the distance
between two skew lines. In the series section, sum until the term falls
below a tolerance instead of counting a fixed number of terms.

## 5. Exercises

Each Try it panel gets as many exercises as the section's techniques
actually support, which is more than three and is not the same number
twice. Two kinds have to be present in every section: one that asks the
reader to predict, sketch or work something out on paper *before* pressing
a key, and one that reaches an answer the section already found by a second
route. Beyond those, the section decides.

## 6. No budgets

The first version of this plan set targets: so many captures, so many
diagrams, so many sections, so many exercises. That was the same mistake
the brief identifies in the first edition, where 49 figures across 47
sections is the tell that nobody decided per section what deserved a
picture. A quota decided in advance is a quota that gets filled whether or
not the page needs it, and starved when the page needs more.

So there are no numbers here. The rules instead:

- **Captures** wherever a reader could be unsure their screen matches what
  the text just claimed, and wherever a menu, soft-key page, editor or
  error screen is referred to but never shown. Some sections will want one.
  The pendulum section will want a dozen.
- **Diagrams** wherever the mathematics needs a picture the calculator
  cannot draw. SVG at `docs/companion/images/fig-NN-slug.svg`, on
  `fig-08-pendulum.svg`'s palette: navy `#1a3a6b` and ink, no gradients,
  nothing carrying meaning in colour alone.
- **Sections** as the subject needs. Chapters will end up unequal, and they
  should: the source spends 22 pages on precalculus and 84 on probability
  and statistics, because those subjects are not the same size. The first
  edition's near-uniform chapters are an artefact of planning, not of the
  mathematics.
- **Length** as the above produces. My estimate of where that lands is
  worth little until a chapter is actually written, which is what the pilot
  is for.

The build's assertions get moved out of the way rather than written to.
`maxPages` is a guard against a truncated render, not a target, so it goes
wide enough to stop mattering; the exact-10-files and exact-8-chapters
checks are guards on our own structure and can be updated if a chapter
needs splitting. Nothing about the shape of this book should be decided by
a number in `build-guidebook-typeset.js`.

One fact rather than a cap: this is an A5 workbook, and past a certain
extent it stops being one physical object. If the honest version lands
there, that is a binding decision for you, not a reason to write less.

## 7. Working method

- Every capture declared in `scripts/companion-screens.js`, generated, and
  then **looked at**, because a half-drawn screen throws nothing.
- Every quoted number run on the emulator. Change an example, re-run it.
- Feasibility probed before a topic is promised, as in section 3.
- The sample below introduces H3 sub-headings inside a numbered section,
  which the book has not used before. Sections are getting long enough to
  need signposts. `typeset.css` will need a rule for them and the page
  breaks want checking, so this gets settled in the pilot chapter.
- `SJASMPLUS=<path> npm run update:free85:reproducibility` at the end,
  because the web build writes under `public/`; sjasmplus built from source
  first. `npm test` green at 194 throughout.
- Order: front matter and chapter 4 as the pilot, built and shown to you
  before the rest; then 8, 7, 3, 5, 1, 2, 6, worst prose and thinnest
  mathematics first.

The one real constraint is not page count, it is verification. Every number
and every screen in this book is run rather than asserted, and that is
slow. It is a reason to sequence the work and show you a finished chapter
early. It is not a reason to make the book smaller.

## 8. The voice, second attempt

The first attempt was rejected, and rightly. It was plain, which is not the
same as being taught by anyone. It narrated the keyboard, handed down
verdicts, and quietly kept up the first edition's habit of finishing every
paragraph with something quotable. Nobody was in the room.

Reading the two books you sent, three things stand out that both do and
neither of my drafts did.

**They name the frightening thing and then puncture it.** Thompson lists
the "dreadful symbols", says `d` merely means a little bit of, and finishes
the chapter with "That's all." Two words, and the terror is gone. He is
not simplifying the mathematics, he is refusing to let the notation act as
a doorman.

**They tell you the truth about the difficulty.** Schaefman says outright
that reading mathematics is not like reading a newspaper and that you will
reread a line several times before it clicks. Thompson says he is a
remarkably stupid fellow who had to unteach himself the difficulties.
Neither is fishing for sympathy. Both are giving the reader permission to
find it hard, which is what stops people quietly concluding they are the
problem.

**They are generous with what an expert would hold back.** Thompson works
the ladder in actual inches, 19 and 180 and 179.89, when he could have left
it in symbols and looked cleverer. Schaefman hands over the two-player
precision game as a device you can use yourself. That generosity is the
thing your Dave Plummer comparison is really about: he tells you what
actually happened, including what went wrong, because he has nothing to
prove. The teacher everyone shut up for was never the one performing
expertise. It was the one who had obviously done the thing and was telling
you the truth about it.

So: first person where it earns its place and nowhere else, warnings before
the mistake rather than explanations after it, the reader's own question
voiced out loud, and not one sentence written to be quoted.

### And Plummer, which is the part I skated over

I name-checked him last time and then did not do the work. Doing it
properly changes more than the other two books did.

What makes people sit still for Dave Plummer is not warmth and it is not
plain language. It is this: **the credential arrives inside the story as a
plain fact, and is never claimed.** He does not say "as an expert in
Windows internals". He says "when I wrote Task Manager, we had to..." and
carries on. The authority leaks out incidentally. It is unarguable, because
he is not arguing it.

Everything else follows from that. He can afford to tell you what actually
went wrong, because being the fool in his own story costs him nothing. He
explains the constraints of the moment, so a decision that looks stupid
from here turns out to be the only sane call at the time. He is generous
with the detail a lesser teller would hold back to seem clever. He is
unhurried, which is its own kind of confidence. And he will say plainly
when he does not know, or when he is out of date.

Now here is the thing I missed. **This book has the best version of that
credential available to any calculator workbook anywhere, and it uses it
exactly once.** I grepped: in 1,441 sentences there is one first person,
in chapter 7, "a mixing tank of my own design".

You built the machine. Every limit in this book is a decision somebody
made on purpose: three graph slots, eight-line programs, 128 columns,
fourteen digits, `^` taking whole exponents from -9 to 9. The first
edition states all of them in the passive voice, as though they were
weather. "The plot samples 128 columns." "Free85's three slots." Nobody
did any of it. It just is that way.

That is the missing ingredient, and it is not a tone. It is authorship.

And the reasons are still in the repo. I went and looked for two of them:

- `firmware/free85/numeric/evaluator.asm:712` is `numeric_integer_power`,
  and it is a multiply loop counted by a single packed-decimal digit. It
  checks the exponent byte is zero and every digit after the first is zero,
  then multiplies. That is *why* `^` stops at 9 and refuses fractions. It
  is not an arbitrary ceiling, it is what a repeated-multiplication power
  looks like when the counter is one digit wide.
- `firmware/free85/include/memory.inc:46` says a number is a decimal
  exponent plus fourteen packed BCD significant digits, seven bytes. That
  is *why* fourteen, and it is why `EVAL(1E-9)` comes back as exactly 1.

Neither of those facts appears anywhere in the book. Both are more
interesting than the sentence currently standing in their place.

So the third change, on top of the other two: **the book gets an author who
built the thing.** Sparingly, never as a boast, and only where the reason
is genuinely better than the bare fact. Below are the revised passages.

Every number and screen is the same verified emulator output as before.

---

## 4.1 Limits by table and zoom

What is sin x divided by x, when x is nought?

Nothing. There is no answer. Nought over nought is not a number, and in a
few minutes the machine will tell you so in as many words.

That is not the interesting question though. The interesting one is what
the thing is *nearly*, when x is *nearly* nought. That does have an answer,
a perfectly definite one, and going and getting it is what a limit is.

I have not chosen this example to be clever. It is the one every calculus
course does, and for a good reason: it is the fact that makes the
derivative of sine come out as cosine. Get this one and you have paid for
most of the chapter in advance.

We will go at it four ways. Draw it, tabulate it, probe it, and then do
some paper. Three of those will point at the answer. Only the last one will
actually deliver it, and the difference between pointing and delivering is
most of what this section is about.

### Getting it into the machine

1. Press [CLEAR]. There is probably something left on the entry line from
   whatever you did last, and the machine will cheerfully add your new
   typing onto the end of it.

2. Press [SIN]. You get `SIN(`, bracket included. Then [x-VAR], [)], [÷],
   [x-VAR].

   Read the line before you go on. It should say `SIN(X)/X`. If it says
   `SIN((X)/X` you have pressed [(] out of habit after [SIN], which
   everybody does once. Press [CLEAR] and type it again.

3. Press [GRAPH]. That stores the line into `Y1` and draws it in the
   standard window, -10 to 10 both ways.

   Sine is slow work for this machine. Let the curve reach the right-hand
   edge before you touch anything, because presses that land mid-draw go
   nowhere and you will decide the key is broken.

   ![The bump of SIN(X)/X, flattened almost to nothing by the standard window](images/co04-sinx-standard.png)

### The graph, which is no help at all

Look at what you have got. A small bump over the origin, ripples either
side, the whole thing squashed into a band a few pixels high.

That is the window's doing. You have made room for heights from -10 to 10,
and this function never leaves the range -0.3 to 1, so nine tenths of the
screen is empty sky. It is section 1.1's complaint in its natural habitat.

Fix it and get closer.

4. Press [+] three times, waiting for each replot. Each press halves every
   bound, so you are now looking at -1.25 to 1.25 and the bump fills the
   screen.

5. Press [▶] twice. The readout says `X=0.0492125984252` and
   `Y=0.99959640223576`.

   ![The zoomed bump with the trace two columns right of centre](images/co04-sinx-zoom-trace.png)

   So a twentieth of a unit right of the middle, the function is 0.9996.
   Encouraging.

Now find the hole.

You cannot. Zoom as long as you have patience for and the curve stays a
smooth unbroken arc, straight through the point that is not there.

Here is why, and it is worth having straight because it will come back at
you later in this book. The machine draws by choosing 128 columns across
the window and working out the height at each. Nought is not one of those
columns and no amount of zooming will make it one. A missing point one
point wide is invisible to something that only ever looks in 128 places.

It is not lying to you. You asked about 128 columns and it answered about
128 columns. The question you wanted to ask was about somewhere it never
looks.

### The table, which is

The table asks at values you choose, nought included. So it can catch what
the plot cannot.

6. Press [2nd] [+] for the standard window, let it redraw, then [MORE] for
   the table.

   ![The table, with UNDEF sitting on the X=0 row](images/co04-sinx-table.png)

   The `X=0` row says `UNDEF`. There it is. The machine has gone away, tried
   to divide nought by nought, failed, and come back and told you.

   Underneath: `0.841`, `0.454`, `0.047`, `-0.18`, `-0.19`. Those are the
   ripples, not the answer. By `X=1` we are down to 0.841 and falling.
   Whatever is going on near nought is going on much closer in than a step
   of 1 can see.

7. Press [-] four times. Each press halves the table step, so you go 1,
   0.5, 0.25, 0.125, 0.0625. Let each redraw settle before the next press.

   ![The same table at step 0.0625, the values climbing towards 1](images/co04-sinx-table-fine.png)

   Read the rows below the hole *upwards*, towards it: 0.983, 0.989, 0.994,
   0.997, 0.999. And the `X=0` row still says `UNDEF`.

   That is the whole shape of it. Walk in towards nought and the values
   climb towards 1 without ever arriving, and at nought itself there is
   simply nothing at all.

8. Press [▲] to see the other side. From `X=-0.31` the rows read `0.983`,
   `0.989`, `0.994`, `0.997`, `0.999`, then `UNDEF`.

   The same five numbers in the same order, and that is not luck. Sine is
   odd, so sin(-x) over -x is the same thing as sin x over x. The function
   is a mirror image about the y axis with one point missing out of the
   middle, so both sides always had to climb to the same place.

### Squeezing better numbers out of it

The table gives you three decimal places, because that is all a
five-character cell will hold. The calculus commands will do better.

9. Press [EXIT] to leave the table, [EXIT] again for the home screen, and
   [CLEAR] to get rid of the equation the graph has just handed back to
   you.

10. Spell out `EVAL(.1)` (letters are [ALPHA] and then the key with that
    letter on it) and press [ENTER]. You get `0.99833416646834`.

11. Now smaller. Press [CLEAR] before each one:

    | Ask this | Get this |
    | --- | --- |
    | `EVAL(.01)` | `0.99998333341673` |
    | `EVAL(.001)` | `0.9999998333334` |
    | `EVAL(-.001)` | `0.9999998333334` |
    | `EVAL(.0001)` | `0.9999999983334` |

    Watch the nines. Two more of them every time x shrinks by a factor of
    ten. That is a rate, rates are worth noticing, and in a few minutes we
    will work out exactly where this one comes from.

    Notice too that `.001` and `-.001` agree in every last digit. That is
    step 8's mirror again, now stated to fourteen places.

12. Push it harder. `EVAL(1E-6)`, with the `E` typed as [EE], gives
    `0.9999999999999`. `EVAL(1E-9)` gives `1`, flat.

    Be careful with that last one. It does not mean the function equals 1 at
    a billionth.

    A number in this machine is fourteen significant digits. That is seven
    bytes of packed decimal, two digits to the byte, and it is all the room
    a number gets. At a billionth, sine of x and x agree in all fourteen of
    them, so the division comes out as exactly 1. Nothing has been
    discovered. The machine has simply run out of places to keep the
    difference.

    That is a fact about seven bytes, not a fact about sine. Confusing the
    two is the classic way to fool yourself with a calculator, and knowing
    the byte count does not make you immune. It just means that when a
    number looks too clean, you know which drawer to go and look in.

13. Now ask it the original question. Press [CLEAR], spell `EVAL(0)`, and
    press [ENTER]:

    ![EVAL at the hole, stopped on SYNTAX ERROR](images/co04-sinx-eval-error.png)

    `SYNTAX ERROR`, with `CLEAR OR EXIT` underneath.

    That message is wrong and it is my fault. There is nothing whatever
    wrong with the syntax of `EVAL(0)`. What has actually happened is that
    the evaluation failed at the point you asked about, and the calculus
    commands report every failure of that kind through the error the parser
    already had to hand. Laying it out again I would give it its own
    message, one that mentioned the point rather than your typing.

    So read it as "there is nothing there", because that is what it means,
    and it will go on meaning that every time a calculus command lands on a
    point where a function has no value.

    Press [CLEAR] to clear the notice. The entry line still holds `EVAL(0)`,
    so press [CLEAR] again to empty that too. Two presses of [CLEAR] after
    any error screen: the first kills the message, the second empties the
    line. Get into the habit early and you will save yourself a lot of
    puzzled retyping.

### Why it is 1, which none of that proved

Stop and take stock for a moment. Everything so far points at 1. Nothing so
far has proved 1.

That is not a quibble. A machine can try a hundred values, or a million; a
limit is a claim about all of them at once, and no amount of trying will
ever get you there. Pointing you at what to go and prove is what the
machine is genuinely good for. It cannot do the other job and it is
important not to let it pretend otherwise.

So here is the proof, and it is a nice one.

Draw a unit circle and take a small angle x at the centre. There are three
regions, each sitting inside the next: the triangle inside the sector, the
sector itself, and the larger triangle outside it.

![A unit circle sector with the triangle inside it and the triangle outside it, the three areas that squeeze sine over x](images/fig-04-squeeze.svg)

Their areas are sin x over 2, then x over 2, then tan x over 2. Divide the
lot through by sin x over 2, turn the inequality upside down, and what is
left is that cos x sits below sin x over x, which sits below 1.

Now let x head for nought. Cosine heads for 1. The quotient is trapped
between a thing heading for 1 and 1 itself, so it has nowhere to go but 1.

That is the squeeze, and you can watch it close.

14. Press [CLEAR] and ask `COS(.1)`: `0.99500416527802`. Step 10 gave
    `0.99833416646834` at the same x. Sure enough, the quotient is sitting
    between them, in a gap five thousandths wide.

    Press [CLEAR] and ask `COS(.01)`: `0.99995000041666`, against the
    quotient's `0.99998333341673`. The gap is down to five
    hundred-thousandths. Push the walls together and whatever is between
    them has no say in the matter.

There is a second route, and it explains those nines from step 11.

Sine of x is x, take away x cubed over 6, plus smaller stuff. Divide by x
and sin x over x is 1, take away x squared over 6, plus smaller stuff
still. So the error ought to go like x squared over 6: shrink x by a factor
of ten and the error should shrink by a hundred, which is two more nines.
Which is exactly what you saw.

15. Test it. Press [CLEAR] and type `1-.1^2/6`: `0.9983333333334`, against
    the quotient's `0.99833416646834`. Agreement to six decimals. Press
    [CLEAR] and type `1-.01^2/6`: `0.9999833333334`, against
    `0.99998333341673`. Nine decimals.

    That one is worth carrying around in your head. For small x, sin x over
    x is 1 take away x squared over 6, and you can do it without a machine
    at all.

### The bit nobody tells you

The answer 1 is not really a fact about sine. It is a fact about sine
*measured in radians*, and I can show you that in about ten key presses.

16. Press [2nd] [MORE] for the mode screen, press [F1] once so the second
    line reads `ANGLE DEG`, and press [EXIT].

17. Press [CLEAR], type `SIN(X)/X` again, and press [GRAPH]. Let it draw.
    It comes out as a flat line lying on the axis, which is your first clue
    that something has changed underneath you.

18. Press [EXIT], press [CLEAR], and ask `EVAL(.1)`: `0.017453283658983`.
    Press [CLEAR] and ask `EVAL(.001)`: `0.017453292519057`.

    Still converging. Converging on something else entirely. Press [CLEAR]
    and type `PI/180`, with the `π` legend on [2nd] [^]:
    `0.017453292519943`. That is where the probes are heading, and by
    x = .001 they have got nine decimal places of the way there.

    It is the chain rule wearing a false moustache. A degree is π/180 of a
    radian, so working in degrees quietly multiplies every angle by π/180
    before the sine ever gets a look at it, and the limit gets multiplied by
    the same thing. Radians are simply the unit that makes the constant come
    out as 1. That is the real reason calculus insists on them, and it is a
    much better reason than "because the book says so".

19. Press [2nd] [MORE], press [F1] once to get back to `ANGLE RAD`, and
    press [EXIT].

    Do not skip that. I have left a machine sitting in `DEG` and then spent
    a quarter of an hour deciding the firmware was broken, when every
    trigonometric answer in the next section was simply being quietly
    scaled by π/180. It is a very cheap way to waste an afternoon.

**Try it.**

1. Try the same four ways on `(1-COS(X))/X`. Table first, then probes at
   .1, .01, .001. Where is it heading? Then do the same for
   `(1-COS(X))/X^2` and work out what dividing by the extra x changed.
2. Guess before you press anything: `SIN(2*X)/X`. The limit is not 1. Work
   out what it should be from the series in step 15, write your answer
   down, and then go and check it at .01 and .001. Being wrong here is
   useful, so write the guess down before you look.
3. In step 7 you halved the table step four times and got to 0.999. Halve
   it four more times and read the same row. How many nines does the cell
   give you now, and what is stopping it giving you more? (The answer is
   about the cell, not about the mathematics.)
4. `EVAL(1E-9)` came back as exactly 1 in step 12, and we said that was the
   machine running out of room. Find the largest power of ten at which the
   answer is still visibly short of 1. That number tells you something
   about the machine you are holding. What?
5. Turn it upside down: store `X/SIN(X)` and probe from both sides. Its
   limit has to be 1 as well, and you can say why in one line. Then try to
   run the squeeze argument of step 14 on it unchanged and see where it
   goes wrong. Fixing it is a two-line job once you spot the trouble.
6. Put the machine in `DEG` and redo exercise 2. Predict the answer before
   you press a key, using what step 18 showed you. Then set it back to
   `RAD`, because you will want it there for section 4.2.
---

## 9. A second demonstration, because it is the clearest one

The passage above shows the authorial voice patching an existing paragraph.
This one shows what it unlocks that was not previously writable at all.

Three chapters currently trip over the same limit: `^` takes whole
exponents from -9 through 9, so compound interest, base-two exponentials
and anything with a fractional power all have to be routed through
`EXP(X*LN(b))`. The first edition treats this three separate times as an
obstacle to be got round. It never says why the obstacle is there, because
under the old voice there was nobody available to say.

Belongs in 1.4. Every claim in it comes from
`firmware/free85/numeric/evaluator.asm:712`.

> **Why the power key gives up**
>
> Type `1.06^2` and you get `1.1236`. Type `1.06^2.5` and you get
> `DOMAIN ERROR`. That looks like something broken, and it is the thing I
> get asked about most, so here is what is really going on in there.
>
> The `^` key is a multiply loop. It takes a copy of the left-hand number,
> multiplies it by itself, and goes round again, counting down as it goes.
> The counter is a single packed-decimal digit, because that was the
> smallest thing that would do the job, and a one-digit counter counts to
> nine. Before any of that starts, the routine looks at every digit of the
> exponent after the first and refuses if any of them is not zero, which is
> how it satisfies itself that you have handed it a whole number.
>
> So `1.06^2.5` is not the power routine failing. It is the power routine
> correctly noticing that it has been given something it has no method for,
> and saying so rather than guessing.
>
> The way through is an identity you will use all over this book: b to the
> power x is e to the power x ln b. Both of those the machine does have.
> Press [CLEAR] and type `EXP(2.5*LN(1.06))` and there is your answer,
> `1.1568170026417`, no multiply loop involved.
>
> Worth knowing where the join is. `1.06^2` and `EXP(2*LN(1.06))` are the
> same number mathematically and they are not always the same number here:
> one is two exact multiplications, the other is a logarithm and an
> exponential, each rounded to fourteen digits. Try both and see how far
> down they part company.

Notice what that gets you for free. It explains a wart instead of
apologising for it, it hands over a technique the reader will need six more
times, and it ends by turning the wart into an experiment. None of that was
reachable while the machine's limits were weather.

**One caveat, and it matters.** The two facts above are checked against the
firmware. The *judgement* in them is not mine to make: whether the
one-digit counter was a size decision or a speed one, whether you would
really give the calculus commands their own error message, whether `^`
was always meant to stay bounded. I can write the shape of an authorial
sentence, but I cannot invent your reasons, and a made-up reason in your
voice is worse than no reason at all. Where the pilot chapter needs one, I
will mark it and ask rather than fill it in.

## 10. What is being asked

Only one thing now: **the voice in sections 8 and 9**. Accept it, or say what is wrong
with it, and chapter 4 gets written and shown to you as a finished
chapter.

Everything else in this plan is a rule rather than a request. Section 4's
additions are what "not enough mathematics" turns into once the source has
been read properly; sections 5 and 6 say the book gets the exercises and
the figures it needs and stops counting them. None of that needs your
approval in advance. The pilot chapter will show it working or show it
failing, which is a better thing to judge than a table of estimates.
