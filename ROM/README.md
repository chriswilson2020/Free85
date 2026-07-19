# Free85 ROM

`FREE85.ROM` is the deterministic 128 KiB output of the original Z80 sources
under `firmware/free85/`. It is included so the emulator, browser demo, and
public validation suite work without installing an assembler.

Rebuild it with:

```sh
npm run build:free85
```

The 1.0 release's exact size and SHA-256 digest are recorded in
`spec/free85/release.json`; `npm run release:free85` rebuilds the ROM and checks
the complete release bundle.

The ROM contains no Texas Instruments ROM code, disassembly, fonts, artwork,
binary tables, or proprietary fixtures. Free85 does not redistribute and never
requires an original `TI85.ROM`.
