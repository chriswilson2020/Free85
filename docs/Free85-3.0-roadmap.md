# Free85 3.0 Phase 17 roadmap

Phase 17 is a full Free85 3.0 release. Three approved graph improvements can
be added compatibly, but widening all complex matrix registers from 3 by 3 to
3 by 6 crosses the persistent RAM boundary already reserved for a future major
release. Calling the combined work 2.22 would hide that migration risk.

## Delivery and versioning

Each completed package merges independently after its own local and GitHub
validation. Feature packages identify themselves as ordered development builds:
`3.0.0-dev.1` through `3.0.0-dev.4`. Phase 17.5 removes the suffix only after
the complete 3.0 release gate passes. The home screen version must therefore
advance monotonically and never fall back to a 2.x label during Phase 17.

Book prose and typeset sources remain outside this implementation process.
Every package must nevertheless record exact changed behaviour, worked values,
key sequences, stale claims, and LCD captures in the 3.0 book-impact ledger so
the later editorial process has authoritative inputs.

## Work packages

- **17.0 — contract and baselines:** freeze ownership, migration, rollback,
  versioning, RAM strategy, and executable baseline evidence.
- **17.1 / 3.0.0-dev.1 — window editor:** directly enter and edit `XMIN`,
  `XMAX`, `YMIN`, and `YMAX`; commit all four bounds atomically.
- **17.2 / 3.0.0-dev.2 — picture overlays:** arm a validated recalled picture
  as a one-shot underlay for the next graph while retaining ordinary clear
  redraw and cancellation behaviour.
- **17.3 / 3.0.0-dev.3 — systems and phase planes:** integrate two coupled
  first-order state equations with Euler, Heun, and RK4, then plot either
  state against time or one state against the other.
- **17.4 / 3.0.0-dev.4 — 3 by 6 matrices:** replace the packed 3 by 3 stride
  assumptions with a versioned workspace descriptor and migrate schema-13
  state transactionally.
- **17.5 / 3.0.0 — hardening:** close every planned probe and freeze the ROM,
  Pages artifact, release manifests, performance limits, and book-impact
  ledger.

## Compatibility boundary

Free85 3.0 continues to accept the last valid Free85 2.21 persistent state and
the two existing graph-database payload formats. Migration validates space and
structure before changing public state. A corrupt or unsupported object is
rejected explicitly; an out-of-capacity migration leaves the previous object
and collection registers intact.

The release does not promise arbitrary matrix sizes, adaptive stiff ODE
integration, or a compositing graphics system. The approved limits are 3 by 6
matrices, two first-order states, and a single explicit picture underlay. Those
bounds preserve the calculator's small, inspectable sandbox while removing the
four practical bottlenecks selected for Phase 17.
