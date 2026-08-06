import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const OUT=process.argv[2];
function run(keys){const h=Free85Harness.boot();h.runFrames(5);
  for(const k of keys){if(typeof k==="number")h.runFrames(k);else h.tap(k);}return h;}
const shot=(n,k)=>writeFileSync(`${OUT}/${n}.png`, renderLcdPng(run(k).machine.renderLcdBitmap()));
const DEQ=["GRAPH",100,"2ND","MORE","MORE","MORE","F4",600,"EXIT",30];
const SETUP=["2ND","MORE","MORE","MORE","MORE",60];
// toggle SYSTEM on from the setup page
shot("sys1",[...DEQ,"ALPHA","0","GRAPH",1500,...SETUP,"F1",60]);
// NEXT cycles the selected field
shot("sys2",[...DEQ,"ALPHA","0","GRAPH",1500,...SETUP,"F1",40,"F3",40,"F3",60]);
// MORE toggles TIME / PHASE
shot("sys3",[...DEQ,"ALPHA","0","GRAPH",1500,...SETUP,"F1",40,"MORE",60]);
console.log("rendered");
