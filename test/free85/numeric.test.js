import assert from "node:assert/strict";
import test from "node:test";
import {
  FREE85_NUMERIC_ERROR_ADDRESS,
  FREE85_UI_MODE_ADDRESS,
  Free85Harness
} from "../helpers/free85-harness.js";

function expressionKeys(expression) {
  const keys = [];
  for (let index = 0; index < expression.length; index += 1) {
    if (expression.startsWith("SQRT(", index)) {
      keys.push("2ND", "X^2");
      index += 4;
    } else if (expression[index] === "E") {
      keys.push("EE");
    } else if (
      expression[index] === "-" &&
      (index === 0 || "+-*/^(E".includes(expression[index - 1]))
    ) {
      keys.push("(-)");
    } else {
      keys.push(expression[index]);
    }
  }
  return keys;
}

function evaluate(expression, settleFrames = 2) {
  const harness = Free85Harness.boot();
  for (const key of expressionKeys(expression)) harness.tap(key);
  harness.tap("ENTER");
  harness.runFrames(settleFrames);
  return harness;
}

test("[numeric.arithmetic] packed-BCD arithmetic vectors produce clean decimal results", () => {
  const vectors = [
    ["2+3", "5"],
    ["5-12", "-7"],
    ["12.5-2.75", "9.75"],
    ["0.1+0.2", "0.3"],
    ["1000+0.001", "1000.001"],
    ["-2+5", "3"],
    ["-2*-3", "6"],
    ["999*999", "998001"],
    ["1/4", "0.25"],
    ["2/3", "0.66666666666667"],
    ["1E-3", "0.001"],
    ["1E3+2", "1002"],
    ["2^0", "1"],
    ["2^9", "512"]
  ];

  for (const [expression, expected] of vectors) {
    const harness = evaluate(expression);
    assert.equal(harness.resultText(), expected, expression);
    assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, expression);
  }
});

test("square root converges through the decimal arithmetic abstraction", () => {
  for (const [expression, expected] of [
    ["SQRT(81)", "9"],
    ["SQRT(0.25)", "0.5"],
    ["SQRT(2)", "1.4142135623731"]
  ]) {
    const harness = evaluate(expression, 30);
    assert.equal(harness.resultText(), expected, expression);
  }
});

test("numeric failures are recoverable dialogs", () => {
  const divideByZero = evaluate("1/0");
  assert.equal(divideByZero.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 2);
  assert.equal(divideByZero.machine.read8(FREE85_UI_MODE_ADDRESS), 1);
  divideByZero.tap("EXIT");
  assert.equal(divideByZero.machine.read8(FREE85_UI_MODE_ADDRESS), 0);
  assert.equal(divideByZero.editorText(), "1/0");

  const malformed = evaluate("1+");
  assert.equal(malformed.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 1);
  assert.equal(malformed.machine.read8(FREE85_UI_MODE_ADDRESS), 1);

  const overflow = evaluate("9E99*9E99");
  assert.equal(overflow.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 3);
  assert.equal(overflow.machine.read8(FREE85_UI_MODE_ADDRESS), 1);

  const domain = evaluate("SQRT(-1)", 30);
  assert.equal(domain.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 4);
  assert.equal(domain.machine.read8(FREE85_UI_MODE_ADDRESS), 1);
});
