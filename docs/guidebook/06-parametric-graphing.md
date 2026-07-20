# Chapter 6: Parametric Graphing

Parametric graphing plots curves whose horizontal and vertical coordinates
are each given as a function of a shared parameter, the form that handles
projectile paths, Lissajous figures, and any curve that doubles back on
itself. When this mode arrives it will sit on the shared graph engine of
Chapter 4 (Cartesian Graphing, Drawing, Formats, and Persistence): a
`Param` graph mode, equation slots holding coordinate pairs, plotting with
the same cancellable redraw, and tracing, tables, and analysis stepped by
the parameter rather than by `X`.

None of this exists in today's firmware.

> ⚠ **Planned:** the parametric graphing workflow: the `Param` mode, the
> paired equation editor, plotting, tracing, tables, and analysis
> (Free85 2.0, work package 14.5).

What the keys do today: [GRAPH] always opens the Cartesian graph screen of
chapter 4, plotting the function slots in `X`; the mode screen has no
graph-type setting; and no menu or catalog entry mentions a parameter. A
single parametric point can still be computed by hand with a stored
variable (Chapter 2: Variables and Stored Data): `0.5->T` followed by
`3*COS(T)` and `3*SIN(T)` evaluates one point of a circle of radius 3 at
parameter 0.5, answering `= 2.6327476856711` and `= 1.4382766158126`.
