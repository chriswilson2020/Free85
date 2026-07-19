import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import { Ti85Machine } from "../../src/ti85.js";
import { FREE85_BOOT_FRAMES, FREE85_ROM_PATH, Free85Harness } from "../helpers/free85-harness.js";

test("Free85 ROM has eight exact 16 KiB banks and fixed vectors", async () => {
  const rom = await readFile(FREE85_ROM_PATH);
  assert.equal(rom.length, 131_072);
  assert.equal(rom[0x0000], 0xc3);
  assert.equal(rom[0x0038], 0xc3);
  assert.equal(rom[0x0066], 0xc3);
  for (let page = 1; page < 8; page += 1) {
    const start = page * 0x4000;
    assert.equal(rom.subarray(start, start + 7).toString("ascii"), "FREE85\0");
    assert.equal(rom[start + 7], page);
    if (page === 1 || page === 2 || page === 3 || page === 4) {
      assert.equal(rom[start + 8], 0xc3);
      assert.equal(rom.subarray(start + 8, start + 0x4000).some((byte) => byte !== 0xff), true);
    } else {
      assert.equal(rom.subarray(start + 8, start + 0x4000).every((byte) => byte === 0xff), true);
    }
  }
});

test("Free85 initializes RAM, banking, interrupts, LCD, and a visible splash", () => {
  const machine = Ti85Machine.fromRomFile(FREE85_ROM_PATH);
  machine.runFrame();
  machine.runFrame();
  const state = machine.getDebugState();

  assert.deepEqual([machine.read8(0x8000), machine.read8(0x8001), machine.read8(0x8002), machine.read8(0x8003)], [70, 56, 53, 9]);
  assert.equal(state.memory.romBank, 1);
  assert.equal(state.cpu.interruptMode, 1);
  assert.equal(state.cpu.IFF1, true);
  assert.equal(state.lcd.enabled, true);
  assert.equal(state.lcd.baseAddress, 0xfc00);
  assert.equal(state.cpu.registers.SP >= 0xfb00 && state.cpu.registers.SP <= 0xfc00, true);
  assert.equal(state.display.litPixelCount > 0, true);
});

test("Free85 transitions from its splash to the home screen", () => {
  const machine = Ti85Machine.fromRomFile(FREE85_ROM_PATH);
  for (let index = 0; index < 5; index += 1) machine.runFrame();
  const splash = machine.renderLcdBitmap();
  assert.deepEqual(
    { litPixelCount: splash.litPixelCount, checksum: splash.checksum.toString(16).padStart(8, "0").toUpperCase() },
    { litPixelCount: 363, checksum: "AAD171C4" }
  );

  for (let index = 5; index < FREE85_BOOT_FRAMES; index += 1) machine.runFrame();
  assert.deepEqual(Free85Harness.prototype.signature.call({ machine }), {
    litPixelCount: 590,
    checksum: "51406E3D",
    lastKey: 0xff
  });
  assert.equal(machine.read8(0x800b), 0);
  assert.equal(machine.read8(0x8010), 0);
});

test("Free85 repeatedly resets to the same stable home state", () => {
  const harness = Free85Harness.boot();
  const expected = harness.signature();
  for (let reset = 0; reset < 20; reset += 1) {
    harness.machine.reset();
    harness.runFrames(FREE85_BOOT_FRAMES);
    assert.deepEqual(harness.signature(), expected, `reset ${reset + 1}`);
  }
});
