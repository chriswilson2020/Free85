import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const h=Free85Harness.boot(); h.runFrames(30);
writeFileSync(process.argv[2]+"/boot30.png", renderLcdPng(h.machine.renderLcdBitmap()));
