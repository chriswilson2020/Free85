# Free85 Product Definition

Free85 is an independently written, open-source scientific graphing calculator
firmware for the TI-85-compatible machine layer in this repository. It runs on
the emulated Z80 and calculator hardware and does not require services from the
original TI firmware.

The current stable release is Free85 2.19.0 (Phase 15.5): an exact 128 KiB
ROM with persistent RAM schema 13, object-store schema 1, a closed applicable
2.0 parity ledger, independently reproducible ROM and Pages artifacts, typed
numerical errors, bounded convergence-checked integration, and measured
large-angle trigonometric reduction, and cycle-safe explicit graph-slot
calculus that supports derivative and accumulator plots, editable DEQ initial
conditions and selectable Euler/Heun/RK4 integration, atomic collection-result
chaining, and expression-valued signed counted loops.

## Parity target

Every physical key, printed shifted function, alpha entry, and reachable
built-in menu must lead to a meaningful Free85 feature. Free85 does not promise
binary, program, file, token, ROM-call, or internal-data compatibility with TI
software.

## Clean-room boundary

Free85 source, generated artifacts, and public tests must not contain or derive
from TI ROM bytes, disassembly, fonts, artwork, binary tables, or proprietary
fixtures. A lawfully obtained original ROM may only be used as a private,
optional black-box oracle. Mathematical expectations come from independent
reference results.

## Hardware target

- Z80 CPU at the machine layer's 6 MHz cadence.
- Eight 16 KiB ROM pages, producing exactly 131,072 bytes.
- Fixed ROM page at `0x0000-0x3fff`.
- Banked ROM page at `0x4000-0x7fff`.
- 32 KiB RAM at `0x8000-0xffff`.
- 128 by 64 monochrome LCD.
- 49 matrix keys and a separate ON key.

## Delivery sequence

Phase 0 defines the product, complete physical-key inventory, planned feature
surfaces, coverage rules, and build skeleton. Phase 1 creates a bootable open
diagnostic ROM with reset vectors, interrupts, LCD output, original font and
screen assets, keypad scanning, and a visible last-key diagnostic.

Phase 2 adds the event-driven UI kernel, expression editor, cursor, modifier
states, soft-menu pages, and explicit development dialogs for reachable
features that are not implemented yet.

Later phases add the calculator kernel, numeric model, expression language,
scientific functions, graphing, collections, statistics, solvers, strings,
catalog/custom menus, and programming environment. Phase 11 completes system,
memory, link, power, and every remaining key/menu surface; the website then
ships Free85 as its default ROM. Phase 12 measures and optimises hot paths,
publishes the reproducible 1.0 release bundle, and locks release completeness,
performance, stress, soak, and browser-default behavior into validation.

Phase 14 extends that baseline to Free85 2.0 command-level parity. Phase 14.10
freezes persistent RAM schema 13 and object-store schema 1, closes every
applicable parity gap, and requires independent ROM and Pages rebuilds to
produce identical hashes before a stable release can be published.

Phase 15 strengthens numerical integrity without reopening the completed
command-parity ledger. Phase 15.1 preserves error classes across nested
evaluators and refuses an `FNINT` result when bounded Simpson refinement cannot
meet the selected tolerance.
Phase 15.2 replaces repeated trigonometric subtraction with bounded
quotient/remainder reduction and an explicit precision boundary.
Phase 15.3 preserves the active-equation calculus forms, adds one-based
explicit graph-slot targets, restores all caller state across the bounded
nested evaluation, and rejects direct and indirect equation cycles cleanly.
Phase 15.4 adds visible DEQ `(X0,Y0)` editing and reset, transactional GDEQ
migration, selectable first-/second-/fourth-order methods, bounded queries, and
cancellation without claiming adaptive or stiff-solver behavior.

## Definition of a complete feature

A feature is complete only when it is reachable through a physical key or
reachable menu, performs a meaningful operation, handles a normal case and an
edge or error case, has automated tests, and is documented. Phase 0 entries are
therefore planned rather than complete.
