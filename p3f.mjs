import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const OUT=process.argv[2];
function run(keys){const h=Free85Harness.boot();h.runFrames(5);
  for(const k of keys){if(typeof k==="number")h.runFrames(k);else h.tap(k);}return h;}
const shot=(n,k)=>writeFileSync(`${OUT}/${n}.png`, renderLcdPng(run(k).machine.renderLcdBitmap()));
// DRAW page 4 (CUSTOM then three MOREs) on a completed graph
shot("draw4",["X-VAR","GRAPH",2500,"CUSTOM",40,"MORE","MORE","MORE",60]);
// DEQ setup page under 3.0
shot("deq30",["GRAPH",100,"2ND","MORE","MORE","MORE","F4",600,"EXIT",30,
  "ALPHA","0","GRAPH",1500,"2ND","MORE","MORE","MORE","MORE",60]);
// matrix editor with columns grown out to six
shot("mat6",["2ND","7",40,"X-VAR","+","+","+","+",60]);
console.log("rendered");
