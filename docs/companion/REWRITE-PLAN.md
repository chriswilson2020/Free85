# Second-edition plan for Explorations with Free85

Answering the brief at `REWRITE-BRIEF.md`. Revised twice: once after reading
the source book in full, once after the voice was rejected and rebuilt.
Nothing in the book has been changed yet.

The source is *Explorations with the Texas Instruments TI-85*, Harvey and
Kenelly (eds.), Academic Press, 1993, 374 pages, eight chapters by eight
authors. It was read the way section 1 of the brief prescribes: for scope,
depth and level, with structured notes on what to cover and how far to push
it, then written from the notes. No sentence of it is reproduced anywhere.

## 1. Where the first edition stands, measured

Baseline build from a clean tree:

```
companion: 1818 keycaps, 49 framed screenshots, 1 maths diagram,
           8 chapters, 47 numbered sections, 47 Try it panels
wrote dist/guidebook/Free85-Companion-typeset.pdf (114 pages)
```

## 2. What changed in this plan, and why

Five things the first version of this plan got wrong.

**a. It under-counted the missing mathematics.** "Push each section further"
became, once the source had been read, a specific list of about thirty named
standard topics the first edition does not contain. Section 5 below. Several
are better than anything I would have invented.

**b. It under-weighted the exercises.** The source closes each section with
around ten; the first edition closes each with three. More important than
the count is the kind: the source repeatedly asks the reader to predict or
sketch first and check afterwards. The first edition almost never does.

**c. It planned to fill gaps that are walls.** The simplex method needs a
3 by 6 tableau against a 3 by 3 ceiling; phase planes need two state
variables against one; overlaying solution families needs a picture store
that does not exist. These are not omissions to repair. Section 3 turns
them from apologies into the book's best material.

**d. It set budgets, which was the brief's own complaint in a new place.**
49 figures across 47 sections is a quota. So is 109. Section 7 replaces
every number with a rule.

**e. Its voice was wrong twice, and the second failure was the instructive
one.** The first attempt was ornate. The second was plain, which is not the
same as being taught by anyone: it narrated the keyboard and kept the habit
of landing every paragraph on something quotable. What was missing was not
a register. It was a person. Section 3.

## 3. The voice

This is the section that matters most, so it comes first, and it is written
as rules rather than as an account of how I got to them.

### 3.1 Where it comes from

Three sources, each contributing something the drafts lacked.

**Thompson, *Calculus Made Easy*.** Name the frightening thing, then
puncture it. He lists the "dreadful symbols", says `d` merely means a little
bit of, and closes the chapter with "That's all." He is not simplifying the
mathematics; he is refusing to let the notation act as a doorman. He also
works his examples in real inches when symbols would have looked cleverer.

**Schaefman, *Math Letters*.** Tell the truth about the difficulty.
Reading mathematics is not like reading a newspaper; you will reread a line
several times before it clicks, and saying so out loud is what stops a
reader concluding that they personally are the problem. He also hands over
devices for thinking, not just results.

**Plummer.** The credential arrives inside the story as a plain fact and is
never claimed. Not "as an expert in Windows internals" but "when I wrote
Task Manager, we had to...", and on with the story. The authority leaks out
incidentally, which makes it unarguable. Everything else follows from having
nothing to prove: he can afford to be the fool in his own story, he explains
the constraints of the moment so that a decision which looks stupid from
here turns out to have been the only sane call, and he is generous with
detail a lesser teller would keep back.

### 3.2 The rule the first edition never found

**The book has an author, and he built the machine.**

I grepped for it: in 1,441 sentences there is exactly one first person, "a
mixing tank of my own design", in chapter 7. Everything else is written from
nowhere. Three graph slots, eight-line programs, 128 columns, fourteen
digits, `^` stopping at 9: every one of those is a decision somebody made on
purpose, and all of them are stated in the passive voice, as though they
were weather.

That is the missing ingredient, and it is not a tone. It is authorship.

The reasons are still in the repo and they are better than the sentences
currently standing in their place:

- `firmware/free85/numeric/evaluator.asm:712`, `numeric_integer_power`, is a
  multiply loop counted by a single packed-decimal digit. It checks the
  exponent byte is zero and every digit after the first is zero, then
  multiplies. That is why `^` stops at 9 and refuses fractions.
- `firmware/free85/include/memory.inc:46` gives a number a decimal exponent
  and fourteen packed BCD significant digits, seven bytes. That is why
  fourteen, and why `EVAL(1E-9)` comes back as exactly 1.

Neither fact appears in the book.

### 3.3 The rules

1. **First person only where it carries something** the third person could
   not: a reason from the firmware, a mistake worth confessing, a judgement
   that is genuinely the author's. Never as decoration, never as a boast.
   Three or four times a section at most, and some sections will want none.
2. **A limit gets its reason, or it stays a bare fact.** No inventing. Where
   the reason exists in the firmware, go and get it. Where it is a design
   judgement only Chris can supply, mark it and ask.
3. **Warn before the mistake, not after it.** "You have pressed [(] out of
   habit after [SIN], which everybody does once" beats a note explaining
   the error screen afterwards.
4. **Voice the reader's question out loud** rather than pre-empting it.
5. **Name the frightening thing, then puncture it.** Short sentence, plain
   words, move on.
6. **Say when something is hard, awkward, or a wart** including the author's
   own. Warts get their constraint explained, not an apology.
7. **Be generous with the detail an expert would hold back.** The technique,
   the actual numbers, the reason. No "beyond the scope of this book".
8. **Nothing written to be quoted.** If a sentence would look good on a
   poster, cut it. This was the first edition's real vice and it survived
   into my plain draft in quieter clothes.
9. House style unchanged: no em dashes, British spelling, sentence case
   headings, keys bracketed with every [CLEAR] spelled out, on-screen text
   in code spans, every quoted number copied exactly from the emulator.
10. Unchanged too: at most one "honest" per chapter. It was a crutch.

### 3.4 What this changes outside the chapters

- **The front matter** currently reads "This book, like the firmware and
  like the two books before it, was written from scratch for Free85."
  Written by nobody. It should introduce the person who built the machine
  and say plainly what he is doing here, in one short paragraph, once.
- **The afterword** is the passage that gains most. It already argues that a
  bounded instrument is the point; it argues it from nowhere. The person who
  chose the bounds saying why he chose them is a different and much stronger
  page, and it is the natural place to put the reasons that did not fit in a
  chapter.
- **Every wall in section 5 becomes an opportunity.** "The simplex needs a
  3 by 6 tableau and matrices stop at 3 by 3" is an apology. "Here is why
  matrices stop at 3 by 3, and here is what that costs you and what it buys
  you" is the book's thesis doing actual work. The walls were always the
  best material; there was nobody available to write them.

### 3.5 Exhibits

Section 9 is 4.1 rewritten under these rules, with three passages carrying
the authorial voice. Section 10 is a second passage, on the power operator,
which shows what the rules unlock that was not previously writable at all.
Every number and screen in both is verified emulator output.

## 4. Capability probes already run

Before promising anything I ran the new candidates on the emulator. Results
that changed the plan:

| Probe | Result | Consequence |
| --- | --- | --- |
| `NCR(5,2)` | `10` | Free85 **has** combinations. Binomial probabilities by formula are open to chapter 3, which I had assumed were not. |
| `DET` of 1,2,3 / 4,5,6 / 7,8,9 | `0`, exactly | Free85 does **not** reproduce the classic singular-matrix round-off trap. I had this pencilled as a headline addition to chapter 6. Dropped: I will not print a failure the machine does not have. |
| `EXP(LN(1+.001)/.001)` | `2.7169239351903` | The 1-to-the-infinity indeterminate form is reachable, routed round `^`'s whole-exponent limit. |
| `-Y*LN(Y/8)` at `Y=3` | `2.9424877590348` | The Gompertz slope evaluates, so it can go in the DifEq slot beside the logistic. |
| `X*SIN(1/X)` with `X` and `-X` in the other two slots | plots, but the interesting part is invisible in the standard window | The squeeze exploration works and needs three presses of [+] to see. That window hunt is the lesson, not an obstacle. |

Remaining feasibility questions (list arithmetic for first differences, what
the DifEq slope does with `X` in it, whether the parametric mode can carry
the unit circle and a sine together) get the same treatment before the
sections that depend on them are written.
## 5. The mathematics to add, by chapter

Every item is a standard topic of its field, taken from the source for
*scope*, and checked against what Free85 can actually do.

Items marked **[wall]** are things the source does that Free85 cannot. Under
section 3.2 these stop being apologies. Each one gets the same treatment:
what you cannot do here, why the machine is built that way, what it costs
you, and what it buys you. Where the reason is in the firmware I go and get
it; where it is a judgement of yours I mark it and ask.

**Chapter 1, Precalculus.** Rational functions and asymptotes are missing
outright: the source ends its first section with a rational function
rewritten as a quadratic plus a remainder, then asks how far right you must
go before the curve and the quadratic differ by less than a thousandth. That
is a section's worth and Free85 can do all of it. Add the four-parameter
wave `A*SIN(B*X+C)+D` taken one parameter at a time, and damped harmonic
motion. Section 1.4 is where the power-operator passage of section 10 goes.
The unit circle becomes a diagram rather than a plot **[wall]**: parametric
mode holds one pair.

**Chapter 2, Business Mathematics.** Sensitivity analysis: move one
constraint's constant, watch a corner move and the optimum with it. The
source makes this a named idea twice; the first edition has nothing like it.
Add the contrast between a well-behaved system and a nearly-parallel one,
which puts conditioning in front of a business reader in chapter 2 rather
than only in chapter 6. The simplex method **[wall]**: a 3 by 6 tableau
against a 3 by 3 ceiling.

**Chapter 3, Probability and Statistics.** The biggest single addition in
the book: **fit a line by hand and watch the sum of squared residuals
fall**. Store a slope and an intercept, loop the eight pairs, accumulate the
squared deviations, display the total; try a better line; then press `LIN`
and find that the machine's answer is the smallest total you could have
reached. That is what least squares *means*, it fits an eight-line program,
and the first edition just presses `LIN` and reads off `A` and `B`. Add
residual plots and what their shapes diagnose, relative frequency converging
on theoretical probability as the trial count grows, and binomial
probabilities by formula now that `NCR(` is confirmed.

**Chapter 4, Calculus I.** The epsilon-delta rectangle: the window is the
box, and a limit exists when you can always shrink the box's width to keep
the curve inside its height. The book's whole thesis is that the window is
an instrument, and this is the sharpest use of it in the source. Add
`SIN(1/X)`, where zooming shows a limit failing to exist, and `X*SIN(1/X)`
squeezed between `X` and `-X` in the other two slots, which is exactly what
three slots are for. Make **the integral an average first and an area
second**: the average survives a function crossing the axis, and negative
area is the awkwardness you invent to keep the other story consistent. Add
trapezoid and Simpson to the existing left, right and midpoint sums, and
check the exact bracket relation instead of asserting the error orders.
Inflection points and tangent-line drawing **[wall]**: the analysis keys
stop at root, minimum, maximum, derivative, integral.

**Chapter 5, Calculus II.** Newton's method. Then the interval of
convergence made visible, which is the point the first edition's Taylor
section misses entirely: `1/(1+X)` and its polynomials agree on an interval
that never widens, sine's on one that widens with every term. One picture
each and the contrast teaches itself. Add the error curve `abs(Y1-Y2)`
plotted directly, pi recovered as four times the integral of `1/(1+X^2)`
from 0 to 1, the 1-to-the-infinity form, and improper integrals of the first
kind where the integrand blows up at the near end. The last is currently one
exercise.

**Chapter 6, Linear Algebra.** Gram-Schmidt on three vectors rather than the
single projection the first edition stops at: `SCL`, `SUB`, `NRM` and `DOT`
are exactly the toolkit and the result is an orthonormal frame you built
yourself. Add back substitution as an act of its own, so elimination and
solving are two ideas rather than one key. The singular-matrix round-off
trap is dropped, per the probe in section 4.

**Chapter 7, Differential Equations.** The logistic and Gompertz equations
become the chapter's spine, the dye tank demoted to a warm-up, and the
comparison is where their inflection points sit and how each approaches its
ceiling. The slope field becomes a diagram **[wall]**: the mode draws
solutions, not directions. Overlaying a family of solutions from different
initial conditions **[wall]**: no picture store. The existing section on the
frozen initial condition already tells that story well and now gets to say
who froze it.

**Chapter 8, Engineering Mathematics.** The pendulum needs rebuilding and
this is the chapter's biggest improvement. The first edition hands over a
finished integrand with no account of where it came from. The honest order
is the source's: write the period as the integral conservation of energy
gives you, try it, watch it fail because the integrand is infinite at the
top of the range, then do the two trigonometric identities and the
substitution that turn it into a proper integral the machine can take. **Do
the mathematics so the machine can succeed** is the lesson and it is worth a
section. Add the circular error as a percentage table and the solver finding
the amplitude at which it reaches one per cent, currently only an exercise.
In the vector section add the scalar triple product as a volume, the cross
product's magnitude as a parallelogram's area, and the distance between two
skew lines. In the series section, sum until the term drops below a
tolerance rather than counting a fixed number of terms.

**Afterword.** Per section 3.4, this stops being a summary and becomes the
place the person who chose the bounds explains why, and where reasons that
did not fit a chapter get their home.

## 6. Exercises

Each Try it panel gets as many exercises as the section's techniques
support, which is more than three and is not the same number twice. Three
kinds have to be present in every section:

- one that asks the reader to predict, sketch or work something out on paper
  **before** pressing a key, with an instruction to write the guess down,
  because being wrong on paper is the point;
- one that reaches an answer the section already found by a second route;
- one that pushes past where the section stopped, so the panel is an
  invitation and not a quiz.

Beyond those three, the section decides.

## 7. No budgets

The first version of this plan set targets: so many captures, so many
diagrams, so many sections. That was the brief's own complaint in a new
place. 49 figures across 47 sections is the tell that nobody decided per
section what deserved a picture, and a quota decided in advance gets filled
whether or not the page needs it and starved when the page needs more.

So there are no numbers. Rules instead:

- **Captures** wherever a reader could be unsure their screen matches what
  the text just claimed, and wherever a menu, soft-key page, editor or error
  screen is referred to but never shown. Some sections want one. The
  pendulum section wants a dozen.
- **Diagrams** wherever the mathematics needs a picture the calculator
  cannot draw. SVG at `docs/companion/images/fig-NN-slug.svg`, on
  `fig-08-pendulum.svg`'s palette: navy `#1a3a6b` and ink, no gradients,
  nothing carrying meaning in colour alone.
- **Sections** as the subject needs. Chapters end up unequal and should: the
  source spends 22 pages on precalculus and 84 on probability and
  statistics, because those subjects are not the same size. The first
  edition's near-uniform chapters are an artefact of planning.
- **Length** as the above produces.

The build's assertions get moved out of the way rather than written to.
`maxPages` is a guard against a truncated render, not a target, so it goes
wide enough to stop mattering; the exact-10-files and exact-8-chapters
checks are guards on our own structure and can be updated if a chapter needs
splitting. Nothing about the shape of this book should be decided by a
number in `build-guidebook-typeset.js`.

One fact rather than a cap: this is an A5 workbook, and past a certain
extent it stops being one physical object. If the honest version lands
there, that is a binding decision for you, not a reason to write less.

## 8. Working method

- Every capture declared in `scripts/companion-screens.js`, generated, and
  then **looked at**, because a half-drawn screen throws nothing.
- Every quoted number run on the emulator. Change an example, re-run it.
- Feasibility probed before a topic is promised, as in section 4.
- **Design reasons harvested from the firmware, per chapter, before
  writing.** Section 3.2 found two in an afternoon by reading
  `numeric/evaluator.asm` and `include/memory.inc`. Each chapter gets the
  same pass over the code its limits come from, and what turns up goes in
  the chapter or the afterword.
- **Where a limit's reason is a judgement rather than a mechanism, it gets
  marked and asked, never invented.** A made-up reason in your voice is
  worse than no reason at all. Expect a short list of these per chapter.
- The exhibits introduce H3 sub-headings inside a numbered section, which
  the book has not used. Sections are getting long enough to need signposts.
  `typeset.css` needs a rule and the page breaks need checking; settled in
  the pilot.
- `SJASMPLUS=<path> npm run update:free85:reproducibility` at the end,
  because the web build writes under `public/`; sjasmplus built from source
  first. `npm test` green at 194 throughout.
- Order: front matter and chapter 4 as the pilot, built and shown to you
  before anything else; then 8, 7, 3, 5, 1, 2, 6, worst prose and thinnest
  mathematics first.

The one real constraint is not page count, it is verification. Every number
and every screen is run rather than asserted, and that is slow. It is a
reason to sequence the work and show you a finished chapter early. It is not
a reason to make the book smaller.

## 9. Exhibit A: section 4.1 rewritten

Under the rules of section 3. Every number and screen is verified emulator
output. Three passages carry the authorial voice: the fourteen-digit
explanation at step 12, the error message at step 13, and the mode warning
at step 19.

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

## 10. Exhibit B: the power key, which was not writable before

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

## 11. What is being asked

One thing: **the voice of section 3, as it lands in the two exhibits.**
Accept it, or say what is still wrong, and chapter 4 gets written and built
as a finished chapter for you to judge.

Two things I need from you rather than from the repo, whenever you get to
them:

1. **Whether the book acknowledges its author at all.** Section 3.2 is a
   real editorial change, not a stylistic one. It puts you on the page. If
   you would rather it did not, say so now, because half the passages in
   section 5 are written on the assumption that it does.
2. **The judgement calls behind the limits**, as they come up. I can read
   the firmware for mechanisms and I will. I cannot read it for reasons.

Everything else is a rule rather than a request. Sections 5 to 8 say what
gets added, how many exercises, how many figures, and in what order, and
none of it needs approval in advance. The pilot chapter will show it working
or show it failing, which is a better thing to judge than a plan.
