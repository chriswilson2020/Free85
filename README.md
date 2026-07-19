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

Phases 0-7 are implemented: boot/diagnostics, UI and editor, packed-BCD numeric
core, expression parsing, scientific functions, graphing, tables, numerical
tools, complex numbers, lists, matrices, and vectors. Phase 8 statistics and
specialist solvers are next.

Graph tests compare exact 1,024-byte LCD framebuffers and reviewed lossless PNG
goldens. Failures produce expected, actual, and red/blue diff images under
`test-results/free85-visual/`.

## Run the calculator

Requires Node.js 24 or newer.

```sh
npm run dev
```

Then open <http://localhost:3000/>. The bundled open-source Free85 ROM loads
automatically; another compatible 128 KiB ROM can be selected from the page.

For a terminal framebuffer preview:

```sh
npm run run:free85 -- GRAPH
```

## Test

```sh
npm test
npm run test:free85:soak
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

## Specification

- [Full implementation specification](docs/Free85-specification.md)
- [Product definition](spec/free85/product.md)
- [Validation rules](spec/free85/validation.md)
- [Firmware documentation](firmware/free85/README.md)

Free85 does not promise compatibility with TI programs, files, ROM calls, or
internal data structures. Texas Instruments and TI-85 are referenced only to
describe calculator compatibility. This project is not affiliated with or
endorsed by Texas Instruments.

## License

MIT. See [LICENSE](LICENSE).
