#!/usr/bin/env node
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const baseline = path.join(root, 'upstream/remend-1.3.1');
const checkout = path.join(root, '.build/upstream-source');
const packageRoot = path.join(checkout, 'packages/remend');
const report = JSON.parse(await readFile(path.join(root, '.build/upstream-vitest.json')));
const inventory = JSON.parse(await readFile(path.join(baseline, 'test-inventory.json')));
assert.deepEqual(JSON.parse(await readFile(path.join(packageRoot, 'package.json'))),
  JSON.parse(await readFile(path.join(baseline, 'package.json'))));
assert.equal(report.success, true);
assert.equal(report.numTotalTests, inventory.expandedTestCount);
assert.equal(report.numPassedTests, inventory.expandedTestCount);
assert.equal(report.numFailedTests, 0);
assert.equal(report.numPendingTests, 0);
assert.equal(report.numTodoTests, 0);
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const artifacts = {};
for (const name of ['index.js', 'index.d.ts']) {
  const distribution = await readFile(path.join(baseline, name));
  const rebuilt = await readFile(path.join(packageRoot, 'dist', name));
  assert.ok(distribution.equals(rebuilt), `Rebuilt ${name} differs from the published artifact`);
  artifacts[name] = { distributionSHA256: hash(distribution), rebuiltSHA256: hash(rebuilt), byteIdentical: true };
}
const version = async name => JSON.parse(await readFile(path.join(packageRoot, 'node_modules', name, 'package.json'))).version;
const summary = {
  schemaVersion: 1, upstreamCommit: inventory.upstreamCommit, upstreamTag: 'remend@1.3.1',
  toolchain: { node: process.version, packageManager: JSON.parse(await readFile(path.join(checkout, 'package.json'))).packageManager,
    vitest: await version('vitest'), tsup: await version('tsup'),
    typescript: JSON.parse(await readFile(path.join(checkout, 'node_modules/typescript/package.json'))).version },
  testFiles: report.testResults.map(result => ({
    file: path.relative(packageRoot, result.name).split(path.sep).join('/'), status: result.status,
    tests: result.assertionResults.map(test => ({ title: test.title, fullName: test.fullName, status: test.status })),
  })).sort((left, right) => left.file.localeCompare(right.file)),
  testCount: report.numTotalTests, passed: report.numPassedTests, failed: report.numFailedTests,
  skipped: report.numPendingTests, todo: report.numTodoTests, artifacts,
  packageMetadataSemanticallyIdentical: true,
  note: 'Original Vitest tests ran unmodified. Benchmark declarations are inventoried separately and are not included in this test count.',
};
const body = JSON.stringify(summary, null, 2) + '\n';
await writeFile(path.join(baseline, 'upstream-validation.json'), body);
const sourceManifest = JSON.parse(await readFile(path.join(baseline, 'source-manifest.json')));
sourceManifest.upstreamValidationSHA256 = hash(body);
sourceManifest.migrationInventorySHA256 = hash(await readFile(path.join(baseline, 'migration-inventory.json')));
sourceManifest.migrationMappingsSHA256 = hash(await readFile(path.join(root, 'scripts/upstream-tests/mappings.json')));
const sourceBytes = JSON.stringify(sourceManifest, null, 2) + '\n';
await writeFile(path.join(baseline, 'source-manifest.json'), sourceBytes);
const manifest = JSON.parse(await readFile(path.join(baseline, 'manifest.json')));
manifest.sourceSnapshot = { path: 'source-manifest.json', sha256: hash(sourceBytes),
  upstreamTag: 'remend@1.3.1', upstreamCommit: inventory.upstreamCommit,
  testInventoryPath: 'test-inventory.json', upstreamValidationPath: 'upstream-validation.json' };
await writeFile(path.join(baseline, 'manifest.json'), JSON.stringify(manifest, null, 2) + '\n');
console.log(`Verified ${summary.passed} original tests and byte-identical JavaScript/declaration rebuilds`);
