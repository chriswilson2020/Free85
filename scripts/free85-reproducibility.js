import { createHash } from "node:crypto";
import { spawnSync } from "node:child_process";
import { cp, mkdir, mkdtemp, readFile, readdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, dirname, join, relative, resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const assembler = process.env.SJASMPLUS ? resolve(process.env.SJASMPLUS) : "sjasmplus";
const reportPath = resolve(root, "spec/free85/reproducibility.json");
const releaseInputs = ["package.json", "index.html", "firmware/free85", "scripts/build-free85.js", "scripts/build-pages.js", "public", "src"];

function run(command, args, cwd, env = process.env) {
  const result = spawnSync(command, args, { cwd, env, encoding: "utf8" });
  if (result.error?.code === "ENOENT") {
    throw new Error("sjasmplus was not found; set SJASMPLUS=/absolute/path/to/sjasmplus");
  }
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error([result.stdout, result.stderr].filter(Boolean).join("\n").trim());
  return [result.stdout, result.stderr].filter(Boolean).join("\n").trim();
}

async function filesBelow(path) {
  const entries = [];
  async function visit(current) {
    for (const item of await readdir(current, { withFileTypes: true })) {
      const absolute = join(current, item.name);
      if (item.isDirectory()) await visit(absolute);
      else if (item.isFile()) entries.push(absolute);
    }
  }
  await visit(path);
  return entries.sort();
}

async function hashFile(path) {
  return createHash("sha256").update(await readFile(path)).digest("hex");
}

async function hashTree(path) {
  const files = await filesBelow(path);
  const hash = createHash("sha256");
  for (const file of files) {
    hash.update(relative(path, file).replaceAll("\\", "/"));
    hash.update("\0");
    hash.update(await readFile(file));
    hash.update("\0");
  }
  return { files: files.length, sha256: hash.digest("hex") };
}

async function copyInputs(destination) {
  for (const input of releaseInputs) {
    const target = resolve(destination, input);
    await mkdir(dirname(target), { recursive: true });
    await cp(resolve(root, input), target, {
      recursive: true,
      filter: (source) => !source.includes("/firmware/free85/generated/")
    });
  }
}

async function cleanBuild(parent, name) {
  const checkout = resolve(parent, name);
  await copyInputs(checkout);
  const env = { ...process.env, SJASMPLUS: assembler };
  run(process.execPath, ["scripts/build-free85.js"], checkout, env);
  run(process.execPath, ["scripts/build-pages.js"], checkout, env);
  return {
    rom: await hashFile(resolve(checkout, "ROM/FREE85.ROM")),
    pages: await hashTree(resolve(checkout, "dist"))
  };
}

const versionOutput = run(assembler, ["--version"], root);
const temporaryRoot = await mkdtemp(join(tmpdir(), "free85-reproducibility-"));
try {
  const [first, second] = await Promise.all([
    cleanBuild(temporaryRoot, "build-a"),
    cleanBuild(temporaryRoot, "build-b")
  ]);
  const checkedRom = await hashFile(resolve(root, "ROM/FREE85.ROM"));
  if (first.rom !== second.rom || first.rom !== checkedRom) {
    throw new Error(`ROM build is not reproducible: checked=${checkedRom}, build-a=${first.rom}, build-b=${second.rom}`);
  }
  if (first.pages.sha256 !== second.pages.sha256 || first.pages.files !== second.pages.files) {
    throw new Error("GitHub Pages artifact is not reproducible across independent builds");
  }

  const report = {
    schema_version: 1,
    release: "2.16.0",
    phase: "15.3",
    independent_builds: 2,
    build_tool: {
      required: "sjasmplus >= 1.21.1",
      observed: versionOutput
    },
    rom: { path: "ROM/FREE85.ROM", bytes: 131072, sha256: checkedRom },
    pages: first.pages,
    inputs: releaseInputs
  };
  const output = `${JSON.stringify(report, null, 2)}\n`;
  if (process.argv.includes("--write")) {
    await writeFile(reportPath, output);
  } else if (process.argv.includes("--check")) {
    const checkedIn = JSON.parse(await readFile(reportPath, "utf8"));
    // The observed tool string documents the local verifier but is allowed to
    // differ when another supported sjasmplus release emits identical bytes.
    checkedIn.build_tool.observed = report.build_tool.observed;
    if (`${JSON.stringify(checkedIn, null, 2)}\n` !== output) {
      throw new Error(`${basename(reportPath)} is stale; run npm run update:free85:reproducibility`);
    }
  }
  console.log(output.trimEnd());
} finally {
  await rm(temporaryRoot, { recursive: true, force: true });
}
