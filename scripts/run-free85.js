import { Free85Harness } from "../test/helpers/free85-harness.js";

const harness = Free85Harness.boot();
for (const key of process.argv.slice(2)) harness.tap(key);
const frame = harness.machine.renderLcdBitmap();
for (let y = 0; y < frame.height; y += 2) {
  let line = "";
  for (let x = 0; x < frame.width; x += 2) {
    const lit = frame.pixels[(y * frame.width) + x]
      || frame.pixels[(y * frame.width) + x + 1]
      || frame.pixels[((y + 1) * frame.width) + x]
      || frame.pixels[((y + 1) * frame.width) + x + 1];
    line += lit ? "#" : " ";
  }
  console.log(line.trimEnd());
}
console.log(JSON.stringify(harness.signature(), null, 2));

