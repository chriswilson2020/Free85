import { spawnSync } from "node:child_process";
import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const firmwareRoot = resolve(root, "firmware/free85");
const generatedRoot = resolve(firmwareRoot, "generated");
const romPath = resolve(root, "ROM/FREE85.ROM");
const pageSize = 0x4000;
const pageCount = 8;
const assembler = process.env.SJASMPLUS || "sjasmplus";

function runAssembler(args) {
  const result = spawnSync(assembler, args, {
    cwd: root,
    encoding: "utf8",
    env: process.env
  });
  if (result.error?.code === "ENOENT") {
    throw new Error("sjasmplus was not found; install it or set SJASMPLUS=/path/to/sjasmplus");
  }
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error([result.stdout, result.stderr].filter(Boolean).join("\n").trim());
  }
  return [result.stdout, result.stderr].filter(Boolean).join("\n").trim();
}

runAssembler(["--version"]);
await rm(generatedRoot, { recursive: true, force: true });
await mkdir(generatedRoot, { recursive: true });
await mkdir(dirname(romPath), { recursive: true });

const pages = [];
const usage = [];
const mapSections = [];
for (let page = 0; page < pageCount; page += 1) {
  const name = `page${page}`;
  const rawPath = resolve(generatedRoot, `${name}.bin`);
  const symbolPath = resolve(generatedRoot, `${name}.sym`);
  const listingPath = resolve(generatedRoot, `${name}.lst`);
  const source = page === 0
    ? resolve(firmwareRoot, "banks/page0.asm")
    : page === 1
      ? resolve(firmwareRoot, "banks/page1.asm")
      : page === 2
        ? resolve(firmwareRoot, "banks/page2.asm")
      : page === 3
        ? resolve(firmwareRoot, "banks/page3.asm")
      : page === 4
        ? resolve(firmwareRoot, "banks/page4.asm")
      : page === 5
        ? resolve(firmwareRoot, "banks/page5.asm")
      : page === 6
        ? resolve(firmwareRoot, "banks/page6.asm")
      : resolve(firmwareRoot, "banks/empty.asm");
  const args = [
    "--nologo",
    "--msg=err",
    `--inc=${firmwareRoot}`,
    `--raw=${rawPath}`,
    `--sym=${symbolPath}`,
    `--lst=${listingPath}`
  ];
  if (page !== 0) args.push(`-DBANK_ID=${page}`);
  args.push(source);
  runAssembler(args);

  const assembled = await readFile(rawPath);
  if (assembled.length > pageSize) {
    throw new Error(`${name} exceeds 16 KiB: ${assembled.length} bytes`);
  }
  const padded = Buffer.alloc(pageSize, 0xff);
  assembled.copy(padded);
  pages.push(padded);
  usage.push({
    page,
    used_bytes: assembled.length,
    free_bytes: pageSize - assembled.length,
    percent_used: Number(((assembled.length / pageSize) * 100).toFixed(2))
  });
  const symbols = await readFile(symbolPath, "utf8");
  mapSections.push(`PAGE ${page}\n${symbols.trim()}\n`);
}

const rom = Buffer.concat(pages);
if (rom.length !== pageSize * pageCount) {
  throw new Error(`Free85 ROM must be exactly 131072 bytes, got ${rom.length}`);
}
await writeFile(romPath, rom);
await writeFile(resolve(generatedRoot, "free85.map"), `${mapSections.join("\n")}\n`);
await writeFile(resolve(generatedRoot, "usage.json"), `${JSON.stringify({
  phase: 12,
  rom_bytes: rom.length,
  page_size: pageSize,
  pages: usage,
  ram: {
    system_state_bytes: 7536,
    stack_reserved_bytes: 256,
    framebuffer_bytes: 1024,
    phase12_reserved_bytes: 8816,
    free_bytes: 0x8000 - 8816
  }
}, null, 2)}\n`);

for (const page of usage) {
  console.log(`Bank ${page.page}: ${page.used_bytes} used, ${page.free_bytes} free (${page.percent_used}%)`);
}
console.log(`Wrote ${rom.length} bytes to ${romPath}`);
