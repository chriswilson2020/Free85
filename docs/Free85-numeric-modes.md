# Free85 2.0 numeric modes and utilities

Phase 14.2 completes the scalar numeric, display-mode, number-base, Boolean,
and callable numerical-analysis package. All calculations continue to use the
14-digit packed-decimal core; the signed-word boundary applies only to base and
Boolean operations.

## Display modes

Open `2nd` `MORE` and press `F1`, then use `F2` to cycle:

- `AUTO` (Normal/Float): ordinary decimal output, switching to an exponent for
  values outside the compact display range;
- `SCI`: one digit before the decimal point and an explicit exponent;
- `ENG`: one to three digits before the decimal point and an exponent divisible
  by three;
- `FIX`: exactly 0-11 fractional digits with half-up decimal rounding.

In `FIX`, `UP` and `DOWN` change the number of fractional digits. The selected
format affects result presentation, not stored precision.

## Scalar utilities

The expression parser and catalog expose `INT`, `FRAC`, `ROUND`, `SIGN`, `MOD`,
`GCD`, `LCM`, `MIN`, `MAX`, `PCT`, `ROOT`, `RAND`, and `RANDI`. `ROUND(x,n)`
accepts 0-11 places. `ROOT(x,n)` requires a positive integer degree and permits
negative `x` only for odd degrees. `RAND()` uses a deterministic 16-bit LFSR;
`RANDI(low,high)` is inclusive.

## Bases and Boolean words

Literal prefixes are accepted anywhere a number is accepted:

```text
0b101010   0o52   42   0x002A
```

They participate in ordinary expression arithmetic. Non-decimal values are
unsigned bit patterns converted to signed two's-complement values at the
16-bit boundary (`0xFFFF` is `-1`, `0x8000` is `-32768`). The `2nd` `1` base
screen displays the previous integer answer as decimal, four-digit hex,
six-digit octal, or sixteen-digit binary with `F1`-`F4`.

`AND`, `OR`, `XOR`, `NOT`, `SHL`, `SHR`, `ROL`, and `ROR` use the same signed
16-bit word. `SHR` is logical; rotations wrap within 16 bits. Counts are
reduced modulo 16, and non-integral or out-of-range operands report a domain
error.

## Callable numerical analysis

The following functions analyse the active graph equation (Y1):

- `EVAL(x)` evaluates it at `x`;
- `NDER(x)` uses a central numerical derivative;
- `FNINT(a,b)` uses a 64-panel composite Simpson rule;
- `FMIN(a,b)` and `FMAX(a,b)` return an extremum location;
- `INTER(a,b)` returns the linear endpoint interpolation at the midpoint;
- `ARC(a,b)` sums a 64-segment polyline arc length.

This active-function convention keeps expressions short enough for the
calculator editor while providing the same workflows from home, programs, and
the catalog. Nested evaluation preserves the user's editor, token stack, parser
state, and X variable. Graph-screen F1-F5 analysis remains available.

## Validation

`test/free85/v2-numeric-modes.test.js` covers exact utility vectors, formatting
boundaries and carries, literal overflow, signed-word edges, shifts/rotations,
and independent calculus references. `test/free85/parity.test.js` verifies the
four base-screen representations.
