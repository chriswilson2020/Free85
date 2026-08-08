// Resolve every cross-reference in Explorations against the two books' real
// headings.
//
// Explorations refers to the Guidebook and to itself in identical words:
// "chapter 16" is the Guidebook, "Chapter 2" is this book, and the two sit in
// the same paragraph. Capitalisation is not a reliable signal - the solutions
// chapter says "chapter 5 hunted a root" about this book, in lower case - so
// the only thing that separates them is whether the word "Guidebook" governs
// the reference. Nothing else in the build resolves these, which means a
// renumber can repoint every Guidebook link and still produce a book that
// builds, at the same page count, with no warning.
//
// A reference governed by "the Guidebook," must name a real Guidebook chapter.
// Every other reference must name a real chapter or section of Explorations.
// Both books wrap their prose at roughly 76 columns, so a reference is matched
// across newlines: "the Guidebook,\nchapter 6" is one reference, and reading
// it a line at a time is what makes it look ambiguous.
import { readFileSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
const COMPANION = `${root}docs/companion/`;
const GUIDEBOOK = `${root}docs/guidebook/`;

const sources = (dir) => readdirSync(dir)
  .filter((f) => /^\d\d-.*\.md$/.test(f)).sort();

// Chapter numbers a book actually has, and the sections under each.
function headings(dir) {
  const chapters = new Set();
  const sections = new Set();
  for (const file of sources(dir)) {
    const text = readFileSync(dir + file, "utf8");
    for (const m of text.matchAll(/^# Chapter (\d+):/gm)) chapters.add(+m[1]);
    for (const m of text.matchAll(/^#{2,3} (\d+)\.(\d+)\s/gm)) {
      sections.add(`${+m[1]}.${+m[2]}`);
    }
  }
  return { chapters, sections };
}

const own = headings(COMPANION);
const guide = headings(GUIDEBOOK);

// "chapter 16", "Chapter 2", "chapters 5 and 6", "section 4.4", "Section 7.6".
const REF = /\b([Cc]hapters?|[Ss]ections?)(\s+)(\d+(?:\.\d+)?)((?:\s*(?:and|to)\s*\d+(?:\.\d+)?)*)/g;

const problems = [];
let checked = 0;

for (const file of sources(COMPANION)) {
  const text = readFileSync(COMPANION + file, "utf8");
  for (const m of text.matchAll(REF)) {
    const word = m[1].toLowerCase();
    // Fold the preceding text so a reference that wraps still shows the
    // "Guidebook," that governs it.
    const before = text.slice(Math.max(0, m.index - 400), m.index)
      .replace(/\s+/g, " ");
    // The word "Guidebook" often governs a whole list: "The Guidebook covers
    // all four: chapter 3 for the calculus commands, 16 for programs". So look
    // back to the start of the sentence, not just at the word in front.
    const sentence = before.split(/(?<=[.?!]) (?=[A-Z*`\[])/).pop();
    // Within such a sentence the book still distinguishes the two by case:
    // lower-case "chapter 3" continues the Guidebook citation, while capital
    // "Chapter 5" turns back to this book, as in "The Guidebook, chapter 3
    // tells that story at SIN(PI/2), and Chapter 5's cardioid meets it again".
    const isGuidebook = /guidebook,?\s*$/i.test(before)
      || (/guidebook/i.test(sentence) && m[1][0] === m[1][0].toLowerCase());
    const numbers = [m[3], ...(m[4] ?? "").match(/\d+(?:\.\d+)?/g) ?? []];
    const line = text.slice(0, m.index).split("\n").length;

    for (const number of numbers) {
      checked += 1;
      const section = number.includes(".");
      if (section && word.startsWith("chapter")) continue;   // "chapter 3.1" is not a form the book uses
      const book = isGuidebook ? guide : own;
      const label = isGuidebook ? "the Guidebook" : "Explorations";
      const ok = section
        ? book.sections.has(number)
        : book.chapters.has(+number);
      // The Guidebook's sections are written "4-3", never "4.3", so a dotted
      // reference under "the Guidebook," is checked against its chapters only.
      if (section && isGuidebook) continue;
      if (!ok) {
        problems.push(`${file}:${line}: "${m[0].replace(/\s+/g, " ")}" `
          + `resolves to ${label} ${section ? "section" : "chapter"} ${number}, `
          + `which does not exist`);
      }
    }
  }
}

if (problems.length) {
  for (const p of problems) console.error(p);
  console.error(`\ncompanion cross-references: ${problems.length} of ${checked} `
    + `do not resolve`);
  process.exit(1);
}
console.log(`companion cross-references: all ${checked} resolve `
  + `(Explorations chapters ${[...own.chapters].sort((a, b) => a - b).join(", ")}; `
  + `${own.sections.size} sections)`);
