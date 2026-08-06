import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const OUT=process.argv[2];
function run(keys){const h=Free85Harness.boot();h.runFrames(5);
  for(const k of keys){if(typeof k==="number")h.runFrames(k);else h.tap(k);}return h;}
const PRE=["GRAPH",100,"2ND","MORE","MORE","MORE","F4",600,"EXIT",30,
  "ALPHA","0","GRAPH",1500,"2ND","2",60,"(-)","X-VAR","GRAPH",1500,
  "2ND","MORE","MORE","MORE","MORE",40,"F1",40];
writeFileSync(OUT+"/o_rk4.png", renderLcdPng(run([...PRE,"F2","F2",40,"F3",40,"+",40,"MORE",40,"F5",15000]).machine.renderLcdBitmap()));
writeFileSync(OUT+"/o_heun.png", renderLcdPng(run([...PRE,"F2",40,"F3",40,"+",40,"MORE",40,"F5",15000]).machine.renderLcdBitmap()));
writeFileSync(OUT+"/o_time.png", renderLcdPng(run([...PRE,"F2","F2",40,"F3",40,"+",40,"F5",15000]).machine.renderLcdBitmap()));
console.log("rendered");
