# Free85 solver and statistics core

Phase 14.7 completes the general solver and the bounded statistics application
using the same fourteen-digit packed-decimal arithmetic as the rest of the
ROM.

## General solver

`2ND`+`GRAPH` opens a persistent solver workspace. A non-empty home expression
becomes the stored equation; reopening the workspace without a home expression
retains it. The workspace stores a selectable `A`-`Z` variable, initial guess,
lower and upper bounds, root, and residual.

The solver first evaluates the guess, scans 32 equal subintervals for a sign
change, and then performs 40 bounded bisections. It publishes a result only
when the absolute residual meets the configured graph tolerance. Invalid
domains, reversed bounds, empty equations, and unbracketed roots produce
recoverable notices. `GRPH` maps the selected solver variable to graph `X`,
copies the solver bounds into the graph window, and opens the shared graph
engine.

## Regression models and forecasts

The statistics menu supports linear, logarithmic, exponential, power, and
degree 2-4 polynomial regression. Logarithmic transforms reject non-positive
samples. Polynomial coefficients are accumulated from packed-decimal normal
equations and solved with pivoted elimination. Coefficients are stored in
ascending power order (`A`, `B`, ...), so a quadratic is
`A+B*x+C*x^2`.

`FCY` evaluates the active model at the selected X value. `FCX` uses the
analytic inverse for two-coefficient models and a deterministic bounded search
over the observed X interval for polynomial models. Forecast inputs and
outputs remain stored after leaving the result screen.

## Statistical commands and plots

`1V`, `2V`, and `LIN` remain directly callable from the command pages. `SHW`
recalls the most recent summary, regression, or forecast. `SX` and `SY` sort
paired rows by X or Y while preserving the association between columns.
`XYLN` maps paired samples through the same bounds as scatter plotting and
joins consecutive samples with clipped integer Bresenham segments.

## Validation

`test/free85/statistics-phase19.test.js` independently checks solver roots and
residuals, editable bounds, graph handoff, every regression family, forward
and inverse forecasts, paired sorting, last-result recall, invalid samples,
and exact solver/xyLine LCD fixtures. Existing Phase 8 tests continue to cover
one/two-variable summaries, specialist solvers, scatter, histogram, and box
plots.
