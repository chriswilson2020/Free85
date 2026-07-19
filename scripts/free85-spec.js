import { readFile } from "node:fs/promises";
import { TI85_KEY_LAYOUT, TI85_KEY_ROWS } from "../src/ti85-keys.js";

export const FREE85_KEYMAP_PATH = "spec/free85/keymap.yaml";
export const FREE85_FEATURES_PATH = "spec/free85/features.yaml";
export const FREE85_USAGE_PATH = "firmware/free85/generated/usage.json";

async function readJsonYaml(path) {
  try {
    return JSON.parse(await readFile(path, "utf8"));
  } catch (error) {
    throw new Error(`Cannot parse ${path} as JSON-compatible YAML: ${error.message}`);
  }
}

export async function readFree85Specifications() {
  const [keymap, features] = await Promise.all([
    readJsonYaml(FREE85_KEYMAP_PATH),
    readJsonYaml(FREE85_FEATURES_PATH)
  ]);
  let usage = null;
  try {
    usage = await readJsonYaml(FREE85_USAGE_PATH);
  } catch (error) {
    if (!error.message.includes("ENOENT")) throw error;
  }
  return { keymap, features, usage };
}

function duplicates(values) {
  const seen = new Set();
  const repeated = new Set();
  for (const value of values) {
    if (seen.has(value)) repeated.add(value);
    seen.add(value);
  }
  return [...repeated];
}

function sameMembers(actual, expected) {
  return actual.length === expected.length
    && [...actual].sort().every((value, index) => value === [...expected].sort()[index]);
}

function validateSurface(errors, entry, modifier, expectedLabel, featureIds) {
  const surface = entry[modifier];
  if (expectedLabel === undefined) {
    if (surface !== null) errors.push(`${entry.physical_key}.${modifier} must be null`);
    return;
  }
  if (!surface || typeof surface !== "object") {
    errors.push(`${entry.physical_key}.${modifier} is missing`);
    return;
  }
  if (surface.label !== expectedLabel) {
    errors.push(`${entry.physical_key}.${modifier} label must be ${JSON.stringify(expectedLabel)}`);
  }
  if (!surface.id || !featureIds.has(surface.id)) {
    errors.push(`${entry.physical_key}.${modifier} references unknown feature ${JSON.stringify(surface.id)}`);
  }
  if (!surface.behaviour) errors.push(`${entry.physical_key}.${modifier} needs a behaviour`);
}

export function validateFree85Specifications({ keymap, features }) {
  const errors = [];
  const physicalDefinitions = TI85_KEY_LAYOUT.flat();
  const physicalNames = physicalDefinitions.map(({ key }) => key);
  const matrixNames = TI85_KEY_ROWS.flat().filter(Boolean);
  const mappedNames = keymap.keys?.map(({ physical_key: key }) => key) ?? [];
  const featureEntries = features.features ?? [];
  const featureIds = new Set(featureEntries.map(({ id }) => id));
  const allowedStatuses = new Set(features.allowed_statuses ?? []);

  if (keymap.schema_version !== 1) errors.push("keymap schema_version must be 1");
  if (features.schema_version !== 1) errors.push("features schema_version must be 1");
  if (keymap.inventory !== "src/ti85-keys.js") errors.push("keymap inventory must name src/ti85-keys.js");
  if (!Array.isArray(keymap.keys)) errors.push("keymap.keys must be an array");
  if (!Array.isArray(features.features)) errors.push("features.features must be an array");

  for (const key of duplicates(physicalNames)) errors.push(`duplicate browser key ${key}`);
  for (const key of duplicates(matrixNames)) errors.push(`duplicate matrix key ${key}`);
  for (const key of duplicates(mappedNames)) errors.push(`duplicate keymap key ${key}`);
  for (const id of duplicates(featureEntries.map(({ id }) => id))) errors.push(`duplicate feature id ${id}`);

  if (!sameMembers(mappedNames, physicalNames)) {
    errors.push("keymap physical keys do not exactly match the browser inventory");
  }
  if (!sameMembers(matrixNames, physicalNames.filter((key) => key !== "ON"))) {
    errors.push("matrix keys must match every physical key except ON");
  }

  const keyEntries = new Map((keymap.keys ?? []).map((entry) => [entry.physical_key, entry]));
  for (const definition of physicalDefinitions) {
    const entry = keyEntries.get(definition.key);
    if (!entry) continue;
    validateSurface(errors, entry, "normal", definition.label, featureIds);
    validateSurface(errors, entry, "second", definition.shift, featureIds);
    validateSurface(errors, entry, "alpha", definition.alpha, featureIds);
    if (!Array.isArray(entry.contexts) || entry.contexts.length === 0) {
      errors.push(`${definition.key} needs at least one context`);
    }
    if (!allowedStatuses.has(entry.status)) errors.push(`${definition.key} has invalid status ${entry.status}`);
    if (!Array.isArray(entry.tests)) errors.push(`${definition.key}.tests must be an array`);
  }

  for (const feature of featureEntries) {
    if (!feature.id) errors.push("feature without id");
    if (!allowedStatuses.has(feature.status)) errors.push(`${feature.id} has invalid status ${feature.status}`);
    if (!Array.isArray(feature.surfaces) || feature.surfaces.length === 0) {
      errors.push(`${feature.id} needs at least one surface`);
    }
    if (!Array.isArray(feature.tests)) errors.push(`${feature.id}.tests must be an array`);
    if (feature.status === "complete") {
      if (!feature.implementation) errors.push(`${feature.id} is complete without an implementation`);
      if (!feature.documentation) errors.push(`${feature.id} is complete without documentation`);
      if (!feature.tests?.length) errors.push(`${feature.id} is complete without tests`);
    }
  }

  for (const entry of keymap.keys ?? []) {
    for (const modifier of ["normal", "second", "alpha"]) {
      const surface = entry[modifier];
      if (!surface) continue;
      const feature = featureEntries.find(({ id }) => id === surface.id);
      const registered = feature?.surfaces?.some(({ key, modifier: candidate }) => (
        key === entry.physical_key && candidate === modifier
      ));
      if (!registered) errors.push(`${surface.id} does not register ${entry.physical_key}.${modifier}`);
    }
  }

  return errors;
}

export function createFree85Coverage({ keymap, features, usage = null }) {
  const physicalDefinitions = TI85_KEY_LAYOUT.flat();
  const shiftedDefinitions = physicalDefinitions.filter(({ shift }) => shift !== undefined);
  const alphaDefinitions = physicalDefinitions.filter(({ alpha }) => alpha !== undefined);
  const completeFeatures = features.features.filter(({ status }) => status === "complete");
  const statusCounts = Object.fromEntries(features.allowed_statuses.map((status) => [status, 0]));
  for (const feature of features.features) statusCounts[feature.status] += 1;
  const percent = (registered, total) => total === 0 ? null : Number(((registered / total) * 100).toFixed(2));
  const registeredSurface = (definition, modifier) => {
    const entry = keymap.keys.find(({ physical_key: key }) => key === definition.key);
    return Boolean(entry?.[modifier]);
  };
  const completeWithTests = completeFeatures.filter(({ tests }) => tests.length > 0).length;

  return {
    schema_version: 1,
    phase: usage?.phase ?? 0,
    source: "spec/free85/features.yaml",
    physical_keys: {
      total: physicalDefinitions.length,
      registered: physicalDefinitions.filter((definition) => registeredSurface(definition, "normal")).length,
      percent: percent(keymap.keys.length, physicalDefinitions.length),
      matrix: TI85_KEY_ROWS.flat().filter(Boolean).length,
      special: 1
    },
    shifted_functions: {
      total: shiftedDefinitions.length,
      registered: shiftedDefinitions.filter((definition) => registeredSurface(definition, "second")).length,
      percent: percent(shiftedDefinitions.filter((definition) => registeredSurface(definition, "second")).length, shiftedDefinitions.length)
    },
    alpha_mappings: {
      total: alphaDefinitions.length,
      registered: alphaDefinitions.filter((definition) => registeredSurface(definition, "alpha")).length,
      percent: percent(alphaDefinitions.filter((definition) => registeredSurface(definition, "alpha")).length, alphaDefinitions.length)
    },
    features: {
      total: features.features.length,
      statuses: statusCounts,
      complete_with_tests: completeWithTests,
      complete_test_percent: percent(completeWithTests, completeFeatures.length)
    },
    tests_referenced: [...new Set(features.features.flatMap(({ tests }) => tests))].length,
    rom_usage: usage ? {
      total_bytes: usage.rom_bytes,
      used_bytes: usage.pages.reduce((total, page) => total + page.used_bytes, 0),
      free_bytes: usage.pages.reduce((total, page) => total + page.free_bytes, 0),
      banks: usage.pages
    } : null,
    ram_usage: usage?.ram ?? null
  };
}
