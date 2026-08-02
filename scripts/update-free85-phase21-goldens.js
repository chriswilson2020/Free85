import { writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { Free85Harness } from "../test/helpers/free85-harness.js";
import { writeLcdGolden } from "../test/helpers/lcd-visual.js";

function capture(name, prepare) {
  const harness = Free85Harness.boot();
  prepare(harness);
  const bitmap = harness.machine.renderLcdBitmap();
  writeLcdGolden(name, bitmap);
  return {
    name,
    litPixelCount: bitmap.litPixelCount,
    checksum: bitmap.checksum.toString(16).padStart(8, "0").toUpperCase()
  };
}

const cases = [
  capture("phase19-home-version", () => {}),
  capture("phase14-memory-browser", (harness) => {
    harness.tap("2ND");
    harness.tap("+");
  }),
  capture("phase21-user-constants", (harness) => {
    harness.tap("2ND");
    harness.tap("4");
    harness.tap("MORE");
    harness.tap("MORE");
    harness.tap("F1");
    harness.tap("ALPHA");
    for (const key of ["5", "LOG", "-", "^"]) harness.tap(key); // RATE
    harness.tap("ENTER");
    harness.tap("ALPHA");
    harness.tap("9");
    harness.tap("ENTER");
  }),
  capture("phase21-extended-character", (harness) => {
    harness.machine.write8(0x9306, 26);
    harness.tap("2ND");
    harness.tap("0");
  }),
  capture("phase21-link-waiting", (harness) => {
    harness.tap("2ND");
    harness.tap("X-VAR");
    harness.tap("ENTER");
    harness.tap("MORE");
    harness.tap("F1");
  })
];

const manifestPath = fileURLToPath(new URL("../test/free85/goldens/graphs/phase21-manifest.json", import.meta.url));
writeFileSync(manifestPath, `${JSON.stringify({ schemaVersion: 1, width: 128, height: 64, cases }, null, 2)}\n`);
for (const entry of cases) console.log(`Approved ${entry.name}: ${entry.litPixelCount} pixels`);
