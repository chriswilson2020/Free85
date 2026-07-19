import assert from "node:assert/strict";
import test from "node:test";
import {
  FREE85_EDITOR_CURSOR_ADDRESS,
  FREE85_EDITOR_INSERT_ADDRESS,
  FREE85_MODIFIERS_ADDRESS,
  FREE85_UI_MODE_ADDRESS,
  Free85Harness
} from "../helpers/free85-harness.js";

function enter(harness, keys) {
  for (const key of keys) harness.tap(key);
}

test("[ui.editor] home editor accepts expressions through the physical keypad", () => {
  const harness = Free85Harness.boot();
  enter(harness, ["2", "+", "3", "*", "(", "4", "-", "1", ")"]);
  assert.equal(harness.editorText(), "2+3*(4-1)");
  assert.equal(harness.machine.read8(FREE85_EDITOR_CURSOR_ADDRESS), 9);
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 0);
});

test("editor cursor, delete, and insert-overwrite mode work", () => {
  const harness = Free85Harness.boot();
  enter(harness, ["1", "2", "3", "LEFT", "DEL"]);
  assert.equal(harness.editorText(), "13");
  assert.equal(harness.machine.read8(FREE85_EDITOR_CURSOR_ADDRESS), 1);

  harness.tap("CLEAR");
  enter(harness, ["1", "2", "3", "LEFT", "LEFT", "2ND", "DEL", "9"]);
  assert.equal(harness.editorText(), "193");
  assert.equal(harness.machine.read8(FREE85_EDITOR_INSERT_ADDRESS), 0);
  enter(harness, ["2ND", "DEL", "8"]);
  assert.equal(harness.editorText(), "1983");
  assert.equal(harness.machine.read8(FREE85_EDITOR_INSERT_ADDRESS), 1);
});

test("[ui.modifiers] 2ND is one-shot and shifted editor operations are reachable", () => {
  const harness = Free85Harness.boot();
  enter(harness, ["2ND", "^", "+", "2ND", "SIN"]);
  assert.equal(harness.editorText(), "PI+ASIN(");
  assert.equal(harness.machine.read8(FREE85_MODIFIERS_ADDRESS) & 0x01, 0);
});

test("ALPHA supports one-shot entry and lock cycling", () => {
  const harness = Free85Harness.boot();
  enter(harness, ["ALPHA", "LOG"]);
  assert.equal(harness.editorText(), "A");
  assert.equal(harness.machine.read8(FREE85_MODIFIERS_ADDRESS) & 0x06, 0);

  enter(harness, ["ALPHA", "ALPHA", "SIN", "COS"]);
  assert.equal(harness.editorText(), "ABC");
  assert.equal(harness.machine.read8(FREE85_MODIFIERS_ADDRESS) & 0x06, 0x06);
  harness.tap("ALPHA");
  assert.equal(harness.machine.read8(FREE85_MODIFIERS_ADDRESS) & 0x06, 0);
});

test("[ui.menus] soft-menu pages and unfinished applications show explicit dialogs", () => {
  const harness = Free85Harness.boot();
  harness.tap("F1");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 1);
  harness.tap("EXIT");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 0);
  const firstPage = harness.signature().checksum;
  harness.tap("MORE");
  assert.notEqual(harness.signature().checksum, firstPage);
  harness.tap("F1");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 1);
  harness.tap("EXIT");
  harness.tap("GRAPH");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 2);
});

test("ENTER and editor boundary errors are visible and dismissible", () => {
  const harness = Free85Harness.boot();
  harness.tap("ENTER");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 1);
  harness.tap("CLEAR");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 0);
  harness.tap("LEFT");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 1);
  harness.tap("EXIT");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 0);
});

test("editor capacity reports an error without corrupting the entry", () => {
  const harness = Free85Harness.boot();
  enter(harness, Array(48).fill("1"));
  assert.equal(harness.editorText(), "1".repeat(48));
  harness.tap("2");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 1);
  assert.equal(harness.editorText(), "1".repeat(48));
  harness.tap("EXIT");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 0);
  assert.equal(harness.editorText(), "1".repeat(48));
});

test("home cursor blinks without changing editor state", () => {
  const harness = Free85Harness.boot();
  const visible = harness.signature().checksum;
  harness.runFrames(25);
  const hidden = harness.signature().checksum;
  assert.notEqual(hidden, visible);
  harness.runFrames(25);
  assert.equal(harness.signature().checksum, visible);
  assert.equal(harness.editorText(), "");
});

test("compact editor crosses the 21-column boundary without changing its contents", () => {
  const harness = Free85Harness.boot();
  enter(harness, Array(22).fill("1"));
  assert.equal(harness.editorText(), "1".repeat(22));
  assert.equal(harness.machine.read8(FREE85_EDITOR_CURSOR_ADDRESS), 22);
  const visible = harness.signature().checksum;
  harness.runFrames(25);
  assert.notEqual(harness.signature().checksum, visible);
  assert.equal(harness.editorText(), "1".repeat(22));
});
