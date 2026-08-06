import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const OUT=process.argv[2];
function run(keys){const h=Free85Harness.boot();h.runFrames(5);
  for(const k of keys){if(typeof k==="number")h.runFrames(k);else h.tap(k);}return h;}
const EQ=["GRAPH",100,"2ND","MORE","MORE","MORE","F4",600,"EXIT",30,
  "ALPHA","0","GRAPH",1500,"2ND","2",60,"(-)","X-VAR","GRAPH",1500];
// step 1: what does EXIT from the table land on?
writeFileSync(OUT+"/s1.png", renderLcdPng(run([...EQ,"MORE",400,"-","-","-","-",80,"EXIT",200]).machine.renderLcdBitmap()));
// step 2: then the setup page
writeFileSync(OUT+"/s2.png", renderLcdPng(run([...EQ,"MORE",400,"-","-","-","-",80,"EXIT",200,
  "2ND","MORE","MORE","MORE","MORE",60]).machine.renderLcdBitmap()));
console.log("rendered");
