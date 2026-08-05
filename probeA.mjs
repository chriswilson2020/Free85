import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const h = Free85Harness.boot(); h.runFrames(5);
for (const k of ["(","X-VAR","X^2","-","4",")","/","(","X-VAR","-","2",")"]) h.tap(k);
h.tap("GRAPH"); h.runFrames(2500); h.tap("EXIT"); h.runFrames(60); h.tap("CLEAR"); h.runFrames(20);
for (const k of ["ALPHA","^","ALPHA","2","ALPHA","LOG","ALPHA","7","(","2",")"]) h.tap(k);
h.tap("ENTER"); h.runFrames(1200);
writeFileSync(process.argv[2] + "/hole.png", renderLcdPng(h.machine.renderLcdBitmap()));
