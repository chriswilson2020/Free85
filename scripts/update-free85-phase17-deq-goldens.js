import { Free85Harness } from "../test/helpers/free85-harness.js";
import { writeLcdGolden } from "../test/helpers/lcd-visual.js";

const addresses = {
  enabled: 0x8501, active: 0x8502, eq1: 0x8510, eq2: 0x8541,
  xmin: 0x8600, xmax: 0x8609, ymin: 0x8612, ymax: 0x861b, tableStep: 0x863f,
  mode: 0x869a, initialY2: 0x8756, flags: 0x875f,
  initialT: 0x8760, initialX: 0x8769, method: 0x877b
};

function packed(value) {
  if (value === 0) return Uint8Array.of(0, 0, 0, 0, 0, 0, 0, 0, 0);
  const sign = value < 0 ? 0x80 : 0;
  const magnitude = Math.abs(value);
  const exponent = Math.floor(Math.log10(magnitude));
  const digits = (magnitude / (10 ** exponent)).toPrecision(14).replace(".", "").slice(0, 14);
  return Uint8Array.of(sign, exponent < 0 ? exponent + 256 : exponent,
    ...Array.from({ length: 7 }, (_, index) => (Number(digits[index * 2]) << 4) | Number(digits[index * 2 + 1])));
}

function writeNumber(harness, address, value) {
  packed(value).forEach((byte, index) => harness.machine.write8(address + index, byte));
}

function writeSlot(harness, address, source) {
  harness.machine.write8(address, source.length);
  [...source].forEach((character, index) => harness.machine.write8(address + 1 + index, character.charCodeAt(0)));
}

function finishPlot(harness) {
  for (let frames = 0; harness.machine.read8(addresses.active); frames += 1) {
    if (frames >= 40_000) throw new Error("system plot did not finish");
    harness.machine.runFrame();
  }
}

function system(phase = false) {
  const harness = Free85Harness.boot();
  harness.tap("GRAPH");
  finishPlot(harness);
  harness.runFrames(3);
  harness.machine.write8(addresses.mode, 3);
  harness.machine.write8(addresses.enabled, 3);
  harness.machine.write8(addresses.flags, 1 | (phase ? 2 : 0));
  harness.machine.write8(addresses.method, 2);
  writeSlot(harness, addresses.eq1, "Y");
  writeSlot(harness, addresses.eq2, "0-X");
  writeNumber(harness, addresses.initialT, 0);
  writeNumber(harness, addresses.initialX, 1);
  writeNumber(harness, addresses.initialY2, 0);
  writeNumber(harness, addresses.xmin, phase ? -1.2 : 0);
  writeNumber(harness, addresses.xmax, phase ? 1.2 : 6.4);
  writeNumber(harness, addresses.ymin, -1.2);
  writeNumber(harness, addresses.ymax, 1.2);
  if (phase) writeNumber(harness, addresses.tableStep, 0.05);
  harness.tap("GRAPH");
  finishPlot(harness);
  return harness;
}

for (const [name, phase] of [["phase17-deq-system-time", false], ["phase17-deq-phase-plane", true]]) {
  const harness = system(phase);
  const bitmap = harness.machine.renderLcdBitmap();
  writeLcdGolden(name, bitmap);
  console.log(`Approved ${name}: ${bitmap.litPixelCount} pixels`);
}

const setup = system(false);
for (const key of ["2ND", "MORE", "MORE", "MORE", "MORE"]) setup.tap(key);
writeLcdGolden("phase17-deq-system-setup", setup.machine.renderLcdBitmap());
console.log("Approved phase17-deq-system-setup");
