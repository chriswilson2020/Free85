You’re right. I misunderstood the instruction and should not have attempted any GitHub action. Paste the specification below directly into Codex.

# Free85: Complete Open TI-85-Style Firmware Specification and Implementation Plan

## 1. Instruction to Codex

Implement an original, open-source calculator firmware called **Free85** for the existing TI-85-compatible machine layer in this repository.

Do not commit, push, open pull requests, rewrite Git history, or modify repository settings unless explicitly instructed. Work only in the local working tree.

Do not modify the ZX Spectrum, CP/M, TRS-80, or shared Z80 CPU behaviour unless a change is strictly required and covered by regression tests.

Proceed incrementally. After each phase:

1. Run the relevant tests.
2. Report what is complete.
3. Report remaining limitations honestly.
4. Do not claim a feature works unless it is reachable through the virtual keypad and has a test.

------

# 2. Product definition

Free85 is an independently written, open-source ROM for TI-85-compatible hardware.

Its required parity target is:

> Every physical TI-85 key, shifted function and built-in menu leads to a working equivalent feature, but the firmware does not claim compatibility with TI programs, files, internal APIs or external applications.

The firmware must:

- boot in the existing `Ti85Machine`;
- run entirely on the emulated Z80 and calculator hardware;
- initialise the LCD and keypad itself;
- provide a complete standalone scientific graphing calculator;
- be distributable with `z80.world`;
- contain no original TI ROM code;
- use an original user interface and original screen text;
- optionally run on sufficiently compatible physical TI-85 hardware in the future.

The original TI-85 ROM may be used privately as a black-box behavioural reference, but it must never be:

- included in the source tree;
- included in generated artifacts;
- required by public tests;
- uploaded to CI;
- copied into fixtures;
- reconstructed from patches;
- automatically downloaded;
- referenced by a public download URL.

------

# 3. Non-goals

Free85 does not need to support:

- ZShell;
- Usgard;
- existing TI-85 assembly programs;
- original TI ROM-call addresses;
- original TI RAM addresses or internal structures;
- TI variable-file compatibility;
- TI backup-file compatibility;
- link compatibility with original applications;
- byte-compatible TI-BASIC tokenisation;
- original visual styling;
- original menu wording;
- exact original error messages;
- pixel-perfect display reproduction;
- undocumented TI firmware bugs;
- external downloadable applications.

Free85 may provide its own programming language and its own data structures.

------

# 4. Existing project assumptions

The repository already contains:

- an accurate JavaScript Z80 implementation;
- a `Ti85Machine` hardware layer;
- 128 KB ROM support;
- 32 KB RAM support;
- ROM banking;
- a 128×64 LCD renderer;
- keypad matrix handling;
- timer and ON-key interrupt behaviour;
- a browser TI-85 faceplate;
- a debugger and instruction stepping;
- local ROM selection.

Preserve those facilities.

The expected TI-85 address model is:

```text
0000–3FFF  Fixed 16 KB ROM page
4000–7FFF  Banked 16 KB ROM page
8000–FFFF  32 KB RAM
```

The target ROM image is:

```text
131,072 bytes
8 pages × 16,384 bytes
```

Do not assume any service from the original TI ROM.

------

# 5. Deliverables

Create the following logical components.

```text
firmware/free85/
├── README.md
├── LICENSE
├── Makefile or build script
├── include/
│   ├── hardware.inc
│   ├── memory.inc
│   ├── keys.inc
│   ├── errors.inc
│   └── objects.inc
├── boot/
│   ├── vectors.asm
│   ├── reset.asm
│   ├── interrupts.asm
│   └── banking.asm
├── drivers/
│   ├── lcd.asm
│   ├── keypad.asm
│   ├── timer.asm
│   └── power.asm
├── kernel/
│   ├── main.asm
│   ├── events.asm
│   ├── heap.asm
│   ├── objects.asm
│   ├── variables.asm
│   └── errors.asm
├── ui/
│   ├── font.asm
│   ├── drawing.asm
│   ├── text.asm
│   ├── editor.asm
│   ├── menus.asm
│   ├── dialogs.asm
│   ├── status.asm
│   └── screens.asm
├── math/
│   ├── number.asm
│   ├── addsub.asm
│   ├── muldiv.asm
│   ├── powers.asm
│   ├── trig.asm
│   ├── logs.asm
│   ├── complex.asm
│   ├── statistics.asm
│   ├── matrices.asm
│   ├── vectors.asm
│   └── numerical.asm
├── language/
│   ├── tokens.asm
│   ├── lexer.asm
│   ├── parser.asm
│   ├── evaluator.asm
│   └── program.asm
├── apps/
│   ├── home.asm
│   ├── graph.asm
│   ├── table.asm
│   ├── solver.asm
│   ├── statistics.asm
│   ├── matrix.asm
│   ├── vector.asm
│   ├── lists.asm
│   ├── programs.asm
│   ├── variables.asm
│   └── system.asm
└── generated/
    └── free85.rom

spec/free85/
├── product.md
├── keymap.yaml
├── features.yaml
├── menus.yaml
├── numeric-model.md
├── language.md
├── error-behaviour.md
├── validation.md
└── coverage.json

test/free85/
├── boot.test.js
├── keypad.test.js
├── calculator.test.js
├── parser.test.js
├── scientific.test.js
├── graph.test.js
├── statistics.test.js
├── matrix.test.js
├── program.test.js
└── coverage.test.js

scripts/
├── build-free85.js
├── run-free85.js
├── free85-key-sequence.js
├── free85-test-vectors.js
└── free85-oracle-capture.js
```

Adapt names to existing repository conventions where necessary, but preserve the separation of firmware, specification, tests, and tools.

------

# 6. Build system

Use a conventional Z80 assembler, preferably `sjasmplus`, unless the repository already standardises on another assembler.

The build must:

1. Assemble all firmware modules.
2. Generate exactly eight 16 KB ROM pages.
3. Pad unused ROM space deterministically.
4. Concatenate pages into one 131,072-byte file.
5. Fail if any page exceeds 16 KB.
6. Produce a map file and symbol file.
7. Report used and free bytes per bank.
8. generate `ROM/FREE85.ROM` or another clearly named distributable output.
9. Never require `TI85.ROM`.

Add commands equivalent to:

```text
npm run build:free85
npm run test:free85
npm run run:free85
npm run coverage:free85
```

The normal test suite must remain runnable without the assembler if the generated open ROM is checked in. The firmware build suite may require the assembler.

------

# 7. Boot and low-level requirements

## 7.1 Reset

At reset, Free85 must:

1. Disable interrupts.
2. Establish a valid stack.
3. Initialise ROM banking.
4. Initialise RAM state.
5. Initialise the LCD.
6. Clear the display.
7. Initialise keypad state.
8. Initialise timer interrupts.
9. Validate the persistent RAM header.
10. Create a fresh object store if RAM is uninitialised or invalid.
11. Enable interrupts.
12. Display a Free85 splash screen.
13. Enter the home calculator.

The splash screen must identify the firmware as Free85 or another project-owned name. It must not claim to be official TI firmware.

## 7.2 Interrupt vectors

Implement:

- reset vector at `0x0000`;
- maskable interrupt handling;
- ON-key handling;
- a safe NMI vector;
- interrupt-safe bank switching;
- keypad repeat timing;
- cursor blinking;
- time-based event delivery.

Interrupt handlers must preserve all registers they modify.

## 7.3 Banking

Create explicit routines for:

- selecting a ROM bank;
- calling a routine in another bank;
- returning to the previous bank;
- reading banked constant tables;
- avoiding bank changes inside unsafe interrupt sections.

Do not scatter raw bank-port writes throughout the firmware.

------

# 8. Hardware abstraction

All hardware interaction must pass through named driver routines.

Required driver interfaces:

```text
lcd_init
lcd_clear
lcd_set_pixel
lcd_clear_pixel
lcd_get_pixel
lcd_draw_bitmap
lcd_present
lcd_set_contrast
lcd_enable
lcd_disable

keypad_init
keypad_scan
keypad_get_event
keypad_is_pressed
keypad_wait_release

timer_init
timer_get_ticks
timer_delay

power_shutdown
power_wake
```

No application should directly access hardware ports.

------

# 9. Display and UI requirements

## 9.1 Display

Target:

```text
128 × 64 monochrome pixels
```

Implement:

- a compact original bitmap font;
- uppercase and lowercase letters;
- digits;
- mathematical symbols;
- menu indicators;
- cursor glyphs;
- graph axes and markers;
- text inversion or highlighting;
- clipped drawing primitives.

Required primitives:

```text
pixel
horizontal line
vertical line
general line
rectangle
filled rectangle
bitmap
character
string
integer
formatted number
```

## 9.2 Screen layout

Use an original interface rather than a pixel copy of TI firmware.

Recommended arrangement:

```text
Top status row
Main content area
Bottom soft-key/menu row
```

The status row may show:

- angle mode;
- numeric display mode;
- shift state;
- alpha state;
- available memory;
- graph mode.

## 9.3 Navigation

Required global behaviour:

- `2ND` activates one shifted operation and then clears.
- `ALPHA` activates alphabetic entry.
- A second ALPHA press may lock alpha mode.
- `EXIT` returns one level.
- shifted `QUIT` returns to the home screen.
- `CLEAR` clears the current entry or dismisses an error.
- `DEL` deletes before or at the cursor according to documented Free85 behaviour.
- shifted `INS` toggles insert/overwrite mode.
- arrow keys move through editors, menus, graphs and tables.
- `MORE` advances menu pages.
- `ENTER` confirms or evaluates.
- `ON` wakes the calculator and may interrupt long operations.

No key may silently do nothing unless the specification explicitly defines that state as unavailable.

------

# 10. Key coverage specification

Use the existing browser `TI85_KEY_LAYOUT` as the authoritative inventory of physical keys and printed shifted labels.

Create `spec/free85/keymap.yaml` containing, for every key:

```yaml
- physical_key: SIN
  normal:
    id: math.sin
    behaviour: Insert or evaluate sine
  second:
    label: SIN^-1
    id: math.asin
    behaviour: Insert or evaluate inverse sine
  alpha:
    label: B
    id: text.B
    behaviour: Insert uppercase B
  status: planned
  tests: []
```

Required fields:

- physical key;
- normal label;
- shifted label;
- alpha label;
- normal feature identifier;
- shifted feature identifier;
- alpha feature identifier;
- contexts where enabled;
- tests;
- implementation status.

A build or test must fail when:

- a physical key is absent;
- a printed shifted function has no feature entry;
- a menu is reachable but contains an unregistered item;
- a supposedly completed feature has no test.

The browser keypad labels and firmware keymap must be cross-checked automatically.

------

# 11. Functional scope

## 11.1 Home calculator

The home screen must support:

- multi-line expression entry;
- cursor movement;
- insert and overwrite modes;
- expression history;
- previous-answer recall;
- variable assignment;
- parentheses;
- unary minus;
- scientific notation;
- implicit multiplication where deliberately supported;
- correct operator precedence;
- recoverable syntax and domain errors.

Required operators:

```text
+
-
×
÷
^
unary -
=
<>
<
>
<=
>=
and
or
not
```

## 11.2 Number entry and formatting

Support:

- decimal entry;
- negative values;
- scientific notation;
- engineering notation;
- fixed decimal format;
- automatic format;
- configurable displayed precision;
- degree and radian modes;
- optional grad mode only if included in the key/menu inventory.

Formatting must avoid displaying meaningless binary floating-point artifacts.

## 11.3 Core scientific functions

Implement at minimum:

```text
abs
sign
floor
ceil
round
fractional part
integer part
factorial
permutations
combinations
square
square root
nth root
reciprocal
power
exp
10^x
ln
log10
sin
cos
tan
asin
acos
atan
sinh
cosh
tanh
inverse hyperbolic functions
minimum
maximum
modulo
random number
```

Where a labelled TI-85 menu exposes additional functions, implement working equivalents.

## 11.4 Constants and conversions

Provide built-in constants through the relevant key or menu:

- π;
- e;
- physical constants appropriate to a scientific calculator;
- user-defined constants.

Provide unit conversion categories:

- length;
- area;
- volume;
- mass;
- temperature;
- time;
- speed;
- pressure;
- energy;
- power;
- angle.

All conversion factors must be defined in source data tables with unit tests.

## 11.5 Variables

Support named variables.

Required scalar types:

- real;
- complex;
- string;
- equation.

Required collection types:

- list;
- matrix;
- vector.

Provide:

- store;
- recall;
- overwrite;
- rename;
- delete;
- browse;
- memory usage display.

The implementation may use Free85-native object formats.

## 11.6 Complex numbers

Support:

- rectangular form;
- polar form;
- real part;
- imaginary part;
- magnitude;
- argument;
- conjugate;
- conversion between forms;
- arithmetic;
- powers and roots;
- appropriate complex results for negative square roots and similar operations.

## 11.7 Lists

Support:

- creation and editing;
- indexing;
- slicing if practical;
- element-wise arithmetic;
- sum;
- product;
- minimum;
- maximum;
- mean;
- median;
- standard deviation;
- sorting;
- cumulative sum;
- sequence generation.

## 11.8 Matrices

Support:

- matrix editor;
- dimensions;
- indexing;
- addition;
- subtraction;
- scalar multiplication;
- matrix multiplication;
- transpose;
- determinant;
- inverse;
- identity matrix;
- row operations;
- reduced row-echelon form;
- solving linear systems.

Set a documented maximum size based on RAM limits.

## 11.9 Vectors

Support:

- vector editor;
- two- and three-dimensional vectors;
- addition and subtraction;
- scalar multiplication;
- magnitude;
- normalisation;
- dot product;
- cross product;
- angle between vectors;
- component access.

## 11.10 Statistics

Support:

- editable data lists;
- one-variable statistics;
- two-variable statistics;
- mean;
- median;
- variance;
- sample standard deviation;
- population standard deviation;
- quartiles;
- minimum and maximum;
- linear regression;
- correlation;
- common additional regressions where reachable through built-in menus;
- scatter plots;
- histogram;
- box plot if feasible and menu-reachable.

All statistical formulas must document whether they use sample or population definitions.

## 11.11 Simultaneous equations

Provide a user interface for entering linear systems and solving them.

At minimum support:

- 2×2;
- 3×3;
- general `n×n` within memory limits;
- unique solution;
- no solution;
- underdetermined system.

## 11.12 Polynomial solver

Support polynomial roots for:

- degree 2;
- degree 3;
- degree 4;
- higher degree numerically where feasible.

Complex roots must be supported.

## 11.13 General solver

Provide numerical solving for:

```text
f(x) = 0
```

Required:

- initial estimate;
- optional lower and upper bounds;
- convergence tolerance;
- maximum iteration limit;
- clear failure state;
- display of residual.

Use a robust combination of bisection, secant and/or Newton methods rather than relying on only one algorithm.

## 11.14 Numerical calculus

Support:

- numerical derivative at a point;
- numerical definite integral;
- graph-based zero;
- graph-based minimum;
- graph-based maximum;
- graph intersection.

Expose configurable tolerance where the shifted `TOLER` function requires it.

## 11.15 Graphing

Support:

- multiple function slots;
- enable and disable individual functions;
- Cartesian function graphing;
- configurable graph window;
- axes;
- grid option;
- trace cursor;
- zoom in;
- zoom out;
- standard window;
- square aspect window;
- zero finding;
- minimum;
- maximum;
- intersection;
- numerical derivative;
- numerical integral;
- graph redraw and cancellation.

Additional graph types should be implemented only when required by the built-in menu inventory.

Graph evaluation must not crash on:

- discontinuities;
- overflow;
- domain errors;
- vertical asymptotes;
- values outside screen range.

## 11.16 Table

Provide a table of function values with:

- configurable start;
- configurable step;
- scrolling;
- multiple enabled functions;
- undefined-value indication.

## 11.17 Strings

Support enough string functionality to make the built-in string menu useful:

- string literals;
- concatenation;
- length;
- substring;
- character extraction;
- numeric-to-string conversion;
- string-to-number conversion;
- comparison.

## 11.18 Catalog and custom menu

`CATALOG` must show all callable functions and commands in alphabetical or grouped form.

The custom menu must allow users to assign commonly used functions to menu slots.

Menu assignments may use Free85-native identifiers.

## 11.19 Programming

The physical `PRGM` key must lead to a working programming facility.

It does not need TI-BASIC compatibility.

Implement a compact Free85 language with at least:

```text
assignment
expressions
Disp
Input
If / Else / End
While / End
For / End
Goto and labels, optional
function calls
list access
matrix access
graph commands
program calls
Stop
Return
```

Provide:

- program list;
- create;
- rename;
- edit;
- run;
- stop;
- delete;
- syntax-error reporting;
- line or statement indication for errors.

The language must use the same expression engine as the home calculator.

No external program loading is required.

## 11.20 Memory and system

Provide:

- memory usage;
- variable management;
- reset settings;
- reset all user data;
- contrast adjustment;
- display mode settings;
- angle mode;
- numeric format;
- firmware version;
- diagnostics;
- power off.

------

# 12. Numeric representation

Create a numeric abstraction so that internal representation can be replaced without rewriting applications.

Recommended initial design:

```text
sign
signed decimal exponent
12–14 significant decimal digits
special-state flags
```

A packed BCD representation is preferred for calculator-like decimal behaviour.

Required operations:

```text
construct from integer
parse decimal text
format decimal text
compare
negate
absolute value
add
subtract
multiply
divide
integer power
general power
square root
normalise
round
```

Transcendental functions may use:

- range reduction;
- polynomial approximations;
- rational approximations;
- CORDIC;
- Newton iteration.

Document:

- precision;
- exponent range;
- rounding mode;
- overflow behaviour;
- underflow behaviour;
- domain errors;
- complex promotion rules.

Do not expose internal rounding garbage to the user.

If implementing decimal floating point blocks progress, a temporary binary software floating-point backend is acceptable only when:

- the abstraction remains replaceable;
- displayed results are rounded cleanly;
- numeric tests pass;
- the limitation is documented.

------

# 13. Parser and evaluator

Implement a real tokenizer and parser. Do not evaluate expressions by ad hoc string scanning.

Recommended precedence:

```text
assignment
logical OR
logical AND
comparison
addition/subtraction
multiplication/division
power
unary
postfix
primary
```

Explicitly test:

```text
2+3*4
(2+3)*4
-2^2
(-2)^2
2^-3
2^3^2
1E-3
2(3+4), if implicit multiplication is enabled
```

The parser must support:

- function calls;
- parentheses;
- lists;
- matrices;
- variables;
- assignment;
- complex literals or constructors;
- indexing.

Use a bounded evaluation stack and return structured errors rather than corrupting memory.

------

# 14. Object store and RAM management

Create a Free85-native persistent RAM structure.

Suggested layout:

```text
system state
event queues
screen buffers
expression workspace
numeric stack
object directory
object heap
program storage
graph definitions
history
free space
```

Every stored object must have:

```text
type
name
length
flags
payload
checksum or integrity field, optional
```

Required object types:

```text
real
complex
string
list
matrix
vector
equation
program
settings
custom menu
```

Memory management must support:

- allocation;
- release;
- compaction or a robust free-list strategy;
- corruption detection;
- clean reset;
- out-of-memory errors.

Never silently overwrite user data.

------

# 15. Error model

Define stable Free85 error identifiers.

At minimum:

```text
SYNTAX
DOMAIN
DIVIDE_BY_ZERO
OVERFLOW
UNDERFLOW
DIMENSION
SINGULAR_MATRIX
UNDEFINED_VARIABLE
TYPE_MISMATCH
OUT_OF_MEMORY
INVALID_NAME
NON_CONVERGENCE
INTERRUPTED
CORRUPT_DATA
```

Errors must:

- preserve calculator stability;
- show an understandable message;
- permit dismissal;
- return the user to an editable state where practical.

Exact TI wording is not required.

------

# 16. Clean-room validation model

## 16.1 Sources of expected behaviour

Use three validation sources:

1. The physical TI-85 key labels and published user-facing feature descriptions.
2. Privately observed behaviour of a lawfully obtained original ROM.
3. Independent mathematical reference results.

Do not use TI disassembly as implementation source.

Do not copy:

- ROM routines;
- binary tables;
- fonts;
- artwork;
- menu screen layouts;
- exact screen text beyond unavoidable short mathematical terms.

## 16.2 Private ROM oracle

Support an optional environment variable:

```text
TI85_ORACLE_ROM=/private/path/TI85.ROM
```

Oracle tools must:

- operate only when the file exists locally;
- never copy it;
- never place it in generated output;
- never print its contents;
- never upload results containing ROM bytes;
- clearly skip oracle tests when absent.

The oracle runner should:

1. Start the original ROM.
2. Apply a defined key sequence.
3. Capture final framebuffer and timing metadata.
4. Start Free85.
5. Apply the equivalent key sequence.
6. compare user-visible behaviour.
7. Save only human-readable observations and test results.

Pixel equality is not required.

## 16.3 Public expected results

Public tests should use semantic expectations:

```yaml
id: calc.precedence.001
keys: [2, PLUS, 3, MULTIPLY, 4, ENTER]
expected:
  display_contains: "14"
id: trig.sin.radian.001
setup:
  angle_mode: radian
keys: [SIN, 1, CLOSE_PAREN, ENTER]
expected:
  numeric: 0.8414709848
  tolerance: 1e-9
```

The public test corpus must not depend on TI-owned files.

------

# 17. Automated test harness

Create a key-sequence test DSL.

Example:

```js
await runFree85Case({
  id: "graph.linear.001",
  keys: [
    "GRAPH",
    "F1",
    "X-VAR",
    "+",
    "1",
    "ENTER",
    "GRAPH"
  ],
  assertions: {
    screenMode: "graph",
    litPixelsGreaterThan: 20,
    noCrash: true
  }
});
```

Required test categories:

- ROM size and boot;
- reset vectors;
- interrupt stability;
- all physical keys recognised;
- all shifted functions registered;
- all alpha characters available;
- menu reachability;
- expression editing;
- arithmetic;
- scientific functions;
- formatting;
- variables;
- lists;
- matrices;
- vectors;
- complex arithmetic;
- statistics;
- solvers;
- graphing;
- programs;
- memory exhaustion;
- recovery from errors;
- repeated reset;
- long-running stability.

Test the firmware through the machine layer, not by directly calling internal firmware routines wherever practical.

------

# 18. Coverage tracking

`features.yaml` must be the source of truth.

Example:

```yaml
- id: math.sin
  surface:
    key: SIN
    modifier: none
  status: complete
  implementation: math/trig.asm
  tests:
    - trig.sin.zero
    - trig.sin.quarter_pi
    - trig.sin.negative
    - trig.sin.large_range
    - trig.sin.domain_complex
```

Allowed status values:

```text
unplanned
planned
implemented
tested
complete
```

A feature is `complete` only when:

1. It is reachable through the keypad or a reachable menu.
2. It performs a meaningful operation.
3. It handles normal input.
4. It handles at least one invalid or edge case.
5. It has automated tests.
6. It is documented.

Generate a coverage report containing:

- physical keys covered;
- shifted functions covered;
- alpha mappings covered;
- menu items covered;
- applications covered;
- tests passing;
- estimated ROM usage;
- estimated RAM usage.

The final target is:

```text
100% physical keys
100% printed shifted functions
100% built-in reachable menu entries
100% completed features with tests
```

------

# 19. Browser integration

When Free85 reaches the diagnostic-ROM milestone:

1. Make the TI-85 page boot `FREE85.ROM` by default.
2. Keep the local ROM file selector as an optional compatibility/testing feature.
3. Label the default clearly as open Free85 firmware.
4. Label locally selected firmware as user-supplied.
5. Never automatically request `TI85.ROM`.
6. Do not send selected ROM bytes to any server.
7. Store user-selected firmware in IndexedDB only if the user explicitly chooses persistence.
8. Provide a control to forget locally stored firmware and return to Free85.

The default website must remain fully useful without any proprietary ROM.

------

# 20. Implementation phases

## Phase 0: Specification and baseline

Deliver:

- `product.md`;
- complete physical key inventory;
- `keymap.yaml`;
- initial `features.yaml`;
- firmware build skeleton;
- regression tests proving existing machines still work.

Acceptance:

- every browser keypad key appears in `keymap.yaml`;
- no repository write outside the local working tree;
- no TI ROM required.

## Phase 1: Bootable diagnostic ROM

Implement:

- reset;
- stack;
- memory initialisation;
- LCD initialisation;
- font;
- keypad scanning;
- timer;
- ON key;
- simple menu;
- hardware diagnostics.

Display:

```text
FREE85
OPEN Z80 CALCULATOR
```

Provide a keypad diagnostic screen showing the last key pressed.

Acceptance:

- 128 KB ROM builds;
- emulator boots it;
- all physical keys register;
- screen remains stable for at least several emulated minutes;
- reset works repeatedly.

## Phase 2: UI kernel

Implement:

- event queue;
- screen framework;
- menu framework;
- text editor;
- cursor;
- 2ND state;
- ALPHA state;
- soft keys;
- error dialogs;
- home screen.

Acceptance:

- all keys lead to registered actions;
- unfinished actions show an explicit “Not implemented” development message only during this phase;
- no silent dead keys.

## Phase 3: Numeric core

Implement:

- numeric type;
- parsing;
- formatting;
- add;
- subtract;
- multiply;
- divide;
- compare;
- square;
- square root;
- powers;
- error handling.

Acceptance:

- arithmetic vector suite passes;
- clean decimal display;
- overflow and divide-by-zero are recoverable.

## Phase 4: Expression engine

Implement:

- lexer;
- parser;
- evaluator;
- variables;
- assignment;
- history;
- previous answer.

Acceptance:

- precedence tests pass;
- editing and reevaluation work;
- malformed expressions do not crash.

## Phase 5: Scientific functions

Implement:

- logs;
- exponentials;
- trig;
- inverse trig;
- hyperbolic functions;
- factorial;
- combinations;
- permutations;
- constants;
- conversions.

Acceptance:

- independent numeric vectors pass within documented tolerance;
- degree/radian modes work.

## Phase 6: Graphing and numerical tools

Implement:

- equation editor;
- graph window;
- plotting;
- trace;
- zoom;
- table;
- roots;
- extrema;
- intersection;
- derivative;
- integral;
- general solver;
- tolerance settings.

Acceptance:

- representative continuous and discontinuous functions work;
- graph operations can be cancelled;
- domain errors do not crash plotting.

## Phase 7: Complex, list, matrix and vector features

Implement all required collection types and editors.

Acceptance:

- every corresponding physical key and menu is functional;
- dimension and singularity errors are handled;
- memory limits are documented.

## Phase 8: Statistics and specialist solvers

Implement:

- one-variable statistics;
- two-variable statistics;
- regression;
- plots;
- simultaneous-equation solver;
- polynomial solver.

Acceptance:

- independent reference data sets pass;
- sample/population distinctions are documented.

## Phase 9: Strings, catalog and custom menu

Implement:

- string type;
- string functions;
- catalog;
- custom menu assignment.

Acceptance:

- every catalog entry is callable;
- custom menu persists in RAM state.

## Phase 10: Programming environment

Implement the Free85 language, editor and runner.

Acceptance:

- programs can be created, edited, run and deleted;
- loops, conditions and expressions work;
- runaway programs can be stopped with ON or another defined key;
- program errors identify the location.

## Phase 11: Complete key and menu parity

Audit:

- physical keys;
- 2ND functions;
- ALPHA functions;
- every built-in menu;
- every submenu;
- every application.

No placeholders may remain.

Acceptance:

```text
key coverage: 100%
shifted coverage: 100%
menu coverage: 100%
completed features tested: 100%
```

## Phase 12: Optimisation and release

Optimise:

- ROM banking;
- RAM use;
- drawing;
- parser speed;
- graph speed;
- transcendental functions.

Deliver:

- open ROM;
- source;
- build instructions;
- licence notices;
- feature coverage report;
- known limitations;
- browser default integration.

------

# 21. Development priorities

Prioritise functionality in this order:

```text
stability
correctness
testability
complete keypad reachability
clear errors
performance
visual polish
```

Do not optimise prematurely.

Do not add compatibility hacks for original applications.

Do not reproduce undocumented TI internals merely because the original ROM uses them.

------

# 22. Coding standards

Firmware code must:

- use named constants;
- avoid unexplained numeric addresses;
- document register inputs and outputs;
- document clobbered registers;
- keep interrupt-critical sections short;
- avoid unbounded recursion;
- check buffer lengths;
- check object dimensions;
- check available memory;
- avoid self-modifying code unless absolutely necessary and documented;
- use consistent bank-call conventions.

JavaScript integration code must:

- use ES modules;
- follow existing repository style;
- use `node:test` where already standard;
- avoid unnecessary browser dependencies;
- keep ROM bytes local;
- provide useful errors.

------

# 23. Performance targets

Initial targets:

- splash screen visible promptly after reset;
- ordinary key response within one display frame;
- basic arithmetic subjectively immediate;
- typical graph redraw within a few seconds of emulated time;
- UI remains interruptible during long operations;
- no memory leak across repeated calculations;
- no crash after 10,000 automated key events.

Correctness takes precedence over exact timing parity.

------

# 24. Definition of done

Free85 is complete when:

1. The generated ROM is exactly 131,072 bytes.
2. It boots from reset in the existing TI-85 machine layer.
3. It requires no proprietary firmware.
4. Every physical keypad key has a working normal action.
5. Every printed shifted function has a working equivalent action.
6. Every alpha entry works.
7. Every built-in reachable menu item performs a real operation.
8. The home calculator supports scientific expressions and variables.
9. Graphing, tables, statistics, matrices, vectors, complex numbers, lists, solvers and programming work.
10. No feature claims compatibility with TI programs or files.
11. The original ROM is not shipped, fetched or required.
12. Public automated tests pass.
13. Feature coverage reports 100%.
14. Existing ZX Spectrum, CP/M and TRS-80 regression tests still pass.
15. The website boots Free85 by default and remains usable without user-supplied firmware.

------

# 25. First Codex task

Begin only with **Phase 0 and Phase 1**.

Do not attempt the complete calculator in one change.

For the first implementation cycle:

1. Inspect the existing TI-85 machine layer and browser keypad.
2. Generate the complete physical key inventory.
3. Create `keymap.yaml` and `features.yaml`.
4. Establish the assembler build.
5. Build a valid 128 KB Free85 ROM.
6. Implement reset, LCD initialisation and keypad scanning.
7. Display the Free85 splash screen.
8. Add a diagnostic screen that displays every key press.
9. Add headless boot and keypad tests.
10. Report exact ROM usage, RAM usage, test results and remaining limitations.

Do not change the website’s default ROM behaviour until the diagnostic ROM boots reliably and passes its tests.

This gives Codex an executable project definition while preventing it from trying to build the entire firmware in one uncontrolled pass.