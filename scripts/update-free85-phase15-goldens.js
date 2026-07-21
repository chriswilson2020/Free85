import { writeFileSync } from "node:fs";
import {
  PHASE15_GOLDEN_CASES,
  PHASE15_MENU_CASES,
  renderPhase15Case,
  renderPhase15Menu
} from "../test/helpers/phase15-drawing.js";
import { writeLcdGolden } from "../test/helpers/lcd-visual.js";

const manifest = { schemaVersion: 1, phase: "14.4", width: 128, height: 64, cases: [] };
for (const drawingCase of PHASE15_GOLDEN_CASES) {
  const bitmap = renderPhase15Case(drawingCase).machine.renderLcdBitmap();
  writeLcdGolden(drawingCase.name, bitmap);
  manifest.cases.push({
    name: drawingCase.name,
    litPixelCount: bitmap.litPixelCount,
    checksum: bitmap.checksum.toString(16).padStart(8, "0").toUpperCase()
  });
  console.log(`Approved ${drawingCase.name} (${bitmap.litPixelCount} pixels, ${bitmap.checksum.toString(16).padStart(8, "0").toUpperCase()})`);
}
for (const menuCase of PHASE15_MENU_CASES) {
  const bitmap = renderPhase15Menu(menuCase.page).machine.renderLcdBitmap();
  writeLcdGolden(menuCase.name, bitmap);
  manifest.cases.push({
    name: menuCase.name,
    litPixelCount: bitmap.litPixelCount,
    checksum: bitmap.checksum.toString(16).padStart(8, "0").toUpperCase()
  });
  console.log(`Approved ${menuCase.name} (${bitmap.litPixelCount} pixels, ${bitmap.checksum.toString(16).padStart(8, "0").toUpperCase()})`);
}
writeFileSync("test/free85/goldens/graphs/phase15-manifest.json", `${JSON.stringify(manifest, null, 2)}\n`);
