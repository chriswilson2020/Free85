import { writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { TI85_PHYSICAL_KEYS } from "../src/ti85-keys.js";
import { Free85Harness } from "../test/helpers/free85-harness.js";
import { writeLcdGolden } from "../test/helpers/lcd-visual.js";

const GRAPH_ACTIVE = 0x8502;
const alphaKeys = new Map(TI85_PHYSICAL_KEYS
  .filter(({ alpha }) => /^[A-Z]$/.test(alpha ?? ""))
  .map(({ alpha, key }) => [alpha, key]));
const cases = [
  { name: "sine-5x", expression: "5*SIN(X)" },
  { name: "parabola", expression: "X^2-4" },
  { name: "reciprocal", expression: "1/X" },
  { name: "square-root", expression: "SQRT(X)" }
];

function typeExpression(harness, expression) {
  for (let index = 0; index < expression.length; index += 1) {
    const character = expression[index];
    if (/[A-Z]/.test(character)) {
      harness.tap("ALPHA");
      harness.tap(alphaKeys.get(character));
    } else if (character === "-" && (index === 0 || "(,+-*/^".includes(expression[index - 1]))) {
      harness.tap("(-)");
    } else {
      harness.tap(character);
    }
  }
}

function renderGraph(expression) {
  const harness = Free85Harness.boot();
  typeExpression(harness, expression);
  harness.tap("GRAPH");
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) !== 0 && frames < 5000) {
    harness.runFrames(100);
    frames += 100;
  }
  if (harness.machine.read8(GRAPH_ACTIVE) !== 0) throw new Error(`${expression} exceeded 5000 frames`);
  return { bitmap: harness.machine.renderLcdBitmap(), frames };
}

const manifest = { schemaVersion: 1, width: 128, height: 64, cases: [] };
for (const graphCase of cases) {
  const { bitmap, frames } = renderGraph(graphCase.expression);
  writeLcdGolden(graphCase.name, bitmap);
  manifest.cases.push({
    ...graphCase,
    frames,
    litPixelCount: bitmap.litPixelCount,
    checksum: bitmap.checksum.toString(16).padStart(8, "0").toUpperCase()
  });
  console.log(`Approved ${graphCase.name}: ${graphCase.expression} (${bitmap.litPixelCount} pixels)`);
}
const manifestPath = fileURLToPath(new URL("../test/free85/goldens/graphs/manifest.json", import.meta.url));
writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
console.log(`Wrote ${manifestPath}`);
