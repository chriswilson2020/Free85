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
  evaluation_frames: { arithmetic: 4, sin: 15, exp: 30, ln: 70 },
  graph_frames: { linear: 150, quadratic: 320, sine: 2300 }
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

function measureEvaluation(expression) {
  const harness = Free85Harness.boot();
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

function improvement(before, after) {
  return Number((((before - after) / before) * 100).toFixed(2));
}

const evaluation = {
  arithmetic: measureEvaluation("(12+34)*(56-7)/3"),
  sin: measureEvaluation("SIN(1)"),
  exp: measureEvaluation("EXP(1)"),
  ln: measureEvaluation("LN(2)")
};
const graph = {
  linear: measureGraph("X"),
  quadratic: measureGraph("X^2-4"),
  sine: measureGraph("5*SIN(X)")
};

const report = {
  schema_version: 1,
  release: "1.0.0",
  phase: 12,
  clock_hz: 6000000,
  key_response: measureKeyResponse(),
  evaluation,
  graph,
  improvement_percent: {
    evaluation: Object.fromEntries(Object.entries(evaluation).map(([name, value]) => [
      name,
      improvement(phase11Baseline.evaluation[name].tstates, value.tstates)
    ])),
    graph: Object.fromEntries(Object.entries(graph).map(([name, value]) => [
      name,
      improvement(phase11Baseline.graph[name].tstates, value.tstates)
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
