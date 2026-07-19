export function oracleFailures(results, stateResults) {
  return {
    regressions: results.filter(({ classification }) => classification === "free85-regression"),
    unreadable: results.filter(({ classification }) => classification === "oracle-observation-unreadable"),
    stateProbeFailures: stateResults.filter(({ classification }) => classification !== "observed")
  };
}

export function oracleFailureMessage(failures) {
  return `Oracle validation failed: ${failures.regressions.length} Free85 regressions, ${failures.unreadable.length} unreadable oracle observations, ${failures.stateProbeFailures.length} failed state probes`;
}
