import assert from "node:assert/strict";
import { Free85Harness } from "../test/helpers/free85-harness.js";

const frames = Number(process.env.FREE85_SOAK_FRAMES ?? 9000);
const harness = Free85Harness.boot();
const expected = harness.signature();
harness.runFrames(frames);
assert.deepEqual(harness.signature(), expected);
console.log(`Free85 remained stable for ${frames} frames (${(frames / 50).toFixed(1)} emulated seconds).`);

