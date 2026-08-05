import assert from "node:assert/strict";
import test from "node:test";
import { FREE85_BOOT_FRAMES, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const HEADER = 0x9d80;
const COUNT = HEADER + 4;
const HEAP_END = HEADER + 6;
const DIRECTORY = 0x9e00;
const ENTRY_SIZE = 16;
const HEAP_START = 0xa200;
const HEAP_LIMIT = 0xf2d0;
const VARIABLES = 0x8218;
const NAME_BUFFER = 0x80c0;

// Bank 7's public jump table is part of the firmware ABI. Tests deliberately
// use it instead of assembler-generated symbol files, which are not required
// in a clean checkout running the checked-in ROM.
const STORE_ENTRY_POINTS = new Map([
  ["phase14_create", 0x400e],
  ["phase14_lookup", 0x4011],
  ["phase14_delete", 0x4014],
  ["phase14_resize", 0x4017],
  ["phase14_compact", 0x401a]
]);

function callStore(machine, name, { A = 0, BC = 0, HL = 0 } = {}) {
  const address = STORE_ENTRY_POINTS.get(name);
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

test("[v3.storage.objects] schema 14 registers persistent typed reserved variables", () => {
  const harness = Free85Harness.boot();
  const { machine } = harness;
  assert.deepEqual(Array.from({ length: 4 }, (_, index) => machine.read8(0x8000 + index)), [70, 56, 53, 14]);
  assert.deepEqual(Array.from({ length: 4 }, (_, index) => machine.read8(HEADER + index)), [79, 56, 53, 2]);
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
  assert.equal(machine.read8(0x8003), 14);
  assert.deepEqual(Array.from({ length: 9 }, (_, index) => machine.read8(VARIABLES + index)), legacy);
  assert.equal(machine.read16(DIRECTORY + 11), VARIABLES);
});

test("[phase17.4.migration] schema-13 matrices move transactionally into the 3x6 workspace", () => {
  const harness = Free85Harness.boot();
  const { machine } = harness;
  const legacyMatrixA = 0x8900;
  const legacyMatrixAImag = 0xf8d8;
  const matrixA = 0xf2e0;
  const matrixAImag = 0xf570;
  const real = [0, 0, 0x12, 0x34, 0x56, 0x78, 0x90, 0x12, 0x34];
  const imag = [0x80, 0, 0x50, 0, 0, 0, 0, 0, 0];
  machine.write8(legacyMatrixA, 2);
  machine.write8(legacyMatrixA + 1, 2);
  real.forEach((byte, index) => machine.write8(legacyMatrixA + 2 + index, byte));
  imag.forEach((byte, index) => machine.write8(legacyMatrixAImag + index, byte));
  machine.write8(0x8003, 13);
  machine.write8(HEADER + 3, 1);
  machine.write16(HEAP_END, HEAP_START);

  machine.reset();
  harness.runFrames(FREE85_BOOT_FRAMES);
  assert.equal(machine.read8(0x8003), 14);
  assert.equal(machine.read8(HEADER + 3), 2);
  assert.deepEqual(Array.from({ length: 2 }, (_, index) => machine.read8(matrixA + index)), [2, 2]);
  assert.deepEqual(Array.from({ length: 9 }, (_, index) => machine.read8(matrixA + 2 + index)), real);
  assert.deepEqual(Array.from({ length: 9 }, (_, index) => machine.read8(matrixAImag + index)), imag);
  assert.equal(machine.read16(HEAP_END), HEAP_START);
});

test("[phase17.4.rollback] insufficient schema-13 heap capacity preserves old matrices and blocks workspace entry", () => {
  const harness = Free85Harness.boot();
  const { machine } = harness;
  const legacyMatrixA = 0x8900;
  machine.write8(legacyMatrixA, 3);
  machine.write8(legacyMatrixA + 1, 3);
  machine.write8(legacyMatrixA + 2, 0x80);
  machine.write8(0x8003, 13);
  machine.write8(HEADER + 3, 1);
  machine.write16(HEAP_END, HEAP_LIMIT + 1);

  machine.reset();
  harness.runFrames(FREE85_BOOT_FRAMES);
  assert.equal(machine.read8(0x8003), 13, "failed migration remains retryable");
  assert.equal(machine.read8(HEADER + 3), 1);
  assert.deepEqual([machine.read8(legacyMatrixA), machine.read8(legacyMatrixA + 1), machine.read8(legacyMatrixA + 2)], [3, 3, 0x80]);
  assert.equal(machine.read16(HEAP_END), HEAP_LIMIT + 1);
  assert.equal(machine.read8(0x9dd6), 0, "runtime workspace remains disabled");
  harness.tap("2ND");
  harness.tap("7");
  assert.equal(machine.read8(0x800b), 1, "matrix entry reports the migration capacity failure");
});

test("[phase17.5.corruption] corrupt schema-13 storage fails migration without partial publication", () => {
  const harness = Free85Harness.boot();
  const { machine } = harness;
  const legacyMatrixA = 0x8900;
  const workspace = 0xf2d0;
  machine.write8(legacyMatrixA, 3);
  machine.write8(legacyMatrixA + 1, 3);
  machine.write8(legacyMatrixA + 2, 0x42);
  machine.write8(0x8003, 13);
  machine.write8(HEADER, 0);
  machine.write8(HEADER + 3, 1);
  machine.write16(HEAP_END, HEAP_START);
  const beforeWorkspace = Array.from({ length: 16 }, (_, index) => machine.read8(workspace + index));

  machine.reset();
  harness.runFrames(FREE85_BOOT_FRAMES);
  assert.equal(machine.read8(0x8003), 13, "schema publication remains retryable");
  assert.equal(machine.read8(HEADER), 0, "corrupt source is not silently rebuilt");
  assert.equal(machine.read8(HEADER + 3), 1);
  assert.deepEqual(Array.from({ length: 3 }, (_, index) => machine.read8(legacyMatrixA + index)), [3, 3, 0x42]);
  assert.equal(machine.read16(HEAP_END), HEAP_START);
  assert.deepEqual(Array.from({ length: 16 }, (_, index) => machine.read8(workspace + index)), beforeWorkspace);
  assert.equal(machine.read8(0x9dd6), 0);
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
