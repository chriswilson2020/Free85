# Free85 2.20.0

Free85 2.20.0 completes Phase 15, the numerical-integrity and workflow
programme begun after 2.11. It freezes the behaviour delivered in 2.12, 2.14,
2.16, 2.18, and 2.19 behind one hardened release gate. The ROM remains exactly
131,072 bytes with persistent RAM schema 13 and object-store schema 1.

## Numerical integrity

- Evaluator failures retain distinct syntax, domain, division, overflow,
  recursion, convergence, cancellation, and precision classifications.
- `FNINT` compares bounded 32/64/128-panel Simpson estimates and refuses
  undefined or unconverged results.
- Circular functions use quotient-based range reduction through the measured
  limits of 1E6 radians and 1E8 degrees, with `PRECISION LOST` beyond them.
- Explicit graph-slot calculus forms make derivative and accumulator functions
  safe to plot and tabulate with bounded cycle detection.
- DEQ exposes editable `(X0,Y0)`, Euler/Heun/RK4 selection, deterministic
  reset and persistence, transactional legacy-state migration, cancellation,
  and bounded non-convergence.

## Workflow improvements

- Pressing `ENTER` while collection result `R` is displayed atomically copies
  it into `A`, preserving shape, vector coordinate form, and complex metadata.
- `FOR V,start,end[,step]` evaluates exact signed 16-bit expressions, supports
  positive and negative nonzero steps, and handles descending and empty ranges.

## Hardening evidence

All Phase 15 TODO probes are ordinary passing tests. A deterministic seeded
suite adds 32 signed counted-loop vectors to the independent numerical,
failure, migration, framebuffer, and workflow coverage. The release command
owns the public tests, exact visual fixtures, performance budgets, 10,000-key
stress test, 9,000-frame/180-second emulated soak, two independent ROM/Pages
builds, and optional private TI-85 oracle lane. The oracle is skipped cleanly
when no user-owned ROM is supplied; proprietary data is never a public build
input.

The final ROM and Pages hashes are recorded in `spec/free85/release.json` and
`spec/free85/reproducibility.json`.

## Book handoff

Firmware behaviour and screenshots are now frozen for the next book editions.
The manual, guidebook, and companion were not edited during Phase 15 firmware
work. Their required corrections, new key sequences, result recaptures, and
stale statements are itemized in `docs/Free85-2.20-book-handoff.md` and
`spec/free85/v2.20-book-impact.yaml`.
