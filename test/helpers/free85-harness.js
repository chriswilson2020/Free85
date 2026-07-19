import { Ti85Machine } from "../../src/ti85.js";

export const FREE85_ROM_PATH = "ROM/FREE85.ROM";
export const FREE85_BOOT_FRAMES = 35;
export const FREE85_LAST_KEY_ADDRESS = 0x8009;
export const FREE85_UI_MODE_ADDRESS = 0x800b;
export const FREE85_MODIFIERS_ADDRESS = 0x800c;
export const FREE85_EDITOR_LENGTH_ADDRESS = 0x8010;
export const FREE85_EDITOR_CURSOR_ADDRESS = 0x8011;
export const FREE85_EDITOR_INSERT_ADDRESS = 0x8012;
export const FREE85_LAST_ACTION_ADDRESS = 0x8013;
export const FREE85_LAST_MODIFIER_ADDRESS = 0x8014;
export const FREE85_EDITOR_BUFFER_ADDRESS = 0x8020;
export const FREE85_RESULT_VISIBLE_ADDRESS = 0x8058;
export const FREE85_RESULT_LENGTH_ADDRESS = 0x8059;
export const FREE85_NUMERIC_ERROR_ADDRESS = 0x805a;
export const FREE85_RESULT_BUFFER_ADDRESS = 0x8060;

export class Free85Harness {
  static boot() {
    const harness = new Free85Harness(Ti85Machine.fromRomFile(FREE85_ROM_PATH));
    harness.runFrames(FREE85_BOOT_FRAMES);
    return harness;
  }

  constructor(machine) {
    this.machine = machine;
  }

  runFrames(count) {
    for (let index = 0; index < count; index += 1) this.machine.runFrame();
  }

  tap(key, holdFrames = 2, gapFrames = 2) {
    this.machine.pressKey(key);
    this.runFrames(holdFrames);
    this.machine.releaseKey(key);
    this.runFrames(gapFrames);
  }

  signature() {
    const frame = this.machine.renderLcdBitmap();
    return {
      litPixelCount: frame.litPixelCount,
      checksum: frame.checksum.toString(16).padStart(8, "0").toUpperCase(),
      lastKey: this.machine.read8(FREE85_LAST_KEY_ADDRESS)
    };
  }

  editorText() {
    const length = this.machine.read8(FREE85_EDITOR_LENGTH_ADDRESS);
    return String.fromCharCode(...Array.from(
      { length },
      (_, index) => this.machine.read8(FREE85_EDITOR_BUFFER_ADDRESS + index)
    ));
  }

  resultText() {
    const length = this.machine.read8(FREE85_RESULT_LENGTH_ADDRESS);
    return String.fromCharCode(...Array.from(
      { length },
      (_, index) => this.machine.read8(FREE85_RESULT_BUFFER_ADDRESS + index)
    ));
  }
}
