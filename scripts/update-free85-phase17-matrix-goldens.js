import { Free85Harness } from "../test/helpers/free85-harness.js";
import { writeLcdGolden } from "../test/helpers/lcd-visual.js";

const harness = Free85Harness.boot();
harness.tap("2ND");
harness.tap("7");
harness.tap("X-VAR");
for (let index = 0; index < 8; index += 1) harness.tap("+");
writeLcdGolden("phase17-matrix-3x6-editor", harness.machine.renderLcdBitmap());
