import assert from "node:assert/strict";
import test from "node:test";
import { assertLcdGolden, packLcdPixels } from "../helpers/lcd-visual.js";
import {
  GRAPH_PLOT_ACTIVE,
  finishAddress,
  invokeDrawingMenu,
  openPhase15Graph,
  renderPhase15Menu
} from "../helpers/phase15-drawing.js";

const P14_DIRECTORY = 0x9e00;
const P14_ENTRY_SIZE = 16;
const P14_TYPE_PICTURE = 11;
const GRAPH_EQ1 = 0x8510;
const GRAPH_ENABLED = 0x8501;
const OVERLAY_ARMED = 0x9dd5;

function bytes(machine, address, length) {
  return Uint8Array.from({ length }, (_, index) => machine.read8(address + index));
}

function objectEntry(machine, type, name) {
  for (let index = 0; index < 64; index += 1) {
    const entry = P14_DIRECTORY + index * P14_ENTRY_SIZE;
    if ((machine.read8(entry + 1) & 1) === 0 || machine.read8(entry) !== type) continue;
    const entryName = String.fromCharCode(...Array.from(
      { length: machine.read8(entry + 2) },
      (_, offset) => machine.read8(entry + 3 + offset)
    ));
    if (entryName === name) return { address: machine.read16(entry + 11), size: machine.read16(entry + 13) };
  }
  return undefined;
}

function installEquation(harness, expression) {
  harness.machine.write8(GRAPH_EQ1, expression.length);
  [...expression].forEach((character, index) => harness.machine.write8(GRAPH_EQ1 + 1 + index, character.charCodeAt(0)));
  harness.machine.write8(GRAPH_ENABLED, 1);
}

test("[phase17.2.overlay] one graph adds pixels over PIC1 without mutating its object", () => {
  const harness = openPhase15Graph("X");
  invokeDrawingMenu(harness, 2, "F3");
  const picture = objectEntry(harness.machine, P14_TYPE_PICTURE, "PIC1");
  assert.ok(picture);
  const stored = bytes(harness.machine, picture.address, picture.size);

  installEquation(harness, "X^2-4");
  invokeDrawingMenu(harness, 3, "F2");
  assert.equal(harness.machine.read8(OVERLAY_ARMED), 1);
  assert.deepEqual(bytes(harness.machine, picture.address, picture.size), stored);
  harness.tap("GRAPH");
  finishAddress(harness, GRAPH_PLOT_ACTIVE);
  assert.equal(harness.machine.read8(OVERLAY_ARMED), 0, "overlay must be consumed once");
  const overlaid = Uint8Array.from(packLcdPixels(harness.machine.renderLcdBitmap()));
  assert.notDeepEqual(overlaid, stored);
  for (let index = 0; index < stored.length; index += 1) {
    assert.equal(overlaid[index] & stored[index], stored[index], `underlay byte ${index}`);
  }
  assert.deepEqual(bytes(harness.machine, picture.address, picture.size), stored);

  harness.tap("GRAPH");
  finishAddress(harness, GRAPH_PLOT_ACTIVE);
  const ordinary = openPhase15Graph("X^2-4");
  assert.deepEqual(
    packLcdPixels(harness.machine.renderLcdBitmap()),
    packLcdPixels(ordinary.machine.renderLcdBitmap()),
    "the following redraw must clear normally"
  );
});

test("[phase17.2.overlay-cancel] OFF cancels an armed underlay before graphing", () => {
  const harness = openPhase15Graph("X");
  invokeDrawingMenu(harness, 2, "F3");
  installEquation(harness, "X^2-4");
  invokeDrawingMenu(harness, 3, "F2");
  assert.equal(harness.machine.read8(OVERLAY_ARMED), 1);
  invokeDrawingMenu(harness, 3, "F3");
  assert.equal(harness.machine.read8(OVERLAY_ARMED), 0);
  harness.tap("GRAPH");
  finishAddress(harness, GRAPH_PLOT_ACTIVE);
  const ordinary = openPhase15Graph("X^2-4");
  assert.deepEqual(packLcdPixels(harness.machine.renderLcdBitmap()), packLcdPixels(ordinary.machine.renderLcdBitmap()));
});

test("[phase17.2.overlay-missing] OVR without PIC1 fails visibly and stays disarmed", () => {
  const harness = openPhase15Graph();
  invokeDrawingMenu(harness, 3, "F2");
  assert.equal(harness.machine.read8(OVERLAY_ARMED), 0);
  assertLcdGolden("phase17-overlay-missing", harness.machine.renderLcdBitmap());
});

test("[phase17.2.overlay-menu] the complete RCG OVR OFF footer fits the LCD", () => {
  assertLcdGolden("phase15-menu-4", renderPhase15Menu(3).machine.renderLcdBitmap());
});
