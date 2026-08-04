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

const CO03_P1_LINES = ["0->S", "FOR A,1,9", "S+RANDI(0,1)->S", "END", "DISP S", "STOP"];
const CO03_P2_LINES = ["36->N", "0->S", "WHILE N", "S+INT(RANDI(1,6)/6)->S",
  "N-1->N", "END", "DISP S", "STOP"];

export const SCREEN_CASES = [
  // Chapter 1 section 1.1: the cubic X^3-4*X in the standard window.
  { name: "co01-cubic-window", keys: ["X-VAR", "^", "3", "-", "4", "*", "X-VAR", "GRAPH", 900] },
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
