// Builds the professionally typeset (DTP) edition of the three Free85 books:
// the Getting Started Manual, the Guidebook, and Explorations with Free85.
//
// Pipeline: pandoc renders each book's Markdown to a single HTML document
// (images embedded as data: URIs), a transform stage rewrites that HTML into
// designed components (keycaps, callout panels, framed LCD screenshots,
// chapter openers, covers, a generated TOC), Paged.js paginates it to A5
// with running heads and folios, and headless Chrome prints the result.
//
// The plain pipeline (scripts/build-guidebook-pdf.js, `npm run
// build:guidebook`) is untouched and remains the fallback. Markdown sources
// are never modified: everything here is presentation only.
//
// Run via `npm run build:guidebook:typeset`.
import { execFileSync } from "node:child_process";
import { mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { TI85_PHYSICAL_KEYS } from "../src/ti85-keys.js";

const root = fileURLToPath(new URL("../", import.meta.url));
const webEdition = process.argv.includes("--web");
const outDir = webEdition ? `${root}public/guidebook/` : `${root}dist/guidebook/`;
mkdirSync(outDir, { recursive: true });
const chrome = process.env.CHROME_BIN
  ?? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";

const stylesheet = readFileSync(`${root}docs/guidebook/typeset.css`, "utf8");
const pagedPolyfill = readFileSync(`${root}scripts/vendor/paged.polyfill.js`, "utf8");
if (pagedPolyfill.includes("</script")) {
  throw new Error("paged.polyfill.js contains '</script' and cannot be inlined");
}

const EDITION = "For firmware 2.10 · Second Edition";
// Explorations is a new book, so it carries its own edition line.
const COMPANION_EDITION = "For firmware 2.10 · First Edition";
const PROJECT_URL = "chriswilson2020.github.io/Free85";

// ---------------------------------------------------------------- keycaps --

// Allowlist of genuine keycap tokens: every physical key label from the
// emulator's own key table, plus the single letters printed as ALPHA legends.
// Ordinary bracketed prose (e.g. interval notation, citation-style text)
// never matches because it is not in this list.
const keycapTokens = new Set();
for (const key of TI85_PHYSICAL_KEYS) {
  keycapTokens.add(key.label);
  if (key.alpha && /^[A-Z]$/.test(key.alpha)) keycapTokens.add(key.alpha);
}
const keycapAlternation = [...keycapTokens]
  .sort((a, b) => b.length - a.length)
  .map((t) => t.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
  .join("|");
const keycapRe = new RegExp(`\\[(${keycapAlternation})\\]`, "g");

// Applies fn to text nodes only, never inside code-like or replaced elements
// (so `[a,b]` interval notation in code spans is left alone, and attribute
// values are never touched).
function transformTextNodes(html, fn) {
  const parts = html.split(/(<[^>]+>)/);
  let skipDepth = 0;
  for (let i = 0; i < parts.length; i += 1) {
    const part = parts[i];
    if (part.startsWith("<")) {
      const m = part.match(/^<(\/?)(code|pre|kbd|script|style|textarea)\b/i);
      if (m) skipDepth = Math.max(0, skipDepth + (m[1] ? -1 : 1));
    } else if (skipDepth === 0 && part !== "") {
      parts[i] = fn(part);
    }
  }
  return parts.join("");
}

// ------------------------------------------------------------- transforms --

function markKeycaps(html, stats) {
  return transformTextNodes(html, (text) =>
    text.replace(keycapRe, (m, token) => {
      stats.keycaps += 1;
      return `<kbd>${token}</kbd>`;
    }));
}

// ⚠ **Planned:** / 🔌 **Hardware:** blockquotes become designed asides. The
// emoji stays out of print; a small-caps label takes its place.
function markCallouts(html, stats) {
  return html.replace(
    /<blockquote>\s*<p>(?:⚠|🔌)️?\s*<strong>(Planned|Hardware):<\/strong>\s*([\s\S]*?)<\/blockquote>/g,
    (m, label, rest) => {
      stats.callouts += 1;
      return `<aside class="callout callout-${label.toLowerCase()}">`
        + `<p class="callout-label">${label}</p><p>${rest.trim()}</aside>`;
    });
}

// Figures come in two kinds and must not be dressed alike. A capture of the
// machine's screen belongs behind bezel and glass, because the frame is what
// tells a reader "this is what you will see". A diagram of the mathematics is
// not a screen and must not pretend to be one: framing a pendulum sketch in a
// calculator bezel says the calculator drew it, which is a lie.
//
// A figure counts as a diagram if ANY of these hold:
//
//   1. it carries class="diagram", from `![caption](x.png){.diagram}` in the
//      Markdown. This is the explicit marker and the only one that works for
//      a raster diagram;
//   2. it is an SVG. Captures are always PNG out of the emulator, so every
//      SVG in these books is drawn artwork;
//   3. its file name starts with fig-, the naming convention.
//
// Test 3 alone is not enough: pandoc runs with --embed-resources, so by the
// time this sees the HTML the src is a data: URI and the file name is gone.
// A PNG diagram therefore MUST use {.diagram} or it will be framed as a
// screen. Prefer SVG for diagrams anyway — it stays sharp in print.
function frameScreenshots(html, stats) {
  return html.replace(
    /<figure>\s*(<img[^>]*>)\s*<figcaption[^>]*>([\s\S]*?)<\/figcaption>\s*<\/figure>/g,
    (m, img, caption) => {
      const cap = `<figcaption>${caption.trim()}</figcaption>`;
      const isDiagram = /class="[^"]*\bdiagram\b[^"]*"/.test(img)
        || /src="data:image\/svg/.test(img)
        || /src="[^"]*\/fig-[^"]*"/.test(img);
      if (isDiagram) {
        stats.diagrams += 1;
        return `<figure class="diagram">${img}${cap}</figure>`;
      }
      stats.figures += 1;
      return `<figure class="lcd"><div class="lcd-frame"><div class="lcd-glass">${img}</div></div>${cap}</figure>`;
    });
}

// Appendix B's four-column key map is the only table that cannot fit A5 at
// the standard size; tag it so the stylesheet can shrink it. Any other table
// longer than 12 rows is tagged table-long so it may break across pages
// (unbreakable near-full-page tables strand headings on empty pages).
//
// The companion's program listings are one repeating component, so they are
// tagged too: left to auto layout, each listing sizes its columns from its
// own longest cell, and the Keys column starts anywhere from a fifth to two
// thirds of the way across. Two listings on one page made that look like an
// accident rather than a grid.
function markKeymapTable(html) {
  return html.replace(/<table>([\s\S]*?)<\/table>/g, (m, inner) => {
    const headerRow = inner.slice(0, inner.indexOf("</tr>"));
    if (headerRow.includes("<th>Key</th>") && headerRow.includes("<th>ALPHA</th>")) {
      return `<table class="keymap">${inner}</table>`;
    }
    if (headerRow.includes("<th>Line</th>") && headerRow.includes("<th>Keys</th>")) {
      // Pandoc emits a colgroup of equal thirds for some of these (it depends
      // on the source table's total width), and under table-layout: fixed a
      // col width beats the cell widths. Four of the seven listings kept the
      // thirds, and one of them ran a stored-expression cell straight into
      // the first keycap. Drop the colgroup so the stylesheet's grid wins.
      return `<table class="program">${inner.replace(/<colgroup>[\s\S]*?<\/colgroup>/, "")}</table>`;
    }
    if ((inner.match(/<tr/g) ?? []).length > 12) {
      return `<table class="table-long">${inner}</table>`;
    }
    return m;
  });
}

// Paragraphs and list items that carry a long unbreakable token — a full
// precision number or repo path in a code span, or a bare slash-bearing
// path in plain prose (appendix D's generator emits its parenthesised spec
// path without a code span, which is how the first version of this tagger
// missed it) — set justified lines impossibly loose; tag them so the
// stylesheet can fall back to ragged right.
function markNumHeavyBlocks(html) {
  const candidates = [];
  for (const m of html.matchAll(/<code>([^<]+)<\/code>/g)) {
    const token = m[1];
    const numeric = token.length >= 13 && /^[-+0-9.,()eEi^\/ ]*[0-9][-+0-9.,()eEi^\/ ]*$/.test(token);
    const longPath = token.length >= 20 && !token.includes(" ");
    if (numeric || longPath) candidates.push(m.index);
  }
  // Long path-like tokens in text nodes, outside any tag or code span
  // (entities excluded so `&gt;` runs cannot inflate a token).
  let offset = 0;
  for (const part of html.split(/(<[^>]+>)/)) {
    if (!part.startsWith("<")) {
      for (const m of part.matchAll(/[^\s<>()&;]{20,}/g)) {
        if (m[0].includes("/")) candidates.push(offset + m.index);
      }
    }
    offset += part.length;
  }
  const positions = new Set();
  for (const index of candidates) {
    const before = html.slice(0, index);
    const open = Math.max(before.lastIndexOf("<p>"), before.lastIndexOf("<li>"));
    if (open < 0) continue;
    const tag = html.startsWith("<p>", open) ? "p" : "li";
    // Only tag if that element is still open where the token sits.
    if (before.indexOf(`</${tag}>`, open) !== -1) continue;
    positions.add(`${open}:${tag}`);
  }
  const edits = [...positions]
    .map((k) => ({ index: Number(k.split(":")[0]), tag: k.split(":")[1] }))
    .sort((a, b) => b.index - a.index);
  for (const { index, tag } of edits) {
    html = `${html.slice(0, index)}<${tag} class="num-heavy">${html.slice(index + tag.length + 2)}`;
  }
  return html;
}

// Explorations numbers its sections in the heading text ("## 1.1 Functions
// and their windows"). Lift the number out of the text into the same hung
// outer-margin ladder the Guidebook generates from counters, so the two books
// look alike and the heading reads as prose. The book's own dot form is kept
// (not the Guidebook's "4-3") because its cross-references say "section 1.4".
// Unnumbered H2s (chapter 8's closing section) are left alone.
function hangSectionNumbers(html, stats) {
  return html.replace(/<h2 id="([^"]+)">(\d+\.\d+)\s+([\s\S]*?)<\/h2>/g,
    (m, id, no, title) => {
      // Chapter 9's sections are worked solutions and have no Try it panel,
      // so they are tallied apart from the explorations they answer.
      if (no.startsWith("9.")) stats.solutions += 1;
      else stats.sections += 1;
      return `<h2 id="${id}" data-secno="${no}">${title.trim()}</h2>`;
    });
}

// Returns the index just past the <ol> whose opening tag starts at `open`,
// counting nested lists so a sub-list cannot end the match early.
function endOfList(html, open) {
  const tags = /<(\/?)ol\b[^>]*>/g;
  tags.lastIndex = open;
  let depth = 0;
  for (let m = tags.exec(html); m; m = tags.exec(html)) {
    depth += m[1] ? -1 : 1;
    if (depth === 0) return m.index + m[0].length;
  }
  return -1;
}

// The signature component of Explorations: every section ends with a
// "**Try it.**" line and a numbered exercise list. The pair becomes one
// tinted panel with the label in small caps — the family's callout ground and
// double rule, no new colour.
function markTryIt(html, stats) {
  const label = /<p><strong>Try it\.<\/strong><\/p>\s*(?=<ol\b)/g;
  const out = [];
  let cursor = 0;
  for (let m = label.exec(html); m; m = label.exec(html)) {
    const listStart = m.index + m[0].length;
    const listEnd = endOfList(html, listStart);
    if (listEnd < 0) continue;
    stats.tryits += 1;
    out.push(html.slice(cursor, m.index));
    out.push(`<aside class="tryit"><p class="tryit-label">Try it</p>`);
    out.push(html.slice(listStart, listEnd));
    out.push(`</aside>`);
    cursor = listEnd;
    label.lastIndex = listEnd;
  }
  out.push(html.slice(cursor));
  return out.join("");
}

// Guidebook chapter H1s become opener blocks on a fresh recto: oversized
// accent number, title, double rule, and the chapter's first paragraph
// pulled up as a standfirst (every chapter opens with a summary paragraph;
// if the element after the H1 is not a plain paragraph, the pull simply
// does not happen). Appendices get the simpler variant.
function buildOpeners(html, stats) {
  html = html.replace(
    /<h1 id="([^"]+)">Chapter (\d+): ([^<]+)<\/h1>(?:\s*<p>([\s\S]*?)<\/p>)?/g,
    (m, id, num, title, standfirst) => {
      stats.chapters += 1;
      return `<header class="chapter-opener" data-chapter="${num}">`
        + `<p class="chapter-kicker">Chapter</p>`
        + `<div class="chapter-number">${num}</div>`
        + `<h1 id="${id}">${title.trim()}</h1>`
        + `<div class="opener-rule"></div>`
        + (standfirst ? `<p class="standfirst">${standfirst.trim()}</p>` : "")
        + `</header>`;
    });
  // The companion closes with an afterword rather than appendices. It gets
  // opener furniture of its own so it reads as the end of the book instead of
  // an unnumbered last section of chapter 8: its own page, its own kicker,
  // and its own running head (.chapter-opener h1 sets the rhead string).
  html = html.replace(
    /<h1 id="([^"]+)">Afterword: ([^<]+)<\/h1>/g,
    (m, id, title) =>
      `<header class="chapter-opener appendix-opener afterword-opener">`
      + `<p class="chapter-kicker">Afterword</p>`
      + `<h1 id="${id}">${title.trim()}</h1>`
      + `<div class="opener-rule"></div>`
      + `</header>`);
  html = html.replace(
    /<h1 id="([^"]+)">Appendix ([A-D]): ([^<]+)<\/h1>/g,
    (m, id, letter, title) => {
      stats.appendices += 1;
      return `<header class="chapter-opener appendix-opener" data-appendix="${letter}">`
        + `<p class="chapter-kicker">Appendix</p>`
        + `<div class="chapter-number">${letter}</div>`
        + `<h1 id="${id}">${title.trim()}</h1>`
        + `<div class="opener-rule"></div>`
        + `</header>`;
    });
  return html;
}

// Book-title H1s (the guidebook front matter and the manual's single H1) get
// the designed title treatment instead of an opener page.
function buildTitleBlock(html, kicker) {
  return html.replace(/<h1 id="([^"]+)">([^<]+)<\/h1>/, (m, id, title) =>
    `<header class="fm-title"><p class="fm-kicker">${kicker}</p>`
    + `<h1 id="${id}">${title.trim()}</h1><div class="opener-rule"></div></header>`);
}

function coverHtml(title, edition = EDITION) {
  const keys = `<span></span>`.repeat(10);
  return `<section class="cover-page"><div class="cover-inner">`
    + `<div class="cover-motif"><div class="cover-lcd">FREE85</div>`
    + `<div class="cover-keys">${keys}</div></div>`
    + `<div class="cover-titleblock">`
    + `<p class="cover-kicker">Scientific graphing calculator</p>`
    + `<h1 class="cover-title">${title}</h1>`
    + `<div class="cover-rule"></div>`
    + `<p class="cover-edition">${edition}</p>`
    + `<p class="cover-url">${PROJECT_URL}</p>`
    + `</div></div></section>`;
}

function colophonHtml(title, { edition = EDITION, note = "" } = {}) {
  return `<section class="colophon"><div class="colophon-push"></div>`
    + `<p class="colophon-mark">FREE85</p><div class="colophon-rule"></div>`
    + `<p><strong>${title}</strong> · ${edition}</p>`
    + (note ? `<p>${note}</p>` : "")
    + `<p>Free85 is clean-room software: the firmware, the font, the screen`
    + ` artwork, the tests, and this book were written from scratch for the`
    + ` project. It contains no Texas Instruments ROM code, disassembly,`
    + ` fonts, artwork, or binary tables. The TI-85 is referenced only to`
    + ` describe the hardware profile the firmware runs on; the project is`
    + ` not affiliated with or endorsed by Texas Instruments.</p>`
    + `<p>Free85 is open source under the MIT License. See the LICENSE file`
    + ` for the licence text and NOTICE.md for the project notices.</p>`
    + `<p>Free85 2.10 · Typeset from the Markdown sources with pandoc and`
    + ` Paged.js, and rendered to PDF by headless Chromium. Set in Charter,`
    + ` Helvetica Neue, and Menlo.</p>`
    + `<p>https://${PROJECT_URL}/</p>`
    + `</section>`;
}

function tocHtml(entries) {
  let html = `<nav class="toc"><h1 class="toc-heading">Contents</h1><div class="toc-rule"></div>`;
  let group = null;
  for (const entry of entries) {
    if (entry.group && entry.group !== group) {
      group = entry.group;
      html += `<p class="toc-group">${group}</p>`;
    }
    const plain = entry.no ? "" : " toc-plain";
    // Front-matter targets sit on roman-folioed pages; their leader has to
    // resolve target-counter in the same numbering the folio prints.
    const roman = entry.roman ? " toc-roman" : "";
    html += `<a class="toc-entry${plain}${roman}" href="#${entry.id}">`
      + `<span class="toc-no">${entry.no ?? ""}</span>`
      + `<span class="toc-title">${entry.title}</span>`
      + `<span class="toc-dots"></span></a>`;
  }
  return `${html}</nav>`;
}

// ---------------------------------------------------------------- pandoc --

function pandocBody(inputs, resourcePath) {
  const html = execFileSync("pandoc", [
    ...inputs,
    "--standalone",
    "--embed-resources",
    "--wrap=none",
    `--resource-path=${resourcePath}`,
    "--metadata", "pagetitle=book",
    "-o", "-",
  ], { encoding: "utf8", maxBuffer: 512 * 1024 * 1024 });
  const start = html.indexOf(">", html.indexOf("<body")) + 1;
  const end = html.lastIndexOf("</body>");
  return html.slice(start, end);
}

// Recent Chrome broke the CSS counter scoping that Paged.js's own
// counter-reset handling relies on: a reset on one page stopped propagating
// to the pages after it, so folios ran 1, 4, 5, 6... after each restart.
// This handler makes the folio deterministic: it walks the laid-out pages in
// order, restarts the count at the front-matter and body groups, and pins
// every page's `page` counter with a per-page rule. Paged.js's TOC
// target-counter resolution reads these same computed values, so the TOC and
// the folios always agree.
const folioHandlerScript = `
class Free85Folios extends Paged.Handler {
  constructor(chunker, polisher, caller) {
    super(chunker, polisher, caller);
    this.styleSheet = polisher.styleSheet;
    this.mode = "pre";
    this.count = 0;
  }
  afterPageLayout(pageElement) {
    if (pageElement.querySelector("header.chapter-opener, header.fm-title")) {
      pageElement.classList.add("free85-opener-page");
    }
    const cl = pageElement.classList;
    if (cl.contains("pagedjs_cover_page")) { this.mode = "pre"; return; }
    if (cl.contains("pagedjs_colophon_page")) { this.mode = "post"; return; }
    if (cl.contains("pagedjs_frontmatter_page") && this.mode === "pre") {
      this.mode = "frontmatter"; this.count = 0;
    }
    if (cl.contains("pagedjs_body_page") && this.mode !== "body") {
      this.mode = "body"; this.count = 0;
    }
    if (this.mode !== "frontmatter" && this.mode !== "body") return;
    this.count += 1;
    this.styleSheet.insertRule(
      ".pagedjs_pages .pagedjs_page[data-page-number=\\"" + pageElement.dataset.pageNumber + "\\"]"
      + " { counter-increment: none; counter-reset: page " + this.count + "; }",
      this.styleSheet.cssRules.length);
  }
}
Paged.registerHandlers(Free85Folios);

// Re-insert the header row when a table is split across pages (Paged.js only
// completes the broken row, it never repeats the thead).
class Free85TableHeaders extends Paged.Handler {
  constructor(chunker, polisher, caller) {
    super(chunker, polisher, caller);
  }
  afterPageLayout(pageElement, page, breakToken, chunker) {
    for (const table of pageElement.querySelectorAll("table[data-split-from]")) {
      if (table.querySelector("thead")) continue;
      const source = chunker.source.querySelector('[data-ref="' + table.dataset.ref + '"]');
      const header = source && source.querySelector("thead");
      if (header) table.insertBefore(header.cloneNode(true), table.firstChild);
    }
  }
}
Paged.registerHandlers(Free85TableHeaders);
`;

function backCoverHtml() {
  return `<section class="back-cover"><div class="bc-inner">`
    + `<p class="bc-mark">FREE85</p><div class="bc-rule"></div>`
    + `<p class="bc-url">${PROJECT_URL}</p>`
    + `</div></section>`;
}

// lang is en-US (not en-GB) deliberately: Chromium's en-GB hyphenation falls
// back to algorithmic breaks that produce corrupt splits (catal-og); the
// en-US dictionary hyphenates correctly.
function assemble({ bodyClass, title, cover, frontMatter, bookBody, colophon }) {
  const webReaderStyle = webEdition ? `
@media screen {
  html { background: #0c100f; font-size: 16px; }
  body {
    width: min(920px, calc(100% - 24px));
    margin: 24px auto 72px;
    background: #f7f5ef;
    box-shadow: 0 24px 80px rgba(0, 0, 0, 0.45);
  }
  body.embedded-reader {
    width: 100%;
    margin: 0;
    box-shadow: none;
  }
  body.embedded-reader .web-reader-nav { display: none; }
  .web-reader-nav {
    position: sticky;
    top: 0;
    z-index: 10;
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
    border-bottom: 1px solid #c9c5ba;
    background: rgba(247, 245, 239, 0.96);
    padding: 12px clamp(18px, 5vw, 56px);
    font: 700 14px/1.2 var(--sans);
    backdrop-filter: blur(10px);
  }
  .web-reader-nav a {
    border: 1px solid #9aa5b5;
    border-radius: 5px;
    color: var(--accent);
    padding: 8px 10px;
  }
  .web-reader-nav a:first-child { margin-right: auto; }
  body > section:not(.cover-page):not(.back-cover) {
    padding: clamp(28px, 6vw, 68px);
  }
  section.cover-page, section.back-cover {
    width: 100%;
    height: min(209mm, calc(100vh - 48px));
    min-height: 620px;
  }
  section.colophon { min-height: 70vh; height: auto; }
  section.chapter { padding-block: 18px 42px; }
  p, li { font-size: 1rem; }
  table { display: block; overflow-x: auto; font-size: 0.9rem; }
  .toc-entry::after { content: none; }
  h2[data-secno]::before { display: none; }
}
@media screen and (max-width: 560px) {
  html { font-size: 14px; }
  body { width: 100%; margin: 0; }
  .web-reader-nav { padding: 9px 10px; }
  .web-reader-nav a { padding: 7px 8px; }
  section.cover-page, section.back-cover { min-height: 560px; }
}
` : "";
  const webReaderNav = webEdition
    ? `<nav class="web-reader-nav" aria-label="Book navigation">`
      + `<a href="../../index.html">← Free85 calculator</a>`
      + `<a href="./Free85-Manual-typeset.html">Manual</a>`
      + `<a href="./Free85-Guidebook-typeset.html">Guidebook</a>`
      + `<a href="./Free85-Companion-typeset.html">Explorations</a></nav>`
    : "";
  const paginationScripts = webEdition ? "" : `<script>
${pagedPolyfill}
</script>
<script>
${folioHandlerScript}
</script>`;
  const embedScript = webEdition ? `<script>
if (new URLSearchParams(window.location.search).has("embed")) {
  document.body.classList.add("embedded-reader");
}
</script>` : "";
  return `<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title}</title>
<link rel="icon" href="data:,">
<style>
${stylesheet}
${webReaderStyle}
</style>
</head>
<body class="${bodyClass}">
${webReaderNav}
${cover}
<section class="front-matter">
${frontMatter}
</section>
<section class="book-body">
${bookBody}
</section>
${colophon}
${backCoverHtml()}
${paginationScripts}
${embedScript}
</body>
</html>
`;
}

// --------------------------------------------------------------- render --

function pdfPageCount(path) {
  const pdf = readFileSync(path, "latin1");
  let max = 0;
  for (const m of pdf.matchAll(/\/Count (\d+)/g)) {
    max = Math.max(max, Number(m[1]));
  }
  return max;
}

function render(name, html, { minPages, maxPages }) {
  const htmlPath = `${outDir}${name}.html`;
  const pdfPath = `${outDir}${name}.pdf`;
  writeFileSync(htmlPath, html);

  if (webEdition) {
    console.log(`wrote public/guidebook/${name}.html`);
    return;
  }

  // Paged.js runs under Chrome's virtual clock, so a large budget costs
  // nothing once pagination finishes early — it only bounds the worst case.
  const chromeArgs = [
    "--headless",
    "--disable-gpu",
    "--no-pdf-header-footer",
    "--virtual-time-budget=120000",
  ];
  execFileSync(chrome, [...chromeArgs, `--print-to-pdf=${pdfPath}`, `file://${htmlPath}`]);

  // Verify Paged.js actually finished before Chrome printed: re-render the
  // DOM under the same budget and compare its page count with the PDF's.
  // A truncated or unpaginated print (raw HTML flowed straight to PDF) is
  // the classic failure mode and shows up immediately here.
  const dom = execFileSync(chrome, [...chromeArgs, "--dump-dom", `file://${htmlPath}`],
    { encoding: "utf8", maxBuffer: 1024 * 1024 * 1024 });
  const domPages = (dom.match(/class="pagedjs_page /g) ?? []).length;
  const pdfPages = pdfPageCount(pdfPath);
  if (domPages === 0) {
    throw new Error(`${name}: Paged.js produced no pages (polyfill did not run)`);
  }
  if (pdfPages !== domPages) {
    throw new Error(`${name}: PDF has ${pdfPages} pages but Paged.js paginated ${domPages} — truncated render`);
  }
  const firstPage = dom.slice(dom.indexOf('class="pagedjs_page '), dom.indexOf('class="pagedjs_page ', dom.indexOf('class="pagedjs_page ') + 1));
  if (!firstPage.includes("cover-lcd")) {
    throw new Error(`${name}: page 1 is not the cover — unpaginated render`);
  }
  if (pdfPages < minPages || pdfPages > maxPages) {
    throw new Error(`${name}: ${pdfPages} pages is outside the sane range ${minPages}-${maxPages}`);
  }
  console.log(`wrote dist/guidebook/${name}.pdf (${pdfPages} pages)`);
}

function checkPrintHygiene(name, html) {
  if (/⚠|🔌/.test(html)) throw new Error(`${name}: emoji leaked into the print HTML`);
  if (/href="[^"#]*\.md/.test(html)) throw new Error(`${name}: unresolved .md link in print HTML`);
}

// ------------------------------------------------------------- guidebook --

function buildGuidebook() {
  const stats = { keycaps: 0, callouts: 0, figures: 0, diagrams: 0, chapters: 0, appendices: 0 };
  const chapterFiles = readdirSync(`${root}docs/guidebook/`)
    .filter((f) => /^\d\d-.*\.md$/.test(f)).sort()
    .map((f) => `${root}docs/guidebook/${f}`);
  const appendixFiles = ["a-command-catalog", "b-keymap", "c-errors", "d-feature-status"]
    .map((s) => `${root}docs/guidebook/appendix-${s}.md`);

  let html = pandocBody([...chapterFiles, ...appendixFiles], `${root}docs/guidebook`);
  html = markCallouts(html, stats);
  html = markKeycaps(html, stats);
  html = frameScreenshots(html, stats);
  html = markKeymapTable(html);
  html = markNumHeavyBlocks(html);
  html = buildOpeners(html, stats);
  html = buildTitleBlock(html, "Free85 · Complete reference");

  // The front matter's hand-written Contents section (links to the source
  // .md files) is replaced by the generated TOC with real page numbers.
  html = html.replace(/<h2 id="contents">[\s\S]*?(?=<header class="chapter-opener")/, "");

  // Split at the first chapter opener: everything before it is front matter.
  const bodyStart = html.indexOf('<header class="chapter-opener"');
  if (bodyStart < 0) throw new Error("guidebook: no chapter opener found");
  let frontMatter = html.slice(0, bodyStart);
  let bookBody = html.slice(bodyStart);

  // Wrap each chapter/appendix in a section (appendix A's catalog headings
  // get compact styling via its class).
  const chunks = bookBody.split(/(?=<header class="chapter-opener)/);
  bookBody = chunks.map((chunk) => {
    const appendix = chunk.match(/^<header class="chapter-opener appendix-opener" data-appendix="([A-D])"/);
    const chapter = chunk.match(/^<header class="chapter-opener" data-chapter="(\d+)"/);
    // Hung section numbers ("4-3" ladder) on every section heading.
    const label = appendix ? appendix[1] : chapter ? chapter[1] : null;
    if (label) {
      let sec = 0;
      chunk = chunk.replace(/<h2 /g, () => `<h2 data-secno="${label}-${++sec}" `);
    }
    const cls = appendix ? `chapter appendix appendix-${appendix[1].toLowerCase()}` : "chapter";
    return `<section class="${cls}">${chunk}</section>`;
  }).join("");

  const entries = [];
  for (const m of bookBody.matchAll(/<header class="chapter-opener(?: appendix-opener)?" data-(chapter|appendix)="([^"]+)">[\s\S]*?<h1 id="([^"]+)">([^<]+)<\/h1>/g)) {
    entries.push({
      group: m[1] === "chapter" ? "Chapters" : "Appendices",
      no: m[2],
      id: m[3],
      title: m[4],
    });
  }
  if (entries.length !== 23) {
    throw new Error(`guidebook: expected 23 TOC entries (19 chapters + 4 appendices), found ${entries.length}`);
  }
  frontMatter += tocHtml(entries);

  const title = "The Free85 Guidebook";
  const doc = assemble({
    bodyClass: "guidebook",
    title: `${title} (typeset)`,
    cover: coverHtml(title),
    frontMatter,
    bookBody,
    colophon: colophonHtml(title),
  });
  checkPrintHygiene("Free85-Guidebook-typeset", doc);
  console.log(`guidebook: ${stats.keycaps} keycaps, ${stats.callouts} callouts, `
    + `${stats.figures} framed screenshots, ${stats.chapters} chapters, ${stats.appendices} appendices`);
  render("Free85-Guidebook-typeset", doc, { minPages: 120, maxPages: 320 });
}

// ---------------------------------------------------------------- manual --

function buildManual() {
  const stats = { keycaps: 0, callouts: 0, figures: 0, diagrams: 0, chapters: 0, appendices: 0 };
  let html = pandocBody(
    [`${root}docs/manual/Free85-Manual.md`],
    `${root}docs/manual:${root}docs/guidebook`);
  html = markCallouts(html, stats);
  html = markKeycaps(html, stats);
  html = frameScreenshots(html, stats);
  html = markNumHeavyBlocks(html);
  html = buildTitleBlock(html, "Free85 · Getting started");

  // The manual's sections are H2-level: no chapter openers, but they drive
  // the TOC and the recto running head.
  const entries = [];
  for (const m of html.matchAll(/<h2 id="([^"]+)">([^<]+)<\/h2>/g)) {
    entries.push({ id: m[1], title: m[2].trim() });
  }
  if (entries.length < 5) {
    throw new Error(`manual: expected the manual's H2 sections for the TOC, found ${entries.length}`);
  }

  const title = "Free85 Getting Started Manual";
  const doc = assemble({
    bodyClass: "manual",
    title: `${title} (typeset)`,
    cover: coverHtml(title),
    frontMatter: tocHtml(entries),
    bookBody: html,
    colophon: colophonHtml(title),
  });
  checkPrintHygiene("Free85-Manual-typeset", doc);
  console.log(`manual: ${stats.keycaps} keycaps, ${stats.callouts} callouts, `
    + `${stats.figures} framed screenshots, ${entries.length} TOC sections`);
  render("Free85-Manual-typeset", doc, { minPages: 10, maxPages: 48 });
}

// ------------------------------------------------------------- companion --

// Explorations with Free85: eight chapters, no appendices and no generated
// content. Structurally it is the Guidebook's chapter machinery (openers,
// standfirsts, framed screenshots, keycaps) plus two things of its own — the
// numbered section headings and the Try it exercise panels.
function buildCompanion() {
  const stats = { keycaps: 0, callouts: 0, figures: 0, diagrams: 0, chapters: 0, appendices: 0, sections: 0, tryits: 0, solutions: 0 };
  const sources = readdirSync(`${root}docs/companion/`)
    .filter((f) => /^\d\d-.*\.md$/.test(f)).sort()
    .map((f) => `${root}docs/companion/${f}`);
  if (sources.length !== 11) {
    throw new Error("companion: expected front matter + 8 chapters + solutions "
      + `+ afterword, found ${sources.length} sources`);
  }

  let html = pandocBody(sources, `${root}docs/companion`);
  html = markCallouts(html, stats);        // none in this book; harmless
  html = markKeycaps(html, stats);
  html = frameScreenshots(html, stats);
  html = markKeymapTable(html);
  html = markNumHeavyBlocks(html);
  html = markTryIt(html, stats);
  html = hangSectionNumbers(html, stats);
  html = buildOpeners(html, stats);
  html = buildTitleBlock(html, "Free85 · Explorations");

  // The front matter's hand-written Contents (links to the source .md files)
  // is replaced by the generated TOC with real page numbers.
  html = html.replace(/<h2 id="contents">[\s\S]*?(?=<header class="chapter-opener")/, "");

  const bodyStart = html.indexOf('<header class="chapter-opener"');
  if (bodyStart < 0) throw new Error("companion: no chapter opener found");
  let frontMatter = html.slice(0, bodyStart);
  let bookBody = html.slice(bodyStart);

  bookBody = bookBody.split(/(?=<header class="chapter-opener)/)
    .map((chunk) => `<section class="chapter">${chunk}</section>`).join("");

  const entries = [];
  for (const m of frontMatter.matchAll(/<h2 id="([^"]+)">([^<]+)<\/h2>/g)) {
    entries.push({ group: "Front matter", roman: true, id: m[1], title: m[2].trim() });
  }
  const chapters = [];
  for (const m of bookBody.matchAll(/<header class="chapter-opener" data-chapter="(\d+)">[\s\S]*?<h1 id="([^"]+)">([^<]+)<\/h1>/g)) {
    chapters.push({ group: "Chapters", no: m[1], id: m[2], title: m[3] });
  }
  if (chapters.length !== 9) {
    throw new Error(`companion: expected 9 chapter TOC entries, found ${chapters.length}`);
  }
  const afterword = bookBody.match(
    /<header class="chapter-opener appendix-opener afterword-opener">.*?<h1 id="([^"]+)">([^<]+)<\/h1>/);
  if (!afterword) throw new Error("companion: no afterword opener found");
  chapters.push({ group: "Afterword", id: afterword[1], title: afterword[2] });
  if (stats.tryits < 40) {
    throw new Error(`companion: expected a Try it panel per section, found ${stats.tryits}`);
  }
  // Every numbered section ends with exactly one Try it panel, so the two
  // counts must agree. They diverge when a "## N.N Title" heading loses the
  // blank line above it: pandoc then reads the heading as ordinary paragraph
  // text, the section silently disappears from the book and the TOC, and
  // nothing else in the build notices. That has happened once.
  // Chapter 9 is the solutions and carries no Try it panels of its own, so
  // it is counted separately and excluded from the comparison.
  if (stats.sections !== stats.tryits) {
    throw new Error(`companion: ${stats.sections} numbered sections in chapters `
      + `1 to 8 but ${stats.tryits} Try it panels. A section heading has `
      + `probably lost the blank line above it and been swallowed into the `
      + `previous paragraph.`);
  }
  // Chapter 9 answers every Try it panel, one solution section per chapter.
  if (stats.solutions !== 8) {
    throw new Error("companion: expected 8 solution sections, one per "
      + `chapter, found ${stats.solutions}`);
  }
  frontMatter += tocHtml([...entries, ...chapters]);

  const title = "Explorations with Free85";
  const doc = assemble({
    bodyClass: "companion",
    title: `${title} (typeset)`,
    cover: coverHtml(title, COMPANION_EDITION),
    frontMatter,
    bookBody,
    colophon: colophonHtml(title, {
      edition: COMPANION_EDITION,
      // Typographic apostrophe: the body text is set with pandoc's smart
      // quotes, and the colophon sits on the same page furniture.
      note: "Explorations with Free85 is the third of the project’s books, after"
        + " the Getting Started Manual and the Guidebook, and the first to be"
        + " written as a workbook. Its explorations, worked examples, data sets,"
        + " and exercises were invented for this machine; every key sequence and"
        + " every quoted number in it was run on the emulator.",
    }),
  });
  checkPrintHygiene("Free85-Companion-typeset", doc);
  console.log(`companion: ${stats.keycaps} keycaps, ${stats.figures} framed screenshots, `
    + `${stats.diagrams} maths diagram${stats.diagrams === 1 ? "" : "s"}, `
    + `${stats.chapters} chapters, ${stats.sections} numbered sections, `
    + `${stats.tryits} Try it panels, ${stats.solutions} solution sections`);
  render("Free85-Companion-typeset", doc, { minPages: 90, maxPages: 340 });
}

buildManual();
buildGuidebook();
buildCompanion();
