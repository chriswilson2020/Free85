import assert from "node:assert/strict";
import test from "node:test";
import { FREE85_NUMERIC_ERROR_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const GRAPH_ACTIVE = 0x8502;
const GRAPH_XMIN = 0x8600;
const GRAPH_XMAX = 0x8609;
const GRAPH_YMIN = 0x8612;
const GRAPH_YMAX = 0x861b;
const GRAPH_PANEL = 0x8691;
const GRAPH_PANEL_PAGE = 0x8692;
const WINDOW_FIELD = 0x86fc;
const WINDOW_INPUT = 0x86fd;
const WINDOW_ERROR = 0x86fe;
const GRAPH_PANEL_ZOOM = 2;
const GRAPH_PANEL_WINDOW = 4;
const NUM_ERR_DOMAIN = 4;

function typeExpression(harness, expression) {
  for (let index = 0; index < expression.length; index += 1) {
    const character = expression[index];
    if (character === "-" && (index === 0 || "(,+-*/^".includes(expression[index - 1]))) harness.tap("(-)");
    else harness.tap(character);
  }
}

function finishPlot(harness, frameLimit = 6000) {
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) !== 0 && frames < frameLimit) {
    harness.runFrames(100);
    frames += 100;
  }
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0, `plot exceeded ${frameLimit} frames`);
}

function openGraph() {
  const harness = Free85Harness.boot();
  harness.tap("X-VAR");
  harness.tap("GRAPH");
  finishPlot(harness);
  return harness;
}

function openWindow(harness) {
  harness.tap("2ND");
  harness.tap("GRAPH");
  assert.equal(harness.machine.read8(GRAPH_PANEL), GRAPH_PANEL_ZOOM);
  harness.tap("MORE");
  harness.tap("MORE");
  assert.equal(harness.machine.read8(GRAPH_PANEL_PAGE), 2);
  harness.tap("F5");
  assert.equal(harness.machine.read8(GRAPH_PANEL), GRAPH_PANEL_WINDOW);
}

function windowValues(harness) {
  return [GRAPH_XMIN, GRAPH_XMAX, GRAPH_YMIN, GRAPH_YMAX]
    .map((address) => harness.packedNumber(address));
}

function enterField(harness, key, expression) {
  harness.tap(key);
  typeExpression(harness, expression);
  assert.equal(harness.machine.read8(WINDOW_INPUT), 1);
  harness.tap("ENTER");
  assert.equal(harness.machine.read8(WINDOW_INPUT), 0);
  assert.equal(harness.machine.read8(WINDOW_ERROR), 0);
}

test("[phase17.1.window-entry] all four bounds accept evaluated expressions and commit atomically", () => {
  const harness = openGraph();
  openWindow(harness);
  enterField(harness, "F1", "-12.5");
  enterField(harness, "F2", "2*7");
  enterField(harness, "F3", "-3");
  enterField(harness, "F4", "3^2");

  assert.deepEqual(windowValues(harness), [-10, 10, -10, 10], "drafts must not mutate the live window");
  harness.tap("F5");
  finishPlot(harness);
  assert.deepEqual(windowValues(harness), [-12.5, 14, -3, 9]);
  assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0);
});

test("[phase17.1.window-atomic] unordered and malformed bounds preserve the complete live window", () => {
  const harness = openGraph();
  const original = windowValues(harness);
  openWindow(harness);
  enterField(harness, "F1", "5");
  enterField(harness, "F2", "4");
  harness.tap("F5");
  assert.equal(harness.machine.read8(GRAPH_PANEL), GRAPH_PANEL_WINDOW);
  assert.equal(harness.machine.read8(WINDOW_ERROR), NUM_ERR_DOMAIN);
  assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), NUM_ERR_DOMAIN);
  assert.deepEqual(windowValues(harness), original);

  harness.tap("F2");
  typeExpression(harness, "1/");
  harness.tap("ENTER");
  assert.notEqual(harness.machine.read8(WINDOW_ERROR), 0);
  assert.deepEqual(windowValues(harness), original);
});

test("[phase17.1.window-cancel] cancelling an entry or the panel discards every draft", () => {
  const harness = openGraph();
  const original = windowValues(harness);
  openWindow(harness);
  harness.tap("F1");
  typeExpression(harness, "-99");
  harness.tap("EXIT");
  assert.equal(harness.machine.read8(WINDOW_INPUT), 0);
  assert.deepEqual(windowValues(harness), original);
  harness.tap("EXIT");
  assert.equal(harness.machine.read8(GRAPH_PANEL), GRAPH_PANEL_ZOOM);
  assert.equal(harness.machine.read8(GRAPH_PANEL_PAGE), 2);
  assert.deepEqual(windowValues(harness), original);
});

test("[phase17.1.window-ui] the selected field and complete footer fit the LCD", () => {
  const harness = openGraph();
  openWindow(harness);
  assert.equal(harness.machine.read8(WINDOW_FIELD), 0);
  assertLcdGolden("phase17-window-editor", harness.machine.renderLcdBitmap());
});
