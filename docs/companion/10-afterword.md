# Afterword: After the last exploration

Eight chapters have used one small machine as a laboratory rather than as
an oracle.

Here is what it has, written out plainly. Three graph slots. Lists of eight
samples. Matrices no bigger than 3 by 3. Vectors of three components.
Polynomials to degree 4. Whole exponents from -9 to 9. Four programs of
eight lines. An entry line of forty-eight characters, and a program line of
the same forty-eight, because they share a buffer. One first-order equation
in the DifEq mode, and one equation in the solver. Fourteen significant
digits, which is seven bytes of packed decimal.

Every one of those numbers is a decision I made, mostly about how much of a
very small machine to spend on one feature. And every one of them has
shaped an exploration in this book.

Some of them closed a door, and this book has said so each time rather than
pretending otherwise. There is no plot of pendulum period against
amplitude, because a graph slot cannot hold `FNINT(` without being asked to
integrate itself. There is no spiral past one revolution, because the polar
sweep is exactly one turn. There is no phase plane, because the mode
integrates one equation from one initial condition. There is no simplex
tableau, because even a two-product problem needs three rows and six
columns. There is no expression that would let `SOLV` do a shooting
method's aiming for you. Sine gives up a little short of four hundred
radians, because its argument reduction subtracts 2 pi at most sixty-three
times.

Each time, the exploration went round instead: a table written out row by
row, an identity applied on paper before the machine was asked, a straight
line drawn through the last two misses.

I want to be careful about what I am claiming here, because there is a
comfortable and slightly dishonest version of this argument that says
limitations are secretly good for you. They are not. If I could have given
you nine graph slots and a phase plane I would have, and the book would
have been better for it in places.

What is true is narrower and I think more interesting. A bound you can see
the whole of teaches you something a bound you cannot see does not.

Three slots made a family of curves something to compare rather than skim.
Eight samples made every statistic checkable by hand, so the machine was
never believed, only checked. A 3 by 3 world made an elimination small
enough to watch every entry change. Eight lines made each program an
argument about what its algorithm really is, because there was no room for
anything that was not the argument. Forty-eight characters forced the sum
of squared residuals into a program, where it became something you run
repeatedly rather than something you evaluate once. A frozen initial
condition made the cost of a shot part of the lesson. Sixty-four panels
under `FNINT(` meant that twice in this book the machine handed you a
confident, wrong answer, and you had to know enough mathematics to catch
it.

That last one matters most. A bigger machine would have got the pendulum
integral right and you would have learned nothing. This one returned
9643.817428027 where the answer was about 2.31, said nothing about it, and
made you go and do the trigonometry that turns an improper integral into a
proper one. That is not a limitation being secretly good for you. That is
a limitation being *visible*, at a size where you can still see all the way
round it, at the exact moment when seeing it teaches you the thing.

The other half of the argument is about what these bounds are not. They are
not the mathematics. The logistic equation does not care that this machine
integrates one equation at a time. Newton's method does not stop doubling
its correct digits because the program slot is eight lines long. The
interval of convergence of a power series is a fact about the series. What
the machine gave you was a place to stand while you looked at those things,
and a set of edges to push against so that you found out where they are.

If you have worked through the exercises, you have done something more
useful than learning a calculator. You have practised the habit of
predicting before pressing, and then finding out. That habit is the whole
of experimental mathematics and it transfers to every tool you will ever
use, most of which will be far bigger than this one and much less willing
to show you their edges.

Put the book down, pick a question of your own, and see how far the machine
takes it before you have to carry it yourself. That moment, when you find
where it stops, is the most useful thing in here.
