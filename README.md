# Free85

Free85 is an independently written, open-source scientific graphing calculator
ROM for a TI-85-compatible Z80 machine. It is inspired by the public-facing
capabilities of the TI-85, but contains no TI ROM code, disassembly, fonts,
artwork, binary tables, or proprietary fixtures.

The repository includes:

- original Z80 firmware source;
- a deterministic 128 KiB `FREE85.ROM` build;
- the TI-85-compatible machine runtime needed to execute it;
- a browser calculator and debugger;
- the product specification and feature/key contracts;
- numerical, UI, graph, stability, and visual-regression tests.

## Current status

Free85 1.0 completes Phases 0-13: boot/diagnostics, UI and editor, packed-BCD numeric
core, expression parsing, scientific functions, graphing, tables, numerical
tools, complex numbers, lists, matrices, vectors, statistics, regression,
statistical plots, simultaneous equations, polynomial roots, native strings,
an alphabetical callable catalog, a character palette, and a persistent custom
menu, a persistent on-calculator programming environment, system settings,
five numeric memories, variables and memory management, number-base display,
native link diagnostics, power control, lowercase alpha, and complete key/menu
parity.

The Phase 12 release adds deterministic performance gates, redundant-bank-call
elision, packed release RAM, cached graph tokenisation, precomputed graph
scaling, convergence-aware transcendental series, faster transparent-space
drawing, and a
10,000-key-event stress test. The release manifest records the exact ROM hash,
coverage, performance report, source, notices, and browser entry point.

Graph tests compare exact 1,024-byte LCD framebuffers and reviewed lossless PNG
goldens. Failures produce expected, actual, and red/blue diff images under
`test-results/free85-visual/`.

Phase 13 adds an optional clean-room differential suite for a user-owned TI-85
ROM: 270 numeric comparisons, application-state probes, private LCD diagnostics,
and chapter-level guidebook traceability. The public build and tests remain
fully independent of proprietary files.

Free85 2.0 work has reached Phase 14.1. Schema 13 adds a typed named-object
directory, a 22,784-byte compacting heap, retryable migration from the 1.0
state, exact capacity accounting, and an object-aware memory browser. The 2.0
gap report now records 4 of 36 gaps as equivalent; later math, graph,
collection, programming, link, and release packages remain explicitly open.

## Run the calculator

Requires Node.js 24 or newer.

```sh
npm run dev
```

Then open <http://localhost:3000/>. The bundled open-source Free85 ROM loads
automatically; another compatible 128 KiB ROM can be selected from the page.

The calculator is also deployed from `main` by the GitHub Pages workflow. Every
deployment runs the validation suite first and publishes only the browser app,
emulator sources, and Free85 ROM. Build the same static artifact locally with:

```sh
npm run build:pages
```

For a terminal framebuffer preview:

```sh
npm run run:free85 -- GRAPH
```

## Test

```sh
npm test
npm run benchmark:free85
npm run test:free85:stress
npm run test:free85:soak
```

To add the optional private behavioural comparison:

```sh
TI85_ORACLE_ROM=/private/path/TI85.ROM npm run test:free85:oracle
```

Approved graph screens are intentionally updated only with:

```sh
npm run update:free85:goldens
```

Review every generated PNG before accepting it.

## Build the ROM

Install `sjasmplus` 1.21.1 or newer, then run:

```sh
npm run build:free85
```

If it is not on `PATH`:

```sh
SJASMPLUS=/absolute/path/to/sjasmplus npm run build:free85
```

The build emits exactly eight 16 KiB pages at `ROM/FREE85.ROM` and reports
per-bank usage under `firmware/free85/generated/`.

To reproduce and validate the complete 1.0 release in one command:

```sh
SJASMPLUS=/absolute/path/to/sjasmplus npm run release:free85
```

## Specification

- [Full implementation specification](docs/Free85-specification.md)
- [Product definition](spec/free85/product.md)
- [Validation rules](spec/free85/validation.md)
- [Clean-room oracle validation](docs/oracle-validation.md)
- [Phase 13 validation result](spec/free85/oracle-report.json)
- [Free85 2.0 execution roadmap](docs/Free85-2.0-roadmap.md)
- [Free85 typed object-store contract](docs/Free85-object-store.md)
- [Free85 2.0 parity gap ledger](spec/free85/v2-parity-gaps.yaml)
- [Guidebook command-level ledger](spec/free85/guidebook-command-ledger.yaml)
- [Free85 2.0 parity progress](spec/free85/v2-parity-report.json)
- [Firmware documentation](firmware/free85/README.md)
- [Release manifest](spec/free85/release.json)
- [Performance report](spec/free85/performance.json)
- [Feature coverage](spec/free85/coverage.json)
- [Known limitations](docs/known-limitations.md)
- [Project notices](NOTICE.md)

Free85 does not promise compatibility with TI programs, files, ROM calls, or
internal data structures. Texas Instruments and TI-85 are referenced only to
describe calculator compatibility. This project is not affiliated with or
endorsed by Texas Instruments.

## License

MIT. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).
