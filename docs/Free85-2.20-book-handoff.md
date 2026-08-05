# Free85 2.20 book-revision handoff

This is the editorial handoff for the first Manual, Guidebook, and
*Explorations with Free85* editions based on firmware 2.20. It records what
will become stale as Phase 15 lands; it does not edit or pre-empt the books
while firmware behaviour is still changing.

The machine-readable source is
`spec/free85/v2.20-book-impact.yaml`. Every numerical-quality issue appears
there with affected files and sections, claims to remove, material to add, and
LCD captures to regenerate.

## Implementation status

Phase 15.1 shipped in Free85 2.12. The future editions must describe distinct
syntax, division, domain, overflow, recursion, non-convergence, and cancellation
diagnostics. They must also replace the fixed-64-panel description of `FNINT`
with its bounded 32/64/128-panel comparison and show the pendulum endpoint case
being refused as `DIVIDE BY ZERO` (or `NO CONVERGENCE` when refinement, rather
than a sampled undefined point, detects the failure). Do not recapture final
book figures yet: the editorial freeze remains Phase 15.6 / Free85 2.20.

Phase 15.2 shipped in Free85 2.14. Replace the 63-subtraction/399-radian story
with quotient-based reduction, the measured limits of 1E6 radians and 1E8
degrees, the 1E-7 outer SIN/COS accuracy guarantee, and `PRECISION LOST` beyond
the supported phase range. The old cliff remains useful only when clearly
labelled as historical 2.10 behaviour.

Phase 15.3 shipped in Free85 2.16. Retain the familiar active-equation syntax,
then add the explicit one-based forms: `EVAL(slot,x)` and `NDER(slot,x)`, plus
`FNINT(slot,a,b)`, `FMIN(slot,a,b)`, `FMAX(slot,a,b)`, `ARC(slot,a,b)`, and
`INTER(slot,a,b)`. Replace claims that calculus cannot appear in graph slots
with reviewed derivative and accumulator graph/table workflows. Explain that
one nested graph-evaluation frame is available and that direct, indirect, or
deeper cycles report `RECURSION ERROR` while unrelated equations continue.
The reviewed implementation fixtures are `phase15-calculus-derivative` and
`phase15-calculus-accumulator`; final book recapture still waits for 2.20.

Phase 15.4 shipped in Free85 2.18. Replace the `GDEQ` deletion ritual with the
fourth graph-format page: F1 cycles Euler/Heun/RK4, F2/F3 select X0/Y0, +/-
edits by the table step, F4 resets to `(Xmin,0)` and Euler, and F5 redraws.
Euler examples must explicitly select Euler. Add Heun/RK4 comparisons and their
measured convergence orders, while stating that the bounded fixed-step engine
is not a stiff solver. Document `NO CONVERGENCE` at the 255-step query limit,
EXIT/ON cancellation, persistence, and transactional v1 GDEQ migration. The
reviewed setup fixture is `phase15-deq-setup`; numerical recapture still waits
for the final 2.20 ROM.

Phase 15.5 shipped in Free85 2.19. Replace manual collection-result
transcription with: display `R`, then press `ENTER` (`ENTER USE R`) to copy the
complete result into `A`; dimensions, vector coordinate form, and complex
components are retained. Replace the single-digit `FOR` limitation with
`FOR V,start,end[,step]`: all three fields are evaluated exact signed 16-bit
integer expressions, step defaults to one, negative steps descend, and zero,
fractional, or out-of-range values report `DOMAIN ERROR`.

## The important editorial changes

1. **Errors become meaningful.** Do not use `SYNTAX ERROR` as prose shorthand
   for an undefined value or failed computation. Explain syntax, domain,
   division, overflow, recursion, and convergence separately.
2. **The pendulum failure changes.** The present `9643.817428027` episode must
   show the final ROM's refusal or justified result. The mathematical lesson
   about transforming an improper integral can remain, but not the defence of
   silently publishing nonsense.
3. **The 399-radian cliff disappears.** Rewrite the repeated-subtraction
   explanation as historical behaviour and document the measured 2.20 range,
   accuracy, and honest outer failure boundary.
4. **Derivatives and accumulators become plottable.** Replace categorical
   statements that graph slots cannot contain calculus with the final
   explicit-slot syntax, cycle rules, plots, and tables.
5. **Initial conditions become ordinary settings.** Remove every `GDEQ`
   deletion ritual used only to change a seed. Document editable `(X0,Y0)`,
   reset, persistence, and migration.
6. **DEQ gains method choice.** Existing Euler explorations remain valuable,
   but they must tell the reader to select Euler. Add comparisons with Heun
   and RK4 and state plainly that Free85 does not promise a stiff solver.
7. **Results can be chained.** Replace manual transcription of `R` with the
   final `USE R` action wherever the purpose is merely to continue a matrix,
   vector, list, or complex calculation.
8. **FOR becomes a normal counted loop.** Replace workarounds caused only by
   the old single-digit parser with expression bounds and optional steps.

## Revision workflow

Do not begin numeric recapture until Phase 15.6 fixes the 2.20 ROM hash. Then:

1. process each entry in the book-impact ledger;
2. execute every affected key sequence on that exact ROM;
3. update prose, answers, exercises, solutions, indexes, and cross-references;
4. regenerate affected LCD images from the ROM rather than modifying them;
5. regenerate command/status appendices;
6. build PDF and web editions and run visual, page-count, link, and
   traceability checks;
7. search for every phrase listed under `mustRemoveOrCorrect` and resolve each
   occurrence deliberately.

The current books remain accurate for the released 2.10 firmware. This handoff
exists so their eventual 2.20 editions describe improved behaviour rather than
accidentally preserving limitations because an old lesson depended on them.
