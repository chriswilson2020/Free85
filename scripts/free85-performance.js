import { writeFile } from "node:fs/promises";
import { TI85_PHYSICAL_KEYS } from "../src/ti85-keys.js";
import { Free85Harness } from "../test/helpers/free85-harness.js";

const GRAPH_ACTIVE = 0x8502;
const RESULT_VISIBLE = 0x8058;
const NUMERIC_ERROR = 0x805a;
const alphaKeys = new Map(TI85_PHYSICAL_KEYS
  .filter(({ alpha }) => /^[A-Z]$/.test(alpha ?? ""))
  .map(({ alpha, key }) => [alpha, key]));

const phase11Baseline = {
  evaluation: {
    arithmetic: { frames: 3, tstates: 360008 },
    sin: { frames: 13, tstates: 1560069 },
    exp: { frames: 46, tstates: 5520217 },
    ln: { frames: 96, tstates: 11520477 }
  },
  graph: {
    linear: { frames: 238, tstates: 29040979 },
    quadratic: { frames: 409, tstates: 49561806 },
    sine: { frames: 2438, tstates: 293050083 }
  }
};

const limits = {
  key_response_frames: 1,
  evaluation_frames: { arithmetic: 4, sin: 15, sin_large: 30, exp: 30, ln: 70, integral: 250 },
  graph_frames: { linear: 150, quadratic: 320, sine: 2400, derivative: 1000, accumulator: 25000 }
};

function typeExpression(harness, expression) {
  for (const character of expression) {
    if (/[A-Z]/.test(character)) {
      harness.tap("ALPHA");
      harness.tap(alphaKeys.get(character));
    } else {
      harness.tap(character);
    }
  }
}

function measureKeyResponse() {
  const harness = Free85Harness.boot();
  const start = harness.machine.cpu.tStates;
  harness.machine.pressKey("7");
  let frames = 0;
  while (harness.editorText() !== "7" && frames < 10) {
    harness.machine.runFrame();
    frames += 1;
  }
  harness.machine.releaseKey("7");
  return { frames, tstates: harness.machine.cpu.tStates - start };
}

function measureEvaluation(expression, equation) {
  const harness = Free85Harness.boot();
  if (equation) {
    harness.machine.write8(0x8510, equation.length);
    for (let index = 0; index < equation.length; index += 1) {
      harness.machine.write8(0x8511 + index, equation.charCodeAt(index));
    }
    harness.machine.write8(0x8501, 1);
  }
  typeExpression(harness, expression);
  const start = harness.machine.cpu.tStates;
  harness.machine.pressKey("ENTER");
  let frames = 0;
  while (!harness.machine.read8(RESULT_VISIBLE) && !harness.machine.read8(NUMERIC_ERROR) && frames < 5000) {
    harness.machine.runFrame();
    frames += 1;
  }
  harness.machine.releaseKey("ENTER");
  return {
    frames,
    tstates: harness.machine.cpu.tStates - start,
    result: harness.resultText(),
    error: harness.machine.read8(NUMERIC_ERROR)
  };
}

function measureGraph(expression) {
  const harness = Free85Harness.boot();
  typeExpression(harness, expression);
  const start = harness.machine.cpu.tStates;
  harness.tap("GRAPH");
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) && frames < 5000) {
    harness.machine.runFrame();
    frames += 1;
  }
  return { frames, tstates: harness.machine.cpu.tStates - start };
}

function measureGraphSlots(first, second, frameLimit) {
  const harness = Free85Harness.boot();
  harness.tap("GRAPH");
  while (harness.machine.read8(GRAPH_ACTIVE)) harness.machine.runFrame();
  for (const [address, source] of [[0x8510, first], [0x8541, second]]) {
    harness.machine.write8(address, source.length);
    for (let index = 0; index < source.length; index += 1) {
      harness.machine.write8(address + 1 + index, source.charCodeAt(index));
    }
  }
  harness.machine.write8(0x8501, 3);
  const start = harness.machine.cpu.tStates;
  harness.tap("GRAPH");
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) && frames < frameLimit) {
    harness.machine.runFrame();
    frames += 1;
  }
  if (harness.machine.read8(GRAPH_ACTIVE)) throw new Error(`${second} graph exceeded ${frameLimit} frames`);
  return { frames, tstates: harness.machine.cpu.tStates - start };
}

function improvement(before, after) {
  return Number((((before - after) / before) * 100).toFixed(2));
}

const evaluation = {
  arithmetic: measureEvaluation("(12+34)*(56-7)/3"),
  sin: measureEvaluation("SIN(1)"),
  sin_large: measureEvaluation("SIN(1000000)"),
  exp: measureEvaluation("EXP(1)"),
  ln: measureEvaluation("LN(2)"),
  integral: measureEvaluation("FNINT(0,2)", "X^2")
};
const graph = {
  linear: measureGraph("X"),
  quadratic: measureGraph("X^2-4"),
  sine: measureGraph("5*SIN(X)"),
  derivative: measureGraphSlots("X^2", "NDER(1,X)", 1000),
  accumulator: measureGraphSlots("2*X", "FNINT(1,0,X)", 25000)
};

const report = {
  schema_version: 1,
  release: "2.19.0",
  phase: "15.5",
  clock_hz: 6000000,
  key_response: measureKeyResponse(),
  evaluation,
  graph,
  improvement_percent: {
    evaluation: Object.fromEntries(Object.entries(evaluation).map(([name, value]) => [
      name,
      phase11Baseline.evaluation[name]
        ? improvement(phase11Baseline.evaluation[name].tstates, value.tstates)
        : null
    ])),
    graph: Object.fromEntries(Object.entries(graph).map(([name, value]) => [
      name,
      phase11Baseline.graph[name]
        ? improvement(phase11Baseline.graph[name].tstates, value.tstates)
        : null
    ]))
  },
  limits
};

const failures = [];
if (report.key_response.frames > limits.key_response_frames) failures.push("ordinary key response");
for (const [name, limit] of Object.entries(limits.evaluation_frames)) {
  if (evaluation[name].frames > limit || evaluation[name].error !== 0) failures.push(`${name} evaluation`);
}
for (const [name, limit] of Object.entries(limits.graph_frames)) {
  if (graph[name].frames > limit) failures.push(`${name} graph`);
}

const json = `${JSON.stringify(report, null, 2)}\n`;
if (process.argv.includes("--write")) await writeFile("spec/free85/performance.json", json);
console.log(json.trimEnd());
if (failures.length > 0) throw new Error(`Free85 performance targets failed: ${failures.join(", ")}`);
