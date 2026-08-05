import { Free85Harness } from "../test/helpers/free85-harness.js";
import { writeLcdGolden } from "../test/helpers/lcd-visual.js";

const harness = Free85Harness.boot();
harness.tap("GRAPH");
while (harness.machine.read8(0x8502)) harness.machine.runFrame();
harness.runFrames(3);
harness.machine.write8(0x869a, 3);
harness.machine.write8(0x8510, 1);
harness.machine.write8(0x8511, "1".charCodeAt(0));
harness.machine.write8(0x8501, 1);
for (const [index, byte] of [0x80, 0x01, 0x10, 0, 0, 0, 0, 0, 0].entries()) {
  harness.machine.write8(0x8760 + index, byte);
}
harness.tap("GRAPH");
while (harness.machine.read8(0x8502)) harness.machine.runFrame();
harness.runFrames(3);
for (const key of ["2ND", "MORE", "MORE", "MORE", "MORE"]) harness.tap(key);
writeLcdGolden("phase15-deq-setup", harness.machine.renderLcdBitmap());
