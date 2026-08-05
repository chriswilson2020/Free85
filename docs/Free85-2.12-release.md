# Free85 2.12.0 release notes

Free85 2.12.0 completes Phase 15.1, the first implementation package in the
2.20 numerical-integrity programme. It retains the completed Free85 2.0
command surface and persistent RAM schema 13.

## Numerical error integrity

- `SYNTAX ERROR` is reserved for expressions the parser cannot read.
- Division by zero, overflow, domain failure, evaluator recursion,
  non-convergence, and user cancellation have distinct internal error codes
  and user-facing diagnostics.
- Graph and table samples can still display a gap or `UNDEF` without leaving
  the home evaluator poisoned; the classified cause is retained for diagnosis.
- Program expression failures retain the same numerical class and exact source
  line instead of being flattened to a generic program syntax error.

## Safer `FNINT`

`FNINT` now computes 32- and 64-panel composite-Simpson estimates and compares
their Richardson error against the selected `TOLER`. If necessary it performs
one final 128-panel estimate. An undefined sample reports its underlying
numeric error; a comparison that still misses tolerance reports
`NO CONVERGENCE`; EXIT or ON reports `CALCULATION STOPPED`.

This bounded check deliberately does not claim to be a fully adaptive
quadrature package. In particular, a feature missed by every nested mesh may
still be missed. The implementation does prevent the documented pendulum
endpoint singularity and independently tested non-convergent intervals from
being presented as trustworthy finite answers.

## Validation

Independent tests cover smooth polynomial, trigonometric, rational, and
reversed-bound integrals; singular and under-resolved intervals; graph/table
error isolation; program error propagation; cancellation; exact framebuffer
changes for the `VERSION 2.12` banner; performance; stress; soak; and two clean
reproducible ROM/Pages builds.

The Manual, Guidebook, and *Explorations with Free85* sources are intentionally
unchanged in this firmware package. Their required 2.20 corrections are
recorded in `docs/Free85-2.20-book-handoff.md` and
`spec/free85/v2.20-book-impact.yaml`.
