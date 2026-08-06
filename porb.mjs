import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const OUT=process.argv[2];
function run(keys){const h=Free85Harness.boot();h.runFrames(5);
  for(const k of keys){if(typeof k==="number")h.runFrames(k);else h.tap(k);}return h;}
const DEQ=["GRAPH",100,"2ND","MORE","MORE","MORE","F4",600,"EXIT",30];
const EQ=["ALPHA","0","GRAPH",1500,"2ND","2",60,"(-)","X-VAR","GRAPH",1500];
const SETUP=["2ND","MORE","MORE","MORE","MORE",40];
// halve the table step N times from the table screen, then plot the orbit
function orbit(halvings, methodPresses){
  const tbl=["MORE",300,...Array(halvings).fill("-"),60,"EXIT",60];
  return [...DEQ,...EQ,...tbl,...SETUP,"F1",40,
    ...Array(methodPresses).fill("F2"),40,"F3",40,"+",40,"MORE",40,"F5",20000];
}
writeFileSync(OUT+"/orb_e4.png", renderLcdPng(run(orbit(4,0)).machine.renderLcdBitmap()));
writeFileSync(OUT+"/orb_rk4_4.png", renderLcdPng(run(orbit(4,2)).machine.renderLcdBitmap()));
writeFileSync(OUT+"/orb_rk4_2.png", renderLcdPng(run(orbit(2,2)).machine.renderLcdBitmap()));
console.log("rendered");
