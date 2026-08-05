import { writeFileSync } from "node:fs";
import { Free85Harness } from "./test/helpers/free85-harness.js";
import { renderLcdPng } from "./test/helpers/lcd-visual.js";
const D={"0":"0","1":"1","2":"2","5":"5",".":".","-":"(-)","(":"(",")":")","^":"^"};
function shot(name,s){
  const h=Free85Harness.boot(); h.runFrames(5);
  for(const c of s) h.tap(D[c]);
  h.tap("ENTER"); h.runFrames(1200);
  writeFileSync(process.argv[2]+"/"+name+".png", renderLcdPng(h.machine.renderLcdBitmap()));
}
shot("negbase","(-2)^0.5"); shot("zeroneg","0^(-1)");
