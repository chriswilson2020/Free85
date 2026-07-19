import assert from "node:assert/strict";
import test from "node:test";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import { FREE85_NUMERIC_ERROR_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const GRAPH_ACTIVE = 0x8502;
const GRAPH_PLOT_X = 0x8503;
const GRAPH_TRACE_X = 0x8504;
const GRAPH_ENABLED = 0x8501;
const GRAPH_TOLERANCE_EXPONENT = 0x8649;
const SCREEN_HOME = 0;
const SCREEN_GRAPH = 2;
const SCREEN_TABLE = 3;
const alphaKeys = new Map(TI85_PHYSICAL_KEYS
  .filter(({ alpha }) => /^[A-Z]$/.test(alpha ?? ""))
  .map(({ alpha, key }) => [alpha, key]));

function typeExpression(harness, expression) {
  for (let index = 0; index < expression.length; index += 1) {
    const character = expression[index];
    if (/[A-Z]/.test(character)) {
      harness.tap("ALPHA");
      harness.tap(alphaKeys.get(character));
    } else if (character === "-" && (index === 0 || "(,+-*/^".includes(expression[index - 1]))) {
      harness.tap("(-)");
    } else {
      harness.tap(character);
    }
  }
}

function openGraph(expression) {
  const harness = Free85Harness.boot();
  typeExpression(harness, expression);
  harness.tap("GRAPH");
  return harness;
}

function finishPlot(harness, frameLimit = 4000) {
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) !== 0 && frames < frameLimit) {
    harness.runFrames(100);
    frames += 100;
  }
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0, `plot exceeded ${frameLimit} frames`);
}

function numericResult(harness) {
  return Number(harness.resultText());
}

function lcdPixel(bitmap, x, y) {
  return bitmap.pixels[(y * bitmap.width) + x];
}

function sinePixelY(x) {
  const graphX = -10 + ((20 * x) / 127);
  return 63 - Math.trunc(((5 * Math.sin(graphX) + 10) / 20) * 63);
}

function assertConnectedSineGeometry(bitmap) {
  let longestVerticalRun = 0;
  for (let x = 0; x < bitmap.width; x += 1) {
    const currentY = sinePixelY(x);
    assert.equal(lcdPixel(bitmap, x, currentY), 1, `missing sine sample at x=${x}, y=${currentY}`);
    if (x > 0) {
      const previousY = sinePixelY(x - 1);
      for (let y = Math.min(previousY, currentY); y <= Math.max(previousY, currentY); y += 1) {
        assert.equal(lcdPixel(bitmap, x, y), 1, `disconnected sine segment at x=${x}, y=${y}`);
      }
    }
    if (x === 64) continue;
    let run = 0;
    for (let y = 0; y < bitmap.height; y += 1) {
      run = lcdPixel(bitmap, x, y) ? run + 1 : 0;
      longestVerticalRun = Math.max(longestVerticalRun, run);
    }
  }
  assert.ok(longestVerticalRun <= 5, `bounded sine contains a ${longestVerticalRun}-pixel vertical stroke`);
  for (const y of [0, 1, 2, 3, 4, 5, 6, 7, 57, 58, 59, 60, 61, 62, 63]) {
    for (let x = 0; x < bitmap.width; x += 1) {
      if (x !== 64) assert.equal(lcdPixel(bitmap, x, y), 0, `sine escaped its expected Y range at x=${x}, y=${y}`);
    }
  }
}

test("[graph.plot] plots incrementally and survives discontinuities", () => {
  const continuous = openGraph("X^2-4");
  assert.equal(continuous.machine.read8(0x800b), SCREEN_GRAPH);
  assert.equal(continuous.machine.read8(GRAPH_ACTIVE), 1);
  continuous.runFrames(600);
  assert.equal(continuous.machine.read8(GRAPH_ACTIVE), 0);
  assert.equal(continuous.machine.read8(GRAPH_PLOT_X), 128);
  assertLcdGolden("parabola", continuous.machine.renderLcdBitmap());

  const discontinuous = openGraph("1/X");
  discontinuous.runFrames(600);
  assert.equal(discontinuous.machine.read8(0x800b), SCREEN_GRAPH);
  assert.equal(discontinuous.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0);
  assert.equal(discontinuous.machine.read8(GRAPH_ACTIVE), 0);
  const reciprocalBitmap = discontinuous.machine.renderLcdBitmap();
  assert.deepEqual(
    Array.from({ length: reciprocalBitmap.height }, (_, y) => y).filter((y) => lcdPixel(reciprocalBitmap, 63, y)),
    [32],
    "1/X must leave a blank sample column at its discontinuity"
  );
  assertLcdGolden("reciprocal", reciprocalBitmap);

  const partialDomain = openGraph("SQRT(X)");
  partialDomain.runFrames(1200);
  assert.equal(partialDomain.machine.read8(0x800b), SCREEN_GRAPH);
  assert.equal(partialDomain.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0);
  assert.equal(partialDomain.machine.read8(GRAPH_ACTIVE), 0);
  assertLcdGolden("square-root", partialDomain.machine.renderLcdBitmap());
});

test("[graph.render-golden] adjacent sine samples form a connected curve", () => {
  const harness = openGraph("5*SIN(X)");
  finishPlot(harness);
  const bitmap = harness.machine.renderLcdBitmap();
  assertConnectedSineGeometry(bitmap);
  assertLcdGolden("sine-5x", bitmap);
});

test("[graph.cancel] EXIT cancels an in-progress redraw and preserves the equation", () => {
  const harness = openGraph("X^2+1");
  harness.runFrames(20);
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 1);
  harness.tap("EXIT");
  harness.runFrames(30);
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0);
  assert.equal(harness.machine.read8(0x800b), SCREEN_HOME);
  assert.equal(harness.editorText(), "X^2+1");
});

test("[graph.trace-zoom-table] trace, zoom, grid, and scrolling table are reachable", () => {
  const harness = openGraph("X");
  harness.runFrames(600);
  harness.tap("RIGHT");
  harness.runFrames(20);
  assert.equal(harness.machine.read8(GRAPH_TRACE_X), 65);
  harness.tap("+");
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 1);
  harness.tap(".");
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 1);
  harness.tap("MORE");
  harness.runFrames(50);
  assert.equal(harness.machine.read8(0x800b), SCREEN_TABLE);
  harness.tap("DOWN");
  harness.runFrames(50);
  assert.equal(harness.machine.read8(0x800b), SCREEN_TABLE);
  harness.tap("EXIT");
  assert.equal(harness.machine.read8(0x800b), SCREEN_GRAPH);
});

test("[graph.equations-intersection] three selectable slots share the graph engine", () => {
  const harness = openGraph("X");
  harness.runFrames(20);
  harness.tap("2ND");
  harness.tap("2");
  assert.equal(harness.machine.read8(0x800b), SCREEN_HOME);
  assert.equal(harness.editorText(), "");
  harness.runFrames(10);
  typeExpression(harness, "2-X");
  harness.tap("GRAPH");
  assert.equal(harness.machine.read8(GRAPH_ENABLED) & 3, 3);
  harness.runFrames(1200);
  harness.tap("2ND");
  harness.tap("F1");
  harness.runFrames(3500);
  assert.equal(harness.machine.read8(0x800b), SCREEN_HOME);
  assert.ok(Math.abs(numericResult(harness) - 1) < 1e-5, harness.resultText());
});

test("[graph.numerical] roots, extrema, derivatives, integrals, and solver use stored equations", () => {
  const root = openGraph("X^2-4");
  root.runFrames(600);
  root.tap("F1");
  root.runFrames(1000);
  assert.ok(Math.abs(Math.abs(numericResult(root)) - 2) < 1e-5, root.resultText());

  const minimum = openGraph("X^2");
  minimum.runFrames(600);
  minimum.tap("F2");
  minimum.runFrames(1500);
  assert.ok(Math.abs(numericResult(minimum)) < 0.002, minimum.resultText());

  const derivative = openGraph("2*X+3");
  derivative.runFrames(600);
  derivative.tap("F4");
  derivative.runFrames(500);
  assert.ok(Math.abs(numericResult(derivative) - 2) < 1e-8, derivative.resultText());

  const integral = openGraph("X^2");
  integral.runFrames(600);
  integral.tap("F5");
  integral.runFrames(1500);
  assert.ok(Math.abs(numericResult(integral) - 2000 / 3) < 1e-8, integral.resultText());

  const solver = Free85Harness.boot();
  typeExpression(solver, "X^2-4");
  solver.tap("2ND");
  solver.tap("GRAPH");
  solver.runFrames(1100);
  assert.ok(Math.abs(Math.abs(numericResult(solver)) - 2) < 1e-5, solver.resultText());
});

test("[graph.tolerance] shifted TOLER cycles numerical convergence settings", () => {
  const harness = Free85Harness.boot();
  assert.equal(harness.machine.read8(GRAPH_TOLERANCE_EXPONENT), 0xfa);
  harness.tap("2ND");
  harness.tap("CLEAR");
  assert.equal(harness.machine.read8(GRAPH_TOLERANCE_EXPONENT), 0xf8);
  harness.tap("EXIT");
  harness.tap("2ND");
  harness.tap("CLEAR");
  assert.equal(harness.machine.read8(GRAPH_TOLERANCE_EXPONENT), 0xf6);
});
