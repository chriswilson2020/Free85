import assert from "node:assert/strict";
import test from "node:test";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import { FREE85_BOOT_FRAMES, FREE85_UI_MODE_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const SCREEN_HOME = 0;
const SCREEN_STRINGS = 11;
const SCREEN_CATALOG = 12;
const SCREEN_CUSTOM = 13;
const SCREEN_CHARACTERS = 14;
const STRING_A = 0x9320;
const STRING_B = 0x9360;
const STRING_RESULT = 0x93a0;
const CATALOG_INDEX = 0x9305;
const CUSTOM_SLOTS = 0x93e0;
const NUM_RESULT = 0x9400;

const alphaKeys = new Map(TI85_PHYSICAL_KEYS
  .filter(({ alpha }) => /^[A-Z]$/.test(alpha ?? ""))
  .map(({ alpha, key }) => [alpha, key]));

function tapAll(harness, keys) {
  for (const key of keys) harness.tap(key);
}

function typeString(harness, value) {
  for (const character of value) {
    if (/[A-Z]/.test(character)) tapAll(harness, ["ALPHA", alphaKeys.get(character)]);
    else harness.tap(character === "-" ? "(-)" : character);
  }
}

function nativeString(harness, address) {
  const length = harness.machine.read8(address);
  return String.fromCharCode(...Array.from({ length }, (_, index) => harness.machine.read8(address + 1 + index)));
}

function openStrings() {
  const harness = Free85Harness.boot();
  tapAll(harness, ["2ND", "6"]);
  return harness;
}

test("[strings.editor] Phase 9 physical keys open strings, catalog, custom, and character screens", () => {
  for (const [keys, screen, golden] of [
    [["2ND", "6"], SCREEN_STRINGS, "phase9-strings-editor"],
    [["2ND", "CUSTOM"], SCREEN_CATALOG, "phase9-catalog"],
    [["CUSTOM"], SCREEN_CUSTOM, "phase9-custom"],
    [["2ND", "0"], SCREEN_CHARACTERS, "phase9-characters"]
  ]) {
    const harness = Free85Harness.boot();
    tapAll(harness, keys);
    assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), screen);
    assertLcdGolden(golden, harness.machine.renderLcdBitmap());
  }
});

test("[strings.operations] native values concatenate, measure, slice, extract, and compare", () => {
  const concat = openStrings();
  typeString(concat, "HELLO");
  concat.tap("X-VAR");
  typeString(concat, "WORLD");
  concat.tap("F1");
  assert.equal(nativeString(concat, STRING_RESULT), "HELLOWORLD");

  const length = openStrings();
  typeString(length, "ABCDEFGHIJKL");
  length.tap("F2");
  assert.equal(length.packedNumber(NUM_RESULT), 12);

  const substring = openStrings();
  typeString(substring, "HELLO");
  tapAll(substring, ["RIGHT", "UP", "UP", "F3"]);
  assert.equal(nativeString(substring, STRING_RESULT), "ELL");

  const character = openStrings();
  typeString(character, "HELLO");
  tapAll(character, ["RIGHT", "F4"]);
  assert.equal(nativeString(character, STRING_RESULT), "E");

  const compare = openStrings();
  typeString(compare, "APPLE");
  compare.tap("X-VAR");
  typeString(compare, "BANANA");
  compare.tap("F5");
  assert.equal(compare.packedNumber(NUM_RESULT), -1);
});

test("[strings.conversion] numbers round-trip through the native string type", () => {
  const toString = Free85Harness.boot();
  tapAll(toString, ["1", "2", "3", ".", "5", "ENTER", "2ND", "6", "MORE", "F1"]);
  assert.equal(nativeString(toString, STRING_RESULT), "123.5");

  const toNumber = openStrings();
  typeString(toNumber, "-12.5");
  tapAll(toNumber, ["MORE", "F2"]);
  assert.equal(toNumber.packedNumber(NUM_RESULT), -12.5);
  assert.equal(toNumber.packedNumber(0x8302), -12.5);
});

test("[catalog.callable] every alphabetical catalog entry invokes a real surface or inserts callable text", () => {
  const appScreens = new Map([
    [9, SCREEN_CHARACTERS], [11, 4], [15, SCREEN_CUSTOM], [22, 2], [30, 5],
    [33, 6], [39, 10], [42, 9], [49, 8], [50, SCREEN_STRINGS], [54, 7]
  ]);
  for (let index = 0; index < 56; index += 1) {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "CUSTOM"]);
    harness.machine.write8(CATALOG_INDEX, index);
    harness.tap("ENTER");
    if (appScreens.has(index)) {
      assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), appScreens.get(index), `catalog ${index}`);
    } else {
      assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_HOME, `catalog ${index}`);
      assert.ok(harness.editorText().length > 0, `catalog ${index}`);
      if (index === 17 || index === 38) continue; // E and PI are constants.
      const argumentsText = index === 36 || index === 37 ? "5,2)"
        : index === 6 ? "0)" // ATANH(1) is outside its open domain.
          : "1)";
      for (const character of argumentsText) harness.tap(character);
      harness.tap("ENTER");
      harness.runFrames(300);
      assert.equal(harness.machine.read8(0x805a), 0, `catalog ${index} must parse and evaluate`);
      assert.equal(harness.machine.read8(0x8058), 1, `catalog ${index} must produce a result`);
    }
  }
});

test("[custom.persistence] catalog assignments survive reset and custom keys invoke them", () => {
  const harness = Free85Harness.boot();
  tapAll(harness, ["2ND", "CUSTOM"]);
  harness.machine.write8(CATALOG_INDEX, 43); // SIN
  harness.tap("F3");
  assert.equal(harness.machine.read8(CUSTOM_SLOTS + 2), 43);

  harness.machine.reset();
  harness.runFrames(FREE85_BOOT_FRAMES);
  assert.equal(harness.machine.read8(CUSTOM_SLOTS + 2), 43);
  tapAll(harness, ["CUSTOM", "F3"]);
  assert.equal(harness.editorText(), "SIN(");
});

test("[characters.palette] the palette inserts punctuation into both home and string editors", () => {
  const home = Free85Harness.boot();
  tapAll(home, ["2ND", "0"]);
  home.machine.write8(0x9306, 2); // double quote
  home.tap("ENTER");
  assert.equal(home.editorText(), "\"");

  const strings = openStrings();
  tapAll(strings, ["2ND", "0"]);
  strings.machine.write8(0x9306, 2);
  strings.tap("ENTER");
  assert.equal(nativeString(strings, STRING_A), "\"");
});
