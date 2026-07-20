import { readFileSync, readdirSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
const read = (p) => JSON.parse(readFileSync(`${root}${p}`, "utf8"));
const dir = `${root}docs/guidebook/`;
const failures = [];

// 1. Every coverage chapter has a numbered chapter file.
const coverage = read("spec/free85/guidebook-coverage.yaml");
const files = existsSync(dir) ? readdirSync(dir).filter((f) => f.endsWith(".md")) : [];
for (const ch of coverage.chapters) {
  if (typeof ch.chapter !== "number") continue; // appendices row
  const prefix = String(ch.chapter).padStart(2, "0");
  if (!files.some((f) => f.startsWith(`${prefix}-`))) failures.push(`missing chapter file ${prefix}-*.md (${ch.topic})`);
}

// 2. Every equivalent ledger item is mentioned somewhere in the book.
// Only the numbered chapter files (NN-*.md) count as "the book" here — the
// generated appendix-*.md files (notably Appendix A, the full command
// catalog) mention essentially every command by construction, so including
// them would make this check vacuously pass regardless of whether the
// chapters actually document each item.
const chapterFiles = files.filter((f) => /^\d\d-/.test(f));
const book = chapterFiles.map((f) => readFileSync(`${dir}${f}`, "utf8")).join("\n").toLowerCase();
const ledger = read("spec/free85/guidebook-command-ledger.yaml");
for (const group of ledger.groups) {
  if (group.status !== "equivalent") continue;
  for (const item of group.items) {
    if (!book.includes(String(item).toLowerCase())) failures.push(`ledger item not documented: ${item} (${group.id})`);
  }
}

// 3. The manual exists.
if (!existsSync(`${root}docs/manual/Free85-Manual.md`)) failures.push("missing docs/manual/Free85-Manual.md");

if (failures.length) {
  console.error(`guidebook traceability FAILED (${failures.length}):`);
  for (const f of failures) console.error(`  - ${f}`);
  process.exit(1);
}
console.log("guidebook traceability OK");
