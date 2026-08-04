# Chapter 4: Explorations in Calculus I

Calculus asks what functions do at places you cannot reach: infinitely
close to a point, or added up across infinitely many slivers. A calculator
cannot reach those places either. What it can do is walk a very long way
towards them and report back, and this chapter is largely about learning to
read those reports properly, including the ones that are lying to you.

We probe limits with the table and the zoom keys, meet a limit that does
not exist at all, build a derivative out of raw difference quotients before
letting `NDER(` take over, hunt turning points with the search commands,
measure an integral as an average before measuring it as an area, and
program Riemann sums to watch an integral being assembled. The calculus
commands and the tolerance setting are the Guidebook, chapter 3; the
analysis keys are the Guidebook, chapter 4.

One habit pays for itself all chapter. The calculus commands read the
*active stored equation*, so store the function with [GRAPH] before asking
them anything. With nothing stored, `EVAL(` and its family answer
`SYNTAX ERROR`. Once something is stored they answer whether or not you let
the plot finish drawing.

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
columns and no amount of zooming will make it one: halve the window and you
get 128 new columns, and nought is not one of those either. A missing point
one point wide is invisible to something that only ever looks in 128
places.

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

## 4.2 A limit that is not there

Section 4.1 could have left you with a comfortable and wrong idea: that if
you probe hard enough, a number turns up. It does not always. Some
functions have no limit at all at a point, and the useful skill is telling
which kind you are looking at.

The specimen is sin of one over x. As x heads for nought, one over x runs
away to infinity, so the sine is asked for its value at angles that get
larger and larger without stopping, and it goes on doing what sine does:
up, down, up, down, faster and faster. It never settles anywhere, because
there is nowhere for it to settle.

Then we will change one thing, multiply the whole lot by x, and watch a
limit appear out of the same oscillation.

### Watching it fail to settle

1. Press [CLEAR], then [SIN], [1], [÷], [x-VAR], [)]. The line reads
   `SIN(1/X)`. Press [GRAPH] and let it finish, which takes a while.

   ![SIN(1/X) in the standard window](images/co04-sinrecip-std.png)

   Away from the origin it is calm enough. It is the middle that matters.

2. Press [+] three times, letting each replot finish.

   ![The same curve zoomed in three times, thrashing near the origin](images/co04-sinrecip-zoom.png)

   Now compare that with section 4.1. There, zooming in made the picture
   *calmer* every time, until the curve was nearly a straight line. Here
   zooming in makes it worse. The wiggles do not spread out as you
   magnify, they crowd together, because there are infinitely many of them
   packed into any interval you care to draw round nought.

   Those vertical strokes near the middle are the plotter losing the race.
   It has one column to spend on a stretch of x that contains several
   complete waves, so it joins two samples that happen to be far apart and
   draws a near-vertical line between them. The picture is not wrong, it is
   just badly outnumbered.

3. Probe it and the numbers say the same thing. Press [EXIT], press
   [CLEAR], and ask `EVAL(` at a few points, [CLEAR] before each:

   | Ask this | Get this |
   | --- | --- |
   | `EVAL(.1)` | `-0.544021085826` |
   | `EVAL(.05)` | `0.91294525072816` |
   | `EVAL(.02)` | `-0.26237485369997` |
   | `EVAL(.01)` | `-0.50636564109442` |
   | `EVAL(.005)` | `-0.87329729713503` |
   | `EVAL(.003)` | `0.31884634470865` |

   Put those beside section 4.1's column of nines. There, every probe was
   closer to the answer than the one before it. Here they are all over the
   place, and getting closer to nought does not help at all. Down, up,
   down, down, down, up. That is what no limit looks like when you meet one
   in the wild.

### Where the machine gives up, and why

4. Keep going. Press [CLEAR] and ask `EVAL(.0025)`:

   ![The sine giving up: SYNTAX ERROR at EVAL(.0025)](images/co04-sin-cliff.png)

   `SYNTAX ERROR` again, which by now you know means "no value here". But
   this time it is not a hole in the function. One over .0025 is 400, and
   the machine will not take the sine of 400.

   Here is what is going on inside, because you are entitled to know.

   To work out a sine, the firmware first drags the angle back into a range
   the series it uses can handle, which means somewhere between minus π and
   π. It does that by repeated subtraction: take 2π off, look again, take
   another 2π off, and so on. It is the most obvious method there is and on
   a machine this size it was the right one, because it needs nothing but a
   subtraction it already had.

   What it does need is a stopping rule, in case somebody hands it
   something enormous and it sits there subtracting until the battery dies.
   So the loop gives up after 63 goes. Sixty-three lots of 2π is 395.84, so
   sine works to a little under 400 radians and then declines.

   You can find the edge yourself. `SIN(398)` answers `0.83175800712131`.
   `SIN(399)` stops with the same notice. Between those two the angle stops
   fitting inside 63 subtractions.

   That is a real limit and I am not going to dress it up: it means this
   machine cannot follow sin of one over x closer to nought than about
   x = 1/400. What it does not mean is that you have learned nothing. You
   have watched the function refuse to settle across a factor of forty in
   x, and the mathematics tells you it goes on refusing forever, at a rate
   no calculator was ever going to keep up with.

### The same oscillation with a limit

5. Now change one thing. Press [CLEAR], type [x-VAR], [×], [SIN], [1], [÷],
   [x-VAR], [)] so the line reads `X*SIN(1/X)`, and press [GRAPH]. Let it
   draw.

   The sine is still doing exactly what it did before, swinging between -1
   and 1 infinitely often. But now it is being multiplied by x, and x is on
   its way to nought.

6. Put the walls up so you can see it. Press [2nd] [2] to move to slot
   `Y2`, type [x-VAR], and press [GRAPH]. Press [2nd] [3] for slot `Y3`,
   type [(-)], [x-VAR], and press [GRAPH]. That gives you the lines y = x
   and y = -x on top of the curve.

7. Press [+] three times, letting each replot finish.

   ![X*SIN(1/X) pinched between the lines X and -X](images/co04-squeeze-zoom.png)

   There is the whole argument in one picture. The two straight lines close
   on the origin like a pair of scissors, and the curve is trapped between
   them, oscillating as wildly as ever inside a gap that is being squeezed
   shut. It has no room left to oscillate in.

   This is the squeeze of section 4.1 again, and this time you are not
   taking it on trust from a diagram. It is on the screen, and the three
   slots are exactly the right number of slots to show it: the thing, and
   the two walls closing on it.

8. The probes agree. [CLEAR] before each:

   | Ask this | Get this |
   | --- | --- |
   | `EVAL(.1)` | `-0.0544021085826` |
   | `EVAL(.05)` | `0.045647262536408` |
   | `EVAL(.02)` | `-0.0052474970739994` |
   | `EVAL(.01)` | `-0.0050636564109442` |
   | `EVAL(.005)` | `-0.0043664864856752` |
   | `EVAL(.003)` | `0.00095653903412595` |

   Still bouncing between positive and negative, exactly as before, because
   the sine has not changed its mind about anything. But the size is
   collapsing: five hundredths, then five thousandths, then one thousandth.
   The sign is still random and the magnitude is not. The limit is 0.

   Compare the two tables directly. Same function inside, same oscillation,
   same refusal to settle on a sign. One has no limit and the other has a
   perfectly good one, and the entire difference is the x out in front.

### A test you can actually apply

There is a way to make "settles down" precise, and the graph screen is
unusually well suited to it, because the thing you need is a rectangle and
a window *is* a rectangle.

Say you claim a function heads for L as x heads for a. Someone who doubts
you names a tolerance: they will believe it if the curve stays within that
much of L. Your job is to find a window narrow enough that the curve does
not leave the top or bottom of the screen anywhere inside it, apart from at
a itself.

If you can always do that, however mean the tolerance, the limit is L. If
there is a tolerance you cannot beat by any narrowing at all, there is no
limit.

That is the whole of the epsilon-delta definition, in a form you can carry
out with the zoom keys. Try it on both of this section's functions and the
difference is immediate: for `X*SIN(1/X)` every squeeze you try succeeds,
and for `SIN(1/X)` you cannot even get started, because the curve fills the
band from -1 to 1 no matter how narrow you make the window.

**Try it.**

1. Before pressing anything, write down what you expect the plot of
   `SIN(1/X)` to do far from the origin, out at x = 5 or 10. Then look.
   Why is it so calm out there when it is so violent near nought?
2. Work out on paper the x at which sin of one over x is exactly 1 for the
   first time going left from x = 1, then the next one, then the next. How
   fast are they bunching up? Check one of them with `EVAL(`.
3. `X*SIN(1/X)` is squeezed by `X` and `-X`. Predict what walls would
   squeeze `X^2*SIN(1/X)`, put all three in the slots, and check that the
   picture looks the way you said it would.
4. What about `SIN(1/X)/X`? Predict first: does it settle, blow up, or
   oscillate worse? Then probe it at .1, .05 and .02 and see.
5. The machine gave up at 400 radians because of 63 subtractions of 2π.
   Work out the smallest x at which you could still ask for `SIN(1/X)`, and
   check your answer against the machine by finding the exact place it
   stops.
6. Run the rectangle test of the last part properly on `X*SIN(1/X)`. Start
   from the standard window, pick a tolerance, and count how many presses
   of [+] it takes to satisfy it. Then halve the tolerance and do it again.
   Is the number of presses growing in a way you could have predicted?

## 4.3 The derivative as a limit

The slope of a curve at a point is the limit of the slopes of secant
lines through it, and unlike most limits, this one can be watched
converging digit by digit. The function under study is f(x) = x^3 - 2x at
x = 1.5, where the derivative 3x^2 - 2 works out on paper to 4.75. The
plan: compute (f(1.5+h) - f(1.5))/h by hand for shrinking h, watch 4.75
emerge, then let the machine's own commands answer in one step.

1. Store the function: type [x-VAR] [^] [3] [-] [2] [×] [x-VAR] so the
   entry line reads `X^3-2*X`, press [GRAPH], and let the plot finish.

2. Slope from the graph first. Press [▶] nine times, which lands the
   trace at `X=1.496062992126` with `Y=0.3563689017143`, the sample
   column nearest 1.5. Press [F4], the derivative key: the home screen
   publishes `= 4.714613425`, the slope at the traced sample, a whisker
   under 4.75 because the trace stopped a whisker short of 1.5.

3. Now the secants. The [F4] result left `X^3-2*X` on the entry line, so
   press [CLEAR]. Spell `(EVAL(1.5+1)-EVAL(1.5))/1` and press [ENTER]:
   `= 10.25`, the slope of the secant from 1.5 to 2.5, far too steep.
   Press [CLEAR] and shrink the step to 0.1 with
   `(EVAL(1.5+.1)-EVAL(1.5))/.1`: `= 5.21`. Pressing [CLEAR] each time,
   step .01 answers `= 4.7951` and step .001 answers `= 4.754501`. Each
   tenfold shrink buys roughly one more correct digit of 4.75.

4. Push harder. With step `1E-6` (the `E` typed with [EE]), the quotient
   `(EVAL(1.5+1E-6)-EVAL(1.5))/1E-6` answers `= 4.7500045`. With `1E-9`
   it answers `= 4.75` exactly, and with `1E-12` it answers `= 4.8`. The
   last two need reading with care. Free85 keeps fourteen decimal digits,
   so as h shrinks, f(1.5 + h) and f(1.5) share ever more leading digits,
   and the subtraction cancels them, leaving ever fewer meaningful ones.
   At 1E-9 the survivors happen to round to exactly 4.75; at 1E-12 one
   digit survives and the quotient comes out 4.8. The clean 4.75 is luck,
   not precision: shrinking h sharpens a difference quotient only until
   cancellation blunts it.

5. The built-in command threads that needle itself. Press [CLEAR], spell
   `NDER(1.5)`, and press [ENTER]:

   ![NDER agreeing with the paper derivative](images/co04-nder-result.png)

   The answer is `= 4.75`. `NDER(` takes a central difference, sampling
   both sides of the point, which cancels the largest error term of the
   one-sided secants; the Guidebook, chapter 3 documents the command
   family. As a check on paper's terms, press [CLEAR] and type
   `3*1.5^2-2` (the [x²] key types `^2`): `= 4.75`.

**Try it.**

1. With `X^3-2*X` still stored, run the shrinking quotients at a = 0,
   where f(0) = 0 makes the typing short. What slope do they head for,
   and what does `NDER(0)` say?
2. The backward quotient `(EVAL(1.5)-EVAL(1.5-.01))/.01` uses the other
   side. Compute it, compare it with the forward .01 answer, and say
   which side of 4.75 each lands on and why.
3. Ask `NDER(` at 0, 1, and 2, and check each answer against 3x^2 - 2.
   How many keystrokes of retyping did the stored equation save you?

## 4.4 Extrema by search

Where a smooth function turns, its derivative passes through zero, and
finding the turning points is the first genuinely useful service calculus
sells. The specimen is a cubic designed to be checkable: f(x) =
x^3/3 - 4x, whose derivative x^2 - 4 vanishes at x = -2 (a local maximum,
value 16/3) and at x = 2 (a local minimum, value -16/3).

1. Type [x-VAR] [^] [3] [÷] [3] [-] [4] [×] [x-VAR] so the entry line
   reads `X^3/3-4*X`, press [GRAPH], and let the plot finish. The
   S-shaped curve rises to its hill left of the axis and dips to its
   valley right of it:

   ![The designed cubic with turning points at -2 and 2](images/co04-extrema-cubic.png)

2. Press [F3], the maximum search. The search sweeps the window and takes
   a few seconds; let it finish. It publishes `= -1.9997326856359` on the
   home screen: the *location* of the maximum, not its value, correct to
   about three decimals. The searches stop when their bracket is tight,
   not when the digits are exact, so a short tail of error is normal.

3. The result screen left `X^3/3-4*X` on the entry line, so pressing
   [GRAPH] stores it back unchanged and replots. (Mind the rule: [GRAPH]
   always stores the entry line into the active slot, and storing an
   *empty* line clears the slot, so return to the graph with the equation
   on the line, never from a blank one.) Press [F2], the minimum search,
   and let it settle: `= 1.9997326856359`, the valley mirroring the hill.

4. The home-screen commands take typed bounds instead of the window, and
   the bounds are the search interval, so choose them to bracket one
   extremum. Press [CLEAR], spell `FMIN(0,4)`, press [ENTER], and let it
   work: `= 1.9998801765763`. Press [CLEAR] and ask `FMAX(-4,0)` (the
   sign with [(-)]): `= -1.9998801765763`. Same turning points, slightly
   different last digits: a different interval, a different search path.

5. Values come from `EVAL(` at the found locations, or at the exact ones
   when you know them: [CLEAR], then `EVAL(2)` answers
   `= -5.3333333333333`, and after another [CLEAR], `EVAL(-2)` answers
   `= 5.3333333333333`, the fourteen-digit faces of -16/3 and 16/3.

6. The tolerance setting belongs to this toolkit's small print. Press
   [2nd] [CLEAR], the `TOLER` key: the `TOLERANCE CHANGED` notice
   confirms the cycle from `1E-6` to `1E-8`, and [CLEAR] dismisses it;
   two more cycles return to `1E-6`. The root hunts of this chapter test
   their residuals against the setting (the Guidebook, chapter 3). The
   extremum searches do not consult it: their answers above carry the
   same digits at every tolerance, worth knowing before you cycle
   `TOLER` hoping for more decimals.

**Try it.**

1. Store `X^2*(X^2-4)/4` and find both of its minima with `FMIN(` and
   suitable bounds. What does symmetry predict about the two locations,
   and do the answers agree?
2. On the section's cubic, ask `FMAX(0,4)`. There is no turning maximum
   inside those bounds, so what does the search report, and what is
   special about the value of f there? (Compare `EVAL(` at the answer
   with `EVAL(-2)`.)
3. Find the cubic's maximum from the graph screen after two presses of
   [+], and compare the digits with step 2's whole-window answer. Which
   window's search came closer to -2?

## 4.5 The definite integral

The integral of a function over an interval is the area between its curve
and the x axis, counted with sign: area above the axis adds, area below
subtracts. The specimen dips on purpose: g(x) = x^2 - 2x - 3 factors as
(x - 3)(x + 1), negative between its zeros -1 and 3, positive outside.

1. Type [x-VAR] [x²] [-] [2] [×] [x-VAR] [-] [3] so the entry line reads
   `X^2-2*X-3`, press [GRAPH], and let the plot finish:

   ![The parabola dipping below the axis between -1 and 3](images/co04-dip-area.png)

2. Press [F5], the integral key, and let it work: the home screen
   publishes `= 606.66666666667`. The window is the interval: [F5]
   integrated from -10 to 10, the paper value 1820/3.

3. Typed bounds are the home commands' job. Press [CLEAR] and spell
   `FNINT(-1,3)`: the answer is `= -10.666666666667`. The dip between the
   zeros has area 32/3, and the integral reports it *negative*: below the
   axis, the signed count subtracts.

4. Press [CLEAR] and ask `FNINT(3,5)`: `= 10.666666666667`. By a designed
   coincidence, the hump from 3 to 5 encloses exactly the same area above
   the axis as the dip does below.

5. So the whole run should cancel. Press [CLEAR] and ask `FNINT(-1,5)`:
   `= 0`, exactly. An integral of zero does not mean nothing happened; it
   means the ups and downs balanced. When the question is "how much area,
   regardless of side", integrate the pieces separately and add sizes.

6. Average value is an integral wearing plainer clothes: the average of a
   function over an interval is its integral divided by the width. A
   story to measure: a harbour weather logger records a day running from
   8 degrees at midnight to 20 degrees at noon, modelled for this chapter
   as `14-6*COS(PI*X/12)` with `X` in hours from midnight (`RAD` mode,
   the fresh-boot default; the `π` legend on [2nd] [^] types `PI`).
   Press [CLEAR], type it ([COS] types `COS(`), press [GRAPH], and let
   the plot finish; the standard window shows only the cold midnight
   arc, most of the day sitting above `YMAX`, and the numbers below read
   the stored equation, not the picture.

7. Press [EXIT] and [CLEAR], then check the design: `EVAL(0)` answers
   `= 8`, and after another [CLEAR], `EVAL(12)` answers
   `= 20.000025006855`, the noon peak through the machine's
   fourteen-digit `PI` (the same small print as `SIN(PI/2)` in the
   Guidebook, chapter 3).

8. The day's average: [CLEAR], then `FNINT(0,24)` answers
   `= 336.000035432` degree-hours, and [CLEAR], then `FNINT(0,24)/24`
   answers `= 14.000001476333`. The average temperature is 14 degrees,
   the cosine's contribution cancelling over its full period, and the
   trailing digits are `PI` again, not the weather.

**Try it.**

1. Check the splitting rule on the parabola: compute `FNINT(-1,1)` and
   `FNINT(1,3)` and confirm the two together match step 3's answer for
   the whole dip.
2. Press [+] once and use [F5] on the parabola in the halved window. Work
   out the -5 to 5 integral on paper and compare.
3. An island town's day swings just 3 degrees either side of 17. Write
   the model in the pattern of step 6, and confirm with `FNINT(` that its
   average over 24 hours is 17 up to the machine's `PI`.

## 4.6 Riemann sums by program

`FNINT(` answers in a second and shows nothing of its method. A Riemann
sum is the method: slice the interval, guess each slice's area from one
sample, add the guesses. The program environment of the Guidebook,
chapter 16 lets the machine do the adding while you choose the sampling,
and watching the sums close in on the integral is the best argument for
why the limit of sums deserves the name "integral". The function is
f(x) = x^2 + 1 on [0, 2], whose integral is 14/3.

1. Store the equation first: type [x-VAR] [x²] [+] [1] so the entry line
   reads `X^2+1`, press [GRAPH], let the plot finish, press [EXIT], and
   press [CLEAR]. Then get the target: spell `FNINT(0,2)` and press
   [ENTER]: `= 4.6666666666667`, the fourteen-digit 14/3.

2. The left sum with four slices takes each slice's height from its left
   edge: the slice width is 2/4 = 0.5 and the sample points are 0, 0.5,
   1, 1.5, which is `A/2` for `A` counting 0 to 3. Press [PRGM], then
   [F1], `NEW`: the editor opens on `EDIT P1`. Type the six lines,
   [ENTER] after each; letters are [ALPHA] plus the key carrying the
   letter, spaces are [2nd] [0] in this editor, and [STO▶] types the
   `->` arrow.

   | Line | Text | Keys |
   | --- | --- | --- |
   | 1 | `0->S` | [0] [STO▶] [S] |
   | 2 | `FOR A,0,3` | [F] [O] [R] [2nd] [0] [A] [,] [0] [,] [3] |
   | 3 | `S+EVAL(A/2)->S` | [S] [+] [E] [V] [A] [L] [(] [A] [÷] [2] [)] [STO▶] [S] |
   | 4 | `END` | [E] [N] [D] |
   | 5 | `DISP S/2` | [D] [I] [S] [P] [2nd] [0] [S] [÷] [2] |
   | 6 | `STOP` | [S] [T] [O] [P] |

   Line 3 leans on the chapter's workhorse: `EVAL(` reads the stored
   `X^2+1`, so the program never contains the function and will serve any
   equation you store later. Line 5 shows the tally times the slice
   width: four heights halved are four half-width slices added.

3. Press [F2], `RUN`. The run screen answers `RUN P1` over `LINE 6`, the
   output line shows `3.75`, and the status reads `DONE`: the left sum,
   well under 4.6667, because every left edge of a rising function
   undershoots its slice.

4. The right sum samples 0.5, 1, 1.5, 2 instead, which is the same
   program counting `A` from 1 to 4. Press [PRGM] for the list, [▼] to
   select the second slot, and [F1] to open `EDIT P2`; type the same six
   lines with line 2 as `FOR A,1,4`. Press [F2]: the run screen answers
   `5.75`. The true integral is bracketed: 3.75 below, 5.75 above.

5. The midpoint sum samples the slice centres 0.25, 0.75, 1.25, 1.75,
   which is `(2*A-1)/4` for `A` from 1 to 4. Press [PRGM], [▼], and [F1]
   for `EDIT P3`, and type the variant with line 2 as `FOR A,1,4` and
   line 3 as `S+EVAL((2*A-1)/4)->S`. Press [F2]: `4.625`, inside the
   bracket and only 1/24 shy of the target.

6. Double the slicing. Press [PRGM], [▼], and [F1] for `EDIT P4`, and
   type the eight-slice midpoint sum: line 2 becomes `FOR A,1,8`, line 3
   becomes `S+EVAL((2*A-1)/8)->S`, and line 5 becomes `DISP S/4` (eight
   quarter-width slices). Press [F2]:

   ![The eight-slice midpoint sum closing in on 14/3](images/co04-riemann-run.png)

   The run screen answers `4.65625`. The midpoint error fell from 1/24
   to 1/96, quartering when the slice count doubled, which is the
   midpoint rule's signature; left and right sums only halve theirs per
   doubling.

The environment shapes the design: `FOR` bounds are single digits, so a
counted loop passes at most ten times, and finer slicings hand the count
to a `WHILE` countdown in the style of Chapter 3 (Explorations in
Probability and Statistics). Four program slots held all four sums, with
`EVAL(` keeping every slot ignorant of which function it measures.

**Try it.**

1. Edit the left sum to eight slices (count 0 to 7, sample `A/4`, display
   `S/4`) and run it. Is its error against `FNINT(0,2)` half of P1's, as
   the doubling rule predicts?
2. The trapezoid estimate is the average of the left and right sums.
   Compute it from P1 and P2's answers on the home screen. Why does it
   still overshoot 14/3 for this particular curve?
3. Store a different equation, plot it through, and rerun P4 without
   editing a single program line. Check its answer against `FNINT(` with
   the matching bounds.

## 4.7 Areas between curves

Two curves enclose a region; how much area is in it? The gap between the
curves at each x is the difference of their heights, so the enclosed area
is the integral of the difference function between the crossing points,
and every tool the chapter has built gets a turn. The designed pair is an
arch and a line, y = 2 - x^2/2 and y = x/2 + 1, which cross where
x^2 + x - 2 = 0, at x = -2 and x = 1.

1. Type [2] [-] [x-VAR] [x²] [÷] [2] so the entry line reads `2-X^2/2`,
   and press [GRAPH]. When the plot finishes, press [2nd] [2] to switch
   to slot `Y2` (the entry line comes back empty), type [x-VAR] [÷] [2]
   [+] [1], and press [GRAPH]:

   ![The arch and the line crossing at -2 and 1](images/co04-between-curves.png)

2. Press [2nd] [F1], the intersection search, and let it settle: the home
   screen publishes `= -1.9999999999999` with the residual line
   `R=1E-13`. That is the left crossing: the search scans the window from
   its left edge, so it reports the leftmost intersection first.

3. The entry line now holds `X/2+1`, the active slot's text, so press
   [GRAPH] to return to the plot. To reach the *other* crossing, make the
   window exclude the first one: press [+] three times, letting each
   replot finish, which narrows the view to -1.25 to 1.25. Press
   [2nd] [F1] again: `= 1` with `R=0`, the right crossing exactly.

4. Now the difference function. Press [GRAPH], then [2nd] [+] to restore
   the standard window, and let it replot. Press [2nd] [3]: slot `Y3`
   becomes active with an empty entry line. Type [1] [-] [x-VAR] [÷] [2]
   [-] [x-VAR] [x²] [÷] [2] so the line reads `1-X/2-X^2/2`, the arch
   minus the line collected on paper, and press [GRAPH]: the difference
   joins the plot as a low hump, positive exactly where the arch is
   above the line.

5. The hump's zeros should be the crossings, and the root search confirms
   it: press [F1] and let it settle. The answer is `= -1.9999999999999`,
   the same figure the intersection search produced, because the two
   questions are the same question. ([F1] reads the active equation,
   which is now the difference in `Y3`.)

6. The area. Press [CLEAR], spell `FNINT(-2,1)`, and press [ENTER]:
   `= 2.25`. Nine quarters of area sit between the arch and the line.
   That is the whole workflow: plot the pair, search out the crossings,
   store the difference, integrate it between them. The difference was
   typed positive on the arch's side; had the line been on top, the same
   integral would have come out negative, the sign convention of section
   4.4 arriving exactly where it is usually unwanted.

**Try it.**

1. Retype `Y3` as the line minus the arch, `X/2+1-(2-X^2/2)`, replot, and
   integrate from -2 to 1 again. What changes, and what stays the same?
2. Replace `Y2` with `X/2` and find the new crossings with [2nd] [F1] and
   a zoom. The exact answers are no longer whole numbers; what do the
   residual lines report instead?
3. Extend the section's integral to `FNINT(-2,4)`. The line crosses back
   over the arch at x = 1, so say what the answer mixes, and how to get
   the total enclosed area on both sides instead.
