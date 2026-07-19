import { cpSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const output = resolve(root, "dist");

rmSync(output, { recursive: true, force: true });
mkdirSync(output, { recursive: true });

for (const path of ["index.html", "public", "src", "ROM/FREE85.ROM"]) {
  cpSync(resolve(root, path), resolve(output, path), { recursive: true });
}

// Pages artifacts are served as static files; this also documents that intent.
writeFileSync(resolve(output, ".nojekyll"), "");

console.log("GitHub Pages artifact created in dist/");
