import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const cellKeys=(v)=>v.flatMap(x=>[...String(x).split("").map(c=>c==="-"?"(-)":c),"ENTER"]);
const h=Free85Harness.boot(); h.runFrames(5);
const keys=["2ND","7",30,"+","X-VAR","+","X-VAR",...cellKeys([0,2,1,2,4,6,1,1,1]),
  "MORE","MORE","MORE","MORE",30,"F1",3000];
for(const k of keys){ if(typeof k==="number") h.runFrames(k); else h.tap(k); }
writeFileSync(process.argv[2]+"/lu.png", renderLcdPng(h.machine.renderLcdBitmap()));
console.log("rendered");
