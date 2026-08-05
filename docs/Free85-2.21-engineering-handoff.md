# Free85 2.21 engineering handoff

Phase 16 ships as Free85 2.21.0. This is an implementation and validation
record for the separate documentation process; it does not revise the manual,
guidebook, or companion book.

## Corrected behaviour

- LU factorization no longer uses Vector R as hidden workspace. Matrix R still
  contains the combined LU factors, while the row permutation is held in
  dedicated state and shown on the matrix result screen as `P:...`.
- The simultaneous-equation editor's `CELL` indicator now preserves and shows
  the actual active column after drawing the row digit.
- The matrix row-operation footer is exactly 21 characters; `SWAP` is shown as
  `SWP`, so the fifth `AUG` label remains wholly inside the LCD.
- The power operator is no longer limited to integer exponents from -9 to 9.
  Exact signed 16-bit integers use exponentiation by squaring. Positive bases
  with other real exponents use `exp(exponent * ln(base))`.
- Power domains are explicit: a fractional power of a negative base is
  `DOMAIN ERROR`, zero to a negative power is `DIVIDE BY ZERO`, and an
  unrepresentable result is `OVERFLOW`.

## Validation evidence

- `test/free85/phase16-release.test.js` covers real and extended-integer powers,
  right associativity, unary-minus precedence, domain errors, divide-by-zero,
  and overflow.
- `test/free85/collections-phase18.test.js` seeds both real and imaginary Vector
  R values before LU and proves every value survives unchanged.
- `test/free85/statistics-solvers.test.js` visually locks `CELL 1 2` after moving
  to the second augmented-system column.
- Reviewed LCD fixtures lock the LU permutation, simultaneous CELL indicator,
  and the fitted row-operation menu.

General real power is intentionally slower than integer power because it runs
both logarithm and exponential kernels. Validation waits up to 240 emulated
frames for that bounded path to complete rather than sampling intermediate
numeric workspace.

The separate book process should execute the exact claim, example, screenshot,
and verification changes in `spec/free85/v2.21-book-impact.yaml`.
