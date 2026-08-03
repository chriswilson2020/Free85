// Builds the professionally typeset (DTP) edition of the Free85 Getting
// Started Manual and the Free85 Guidebook.
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
const outDir = `${root}dist/guidebook/`;
mkdirSync(outDir, { recursive: true });
const chrome = process.env.CHROME_BIN
  ?? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";

const stylesheet = readFileSync(`${root}docs/guidebook/typeset.css`, "utf8");
const pagedPolyfill = readFileSync(`${root}scripts/vendor/paged.polyfill.js`, "utf8");
if (pagedPolyfill.includes("</script")) {
  throw new Error("paged.polyfill.js contains '</script' and cannot be inlined");
}

const EDITION = "For firmware 2.10 · Second Edition";
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

// Every screenshot figure gets a calculator-bezel frame; pandoc's implicit
// figcaption (the Markdown alt text) becomes the caption below the frame.
function frameScreenshots(html, stats) {
  return html.replace(
    /<figure>\s*(<img[^>]*>)\s*<figcaption[^>]*>([\s\S]*?)<\/figcaption>\s*<\/figure>/g,
    (m, img, caption) => {
      stats.figures += 1;
      return `<figure class="lcd"><div class="lcd-frame"><div class="lcd-glass">${img}</div></div>`
        + `<figcaption>${caption.trim()}</figcaption></figure>`;
    });
}

// Appendix B's four-column key map is the only table that cannot fit A5 at
// the standard size; tag it so the stylesheet can shrink it. Any other table
// longer than 12 rows is tagged table-long so it may break across pages
// (unbreakable near-full-page tables strand headings on empty pages).
function markKeymapTable(html) {
  return html.replace(/<table>([\s\S]*?)<\/table>/g, (m, inner) => {
    const headerRow = inner.slice(0, inner.indexOf("</tr>"));
    if (headerRow.includes("<th>Key</th>") && headerRow.includes("<th>ALPHA</th>")) {
      return `<table class="keymap">${inner}</table>`;
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

function coverHtml(title) {
  const keys = `<span></span>`.repeat(10);
  return `<section class="cover-page"><div class="cover-inner">`
    + `<div class="cover-motif"><div class="cover-lcd">FREE85</div>`
    + `<div class="cover-keys">${keys}</div></div>`
    + `<div class="cover-titleblock">`
    + `<p class="cover-kicker">Scientific graphing calculator</p>`
    + `<h1 class="cover-title">${title}</h1>`
    + `<div class="cover-rule"></div>`
    + `<p class="cover-edition">${EDITION}</p>`
    + `<p class="cover-url">${PROJECT_URL}</p>`
    + `</div></div></section>`;
}

function colophonHtml(title) {
  return `<section class="colophon"><div class="colophon-push"></div>`
    + `<p class="colophon-mark">FREE85</p><div class="colophon-rule"></div>`
    + `<p><strong>${title}</strong> · ${EDITION}</p>`
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
    html += `<a class="toc-entry${plain}" href="#${entry.id}">`
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
  return `<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="utf-8">
<title>${title}</title>
<style>
${stylesheet}
</style>
</head>
<body class="${bodyClass}">
${cover}
<section class="front-matter">
${frontMatter}
</section>
<section class="book-body">
${bookBody}
</section>
${colophon}
${backCoverHtml()}
<script>
${pagedPolyfill}
</script>
<script>
${folioHandlerScript}
</script>
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
  const stats = { keycaps: 0, callouts: 0, figures: 0, chapters: 0, appendices: 0 };
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
  const stats = { keycaps: 0, callouts: 0, figures: 0, chapters: 0, appendices: 0 };
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

buildManual();
buildGuidebook();
