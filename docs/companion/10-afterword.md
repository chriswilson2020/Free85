# Afterword: After the last exploration

Eight chapters have used one small machine as a laboratory rather than as
an oracle.

Here is what it has, written out plainly. Three graph slots. Lists of eight
samples. Matrices of three rows and up to six columns, and square-only work
confined to 3 by 3. Vectors of three components. Polynomials to degree 4.
Four programs of eight lines. An entry line of forty-eight characters, and
a program line of the same forty-eight, because they share a buffer. Two
coupled first-order equations in the DifEq mode, and one equation in the
solver. Fourteen significant digits, which is seven bytes of packed
decimal.

Every one of those numbers is a decision I made, mostly about how much of a
very small machine to spend on one feature. And every one of them has
shaped an exploration in this book.

Some of them closed a door, and this book said so each time rather than
pretending otherwise. Then most of those doors opened.

That paragraph used to list six of them. A graph slot could not hold
`FNINT(`, so there was no plot of pendulum period against amplitude. Sine
gave up a little short of four hundred radians. There was no phase plane,
because the mode integrated one equation from one initial condition. There
was no simplex tableau, because even a two-product problem needs three rows
and six columns. There was no window editor. There was no way to hold one
plot on the screen while another drew over it.

Every one of those is now false. The calculus commands take an explicit
slot and plot as functions of x. Reduction is by quotient and runs to a
million radians. DEQ integrates two coupled states and draws the phase
plane. The matrix workspace is three rows by six columns, which are the
exact dimensions this paragraph named as the reason simplex was
impossible. `WIN` gives four numeric fields. `OVR` lays a stored picture
under the next graph.

Two of those I wrote as permanent and they lasted one release. One of them
I described as a design decision when it was a thing I had not got round
to. Only the polar sweep of exactly one turn, and the absence of an
expression that would let `SOLV` aim a shooting method for you, are still
standing.

Each time a door was shut, the exploration went round instead: a table
written out row by row, an identity applied on paper before the machine was
asked, a straight line drawn through the last two misses. Those detours are
still in this book, and I have kept them, because the going-round is where
the mathematics was. What has changed is that they are now choices rather
than requirements, and the book says which is which.

I want to be careful about what I am claiming here, because there is a
comfortable and slightly dishonest version of this argument that says
limitations are secretly good for you. They are not. I wrote in an earlier
edition that if I could have given you nine graph slots and a phase plane I
would have, and that the book would have been better for it in places. I
have since given you the phase plane, and the book is better for it in
places, exactly as predicted. The graph slots are still three.

What is true is narrower and I think more interesting. A bound you can see
the whole of teaches you something a bound you cannot see does not.

Three slots made a family of curves something to compare rather than skim.
Eight samples made every statistic checkable by hand, so the machine was
never believed, only checked. A 3 by 3 world made an elimination small
enough to watch every entry change. Eight lines made each program an
argument about what its algorithm really is, because there was no room for
anything that was not the argument. Forty-eight characters forced the sum
of squared residuals into a program, where it became something you run
repeatedly rather than something you evaluate once. Two more belong on that list, and they are no longer there.

The initial condition in differential-equation mode used to be frozen once
it was set, so changing a shot meant deleting a store object and starting
over, and I argued that the cost of a shot was part of the lesson.
`FNINT(` used to spread sixty-four panels across whatever interval you
gave it and hand back the total, which meant that twice in this book the
machine gave you a confident, wrong answer and you needed enough
mathematics to catch it. I argued that too, and rather well, in the
edition of this book that came before this one.

Both arguments were comfortable, and one of them was wrong. A limitation
can teach you something and still be a defect, and the test is not whether
a reader learns from working around it, because a reader can learn from
almost anything. The test is whether the machine was honest. A frozen seed
was honest: it never pretended to be anything else, and you could see the
whole of it from outside. The silent integral was not. It answered in the
same voice it uses when it is right, and no amount of pedagogical benefit
buys that back.

So the seed is now an ordinary editable setting, and `FNINT(` compares its
estimates and refuses when they will not agree. The pendulum still needs
the substitution: nothing about the mathematics moved, and the
trigonometry that turns an improper integral into a proper one is still
the thing worth learning. What moved is that you now find out you need it.

That is the distinction I was reaching for and did not have. Not a
limitation being secretly good for you. A limitation being *visible*, at a
size where you can still see all the way round it, at the exact moment
when seeing it teaches you the thing.

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
