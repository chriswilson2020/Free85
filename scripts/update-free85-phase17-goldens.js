import { Free85Harness } from "../test/helpers/free85-harness.js";
import { writeLcdGolden } from "../test/helpers/lcd-visual.js";

function menu(keys, pages) {
  const harness = Free85Harness.boot();
  for (const key of keys) harness.tap(key);
  for (let index = 0; index < pages; index += 1) harness.tap("MORE");
  return harness.machine.renderLcdBitmap();
}

for (const [name, keys, pages] of [
  ["phase17-list-menu", ["2ND", "-"], 3],
  ["phase17-matrix-row-menu", ["2ND", "7"], 2],
  ["phase17-matrix-decomposition-menu", ["2ND", "7"], 4],
  ["phase17-vector-menu", ["2ND", "8"], 3]
]) {
  const bitmap = menu(keys, pages);
  writeLcdGolden(name, bitmap);
  console.log(`Approved ${name}: ${bitmap.litPixelCount} pixels`);
}
