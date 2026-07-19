import { writeFile } from "node:fs/promises";
import {
  createFree85Coverage,
  readFree85Specifications,
  validateFree85Specifications
} from "./free85-spec.js";

const specifications = await readFree85Specifications();
const errors = validateFree85Specifications(specifications);
if (errors.length > 0) {
  for (const error of errors) console.error(`- ${error}`);
  process.exitCode = 1;
} else {
  const coverage = createFree85Coverage(specifications);
  const output = `${JSON.stringify(coverage, null, 2)}\n`;
  await writeFile("spec/free85/coverage.json", output);
  console.log(output.trimEnd());
}

