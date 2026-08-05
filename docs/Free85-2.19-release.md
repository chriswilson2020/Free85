# Free85 2.19.0

Free85 2.19.0 completes Phase 15.5, removing two avoidable workflow
restrictions while retaining the frozen persistent RAM schema 13 and object
store schema 1.

## Result chaining

Complex, list, matrix, and vector results remain visible in read-only register
`R`. While `R` is displayed, the help row now says `ENTER USE R`; pressing
`ENTER` copies the complete result into input register `A` and selects its first
element. The copy preserves list length, matrix/vector dimensions, vector
coordinate form, and every complex imaginary component. Register `B` is left
unchanged. Existing editing, arithmetic, conversion, and persistence workflows
remain compatible.

## Counted loops

Programs accept `FOR V,start,end[,step]`. Start, end, and the optional step are
evaluated once through the normal expression engine and must be exact signed
16-bit integers. Bounds are inclusive, step defaults to one, and positive or
negative nonzero steps are supported. An unreachable direction produces an
empty loop. Zero, fractional, and out-of-range values report `DOMAIN ERROR`.
The original `FOR A,1,3` syntax remains valid.

The bounded eight-frame control stack is unchanged. A parallel 16-byte step
plane uses the existing runtime gap without changing persistent addresses or
source format.

## Validation

`test/free85/phase15-workflows.test.js` covers complete result copies for all
four collection families, signed expression bounds, nested function commas,
default and explicit steps, descending loops, empty ranges, nesting, and
failure cases. The former Phase 15 `FOR` TODO is now an ordinary passing test.
The full public functional, visual, performance, stress, soak, Pages, and
reproducibility gates bind the checked-in ROM and release reports.

The manual, guidebook, and companion sources are intentionally deferred to the
final 2.20 editorial pass. Their exact corrections and replacement key
sequences are recorded in `docs/Free85-2.20-book-handoff.md` and
`spec/free85/v2.20-book-impact.yaml`.
