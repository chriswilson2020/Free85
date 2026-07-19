import { Free85Harness } from "../test/helpers/free85-harness.js";

const harness = Free85Harness.boot();
const keys = ["1", "2", "3", "+", "CLEAR", "EXIT"];
const eventCount = 10000;

for (let index = 0; index < eventCount; index += 1) {
  harness.tap(keys[index % keys.length], 1, 1);
}

const state = harness.machine.getDebugState();
if (harness.machine.read8(0x8000) !== 70 || harness.machine.read8(0x8003) !== 12) {
  throw new Error("Free85 state header was corrupted during the key-event stress run");
}
if (state.cpu.registers.SP < 0xfb00 || state.cpu.registers.SP > 0xfc00) {
  throw new Error(`Free85 stack escaped its reserved range: ${state.cpu.registers.SP.toString(16)}`);
}
if (!state.lcd.enabled || state.display.litPixelCount === 0) {
  throw new Error("Free85 display stopped during the key-event stress run");
}

console.log(`Free85 remained responsive after ${eventCount} automated key events.`);
