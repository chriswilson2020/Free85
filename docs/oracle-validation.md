# Phase 13 clean-room validation

Free85 can optionally be checked against a legally obtained TI-85 ROM without
making that ROM a build input or distributing any part of it. This is a
behavioural oracle, not a compatibility shim and not a pixel-cloning process.

## Run it

The ordinary public suite needs no proprietary file:

```sh
npm run validate:free85
```

Enable the private oracle locally:

```sh
TI85_ORACLE_ROM=/private/path/TI85.ROM npm run test:free85:oracle
```

Run the complete public and private package together with:

```sh
TI85_ORACLE_ROM=/private/path/TI85.ROM npm run validate:free85:complete
```

If the variable is absent, the oracle lane reports `SKIP` and exits
successfully. A ROM must be exactly 128 KiB. The script reports its SHA-256
fingerprint for local reproducibility but never copies or prints ROM contents.

Add `--write-private` to write a detailed JSON report and the final monochrome
LCD capture under ignored `oracle-results/`. The capture is diagnostic material
from the user's own ROM and must not be committed or redistributed. Set
`FREE85_ORACLE_OUTPUT` to choose another private output directory.

## Comparison model

The full run contains 14 reviewed edge/precision vectors, 256 seeded arithmetic
vectors, and five application-state probes. Each numerical observation is
checked three ways:

1. Free85 is compared with an independently calculated expected value.
2. The user ROM is driven with the equivalent physical key sequence.
3. The two semantic numbers are compared at `1e-10` relative tolerance.

TI glyphs are calibrated in memory by asking the running calculator to display
the digits, decimal point, and negative sign. The calibration is never written
to disk. This makes the reader robust to distinct Free85/TI font artwork while
preserving the clean-room boundary. Screen probes compare transitions,
readability, and LCD state—not framebuffer identity.

Classifications are explicit: `equivalent`, `free85-regression`,
`oracle-observation-unreadable`, or `intentional-or-unresolved-divergence`.
Unreadable output fails the lane rather than being silently treated as parity.

## What “exhaustive” means here

The package combines several complementary layers:

- all registered Free85 keys/features and parser/numeric vectors;
- deterministic LCD golden images, including graph continuity;
- 10,000-event stress and a 180-second emulated soak;
- CPU/frame performance limits;
- seeded private cross-ROM numeric and state observations;
- chapter-level TI-85 Guidebook traceability.

No finite suite proves every calculator state. “Exhaustive” therefore means
complete coverage of the documented Free85 v1 contract plus broad, repeatable
differential and long-run testing. Polar, parametric, differential-equation,
and other TI-only facilities are listed honestly as out of scope rather than
counted as Free85 failures. See `spec/free85/guidebook-coverage.yaml`.

## Copyright and release safety

Never commit a TI ROM, screenshots captured from it, extracted glyphs,
disassembly, memory dumps, or binary fixtures. `.gitignore` blocks the common
local ROM and result locations. CI and release builds use only the open Free85
sources and `ROM/FREE85.ROM`.
