import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const h = Free85Harness.boot(); h.runFrames(10);
for (const k of ["ALPHA","^","ALPHA","2","ALPHA","LOG","ALPHA","7","(","1",")"]) h.tap(k);
h.tap("ENTER"); h.runFrames(800);
writeFileSync(process.argv[2] + "/empty.png", renderLcdPng(h.machine.renderLcdBitmap()));
