# Free85 1.0 known limitations

Free85 is a complete standalone calculator for its documented feature set, but
it is not a binary-compatible replacement for Texas Instruments firmware.

- TI programs, applications, files, tokens, ROM calls, link formats, and
  undocumented internal data are not supported.
- Numbers use fourteen significant packed-BCD digits with decimal exponents
  from -128 through 127. Overflow, underflow, domain, and capacity failures are
  reported instead of silently changing representation.
- Graphs are rendered incrementally so ON and EXIT remain responsive. Simple
  graphs finish in roughly 2.5-6 emulated seconds; expressions containing
  transcendental functions can take substantially longer.
- The native link screen exercises the physical link lines and Free85 protocol
  state. It does not import or export proprietary TI file formats.
- Number-base and Boolean operations use signed 16-bit two's-complement words;
  ordinary decimal arithmetic retains the wider packed-BCD range.
- Home calculus callables operate on the active Y1 equation. They intentionally
  use short `EVAL(x)`/`FNINT(a,b)` forms instead of accepting an expression and
  variable as additional arguments.
- Lists contain at most eight values, matrices are at most 3x3, vectors have at
  most three components, simultaneous systems are at most 4x4, and polynomial
  solving is limited to degree four.
- The programming environment provides four programs of eight 48-character
  lines each, eight nested control frames, and four nested calls.
- Firmware schema upgrades may clear versioned calculator RAM because Free85
  does not promise internal-state compatibility between releases.
- The browser integration targets the repository's TI-85-compatible emulator;
  physical-hardware installation is not part of the 1.0 release validation.
