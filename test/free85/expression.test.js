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
    } else if (expression.startsWith("ANS", index)) {
      keys.push("2ND", "(-)");
      index += 2;
    } else if (expression[index] === "E") {
      keys.push("EE");
    } else if (expression[index] === "→") {
      keys.push("STO");
    } else if (/[A-Z]/.test(expression[index])) {
      keys.push("ALPHA", {
        A: "LOG", B: "SIN", C: "COS", D: "TAN", X: "+"
      }[expression[index]]);
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

function enterExpression(harness, expression) {
  for (const key of expressionKeys(expression)) {
    assert.ok(key, `no physical key mapping for ${expression}`);
    harness.tap(key);
  }
}

function evaluate(expression, settleFrames = 35) {
  const harness = Free85Harness.boot();
  enterExpression(harness, expression);
  harness.tap("ENTER");
  harness.runFrames(settleFrames);
  return harness;
}

test("[expression.precedence] parser follows precedence, associativity, and unary rules", () => {
  const vectors = [
    ["2+3*4", "14"],
    ["(2+3)*4", "20"],
    ["-2^2", "-4"],
    ["(-2)^2", "4"],
    ["2^-3", "0.125"],
    ["2^3^2", "512"],
    ["1E-3", "0.001"],
    ["2(3+4)", "14"],
    ["SQRT(81)+1", "10"]
  ];
  for (const [expression, expected] of vectors) {
    const harness = evaluate(expression);
    assert.equal(harness.resultText(), expected, expression);
    assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, expression);
  }
});

test("[expression.variables] assignment, variables, and previous answer share numeric objects", () => {
  const harness = Free85Harness.boot();
  enterExpression(harness, "5→A");
  harness.tap("ENTER");
  assert.equal(harness.resultText(), "5");

  harness.tap("CLEAR");
  enterExpression(harness, "A+2");
  harness.tap("ENTER");
  assert.equal(harness.resultText(), "7");

  harness.tap("CLEAR");
  enterExpression(harness, "ANS*3");
  harness.tap("ENTER");
  assert.equal(harness.resultText(), "21");
});

test("[expression.history] history navigation restores editable expressions and reevaluates", () => {
  const harness = Free85Harness.boot();
  for (const expression of ["1+1", "2+2", "3+3"]) {
    enterExpression(harness, expression);
    harness.tap("ENTER");
    harness.tap("CLEAR");
  }

  harness.tap("UP");
  assert.equal(harness.editorText(), "3+3");
  harness.tap("UP");
  assert.equal(harness.editorText(), "2+2");
  harness.tap("DOWN");
  assert.equal(harness.editorText(), "3+3");
  harness.tap("ENTER");
  assert.equal(harness.resultText(), "6");
  harness.tap("DEL");
  harness.tap("4");
  harness.tap("ENTER");
  assert.equal(harness.editorText(), "3+4");
  assert.equal(harness.resultText(), "7");
});

test("malformed token streams return syntax dialogs without corrupting the editor", () => {
  for (const expression of ["2+*3", "(2+3", "2^^3", "SQRT()"] ) {
    const harness = evaluate(expression);
    assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 1, expression);
    assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 1, expression);
    harness.tap("EXIT");
    assert.equal(harness.editorText(), expression, expression);
    assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 0, expression);
  }
});
