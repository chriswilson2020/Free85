# Free85 ROM

`FREE85.ROM` is the deterministic 128 KiB output of the original Z80 sources
under `firmware/free85/`. It is included so the emulator, browser demo, and
public validation suite work without installing an assembler.

Rebuild it with:

```sh
npm run build:free85
```

Free85 2.20.0's exact size and SHA-256 digest are recorded in
`spec/free85/release.json`. `npm run release:free85` rebuilds and validates the
complete release bundle, while `npm run verify:free85:reproducible` performs
two independent ROM and GitHub Pages builds and checks their recorded hashes.

The ROM contains no Texas Instruments ROM code, disassembly, fonts, artwork,
binary tables, or proprietary fixtures. Free85 does not redistribute and never
requires an original `TI85.ROM`.
