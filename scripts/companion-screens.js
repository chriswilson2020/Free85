import { mkdirSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { Free85Harness } from "../test/helpers/free85-harness.js";
import { renderLcdPng } from "../test/helpers/lcd-visual.js";

const OUT_DIR = fileURLToPath(new URL("../docs/companion/images/", import.meta.url));

// Screen captures for Explorations with Free85. Each case boots a fresh
// machine and taps the listed keys; a number in the key list means "run that
// many frames" and lets slow work (an incremental plot, a zoom replot)
// finish before the next key or the capture. Names are kebab-case, prefixed
// coNN for the companion chapter they belong to, and are referenced from the
// Markdown chapters in docs/companion/.

// Keys for typing one program-editor line exactly as chapter 3 instructs:
// letters are [ALPHA] plus the key carrying the letter, a space is [2nd] [0],
// "->" is [STO▶], everything else is its own key; [ENTER] moves to the next
// line.
const PROGRAM_LETTER_KEYS = {
  A: "LOG", B: "SIN", C: "COS", D: "TAN", E: "^", F: "LN", G: "EE", H: "(",
  I: ")", J: "/", K: "X^2", L: "7", M: "8", N: "9", O: "*", P: ",", Q: "4",
  R: "5", S: "6", T: "-", U: "1", V: "2", W: "3", X: "+", Y: "0", Z: "."
};

function programLineKeys(text) {
  const keys = [];
  let index = 0;
  while (index < text.length) {
    if (text.startsWith("->", index)) { keys.push("STO"); index += 2; continue; }
    const character = text[index];
    if (character === " ") keys.push("2ND", "0");
    else if (/[A-Z]/.test(character)) keys.push("ALPHA", PROGRAM_LETTER_KEYS[character]);
    else keys.push(character);
    index += 1;
  }
  keys.push("ENTER");
  return keys;
}

// Section 3.5 scores a trial line against the bean data by hand. The slope
// lives in M and the intercept in B, so the program contains no particular
// line and scores whichever one the reader has just stored. The six heights
// are written into lines 2 to 4, two points per line, because 48 characters
// is as many as will fit.
const CO03_SSD_LINES = ["0->S", "S+(B+M*1-7)^2+(B+M*2-7)^2->S",
  "S+(B+M*3-10)^2+(B+M*4-12)^2->S", "S+(B+M*5-13)^2+(B+M*6-17)^2->S",
  "DISP S", "STOP"];
// Store an intercept into B and a slope into M, then type and run the score.
const co03Score = (intercept, slope) => [
  ...String(intercept).split(""), "STO", "ALPHA", "SIN", "ENTER", 200, "CLEAR", 30,
  ...String(slope).split(""), "STO", "ALPHA", "8", "ENTER", 200, "CLEAR", 30,
  "PRGM", 60, "F1", 120,
  ...CO03_SSD_LINES.flatMap(programLineKeys), 200, "F2", 12000];

const CO03_P1_LINES = ["0->S", "FOR A,1,9", "S+RANDI(0,1)->S", "END", "DISP S", "STOP"];
const CO03_P2_LINES = ["36->N", "0->S", "WHILE N", "S+INT(RANDI(1,6)/6)->S",
  "N-1->N", "END", "DISP S", "STOP"];

// Chapter 4's four Riemann-sum programs: left, right, and midpoint sums with
// four slices, then the midpoint sum with eight.
const CO04_P1_LINES = ["0->S", "FOR A,0,3", "S+EVAL(A/2)->S", "END", "DISP S/2", "STOP"];
const CO04_P2_LINES = ["0->S", "FOR A,1,4", "S+EVAL(A/2)->S", "END", "DISP S/2", "STOP"];
const CO04_P3_LINES = ["0->S", "FOR A,1,4", "S+EVAL((2*A-1)/4)->S", "END", "DISP S/2", "STOP"];
const CO04_P4_LINES = ["0->S", "FOR A,1,8", "S+EVAL((2*A-1)/8)->S", "END", "DISP S/4", "STOP"];

// Chapter 7's differential-equation runs. Seeding stores the initial y into
// the variable Y before the mode is entered, because the mode freezes that
// value when it first starts; DEQ_MODE then walks the graph mode page to the
// DifEq entry and drops back to the home screen with the entry line empty.
const co07Seed = (value) => [
  ...String(value).split("").map((character) => (character === "-" ? "(-)" : character)),
  "STO", "ALPHA", "0", "ENTER", 120, "CLEAR", 30
];
const CO07_DEQ_MODE = ["GRAPH", 1200, "2ND", "MORE", 90, "MORE", "MORE", 90,
  "F4", 2500, "EXIT", 90];
// The tank of sections 7.1 to 7.5: dy/dx = -.15*Y seeded at 9.
const CO07_TANK = [...co07Seed(9), ...CO07_DEQ_MODE,
  "(-)", ".", "1", "5", "*", "ALPHA", "0", "GRAPH", 6000];
// Section 7.4's Euler walk and section 7.5's improved-Euler pair, whose step
// lives in P3 because eight lines cannot hold driver and method together.
const CO07_P1_LINES = ["9->Y", ".5->H", "7->N", "WHILE N", "Y+H*EVAL(0)->Y",
  "N-1->N", "END", "DISP Y"];
const CO07_P2_LINES = ["9->Y", ".5->H", "7->N", "WHILE N", "CALL 3",
  "N-1->N", "END", "DISP Y"];
const CO07_P3_LINES = ["EVAL(0)->K", "Y+H*K->Y", "Y+H*(EVAL(0)-K)/2->Y", "RETURN"];

// Chapter 2 section 2.2's two solves. The same one-per-cent nudge to a
// right-hand side barely moves a well-conditioned system and sends a
// near-parallel one across the axis, from X 5 to X -5.
const co02Solve = (rows) => ["2ND", "STAT", 60,
  ...rows.flatMap((value) => [
    ...String(value).split("").map((character) => (character === "-" ? "(-)" : character)),
    "ENTER"]),
  "F1", 1500];

// Chapter 1 section 1.4's rational function. (X^2+1)/(X-1) divides out to
// X+1 with a remainder of 2/(X-1), so the curve closes on the line X+1 far
// out and runs away at X=1, where the table reads UNDEF.
const CO01_RATIONAL = ["(", "X-VAR", "X^2", "+", "1", ")", "/",
  "(", "X-VAR", "-", "1", ")"];

// Chapter 5 section 5.2's Newton's method. EVAL( and NDER( both read the
// stored equation, so line 4 is the method entire and the program names no
// function. Line 2 is the step count, edited between runs to watch the
// correct digits double. Each step evaluates the stored cubic twice, so the
// run needs generous settle frames.
const co05Newton = (start, steps) => ["X-VAR", "^", "3", "-", "2", "*",
  "X-VAR", "-", "5", "GRAPH", 1500, "EXIT", 200, "CLEAR", 30,
  "PRGM", 60, "F1", 120,
  ...[`${start}->R`, `${steps}->N`, "WHILE N", "R-EVAL(R)/NDER(R)->R",
    "N-1->N", "END", "DISP R", "STOP"].flatMap(programLineKeys), 200,
  "F2", 20000 + steps * 12000];

// Chapter 5 section 5.9's geometric impersonators against 1/(1+X). Outside
// the interval of convergence the longer polynomial is the worse of the two,
// which is the opposite of what the sine slots do.
const CO05_GEOMETRIC = ["1", "/", "(", "1", "+", "X-VAR", ")", "GRAPH", 2500,
  "2ND", "2", 60, "1", "-", "X-VAR", "+", "X-VAR", "X^2", "-", "X-VAR", "^",
  "3", "GRAPH", 2500,
  "2ND", "3", 60, "1", "-", "X-VAR", "+", "X-VAR", "X^2", "-", "X-VAR", "^",
  "3", "+", "X-VAR", "^", "4", "-", "X-VAR", "^", "5", "GRAPH", 3000];

// Chapter 7 section 7.6's two growth models, both seeded at 1 with a
// ceiling of 10. The Gompertz needs a logarithm at every one of the 127
// Euler steps, which makes it the slowest thing in the book: its table
// wants around 60000 frames to fill a page, against 3000 for the logistic.
const CO07_LOGISTIC = [".", "5", "*", "ALPHA", "0", "*", "(", "1", "-",
  "ALPHA", "0", "/", "1", "0", ")"];
const CO07_GOMPERTZ = [".", "3", "*", "ALPHA", "0", "*", "LN", "1", "0", "/",
  "ALPHA", "0", ")"];

// Chapter 4's two limit specimens, stored into Y1 with [GRAPH]. Both are
// trigonometric and therefore slow, so callers add their own settle frames.
const CO04_SINX = ["SIN", "X-VAR", ")", "/", "X-VAR", "GRAPH"];
const CO04_SINRECIP = ["SIN", "1", "/", "X-VAR", ")", "GRAPH"];

// Chapter 4 spells its calculus commands letter by letter the way the text
// instructs, so the captures type them the same way rather than by name.
function co04Spell(text) {
  const keys = [];
  for (const character of text) {
    if (/[A-Z]/.test(character)) keys.push("ALPHA", PROGRAM_LETTER_KEYS[character]);
    else if (character === "-") keys.push("(-)");
    else keys.push(character);
  }
  return keys;
}

// Chapter 5 spells FNINT( letter by letter on the home screen: [ALPHA]
// plus the key carrying each letter, as the chapter instructs.
const FNINT_KEYS = ["ALPHA", "LN", "ALPHA", "9", "ALPHA", ")", "ALPHA", "9",
  "ALPHA", "-"];

// Keys for typing a run of matrix or vector cells, [ENTER] after each value;
// a minus sign is the [(-)] key, as chapter 6 instructs.
function cellKeys(values) {
  return values.flatMap((value) => [
    ...String(value).split("").map((character) => (character === "-" ? "(-)" : character)),
    "ENTER"
  ]);
}

// Chapter 6 section 6.3 reaches the ill-conditioned COND through the whole
// section: the well-conditioned norms and COND, the solve with 5, 4, 4, the
// 5.001 nudge, then the near-dependent retype and its COND. The perturbed
// solve continues from the same state.
const CO06_COND_KEYS = ["2ND", "7", 30, "+", "X-VAR", "+", "X-VAR",
  ...cellKeys([1, 4, 0, 2, 1, 1, 0, 1, 3]),
  "MORE", "MORE", "MORE", 30,
  "F1", 300, "F2", 300, "F3", 300, "F4", 600,
  "ALPHA", 30, "+", "X-VAR", "-", "X-VAR", 30,
  ...cellKeys([5, 4, 4]),
  "ALPHA", 30, "EXIT", 30, "2ND", "7", 30, "MORE", 30, "F5", 600,
  "RIGHT", "RIGHT", 30, "RIGHT", 30,
  "ALPHA", 30, ...cellKeys(["5.001"]), 30,
  "ALPHA", 30, "F5", 600,
  "RIGHT", "RIGHT", 30, "RIGHT", 30,
  "ALPHA", "ALPHA", 30,
  ...cellKeys([1, 1, 1, 1, "1.001", 1, 1, 1, "1.001"]),
  "MORE", "MORE", 30, "F4", 900];

// Chapter 8 section 8.1 keeps the pendulum's elliptic integrand in the graph
// slot with the squared modulus in the variable K, so a new amplitude costs
// one store; the ratio probe divides twice the integral by pi and the period
// multiplies it by four times the root of L over g.
const CO08_PENDULUM = ["2", "*", "2ND", "^", "*", "2ND", "X^2", "2", ".", "5",
  "/", "9", ".", "8", ")", "ENTER", 300, "CLEAR", 30,
  "1", "/", "2ND", "X^2", "1", "-", "ALPHA", "X^2", "*", "SIN", "X-VAR", ")",
  "X^2", ")", "GRAPH", 12000, "EXIT", 120, "CLEAR", 30];
const CO08_RATIO = ["2", "*", ...FNINT_KEYS, "(", "0", ",", "2ND", "^", "/",
  "2", ")", "/", "2ND", "^", "ENTER", 3000, "CLEAR", 30];
const co08Modulus = (halfAngleKeys) => [...halfAngleKeys, "X^2", "STO",
  "ALPHA", "X^2", "ENTER", 60, "CLEAR", 30];

// Chapter 8 section 8.2's two summing programs, and section 8.3's Euler shot.
// Section 8.3's tolerance-driven variant: counts up instead of down and
// stops when the next term falls below a ten thousandth. The editor cannot
// type "<", so the test is INT(1E4/N^2), which is nonzero exactly while the
// term is still worth adding.
const CO08_TOLERANCE_LINES = ["0->S", "1->N", "WHILE INT(1E4/N^2)",
  "S+1/N^2->S", "N+1->N", "END", "DISP S", "STOP"];
const CO08_P1_LINES = ["0->S", "10->N", "WHILE N", "S+1/N^2->S", "N-1->N",
  "END", "DISP S", "STOP"];
const CO08_P2_LINES = ["0->S", "6->N", "WHILE N", "(1+S)/4->S", "N-1->N",
  "END", "DISP S", "STOP"];
const CO08_P3_LINES = ["10->Y", "20/127->H", "127->N", "WHILE N",
  "Y+H*EVAL(0)->Y", "N-1->N", "END", "DISP Y"];

// Section 8.3's reed bed: dy/dx = -.02*Y^2 seeded at 10 milligrams per litre,
// entered the same way chapter 7 enters the DifEq mode.
const CO08_REED = ["1", "0", "STO", "ALPHA", "0", "ENTER", 120, "CLEAR", 30,
  ...CO07_DEQ_MODE, "(-)", ".", "0", "2", "*", "ALPHA", "0", "X^2",
  "GRAPH", 9000];

// Section 8.4's vector work runs in ANGLE DEG, and leaves the editor between
// sub-explorations because re-entry restores register A, component 1, and the
// first soft-key page in one move.
const CO08_DEGREES = ["2ND", "MORE", 90, "F1", 60, "EXIT", 60];
const co08Components = (values) => values.flatMap((value) => [
  ...String(value).split("").map((character) => (character === "-" ? "(-)" : character)),
  "ENTER"
]);

export const SCREEN_CASES = [
  // Chapter 1 section 1.1: the cubic X^3-4*X in the standard window.
  { name: "co02-well-conditioned", keys: co02Solve([1, 2, 8.1, 3, -1, 3]) },
  { name: "co02-ill-conditioned", keys: co02Solve([1, 2, 8.1, 1.01, 2, 8.05]) },
  { name: "co01-cubic-window", keys: ["X-VAR", "^", "3", "-", "4", "*", "X-VAR", "GRAPH", 900] },
  // Chapter 1 section 1.4: the rational function's two branches, with the
  // near-vertical strokes either side of X=1 that are the plotter joining
  // samples a very long way apart.
  { name: "co01-rational", keys: [...CO01_RATIONAL, "GRAPH", 3000] },
  // The same function with its slant asymptote X+1 in Y2, tabulated so the
  // gap 2/(X-1) can be read shrinking down the rows, and the pole caught as
  // UNDEF on the X=1 row.
  {
    name: "co01-slant-table",
    keys: [...CO01_RATIONAL, "GRAPH", 3000,
      "2ND", "2", 60, "X-VAR", "+", "1", "GRAPH", 2500, "MORE", 2000]
  },
  // Chapter 1 section 1.2: the slope family X/2, X, 3*X plotted together.
  {
    name: "co01-slope-family",
    keys: ["X-VAR", "/", "2", "GRAPH", 900, "2ND", "2", 30, "X-VAR", "GRAPH", 1800,
      "2ND", "3", 30, "3", "*", "X-VAR", "GRAPH", 2700]
  },
  // Chapter 1 section 1.3: the odd-symmetry test. Y2=f(-x) and Y3=-f(x)
  // land on the same pixels, so three stored slots draw two curves.
  {
    name: "co01-odd-test",
    keys: ["X-VAR", "^", "3", "-", "4", "*", "X-VAR", "GRAPH", 900,
      "2ND", "2", 30, "(", "(-)", "X-VAR", ")", "^", "3", "-", "4", "*",
      "(", "(-)", "X-VAR", ")", "GRAPH", 2400,
      "2ND", "3", 30, "(-)", "(", "X-VAR", "^", "3", "-", "4", "*", "X-VAR", ")",
      "GRAPH", 3600]
  },
  // Chapter 1 section 1.4: EXP(X), LN(X), and the mirror line X in the
  // square window; the exponential plots are slow, hence the long waits.
  {
    name: "co01-exp-inverses",
    keys: ["2ND", "LN", "X-VAR", ")", "GRAPH", 8000,
      "2ND", "2", 60, "LN", "X-VAR", ")", "GRAPH", 16000,
      "2ND", "3", 60, "X-VAR", "GRAPH", 20000, "2ND", "-", 26000]
  },
  // Chapter 1 section 1.5: the daylight model 4.3*SIN(PI*X/6) in the
  // standard window.
  {
    name: "co01-daylight-model",
    keys: ["4", ".", "3", "*", "SIN", "2ND", "^", "*", "X-VAR", "/", "6", ")",
      "GRAPH", 8000]
  },
  // Chapter 1 section 1.6: the inverse of f(t)=t^3/10 drawn by the swapped
  // parametric pair x(t)=X^3/10, y(t)=X.
  {
    name: "co01-inverse-pair",
    keys: ["GRAPH", 100, "2ND", "MORE", "MORE", "MORE", "F3", 100, "EXIT", 30,
      "X-VAR", "GRAPH", 3000, "2ND", "2", 60, "X-VAR", "^", "3", "/", "1", "0",
      "GRAPH", 8000,
      "2ND", "1", 60, "CLEAR", "X-VAR", "^", "3", "/", "1", "0", "GRAPH", 8000,
      "2ND", "2", 60, "CLEAR", "X-VAR", "GRAPH", 8000]
  },
  // Chapter 2 section 2.1: the tea-blend 3x3 system's unique solution.
  {
    name: "co02-simult-blend",
    keys: ["2ND", "STAT", 30, "F3", 30,
      "1", "ENTER", "1", "ENTER", "1", "ENTER", "1", "0", "ENTER",
      "1", "2", "ENTER", "9", "ENTER", "6", "ENTER", "8", "4", "ENTER",
      "(-)", "2", "ENTER", "0", "ENTER", "1", "ENTER", "0", "ENTER",
      "F1", 300]
  },
  // Chapter 2 section 2.2: timber and labour constraint lines with the 360
  // profit line resting on the corner (4, 6).
  {
    name: "co02-lp-profit",
    keys: ["(", "1", "6", "-", "X-VAR", ")", "/", "2", "GRAPH", 900,
      "2ND", "2", 30, "(", "2", "4", "-", "3", "*", "X-VAR", ")", "/", "2",
      "GRAPH", 1800,
      "2ND", "3", 30, "(", "3", "6", "0", "-", "3", "0", "*", "X-VAR", ")",
      "/", "4", "0", "GRAPH", 2700]
  },
  // Chapter 2 section 2.3: the framer's tableau after SWAP, RADD, RMUL, and
  // the final RADD, stepped to CELL 1 3 where the print price 40 sits. The
  // key list mirrors the walkthrough: each result in R is read (five steps),
  // wrapped home, carried back into A, and the scale for the next operation
  // stored in B's top-left cell.
  {
    name: "co02-tableau-solved",
    keys: ["2ND", "7", 30, "X-VAR", "+", "X-VAR",
      "2", "ENTER", "1", "ENTER", "1", "1", "0", "ENTER",
      "1", "ENTER", "3", "ENTER", "1", "3", "0", "ENTER",
      "MORE", "MORE", 30, "F2", 60,
      "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", 30,
      "ALPHA", "ALPHA", 30,
      "1", "ENTER", "3", "ENTER", "1", "3", "0", "ENTER",
      "2", "ENTER", "1", "ENTER", "1", "1", "0", "ENTER",
      "ALPHA", 30, "(-)", "2", "ENTER", "ALPHA", 30,
      "DOWN", "DOWN", "DOWN", 30, "F3", 60,
      "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", 30,
      "ALPHA", "ALPHA", 30,
      "1", "ENTER", "3", "ENTER", "1", "3", "0", "ENTER",
      "0", "ENTER", "(-)", "5", "ENTER", "(-)", "1", "5", "0", "ENTER",
      "ALPHA", 30, "(-)", ".", "2", "ENTER", "ALPHA", 30,
      "DOWN", "DOWN", "DOWN", 30, "F4", 60,
      "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", 30,
      "ALPHA", "ALPHA", 30,
      "1", "ENTER", "3", "ENTER", "1", "3", "0", "ENTER",
      "0", "ENTER", "1", "ENTER", "3", "0", "ENTER",
      "ALPHA", 30, "(-)", "3", "ENTER", "ALPHA", 30,
      "F3", 60,
      "RIGHT", "RIGHT", 30]
  },
  // Chapter 2 section 2.4: the loan payment in the solver workspace. Same
  // workspace state as the walkthrough (equation, VAR A, bounds 0 to 1000)
  // reached directly from a fresh machine.
  {
    name: "co02-solver-payment",
    keys: ["2", "4", "STO", "ALPHA", "SIN", "ENTER", 30, "CLEAR",
      "1", "0", "0", "0", "0", "*", "2ND", "LN", "ALPHA", "SIN", "*", "LN",
      "1", ".", "0", "1", ")", ")", "-", "ALPHA", "LOG", "*", "(",
      "2ND", "LN", "ALPHA", "SIN", "*", "LN", "1", ".", "0", "1", ")", ")",
      "-", "1", ")", "/", ".", "0", "1",
      "2ND", "GRAPH", 60,
      "F3", 30, "F3", 30, "F3", 30,
      "F5", 30, "F5", 30, "F5", 30,
      "0", "ENTER", 30, "1", "0", "0", "0", "ENTER", 60,
      "F1", 9000]
  },
  // Chapter 2 section 2.4: the NO BOUNDED ROOT notice when the upper bound
  // caps the payment at 300.
  {
    name: "co02-solver-no-root",
    keys: ["2", "4", "STO", "ALPHA", "SIN", "ENTER", 30, "CLEAR",
      "1", "0", "0", "0", "0", "*", "2ND", "LN", "ALPHA", "SIN", "*", "LN",
      "1", ".", "0", "1", ")", ")", "-", "ALPHA", "LOG", "*", "(",
      "2ND", "LN", "ALPHA", "SIN", "*", "LN", "1", ".", "0", "1", ")", ")",
      "-", "1", ")", "/", ".", "0", "1",
      "2ND", "GRAPH", 60,
      "F3", 30, "F3", 30, "F3", 30,
      "F5", 30, "F5", 30, "F5", 30,
      "0", "ENTER", 30, "3", "0", "0", "ENTER", 60,
      "F1", 9000]
  },
  // Chapter 2 section 2.5: RREF of the coffee-shop steady-state matrix,
  // stepped to CELL 1 3 where the -2.5 proportion sits.
  {
    name: "co02-markov-steady",
    keys: ["2ND", "7", 30, "+", "X-VAR", "+", "X-VAR",
      "(-)", ".", "2", "ENTER", ".", "2", "ENTER", ".", "2", "ENTER",
      ".", "1", "ENTER", "(-)", ".", "3", "ENTER", ".", "2", "ENTER",
      ".", "1", "ENTER", ".", "1", "ENTER", "(-)", ".", "4", "ENTER",
      "F5", 900,
      "RIGHT", "RIGHT", 30]
  },
  // Chapter 3 section 3.1: the box plot of the keeper's sorted week, bars
  // at 15, 17.5, and 20 between edges standing for 12 and 43.
  {
    name: "co03-box-visitors",
    keys: ["STAT", "+", "+", "+", "+",
      "1", "5", "ENTER", "1", "2", "ENTER", "1", "7", "ENTER", "1", "5", "ENTER",
      "1", "9", "ENTER", "2", "1", "ENTER", "1", "8", "ENTER", "4", "3", "ENTER",
      "MORE", "MORE", "MORE", "MORE", "F4", 200,
      "MORE", "MORE", "MORE", "MORE", "F5", 600]
  },
  // Chapter 3 section 3.3: P2's run screen after the section's exact key
  // order (P1 typed and run once first), answering 8 sixes in 36 rolls.
  {
    name: "co03-ssd-poor",
    keys: co03Score(3, 2.5)
  },
  // The same program scoring the line LIN actually returns. Every nudge away
  // from 4 and 2 scores worse, which is what makes it the least squares fit.
  {
    name: "co03-ssd-best",
    keys: co03Score(4, 2)
  },
  {
    name: "co03-sim-run",
    keys: ["PRGM", "F1", 30,
      ...CO03_P1_LINES.flatMap(programLineKeys), "F2", 3000,
      "PRGM", 30, "DOWN", "F1", 30,
      ...CO03_P2_LINES.flatMap(programLineKeys), "F2", 12000]
  },
  // Chapter 3 section 3.4: the duckweed pairs on the scatter plot, bending
  // away from any straight line.
  {
    name: "co03-scat-duckweed",
    keys: ["STAT", "+",
      "1", "ENTER", "2", "ENTER", "3", "ENTER", "4", "ENTER", "5", "ENTER",
      "ALPHA",
      "6", "ENTER", "1", "2", "ENTER", "2", "4", "ENTER", "4", "8", "ENTER",
      "9", "6", "ENTER",
      "F4", 600]
  },
  // Chapter 3 section 3.4: the graph table with the fitted line in Y1 and
  // the fitted exponential in Y2, compared row by row.
  {
    name: "co03-fit-table",
    keys: ["(-)", "2", "7", ".", "6", "+", "2", "1", ".", "6", "*", "X-VAR",
      "GRAPH", 4000,
      "2ND", "2", 120,
      "CLEAR", "3", "*", "2ND", "LN", ".", "6", "9", "3", "1", "*", "X-VAR",
      ")", "GRAPH", 30000,
      "MORE", 600]
  },
  // Chapter 3 section 3.5: the FCX forecast screen answering the week the
  // pond is full, from the EXPR fit and a stored target of 100.
  {
    name: "co03-forecast-fcx",
    keys: ["STAT", "+",
      "1", "ENTER", "2", "ENTER", "3", "ENTER", "4", "ENTER", "5", "ENTER",
      "ALPHA",
      "6", "ENTER", "1", "2", "ENTER", "2", "4", "ENTER", "4", "8", "ENTER",
      "9", "6", "ENTER",
      "MORE", "MORE", "MORE", "F2", 1200,
      "CLEAR", 30, "+", "UP", "1", "0", "0", "ENTER", 30, "UP",
      "MORE", "F2", 1200]
  },
  // Chapter 3 section 3.6: XYLN joining the shuffled tally sheets in entry
  // order, the zig-zag that sorting repairs.
  {
    name: "co03-xyline-zigzag",
    keys: ["STAT", "+", "+", "+", "+",
      "3", "ENTER", "1", "ENTER", "6", "ENTER", "8", "ENTER", "2", "ENTER",
      "5", "ENTER", "4", "ENTER", "7", "ENTER",
      "ALPHA",
      "1", "7", "ENTER", "1", "5", "ENTER", "2", "1", "ENTER", "4", "3", "ENTER",
      "1", "2", "ENTER", "1", "9", "ENTER", "1", "5", "ENTER", "1", "8", "ENTER",
      "MORE", "MORE", "MORE", "MORE", "MORE", "F2", 600]
  },
  // Chapter 4 section 4.1: SIN(X)/X four ways. Trigonometry is slow to plot,
  // so every case below pays for a full draw before it does anything else.
  // The five captures are the standard window, the trace after three zooms,
  // the table at step 1 and at step 0.0625, and the error EVAL(0) stops on.
  { name: "co04-sinx-standard", keys: [...CO04_SINX, 9000] },
  {
    name: "co04-sinx-zoom-trace",
    keys: [...CO04_SINX, 9000, "+", 5000, "+", 5000, "+", 6000,
      "RIGHT", 400, "RIGHT", 600]
  },
  { name: "co04-sinx-table", keys: [...CO04_SINX, 9000, "MORE", 2000] },
  {
    name: "co04-sinx-table-fine",
    keys: [...CO04_SINX, 9000, "MORE", 2000, "-", 800, "-", 800, "-", 800,
      "-", 1200]
  },
  {
    name: "co04-sinx-eval-error",
    keys: [...CO04_SINX, 9000, "EXIT", 300, "CLEAR", 20,
      ...co04Spell("EVAL(0)"), "ENTER", 600]
  },
  // Chapter 4 section 4.2: SIN(1/X), which has no limit at 0, and
  // X*SIN(1/X), which has one because the two lines X and -X close on it.
  // 1/.0025 is 400 radians, which the quotient-based reduction of 2.14
  // handles without complaint; the boundary the chapter now walks up to is
  // one million radians, so EVAL(9E-7) is where the machine declines.
  { name: "co04-sinrecip-std", keys: [...CO04_SINRECIP, 14000] },
  {
    name: "co04-sinrecip-zoom",
    keys: [...CO04_SINRECIP, 14000, "+", 7000, "+", 7000, "+", 8000]
  },
  {
    name: "co04-sin-cliff",
    keys: [...CO04_SINRECIP, 14000, "EXIT", 300, "CLEAR", 20,
      ...co04Spell("EVAL(.0025)"), "ENTER", 900]
  },
  {
    name: "co04-sin-precision",
    keys: [...CO04_SINRECIP, 14000, "EXIT", 300, "CLEAR", 20,
      ...co04Spell("EVAL(9"), "EE", "(-)", "7", ")", "ENTER", 900]
  },
  {
    name: "co04-squeeze-zoom",
    keys: ["X-VAR", "*", ...CO04_SINRECIP, 14000,
      "2ND", "2", 60, "X-VAR", "GRAPH", 5000,
      "2ND", "3", 60, "(-)", "X-VAR", "GRAPH", 5000,
      "+", 9000, "+", 9000, "+", 10000]
  },
  // Chapter 4 section 4.3: the difference quotient of X^3-2*X at step .01,
  // typed out in full so it needs no calculus command, tabulated beside the
  // true derivative 3*X^2-2. The Y1 column sits just above Y2 all the way
  // down, which is the chord overshooting a curve that bends upwards.
  {
    name: "co04-diffquot-table",
    keys: ["(", "(", "X-VAR", "+", ".", "0", "1", ")", "^", "3",
      "-", "2", "*", "(", "X-VAR", "+", ".", "0", "1", ")",
      "-", "(", "X-VAR", "^", "3", "-", "2", "*", "X-VAR", ")", ")",
      "/", ".", "0", "1", "GRAPH", 4000,
      "2ND", "2", 60, "3", "*", "X-VAR", "X^2", "-", "2", "GRAPH", 4000,
      "MORE", 1500]
  },
  // Chapter 4 section 4.6: the editor showing P1's line 3, the one worth
  // checking twice. The editor holds one line on screen at a time, which
  // the first edition never showed and never mentioned; four presses of
  // [UP] from the blank line 7 land on it.
  {
    name: "co04-editor-p1",
    keys: ["X-VAR", "X^2", "+", "1", "GRAPH", 1200, "EXIT", 60, "CLEAR", 30,
      "PRGM", 60, "F1", 120,
      ...CO04_P1_LINES.flatMap((line) => programLineKeys(line)), 200,
      "UP", 60, "UP", 60, "UP", 60, "UP", 250]
  },
  // Chapter 4 section 4.2: NDER(1.5) answering the paper derivative 4.75 of
  // the stored X^3-2*X.
  {
    name: "co04-nder-result",
    keys: ["X-VAR", "^", "3", "-", "2", "*", "X-VAR", "GRAPH", 1200,
      "EXIT", 30, "CLEAR",
      "ALPHA", "9", "ALPHA", "TAN", "ALPHA", "^", "ALPHA", "5",
      "(", "1", ".", "5", ")", "ENTER", 600]
  },
  // Chapter 4 section 4.3: the designed cubic X^3/3-4*X, hill at -2 and
  // valley at 2, in the standard window.
  {
    name: "co04-extrema-cubic",
    keys: ["X-VAR", "^", "3", "/", "3", "-", "4", "*", "X-VAR", "GRAPH", 1200]
  },
  // Chapter 4 section 4.4: the parabola X^2-2*X-3 dipping below the axis
  // between its zeros -1 and 3.
  {
    name: "co04-dip-area",
    keys: ["X-VAR", "X^2", "-", "2", "*", "X-VAR", "-", "3", "GRAPH", 1200]
  },
  // Chapter 4 section 4.5: P4's run screen after the section's exact build
  // order (P1 to P3 typed and run first), the eight-slice midpoint sum
  // answering 4.65625 against FNINT's 4.6666666666667.
  {
    name: "co04-riemann-run",
    keys: ["X-VAR", "X^2", "+", "1", "GRAPH", 1200, "EXIT", 30,
      "PRGM", "F1", 30, ...CO04_P1_LINES.flatMap(programLineKeys), "F2", 6000,
      "PRGM", 30, "DOWN", "F1", 30, ...CO04_P2_LINES.flatMap(programLineKeys), "F2", 6000,
      "PRGM", 30, "DOWN", "F1", 30, ...CO04_P3_LINES.flatMap(programLineKeys), "F2", 6000,
      "PRGM", 30, "DOWN", "F1", 30, ...CO04_P4_LINES.flatMap(programLineKeys), "F2", 9000]
  },
  // Chapter 4 section 4.6: the arch 2-X^2/2 and the line X/2+1 crossing at
  // -2 and 1 in the standard window.
  {
    name: "co04-between-curves",
    keys: ["2", "-", "X-VAR", "X^2", "/", "2", "GRAPH", 1200,
      "2ND", "2", 30, "X-VAR", "/", "2", "+", "1", "GRAPH", 2400]
  },
  // Chapter 5 section 5.1: the designed quartic's root browser opening on
  // ROOT 1, RE 2.7320508075688 (1 plus root 3).
  {
    name: "co05-newton-converged",
    keys: co05Newton(2, 4)
  },
  // The table at its default step of 1, which is where the failure is
  // loudest: at X=5 the degree-3 impersonator is out by 104 and the
  // degree-5 by 2604, so the longer polynomial is the worse of the two.
  {
    name: "co05-geometric-table",
    keys: [...CO05_GEOMETRIC, "MORE", 2500]
  },
  {
    name: "co05-poly-roots",
    keys: ["2ND", "PRGM", 30, "F4", 10,
      "1", "ENTER", "(-)", "2", "ENTER", "(-)", "4", "ENTER",
      "4", "ENTER", "4", "ENTER", "F1", 9000]
  },
  // Chapter 5 section 5.2: the 10 by 5 pond ellipse 5*COS(X), 2.5*SIN(X)
  // in the square window.
  {
    name: "co05-pond-ellipse",
    keys: ["GRAPH", 100, "2ND", "MORE", 10, "MORE", "MORE", "F3", 100,
      "EXIT", 30, "5", "*", "COS", "X-VAR", ")", "GRAPH", 12000,
      "2ND", "2", 60, "2", ".", "5", "*", "SIN", "X-VAR", ")", "GRAPH", 30000,
      "2ND", "-", 30000]
  },
  // Chapter 5 section 5.3: the four-petal rose 4*SIN(2X) in the square
  // window.
  {
    name: "co05-polar-rose",
    keys: ["GRAPH", 100, "2ND", "MORE", 10, "MORE", "MORE", "F2", 100,
      "EXIT", 30, "4", "*", "SIN", "2", "X-VAR", ")", "GRAPH", 12000,
      "2ND", "-", 12000]
  },
  // Chapter 5 section 5.3: the spiral X/2 stopping after the fixed single
  // revolution, plotted after the rose and cardioid in the section's order.
  {
    name: "co05-polar-spiral",
    keys: ["GRAPH", 100, "2ND", "MORE", 10, "MORE", "MORE", "F2", 100,
      "EXIT", 30, "4", "*", "SIN", "2", "X-VAR", ")", "GRAPH", 12000,
      "2ND", "-", 12000,
      "EXIT", 30, "CLEAR", "2", ".", "5", "*", "(", "1", "+", "COS",
      "X-VAR", ")", ")", "GRAPH", 12000,
      "EXIT", 30, "CLEAR", "X-VAR", "/", "2", "GRAPH", 12000]
  },
  // Chapter 5 section 5.4: the pebble's flight, x(t)=3*X and y(t)=9*X-5*X^2
  // in the standard window, pre-launch tail included.
  {
    name: "co05-projectile",
    keys: ["GRAPH", 100, "2ND", "MORE", 10, "MORE", "MORE", "F3", 100,
      "EXIT", 30, "3", "*", "X-VAR", "GRAPH", 6000,
      "2ND", "2", 60, "9", "*", "X-VAR", "-", "5", "*", "X-VAR", "X^2",
      "GRAPH", 12000]
  },
  // Chapter 5 section 5.5: FNINT(3,6) on the stored 1/X matching the area
  // from 1 to 2, after the section's exact probe order (the 2*X accumulator
  // first, then the logarithm probes).
  {
    name: "co05-accumulator",
    keys: ["2", "*", "X-VAR", "GRAPH", 1200, "EXIT", 30, "CLEAR",
      ...FNINT_KEYS, "(", "0", ",", "1", ")", "ENTER", 600, "CLEAR",
      ...FNINT_KEYS, "(", "0", ",", "2", ")", "ENTER", 600, "CLEAR",
      ...FNINT_KEYS, "(", "0", ",", "3", ")", "ENTER", 600, "CLEAR",
      ...FNINT_KEYS, "(", "0", ",", "2", ".", "5", ")", "ENTER", 600, "CLEAR",
      "1", "/", "X-VAR", "GRAPH", 1200, "EXIT", 30, "CLEAR",
      ...FNINT_KEYS, "(", "1", ",", "2", ")", "ENTER", 600, "CLEAR",
      "LN", "2", ")", "ENTER", 300, "CLEAR",
      ...FNINT_KEYS, "(", "1", ",", "4", ")", "ENTER", 600, "CLEAR",
      ...FNINT_KEYS, "(", "1", ",", "8", ")", "ENTER", 600, "CLEAR",
      ...FNINT_KEYS, "(", "3", ",", "6", ")", "ENTER", 600]
  },
  // Chapter 5 section 5.8: SIN(X) in the trigonometric window with its
  // degree-3 and degree-5 approximations in the other two slots.
  {
    name: "co05-taylor-slots",
    keys: ["SIN", "X-VAR", ")", "GRAPH", 12000,
      "2ND", "GRAPH", 60, "MORE", 30, "F5", 30000,
      "2ND", "2", 60, "X-VAR", "-", "X-VAR", "^", "3", "/", "6",
      "GRAPH", 30000,
      "2ND", "3", 60, "X-VAR", "-", "X-VAR", "^", "3", "/", "6",
      "+", "X-VAR", "^", "5", "/", "1", "2", "0", "GRAPH", 40000]
  },
  // Chapter 6 section 6.1: the reduced tableau of x+2y=8, 3x-y=3 stepped to
  // CELL 1 3, where the value of x sits, after the section's SIMULT solve.
  {
    name: "co06-rref-solution",
    keys: ["2ND", "STAT", 30, ...cellKeys([1, 2, 8, 3, -1, 3]),
      "F1", 300, "EXIT", 30, "CLEAR", 30,
      "2ND", "7", 30, "X-VAR", "+", 30, ...cellKeys([1, 2, 8, 3, -1, 3]),
      "F5", 300, "RIGHT", "RIGHT", 30]
  },
  // Chapter 6 section 6.3: COND answering 9490.8400582879 for the
  // near-dependent matrix, reached through the section's whole flow.
  { name: "co06-cond-ill", keys: [...CO06_COND_KEYS] },
  // Chapter 6 section 6.3: the solution after the one-thousandth nudge,
  // 3.001 at CELL 1 1 where 1 stood before.
  {
    name: "co06-perturbed-solve",
    keys: [...CO06_COND_KEYS,
      "ALPHA", 30, ...cellKeys([3, "3.001", "3.001"]),
      "ALPHA", 30, "EXIT", 30, "2ND", "7", 30, "MORE", 30, "F5", 600,
      "RIGHT", "RIGHT", 30, "RIGHT", 30,
      "ALPHA", 30, ...cellKeys(["3.001"]), 30,
      "ALPHA", 30, "F5", 600]
  },
  // Chapter 6 section 6.4: ANG answering the fourteen-digit right angle for
  // the straightened pair, after the section's subtraction and carry.
  {
    name: "co06-right-angle",
    keys: ["2ND", "8", 30, ...cellKeys([5, 2, 0]),
      "ALPHA", 30, ...cellKeys([1, 2, 2]), "ALPHA", 30,
      "F1", 300, "F3", 300, "F5", 300,
      "MORE", 30, "F2", 300,
      "RIGHT", "RIGHT", 30, "RIGHT", 30,
      "ALPHA", "ALPHA", 30, ...cellKeys([4, 0, -2]),
      "EXIT", 30, "2ND", "8", 30, "F3", 300, "F5", 300]
  },
  // Chapter 6 section 6.5: the rotation-flavoured matrix's eigenvalues on
  // the imaginary-parts page, IM -2 under the first cell, after the whole
  // section's multiplications and eigensystems in order.
  {
    name: "co06-eigen-complex",
    keys: ["2ND", "7", 30, ...cellKeys([5, 2, 2, 2]),
      "ALPHA", 30, "X-VAR", "-", "X-VAR", 30, ...cellKeys([1, 0]),
      "ALPHA", 30, "MORE", 30, "F3", 300, "RIGHT", 30, "RIGHT", 30,
      "ALPHA", 30, ...cellKeys([2, 1]), "ALPHA", 30, "F3", 300,
      "RIGHT", 30, "RIGHT", 30,
      "MORE", "MORE", "MORE", 30, "F2", 3000, "RIGHT", 30,
      "F3", 3000, "RIGHT", "RIGHT", "RIGHT", 30, "RIGHT", 30,
      "ALPHA", "ALPHA", 30, "+", "X-VAR", "+", "X-VAR", 30,
      ...cellKeys([2, 0, 0, 1, 3, 0, 4, 5, 6]),
      "F2", 30000, "RIGHT", "RIGHT", 30,
      "F3", 30000, "RIGHT", "RIGHT", "RIGHT", 30, "RIGHT", "RIGHT", "RIGHT", 30,
      "RIGHT", "RIGHT", "RIGHT", 30,
      "ALPHA", 30, "+", 30, ...cellKeys([0, 0, 1]),
      "ALPHA", 30, "EXIT", 30, "2ND", "7", 30, "MORE", 30, "F3", 300,
      "RIGHT", "RIGHT", 30, "RIGHT", 30,
      "ALPHA", "ALPHA", 30, "-", "X-VAR", "-", "X-VAR", 30,
      ...cellKeys([1, -2, 2, 1]),
      "MORE", "MORE", "MORE", 30, "F2", 3000, "MORE", 30]
  },
  // Chapter 6 section 6.6: the combined LU factors of the matrix whose
  // elimination begins with a row swap, after the section's first specimen.
  {
    name: "co06-lu-pivot",
    keys: ["2ND", "7", 30, "+", "X-VAR", "+", "X-VAR",
      ...cellKeys([2, 1, 1, 4, 5, 4, 2, 10, 11]),
      "F1", 300, "MORE", "MORE", "MORE", "MORE", 30, "F1", 3000,
      "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", 30,
      "RIGHT", 30, "ALPHA", "ALPHA", 30,
      ...cellKeys([0, 2, 1, 2, 4, 6, 1, 1, 1]),
      "EXIT", 30, "2ND", "7", 30, "F1", 300,
      "MORE", "MORE", "MORE", "MORE", 30, "F1", 3000]
  },
  // Chapter 7 section 7.1: the tank's dye concentration decaying across the
  // standard window from the frozen initial condition 9.
  { name: "co07-tank-decay", keys: [...CO07_TANK] },
  // Chapter 7 section 7.2: the same equation after one [+], the run re-based
  // on the new left window edge and the step halved with it.
  { name: "co07-narrow-window", keys: [...CO07_TANK, "+", 6000] },
  // Chapter 7 section 7.3: the table page holding the 3.5-minute reading of
  // the standard window, 5.290 at X=-6.5, after halving the table step.
  {
    name: "co07-step-table",
    keys: [...CO07_TANK, "MORE", 6000, "-", 5000, "UP", 5000, "UP", 5000,
      "UP", 5000]
  },
  // Chapter 7 section 7.4: P1's run screen, seven Euler steps of 0.5.
  {
    name: "co07-euler-run",
    keys: [...CO07_TANK, "EXIT", 90, "CLEAR", 30, "PRGM", "F1", 60,
      ...CO07_P1_LINES.flatMap(programLineKeys), "F2", 12000]
  },
  // Chapter 7 section 7.5: P2's run screen after the section's build order,
  // the driver calling P3 for each improved-Euler step.
  {
    name: "co07-heun-run",
    keys: [...CO07_TANK, "EXIT", 90, "CLEAR", 30, "PRGM", "F1", 60,
      ...CO07_P1_LINES.flatMap(programLineKeys), "F2", 12000,
      "PRGM", 60, "DOWN", "F1", 60,
      ...CO07_P2_LINES.flatMap(programLineKeys), "EXIT", 120,
      "DOWN", "F1", 60,
      ...CO07_P3_LINES.flatMap(programLineKeys), "EXIT", 120,
      "UP", 60, "F3", 40000]
  },
  // Chapter 7 section 7.6: the equilibrium of .4*(3-Y) approached from below,
  // reached by seeding -6 before the mode's first entry.
  {
    name: "co07-logistic-plot",
    keys: [...co07Seed(1), ...CO07_DEQ_MODE, ...CO07_LOGISTIC, "GRAPH", 14000]
  },
  // The table paged back twice to the steepest stretch, where the growth is
  // still accelerating towards the inflection at half the ceiling.
  {
    name: "co07-logistic-table",
    keys: [...co07Seed(1), ...CO07_DEQ_MODE, ...CO07_LOGISTIC, "GRAPH", 14000,
      "MORE", 4000, "UP", 2500, "UP", 2500]
  },
  { name: "co07-gompertz-plot",
    keys: [...co07Seed(1), ...CO07_DEQ_MODE, ...CO07_GOMPERTZ, "GRAPH", 16000]
  },
  // The slowest capture in the book: a logarithm on every Euler step, and a
  // fresh walk from the window edge for every row of the table.
  {
    name: "co07-gompertz-table",
    keys: [...co07Seed(1), ...CO07_DEQ_MODE, ...CO07_GOMPERTZ, "GRAPH", 16000,
      "MORE", 60000]
  },
  // Section 7.7's setup page, which replaced the GDEQ deletion ritual: the
  // method and the initial condition, edited in place.
  {
    name: "co07-deq-setup",
    keys: [...co07Seed(1), ...CO07_DEQ_MODE,
      ".", "4", "*", "(", "3", "-", "ALPHA", "0", ")", "GRAPH", 9000,
      "2ND", "MORE", "MORE", "MORE", "MORE", 60]
  },
  {
    name: "co07-equilibrium",
    keys: [...co07Seed(-6), ...CO07_DEQ_MODE,
      ".", "4", "*", "(", "3", "-", "ALPHA", "0", ")", "GRAPH", 9000]
  },
  // Chapter 8 section 8.1: the integral conservation of energy hands you,
  // integrated between 0 and the amplitude. The integrand is infinite at the
  // top of the swing, so a sample lands on the singularity and FNINT( now
  // answers DIVIDE BY ZERO rather than the 9643 that firmware 2.10 handed
  // back without comment where the answer is about 2.31.
  {
    name: "co08-naive-integral",
    keys: ["2ND", "^", "/", "4", "STO", "ALPHA", "LOG", "ENTER", 200, "CLEAR", 30,
      "1", "/", "2ND", "X^2", "COS", "X-VAR", ")", "-", "COS", "ALPHA", "LOG", ")", ")",
      "GRAPH", 9000, "EXIT", 300, "CLEAR", 30,
      ...FNINT_KEYS, "(", "0", ",", "ALPHA", "LOG", ")", "ENTER", 12000]
  },
  // Chapter 8 section 8.3: the same hundred reciprocal squares added upwards
  // and stopped on a tolerance rather than a term count. Line 3 is the
  // comparison this editor cannot type, written as arithmetic instead.
  {
    name: "co08-tolerance-run",
    keys: ["PRGM", 60, "F1", 120,
      ...CO08_TOLERANCE_LINES.flatMap(programLineKeys), 200, "F2", 90000]
  },
  // Chapter 8 section 8.1: the swing's true period at a 150-degree amplitude,
  // after the section's whole run of modulus stores and ratio probes.
  {
    name: "co08-pendulum-period",
    keys: [...CO08_PENDULUM, ...CO08_RATIO,
      ...co08Modulus(["SIN", "2ND", "^", "/", "3", "6", ")"]), ...CO08_RATIO,
      ...co08Modulus(["SIN", "2ND", "^", "/", "1", "2", ")"]), ...CO08_RATIO,
      ...co08Modulus(["SIN", "2ND", "^", "/", "6", ")"]), ...CO08_RATIO,
      ...co08Modulus(["SIN", "2ND", "^", "/", "4", ")"]), ...CO08_RATIO,
      ...co08Modulus(["SIN", "2ND", "^", "/", "3", ")"]), ...CO08_RATIO,
      ...co08Modulus(["SIN", "5", "*", "2ND", "^", "/", "1", "2", ")"]), ...CO08_RATIO,
      "4", "*", "2ND", "X^2", "2", ".", "5", "/", "9", ".", "8", ")", "*",
      ...FNINT_KEYS, "(", "0", ",", "2ND", "^", "/", "2", ")", "ENTER", 3000]
  },
  // Chapter 8 section 8.2: the reciprocal-squares partial sum at a hundred
  // terms, after the ten- and forty-term runs the section takes first.
  {
    name: "co08-basel-run",
    keys: ["PRGM", "F1", 60, ...CO08_P1_LINES.flatMap(programLineKeys), "F2", 6000,
      "PRGM", 60, "F1", 60, "DOWN", "CLEAR", ...programLineKeys("40->N"), "F2", 24000,
      "PRGM", 60, "F1", 60, "DOWN", "CLEAR", ...programLineKeys("100->N"), "F2", 60000]
  },
  // Chapter 8 section 8.2: the damper series at twelve terms, after the
  // reciprocal-squares program and the six-term run the section takes first.
  {
    name: "co08-damper-run",
    keys: ["PRGM", "F1", 60, ...CO08_P1_LINES.flatMap(programLineKeys), "F2", 6000,
      "PRGM", 60, "DOWN", "F1", 60, ...CO08_P2_LINES.flatMap(programLineKeys), "F2", 6000,
      "PRGM", 60, "F1", 60, "DOWN", "CLEAR", ...programLineKeys("12->N"), "F2", 12000]
  },
  // Chapter 8 section 8.3: the first shot's table page, the outlet reading
  // 1.979 at X=10 against a target of 2.
  { name: "co08-first-shot", keys: [...CO08_REED, "MORE", 6000, "DOWN", 5000] },
  // Chapter 8 section 8.3: the fourth shot's run screen, the seed 10.559
  // landing four hundred-thousandths above the target.
  {
    name: "co08-shot-run",
    keys: [...CO08_REED, "EXIT", 120, "CLEAR", 30,
      "PRGM", "DOWN", "DOWN", "F1", 60, ...CO08_P3_LINES.flatMap(programLineKeys),
      "F2", 60000,
      "PRGM", 60, "F1", 60, "CLEAR", ...programLineKeys("11->Y"), "F2", 60000,
      "PRGM", 60, "F1", 60, "CLEAR", ...programLineKeys("10.577->Y"), "F2", 60000,
      "PRGM", 60, "F1", 60, "CLEAR", ...programLineKeys("10.559->Y"), "F2", 60000]
  },
  // Chapter 8 section 8.4: the three guy tensions adding to a pure downward
  // pull, the third component reading -3600 after the section's carries.
  {
    name: "co08-guy-sum",
    keys: [...CO08_DEGREES,
      "2ND", "8", 60, ...co08Components([9, 120, 0]), 60,
      "MORE", "MORE", 60, "F2", 600, "RIGHT", 30,
      "EXIT", 60, "2ND", "8", 60, ...co08Components([9, 0, -12]), 60,
      "F1", 600, "F2", 600, "RIGHT", 30, "RIGHT", 30,
      "EXIT", 60, "2ND", "8", 60, ...co08Components([9, 0, -12]), 60,
      "ALPHA", 30, ...co08Components([-4.5, 7.7942286341, -12]), 60,
      "ALPHA", 30, "F3", 600, "F5", 900,
      "EXIT", 60, "2ND", "8", 60, ...co08Components([0, 0, 12]), 60,
      "ALPHA", 30, ...co08Components([900, 0, -1200]), 60,
      "ALPHA", 30, "F4", 600, "RIGHT", 30,
      "EXIT", 60, "2ND", "8", 60, ...co08Components([900, 0, -1200]), 60,
      "ALPHA", 30, ...co08Components([-450, 779.42286341, -1200]), 60,
      "ALPHA", 30, "MORE", 30, "F1", 600, "RIGHT", 30, "RIGHT", 30,
      "EXIT", 60, "2ND", "8", 60, ...co08Components([450, 779.42286341, -2400]), 60,
      "ALPHA", 30, ...co08Components([-450, -779.42286341, -1200]), 60,
      "ALPHA", 30, "MORE", 30, "F1", 600, "RIGHT", 30, "RIGHT", 30]
  }
];

function capture({ keys }) {
  const harness = Free85Harness.boot();
  for (const key of keys) {
    if (typeof key === "number") harness.runFrames(key);
    else harness.tap(key);
  }
  return harness.machine.renderLcdBitmap();
}

mkdirSync(OUT_DIR, { recursive: true });
for (const screenCase of SCREEN_CASES) {
  if (!/^[a-z0-9-]+$/.test(screenCase.name)) throw new Error(`bad name ${screenCase.name}`);
  writeFileSync(`${OUT_DIR}${screenCase.name}.png`, renderLcdPng(capture(screenCase)));
  console.log(`wrote ${screenCase.name}.png`);
}
