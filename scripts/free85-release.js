import { createHash } from "node:crypto";
import { readFile, writeFile } from "node:fs/promises";

const [rom, coverageText, performanceText, packageText] = await Promise.all([
  readFile("ROM/FREE85.ROM"),
  readFile("spec/free85/coverage.json", "utf8"),
  readFile("spec/free85/performance.json", "utf8"),
  readFile("package.json", "utf8")
]);
const coverage = JSON.parse(coverageText);
const performance = JSON.parse(performanceText);
const packageJson = JSON.parse(packageText);

if (rom.length !== 131072) throw new Error(`Release ROM is ${rom.length} bytes instead of 131072`);
if (coverage.phase !== 12 || coverage.features.complete_test_percent !== 100) {
  throw new Error("Release coverage is not Phase 12 at 100 percent");
}
if (performance.phase !== 12 || performance.release !== packageJson.version) {
  throw new Error("Release performance report does not match the package version");
}

const manifest = {
  schema_version: 1,
  name: "Free85",
  version: packageJson.version,
  phase: 12,
  license: "MIT",
  rom: {
    path: "ROM/FREE85.ROM",
    bytes: rom.length,
    sha256: createHash("sha256").update(rom).digest("hex"),
    banks: 8,
    bank_bytes: 16384
  },
  source: "firmware/free85/",
  build_instructions: "README.md#build-the-rom",
  coverage_report: "spec/free85/coverage.json",
  performance_report: "spec/free85/performance.json",
  known_limitations: "docs/known-limitations.md",
  notices: ["LICENSE", "NOTICE.md", "firmware/free85/LICENSE"],
  browser_default: "public/ti85-app.js"
};

const output = `${JSON.stringify(manifest, null, 2)}\n`;
if (process.argv.includes("--write")) await writeFile("spec/free85/release.json", output);
console.log(output.trimEnd());
