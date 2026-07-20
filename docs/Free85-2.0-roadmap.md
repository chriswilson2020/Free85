# Free85 2.0 execution roadmap

Free85 2.0 is the full user-facing TI-85 feature-parity release. Phase 14 is
the umbrella programme for that release; it is divided into independently
reviewable work packages rather than one large firmware change.

This target does not include TI binary compatibility. TI programs, token
streams, files, ROM calls, internal data structures, fonts, artwork, and ROM
code remain outside the clean-room boundary. Where the TI-85 exposes a useful
workflow such as link backup or graph-picture storage, Free85 will provide the
same user capability using an original, documented Free85 format.

## Starting conditions

1. Merge Phase 13 and require its public/oracle validation to be green.
2. Merge this planning package after rebasing it onto that result.
3. Treat `spec/free85/v2-parity-gaps.yaml` as the 2.0 gap ledger and
   `spec/free85/v2-roadmap.yaml` as the dependency and acceptance manifest.
4. Phase 13's chapter-level guidebook summary is a historical snapshot, not a
   claim of command-level parity. Phase 14.0 replaces it with granular data.

## Delivery rules

Each work package gets its own `codex/phase-14-*` branch and pull request. A
package starts from the latest green `main`, contains its source, tests,
documentation, and generated reports together, and is merged before a
dependent package begins. No package may reduce existing numerical coverage,
change a reviewed LCD golden without explicit review, or add a public test
dependency on a proprietary ROM.

Every completed feature must have:

- a physical-key, menu, catalog, or program entry path;
- a normal vector and at least one boundary/error vector;
- independent mathematical expectations where applicable;
- deterministic persistence and reset semantics;
- user documentation and a stable feature identifier;
- optional black-box oracle evidence when the TI behaviour is observable.

## Work packages

### 14.0 - Command-level parity ledger

Create an original inventory of every public function, instruction, mode, and
workflow documented by the TI-85 Guidebook. Link every applicable entry to a
Free85 feature identifier, implementation, documentation, and test. Replace
the coarse chapter labels with `equivalent`, `partial`, `missing`,
`hardware-dependent`, or `excluded-clean-room`. The gate fails on unclassified
or unowned entries.

### 14.1 - Object store, names, and capacity

Introduce a typed, compact object store for real and complex numbers, lists,
matrices, vectors, strings, equations, programs, constants, graph databases,
and pictures. Add reserved system variables, typed memory accounting,
individual deletion, resizing, and transactional schema migration. This is
the foundation for larger equation collections and all later persistence.

Implemented in schema 13. Bank 7 owns the typed directory and compacting heap,
legacy A-Z values are exposed as reserved real objects without being moved,
and warm resets preserve dynamic objects. Schema-12 migration commits the new
version only after rebuilding the directory. The memory screen shows the
selected object's name, type, and size and supports arrow selection plus
individual deletion. See `docs/Free85-object-store.md` for the binary contract.

### 14.2 - Numeric utilities, modes, bases, and Boolean operations

Add the missing integer/fraction utilities, random generation, interpolation,
generic calculus callables, complete Normal/Sci/Eng/Fix formatting, and real
binary/octal/decimal/hexadecimal entry modes. Implement AND, OR, XOR, NOT,
shifts, and rotations with documented signed-width semantics.

Implemented. The home parser now accepts signed 16-bit `0b`, `0o`, and `0x`
literals; the base screen provides four full-width views; Boolean commands use
documented two's-complement word semantics; and the catalog exposes the new
scalar utilities. System format selection cycles AUTO/SCI/ENG/FIX with
adjustable fixed precision. Active-Y1 evaluation, derivative, integral,
extrema, interpolation, and arc-length callables reuse the graph engine while
preserving the surrounding editor/parser context. See
`docs/Free85-numeric-modes.md`.

### 14.3 - Shared graph engine

Refactor Cartesian plotting into a mode-independent sampling/rendering engine.
Add named window variables, all format flags, simultaneous/sequential drawing,
complete zoom presets, free cursor, trace, table adapters, cancellation, and
mode-neutral numerical analysis hooks. Existing connected-curve and
discontinuity guarantees remain mandatory.

Implemented. Cartesian plot, trace, table, and analysis callers now share a
mode-neutral evaluator. A persistent format panel controls axes, coordinates,
labels, grid, line/dot rendering, equation enablement, and simultaneous or
sequential sampling. The zoom panel supplies box, in/out, standard, square,
decimal, fit, integer, previous, trig, store/recall, and factor controls. Free
cursor coordinates and readable `XMIN`, `XMAX`, `YMIN`, and `YMAX` values use
the same packed-decimal window. Exact legacy goldens remain unchanged and the
new dot-format golden is reviewed. See `docs/Free85-graph-engine.md`.

### 14.4 - Graph drawing and persistence

Implement shade, line, vertical line, circle, tangent, point on/off/change,
function/inverse drawing, pen input, and clear-drawing operations. Add original
Free85 graph-database and picture objects with store/recall, memory accounting,
program access, and exact framebuffer goldens.

### 14.5 - Polar, parametric, and differential-equation graphing

Add polar `r(theta)`, parametric `x(t),y(t)`, and first-order differential
equation modes on the shared engine. Each mode receives its own editor,
variables, window/step configuration, trace, table, analysis, cancel path, and
goldens. Coordinate conversions and vector display modes share the same angle
and coordinate primitives.

### 14.6 - Collection and linear-algebra completion

Complete list dimension/fill/sort/sequence/conversion operations; matrix row
operations, augmentation, norms, condition number, LU, eigenvalues, and
eigenvectors; and vector rectangular/cylindrical/spherical conversions. Apply
valid scalar operations element-by-element and preserve complex values through
all supported collection paths.

### 14.7 - Solver and statistics completion

Expand the solver to equations, selectable variables, guesses, bounds, stored
results, and graphical exploration. Add logarithmic, exponential, power, and
degree 2-4 regression, forecasts, command-line one/two-variable analysis,
sorted paired data, and connected XY plots. Validate coefficients, predictions,
roots, and residuals against independent implementations.

### 14.8 - Programming-language completion

Add labels/Goto, Repeat, increment/decrement-and-skip, program menus, GetKey,
Pause, Prompt, positioned Output, string input, graph display, and
equation/string conversion. Expose every new 2.0 math, collection, graph,
solver, and statistics operation to programs. External-device instructions use
an open virtual-device interface and remain interruptible.

### 14.9 - Constants, characters, memory, and link workflows

Add editable user constants and original Greek/international glyphs; finish the
typed memory browser; and implement item selection, send, receive,
duplicate-name resolution, interruption, and backup/restore over the Free85
link protocol. Emulator loopback tests are mandatory; physical-hardware results
are reported separately and may not be silently inferred.

### 14.10 - 2.0 hardening and release

Close every applicable ledger entry, remove temporary feature flags, freeze the
RAM schema, rebuild the exact 128 KiB ROM, update Pages and all documentation,
and run the complete validation matrix. Produce 2.0.0 release manifests,
reproducible hashes, migration notes, limitations, and clean-room provenance.

## Release train

- **2.0.0-alpha.1:** packages 14.0-14.3 merged; new object model, math, bases,
  modes, and graph core are stable.
- **2.0.0-alpha.2:** packages 14.4-14.6 merged; all graph modes and collection
  operations are feature-complete.
- **2.0.0-beta.1:** packages 14.7-14.9 merged; every planned user-facing surface
  exists and the gap ledger contains no `missing` entries.
- **2.0.0-rc.1:** full oracle, visual, randomized, stress, soak, migration,
  memory-pressure, and performance validation passes with no unexplained
  divergence.
- **2.0.0:** reproducible release artifacts and Pages deployment are approved.

## Validation matrix

The public lane builds Free85 from source and runs feature, parser, numeric,
property, collection, program, persistence, LCD-golden, performance,
memory-pressure, 10,000-event stress, and 180-second soak tests. It never reads
a TI ROM.

The optional private lane uses a user-owned ROM only as a black-box behavioural
oracle. It compares normalized values, modes, state transitions, error classes,
and timing envelopes rather than pixel identity. No ROM bytes, extracted
glyphs, screenshots, dumps, or proprietary fixtures enter the repository.

Link validation has three levels: deterministic protocol-unit tests, two-machine
emulator loopback including fault injection, and separately reported physical
hardware trials. Only the first two are required for continuous integration.

## Definition of Free85 2.0 complete

Free85 2.0 is complete when every applicable ledger entry is `equivalent`, all
hardware-dependent entries have a tested emulator implementation and an honest
hardware status, every clean-room exclusion is documented, all package gates
pass, and the 2.0 ROM, source, reports, documentation, and Pages artifact are
reproducible from a clean checkout.
