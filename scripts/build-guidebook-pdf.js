// Builds print-ready PDFs of the Free85 Getting Started Manual and the
// Free85 Guidebook. Pandoc renders each Markdown source into a single
// standalone HTML file (images embedded as data: URIs so nothing needs to
// be re-resolved later), then headless Chrome prints that HTML to PDF.
//
// Run via `npm run build:guidebook`, after the screenshot and appendix
// generators (see package.json).
import { execFileSync } from "node:child_process";
import { mkdirSync, readdirSync, readFileSync, statSync } from "node:fs";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
const outDir = `${root}dist/guidebook/`;
mkdirSync(outDir, { recursive: true });
const chrome = process.env.CHROME_BIN
  ?? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";

function buildPdf(name, inputs, resourcePath) {
  const html = `${outDir}${name}.html`;
  execFileSync("pandoc", [
    ...inputs,
    "--standalone",
    "--css", `${root}docs/guidebook/print.css`,
    "--embed-resources",
    `--resource-path=${resourcePath}`,
    // "pagetitle" only sets the HTML <title> element. The "title" metadata
    // field would additionally make pandoc's default template render a
    // visible title-block <h1> at the top of <body>, duplicating the
    // document's own first heading — so it is deliberately avoided here.
    "--metadata", `pagetitle=${name.replace(/-/g, " ")}`,
    "-o", html,
  ]);

  const htmlSize = statSync(html).size;
  const dataUriCount = (readFileSync(html, "utf8").match(/src="data:image/g) ?? []).length;
  if (dataUriCount === 0) {
    throw new Error(`${name}: no embedded images found in ${html} (expected images to be embedded)`);
  }
  console.log(`  ${name}.html: ${(htmlSize / 1024 / 1024).toFixed(2)} MiB, ${dataUriCount} embedded images`);

  execFileSync(chrome, [
    "--headless",
    "--disable-gpu",
    "--no-pdf-header-footer",
    "--virtual-time-budget=20000",
    `--print-to-pdf=${outDir}${name}.pdf`,
    `file://${html}`,
  ]);
  console.log(`wrote dist/guidebook/${name}.pdf`);
}

const chapters = readdirSync(`${root}docs/guidebook/`)
  .filter((f) => /^\d\d-.*\.md$/.test(f)).sort()
  .map((f) => `${root}docs/guidebook/${f}`);
const appendices = ["a-command-catalog", "b-keymap", "c-errors", "d-feature-status"]
  .map((s) => `${root}docs/guidebook/appendix-${s}.md`);

buildPdf(
  "Free85-Manual",
  [`${root}docs/manual/Free85-Manual.md`],
  `${root}docs/manual:${root}docs/guidebook`
);
buildPdf(
  "Free85-Guidebook",
  [...chapters, ...appendices],
  `${root}docs/guidebook`
);
