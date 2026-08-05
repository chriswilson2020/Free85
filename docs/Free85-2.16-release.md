# Free85 2.16.0

Free85 2.16.0 completes Phase 15.3, the re-entrant-calculus work package in the
2.20 numerical-integrity programme.

## What changed

- Existing active-equation calculus remains source-compatible.
- `EVAL(slot,x)` and `NDER(slot,x)` explicitly target graph slots 1 through 3.
- `FNINT`, `FMIN`, `FMAX`, `ARC`, and `INTER` accept `slot,a,b` forms.
- Derivative and accumulator expressions can be plotted and tabulated.
- Nested evaluation restores the caller's parser, editor, token cache, active
  slot, plot/table counters, X value, and graph window.
- Direct and indirect graph-slot cycles report `RECURSION ERROR`; unrelated
  equations continue normally. Nesting is deliberately bounded to one graph
  evaluation frame.

## Validation

Independent vectors verify `NDER(1,2)` on `Y1=X^2` as 4 and
`FNINT(1,0,2)` as 8/3. Reviewed lossless LCD fixtures cover the derivative
function and accumulator function, including their tables. Direct and indirect
cycle cases compare the surviving unrelated curve with a clean reference.
The release suite also retains all earlier public, visual, stress, soak,
performance, and reproducibility gates without requiring a TI ROM.

## Compatibility

The persistent RAM schema remains 13 and the object-store schema remains 1.
TI programs, files, tokens, ROM calls, and undocumented internal formats remain
outside Free85's compatibility target.
