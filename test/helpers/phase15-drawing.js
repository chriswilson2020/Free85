import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import { Free85Harness } from "./free85-harness.js";

export const GRAPH_PLOT_ACTIVE = 0x8502;
export const GRAPH_CURSOR_MODE = 0x8696;
export const P15_ACTIVE = 0x9dc7;

const alphaKeys = new Map(TI85_PHYSICAL_KEYS
  .filter(({ alpha }) => /^[A-Z]$/.test(alpha ?? ""))
  .map(({ alpha, key }) => [alpha, key]));

function typeExpression(harness, expression) {
  for (const character of expression) {
    if (/[A-Z]/.test(character)) {
      harness.tap("ALPHA");
      harness.tap(alphaKeys.get(character));
    } else {
      harness.tap(character);
    }
  }
}

export function finishAddress(harness, address, frameLimit = 5000) {
  let frames = 0;
  while (harness.machine.read8(address) !== 0 && frames < frameLimit) {
    harness.runFrames(100);
    frames += 100;
  }
  if (harness.machine.read8(address) !== 0) throw new Error(`operation at ${address.toString(16)} exceeded ${frameLimit} frames`);
}

export function openPhase15Graph(expression = "X") {
  const harness = Free85Harness.boot();
  typeExpression(harness, expression);
  harness.tap("GRAPH");
  finishAddress(harness, GRAPH_PLOT_ACTIVE);
  return harness;
}

function openDrawingPage(harness, page) {
  harness.tap("CUSTOM");
  for (let index = 0; index < page; index += 1) harness.tap("MORE");
}

function move(harness, key, count) {
  for (let index = 0; index < count; index += 1) harness.tap(key);
}

export const PHASE15_GOLDEN_CASES = [
  { name: "phase15-line", page: 0, key: "F1", action(h) { h.tap("ENTER"); move(h, "RIGHT", 12); move(h, "DOWN", 6); h.tap("ENTER"); } },
  { name: "phase15-vertical", page: 0, key: "F2", action(h) { move(h, "RIGHT", 10); h.tap("ENTER"); } },
  { name: "phase15-circle", page: 0, key: "F3", action(h) { h.tap("ENTER"); move(h, "RIGHT", 10); h.tap("ENTER"); } },
  { name: "phase15-tangent", page: 0, key: "F4", action(h) { h.tap("ENTER", 20, 4); } },
  { name: "phase15-shade", page: 0, key: "F5", incremental: true },
  { name: "phase15-point-on", page: 1, key: "F1", action(h) { move(h, "RIGHT", 6); move(h, "UP", 4); h.tap("ENTER"); } },
  { name: "phase15-point-off", page: 1, key: "F2", action(h) { move(h, "RIGHT", 6); h.tap("ENTER"); } },
  { name: "phase15-point-change", page: 1, key: "F3", action(h) { move(h, "RIGHT", 8); h.tap("ENTER"); } },
  { name: "phase15-draw-function", page: 1, key: "F4", incremental: true },
  { name: "phase15-inverse", page: 1, key: "F5", incremental: true },
  { name: "phase15-pen", page: 2, key: "F1", action(h) { move(h, "RIGHT", 8); move(h, "UP", 5); move(h, "LEFT", 4); h.tap("EXIT"); } },
  { name: "phase15-clear", page: 2, key: "F2" }
];

export const PHASE15_MENU_CASES = Array.from({ length: 4 }, (_, page) => ({
  name: `phase15-menu-${page + 1}`,
  page
}));

export function renderPhase15Case(drawingCase) {
  const harness = openPhase15Graph();
  openDrawingPage(harness, drawingCase.page);
  harness.tap(drawingCase.key);
  drawingCase.action?.(harness);
  if (drawingCase.incremental) finishAddress(harness, P15_ACTIVE);
  finishAddress(harness, GRAPH_PLOT_ACTIVE);
  return harness;
}

export function invokeDrawingMenu(harness, page, key) {
  openDrawingPage(harness, page);
  harness.tap(key);
}

export function renderPhase15Menu(page) {
  const harness = openPhase15Graph();
  openDrawingPage(harness, page);
  return harness;
}
