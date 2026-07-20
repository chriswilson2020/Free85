# Free85 Manual and Guidebook Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce the Free85 Getting Started Manual and 19-chapter reference Guidebook as clean-room Markdown plus generated PDFs, with real LCD screenshots, generated appendices, and a traceability check.

**Architecture:** Hand-written chapters live in `docs/manual/` and `docs/guidebook/`; three small Node scripts generate screenshots (via `Free85Harness` + `lcd-visual.js`), appendices (from the JSON-content contract files in `spec/free85/`), and PDFs (pandoc → HTML → headless Chrome). A standalone traceability script asserts the book covers every `equivalent` ledger item.

**Tech Stack:** Node 24 ESM scripts (no new dependencies — the `.yaml` contract files are JSON and parse with `JSON.parse`), pandoc (installed at `/opt/homebrew/bin/pandoc`), Google Chrome headless for PDF.

**Spec:** `docs/superpowers/specs/2026-07-20-manual-guidebook-design.md`

**Branch:** `docs/manual-guidebook` (already created)

---

## Conventions (used by every chapter task)

- **Key notation:** physical keys in square brackets: `[ENTER]`, `[2nd]`, `[ALPHA]`, `[F1]`…`[F5]`, `[GRAPH]`. Shifted functions as `[2nd] [x²]` style sequences. Key names must match `physical_key` values in `spec/free85/keymap.yaml`.
- **On-screen text** in code spans: `5*SIN(X)`.
- **Screenshots:** embedded as `![<alt text>](images/<name>.png)`. Every image name must exist as a case in `scripts/guidebook-screens.js`.
- **Gap callout** (exact form, so the traceability of flags is greppable):

  ```markdown
  > ⚠ **Planned:** <what is missing> (Free85 2.0, work package <id or "unscheduled">).
  ```

- **Hardware-dependent callout:**

  ```markdown
  > 🔌 **Hardware:** <what works in the emulator> — physical-cable validation is reported separately.
  ```

- **Chapter files:** `docs/guidebook/NN-<kebab-title>.md`, first line `# Chapter N: <Title>`.
- **Verifying key sequences:** before documenting any sequence, run it:
  `npm run run:free85 -- <KEY> <KEY> ...` and confirm the rendered framebuffer/signature shows the described behaviour. Key names come from `src/ti85-keys.js`.
- **Clean-room rule:** never consult TI documentation; sources are this repo's `docs/`, `spec/`, `firmware/`, and emulator behaviour. Prose must be original.
- **Commit style:** matches repo history (short imperative subject), with the `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>` trailer.

---

### Task 1: Screenshot generator

**Files:**
- Modify: `test/helpers/lcd-visual.js` (add one export; no existing function changes)
- Create: `scripts/guidebook-screens.js`
- Modify: `package.json` (add script `build:guidebook:screens`)

- [ ] **Step 1: Export a PNG renderer from lcd-visual.js**

Add at the end of `test/helpers/lcd-visual.js`:

```js
export function renderLcdPng(bitmap, scale = 4) {
  return renderPixels(bitmap, scale);
}
```

- [ ] **Step 2: Write `scripts/guidebook-screens.js`**

```js
import { mkdirSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { Free85Harness } from "../test/helpers/free85-harness.js";
import { renderLcdPng } from "../test/helpers/lcd-visual.js";

const OUT_DIR = fileURLToPath(new URL("../docs/guidebook/images/", import.meta.url));

// Each case boots a fresh machine and taps the listed keys.
// Names must be kebab-case and are referenced from the Markdown chapters.
export const SCREEN_CASES = [
  { name: "ch01-home-screen", keys: [] },
  { name: "ch01-mode-screen", keys: ["2ND", "MORE"] }
];

function capture({ keys }) {
  const harness = Free85Harness.boot();
  for (const key of keys) harness.tap(key);
  return harness.machine.renderLcdBitmap();
}

mkdirSync(OUT_DIR, { recursive: true });
for (const screenCase of SCREEN_CASES) {
  if (!/^[a-z0-9-]+$/.test(screenCase.name)) throw new Error(`bad name ${screenCase.name}`);
  writeFileSync(`${OUT_DIR}${screenCase.name}.png`, renderLcdPng(capture(screenCase)));
  console.log(`wrote ${screenCase.name}.png`);
}
```

Note: `["2ND", "MORE"]` for the mode screen is a guess — before committing,
verify the real mode-screen sequence with `npm run run:free85 -- 2ND MORE`
and adjust to whatever `keymap.yaml` says opens MODE (look for a `second`
entry labelled `MODE`). Chapter tasks append their own cases later.

- [ ] **Step 3: Add npm script**

In `package.json` scripts block add:

```json
"build:guidebook:screens": "node scripts/guidebook-screens.js",
```

- [ ] **Step 4: Run and verify determinism**

```sh
npm run build:guidebook:screens && shasum docs/guidebook/images/*.png > /tmp/a
npm run build:guidebook:screens && shasum docs/guidebook/images/*.png > /tmp/b
diff /tmp/a /tmp/b && echo DETERMINISTIC
```

Expected: `DETERMINISTIC`, and both PNGs look like real calculator screens
(open them to confirm — home screen should show the boot state).

- [ ] **Step 5: Commit**

```sh
git add test/helpers/lcd-visual.js scripts/guidebook-screens.js package.json docs/guidebook/images
git commit -m "Add guidebook LCD screenshot generator"
```

---

### Task 2: Appendix generators

**Files:**
- Create: `scripts/build-guidebook-appendices.js`
- Modify: `package.json` (add script `build:guidebook:appendices`)
- Generated output: `docs/guidebook/appendix-a-command-catalog.md`, `appendix-b-keymap.md`, `appendix-d-feature-status.md`

- [ ] **Step 1: Write the generator**

`scripts/build-guidebook-appendices.js`:

```js
import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
const read = (p) => JSON.parse(readFileSync(`${root}${p}`, "utf8"));
const HEADER = "<!-- Generated by scripts/build-guidebook-appendices.js — do not edit by hand. -->\n\n";
const esc = (s) => String(s).replace(/\|/g, "\\|");

const ledger = read("spec/free85/guidebook-command-ledger.yaml");
const keymap = read("spec/free85/keymap.yaml");
const coverage = read("spec/free85/guidebook-coverage.yaml");
const gaps = read("spec/free85/v2-parity-gaps.yaml");

// Appendix A: command catalog grouped by ledger group.
let a = `${HEADER}# Appendix A: Command and Function Catalog\n\n` +
  "Grouped by functional area. Status comes from the Free85 2.0 command " +
  "ledger: `equivalent` items work today; other statuses are tracked gaps.\n";
for (const group of ledger.groups) {
  a += `\n## ${group.id} (${group.status})\n\n`;
  if (group.target) a += `> Target: ${group.target}\n\n`;
  a += "| Item |\n| --- |\n";
  for (const item of group.items) a += `| \`${esc(item)}\` |\n`;
}
writeFileSync(`${root}docs/guidebook/appendix-a-command-catalog.md`, a);

// Appendix B: full keymap table.
let b = `${HEADER}# Appendix B: Complete Key Map\n\n` +
  "| Key | Normal | 2nd | ALPHA |\n| --- | --- | --- | --- |\n";
for (const key of keymap.keys) {
  const cell = (m) => m ? `${esc(m.label)} — ${esc(m.behaviour)}` : "—";
  b += `| \`${esc(key.physical_key)}\` | ${cell(key.normal)} | ${cell(key.second)} | ${cell(key.alpha)} |\n`;
}
writeFileSync(`${root}docs/guidebook/appendix-b-keymap.md`, b);

// Appendix D: chapter coverage + open 2.0 gaps.
let d = `${HEADER}# Appendix D: Feature Status and 2.0 Gaps\n\n## Chapter status\n\n` +
  "| Chapter | Topic | Status |\n| --- | --- | --- |\n";
for (const ch of coverage.chapters) d += `| ${ch.chapter} | ${esc(ch.topic)} | ${ch.status}${ch.reason ? ` — ${esc(ch.reason)}` : ""} |\n`;
d += "\n## Open work packages\n\n";
for (const gap of gaps.gaps ?? gaps.groups ?? []) d += `- **${esc(gap.id ?? "")}**: ${esc(gap.target ?? gap.reason ?? JSON.stringify(gap))}\n`;
writeFileSync(`${root}docs/guidebook/appendix-d-feature-status.md`, d);
console.log("wrote appendices A, B, D");
```

Before committing, inspect `spec/free85/v2-parity-gaps.yaml` and adjust the
Appendix D loop to its actual top-level shape (the `gaps ?? groups` fallback
is a guess — use the real property name and real per-entry fields).

- [ ] **Step 2: Add npm script**

```json
"build:guidebook:appendices": "node scripts/build-guidebook-appendices.js",
```

- [ ] **Step 3: Run and spot-check**

```sh
npm run build:guidebook:appendices
grep -c "^| " docs/guidebook/appendix-b-keymap.md   # expect 51 (50 keys + header separator counts one less; verify ~50 rows)
grep "sinh" docs/guidebook/appendix-a-command-catalog.md
grep "polar graphing" docs/guidebook/appendix-d-feature-status.md
```

Expected: keymap table has one row per key in `keymap.yaml` (50), `sinh`
appears in Appendix A, chapter 5 row appears in Appendix D.

- [ ] **Step 4: Commit**

```sh
git add scripts/build-guidebook-appendices.js package.json docs/guidebook/appendix-*.md
git commit -m "Generate guidebook appendices from spec contracts"
```

---

### Task 3: Traceability check (write first — it fails until the book is done)

**Files:**
- Create: `scripts/check-guidebook-traceability.js`
- Modify: `package.json` (add script `test:guidebook`)

- [ ] **Step 1: Write the check**

```js
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
const book = files.map((f) => readFileSync(`${dir}${f}`, "utf8")).join("\n").toLowerCase();
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
```

- [ ] **Step 2: Add npm script**

```json
"test:guidebook": "node scripts/check-guidebook-traceability.js",
```

- [ ] **Step 3: Run to verify it fails for the right reason**

```sh
npm run test:guidebook
```

Expected: FAIL listing 19 missing chapter files, missing manual, and many
undocumented ledger items. (It goes green in Task 13.)

- [ ] **Step 4: Commit**

```sh
git add scripts/check-guidebook-traceability.js package.json
git commit -m "Add guidebook traceability check"
```

---

### Task 4: Getting Started Manual

**Files:**
- Create: `docs/manual/Free85-Manual.md`
- Modify: `scripts/guidebook-screens.js` (add manual screenshots; images referenced as `../guidebook/images/<name>.png`)

- [ ] **Step 1: Add manual screenshot cases**

Append to `SCREEN_CASES` (verify each sequence with `npm run run:free85 -- <keys>` first):

```js
{ name: "manual-boot", keys: [] },
{ name: "manual-first-calc", keys: ["2", "+", "3", "ENTER"] },
{ name: "manual-soft-menu", keys: ["GRAPH"] },
{ name: "manual-catalog", keys: ["2ND", "CUSTOM"] }
```

Run `npm run build:guidebook:screens`.

- [ ] **Step 2: Write the manual**

Sections (write full original prose for each; verify every stated key
sequence via `npm run run:free85`):

1. **Welcome** — what Free85 is; independent clean-room firmware; MIT-style licensing per `LICENSE`/`NOTICE.md`; what "TI-85-compatible machine" means (Z80 @ 6 MHz, 128 KiB ROM, 32 KiB RAM, 128×64 LCD, 49 keys + ON).
2. **Running Free85** — GitHub Pages URL of the deployed browser app; `npm run dev` + <http://localhost:3000/>; loading another 128 KiB ROM; terminal preview `npm run run:free85 -- GRAPH`. Source: `README.md`.
3. **The keyboard** — layout zones (soft keys F1–F5, cursor pad, function rows, digit pad); `[2nd]` and `[ALPHA]` modifier behaviour incl. lowercase alpha; where every printed shifted function lives (point to Appendix B). Source: `spec/free85/keymap.yaml`, `src/ti85-keys.js`.
4. **The screen** — home screen layout, status region, soft-menu rows, editors; include `manual-boot` and `manual-soft-menu` screenshots.
5. **First calculations** — arithmetic entry, `[ENTER]`, ANS, previous-entry recall, editing with cursor/DEL/insert, error dismissal with `[CLEAR]`; include `manual-first-calc` screenshot.
6. **Modes** — AUTO/SCI/ENG/FIX display, angle modes, number bases (summary; details in Guidebook ch. 1 and 10). Source: `docs/Free85-numeric-modes.md`.
7. **Where next** — one-line map of the 19 Guidebook chapters.

- [ ] **Step 3: Verify sequences and traceability delta**

```sh
npm run run:free85 -- 2 + 3 ENTER   # confirm result display shows 5
npm run test:guidebook               # manual failure line disappears
```

- [ ] **Step 4: Commit**

```sh
git add docs/manual/Free85-Manual.md scripts/guidebook-screens.js docs/guidebook/images
git commit -m "Add Free85 Getting Started Manual"
```

---

### Task 5: Guidebook front matter + Chapter 1

**Files:**
- Create: `docs/guidebook/00-front-matter.md`, `docs/guidebook/01-operating-the-calculator.md`
- Modify: `scripts/guidebook-screens.js`

- [ ] **Step 1: Front matter** — title page text, clean-room notice (paraphrase `spec/free85/product.md` boundary), how to read key notation and callouts, table of contents listing chapters 1–19 and appendices A–D.

- [ ] **Step 2: Chapter 1 "Operating the Calculator"** — sections: power/ON; home screen; entry and editing (cursor, insert/overwrite, DEL, CLEAR); previous entries; ANS; menus and `[MORE]` paging; mode settings (display AUTO/SCI/ENG/FIX, angle, base — with screenshot); catalog `[2nd] [CUSTOM]`; custom menu `[CUSTOM]`; character palette. Gap callouts from coverage ch. 1 reason ("engineering and fixed-place display modes remain" — check `docs/Free85-numeric-modes.md` for what actually works today and flag only real gaps). Sources: `docs/Free85-specification.md` §9, §11.1–11.2; `test/free85/ui.test.js` for actual behaviour.

- [ ] **Step 3: Screenshots** — add and reference: `ch01-home-screen` (exists), `ch01-mode-screen` (exists — fix keys if Task 1 guess was wrong), `ch01-catalog`, `keys: ["2ND", "CUSTOM"]`; `ch01-custom-menu`, `keys: ["CUSTOM"]`. Regenerate.

- [ ] **Step 4: Verify + commit**

```sh
npm run build:guidebook:screens && npm run test:guidebook   # ch 1 failure gone
git add docs/guidebook scripts/guidebook-screens.js
git commit -m "Add guidebook front matter and chapter 1"
```

---

### Task 6: Chapters 2 and 18 (variables, object store, memory)

**Files:**
- Create: `docs/guidebook/02-variables-and-stored-data.md`, `docs/guidebook/18-memory-management.md`
- Modify: `scripts/guidebook-screens.js`

- [ ] **Step 1: Chapter 2** — storing with `[STO]`, naming rules, the five numeric memories, typed named-object directory (schema 13), reserved names, recalling values, deleting. Gap callouts from ledger `constants.user` (missing) if user constants belong here per coverage. Sources: `docs/Free85-object-store.md`, spec §11.5, §14; `test/free85/object-store.test.js`.

- [ ] **Step 2: Chapter 18** — memory browser by type, object sizes, individual deletion, reset, exact capacity accounting, 22,784-byte heap, migration from 1.0 state. Gap callout: "14.9 link selection and backup workflows remain" (per coverage ch. 18). Sources: `docs/Free85-object-store.md`, `test/free85/parity.test.js`.

- [ ] **Step 3: Screenshots** — `ch18-memory-browser` with the key sequence that opens the memory screen (find it in `keymap.yaml` — the `second` entries labelled `M1`…`M5` or a MEM menu; verify with `npm run run:free85`).

- [ ] **Step 4: Verify + commit** (same pattern as Task 5, message "Add guidebook chapters 2 and 18").

---

### Task 7: Chapter 3 (mathematics, calculus, comparisons)

**Files:**
- Create: `docs/guidebook/03-mathematics.md`
- Modify: `scripts/guidebook-screens.js`

- [ ] **Step 1: Write chapter** — sections: arithmetic and precedence; scientific functions (all of ledger `math.core` + `math.scientific` items — name each: `abs`, `sqrt`, `10^x`, `e^x`, `ln`, `log`, trig, inverse trig, hyperbolic, inverse hyperbolic); combinatorics (`factorial`, `nPr`, `nCr`); utilities (`fPart`, `iPart`, `int`, `mod`, `gcd`, `lcm`, `max`, `min`, `percent`, `root`, `round`, `sign`, `rand`); relational operators (`==`, `!=`, `<`, `<=`, `>`, `>=`); calculus callables (`arc`, `der1`, `der2`, `eval`, `evalF`, `fMax`, `fMin`, `fnInt`, `nDer`, `inter`, `peval`) noting the known limitation that they operate on active Y1 (`docs/known-limitations.md`); angle formats with gap callout for `->DMS`/`->Frac` (ledger `math.angle-format`, partial). Each function gets: one-line description, syntax, one worked example verified in the emulator. Sources: spec §11.3, §11.14, `docs/Free85-numeric-modes.md`, `test/free85/scientific.test.js` for expected values.

- [ ] **Step 2: Screenshots** — `ch03-math-menu` (the MATH soft menu; find opening key in keymap), `ch03-worked-example` (a verified calculation).

- [ ] **Step 3: Verify + commit** ("Add guidebook chapter 3").

---

### Task 8: Chapters 4–7 (graphing family)

**Files:**
- Create: `docs/guidebook/04-cartesian-graphing.md`, `05-polar-graphing.md`, `06-parametric-graphing.md`, `07-differential-equation-graphing.md`
- Modify: `scripts/guidebook-screens.js`

- [ ] **Step 1: Chapter 4** — equation editor (`[GRAPH]` menu: y(x)= etc.), entering/selecting functions, RANGE window variables, ZOOM (`ZIn`, `ZOut`, `ZStd`, `ZSqr` today; gap callout for `ZBox`/`ZFit`/`ZTrig`/factors per ledger `graph.zoom` partial), TRACE, graph format flags (gap callout per `graph.format` partial), MATH-on-graph tools (root/intersection per spec §11.15), tables (`[TABLE]`), cached tokenisation note. Gap callouts: drawing commands (`graph.draw` missing), graph/picture storage (`graph.persistence` missing). Sources: spec §11.15–11.16, `test/free85/graph.test.js`, existing goldens.

- [ ] **Step 2: Chapters 5, 6, 7 stubs** — each ~half page: what the mode will do, current status **missing**, planned work package 14.5 (5/6) and the diffeq package (7) per `guidebook-coverage.yaml`; where the keys currently lead (verify what `[2nd]`-mode entries do today in the emulator and describe honestly).

- [ ] **Step 3: Screenshots** — `ch04-equation-editor` (`keys: ["GRAPH"]` then the editor soft key — verify), `ch04-sine-plot` (reuse the key script from `scripts/update-free85-graph-goldens.js` `typeExpression` approach: boot, open editor, type `5*SIN(X)`, plot), `ch04-table`.

- [ ] **Step 4: Verify + commit** ("Add guidebook graphing chapters 4-7").

---

### Task 9: Chapters 8, 9, 10 (constants, strings, bases)

**Files:**
- Create: `docs/guidebook/08-constants-and-conversions.md`, `09-strings-and-characters.md`, `10-number-bases-and-boolean.md`
- Modify: `scripts/guidebook-screens.js`

- [ ] **Step 1: Chapter 8** — built-in constants and unit conversions as implemented (source: spec §11.4, `test/free85/scientific.test.js`, `test/free85/parity.test.js`; enumerate the actual constants/conversions from the CONS/CONV menus in the emulator). Gap callout: user-defined constants (`constants.user` missing).

- [ ] **Step 2: Chapter 9** — string creation, `Concatenate`, `lngth`, `sub`, character palette, catalog access. Gap callouts: `Eq->St`/`St->Eq` round trips and extended Greek/international characters (ledger `strings.core`, `characters.extended` partial). Sources: spec §11.17, `test/free85/strings-catalog-custom.test.js`.

- [ ] **Step 3: Chapter 10** — Bin/Oct/Dec/Hex display modes, signed 16-bit two's-complement entry (`docs/known-limitations.md`), base conversions (`->Bin` etc.), Boolean word ops (`and`, `or`, `xor`, `not`, `rotL`, `rotR`, `shftL`, `shftR`), interaction with ordinary BCD arithmetic. Source: `docs/Free85-numeric-modes.md`, `test/free85/v2-numeric-modes.test.js`.

- [ ] **Step 4: Screenshots** — `ch09-strings-editor` (`keys: ["2ND", "6"]`), `ch09-characters` (`keys: ["2ND", "0"]`), `ch10-base-example` (a verified hex-entry calculation).

- [ ] **Step 5: Verify + commit** ("Add guidebook chapters 8-10").

---

### Task 10: Chapters 11, 12, 13 (complex, lists, matrices/vectors)

**Files:**
- Create: `docs/guidebook/11-complex-numbers.md`, `12-lists.md`, `13-matrices-and-vectors.md`
- Modify: `scripts/guidebook-screens.js`

- [ ] **Step 1: Chapter 11** — complex entry, arithmetic, `angle`/`conj`/`imag`/`real`, polar/rectangular conversion as implemented; gap callout per ledger `complex.scalar` partial (catalog/program exposure) and `collections.elementwise` partial. Sources: spec §11.6, `test/free85/collections.test.js`.

- [ ] **Step 2: Chapter 12** — list editor (`[2nd] [-]`), max 8 elements (`docs/known-limitations.md`), `sum`, `prod`, `sortA`, `seq` as implemented; gap callouts per ledger `list.operations` partial (`dimL`, `Fill`, `sortD`, conversions). Sources: spec §11.7.

- [ ] **Step 3: Chapter 13** — matrix editor (`[2nd] [7]`), vector editor (`[2nd] [8]`), 3×3/3-component limits, `det`, inverse, `rref`, transpose, `dot`, `cross`, `unitV` as implemented; gap callouts per ledger `matrix.operations`/`vector.operations` partial (LU, eig, norms, fills) and `coordinates.vector` (cylindrical/spherical modes). Sources: spec §11.8–11.9.

- [ ] **Step 4: Screenshots** — `ch11-complex-editor` (`["2ND","9"]`), `ch12-list-editor` (`["2ND","-"]`), `ch13-matrix-editor` (`["2ND","7"]`), `ch13-vector-editor` (`["2ND","8"]`).

- [ ] **Step 5: Verify + commit** ("Add guidebook chapters 11-13").

---

### Task 11: Chapters 14, 15 (solvers, statistics)

**Files:**
- Create: `docs/guidebook/14-solving-equations.md`, `15-statistics.md`
- Modify: `scripts/guidebook-screens.js`

- [ ] **Step 1: Chapter 14** — simultaneous equations (`[2nd] [STAT]`→SIMULT per goldens script; up to 4×4), polynomial roots (`[2nd] [PRGM]`→POLY; degree ≤ 4), general zero-finding as implemented; gap callout per ledger `solver.general` partial (stored-equation multi-variable Solver). Sources: spec §11.11–11.13, `test/free85/statistics-solvers.test.js`.

- [ ] **Step 2: Chapter 15** — stat data editor (`[STAT]`), one/two-variable results, linear regression, histogram and scatter plots; gap callouts per ledger `statistics.models`/`statistics.commands`/`statistics.plots` partial (other regression families, forecasts, `ShwSt`, sorting, xyline). Sources: spec §11.10.

- [ ] **Step 3: Screenshots** — `ch14-simult-editor` (`["2ND","STAT"]`), `ch14-poly-editor` (`["2ND","PRGM"]`), `ch15-stat-editor` (`["STAT"]`).

- [ ] **Step 4: Verify + commit** ("Add guidebook chapters 14-15").

---

### Task 12: Chapters 16, 17, 19 (programming, worked examples, linking)

**Files:**
- Create: `docs/guidebook/16-programming.md`, `17-worked-examples.md`, `19-linking.md`
- Modify: `scripts/guidebook-screens.js`

- [ ] **Step 1: Chapter 16** — program list/editor (`[PRGM]`), 4 programs × 8 lines × 48 chars, control flow (`If`/`Then`/`Else`/`End`, `For`, `While`), `Disp`, numeric `Input`, `Return`, `Stop`, nesting limits (8 frames, 4 calls per `docs/known-limitations.md`); gap callouts per ledger `program.control`, `program.io`, `program.catalog` partial. Sources: spec §11.19, `test/free85/programming.test.js`.

- [ ] **Step 2: Chapter 17** — three complete worked examples exercising implemented features end-to-end, each fully verified in the emulator: (a) graph `X^2-4`, zoom standard, trace to a root, confirm with a calculus callable; (b) enter paired data, run linear regression, read slope/intercept; (c) write and run a small program (e.g. loop summing 1..10 with `For` and `Disp`). Every keystroke listed and tested via `npm run run:free85`.

- [ ] **Step 3: Chapter 19** — native link diagnostics as implemented; hardware-dependent callouts for item transfer and backup per ledger `link.transfer`/`link.backup`; clean-room note: no TI file-format compatibility (ledger `clean-room.exclusions`). Sources: spec §11.20, coverage ch. 19.

- [ ] **Step 4: Screenshots** — `ch16-program-list` (`["PRGM"]`), `ch16-program-editor` (`["PRGM","F1"]`), `ch17-regression-result` (verified sequence from example b).

- [ ] **Step 5: Verify + commit** ("Add guidebook chapters 16, 17 and 19").

---

### Task 13: Appendix C (errors) + traceability green

**Files:**
- Create: `docs/guidebook/appendix-c-errors.md`

- [ ] **Step 1: Extract the real error model** — read `firmware/free85/numeric/core.asm`, `numeric/evaluator.asm`, and UI error display code; list each error condition the firmware can raise (numeric error codes written to `0x805a`/`FREE85_NUMERIC_ERROR_ADDRESS`, syntax errors, `ERROR LINE` from programs per `firmware/free85/programming/phase10.asm:1632`, out-of-memory). For each: what triggers it, what the screen shows, how to recover (`[CLEAR]`). Trigger at least three representative errors in the emulator (e.g. `1/0`, unmatched parenthesis, `SQRT(-1)` in real mode) with `npm run run:free85` and document actual screens.

- [ ] **Step 2: Run the full traceability check**

```sh
npm run test:guidebook
```

Expected: `guidebook traceability OK`. If ledger items are missing, add them
to the right chapter (genuinely document them — no keyword stuffing).

- [ ] **Step 3: Commit** ("Add error appendix; guidebook traceability green").

---

### Task 14: PDF build

**Files:**
- Create: `scripts/build-guidebook-pdf.js`, `docs/guidebook/print.css`
- Modify: `package.json` (script `build:guidebook`), `.gitignore` (add `dist/`if absent)

- [ ] **Step 1: Write `docs/guidebook/print.css`**

```css
@page { size: A5; margin: 18mm 15mm; }
body { font-family: Georgia, serif; font-size: 10.5pt; line-height: 1.45; }
h1 { page-break-before: always; font-size: 18pt; }
h1:first-of-type { page-break-before: avoid; }
h2 { font-size: 13pt; margin-top: 1.4em; }
code, pre { font-family: "SF Mono", Menlo, monospace; font-size: 9pt; }
img { image-rendering: pixelated; width: 256px; display: block; margin: 0.6em 0; }
table { border-collapse: collapse; font-size: 9pt; }
th, td { border: 1px solid #999; padding: 2px 6px; }
blockquote { border-left: 3px solid #b58900; padding-left: 0.8em; color: #444; }
```

- [ ] **Step 2: Write `scripts/build-guidebook-pdf.js`**

```js
import { execFileSync } from "node:child_process";
import { mkdirSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
const out = `${root}dist/guidebook/`;
mkdirSync(out, { recursive: true });
const chrome = process.env.CHROME_BIN
  ?? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";

function buildPdf(name, inputs, resourcePath) {
  const html = `${out}${name}.html`;
  execFileSync("pandoc", [
    ...inputs, "--standalone", "--css", `${root}docs/guidebook/print.css`,
    "--embed-resources", `--resource-path=${resourcePath}`,
    "--metadata", `title=${name.replace(/-/g, " ")}`, "-o", html
  ]);
  execFileSync(chrome, [
    "--headless", "--disable-gpu", "--no-pdf-header-footer",
    `--print-to-pdf=${out}${name}.pdf`, `file://${html}`
  ]);
  console.log(`wrote dist/guidebook/${name}.pdf`);
}

const chapters = readdirSync(`${root}docs/guidebook/`)
  .filter((f) => /^\d\d-.*\.md$/.test(f)).sort()
  .map((f) => `${root}docs/guidebook/${f}`);
const appendices = ["a-command-catalog", "b-keymap", "c-errors", "d-feature-status"]
  .map((s) => `${root}docs/guidebook/appendix-${s}.md`);

buildPdf("Free85-Manual", [`${root}docs/manual/Free85-Manual.md`], `${root}docs/manual:${root}docs/guidebook`);
buildPdf("Free85-Guidebook", [...chapters, ...appendices], `${root}docs/guidebook`);
```

- [ ] **Step 3: Add npm script and gitignore entry**

```json
"build:guidebook": "npm run build:guidebook:screens && npm run build:guidebook:appendices && node scripts/build-guidebook-pdf.js",
```

Check `.gitignore` for `dist/`; add if missing.

- [ ] **Step 4: Build and inspect**

```sh
npm run build:guidebook
ls -la dist/guidebook/*.pdf
```

Expected: both PDFs exist, guidebook > 200 KB. Open both; check chapter page
breaks, screenshot rendering (crisp pixels, not blurred), tables fitting the
page. Fix CSS as needed.

- [ ] **Step 5: Commit** ("Add PDF build for manual and guidebook").

---

### Task 15: Finish line

- [ ] **Step 1: Full verification**

```sh
npm run test:guidebook
npm run build:guidebook
npm test        # confirm nothing existing broke (lcd-visual.js change is additive)
```

- [ ] **Step 2: README pointer** — add a short "Documentation" section to `README.md` linking `docs/manual/Free85-Manual.md`, `docs/guidebook/00-front-matter.md`, and the `npm run build:guidebook` command.

- [ ] **Step 3: Commit** ("Link manual and guidebook from README"), then present the branch to the user (merge/PR decision is theirs — use superpowers:finishing-a-development-branch).
