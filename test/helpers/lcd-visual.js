import assert from "node:assert/strict";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { deflateSync } from "node:zlib";

const LCD_WIDTH = 128;
const LCD_HEIGHT = 64;
const LCD_BYTES_PER_ROW = LCD_WIDTH / 8;
const GOLDEN_DIR = fileURLToPath(new URL("../free85/goldens/graphs/", import.meta.url));
const ARTIFACT_DIR = join(process.cwd(), "test-results", "free85-visual");
const PNG_SIGNATURE = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
const LCD_OFF = [177, 207, 181];
const LCD_ON = [45, 62, 55];
const DIFF_MISSING = [37, 99, 235];
const DIFF_UNEXPECTED = [220, 38, 38];

function crc32(buffer) {
  let crc = 0xffffffff;
  for (const byte of buffer) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit += 1) {
      crc = (crc >>> 1) ^ ((crc & 1) ? 0xedb88320 : 0);
    }
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function pngChunk(type, data = Buffer.alloc(0)) {
  const name = Buffer.from(type, "ascii");
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  const checksum = Buffer.alloc(4);
  checksum.writeUInt32BE(crc32(Buffer.concat([name, data])));
  return Buffer.concat([length, name, data, checksum]);
}

function encodePng(width, height, rgb) {
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width, 0);
  header.writeUInt32BE(height, 4);
  header[8] = 8;
  header[9] = 2;
  const stride = width * 3;
  const scanlines = Buffer.alloc((stride + 1) * height);
  for (let y = 0; y < height; y += 1) {
    rgb.copy(scanlines, (y * (stride + 1)) + 1, y * stride, (y + 1) * stride);
  }
  return Buffer.concat([
    PNG_SIGNATURE,
    pngChunk("IHDR", header),
    pngChunk("IDAT", deflateSync(scanlines, { level: 9 })),
    pngChunk("IEND")
  ]);
}

export function packLcdPixels({ width, height, pixels }) {
  assert.equal(width, LCD_WIDTH);
  assert.equal(height, LCD_HEIGHT);
  const packed = Buffer.alloc(LCD_BYTES_PER_ROW * LCD_HEIGHT);
  for (let y = 0; y < LCD_HEIGHT; y += 1) {
    for (let x = 0; x < LCD_WIDTH; x += 1) {
      if (pixels[(y * LCD_WIDTH) + x]) packed[(y * LCD_BYTES_PER_ROW) + (x >> 3)] |= 0x80 >> (x & 7);
    }
  }
  return packed;
}

export function unpackLcdPixels(packed) {
  assert.equal(packed.length, LCD_BYTES_PER_ROW * LCD_HEIGHT);
  const pixels = new Uint8Array(LCD_WIDTH * LCD_HEIGHT);
  for (let y = 0; y < LCD_HEIGHT; y += 1) {
    for (let x = 0; x < LCD_WIDTH; x += 1) {
      pixels[(y * LCD_WIDTH) + x] = (packed[(y * LCD_BYTES_PER_ROW) + (x >> 3)] >> (7 - (x & 7))) & 1;
    }
  }
  return { width: LCD_WIDTH, height: LCD_HEIGHT, pixels };
}

function renderPixels(bitmap, scale = 4, comparePixels) {
  const width = bitmap.width * scale;
  const height = bitmap.height * scale;
  const rgb = Buffer.alloc(width * height * 3);
  for (let y = 0; y < bitmap.height; y += 1) {
    for (let x = 0; x < bitmap.width; x += 1) {
      const offset = (y * bitmap.width) + x;
      let color = bitmap.pixels[offset] ? LCD_ON : LCD_OFF;
      if (comparePixels && bitmap.pixels[offset] !== comparePixels[offset]) {
        color = bitmap.pixels[offset] ? DIFF_UNEXPECTED : DIFF_MISSING;
      }
      for (let sy = 0; sy < scale; sy += 1) {
        for (let sx = 0; sx < scale; sx += 1) {
          const target = ((((y * scale) + sy) * width) + (x * scale) + sx) * 3;
          rgb[target] = color[0];
          rgb[target + 1] = color[1];
          rgb[target + 2] = color[2];
        }
      }
    }
  }
  return encodePng(width, height, rgb);
}

export function writeLcdGolden(name, bitmap) {
  assert.match(name, /^[a-z0-9-]+$/);
  mkdirSync(GOLDEN_DIR, { recursive: true });
  const packed = packLcdPixels(bitmap);
  writeFileSync(join(GOLDEN_DIR, `${name}.lcd`), packed);
  writeFileSync(join(GOLDEN_DIR, `${name}.png`), renderPixels(bitmap));
}

export function assertLcdGolden(name, bitmap) {
  assert.match(name, /^[a-z0-9-]+$/);
  const rawPath = join(GOLDEN_DIR, `${name}.lcd`);
  const pngPath = join(GOLDEN_DIR, `${name}.png`);
  const actualRaw = packLcdPixels(bitmap);
  let expectedRaw;
  try {
    expectedRaw = readFileSync(rawPath);
  } catch {
    mkdirSync(ARTIFACT_DIR, { recursive: true });
    writeFileSync(join(ARTIFACT_DIR, `${name}-actual.png`), renderPixels(bitmap));
    assert.fail(`missing LCD golden ${rawPath}; inspect the actual PNG, then run npm run update:free85:goldens`);
  }

  const expectedBitmap = unpackLcdPixels(expectedRaw);
  const expectedPng = renderPixels(expectedBitmap);
  assert.deepEqual(readFileSync(pngPath), expectedPng, `${pngPath} is stale or was edited independently of its raw LCD fixture`);
  if (actualRaw.equals(expectedRaw)) return;

  mkdirSync(ARTIFACT_DIR, { recursive: true });
  const expectedArtifact = join(ARTIFACT_DIR, `${name}-expected.png`);
  const actualArtifact = join(ARTIFACT_DIR, `${name}-actual.png`);
  const diffArtifact = join(ARTIFACT_DIR, `${name}-diff.png`);
  writeFileSync(expectedArtifact, expectedPng);
  writeFileSync(actualArtifact, renderPixels(bitmap));
  writeFileSync(diffArtifact, renderPixels(bitmap, 4, expectedBitmap.pixels));
  let changedPixels = 0;
  for (let index = 0; index < bitmap.pixels.length; index += 1) {
    if (bitmap.pixels[index] !== expectedBitmap.pixels[index]) changedPixels += 1;
  }
  assert.fail(`LCD golden ${name} changed by ${changedPixels} pixels; inspect ${expectedArtifact}, ${actualArtifact}, and ${diffArtifact}`);
}

export function renderLcdPng(bitmap, scale = 4) {
  return renderPixels(bitmap, scale);
}

