import assert from "node:assert/strict";
import test from "node:test";
import { FREE85_UI_MODE_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden, packLcdPixels } from "../helpers/lcd-visual.js";
import {
  GRAPH_CURSOR_MODE,
  P15_ACTIVE,
  PHASE15_GOLDEN_CASES,
  PHASE15_MENU_CASES,
  finishAddress,
  invokeDrawingMenu,
  openPhase15Graph,
  renderPhase15Case,
  renderPhase15Menu
} from "../helpers/phase15-drawing.js";

const LCD_FRAMEBUFFER = 0xfc00;
const P14_COUNT = 0x9d84;
const P14_DIRECTORY = 0x9e00;
const P14_ENTRY_SIZE = 16;
const P14_TYPE_GRAPH_DB = 10;
const P14_TYPE_PICTURE = 11;
const GRAPH_ACTIVE_SLOT = 0x8500;
const GRAPH_ENABLED = 0x8501;
const GRAPH_EQ1 = 0x8510;
const GRAPH_XMIN = 0x8600;
const GRAPH_TABLE_START = 0x8636;
const GRAPH_FORMAT = 0x8690;
const GRAPH_MODE = 0x869a;
const GRAPH_ZOOM_FACTOR = 0x86a0;
const P10_EXISTS = 0x9510;
const P10_NAMES = 0x9520;
const P10_DATA = 0x9540;

function bytes(machine, address, length) {
  return Uint8Array.from({ length }, (_, index) => machine.read8(address + index));
}

function objectEntry(machine, type, name) {
  for (let index = 0; index < 64; index += 1) {
    const entry = P14_DIRECTORY + index * P14_ENTRY_SIZE;
    if ((machine.read8(entry + 1) & 1) === 0 || machine.read8(entry) !== type) continue;
    const entryName = String.fromCharCode(...Array.from({ length: machine.read8(entry + 2) }, (_, offset) => machine.read8(entry + 3 + offset)));
    if (entryName === name) return {
      address: machine.read16(entry + 11),
      size: machine.read16(entry + 13)
    };
  }
  return undefined;
}

function installProgram(harness, lines) {
  harness.machine.write8(P10_EXISTS, 1);
  for (const [index, character] of [..."DRAWTEST\0"].entries()) harness.machine.write8(P10_NAMES + index, character.charCodeAt(0));
  for (let line = 0; line < lines.length; line += 1) {
    const address = P10_DATA + line * 49;
    harness.machine.write8(address, lines[line].length);
    for (let index = 0; index < lines[line].length; index += 1) harness.machine.write8(address + 1 + index, lines[line].charCodeAt(index));
  }
}

test("[graph.phase15-draw] every drawing primitive has an exact LCD golden", () => {
  for (const drawingCase of PHASE15_GOLDEN_CASES) {
    const harness = renderPhase15Case(drawingCase);
    assert.equal(harness.machine.read8(GRAPH_CURSOR_MODE), 0, drawingCase.name);
    assert.equal(harness.machine.read8(P15_ACTIVE), 0, drawingCase.name);
    assertLcdGolden(drawingCase.name, harness.machine.renderLcdBitmap());
  }
});

test("[graph.phase15-menu] every compact drawing-menu page has an exact LCD golden", () => {
  for (const menuCase of PHASE15_MENU_CASES) {
    assertLcdGolden(menuCase.name, renderPhase15Menu(menuCase.page).machine.renderLcdBitmap());
  }
});

test("[graph.phase15-cancel] incremental drawing cancels immediately", () => {
  const harness = openPhase15Graph();
  invokeDrawingMenu(harness, 0, "F5");
  harness.runFrames(12);
  assert.notEqual(harness.machine.read8(P15_ACTIVE), 0);
  harness.tap("EXIT", 20, 4);
  assert.equal(harness.machine.read8(P15_ACTIVE), 0);
});

test("[graph.phase15-picture] StPic/RcPic round-trip all 1024 framebuffer bytes", () => {
  const harness = renderPhase15Case(PHASE15_GOLDEN_CASES[0]);
  const expected = Uint8Array.from(packLcdPixels(harness.machine.renderLcdBitmap()));
  const initialCount = harness.machine.read8(P14_COUNT);
  invokeDrawingMenu(harness, 2, "F3");
  assert.equal(harness.machine.read8(P14_COUNT), initialCount + 1);
  const picture = objectEntry(harness.machine, P14_TYPE_PICTURE, "PIC1");
  assert.ok(picture);
  assert.equal(picture.size, 1024);
  assert.deepEqual(bytes(harness.machine, picture.address, picture.size), expected);
  for (let index = 0; index < 1024; index += 1) harness.machine.write8(LCD_FRAMEBUFFER + index, (index * 37) & 0xff);
  invokeDrawingMenu(harness, 2, "F4");
  assert.deepEqual(Uint8Array.from(packLcdPixels(harness.machine.renderLcdBitmap())), expected);
  invokeDrawingMenu(harness, 2, "F3");
  assert.equal(harness.machine.read8(P14_COUNT), initialCount + 1, "re-store must replace PIC1 without leaking an object");
});

test("[graph.phase15-gdb] StGDB/RcGDB preserve exact graph settings and equations", () => {
  const harness = openPhase15Graph("X^2");
  const expected = {
    header: Uint8Array.of(1, harness.machine.read8(GRAPH_FORMAT), harness.machine.read8(GRAPH_ENABLED), harness.machine.read8(GRAPH_ACTIVE_SLOT), harness.machine.read8(GRAPH_MODE)),
    window: bytes(harness.machine, GRAPH_XMIN, 36),
    zoom: bytes(harness.machine, GRAPH_ZOOM_FACTOR, 9),
    table: bytes(harness.machine, GRAPH_TABLE_START, 18),
    equations: bytes(harness.machine, GRAPH_EQ1, 147)
  };
  invokeDrawingMenu(harness, 2, "F5");
  const gdb = objectEntry(harness.machine, P14_TYPE_GRAPH_DB, "GDB1");
  assert.ok(gdb);
  assert.equal(gdb.size, 215);
  assert.deepEqual(bytes(harness.machine, gdb.address, 215), Uint8Array.from([
    ...expected.header, ...expected.window, ...expected.zoom, ...expected.table, ...expected.equations
  ]));
  for (const [address, length] of [[GRAPH_XMIN, 36], [GRAPH_ZOOM_FACTOR, 9], [GRAPH_TABLE_START, 18], [GRAPH_EQ1, 147]]) {
    for (let index = 0; index < length; index += 1) harness.machine.write8(address + index, 0xa5);
  }
  harness.machine.write8(GRAPH_FORMAT, 0);
  harness.machine.write8(GRAPH_ENABLED, 0);
  harness.machine.write8(GRAPH_ACTIVE_SLOT, 0);
  harness.machine.write8(GRAPH_MODE, 0);
  invokeDrawingMenu(harness, 3, "F1");
  assert.deepEqual(bytes(harness.machine, GRAPH_XMIN, 36), expected.window);
  assert.deepEqual(bytes(harness.machine, GRAPH_ZOOM_FACTOR, 9), expected.zoom);
  assert.deepEqual(bytes(harness.machine, GRAPH_TABLE_START, 18), expected.table);
  assert.deepEqual(bytes(harness.machine, GRAPH_EQ1, 147), expected.equations);
  assert.deepEqual(Uint8Array.of(harness.machine.read8(GRAPH_FORMAT), harness.machine.read8(GRAPH_ENABLED), harness.machine.read8(GRAPH_ACTIVE_SLOT), harness.machine.read8(GRAPH_MODE)), expected.header.slice(1));
  finishAddress(harness, 0x8502);
});

test("[graph.phase15-program] every drawing operation is program-callable", () => {
  for (const code of "0123456789AB") {
    const harness = Free85Harness.boot();
    harness.machine.write8(GRAPH_EQ1, 1);
    harness.machine.write8(GRAPH_EQ1 + 1, "X".charCodeAt(0));
    harness.machine.write8(GRAPH_ENABLED, 1);
    installProgram(harness, ["32->A", "20->B", "70->C", "40->D", `DRAW ${code}`]);
    harness.tap("PRGM");
    harness.tap("F3");
    harness.runFrames(40);
    try {
      finishAddress(harness, P15_ACTIVE);
    } catch (error) {
      throw new Error(`DRAW ${code}: ${error.message}`);
    }
    assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 2, code);
    assert.equal(harness.machine.read8(0x9506), 0, code);
  }

  const invalid = Free85Harness.boot();
  installProgram(invalid, ["200->A", "DRAW 1"]);
  invalid.tap("PRGM");
  invalid.tap("F3");
  invalid.runFrames(30);
  assert.equal(invalid.machine.read8(FREE85_UI_MODE_ADDRESS), 18);
  assert.equal(invalid.machine.read8(0x9506), 1);

  for (const [storeCode, recallCode, type, name] of [
    ["C", "D", P14_TYPE_PICTURE, "PIC1"],
    ["E", "F", P14_TYPE_GRAPH_DB, "GDB1"]
  ]) {
    const harness = Free85Harness.boot();
    installProgram(harness, [`DRAW ${storeCode}`]);
    harness.tap("PRGM");
    harness.tap("F3");
    harness.runFrames(30);
    assert.ok(objectEntry(harness.machine, type, name), storeCode);
    installProgram(harness, [`DRAW ${recallCode}`]);
    harness.tap("PRGM");
    harness.tap("F3");
    harness.runFrames(30);
    assert.equal(harness.machine.read8(0x9506), 0, recallCode);
    assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 2, recallCode);
  }
});
