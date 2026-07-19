import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";
import { FREE85_BOOT_FRAMES, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const HEADER = 0x9d80;
const COUNT = HEADER + 4;
const HEAP_END = HEADER + 6;
const DIRECTORY = 0x9e00;
const ENTRY_SIZE = 16;
const HEAP_START = 0xa200;
const HEAP_LIMIT = 0xfb00;
const VARIABLES = 0x8218;
const NAME_BUFFER = 0x80c0;

const symbols = new Map(readFileSync("firmware/free85/generated/page7.sym", "utf8")
  .split("\n")
  .map((line) => line.match(/^([a-zA-Z0-9_]+): EQU 0x([0-9A-Fa-f]+)$/))
  .filter(Boolean)
  .map((match) => [match[1], Number.parseInt(match[2], 16)]));

function callStore(machine, name, { A = 0, BC = 0, HL = 0 } = {}) {
  const address = symbols.get(name);
  assert.ok(address, `missing ${name}`);
  machine.writePort(0x05, 7);
  machine.write8(0x800a, 7);
  const stack = 0xfae0;
  const sentinel = 0x0200;
  machine.write16(stack, sentinel);
  const state = machine.cpu.getState();
  machine.cpu.setState({
    ...state,
    registers: {
      ...state.registers,
      A,
      B: BC >> 8,
      C: BC,
      H: HL >> 8,
      L: HL,
      SP: stack,
      PC: address
    },
    IFF1: false,
    IFF2: false,
    halted: false,
    pendingInterrupt: false
  });
  for (let steps = 0; machine.cpu.PC !== sentinel; steps += 1) {
    assert.ok(steps < 100_000, `${name} did not return`);
    machine.step();
  }
  return machine.cpu.getState();
}

function writeName(machine, name) {
  for (let index = 0; index < 9; index += 1) {
    machine.write8(NAME_BUFFER + index, index < name.length ? name.charCodeAt(index) : 0);
  }
}

function create(machine, type, name, size) {
  writeName(machine, name);
  const state = callStore(machine, "phase14_create", { A: type, BC: size, HL: NAME_BUFFER });
  assert.equal(state.flags.C, false, name);
  return { entry: state.registers.HL, payload: state.registers.DE };
}

test("[v2.storage.objects] schema 13 registers persistent typed reserved variables", () => {
  const harness = Free85Harness.boot();
  const { machine } = harness;
  assert.deepEqual(Array.from({ length: 4 }, (_, index) => machine.read8(0x8000 + index)), [70, 56, 53, 13]);
  assert.deepEqual(Array.from({ length: 4 }, (_, index) => machine.read8(HEADER + index)), [79, 56, 53, 1]);
  assert.equal(machine.read8(COUNT), 26);
  assert.equal(machine.read16(HEAP_END), HEAP_START);
  for (let index = 0; index < 26; index += 1) {
    const entry = DIRECTORY + index * ENTRY_SIZE;
    assert.equal(machine.read8(entry), 1);
    assert.equal(machine.read8(entry + 1), 3);
    assert.equal(machine.read8(entry + 3), "A".charCodeAt(0) + index);
    assert.equal(machine.read16(entry + 11), VARIABLES + index * 9);
    assert.equal(machine.read16(entry + 13), 9);
  }
});

test("[v2.storage.capacity] allocation lookup resizing deletion and compaction preserve payloads", () => {
  const { machine } = Free85Harness.boot();
  const one = create(machine, 6, "ONE", 5);
  const two = create(machine, 7, "TWO", 5);
  for (let index = 0; index < 5; index += 1) {
    machine.write8(one.payload + index, 10 + index);
    machine.write8(two.payload + index, 20 + index);
  }

  writeName(machine, "TWO");
  let state = callStore(machine, "phase14_lookup", { A: 7, HL: NAME_BUFFER });
  assert.equal(state.flags.C, false);
  assert.equal(state.registers.HL, two.entry);

  state = callStore(machine, "phase14_resize", { BC: 9, HL: one.entry });
  assert.equal(state.flags.C, false);
  assert.equal(machine.read16(two.entry + 11), two.payload + 4);
  assert.deepEqual(Array.from({ length: 5 }, (_, index) => machine.read8(two.payload + 4 + index)), [20, 21, 22, 23, 24]);

  state = callStore(machine, "phase14_resize", { BC: 3, HL: one.entry });
  assert.equal(state.flags.C, false);
  assert.equal(machine.read16(two.entry + 11), two.payload - 2);
  assert.deepEqual(Array.from({ length: 5 }, (_, index) => machine.read8(two.payload - 2 + index)), [20, 21, 22, 23, 24]);

  state = callStore(machine, "phase14_delete", { HL: one.entry });
  assert.equal(state.flags.C, false);
  assert.equal(machine.read16(two.entry + 11), HEAP_START);
  assert.equal(machine.read16(HEAP_END), HEAP_START + 5);
  assert.deepEqual(Array.from({ length: 5 }, (_, index) => machine.read8(HEAP_START + index)), [20, 21, 22, 23, 24]);
  state = callStore(machine, "phase14_compact");
  assert.equal(state.flags.C, false);
  assert.equal(state.registers.BC, HEAP_LIMIT - HEAP_START - 5);
  for (const invalid of [DIRECTORY - 1, DIRECTORY + 1, DIRECTORY + 64 * ENTRY_SIZE]) {
    state = callStore(machine, "phase14_delete", { HL: invalid });
    assert.equal(state.flags.C, true, `delete ${invalid.toString(16)}`);
    state = callStore(machine, "phase14_resize", { BC: 2, HL: invalid });
    assert.equal(state.flags.C, true, `resize ${invalid.toString(16)}`);
  }
});

test("[v2.storage.capacity] all public types, directory pressure and low-memory failures are deterministic", () => {
  const { machine } = Free85Harness.boot();
  for (let type = 1; type <= 11; type += 1) create(machine, type, `T${type}`, 1);
  for (let index = 0; index < 27; index += 1) create(machine, 1, `D${index}`, 1);
  assert.equal(machine.read8(COUNT), 64);
  const directoryFullEnd = machine.read16(HEAP_END);
  writeName(machine, "FULL");
  let state = callStore(machine, "phase14_create", { A: 1, BC: 1, HL: NAME_BUFFER });
  assert.equal(state.flags.C, true);
  assert.equal(machine.read16(HEAP_END), directoryFullEnd);

  const lowMemory = Free85Harness.boot().machine;
  const before = lowMemory.read16(HEAP_END);
  writeName(lowMemory, "HUGE");
  state = callStore(lowMemory, "phase14_create", { A: 1, BC: HEAP_LIMIT - before + 1, HL: NAME_BUFFER });
  assert.equal(state.flags.C, true);
  assert.equal(lowMemory.read16(HEAP_END), before);
  assert.equal(lowMemory.read8(COUNT), 26);

  for (const [type, size] of [[0, 1], [12, 1], [1, 0]]) {
    writeName(lowMemory, "BAD");
    state = callStore(lowMemory, "phase14_create", { A: type, BC: size, HL: NAME_BUFFER });
    assert.equal(state.flags.C, true, `type ${type} size ${size}`);
    assert.equal(lowMemory.read8(COUNT), 26);
  }
});

test("[v2.storage.objects] dynamic objects and payloads survive warm reset", () => {
  const harness = Free85Harness.boot();
  const { machine } = harness;
  const object = create(machine, 8, "KEEP", 4);
  [1, 3, 3, 7].forEach((byte, index) => machine.write8(object.payload + index, byte));
  machine.reset();
  harness.runFrames(FREE85_BOOT_FRAMES);
  assert.equal(machine.read8(COUNT), 27);
  assert.equal(machine.read16(HEAP_END), HEAP_START + 4);
  assert.deepEqual(Array.from({ length: 4 }, (_, index) => machine.read8(object.payload + index)), [1, 3, 3, 7]);
  writeName(machine, "KEEP");
  const state = callStore(machine, "phase14_lookup", { A: 8, HL: NAME_BUFFER });
  assert.equal(state.flags.C, false);
  assert.equal(state.registers.HL, object.entry);
});

test("[v2.storage.migration] schema-12 migration is retryable and preserves legacy values", () => {
  const harness = Free85Harness.boot();
  const { machine } = harness;
  const legacy = [0x80, 0x02, 0x12, 0x34, 0x56, 0x78, 0x90, 0x12, 0x34];
  legacy.forEach((byte, index) => machine.write8(VARIABLES + index, byte));
  machine.write8(0x8003, 12);
  machine.write8(HEADER, 0);
  machine.reset();
  harness.runFrames(FREE85_BOOT_FRAMES);
  assert.equal(machine.read8(0x8003), 13);
  assert.deepEqual(Array.from({ length: 9 }, (_, index) => machine.read8(VARIABLES + index)), legacy);
  assert.equal(machine.read16(DIRECTORY + 11), VARIABLES);
});

test("[v2.memory.browser] browser renders typed entries and clears one selected object", () => {
  const harness = Free85Harness.boot();
  harness.tap("2ND");
  harness.tap("+");
  assert.equal(harness.machine.read8(0x800b), 27);
  assertLcdGolden("phase14-memory-browser", harness.machine.renderLcdBitmap());
  harness.machine.write8(VARIABLES, 0x80);
  harness.tap("DEL");
  assert.equal(harness.machine.read8(VARIABLES), 0);
  assert.equal(harness.machine.read8(COUNT), 26);
});
