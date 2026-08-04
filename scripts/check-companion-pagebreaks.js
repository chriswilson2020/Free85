// Reports pages whose text stops well short of the foot.
//
// A framed capture cannot break across a page and its one-line lead-in is
// glued to it, so a figure that will not fit pushes both to the next page
// and strands white space behind it. The typeset build cannot see this: the
// PDF is valid either way. Only a measurement catches it, and this is that
// measurement.
//
//   node scripts/check-companion-pagebreaks.js [book] [threshold-pt]
//
// book defaults to Companion, threshold to 100pt (about six lines of text).
import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync, mkdtempSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const book = process.argv[2] ?? "Companion";
const threshold = Number(process.argv[3] ?? 100);
const chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const source = `dist/guidebook/Free85-${book}-typeset.html`;

const MEASURE = `
<script>
(function () {
  function measure() {
    var pages = document.querySelectorAll(".pagedjs_page");
    if (!pages.length) return setTimeout(measure, 250);
    var out = [];
    pages.forEach(function (page, index) {
      var area = page.querySelector(".pagedjs_page_content");
      if (!area) return;
      var box = area.getBoundingClientRect();
      var lowest = box.top;
      var CONTENT = "p,li,figure,figcaption,h1,h2,h3,h4,table,tr,aside,blockquote,pre,img,hr";
      area.querySelectorAll(CONTENT).forEach(function (node) {
        if (!node.getClientRects().length) return;
        var r = node.getBoundingClientRect();
        if (r.bottom > lowest && r.bottom <= box.bottom + 1) lowest = r.bottom;
      });
      var folio = page.querySelector(".pagedjs_margin-bottom-center .pagedjs_margin-content");
      out.push([index + 1, folio ? folio.textContent.trim() : "",
        Math.round((box.bottom - lowest) * 0.75)]);
    });
    var pre = document.createElement("pre");
    pre.id = "pagebreak-report";
    pre.textContent = JSON.stringify(out);
    document.body.appendChild(pre);
  }
  measure();
})();
</script>`;

const dir = mkdtempSync(join(tmpdir(), "free85-pb-"));
const probe = join(dir, "probe.html");
writeFileSync(probe, readFileSync(source, "utf8").replace("</body>", `${MEASURE}</body>`));

const dom = execFileSync(chrome, ["--headless", "--disable-gpu", "--no-sandbox",
  "--virtual-time-budget=180000", "--dump-dom", `file://${probe}`],
  { encoding: "utf8", maxBuffer: 1024 * 1024 * 1024 });

const found = dom.match(/<pre id="pagebreak-report">([^<]*)<\/pre>/);
if (!found) {
  console.error(`${book}: measurement did not run. Build the typeset HTML first.`);
  process.exit(1);
}
const pages = JSON.parse(found[1].replace(/&quot;/g, '"').replace(/&amp;/g, "&"));
const short = pages.filter((p) => p[2] >= threshold);
console.log(`${book}: ${pages.length} pages measured, `
  + `${short.length} ending ${threshold}pt or more short`);
for (const [index, folio, gap] of short) {
  console.log(`  page ${String(index).padStart(3)}  folio ${folio.padEnd(5)}  ${gap}pt short`);
}
