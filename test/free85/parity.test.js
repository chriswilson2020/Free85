import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import {
  FREE85_MODIFIERS_ADDRESS,
  FREE85_UI_MODE_ADDRESS,
  Free85Harness
} from "../helpers/free85-harness.js";

const ANGLE_MODE_ADDRESS = 0x801a;
const VARIABLES_ADDRESS = 0x8218;
const P11_DISPLAY_MODE_ADDRESS = 0x9d03;
const P11_CONTRAST_ADDRESS = 0x9d04;
const P11_LINK_STATE_ADDRESS = 0x9d05;
const P11_OUTPUT_BUFFER_ADDRESS = 0x9d60;
const DIALOG_KIND_ADDRESS = 0x8019;

function shifted(harness, key) {
  harness.tap("2ND");
  harness.tap(key);
}

function zeroTerminated(machine, address, capacity = 32) {
  const bytes = [];
  for (let index = 0; index < capacity; index += 1) {
    const byte = machine.read8(address + index);
    if (byte === 0) break;
    bytes.push(byte);
  }
  return String.fromCharCode(...bytes);
}

test("[parity.surfaces] every remaining menu and application opens a native screen", () => {
  for (const [key, screen] of [
    ["MORE", 20], ["X-VAR", 28], ["*", 21], ["4", 22], ["5", 23],
    ["STO▶", 26], ["1", 24], ["2", 25], ["3", 26], ["+", 27]
  ]) {
    const harness = Free85Harness.boot();
    shifted(harness, key);
    assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), screen, key);
  }

  const pageTwo = Free85Harness.boot();
  pageTwo.tap("MORE");
  pageTwo.tap("F5");
  assert.equal(pageTwo.machine.read8(FREE85_UI_MODE_ADDRESS), 15);
});

test("[parity.memory-slots] M1-M5 store, recall, and persist packed decimal values", () => {
  for (const key of ["F1", "F2", "F3", "F4", "F5"]) {
    const harness = Free85Harness.boot();
    harness.tap("5");
    shifted(harness, key);
    assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 1);
    harness.tap("EXIT");
    harness.tap("CLEAR");
    shifted(harness, key);
    assert.equal(harness.resultText(), "5", key);

    harness.machine.reset();
    harness.runFrames(35);
    shifted(harness, key);
    assert.equal(harness.resultText(), "5", `${key} after reset`);
  }
});

test("[parity.alpha-lower] shifted ALPHA selects lowercase one-shot and lock input", () => {
  const harness = Free85Harness.boot();
  shifted(harness, "ALPHA");
  assert.equal(harness.machine.read8(FREE85_MODIFIERS_ADDRESS) & 0x08, 0x08);
  harness.tap("ALPHA");
  harness.tap("LOG");
  assert.equal(harness.editorText(), "a");
  harness.tap("ALPHA");
  harness.tap("ALPHA");
  harness.tap("SIN");
  harness.tap("COS");
  assert.equal(harness.editorText(), "abc");
});

test("[parity.menus] math, constants, and conversions insert callable expressions", () => {
  const menus = [
    ["*", ["ABS(", "SQRT(", "FACT(", "NPR(", "NCR(", "SINH(", "COSH(", "TANH(", "ASINH(", "ACOSH("]],
    ["4", ["PI", "E", "LIGHT", "GRAV", "PLANCK", "BOLTZ", "AVOG"]],
    ["5", ["CMIN(", "INCM(", "SQMFT(", "SQFTM(", "LGAL(", "GALL(", "KGLB(", "LBKG(", "CTOF(", "FTOC(", "MINS(", "SMIN(", "KMHMPH(", "MPHKMH(", "BARPSI(", "PSIBAR(", "JCAL(", "CALJ(", "WHP(", "HPW(", "RAD(", "DEG("]]
  ];
  const softKeys = ["F1", "F2", "F3", "F4", "F5"];
  for (const [openKey, entries] of menus) {
    for (const [index, expected] of entries.entries()) {
      const harness = Free85Harness.boot();
      shifted(harness, openKey);
      for (let page = 0; page < Math.floor(index / 5); page += 1) harness.tap("MORE");
      harness.tap(softKeys[index % 5]);
      assert.equal(harness.editorText(), expected, `${openKey} item ${index + 1}`);
    }
  }
});

test("[parity.tests] all relational operators evaluate to calculator booleans", () => {
  for (const { left, page = 0, key, right, expected } of [
    { left: "2", key: "F1", right: "2", expected: "1" },
    { left: "2", key: "F2", right: "3", expected: "1" },
    { left: "2", key: "F3", right: "3", expected: "1" },
    { left: "3", key: "F4", right: "3", expected: "1" },
    { left: "4", key: "F5", right: "3", expected: "1" },
    { left: "3", page: 1, key: "F1", right: "3", expected: "1" }
  ]) {
    const harness = Free85Harness.boot();
    harness.tap(left);
    shifted(harness, "2");
    if (page) harness.tap("MORE");
    harness.tap(key);
    harness.tap(right);
    harness.tap("ENTER");
    assert.equal(harness.resultText(), expected, harness.editorText());
  }

  const negative = Free85Harness.boot();
  negative.tap("(-)");
  negative.tap("2");
  shifted(negative, "2");
  negative.tap("F3");
  negative.tap("(-)");
  negative.tap("1");
  negative.tap("ENTER");
  assert.equal(negative.resultText(), "1");

  const falseResult = Free85Harness.boot();
  falseResult.tap("3");
  shifted(falseResult, "2");
  falseResult.tap("F3");
  falseResult.tap("2");
  falseResult.tap("ENTER");
  assert.equal(falseResult.resultText(), "0");
});

test("[parity.system] angle, display format, contrast, and reset settings are live", () => {
  const harness = Free85Harness.boot();
  shifted(harness, "MORE");
  harness.tap("F1");
  harness.tap("F2");
  const originalContrast = harness.machine.read8(P11_CONTRAST_ADDRESS);
  harness.tap("F4");
  assert.equal(harness.machine.read8(ANGLE_MODE_ADDRESS), 1);
  assert.equal(harness.machine.read8(P11_DISPLAY_MODE_ADDRESS), 1);
  assert.equal(harness.machine.read8(P11_CONTRAST_ADDRESS), originalContrast + 1);
  harness.tap("F3");
  assert.equal(harness.machine.read8(P11_CONTRAST_ADDRESS), originalContrast);
  harness.tap("EXIT");
  harness.tap("2");
  harness.tap("ENTER");
  assert.equal(harness.resultText(), "2E0");

  shifted(harness, "+");
  harness.tap("F3");
  assert.equal(harness.machine.read8(ANGLE_MODE_ADDRESS), 0);
  assert.equal(harness.machine.read8(P11_DISPLAY_MODE_ADDRESS), 0);
  assert.equal(harness.machine.read8(P11_CONTRAST_ADDRESS), 0x10);
});

test("[parity.variables-memory] variable recall and scoped memory clearing work", () => {
  const harness = Free85Harness.boot();
  for (const key of ["5", "STO▶", "ALPHA", "LOG", "ENTER"]) harness.tap(key);
  assert.equal(harness.packedNumber(VARIABLES_ADDRESS), 5);
  harness.tap("CLEAR");
  shifted(harness, "STO▶");
  harness.tap("ENTER");
  assert.equal(harness.editorText(), "A");
  harness.tap("CLEAR");
  shifted(harness, "+");
  harness.tap("F1");
  assert.equal(harness.packedNumber(VARIABLES_ADDRESS), 0);

  const programs = Free85Harness.boot();
  programs.machine.write8(0x9510, 1);
  shifted(programs, "+");
  programs.tap("F2");
  assert.equal(programs.machine.read8(0x9510), 0);

  const fullReset = Free85Harness.boot();
  fullReset.machine.write8(VARIABLES_ADDRESS + 2, 0x50);
  shifted(fullReset, "+");
  fullReset.tap("F4");
  fullReset.runFrames(35);
  assert.equal(fullReset.machine.read8(0x8003), 11);
  assert.equal(fullReset.packedNumber(VARIABLES_ADDRESS), 0);
});

test("[parity.base] decimal, hexadecimal, and binary views use the previous answer", () => {
  for (const [key, expected] of [["F1", "42"], ["F2", "0x2A"], ["F3", "0b00101010"]]) {
    const harness = Free85Harness.boot();
    harness.tap("4");
    harness.tap("2");
    harness.tap("ENTER");
    shifted(harness, "1");
    harness.tap(key);
    assert.equal(zeroTerminated(harness.machine, P11_OUTPUT_BUFFER_ADDRESS), expected);
  }

  const outOfRange = Free85Harness.boot();
  for (const key of ["2", "5", "6", "ENTER"]) outOfRange.tap(key);
  shifted(outOfRange, "1");
  outOfRange.tap("F2");
  assert.equal(outOfRange.machine.read8(FREE85_UI_MODE_ADDRESS), 1);
});

test("[parity.history-power-link] ENTRY, ON/OFF, and native link paths are operational", () => {
  const history = Free85Harness.boot();
  history.tap("7");
  history.tap("ENTER");
  history.tap("CLEAR");
  shifted(history, "ENTER");
  assert.equal(history.editorText(), "7");

  const power = Free85Harness.boot();
  power.tap("ON");
  assert.equal(power.machine.read8(FREE85_UI_MODE_ADDRESS), 1);
  power.tap("EXIT");
  shifted(power, "ON");
  assert.equal(power.machine.getDebugState().lcd.enabled, false);
  power.tap("ON");
  assert.equal(power.machine.getDebugState().lcd.enabled, true);

  const link = Free85Harness.boot();
  shifted(link, "X-VAR");
  link.tap("F1");
  assert.equal(link.machine.linkPort & 0x03, 0);
  assert.equal(link.machine.read8(P11_LINK_STATE_ADDRESS) & 0x03, 3);
  link.tap("F2");
  assert.equal(link.machine.read8(P11_LINK_STATE_ADDRESS) & 0x03, 3);
});

test("[parity.audit] Phase 11 source specifications contain no planned placeholders", async () => {
  const features = JSON.parse(await readFile("spec/free85/features.yaml", "utf8"));
  const planned = features.features.filter(({ status }) => status === "planned");
  assert.deepEqual(planned.map(({ id }) => id), []);
  assert.equal(features.features.every(({ tests }) => tests.length > 0), true);
});

test("[parity.no-placeholders] every normal and printed shifted key avoids the planned dialog", () => {
  for (const definition of TI85_PHYSICAL_KEYS) {
    const normal = Free85Harness.boot();
    normal.tap(definition.key);
    const normalIsPlanned = normal.machine.read8(FREE85_UI_MODE_ADDRESS) === 1
      && normal.machine.read8(DIALOG_KIND_ADDRESS) === 0;
    assert.equal(normalIsPlanned, false, `${definition.key}.normal`);

    if (definition.shift === undefined) continue;
    const second = Free85Harness.boot();
    shifted(second, definition.key);
    const secondIsPlanned = second.machine.read8(FREE85_UI_MODE_ADDRESS) === 1
      && second.machine.read8(DIALOG_KIND_ADDRESS) === 0;
    assert.equal(secondIsPlanned, false, `${definition.key}.second`);
  }
});
