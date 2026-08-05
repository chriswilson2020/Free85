# Free85 2.14.0 known limitations

Free85 is a complete standalone calculator for its documented feature set, but
it is not a binary-compatible replacement for Texas Instruments firmware.

- TI programs, applications, files, tokens, ROM calls, link formats, and
  undocumented internal data are not supported.
- Numbers use fourteen significant packed-BCD digits with decimal exponents
  from -128 through 127. Magnitudes below 1E-128 underflow deterministically to
  zero; overflow, domain, and capacity failures are reported.
- Graphs are rendered incrementally so ON and EXIT remain responsive. Simple
  graphs finish in roughly 2.5-6 emulated seconds; expressions containing
  transcendental functions can take substantially longer.
- The native link screen and emulator cable implement the open Free85 transfer
  and backup protocol. Physical-cable validation has not yet been reported, and
  proprietary TI link/file formats are intentionally unsupported.
- Number-base and Boolean operations use signed 16-bit two's-complement words;
  ordinary decimal arithmetic retains the wider packed-BCD range.
- Home calculus callables operate on the active Y1 equation. They intentionally
  use short `EVAL(x)`/`FNINT(a,b)` forms instead of accepting an expression and
  variable as additional arguments. A calculus callable stored inside a graph
  slot is refused to protect the single-level evaluator context.
- Circular functions use bounded quotient/remainder reduction. Their measured
  supported input range is magnitude 1E6 radians or 1E8 degrees; larger values
  report `PRECISION LOST` rather than returning an unjustified phase. SIN and
  COS are bounded to 1E-7 absolute error across the outer tested range and
  1E-9 through 1E4 radians. TAN necessarily becomes ill-conditioned near its
  poles and should not be treated as having a uniform absolute-error bound;
  a reduced cosine within 1E-10 of zero is refused as `DOMAIN ERROR`.
- `FNINT` compares 32- and 64-panel composite-Simpson estimates and may refine
  once to 128 panels. It reports `DIVIDE BY ZERO` for an undefined sample and
  `NO CONVERGENCE` when the bounded comparison misses the selected tolerance.
  This is a safety check, not a general adaptive integrator: narrow features
  which every sampled mesh misses can still evade detection.
- Differential-equation graphing uses fixed-step Euler integration. Its initial
  Y value is frozen in the saved `GDEQ` state; choosing another currently
  requires deleting that object and re-entering the equation.
- Lists contain at most eight values, matrices are at most 3x3, vectors have at
  most three components, simultaneous systems are at most 4x4, and polynomial
  solving is limited to degree four. Collection results land in read-only `R`
  and there is not yet an atomic result-to-input copy operation.
- The programming environment provides four programs of eight 48-character
  lines each, eight nested control frames, and four nested calls. `FOR` bounds
  are single digits from 0 through 9 and its step is always positive one.
- Free85 2.14.0 retains the frozen persistent RAM schema 13 and object-store schema 1. It
  migrates schema 12 transactionally; unsupported or corrupt schema headers
  are reset rather than interpreted speculatively.
- The browser integration targets the repository's TI-85-compatible emulator;
  physical-hardware installation is not part of the 2.14.0 release validation.

The accepted Phase 15 roadmap owns the numerical and workflow limitations
above for Free85 2.20. Larger dynamic collections and program stores remain a
separate potential Free85 3.0 workspace redesign.
