// Measures the companion's prose against the house style the rewrite brief
// sets out. The first edition had 49 sentences over 45 words, unevenly
// spread, and two causes accounted for nearly all of them: cross-reference
// pile-ups, and keystroke sequences narrated through subordinate clauses.
// This is the measurement that keeps them from coming back.
//
//   node scripts/check-companion-prose.js [word-limit]
import { readdirSync, readFileSync } from "node:fs";

const limit = Number(process.argv[2] ?? 45);
const dir = "docs/companion/";
const files = readdirSync(dir).filter((f) => /^\d\d-.*\.md$/.test(f)).sort();

let total = 0;
const report = [];

for (const file of files) {
  // Keep prose only: drop headings, table rows, figure lines and fenced
  // blocks, then rejoin wrapped lines within each paragraph.
  const paragraphs = [];
  let current = [];
  for (const line of readFileSync(dir + file, "utf8").split("\n")) {
    const trimmed = line.trim();
    const skip = trimmed.startsWith("#") || trimmed.startsWith("|")
      || trimmed.startsWith("![") || trimmed.startsWith("```");
    if (trimmed === "" || skip) {
      if (current.length) paragraphs.push(current.join(" "));
      current = [];
      continue;
    }
    current.push(trimmed.replace(/^(\d+\.|-|\*)\s+/, ""));
  }
  if (current.length) paragraphs.push(current.join(" "));

  const long = [];
  for (const paragraph of paragraphs) {
    // Bold and italic markers can sit between a full stop and the next
    // capital, so let them through the split or a run-on is reported that
    // the reader never sees.
    for (const sentence of paragraph.split(/(?<=[.?!])[*_]*\s+(?=[*_]*[A-Z(`[])/)) {
      const words = sentence.trim().split(/\s+/).filter(Boolean).length;
      if (words > limit) long.push({ words, text: sentence.trim() });
    }
  }
  total += long.length;
  if (long.length) report.push({ file, long });
}

console.log(`companion prose: ${total} sentences over ${limit} words`);
for (const { file, long } of report) {
  console.log(`\n  ${file}  (${long.length})`);
  for (const { words, text } of long.sort((a, b) => b.words - a.words)) {
    console.log(`    ${String(words).padStart(3)}  ${text}`);
  }
}
if (total === 0) console.log("\n  nothing over the limit.");
