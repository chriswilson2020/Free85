import assert from "node:assert/strict";
import test from "node:test";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import { FREE85_NUMERIC_ERROR_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden, packLcdPixels } from "../helpers/lcd-visual.js";

const GRAPH_ENABLED = 0x8501;
const GRAPH_ACTIVE = 0x8502;
const GRAPH_EQ2 = 0x8541;
const GRAPH_XMIN = 0x8600;
const GRAPH_XMAX = 0x8609;
const GRAPH_YMIN = 0x8612;
const GRAPH_YMAX = 0x861b;
const GRAPH_FORMAT = 0x8690;
const GRAPH_PANEL = 0x8691;
const GRAPH_PANEL_PAGE = 0x8692;
const GRAPH_DRAW_SLOT = 0x8693;
const GRAPH_CURSOR_X = 0x8694;
const GRAPH_CURSOR_Y = 0x8695;
const GRAPH_CURSOR_MODE = 0x8696;
const GRAPH_BOX_STATE = 0x8697;
const GRAPH_ZOOM_FACTOR = 0x86a0;
const SCREEN_HOME = 0;
const SCREEN_GRAPH = 2;
const FORMAT_AXES = 0x01;
const FORMAT_COORD = 0x02;
const FORMAT_LABEL = 0x04;
const FORMAT_GRID = 0x08;
const FORMAT_LINE = 0x10;
const FORMAT_SIMUL = 0x20;
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

function openGraph(expression = "X") {
  const harness = Free85Harness.boot();
  typeExpression(harness, expression);
  harness.tap("GRAPH");
  finishPlot(harness);
  return harness;
}

function finishPlot(harness, frameLimit = 6000) {
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) !== 0 && frames < frameLimit) {
    harness.runFrames(100);
    frames += 100;
  }
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0, `plot exceeded ${frameLimit} frames`);
}

function openFormat(harness) {
  harness.tap("2ND");
  harness.tap("MORE");
  assert.equal(harness.machine.read8(GRAPH_PANEL), 1);
}

function openZoom(harness) {
  harness.tap("2ND");
  harness.tap("GRAPH");
  assert.equal(harness.machine.read8(GRAPH_PANEL), 2);
}

function installEquation(machine, address, expression) {
  machine.write8(address, expression.length);
  for (const [index, character] of [...expression].entries()) {
    machine.write8(address + 1 + index, character.charCodeAt(0));
  }
}

function windowValues(harness) {
  return [GRAPH_XMIN, GRAPH_XMAX, GRAPH_YMIN, GRAPH_YMAX]
    .map((address) => harness.packedNumber(address));
}

function assertWindow(harness, expected, epsilon = 1e-10) {
  const actual = windowValues(harness);
  for (let index = 0; index < expected.length; index += 1) {
    assert.ok(Math.abs(actual[index] - expected[index]) <= epsilon,
      `window[${index}] expected ${expected[index]}, got ${actual[index]}`);
  }
}

test("[graph.phase14-format] persistent format, draw, sequence, and FnOn/FnOff controls", () => {
  const harness = openGraph("X^2-4");
  assert.equal(harness.machine.read8(GRAPH_FORMAT),
    FORMAT_AXES | FORMAT_COORD | FORMAT_GRID | FORMAT_LINE | FORMAT_SIMUL);

  openFormat(harness);
  for (const key of ["F1", "F2", "F3", "F4", "F5"]) harness.tap(key);
  assert.equal(harness.machine.read8(GRAPH_FORMAT), FORMAT_LABEL | FORMAT_SIMUL);
  harness.tap("MORE");
  assert.equal(harness.machine.read8(GRAPH_PANEL_PAGE), 1);
  harness.tap("F1");
  harness.tap("F2");
  assert.equal(harness.machine.read8(GRAPH_FORMAT), FORMAT_LABEL);
  assert.equal(harness.machine.read8(GRAPH_ENABLED) & 1, 0);
  harness.tap("F2");
  assert.equal(harness.machine.read8(GRAPH_ENABLED) & 1, 1);
  harness.tap("EXIT");
  finishPlot(harness);
  assert.equal(harness.machine.read8(GRAPH_PANEL), 0);
  assert.equal(harness.machine.read8(GRAPH_FORMAT), FORMAT_LABEL);
  assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0);
  assertLcdGolden("phase14-dot-format", harness.machine.renderLcdBitmap());
});

test("[graph.phase14-render] sequential and simultaneous drawing produce identical curves", () => {
  const harness = openGraph("X");
  installEquation(harness.machine, GRAPH_EQ2, "-X");
  harness.machine.write8(GRAPH_ENABLED, 3);
  harness.tap("GRAPH");
  finishPlot(harness);
  const simultaneous = packLcdPixels(harness.machine.renderLcdBitmap());

  openFormat(harness);
  harness.tap("MORE");
  harness.tap("F1");
  harness.tap("EXIT");
  finishPlot(harness);
  const sequential = packLcdPixels(harness.machine.renderLcdBitmap());
  assert.deepEqual(sequential, simultaneous);
  assert.equal(harness.machine.read8(GRAPH_DRAW_SLOT), 0);
});

test("[graph.phase14-cursor] free cursor reports a movable graph coordinate", () => {
  const harness = openGraph();
  harness.tap("UP");
  assert.equal(harness.machine.read8(GRAPH_CURSOR_MODE), 1);
  assert.deepEqual([harness.machine.read8(GRAPH_CURSOR_X), harness.machine.read8(GRAPH_CURSOR_Y)], [64, 31]);
  harness.tap("RIGHT");
  harness.tap("DOWN");
  assert.deepEqual([harness.machine.read8(GRAPH_CURSOR_X), harness.machine.read8(GRAPH_CURSOR_Y)], [65, 32]);
  harness.tap("EXIT");
  finishPlot(harness);
  assert.equal(harness.machine.read8(GRAPH_CURSOR_MODE), 0);
});

test("[graph.phase14-zoom] presets, factors, previous window, and recall are consistent", () => {
  const harness = openGraph();
  openZoom(harness);
  harness.tap("MORE");
  harness.tap("F1");
  finishPlot(harness);
  assertWindow(harness, [-6.3, 6.3, -3.1, 3.1]);

  openZoom(harness);
  harness.tap("MORE");
  harness.tap("F3");
  finishPlot(harness);
  assertWindow(harness, [-63, 64, -31, 32]);

  openZoom(harness);
  harness.tap("MORE");
  harness.tap("F5");
  finishPlot(harness);
  assertWindow(harness, [-2 * Math.PI, 2 * Math.PI, -4, 4], 1e-12);

  openZoom(harness);
  harness.tap("MORE");
  harness.tap("F4");
  finishPlot(harness);
  assertWindow(harness, [-63, 64, -31, 32]);

  openZoom(harness);
  harness.tap("MORE");
  harness.tap("MORE");
  harness.tap("F1");
  finishPlot(harness);
  harness.tap("+");
  finishPlot(harness);
  openZoom(harness);
  harness.tap("MORE");
  harness.tap("MORE");
  harness.tap("F2");
  finishPlot(harness);
  assertWindow(harness, [-63, 64, -31, 32]);

  openZoom(harness);
  harness.tap("MORE");
  harness.tap("MORE");
  harness.tap("F4");
  assert.equal(harness.packedNumber(GRAPH_ZOOM_FACTOR), 4);
  harness.tap("EXIT");
  finishPlot(harness);
});

test("[graph.phase14-box-fit] box selection and ZFit derive bounded numeric windows", () => {
  const box = openGraph();
  openZoom(box);
  box.tap("F1");
  assert.equal(box.machine.read8(GRAPH_CURSOR_MODE), 2);
  box.tap("ENTER");
  assert.equal(box.machine.read8(GRAPH_BOX_STATE), 1);
  for (let count = 0; count < 20; count += 1) box.tap("RIGHT");
  for (let count = 0; count < 16; count += 1) box.tap("DOWN");
  const cursorX = box.machine.read8(GRAPH_CURSOR_X);
  const cursorY = box.machine.read8(GRAPH_CURSOR_Y);
  assert.ok(cursorX > 32 && cursorY > 16);
  box.tap("ENTER");
  box.runFrames(200);
  finishPlot(box);
  assertWindow(box, [
    -10 + ((20 * 32) / 127),
    -10 + ((20 * cursorX) / 127),
    10 - ((20 * cursorY) / 63),
    10 - ((20 * 16) / 63)
  ], 1e-10);

  const fit = openGraph("X^2");
  openZoom(fit);
  fit.tap("MORE");
  fit.tap("F2");
  fit.runFrames(2000);
  finishPlot(fit, 10000);
  const [, , ymin, ymax] = windowValues(fit);
  assert.ok(ymin < 0 && ymin > -11, `unexpected fitted ymin ${ymin}`);
  assert.ok(ymax > 100 && ymax < 111, `unexpected fitted ymax ${ymax}`);
});

test("[graph.phase14-window-vars] graph window names are readable numeric values", () => {
  const harness = Free85Harness.boot();
  typeExpression(harness, "XMIN+XMAX+YMIN+YMAX");
  harness.tap("ENTER");
  assert.equal(Number(harness.resultText()), 0);
  assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0);
});

test("[graph.phase14-cancel] redraw remains cancellable in sequential mode", () => {
  const harness = openGraph("X^2+1");
  openFormat(harness);
  harness.tap("MORE");
  harness.tap("F1");
  harness.tap("EXIT");
  harness.runFrames(20);
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 1);
  harness.tap("EXIT");
  harness.runFrames(30);
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0);
  assert.equal(harness.machine.read8(0x800b), SCREEN_HOME);
  assert.equal(harness.editorText(), "X^2+1");
  assert.notEqual(harness.machine.read8(0x800b), SCREEN_GRAPH);
});
