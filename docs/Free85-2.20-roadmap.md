# Free85 2.20 numerical-integrity roadmap

Free85 2.20 is Phase 15: a backward-compatible reliability and workflow
programme following the 2.10 firmware and 2.11 documentation/distribution
patches. It does not reopen the completed Free85 2.0 command-parity ledger.
Instead, `spec/free85/numerical-quality.yaml` records behaviours which exist but
need stronger numerical guarantees or safer user workflows.

Version numbers remain monotonic. The feature releases are 2.12, 2.14, 2.16,
2.18, 2.19, and the hardened 2.20 release. A 2.2 or 2.5 label would compare
below the already published 2.10 release.

## Delivery rules

Each work package begins from a green main branch and includes firmware,
independent expectations, normal and failure vectors, persistence behaviour,
performance limits, and any developer-facing specification changes. An
executable TODO may document a 2.11.1 defect during Phase 15.0; the package
that owns it must turn it into an ordinary passing test before it merges.

Public validation remains clean-room and never requires a TI ROM. The optional
private TI-85 oracle checks unchanged observable behaviour, but Free85-only
algorithms such as adaptive integration and RK4 are judged against independent
mathematical references rather than TI output.

## Work packages

- **15.0 — baseline and failure catalogue:** register every weakness, its
  evidence, owner, acceptance criteria, and executable baseline probes.
- **15.1 / 2.12 — error integrity and safe integration:** preserve error
  classes through nested evaluators and add bounded convergence checking to
  `FNINT`.
- **15.2 / 2.14 — trigonometric range reduction:** replace the 63-subtraction
  reducer, measure a guaranteed range, and fail explicitly outside it.
- **15.3 / 2.16 — re-entrant calculus:** retain active-equation callables and
  add explicit graph-slot targets with bounded context and cycle detection.
- **15.4 / 2.18 — differential equations:** directly editable `(X0,Y0)`,
  transactional saved-state migration, selectable Euler/Heun/RK4 methods,
  convergence checks, and cancellation.
- **15.5 / 2.19 — workflow restrictions:** atomic result-to-input copying for
  collections and expression-valued `FOR` bounds with an optional step.
- **15.6 / 2.20 — hardening:** public, visual, randomized, performance,
  stress, soak, migration, reproducibility, and optional oracle gates.

## Completed packages

- **15.0:** accepted baseline, quality ledger, executable failure probes, and
  deferred book-revision map.
- **15.1 / 2.12:** typed evaluator errors and bounded, cancellable Simpson
  refinement are implemented and release-gated. The book-impact ledger records
  the exact old claims and captures to replace after 2.20 behaviour freezes.
- **15.2 / 2.14:** bounded quotient-based circular reduction removes the old
  399-radian cliff, publishes measured radian/degree ranges, and reports
  precision loss beyond them.

## Explicit boundary

Larger matrices, vectors, lists, statistics columns, and program stores are
not part of 2.20. They require a dynamic RAM workspace and persistent-schema
redesign and are therefore candidates for Free85 3.0. Phase 15 removes the
gratuitous single-digit loop and manual result-copy restrictions without
pretending that fixed hardware capacity has disappeared.

The manual, guidebook, and companion book are not Phase 15 implementation
inputs. They can be revised after the firmware behaviour is frozen. The active
scope documents are this roadmap, the machine-readable quality ledger, source
tests, README, release notes, and known limitations.

The deferred revision is nevertheless specified now: see
`docs/Free85-2.20-book-handoff.md` and the machine-readable
`spec/free85/v2.20-book-impact.yaml`. Together they map every correction to the
book sections, stale claims, worked results, key sequences, and LCD captures
which must change in the first 2.20 editions.
