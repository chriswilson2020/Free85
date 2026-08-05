import assert from "node:assert/strict";
import test from "node:test";
import {
  FREE85_DUPLICATE_POLICY,
  FREE85_LINK_COMMAND,
  FREE85_LINK_MAILBOX,
  FREE85_LINK_STATUS,
  Free85LinkError,
  Free85LinkSession,
  decodeFree85Packet,
  encodeFree85Packet,
  listFree85Objects,
  selectFree85Objects
} from "../../src/free85-link.js";
import {
  FREE85_EDITOR_BUFFER_ADDRESS,
  FREE85_EDITOR_CURSOR_ADDRESS,
  FREE85_EDITOR_LENGTH_ADDRESS,
  Free85Harness
} from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const NUM_RESULT = 0x8092;
const NAME_A = 0x80c0;
const NAME_B = 0x80d0;
const CHAR_INDEX = 0x9306;
const SCREEN_CONSTANTS = 22;
const SCREEN_CHARACTERS = 14;
const UI_SCREEN = 0x800b;
const CONSTANT_TYPE = 9;
const HEAP_CAPACITY = 0xf2d0 - 0xa200;

const PHASE21 = Object.freeze({ store: 0x402c, delete: 0x402f, rename: 0x4032 });

function writeText(machine, address, text, capacity = 16) {
  for (let index = 0; index < capacity; index += 1) {
    machine.write8(address + index, index < text.length ? text.charCodeAt(index) : 0);
  }
}

function setEditor(harness, text) {
  writeText(harness.machine, FREE85_EDITOR_BUFFER_ADDRESS, text, 48);
  harness.machine.write8(FREE85_EDITOR_LENGTH_ADDRESS, text.length);
  harness.machine.write8(FREE85_EDITOR_CURSOR_ADDRESS, text.length);
}

function callPhase21(machine, address, { HL = 0, DE = 0 } = {}) {
  const originalBank = machine.selectedRomBank();
  const originalCurrentBank = machine.read8(0x800a);
  const state = machine.cpu.getState();
  machine.writePort(0x05, 6);
  machine.write8(0x800a, 6);
  const stack = 0xfae0;
  const sentinel = 0x0200;
  machine.write16(stack, sentinel);
  machine.cpu.setState({
    ...state,
    registers: {
      ...state.registers,
      H: HL >>> 8,
      L: HL,
      D: DE >>> 8,
      E: DE,
      SP: stack,
      PC: address
    },
    IFF1: false,
    IFF2: false,
    halted: false,
    pendingInterrupt: false
  });
  for (let steps = 0; machine.cpu.PC !== sentinel; steps += 1) {
    assert.ok(steps < 100_000, "Phase 21 call did not return");
    machine.step();
  }
  const result = machine.cpu.getState();
  machine.cpu.setState(state);
  machine.writePort(0x05, originalBank);
  machine.write8(0x800a, originalCurrentBank);
  return result;
}

function callObjectStore(machine, address, { A = 0, BC = 0, HL = 0 } = {}) {
  const originalBank = machine.selectedRomBank();
  const originalCurrentBank = machine.read8(0x800a);
  const state = machine.cpu.getState();
  machine.writePort(0x05, 7);
  machine.write8(0x800a, 7);
  const stack = 0xfae0;
  const sentinel = 0x0200;
  machine.write16(stack, sentinel);
  machine.cpu.setState({
    ...state,
    registers: {
      ...state.registers,
      A,
      B: BC >>> 8,
      C: BC,
      H: HL >>> 8,
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
    assert.ok(steps < 100_000, "object-store call did not return");
    machine.step();
  }
  const result = machine.cpu.getState();
  machine.cpu.setState(state);
  machine.writePort(0x05, originalBank);
  machine.write8(0x800a, originalCurrentBank);
  return result;
}

function evaluate(harness, expression) {
  setEditor(harness, expression);
  harness.tap("ENTER");
  return harness.packedNumber(NUM_RESULT);
}

function storeConstant(harness, name, value) {
  assert.equal(evaluate(harness, String(value)), value);
  writeText(harness.machine, NAME_A, name);
  const result = callPhase21(harness.machine, PHASE21.store, { HL: NAME_A, DE: NUM_RESULT });
  assert.equal(result.flags.C, false, name);
  return listFree85Objects(harness.machine).find((object) => object.type === CONSTANT_TYPE && object.name === name);
}

function objectState(machine) {
  return listFree85Objects(machine).map(({ type, flags, name, payload }) => ({
    type,
    flags: flags & 0x03,
    name,
    payload: Array.from(payload)
  }));
}

test("[constants.user] create, edit, name, use, delete, and reset are persistent ROM workflows", () => {
  const harness = Free85Harness.boot();
  storeConstant(harness, "RATE", 12.5);
  assert.equal(evaluate(harness, "RATE*2"), 25);

  storeConstant(harness, "RATE", 3.25);
  assert.equal(evaluate(harness, "RATE+1"), 4.25);

  writeText(harness.machine, NAME_A, "RATE");
  writeText(harness.machine, NAME_B, "SPEED");
  let result = callPhase21(harness.machine, PHASE21.rename, { HL: NAME_A, DE: NAME_B });
  assert.equal(result.flags.C, false);
  assert.equal(evaluate(harness, "SPEED*4"), 13);

  harness.machine.reset();
  harness.runFrames(35);
  assert.equal(evaluate(harness, "SPEED"), 3.25);

  writeText(harness.machine, NAME_A, "SPEED");
  result = callPhase21(harness.machine, PHASE21.delete, { HL: NAME_A });
  assert.equal(result.flags.C, false);
  assert.equal(listFree85Objects(harness.machine).some((object) => object.name === "SPEED" && object.type === CONSTANT_TYPE), false);
});

test("[constants.user] the third CONSTANTS page recalls named user values", () => {
  const harness = Free85Harness.boot();
  storeConstant(harness, "RATE", 9);
  setEditor(harness, "");
  harness.tap("2ND");
  harness.tap("4");
  assert.equal(harness.machine.read8(UI_SCREEN), SCREEN_CONSTANTS);
  harness.tap("MORE");
  harness.tap("MORE");
  assertLcdGolden("phase21-user-constants", harness.machine.renderLcdBitmap());
  harness.tap("F4");
  assert.equal(harness.editorText(), "RATE");
});

test("[constants.user] the calculator UI creates, edits, renames, uses, and deletes a constant", () => {
  const harness = Free85Harness.boot();
  harness.tap("2ND");
  harness.tap("4");
  harness.tap("MORE");
  harness.tap("MORE");
  harness.tap("F1");
  harness.tap("ALPHA");
  for (const key of ["5", "LOG", "-", "^"]) harness.tap(key); // RATE
  harness.tap("ENTER");
  harness.tap("ALPHA");
  harness.tap("4");
  harness.tap("ENTER");
  let constant = listFree85Objects(harness.machine).find(({ name, type }) => name === "RATE" && type === CONSTANT_TYPE);
  assert.equal(harness.packedNumber(constant.address), 4);

  harness.tap("F2");
  harness.tap("8");
  harness.tap("ENTER");
  constant = listFree85Objects(harness.machine).find(({ name, type }) => name === "RATE" && type === CONSTANT_TYPE);
  assert.equal(harness.packedNumber(constant.address), 8);
  harness.tap("F3");
  harness.tap("ALPHA");
  for (const key of ["9", "^"]) harness.tap(key); // NE
  harness.tap("ENTER");
  assert.ok(listFree85Objects(harness.machine).some(({ name, type }) => name === "NE" && type === CONSTANT_TYPE));
  harness.tap("F4");
  assert.equal(harness.editorText(), "NE");
  harness.tap("2ND");
  harness.tap("4");
  harness.tap("MORE");
  harness.tap("MORE");
  harness.tap("F5");
  assert.equal(listFree85Objects(harness.machine).some(({ name, type }) => name === "NE" && type === CONSTANT_TYPE), false);
});

test("[characters.extended] Greek and international glyph codes render and insert", () => {
  for (const [index, code] of [[26, 123], [37, 134], [38, 135], [53, 150]]) {
    const harness = Free85Harness.boot();
    harness.machine.write8(CHAR_INDEX, index);
    harness.tap("2ND");
    harness.tap("0");
    assert.equal(harness.machine.read8(UI_SCREEN), SCREEN_CHARACTERS);
    const before = harness.machine.renderLcdBitmap();
    assert.ok(before.litPixelCount > 80, `glyph ${code}`);
    if (code === 123) assertLcdGolden("phase21-extended-character", before);
    harness.tap("ENTER");
    assert.equal(harness.machine.read8(FREE85_EDITOR_BUFFER_ADDRESS), code);
  }
});

test("[link.transfer] ROM selection, policy, and command mailboxes are visible and cancellable", () => {
  const harness = Free85Harness.boot();
  harness.tap("2ND");
  harness.tap("X-VAR");
  harness.tap("ENTER");
  harness.tap("MORE");
  harness.tap("F1");
  assert.equal(harness.machine.read8(FREE85_LINK_MAILBOX.command), FREE85_LINK_COMMAND.send);
  assert.equal(harness.machine.read8(FREE85_LINK_MAILBOX.status), FREE85_LINK_STATUS.waiting);
  assert.equal(harness.machine.read8(FREE85_LINK_MAILBOX.duplicate), FREE85_DUPLICATE_POLICY.overwrite);
  assertLcdGolden("phase21-link-waiting", harness.machine.renderLcdBitmap());
  harness.tap("F5");
  assert.equal(harness.machine.read8(FREE85_LINK_MAILBOX.status), FREE85_LINK_STATUS.cancelled);
});

test("[link.transfer] packet encoding rejects corruption and round-trips metadata", () => {
  const packet = encodeFree85Packet({ type: 6, flags: 1, name: "TEXT", payload: Uint8Array.of(3, 65, 66, 67) }, 42);
  assert.deepEqual(decodeFree85Packet(packet), {
    sequence: 42,
    type: 6,
    name: "TEXT",
    external: false,
    payload: Uint8Array.of(3, 65, 66, 67)
  });
  const corrupt = Uint8Array.from(packet);
  corrupt[corrupt.length - 5] ^= 1;
  assert.throws(() => decodeFree85Packet(corrupt), (error) => error instanceof Free85LinkError && error.code === 4);
});

test("[link.transfer] two-machine mailbox loopback sends selected objects", () => {
  const left = Free85Harness.boot();
  const right = Free85Harness.boot();
  storeConstant(left, "RATE", 7.5);
  assert.equal(selectFree85Objects(left.machine, ({ name }) => name === "RATE"), 1);
  left.machine.write8(FREE85_LINK_MAILBOX.command, FREE85_LINK_COMMAND.send);
  right.machine.write8(FREE85_LINK_MAILBOX.command, FREE85_LINK_COMMAND.receive);
  right.machine.write8(FREE85_LINK_MAILBOX.duplicate, FREE85_DUPLICATE_POLICY.overwrite);
  const session = new Free85LinkSession(left.machine, right.machine);
  const result = session.service();
  assert.equal(result.received, 1);
  assert.equal(right.machine.read8(FREE85_LINK_MAILBOX.status), FREE85_LINK_STATUS.complete);
  assert.equal(evaluate(right, "RATE*2"), 15);
});

test("[link.transfer] skip, overwrite, and rename resolve duplicates deterministically", () => {
  const source = Free85Harness.boot();
  storeConstant(source, "RATE", 8);
  selectFree85Objects(source.machine, ({ name }) => name === "RATE");
  const packets = new Free85LinkSession(source.machine, source.machine).packets(source.machine, { selectedOnly: true });

  const skip = Free85Harness.boot();
  const original = storeConstant(skip, "RATE", 2).payload;
  new Free85LinkSession(source.machine, skip.machine).receive(skip.machine, packets, { duplicate: FREE85_DUPLICATE_POLICY.skip });
  assert.deepEqual(listFree85Objects(skip.machine).find(({ name, type }) => name === "RATE" && type === CONSTANT_TYPE).payload, original);

  const overwrite = Free85Harness.boot();
  storeConstant(overwrite, "RATE", 2);
  new Free85LinkSession(source.machine, overwrite.machine).receive(overwrite.machine, packets, { duplicate: FREE85_DUPLICATE_POLICY.overwrite });
  assert.equal(evaluate(overwrite, "RATE"), 8);

  const rename = Free85Harness.boot();
  storeConstant(rename, "RATE", 2);
  new Free85LinkSession(source.machine, rename.machine).receive(rename.machine, packets, { duplicate: FREE85_DUPLICATE_POLICY.rename });
  assert.equal(evaluate(rename, "RATE"), 2);
  assert.equal(evaluate(rename, "RATEA"), 8);
});

test("[link.transfer] interruption, corruption, and low memory roll back receiver objects", () => {
  const source = Free85Harness.boot();
  const target = Free85Harness.boot();
  storeConstant(source, "RATE", 11);
  storeConstant(target, "KEEP", 4);
  selectFree85Objects(source.machine, ({ name }) => name === "RATE");
  const session = new Free85LinkSession(source.machine, target.machine);
  const packets = session.packets(source.machine, { selectedOnly: true });
  const before = objectState(target.machine);
  for (const fault of [{ interruptAfterBytes: 1 }, { corruptPacketIndex: 0 }, { capacityLimit: 0 }]) {
    assert.throws(() => session.receive(target.machine, packets, { fault }), Free85LinkError);
    assert.deepEqual(objectState(target.machine), before);
  }

  const pressured = Free85Harness.boot();
  writeText(pressured.machine, NAME_A, "FILL");
  const allocation = callObjectStore(pressured.machine, 0x400e, { A: 6, BC: HEAP_CAPACITY - 50, HL: NAME_A });
  assert.equal(allocation.flags.C, false);
  const pressuredBefore = objectState(pressured.machine);
  const tooLarge = encodeFree85Packet({
    type: 6,
    flags: 1,
    name: "NEW",
    payload: new Uint8Array(100)
  });
  assert.throws(
    () => session.receive(pressured.machine, [tooLarge]),
    (error) => error instanceof Free85LinkError && error.code === 5
  );
  assert.deepEqual(objectState(pressured.machine), pressuredBefore);
});

test("[link.backup] restore replaces dynamic state and rolls back a failed archive", () => {
  const source = Free85Harness.boot();
  const target = Free85Harness.boot();
  storeConstant(source, "RATE", 6);
  storeConstant(target, "OLD", 99);
  const session = new Free85LinkSession(source.machine, target.machine);
  const backup = session.createBackup(source.machine);
  session.restore(target.machine, backup);
  assert.equal(listFree85Objects(target.machine).some(({ name }) => name === "OLD"), false);
  assert.equal(evaluate(target, "RATE"), 6);

  const rollback = Free85Harness.boot();
  storeConstant(rollback, "KEEP", 5);
  const before = objectState(rollback.machine);
  const broken = { ...backup, packets: backup.packets.map((packet) => Uint8Array.from(packet)) };
  broken.packets.at(-1)[broken.packets.at(-1).length - 5] ^= 1;
  broken.checksum = (() => {
    // Preserve the archive-level checksum failure path without exposing the
    // internal hash implementation: the original checksum is intentionally
    // now stale.
    return backup.checksum;
  })();
  assert.throws(() => session.restore(rollback.machine, broken), Free85LinkError);
  assert.deepEqual(objectState(rollback.machine), before);
});
