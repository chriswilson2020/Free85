# Free85 graph modes and coordinate systems

Phase 14.5 adds three adapters to the shared graph engine introduced in Phase
14.3. Open **GRAPH FORMAT** (`2nd`, `MORE`) and press `MORE` twice to reach the
mode page. `F1` selects function, `F2` polar, `F3` parametric, and `F4`
differential-equation mode. `F5` switches graph-coordinate display between
rectangular and polar.

Polar mode uses equation slot 1 as `r(theta)` and samples one revolution in
the active RAD/DEG angle mode. Parametric mode uses slot 1 for `x(t)` and slot
2 for `y(t)`. Differential-equation mode uses slot 1 for `dy/dx=f(x,y)`, starts
at `Xmin` with persistent initial-Y state (seeded from variable `Y` when the
mode is first created), and advances with a deterministic Euler step equal to
the graph x step. Trace and table rows reintegrate from that initial condition,
so their results do not depend on the last rendered frame.

Switching modes stores the outgoing equations, enabled mask, active slot,
window, table start/step, and coordinate-display preference in a typed native
graph object. Returning to a mode restores that exact state. Plotting remains
incremental and `EXIT`/`CLEAR` cancellation follows the shared engine path.

The vector application's third menu page supplies rectangular-to-cylindrical,
cylindrical-to-rectangular, rectangular-to-spherical, and
spherical-to-rectangular conversions. Cylindrical triples are `(rho,theta,z)`;
spherical triples are `(r,theta,phi)`, with `phi` measured from positive Z.
All angles honor the calculator's global RAD/DEG setting.

Validation lives in `test/free85/graph-phase16.test.js` and the coordinate
cases in `test/free85/collections.test.js`. The three mode plots have packed
LCD and PNG goldens under `test/free85/goldens/graphs/` and can be regenerated
with `npm run update:free85:phase16-goldens`.
