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
