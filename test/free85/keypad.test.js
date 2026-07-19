import assert from "node:assert/strict";
import test from "node:test";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import { Free85Harness } from "../helpers/free85-harness.js";

test("every physical key reaches a visible Phase 2 action", () => {
  for (const [expectedCode, definition] of TI85_PHYSICAL_KEYS.entries()) {
    const harness = Free85Harness.boot();
    const homeChecksum = harness.signature().checksum;
    harness.tap(definition.key);
    const signature = harness.signature();
    assert.equal(signature.lastKey, expectedCode, definition.key);
    assert.notEqual(signature.checksum, homeChecksum, definition.key);
    assert.equal(signature.litPixelCount > 0, true, definition.key);
  }
});

test("Free85 debounces a held key and accepts it again after release", () => {
  const harness = Free85Harness.boot();
  harness.machine.pressKey("GRAPH");
  harness.runFrames(2);
  const pressed = harness.signature();
  harness.runFrames(20);
  assert.deepEqual(harness.signature(), pressed);

  harness.machine.releaseKey("GRAPH");
  harness.runFrames(2);
  harness.tap("SIN");
  assert.equal(harness.signature().lastKey, TI85_PHYSICAL_KEYS.findIndex(({ key }) => key === "SIN"));
});

test("every printed shifted function inserts or reports a visible action", () => {
  for (const definition of TI85_PHYSICAL_KEYS.filter(({ shift }) => shift !== undefined)) {
    const harness = Free85Harness.boot();
    harness.tap("2ND");
    const armedChecksum = harness.signature().checksum;
    harness.tap(definition.key);
    assert.equal(harness.machine.read8(0x800c) & 0x01, 0, definition.key);
    assert.equal(harness.machine.read8(0x8014), 1, definition.key);
    assert.notEqual(harness.signature().checksum, armedChecksum, definition.key);
  }
});

test("[ui.alpha-surfaces] all printed alpha mappings insert their registered character", () => {
  for (const definition of TI85_PHYSICAL_KEYS.filter(({ alpha }) => alpha !== undefined)) {
    const harness = Free85Harness.boot();
    harness.tap("ALPHA");
    harness.tap(definition.key);
    assert.equal(harness.editorText(), definition.alpha, definition.key);
    assert.equal(harness.machine.read8(0x800c) & 0x06, 0, definition.key);
    assert.equal(harness.machine.read8(0x8014), 2, definition.key);
  }
});
