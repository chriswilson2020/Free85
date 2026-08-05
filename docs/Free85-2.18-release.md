# Free85 2.18.0

Free85 2.18.0 completes Phase 15.4, the differential-equation redesign in the
2.20 numerical-integrity programme.

## What changed

- A fourth graph-format page shows the DEQ method, X0, and Y0.
- F1 cycles Euler, Heun, and classical RK4; F2/F3 select X0/Y0; +/- edits by
  the table step; F4 resets to `(Xmin,0)` and Euler; F5 redraws.
- Changing an initial condition preserves the equation and no longer requires
  deleting `GDEQ`.
- Queries begin at the visible `(X0,Y0)`, use a final partial step, poll EXIT
  and ON, and report `NO CONVERGENCE` at a 255-step bound.
- Existing 213-byte GDEQ payloads load without mutation and grow
  transactionally to the versioned 224-byte payload on their next save.

## Numerical validation

For `y'=y`, `(X0,Y0)=(0,1)`, halving h from 0.1 to 0.05 produces the expected
error ratios near 2 for Euler, 4 for Heun, and 16 for RK4. The suite also covers
editable-state persistence, reset, legacy migration, bounded non-convergence,
physical-key cancellation, tables, traces, and reviewed LCD output.

These are bounded fixed-step educational methods, not adaptive or stiff ODE
solvers. Free85 states that boundary explicitly rather than implying that RK4
solves every differential equation reliably.

## Compatibility

Persistent RAM schema 13 and object-store schema 1 remain frozen. The GDEQ
payload has its own transactional v1-to-v2 migration. TI binary formats and
undocumented interfaces remain outside Free85's compatibility target.
