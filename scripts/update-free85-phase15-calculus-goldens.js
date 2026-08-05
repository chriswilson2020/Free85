import { Free85Harness } from "../test/helpers/free85-harness.js";
import { writeLcdGolden } from "../test/helpers/lcd-visual.js";

const GRAPH_ENABLED = 0x8501;
const GRAPH_ACTIVE = 0x8502;
const GRAPH_EQ1 = 0x8510;
const GRAPH_EQ2 = 0x8541;

function writeSlot(harness, address, source) {
  harness.machine.write8(address, source.length);
  for (let index = 0; index < source.length; index += 1) {
    harness.machine.write8(address + 1 + index, source.charCodeAt(index));
  }
}

function finishPlot(harness, limit) {
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) && frames < limit) {
    harness.runFrames(100);
    frames += 100;
  }
  if (harness.machine.read8(GRAPH_ACTIVE)) throw new Error(`plot exceeded ${limit} frames`);
}

for (const { name, first, second, limit } of [
  { name: "phase15-calculus-derivative", first: "X^2", second: "NDER(1,X)", limit: 10000 },
  { name: "phase15-calculus-accumulator", first: "2*X", second: "FNINT(1,0,X)", limit: 25000 }
]) {
  const harness = Free85Harness.boot();
  harness.tap("GRAPH");
  finishPlot(harness, 10000);
  writeSlot(harness, GRAPH_EQ1, first);
  writeSlot(harness, GRAPH_EQ2, second);
  harness.machine.write8(GRAPH_ENABLED, 3);
  harness.tap("GRAPH");
  finishPlot(harness, limit);
  writeLcdGolden(name, harness.machine.renderLcdBitmap());
}
