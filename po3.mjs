import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const OUT=process.argv[2];
function run(keys){const h=Free85Harness.boot();h.runFrames(5);
  for(const k of keys){if(typeof k==="number")h.runFrames(k);else h.tap(k);}return h;}
const PRE=["GRAPH",100,"2ND","MORE","MORE","MORE","F4",600,"EXIT",30,
  "ALPHA","0","GRAPH",1500,"2ND","2",60,"(-)","X-VAR","GRAPH",1500,
  "2ND","MORE","MORE","MORE","MORE",40,"F1",40,"F2","F2",40,"F3",40,
  ...Array(8).fill("+"),40];
writeFileSync(OUT+"/p8.png", renderLcdPng(run([...PRE,"MORE",40,"F5",20000]).machine.renderLcdBitmap()));
writeFileSync(OUT+"/t8.png", renderLcdPng(run([...PRE,"F5",20000]).machine.renderLcdBitmap()));
writeFileSync(OUT+"/p8e.png", renderLcdPng(run([...PRE.slice(0,PRE.indexOf("F2")),"F3",40,...Array(8).fill("+"),40,"MORE",40,"F5",20000]).machine.renderLcdBitmap()));
console.log("rendered");
