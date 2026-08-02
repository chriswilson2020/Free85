# Chapter 8: Physical and User Constants and Conversions

Two shifted keys turn the calculator into a small reference book. [2nd] [4]
(the `CONS` legend) opens the constants menu, holding the mathematical and
physical constants along with the constants you define yourself, and
[2nd] [5] (the `CONV` legend) opens the conversions menu, holding a pair
of unit-conversion functions for each of eleven categories. Both menus
work like the `MATH` menu of Chapter 3 (Mathematics, Calculus, and
Comparisons): press the soft key under an item to insert it into your
entry line and return to the home screen, or [MORE] for the next page.
As everywhere else, whatever a menu inserts can also be typed letter by
letter with [ALPHA], or pasted from the catalog (Chapter 1: Operating the
Calculator).

## The constants menu

Press [2nd] [4] and the `CONSTANTS` menu lists its first page:

![The constants menu opened with 2nd 4](images/ch08-constants-menu.png)

Page one carries `PI`, `E`, `LIGHT`, `GRAV`, and `PLANCK` on [F1] through
[F5]; press [MORE] for `BOLTZ` and `AVOG`. A second [MORE] turns past
them to the `USER CONSTANTS` screen of the next section, and a third
brings the first page back around. Each menu item is a plain name: the
menu inserts it, and the name on its own evaluates to the stored value.
Every value below is quoted from the machine:

- **`PI`**, the circle constant: `PI` answers `= 3.1415926535898`. It is
  the same `PI` the `π` legend on [2nd] [^] types.
- **`E`**, Euler's number: `E` answers `= 2.718281828459`. Standing alone,
  `E` is this constant; between digits it is the exponent marker typed by
  [EE], as chapter 3 explains, so `1E3` is a thousand, not a multiple
  of Euler's number.
- **`LIGHT`**, the speed of light in a vacuum, in metres per second:
  `LIGHT` answers `= 299792458`.
- **`GRAV`**, standard gravity, in metres per second squared: `GRAV`
  answers `= 9.80665`.
- **`PLANCK`**, the Planck constant, in joule seconds: `PLANCK` answers
  `= 6.62607015E-34`.
- **`BOLTZ`**, the Boltzmann constant, in joules per kelvin: `BOLTZ`
  answers `= 1.380649E-23`.
- **`AVOG`**, the Avogadro constant, per mole: `AVOG` answers
  `= 6.02214076E23`.

A constant behaves like any other number in an expression. `2*LIGHT`
answers `= 599584916`, and `GRAV*70` answers `= 686.4655`, the weight in
newtons of a 70 kilogram mass.

## User constants

The menu's last page is not a menu but a manager. Press [MORE] twice
from the first page and the `USER CONSTANTS` screen opens, with a count
of your constants at the top right and the soft keys
`NEW EDIT NAME USE DEL`. On a fresh machine the count is `0` and the
middle of the screen says `NO USER CONSTANTS`.

To create a constant, press [F1] (`NEW`). The `CONSTANT NAME` prompt
opens with the hint `ENTER SAVE EXIT`, and [ALPHA] works differently
here than on the home screen: one press keeps letter entry on until the
next press releases it, so `RATE` is [ALPHA] [R] [A] [T] [E]. Press
[ENTER] and the `CONSTANT VALUE` prompt follows; type `12.5` (pressing
[ALPHA] first to release the letter lock) and [ENTER] saves the
constant and returns to the screen:

![The USER CONSTANTS screen holding RATE](images/ch08-user-constants.png)

The count now reads `1` above the name `RATE` and the value `12.5`. A
name is one to seven letters, and the value line takes a whole
expression, evaluated when you save: a constant named `TAU` with its
value typed as `2*PI` is stored as `6.2831853071796`.

The new name then works everywhere the built-in names do. Type `RATE`
with [ALPHA] on the home screen and it answers `= 12.5`, exactly as
`GRAV` answers its value.

The screen shows one constant at a time; when you hold several, [▲] and
[▼] (or [◀] and [▶]) step through them, [MORE] carries on around to the
menu's first page, and [EXIT] returns home. The other soft keys work on
the constant on show:

- **`EDIT`** ([F2]) reopens the `CONSTANT VALUE` prompt with an empty
  line: type the new value and [ENTER] saves it, so `8` [ENTER] leaves
  `RATE` reading `8`.
- **`NAME`** ([F3]) opens the `RENAME CONSTANT` prompt for a new name;
  the value stays.
- **`USE`** ([F4]) drops the constant's name into the home entry line
  and returns home, saving the letter-by-letter typing: with `RATE`
  holding `12.5`, `USE` and then [×] [2] [ENTER] answers `= 25`.
- **`DEL`** ([F5]) removes the constant on show.

A request the screen cannot honour answers the full-screen notice
`CONSTANT ERROR`: accepting an empty name with [ENTER], saving a value
under a name that is not one to seven letters, or renaming onto a name
already taken. [CLEAR] or [EXIT] dismisses the notice to the home
screen.

Each user constant is an object in the typed store of Chapter 2
(Variables and Stored Data): the memory browser of Chapter 18 (Memory
Management) lists `RATE` with `TYPE CONSTANT`, and the store's
persistence carries your constants through a restart. Appendix A
catalogues this workflow as `create-user-constant`,
`edit-user-constant`, `name-user-constant`, and `delete-user-constant`.

## The conversions menu

Press [2nd] [5] and the `CONVERSIONS` menu pages through twenty-two
functions, five at a time. Each is named source-unit-first, so `INCM(`
reads "inches to centimetres" and `CMIN(` the reverse, and each category
contributes one such pair:

| Category | Functions | Units |
| --- | --- | --- |
| Length | `CMIN(`, `INCM(` | centimetres and inches |
| Area | `SQMFT(`, `SQFTM(` | square metres and square feet |
| Volume | `LGAL(`, `GALL(` | litres and US gallons |
| Mass | `KGLB(`, `LBKG(` | kilograms and pounds |
| Temperature | `CTOF(`, `FTOC(` | degrees Celsius and Fahrenheit |
| Time | `MINS(`, `SMIN(` | minutes and seconds |
| Speed | `KMHMPH(`, `MPHKMH(` | kilometres per hour and miles per hour |
| Pressure | `BARPSI(`, `PSIBAR(` | bar and pounds per square inch |
| Energy | `JCAL(`, `CALJ(` | joules and calories |
| Power | `WHP(`, `HPW(` | watts and horsepower |
| Angle | `RAD(`, `DEG(` | degrees and radians |

The menu lists them in exactly this order, reading down the table row by
row: page one starts with `CMIN(` and page five holds `RAD(` and `DEG(`.

A conversion is an ordinary one-argument function. To convert the boiling
point of water, press [2nd] [5] [MORE] [F4] to insert `CTOF(`, then type
`100)` and press [ENTER]:

![CTOF(100) evaluated on the home screen](images/ch08-conversion-example.png)

`CTOF(100)` answers `= 212`. More examples, one from each category:

- `INCM(1)` answers `= 2.54`: one inch in centimetres.
- `SQMFT(1)` answers `= 10.76391041671`: a square metre in square feet.
- `GALL(1)` answers `= 3.785411784`: a US gallon in litres.
- `KGLB(1)` answers `= 2.2046226218488`: a kilogram in pounds.
- `FTOC(32)` answers `= 0`: temperature conversions include the offset,
  not just a scale factor, so `CTOF(0)` answers `= 32`.
- `MINS(2)` answers `= 120` and `SMIN(90)` answers `= 1.5`.
- `KMHMPH(100)` answers `= 62.137119223733` and `MPHKMH(100)` answers
  `= 160.9344`.
- `BARPSI(1)` answers `= 14.503773773022` and `PSIBAR(1)` answers
  `= 0.068947572931678`.
- `JCAL(1)` answers `= 0.23900573613767` and `CALJ(1)` answers `= 4.184`.
- `WHP(1000)` answers `= 1.341022089595`: a kilowatt in horsepower; the
  reverse `HPW(1)` answers `= 745.69987158229`.
- `RAD(180)` answers `= 3.1415926535898` and `DEG(PI)` answers `= 180`,
  the same angle converters chapter 3 uses alongside the `RAD`/`DEG`
  angle mode.

Because the arithmetic is the fourteen-digit decimal of chapter 3, a
conversion and its inverse can fall just short of an exact round trip:
`CMIN(2.54)` answers `= 0.99999999999999`, not `= 1`. The residue is the
true product of the stored conversion factors, and it is why a chain of
conversions is best done in one expression rather than by retyping rounded
intermediate results.

Conversions nest and combine like any function: `CTOF(FTOC(32))` answers
`= 32`, and `KMHMPH(3.6)` answers `= 2.2369362920544`, converting a metre
per second expressed as `3.6` kilometres per hour.
