# Free85 Validation Rules

`features.yaml` is the feature-status source of truth. `keymap.yaml` maps the
physical faceplate to those feature identifiers. Both files use JSON syntax,
which is valid YAML 1.2, so the dependency-free Node.js validation tools can
parse them deterministically.

The Phase 0 validator enforces:

- exactly the 50 browser faceplate keys are present once in `keymap.yaml`;
- all 49 matrix keys have one unique hardware position and ON is the sole
  non-matrix key;
- normal, printed second, and printed alpha labels match the shared browser
  inventory;
- every normal, second, and alpha surface references a registered feature;
- feature identifiers are unique and statuses are valid;
- completed features name an implementation, documentation, and tests;
- Phase 2 editor and modifier surfaces may be `tested`; calculator operations
  advance only when their actual numeric workflow has a stable vector test.

The generated `coverage.json` reports physical, shifted, alpha, and feature
registration separately from implementation completion. Registration means a
surface has an owned stable identifier; it does not claim working firmware.

Phase 1 extends validation through `Ti85Machine`: reset and interrupt vectors,
LCD boot output, all physical key events, repeated reset, deterministic ROM
size, bank usage, and stability. Public Free85 tests never load `TI85.ROM`.

Phase 2 additionally drives all normal keys, every printed shifted surface, and
every alpha mapping through the event queue and UI dispatcher. A tested editor
surface must identify its assembly implementation and a stable test identifier.
Placeholder dialogs prove reachability but do not upgrade the underlying
calculator feature from `planned`.

Phase 3 adds representation-level and keypad-driven arithmetic vectors for the
four basic operations, bounded integer powers, square, square root, decimal
parsing/formatting, signed decimal exponents, rounding, and recoverable errors.
These vectors run entirely against the open Free85 ROM.

Phase 4 validates the tokenizer and bounded precedence parser against the
specification's associativity and unary test vectors. Separate workflows cover
postfix assignment, variables, previous answer, four-slot editable history,
reevaluation, implicit multiplication, and recoverable malformed input.

Phase 5 validates logarithmic, exponential, circular, inverse-circular,
hyperbolic, inverse-hyperbolic, factorial, permutation, combination, physical
constant, and all eleven required conversion-category vectors against
JavaScript's independent math
implementation. Comparisons use a documented 1e-10 relative tolerance with an
absolute scale floor of one. Separate vectors toggle degree/radian mode and
verify domain and function-arity failures remain recoverable.

Phase 6 validates incremental Cartesian plotting, three selectable equation
slots, discontinuity isolation, redraw cancellation, trace, zoom, grid,
standard/square windows, and a scrolling table through the physical keypad.
Independent numerical vectors cover roots, extrema, Y1/Y2 intersections,
central-difference derivatives, 64-panel Simpson integration, the home solver,
and tolerance selection. Solver roots are checked together with their residual;
an unbounded discontinuity may not be accepted merely because its sign changes.

Phase 7 adds keypad-driven editor workflows and packed-decimal result vectors
for complex arithmetic and roots, list aggregation and ordering, matrix
determinants/transposition/multiplication/inversion/RREF/linear solving, and
vector norm/dot/cross/angle operations. Error vectors assert recoverable
dimension and singularity dialogs. Collection maximums and population standard
deviation semantics are documented in the firmware guide.

Phase 11 performs the final parity audit. It rejects any remaining `planned`
feature, requires every feature to carry an implementation, documentation, and
stable test identifier, and exercises the final system, memory, menu, lowercase
alpha, native link, power, previous-entry, number-base, and comparison paths.
The generated report must show 100 percent registered physical keys, shifted
functions, and alpha mappings, plus 100 percent complete features with tests.

Phase 12 adds deterministic Z80 T-state and frame budgets for ordinary key
response, representative arithmetic and transcendental expressions, and three
graph workloads. It also requires the exact 128 KiB release ROM and SHA-256
manifest, 10,000 automated key events without corruption or stack escape, the
180-second emulated soak, complete licence and limitations documents, and a
static-site build whose default ROM is Free85. Performance optimisation may not
change accepted numerical vectors or reviewed LCD framebuffer goldens.

Phase 13 adds an optional clean-room oracle lane. When `TI85_ORACLE_ROM` names
a user-owned 128 KiB ROM, the harness boots it through the public calculator
interface, sends physical key sequences, calibrates an in-memory numeric OCR
reader, and compares semantic results with Free85 and independent expected
values. It stores no ROM bytes or TI glyph fixtures. The full lane covers 270
deterministic numeric vectors and five application-state probes; the existing
public suite remains authoritative for errors, screen goldens, stress, soak,
timing, and every Free85 feature. `guidebook-coverage.yaml` separately records
equivalent, divergent, out-of-scope, and hardware-dependent guidebook areas.

Phase 14.0 replaces the coarse chapter summary with a command-level Free85 2.0
ledger. Every inventoried function, instruction, mode, semantic family, and
major workflow has exactly one classification. An `equivalent` group requires
implementation evidence; partial, missing, and hardware-dependent groups must
name a registered 2.0 gap owner and a concrete completion target. The generated
`v2-parity-report.json` is rejected when stale. Phase 14.0 also makes explicit
bad ROM paths, uncertain OCR cells, and failed application-state probes fatal
to private oracle runs.

Phase 14.1 adds direct Z80 validation of the schema-13 typed object store. The
suite covers every public type identifier, named lookup, directory exhaustion,
heap exhaustion, grow and shrink relocation, deletion compaction, payload and
address preservation, warm-reset persistence, retryable schema-12 migration,
and legacy-value preservation. The memory browser has a reviewed raw 1,024-byte
LCD fixture and PNG, and its delete path is driven through physical keys.
