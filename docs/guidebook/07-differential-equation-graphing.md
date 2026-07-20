# Chapter 7: Differential-Equation Graphing

Differential-equation graphing plots the solutions of first-order
differential equations from an initial condition, letting you see how a
system evolves without finding a closed-form answer first. When this mode
arrives it will complete the graph engine of Chapter 4 (Cartesian
Graphing, Drawing, Formats, and Persistence): a `DifEq` graph mode with
its own equation editor, numerical solution plotting, interactive
exploration from chosen initial conditions, and the differentiation-mode
selectors `dxDer1` and `dxNDer` that choose how derivatives are computed
while it runs.

None of this exists in today's firmware.

> ⚠ **Planned:** the differential-equation workflow: the `DifEq` mode, the
> equation editor, solution plotting, exploration, solving, and the
> `dxDer1`/`dxNDer` differentiation modes (Free85 2.0, work package 14.5).

What the keys do today: [GRAPH] always opens the Cartesian graph screen and
plots the function slots in `X`; the mode screen has no graph-type or
differentiation-mode settings; and nothing in any menu solves a
differential equation. The closest tools in today's firmware are the
derivative commands: `NDER(` takes the central numerical derivative of the
stored equation from the home screen (Chapter 3: Mathematics, Calculus, and
Comparisons), and [F4] on the graph screen takes the same derivative at the
traced position (chapter 4).
