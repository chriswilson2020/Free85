# Rewrite brief — Explorations with Free85

Read this before touching anything. The first edition is a working draft:
correct, verified and typeset, but too thin, too pleased with itself, and
under-illustrated. Chris's verdict was "a good start but lacking quite a
lot", and he is right.

This brief records what is wrong, what is legitimately available to fix it,
and what will break if you change the wrong thing.

## 1. Read this first: the originality rule was too strict

The first edition was written under a rule that no chapter writer or
reviewer could see *Explorations with the Texas Instruments TI-85*, the book
that inspired this one. That rule was self-imposed and it went well beyond
what copyright requires. It is the single biggest reason the book is thin,
and it should not be repeated.

**What copyright actually protects is expression, not ideas, facts or
mathematics.** So the following were always available and should be used:

- the course order and chapter structure;
- the **standard examples of the field** — `sin(x)/x` for limits, the
  logistic and Gompertz equations, the pendulum and elliptic integrals,
  Newton's method, Riemann sums. These are not any one book's invention.
  They are how mathematics is taught everywhere, and a learner is better
  served by the example they will meet again in their course than by a
  novelty invented to be different;
- the same depth, rigour and level of ambition;
- the same pedagogical method: explore numerically, then graphically, then
  confirm by a second route.

**What is not available:** its actual sentences, its phrasing, and wholesale
copying of genuinely distinctive creative choices. Porting it verbatim with
the keystrokes changed is a derivative work and is not an option — the repo
is MIT-licensed and published publicly, so this is distribution, not private
study.

**The method to use instead**, which is what professional textbook writing
does: read the source for scope, depth and level; take structured notes on
*what mathematics to cover and how far to push it*; then write from those
notes in your own words, with your own screens and your own numbers. Depth
and structure travel. Sentences do not.

The first edition avoided the standard examples in favour of invented ones
(café receipts, a joinery's timber budget, a tea blend). Some of that is
charming and can stay, but it was chosen to be *different* rather than to
teach, and it is a large part of why the book reads as lightweight.

## 2. What is lacking, in Chris's words and in measurements

His list: voice and register; not enough mathematics; not enough
hand-holding; not enough proper calculator listings; not close enough to
the original in quality; and not enough non-calculator figures.

### Voice and register

1,441 prose sentences, median 19 words — the baseline is sound. The problems
are local and fixable:

- **49 sentences run over 45 words**, unevenly spread: ch8 12, ch3 9, ch7 7,
  ch2 6, ch6 6, ch1 2, ch4 2, ch5 2, front matter 2, afterword 1. Two causes
  account for nearly all: cross-reference pile-ups (the worst names five
  chapters in 68 words), and keystroke sequences narrated through
  subordinate clauses instead of broken into steps.
- **The opening sentence of the book should be deleted outright:**

  > A question worth asking about the mathematics, worked through on the
  > machine keystroke by keystroke, and then handed over as exercises for
  > you to carry on with: that is an exploration, and this is a book of
  > them.

  43 words that withhold the subject through three clauses and then pivot on
  a colon to congratulate themselves. The next sentence already says what
  the book is, plainly and better.
- The register throughout is a shade too literary and too satisfied. Aim for
  plain instruction that gets out of the reader's way.

### Mathematical depth

The explorations stop too early. A section typically sets up a question,
works one example, and hands over. It should push further: why the method
works, where it fails, what changes when a parameter moves, how to check the
answer a second way. This is where matching the source's *depth* (entirely
legitimate) matters most.

### Hand-holding

Assumes too much. A learner following along needs to be told what to expect
on screen before they press the key, what it means if they see something
else, and how to recover. Add the recovery paths: what to clear, how to get
back to a known state.

### Calculator listings

Not enough proper listings. Programs currently appear as Line/Text/Keys
tables only. Show the editor as the reader will see it, give complete
listings rather than fragments, and show the run screen with its output.

### Non-calculator figures — the tooling now exists

The first edition had 49 LCD captures and **no explanatory diagrams at all**:
no sketch of the pendulum, no geometry for the shooting method, no clean plot
of a feasible region, no slope field. That is a serious gap in a mathematics
workbook, and it was not laziness — the build could not render one. Every
figure was framed in the calculator bezel unconditionally, so a diagram came
out looking as though the calculator had drawn it.

**That is fixed. Both figure kinds now work.** Captures keep the bezel and
glass; diagrams are set undressed at 78mm (or 108mm with `.wide`), so a
glance tells a reader which pictures came off the machine and which explain
the mathematics behind it.

A figure counts as a diagram if it carries `{.diagram}`, **or** is an SVG,
**or** is named `fig-*`. Use SVG: it stays sharp in print, and the media type
is detected automatically. The `fig-` name alone is NOT sufficient, because
the build embeds resources and the file name is a data: URI by the time the
transform runs — so a raster diagram must be marked explicitly:

```markdown
![The feasible region, with the optimum at the upper corner](images/fig-02-lp.png){.diagram}
```

`source/images/fig-08-pendulum.svg` is the worked example: navy and ink only,
no gradients, nothing depending on colour, so the page survives greyscale
reproduction. Copy its conventions.

Diagrams that would earn their place immediately: the pendulum geometry
(done), the shooting method's two misses bracketing the target, a slope field
with one solution threaded through it, the LP feasible region with its corner
points, the unit circle behind the trigonometric graphs, and a sketch of what
a Riemann sum is actually summing.

### Screen captures

49 across 47 sections — almost exactly one per section in every chapter,
which is the tell that nobody decided per section what deserved a picture.
Every zoom, trace and window change is described in prose where it should be
shown. Menu and soft-key states are never shown. Aim for two to three per
section, chosen wherever a reader could be unsure their screen matches.

## 3. How to add a screen capture

Captures are generated from the emulator, never cropped by hand.

**a. Declare it** in `build/companion-screens.js`:

```js
{
  name: "co04-zoom-before",          // coNN-slug, lowercase and hyphens only
  keys: ["X-VAR", "^", "3", "-", "4", "*", "X-VAR", "GRAPH", 900,
         "F2", 1200]
}
```

Strings are key names (`src/ti85-keys.js` in the repo). **Bare numbers are
settle frames.** Graphs need time: ~900 for one plot, 2400 for three,
8000-16000 for exponentials. Too short captures a half-drawn screen, and the
build will not complain — you must look at the PNG.

**b. Generate:** `npm run build:companion:screens` (idempotent).

**c. Reference it**, relative to the chapter file. Alt text is what a reader
of the read-aloud PDF gets, so describe what is *on the screen*:

```markdown
![The cubic before the zoom, filling a tenth of the screen](images/co04-zoom-before.png)
```

**d. Rebuild:** `npm run build:guidebook:typeset` and
`npm run build:guidebook:web`.

**Then check the pages you touched.** A framed capture cannot break across a
page and its one-line lead-in is glued to it, so a badly placed figure pushes
white to the foot of the previous page. 13 pages already end more than 100pt
short; careless figure placement makes that worse.

## 4. House style, shared by all three books

- No em dashes. British spelling.
- Sentence case for section headings, Title Case for chapter titles.
- Keys in brackets with keycap labels: [ENTER], [2nd], [F1]. Every [CLEAR]
  spelled out, never implied.
- On-screen text and commands in `code spans`.
- Every quoted result copied exactly from the emulator, at full precision.
- Cross-references as "the Guidebook, chapter 13".
- No developer register: not "callable", "validation suite", "contract".
- Roughly 76-column wrap in the source.
- At most one "honest" per chapter. It was a crutch in the first edition.

## 5. What will stop the build

`build-guidebook-typeset.js` asserts the companion's shape and throws:

- exactly 10 source files matching `^\d\d-.*\.md$`;
- exactly 8 chapter openers from H1s reading `Chapter N: Title`;
- an afterword opener from an H1 reading `Afterword: Title`;
- at least 40 Try it panels (currently 47, one per section).

Adding a chapter means updating the count; adding a section means adding its
Try it panel; renaming an H1 breaks opener detection.

## 6. Markdown traps that have already bitten this book

- **A wrapped line beginning `N.`** becomes a spurious ordered list and the
  number is *silently swallowed from the sentence*. This shipped once: a page
  read "since 1 + 4 + 4 is" followed by a bare "9."
- **Paired carets in prose** trigger pandoc superscript. Escape as `\^`.
- **Pandoc emits a colgroup of equal thirds** on some pipe tables, overriding
  column widths. The build strips it for program listings.
- **Single code tokens longer than about 68mm** overflow the A5 measure.

## 7. Do not touch without measuring

- `typeset.css`: **Chrome floors `border-width` to whole CSS pixels**, so any
  border under 1.5pt prints at exactly 0.72pt whatever it asks for. Rules
  meant to read heavier must be at least 1.5pt.
- `vendor/paged.polyfill.js` carries two patches marked `LOCAL PATCH
  (Free85)`. Without them the build hangs in headless Chrome and hyphenation
  artefacts return at page turns.
- `hyphenate-limit-chars: 6 5 3` is deliberate: Chrome counts leading
  punctuation toward the limit, so lower values let quotes and parentheses
  buy two- and three-letter breaks.

## 8. Worth preserving

- Every key sequence and quoted number was run on the emulator. Keep that
  standard: change an example, re-run it.
- Captures are generated, not cropped, so the book cannot drift from the
  firmware unnoticed.
- The treatment of the machine's limits as the reason the exercises work
  rather than as apologies — three graph slots, eight-entry lists, 3x3
  matrices, eight-line programs. Where a limit closes a door the book says so
  and goes round. That is the book's best idea and it should survive the
  rewrite.
