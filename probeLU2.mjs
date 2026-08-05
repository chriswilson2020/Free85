import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const cellKeys=(v)=>v.flatMap(x=>[...String(x).split("").map(c=>c==="-"?"(-)":c),"ENTER"]);
function shot(name, cells){
  const h=Free85Harness.boot(); h.runFrames(5);
  for(const k of ["2ND","7"]) h.tap(k); h.runFrames(30);
  for(const k of cellKeys(cells)) h.tap(k);
  for(const k of ["MORE","MORE","MORE","MORE"]) h.tap(k); h.runFrames(30);
  h.tap("F1"); h.runFrames(3000);
  writeFileSync(process.argv[2]+"/"+name+".png", renderLcdPng(h.machine.renderLcdBitmap()));
}
shot("lu2x2_pivot",[0,1,2,3]);   // guidebook's pivoting example
shot("lu2x2_plain",[4,3,6,3]);   // guidebook's non-pivoting example
