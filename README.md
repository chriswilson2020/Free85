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

Free85 2.10.0 is the stable Phase 14.10 release. It is a deterministic 128 KiB
ROM with complete coverage of the applicable Free85 2.0 parity ledger,
persistent RAM schema 13, object-store schema 1, and independently reproducible
ROM and GitHub Pages artifacts. The home screen identifies the running release
as `VERSION 2.10`.

The original 1.0 baseline completed Phases 0-13: boot/diagnostics, UI and
editor, packed-BCD numeric core, expression parsing, scientific functions,
graphing, tables, numerical tools, complex numbers, collections, statistics,
solvers, strings, catalog/custom menus, programming, system settings, memory,
native link diagnostics, power control, and complete key/menu parity.

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

Free85 2.10.0 completes Phase 14.10. Schema 13 adds a typed named-object
directory, a 22,784-byte compacting heap, retryable migration from the 1.0
state, exact capacity accounting, and an object-aware memory browser. Phase
14.2 adds scalar numeric utilities, AUTO/SCI/ENG/FIX output, signed 16-bit
binary/octal/decimal/hexadecimal entry and display, Boolean word operations,
and callable active-function calculus. Phase 14.3 adds a shared Cartesian graph
engine with persistent format controls, simultaneous/sequential drawing, free
cursor, named window values, and the complete zoom panel. Phase 14.4 adds every
Cartesian drawing primitive, exact native picture/graph-database persistence,
program access, and reviewed LCD goldens. Later packages complete polar,
parametric, and differential-equation graphing; complex collections and linear
algebra; solver/statistics parity; and the bounded programming language with
native catalog dispatch. Phase 14.9 completes user constants, extended
characters, typed memory accounting, and fault-tested Free85 link transfer and
backup workflows. Phase 14.10 freezes schema 13, closes the applicable parity
ledger, and publishes independently rebuilt ROM and Pages hashes. Physical-cable
validation remains explicitly separate from the emulator-tested 2.0 release.

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
npm run validate:free85
SJASMPLUS=/absolute/path/to/sjasmplus npm run verify:free85:reproducible
```

The validation command runs the public functional, framebuffer, performance,
10,000-event stress, 180-second soak, and Pages-build gates. Reproducibility
requires `sjasmplus` 1.21.1 or newer; the current release evidence records
`sjasmplus` 1.21.1.

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

To reproduce and validate the complete 2.0 release in one command:

```sh
SJASMPLUS=/absolute/path/to/sjasmplus npm run release:free85
```

The release command builds the ROM and Pages artifact twice in isolated
temporary directories and rejects any byte or tree-hash difference.

### Publishing a release

The download links below point at the assets of the *latest release*, which
are not tracked in the repository: `dist/` is ignored, and the Pages
workflow publishes only the online editions. Attaching them is therefore a
separate step, and it is automated.

Publish a release on GitHub and the **Attach Free85 release assets**
workflow builds the ROM and all three typeset PDFs from that tag, runs the
validation suite and the reproducibility check first, and uploads them. It
runs on nothing else: not on a push to `main`, not on a pull request.

To refresh the assets of a release that already exists, run the same
workflow by hand from the Actions tab and give it the tag. Same-named
assets are replaced.

The ROM is built on Linux, where it is also checked for byte
reproducibility. The books are built on macOS, because `typeset.css` asks
for Charter, Helvetica Neue and Menlo, and those are macOS system fonts.
Built anywhere else, Chrome substitutes whatever it can find and every book
silently repaginates. The workflow fails if any of the three fonts is
missing, and again if a book does not come out at the page count it was
proofed at.

## Documentation

- [Getting Started Manual](docs/manual/Free85-Manual.md): running Free85,
  the keyboard and screen, first calculations, modes, and the catalog.
- [The Free85 Guidebook](docs/guidebook/00-front-matter.md): nineteen
  reference chapters plus appendices covering every command, key, error,
  and feature status. Every documented key sequence and result is captured
  from the emulator, and `npm run test:guidebook` checks that the book
  covers every completed command in the ledger.
- [Explorations with Free85](docs/companion/00-front-matter.md): a workbook
  of eight chapters, from precalculus to engineering mathematics, that puts
  the calculator to work on invented problems. Every exploration, data set,
  and exercise was written for this machine, and every key sequence and
  quoted result in it was run on the emulator.
- Typeset editions, ready to read or print (A5, covers, full table of
  contents): read the
  [Manual online](https://chriswilson2020.github.io/Free85/public/guidebook/Free85-Manual-typeset.html),
  the
  [Guidebook online](https://chriswilson2020.github.io/Free85/public/guidebook/Free85-Guidebook-typeset.html),
  or
  [Explorations online](https://chriswilson2020.github.io/Free85/public/guidebook/Free85-Companion-typeset.html),
  or download the
  [Manual PDF](https://github.com/chriswilson2020/Free85/releases/latest/download/Free85-Manual-typeset.pdf),
  the
  [Guidebook PDF](https://github.com/chriswilson2020/Free85/releases/latest/download/Free85-Guidebook-typeset.pdf)
  and the
  [Explorations PDF](https://github.com/chriswilson2020/Free85/releases/latest/download/Free85-Companion-typeset.pdf)
  from the latest release.
- All three books rebuild into `dist/guidebook/` from the Markdown sources:

```sh
npm run build:guidebook:typeset
npm run build:guidebook:web
```

(`npm run build:guidebook` produces the plain untypeset PDFs of the Manual
and Guidebook. Both need `pandoc` and Google Chrome, and regenerate the LCD
screenshots and the generated appendices first. The companion's own
screenshots come from `npm run build:companion:screens`.)

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
- [Free85 2.0 release and migration notes](docs/Free85-2.0-release.md)
- [Reproducibility report](spec/free85/reproducibility.json)
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
