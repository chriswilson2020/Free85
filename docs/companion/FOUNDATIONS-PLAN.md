# Adding foundation chapters to Explorations

Explorations opens at precalculus and moves quickly. This plan adds three
chapters ahead of it, for a reader arriving from middle school or early
high school algebra, and renumbers everything after them.

The decision to put this material inside Explorations rather than in a
fourth book was Chris's. It is worth recording why the alternative was
considered and rejected, because the reasoning bears on how the new
chapters should be written: a separate book would have had its own voice
and pacing, and inside Explorations the new chapters must instead sound
like the ones that follow them, only slower.

## What the three chapters cover

1. **Lines and patterns.** The three linear forms as one line: `y = mx+b`,
   point-slope, and `Ax+By = C` in three graph slots proving they coincide.
   Parallel and perpendicular slopes, where the square window earns its
   place because perpendicular lines do not look perpendicular without it.
   Direct against inverse variation, read from two tables side by side.
   Arithmetic and geometric sequences, which `FOR V,start,end[,step]` and
   the `seq` list command express directly since firmware 2.19.
2. **Quadratics.** The discriminant against the picture: two intercepts,
   one, or none, with `NO NUMERIC RESULT` from the root finder as the
   machine's own way of saying the third case. Then `-b/2a` worked on paper
   against the graph's minimum search, which answers something like
   `0.00011982342365967`. Exact method against numerical method,
   disagreeing visibly, on a problem the reader can already do by hand.
   That section is the best argument in the chapter and should be written
   first.
3. **Geometry and right triangles.** SOH CAH TOA in `DEG`, before any
   radian or unit-circle material. Distance and midpoint through the vector
   registers, where distance is the norm of a difference. Transformations
   as matrices: since firmware 3.0 the workspace holds three rows by six
   columns, so six points of a shape live in one matrix and a single
   multiplication rotates or reflects the whole polygon at once.

Counting, permutations and combinations, and the spread statistics (range,
IQR, mode) fold into the existing probability and statistics chapter rather
than becoming a fourth new one. It already has the lists and the menus, and
`MEAN MED VAR SSD PSD` and `MIN MAX Q1 Q3 BOX` are already on the machine.

Everything above works on firmware 3.0 as it stands. No firmware change is
needed for any of it, which is worth checking again before starting in case
that has stopped being true.

## Do the renumber first, on its own

Three chapters at the front means chapters 1 to 8 become 4 to 11, and the
solutions and afterword move with them. That is roughly four hundred edit
points: 64 numbered section headings, 96 `section N.M` references, 99
`Chapter N` references, 63 solution headings, and 80 capture files with
their 80 declarations in `scripts/companion-screens.js`.

Ship that as its own change, with no new prose in it. The book should come
out byte-for-byte equivalent apart from numbering, which makes it easy to
review: same page count, same captures, same sentences.

### The trap

Explorations refers to the Guidebook and to itself in identical words.
These sit in the same paragraphs:

- `chapter 16`, `chapter 14`, `chapter 13` mean the **Guidebook**, which
  has nineteen chapters;
- `Chapter 2`, `chapter 5 hunted a root` mean **Explorations**.

A blind find-and-replace corrupts every Guidebook reference, and nothing in
the build catches it: the assertions count sections and panels, they do not
resolve cross-references. Only references to chapter 9 and above are
unambiguously the Guidebook. Every reference to chapters 1 through 8 has to
be read.

If this is going to be done more than once, a checker that resolves every
`chapter N` and `section N.M` against the two books' actual headings would
be worth more than the renumber itself.

### Build assertions that will need moving

`scripts/build-guidebook-typeset.js` hard-codes the shape of this book:

- `sources.length !== 11` becomes 14;
- `chapters.length !== 9` becomes 12;
- `stats.solutions !== 8` becomes 11, one solutions section per chapter;
- `sections === tryits` needs no change, and is the assertion that will
  catch a new section written without its **Try it** panel. It already has.

## Writing the chapters

House style is unchanged and is recorded in `REWRITE-BRIEF.md` section 4.
The voice work is in `REWRITE-PLAN.md`. Two rules matter more than the
rest, and both have earned it:

- **Every quoted number comes from the emulator at full precision.** Not
  from arithmetic, not from memory, not from a ledger. This has caught a
  drifted `ARC(0,1)`, a wrong final digit in `1.06^0.5`, an exact answer
  where an approximate one was expected in `(1+.1)^(1/.1)`, and a phase
  orbit described as a clean circle when the machine draws twenty
  overlapping revolutions.
- **The book has an author and he built the machine.** Sparing first
  person, used to take responsibility rather than to narrate.

For these chapters, three adjustments to the register: shorter sections,
more space between steps, and far less arguing from the machine's limits.
That last one is what makes the later chapters expensive to maintain, and a
chapter about slope does not need it.

Each new section needs a **Try it** panel and a worked solution in the
solutions chapter, with key presses and outputs, like every other section
in the book.
