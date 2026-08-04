import assert from "node:assert/strict";
import test from "node:test";
import { Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";
import { readNumericLines } from "../../scripts/free85-lcd-ocr.js";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";

const alphaKeys = new Map(TI85_PHYSICAL_KEYS
  .filter(({ alpha }) => /^[A-Z]$/.test(alpha ?? ""))
  .map(({ alpha, key }) => [alpha, key]));

const GRAPH_EQ1 = 0x8510;
const GRAPH_EQ2 = 0x8541;
const GRAPH_ENABLED = 0x8501;
const GRAPH_ACTIVE = 0x8502;
const GRAPH_MODE = 0x869a;
const GRAPH_RESULT_X = 0x8675;
const GRAPH_RESULT_Y = 0x867e;
const GRAPH_FORMAT = 0x8690;
const GRAPH_FMT_AXES = 0x01;
const GRAPH_FMT_GRID = 0x08;

function finishPlot(harness, limit = 10000) {
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) && frames < limit) {
    harness.runFrames(100);
    frames += 100;
  }
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0, `plot exceeded ${limit} frames`);
}

function selectMode(harness, key) {
  harness.tap("2ND");
  harness.tap("MORE");
  harness.tap("MORE");
  harness.tap("MORE");
  harness.tap(key);
  finishPlot(harness);
}

function type(harness, expression) {
  for (const character of expression) {
    if (character === "X") harness.tap("X-VAR");
    else if (character === "-") harness.tap("(-)");
    else harness.tap(character);
  }
}

function enterModeEquation(modeKey, expression) {
  const harness = Free85Harness.boot();
  harness.tap("GRAPH");
  finishPlot(harness);
  selectMode(harness, modeKey);
  harness.tap("EXIT");
  type(harness, expression);
  harness.tap("GRAPH");
  finishPlot(harness);
  return harness;
}

test("[graph.polar] polar editor plots, traces, tables, and preserves its equation", () => {
  const harness = enterModeEquation("F2", "5");
  assert.equal(harness.machine.read8(GRAPH_MODE), 1);
  assert.equal(harness.machine.read8(GRAPH_ENABLED) & 1, 1);
  assertLcdGolden("phase16-polar-circle", harness.machine.renderLcdBitmap());
  harness.tap("MORE");
  assert.equal(harness.machine.read8(0x800b), 3);
  harness.tap("GRAPH");
  finishPlot(harness);
  for (const key of ["2ND", "MORE", "MORE", "MORE", "F5", "EXIT"]) harness.tap(key);
  finishPlot(harness);
  harness.tap("RIGHT");
  assert.ok(Math.abs(harness.packedNumber(GRAPH_RESULT_X) - 5) < 1e-8, "PolarGC trace reports radius");
  assert.ok(Number.isFinite(harness.packedNumber(GRAPH_RESULT_Y)), "PolarGC trace reports theta");
  selectMode(harness, "F1");
  selectMode(harness, "F2");
  assert.equal(harness.machine.read8(GRAPH_EQ1), 1);
  assert.equal(harness.machine.read8(GRAPH_EQ1 + 1), "5".charCodeAt(0));
});

test("[graph.parametric] paired x(t),y(t) editors render through the shared engine", () => {
  const harness = enterModeEquation("F3", "X");
  harness.tap("2ND");
  harness.tap("2");
  type(harness, "X^2");
  harness.tap("GRAPH");
  finishPlot(harness);
  assert.equal(harness.machine.read8(GRAPH_MODE), 2);
  assert.equal(harness.machine.read8(GRAPH_EQ2), 3);
  assert.equal(harness.machine.read8(GRAPH_ENABLED) & 3, 3);
  assertLcdGolden("phase16-parametric", harness.machine.renderLcdBitmap());
  harness.tap("LEFT");
  assert.ok(Number.isFinite(harness.packedNumber(GRAPH_RESULT_X)));
  assert.ok(Number.isFinite(harness.packedNumber(GRAPH_RESULT_Y)));
  harness.tap("MORE");
  assert.equal(harness.machine.read8(0x800b), 3);
});

test("[graph.diffeq] Euler solve, trace reintegration, table, and cancellation are deterministic", () => {
  const harness = enterModeEquation("F4", "1");
  assert.equal(harness.machine.read8(GRAPH_MODE), 3);
  assertLcdGolden("phase16-diffeq", harness.machine.renderLcdBitmap());
  // dy/dx=1 seeded with Y=0 solves to y=x+10 on the standard window. Each
  // trace step reintegrates from (Xmin, initial Y), which spans many frames.
  harness.tap("RIGHT");
  harness.runFrames(200);
  harness.tap("RIGHT");
  harness.runFrames(200);
  const traceX = -10 + 66 * (20 / 127);
  assert.ok(Math.abs(harness.packedNumber(GRAPH_RESULT_X) - traceX) < 1e-9, "trace advances along the solution");
  assert.ok(Math.abs(harness.packedNumber(GRAPH_RESULT_Y) - (traceX + 10)) < 1e-9, "trace reports the integrated value");
  harness.tap("MORE");
  harness.runFrames(2500);
  assert.equal(harness.machine.read8(0x800b), 3);
  // The table X column steps 0..5 and Y1 reports the integrated y=x+10.
  const rows = readNumericLines(harness.machine.renderLcdBitmap(), { originX: 0, originY: 0 })
    .filter(({ row }) => row >= 1 && row <= 6)
    .map(({ text }) => text.replace(/\s+/g, " "));
  assert.deepEqual(rows, ["0 10 - -", "1 11 - -", "2 12 - -", "3 13 - -", "4 14 - -", "5 15 - -"]);
  harness.tap("GRAPH");
  harness.runFrames(8);
  if (harness.machine.read8(0x800b) === 3) harness.tap("GRAPH");
  while (harness.machine.read8(0x850e)) harness.runFrames(1);
  assert.equal(harness.machine.read8(0x800b), 2);
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 1);
  harness.runFrames(8);
  harness.tap("EXIT");
  harness.runFrames(8);
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0);
});

test("[graph.eval-guard] a graph-calculus name stored in a graph slot errors instead of crashing", () => {
  const storeSlot = (harness, source) => {
    harness.machine.write8(GRAPH_EQ1, source.length);
    for (let index = 0; index < source.length; index += 1) {
      harness.machine.write8(GRAPH_EQ1 + 1 + index, source.charCodeAt(index));
    }
    harness.machine.write8(GRAPH_ENABLED, 1);
  };

  // Function mode: EVAL(2) as Y1 re-enters the single-level calculus context.
  const cartesian = Free85Harness.boot();
  cartesian.tap("GRAPH");
  finishPlot(cartesian);
  storeSlot(cartesian, "EVAL(2)");
  cartesian.tap("GRAPH");
  finishPlot(cartesian);
  assert.equal(cartesian.machine.read8(0x800b), 2, "plot stays on the graph screen");

  // Polar mode: the originally reported crash stored EVAL(2) as r(theta).
  const polar = Free85Harness.boot();
  polar.tap("GRAPH");
  finishPlot(polar);
  selectMode(polar, "F2");
  storeSlot(polar, "EVAL(2)");
  polar.tap("GRAPH");
  finishPlot(polar);
  assert.equal(polar.machine.read8(GRAPH_MODE), 1);
  assert.equal(polar.machine.read8(0x800b), 2, "polar plot stays on the graph screen");
});

// The simultaneous plotter and the table both count their equation slots in
// GRAPH_NUMERIC_OP, which every callable calculus entry point resets to zero.
// A calculus name in Y2 or Y3 therefore rewound the slot counter on each
// sample and the tick never returned, so no key was ever read again. Slot Y1
// hid the fault: rewinding to zero is where its counter already stood.
test("[graph.calculus-slot] a calculus name in a later graph slot fails the sample, not the machine", () => {
  const writeSlot = (harness, address, source) => {
    harness.machine.write8(address, source.length);
    for (let index = 0; index < source.length; index += 1) {
      harness.machine.write8(address + 1 + index, source.charCodeAt(index));
    }
  };

  for (const source of ["FNINT(0,X)", "EVAL(2)", "NDER(X)"]) {
    const harness = Free85Harness.boot();
    harness.tap("GRAPH");
    finishPlot(harness);
    writeSlot(harness, GRAPH_EQ1, "2*X");
    writeSlot(harness, GRAPH_EQ2, source);
    harness.machine.write8(GRAPH_ENABLED, 3);
    harness.tap("GRAPH");
    finishPlot(harness, 4000);
    assert.equal(harness.machine.read8(0x800b), 2, `${source} leaves the graph screen up`);

    // The table walks the same slot counter.
    harness.tap("MORE");
    harness.runFrames(400);
    assert.equal(harness.machine.read8(0x800b), 3, `${source} tabulates without wedging`);

    // A wedged tick never polls the keypad again, so keys that walk the table
    // back to the graph and out to the home screen prove the machine is still
    // answering.
    harness.tap("EXIT");
    finishPlot(harness, 4000);
    assert.equal(harness.machine.read8(0x800b), 2, `${source} returns from the table`);
    harness.tap("EXIT");
    harness.runFrames(20);
    assert.equal(harness.machine.read8(0x800b), 0, `${source} leaves the machine responsive`);
  }
});

test("[graph.calculus-home] callable calculus still integrates the active slot from the home screen", () => {
  const harness = Free85Harness.boot();
  harness.machine.write8(GRAPH_EQ1, 3);
  for (const [index, character] of [..."1/X"].entries()) {
    harness.machine.write8(GRAPH_EQ1 + 1 + index, character.charCodeAt(0));
  }
  harness.machine.write8(GRAPH_ENABLED, 1);
  for (const letter of "FNINT") {
    harness.tap("ALPHA");
    harness.tap(alphaKeys.get(letter));
  }
  for (const key of ["(", "1", ",", "2", ")", "ENTER"]) harness.tap(key);
  harness.runFrames(400);
  assert.equal(harness.machine.read8(0x800b), 0, "FNINT( answers on the home screen");
  assert.ok(
    Math.abs(Number(harness.resultText()) - Math.LN2) < 1e-6,
    `FNINT(1,2) integrates 1/X to ln 2, got ${harness.resultText()}`
  );
});

// The DifEq table converts a sample index through the same routine as a
// plotted column, so it stopped at the hundredth of the plot's 128 samples and
// every row past X=5.7 in the standard window answered UNDEF.
test("[graph.diffeq-table-depth] the DifEq table reads to the right edge of the window", () => {
  const harness = enterModeEquation("F4", "1");
  harness.tap("MORE");
  harness.runFrames(2500);
  const tableRows = () => readNumericLines(harness.machine.renderLcdBitmap(), { originX: 0, originY: 0 })
    .filter(({ row }) => row >= 1 && row <= 6)
    .map(({ text }) => text.replace(/\s+/g, " "));
  assert.deepEqual(tableRows(), ["0 10 - -", "1 11 - -", "2 12 - -", "3 13 - -", "4 14 - -", "5 15 - -"]);
  harness.tap("DOWN");
  harness.runFrames(2500);
  assert.deepEqual(tableRows(), ["5 15 - -", "6 16 - -", "7 17 - -", "8 18 - -", "9 19 - -", "10 20 - -"]);
});

// Mapping a plotted point to its screen column used to reject any value of
// 100 or more, so polar and parametric curves lost every point in columns
// 100..127. Function-mode plots walk the columns directly and never showed it.
test("[graph.right-columns] polar and parametric curves reach the rightmost screen columns", () => {
  // Screen column for a window x on the standard -10..10 range, truncated the
  // way the firmware truncates its mapped coordinate.
  const column = (x) => Math.trunc(((x + 10) / 20) * 127);

  const writeSlot = (harness, address, source) => {
    harness.machine.write8(address, source.length);
    for (let index = 0; index < source.length; index += 1) {
      harness.machine.write8(address + 1 + index, source.charCodeAt(index));
    }
  };

  // Axes, ticks and grid dots light columns of their own, so switch them off
  // and let every lit pixel belong to the curve.
  const plot = (modeKey, first, second, enabled) => {
    const harness = Free85Harness.boot();
    harness.tap("GRAPH");
    finishPlot(harness);
    selectMode(harness, modeKey);
    writeSlot(harness, GRAPH_EQ1, first);
    if (second !== null) writeSlot(harness, GRAPH_EQ2, second);
    harness.machine.write8(GRAPH_ENABLED, enabled);
    const format = harness.machine.read8(GRAPH_FORMAT);
    harness.machine.write8(GRAPH_FORMAT, format & ~(GRAPH_FMT_AXES | GRAPH_FMT_GRID));
    harness.tap("GRAPH");
    finishPlot(harness);

    const frame = harness.machine.renderLcdBitmap();
    const columns = [];
    for (let x = 0; x < frame.width; x += 1) {
      for (let y = 0; y < frame.height; y += 1) {
        if (frame.pixels[(y * frame.width) + x]) {
          columns.push(x);
          break;
        }
      }
    }
    return { first: columns[0], last: columns[columns.length - 1], columns };
  };

  const circle = plot("F2", "8", null, 1);
  assert.equal(circle.first, column(-8), "r=8 reaches its left extreme");
  assert.equal(circle.last, column(8), "r=8 reaches its right extreme");

  const ellipse = plot("F3", "6*COS(X)", "3*SIN(X)", 3);
  assert.equal(ellipse.first, column(-6), "the ellipse reaches its left vertex");
  assert.equal(ellipse.last, column(6), "the ellipse reaches its right vertex");

  // theta starts at 0, so r=10 places a point on the far edge column exactly.
  const wide = plot("F2", "10", null, 1);
  assert.deepEqual(wide.columns, Array.from({ length: 128 }, (_, index) => index),
    "r=10 fills every column including the last");

  // x(t)=y(t)=t carries a point in each column across the band that used to be
  // dropped. It stops one short of column 127 because the parameter accumulates
  // to a hair under 10, not because the column is out of reach.
  const diagonal = plot("F3", "X", "X", 3);
  assert.equal(diagonal.first, 0, "x(t)=y(t)=t starts at the left edge");
  assert.equal(diagonal.last, 126, "x(t)=y(t)=t runs to the last sampled column");
  for (let target = 100; target <= 126; target += 1) {
    assert.ok(diagonal.columns.includes(target), `x(t)=y(t)=t carries column ${target}`);
  }
});

// The statistics plotter mapped its points through a byte-for-byte copy of the
// same broken conversion, but its caller answered 0 for a rejected value rather
// than dropping the point, so a mark in the top sixth of the x range was drawn
// at the LEFT edge — a wrong position that reads as data. The exact maximum
// escaped, because the mapping short-circuits when the value equals the max.
const STATS_LIST_X = 0x8780;
const STATS_LIST_Y = 0x8800;

test("[statistics.right-columns] stat plots place their rightmost marks instead of stacking them at the left edge", () => {
  const writePacked = (harness, address, value) => {
    const [mantissa, exponent] = Math.abs(value).toExponential(13).split("e");
    const digits = mantissa.replace(".", "");
    harness.machine.write8(address, value < 0 ? 0x80 : 0);
    harness.machine.write8(address + 1, Number(exponent) & 0xff);
    for (let index = 0; index < 7; index += 1) {
      harness.machine.write8(address + 2 + index, Number.parseInt(digits.slice(index * 2, index * 2 + 2), 16));
    }
  };

  const plot = (xs, ys, keys) => {
    const harness = Free85Harness.boot();
    harness.tap("STAT");
    harness.machine.write8(STATS_LIST_X, xs.length);
    harness.machine.write8(STATS_LIST_Y, ys.length);
    xs.forEach((value, index) => writePacked(harness, STATS_LIST_X + 1 + (index * 9), value));
    ys.forEach((value, index) => writePacked(harness, STATS_LIST_Y + 1 + (index * 9), value));
    for (const key of keys) harness.tap(key);
    harness.runFrames(2000);
    return harness.machine.renderLcdBitmap();
  };

  // Rows 7..54 are the plotting band; the title and the EXIT footer sit outside
  // it, so every lit pixel in the band belongs to a mark.
  const marks = (frame) => {
    const found = [];
    for (let y = 7; y <= 54; y += 1) {
      for (let x = 0; x < frame.width; x += 1) {
        if (frame.pixels[(y * frame.width) + x]) found.push([x, y]);
      }
    }
    return found.sort(([ax], [bx]) => ax - bx);
  };

  // x = 1..5 maps to columns 4, 33, 63, 93, 123: whole steps that all convert
  // even with the two-digit limit, so this set passed before the fix.
  const wholeSteps = marks(plot([1, 2, 3, 4, 5], [6, 12, 24, 48, 96], ["F4"]));
  assert.deepEqual(wholeSteps, [[4, 54], [33, 51], [63, 45], [93, 33], [123, 7]]);

  // 4.6 of the way to the maximum lands on column 111, inside the band the
  // conversion used to reject. Only that one mark moves.
  const intoTheBand = marks(plot([1, 2, 3, 4.6, 5], [6, 12, 24, 48, 96], ["F4"]));
  assert.deepEqual(intoTheBand, [[4, 54], [33, 51], [63, 45], [111, 33], [123, 7]]);

  // The box plot draws its quartiles through the same mapping. Q3 = 9.4 of a
  // 0..10 range is column 115; it used to be drawn on top of the left whisker.
  const box = plot([0, 1, 2, 9.3, 9.4, 10], [1, 1, 1, 1, 1, 1], ["MORE", "MORE", "F5"]);
  const rules = [];
  for (let x = 0; x < box.width; x += 1) {
    let lit = 0;
    for (let y = 22; y <= 42; y += 1) if (box.pixels[(y * box.width) + x]) lit += 1;
    if (lit >= 15) rules.push(x);
  }
  assert.deepEqual(rules, [15, 71, 115], "Q1, median and Q3 stand at their own columns");
});
