import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const OUT=process.argv[2];
function run(keys){const h=Free85Harness.boot();h.runFrames(5);
  for(const k of keys){if(typeof k==="number")h.runFrames(k);else h.tap(k);}return h;}
// plot X, then open the window editor
const BASE=["X-VAR","GRAPH",2500];
writeFileSync(OUT+"/win.png", renderLcdPng(run([...BASE,"2ND","GRAPH",60,"MORE","MORE",40,"F5",60]).machine.renderLcdBitmap()));
// the zoom page that now carries WIN
writeFileSync(OUT+"/zoom3.png", renderLcdPng(run([...BASE,"2ND","GRAPH",60,"MORE","MORE",60]).machine.renderLcdBitmap()));
console.log("rendered");
