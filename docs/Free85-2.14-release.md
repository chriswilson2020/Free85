# Free85 2.14.0 release notes

Free85 2.14.0 completes Phase 15.2 of the numerical-integrity programme. It
retains the Free85 2.12 error and integration improvements, the completed 2.0
command surface, and persistent RAM schema 13.

## Trigonometric range reduction

- SIN, COS, and TAN now use a bounded quotient/remainder reduction instead of
  repeatedly adding or subtracting two pi at most 63 times.
- Radian inputs are supported through magnitude 1,000,000. Degree inputs are
  reduced modulo 360 before conversion and are supported through magnitude
  100,000,000 degrees.
- SIN and COS have an independently tested 1E-7 absolute-error bound across
  the outer supported range and 1E-9 vectors through 10,000 radians.
- Inputs outside the measured range report `PRECISION LOST`; they are not
  misreported as syntax or domain errors and are not given a plausible but
  unjustified result.
- EXIT and ON remain cancellation points during reduction.

Outer quadrants are reflected into the Taylor series' accurate interval. The
work also corrects a latent TAN workspace alias: calculating cosine could
overwrite the saved sine result, especially after a large-angle reduction.

TAN cannot have a uniform absolute-error promise near odd multiples of pi/2,
where the mathematical function itself is ill-conditioned. Tests therefore
cover representative values away from poles, while values whose reduced
cosine is within 1E-10 of zero return `DOMAIN ERROR`.

## Validation

The public suite covers positive and negative angles, the former 399-radian
cliff, quadrant boundaries, radians and degrees at both supported limits,
precision refusal immediately outside them, program error propagation,
cancellation, ordinary scientific regressions, graph performance, framebuffer
goldens, stress, soak, and two independent reproducible ROM/Pages builds.

The Manual, Guidebook, and *Explorations with Free85* sources remain unchanged.
Their precise 2.14 corrections are recorded in the 2.20 book-impact handoff for
the later coordinated editorial pass.
