// Open Free85 5x7 glyphs used only as shape hypotheses. No TI glyph data is
// stored here. The deliberately tolerant matcher reads semantic text from a
// user-owned ROM while allowing the two ROMs to render different pixels.
const glyphRows = {
  "-": [0, 0, 0, 31, 0, 0, 0],
  ".": [0, 0, 0, 0, 0, 4, 4],
  "/": [1, 2, 4, 8, 16, 0, 0],
  "0": [14, 17, 19, 21, 25, 17, 14],
  "1": [4, 12, 4, 4, 4, 4, 14],
  "2": [14, 17, 1, 2, 4, 8, 31],
  "3": [30, 1, 1, 14, 1, 1, 30],
  "4": [2, 6, 10, 18, 31, 2, 2],
  "5": [31, 16, 16, 30, 1, 1, 30],
  "6": [14, 16, 16, 30, 17, 17, 14],
  "7": [31, 1, 2, 4, 8, 8, 8],
  "8": [14, 17, 17, 14, 17, 17, 14],
  "9": [14, 17, 17, 15, 1, 1, 14],
  "E": [31, 16, 16, 30, 16, 16, 31]
};

export function cellRows(bitmap, originX, originY, column, row) {
  return Array.from({ length: 7 }, (_, y) => {
    let bits = 0;
    for (let x = 0; x < 5; x += 1) {
      bits = (bits << 1) | bitmap.pixels[((originY + row * 8 + y) * bitmap.width) + originX + column * 6 + x];
    }
    return bits;
  });
}

function distance(left, right) {
  let total = 0;
  for (let row = 0; row < 7; row += 1) {
    let bits = left[row] ^ right[row];
    while (bits) {
      total += bits & 1;
      bits >>>= 1;
    }
  }
  return total;
}

function recognize(rows, hypotheses = glyphRows) {
  if (rows.every((value) => value === 0)) return { character: " ", distance: 0 };
  let best = { character: "?", distance: Infinity };
  for (const [character, candidates] of Object.entries(hypotheses)) {
    for (const candidate of Array.isArray(candidates[0]) ? candidates : [candidates]) {
      const score = distance(rows, candidate);
      if (score < best.distance) best = { character, distance: score };
    }
  }
  return best.distance <= 9 ? best : { character: "?", distance: best.distance };
}

export function readRawLines(bitmap, { originX = 1, originY = 0 } = {}) {
  return Array.from({ length: 8 }, (_, row) => ({
    row,
    cells: Array.from({ length: 21 }, (_, column) => cellRows(bitmap, originX, originY, column, row))
  }));
}

export function readNumericLines(bitmap, { originX = 1, originY = 0, hypotheses = glyphRows } = {}) {
  const lines = [];
  for (let row = 0; row < 8; row += 1) {
    const cells = Array.from({ length: 21 }, (_, column) => recognize(cellRows(bitmap, originX, originY, column, row), hypotheses));
    const first = cells.findIndex(({ character }) => character !== " ");
    let last = cells.length - 1;
    while (last >= 0 && cells[last].character === " ") last -= 1;
    if (first < 0) continue;
    const text = cells.slice(first, last + 1).map(({ character }) => character).join("");
    const confidence = cells.slice(first, last + 1).reduce((sum, cell) => sum + cell.distance, 0);
    lines.push({ row, firstColumn: first, lastColumn: last, text, confidence });
  }
  return lines;
}

export function readRightAlignedNumber(bitmap, options = {}) {
  const candidates = readNumericLines(bitmap, options)
    .filter(({ lastColumn, text }) => lastColumn >= 18 && /^[-0-9.E?]+$/.test(text) && !/^\?+$/.test(text));
  if (candidates.length === 0) return null;
  const candidate = candidates[candidates.length - 1];
  return { ...candidate, value: candidate.text.replace(/\?/g, "") };
}

export function bitmapToPbm(bitmap) {
  const rows = [];
  for (let y = 0; y < bitmap.height; y += 1) {
    rows.push(Array.from({ length: bitmap.width }, (_, x) => bitmap.pixels[y * bitmap.width + x]).join(" "));
  }
  return `P1\n${bitmap.width} ${bitmap.height}\n${rows.join("\n")}\n`;
}
