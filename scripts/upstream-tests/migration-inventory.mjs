#!/usr/bin/env node
import assert from 'node:assert/strict';
import { readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const baseline = path.join(root, 'upstream/remend-1.3.1');
const inventory = JSON.parse(await readFile(path.join(baseline, 'test-inventory.json')));
const mappings = JSON.parse(await readFile(path.join(here, 'mappings.json')));
const used = new Set();
const cases = [];
for (const file of inventory.files) {
  for (const item of file.tests) {
    const mapping = mappings[item.id];
    if (mapping) {
      used.add(item.id);
      if (mapping.status === 'type-system-adaptation') {
        assert.ok(mapping.evidenceFiles?.length, `Missing type-system evidence for ${item.id}`);
        if (mapping.swiftFile) await readFile(path.join(root, mapping.swiftFile));
      } else if (mapping.swiftFile && mapping.symbol) {
        const source = await readFile(path.join(root, mapping.swiftFile), 'utf8');
        assert.ok(source.includes(`func ${mapping.symbol.split('.').at(-1)}(`), `Missing Swift function for ${item.id}`);
      } else {
        assert.ok(mapping.status !== 'direct-port' && mapping.evidenceFiles?.length, `Missing mapping evidence for ${item.id}`);
      }
      for (const evidence of mapping.evidenceFiles ?? []) await readFile(path.join(root, evidence));
    }
    cases.push({ ...item, status: mapping?.status ?? (item.kind === 'benchmark' ? 'separate-benchmark' : 'not-ported'),
      swiftFile: mapping?.swiftFile ?? null, symbol: mapping?.symbol ?? null,
      evidenceFiles: mapping?.evidenceFiles ?? [], note: mapping?.note ?? (item.kind === 'benchmark'
        ? 'Upstream benchmark only; not counted as a functional test or a Swift performance acceptance threshold.'
        : mapping ? 'Original test name, input, and assertions are preserved.' : 'No verified direct Swift migration yet.') });
  }
}
assert.deepEqual([...used].sort(), Object.keys(mappings).sort(), 'Mapping references an unknown upstream declaration');
const counts = {}, expanded = {};
for (const item of cases) {
  counts[item.status] = (counts[item.status] ?? 0) + 1;
  expanded[item.status] = (expanded[item.status] ?? 0) + item.parameterCount;
}
if (process.argv.includes('--require-complete')) assert.equal(counts['not-ported'] ?? 0, 0, 'Original functional tests remain unmigrated');
const output = { schemaVersion: 1, upstreamCommit: inventory.upstreamCommit,
  functionalDeclarations: inventory.testDeclarationCount, expandedFunctionalTests: inventory.expandedTestCount,
  benchmarkDeclarations: inventory.benchmarkDeclarationCount, counts, expandedCounts: expanded, cases };
const body = JSON.stringify(output, null, 2) + '\n';
const destination = path.join(baseline, 'migration-inventory.json');
if (process.argv.includes('--verify')) assert.equal(await readFile(destination, 'utf8'), body);
else await writeFile(destination, body);
console.log(`Upstream migration declarations: ${JSON.stringify(counts)}; expanded: ${JSON.stringify(expanded)}`);
