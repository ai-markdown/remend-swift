#!/usr/bin/env node
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readdir, readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const baseline = path.join(root, 'upstream/remend-1.3.1');
const hash = value => createHash('sha256').update(value).digest('hex');
const read = name => readFile(path.join(baseline, name));
const manifest = JSON.parse(await read('manifest.json'));
assert.equal(manifest.upstreamVersion, '1.3.1');
assert.equal(manifest.sourceSnapshot.path, 'source-manifest.json');
assert.equal(manifest.sourceSnapshot.upstreamCommit, '8a2ac221a878a0fc5839f2035c1e16575cfa3440');
const sourceBytes = await read('source-manifest.json');
assert.equal(hash(sourceBytes), manifest.sourceSnapshot.sha256);
const source = JSON.parse(sourceBytes);
assert.equal(source.upstreamTag, 'remend@1.3.1');
assert.equal(source.upstreamCommit, manifest.sourceSnapshot.upstreamCommit);
assert.equal(source.generatorSHA256, hash(await readFile(path.join(here, 'freeze-source.mjs'))));
const refBytes = await read('release-ref.json');
assert.equal(source.releaseRefSHA256, hash(refBytes));
const ref = JSON.parse(refBytes);
assert.equal(ref.ref, 'refs/tags/remend@1.3.1');
assert.equal(ref.object.type, 'commit');
assert.equal(ref.object.sha, source.upstreamCommit);
const actualFiles = [];
async function walk(directory, prefix = '') {
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const relative = path.posix.join(prefix, entry.name);
    if (entry.isDirectory()) await walk(path.join(directory, entry.name), relative);
    else { assert.ok(entry.isFile()); actualFiles.push(relative); }
  }
}
await walk(path.join(baseline, 'repository'));
assert.deepEqual(actualFiles.sort(), Object.keys(source.sourceFiles).sort());
for (const [name, expected] of Object.entries(source.sourceFiles)) assert.equal(hash(await read('repository/' + name)), expected, name);
const inventoryBytes = await read('test-inventory.json');
assert.equal(hash(inventoryBytes), source.testInventorySHA256);
const inventory = JSON.parse(inventoryBytes);
assert.equal(inventory.upstreamCommit, source.upstreamCommit);
assert.equal(inventory.generatorSHA256, hash(await readFile(path.join(here, 'inventory.mjs'))));
assert.equal(inventory.testFileCount, 26);
assert.equal(inventory.testDeclarationCount, 477);
assert.equal(inventory.expandedTestCount, 489);
assert.equal(inventory.skippedDeclarations, 0);
assert.equal(inventory.todoDeclarations, 0);
assert.equal(inventory.benchmarkFileCount, 1);
assert.equal(inventory.benchmarkDeclarationCount, 26);
const all = inventory.files.flatMap(file => file.tests);
assert.equal(new Set(all.map(item => item.id)).size, all.length);
assert.equal(all.length, 503);
for (const file of inventory.files) {
  assert.equal(hash(await read('repository/packages/remend/' + file.file)), file.sha256);
  assert.equal(file.tests.length, file.declarationCount);
  assert.equal(file.tests.reduce((sum, item) => sum + item.parameterCount, 0), file.expandedCount);
  for (const item of file.tests) {
    assert.equal(item.id, `${file.file}:${item.line}`);
    assert.equal(item.mode, 'run');
    assert.equal(item.parameterCount, item.parameters?.length ?? 1);
  }
}
const validationBytes = await read('upstream-validation.json');
assert.equal(hash(validationBytes), source.upstreamValidationSHA256);
const validation = JSON.parse(validationBytes);
assert.equal(validation.upstreamCommit, source.upstreamCommit);
assert.equal(validation.toolchain.vitest, '4.1.10');
assert.equal(validation.toolchain.tsup, '8.5.1');
assert.equal(validation.toolchain.typescript, '5.9.3');
assert.equal(validation.toolchain.packageManager, 'pnpm@10.30.3');
assert.equal(validation.testCount, 489);
assert.equal(validation.passed, 489);
assert.equal(validation.failed + validation.skipped + validation.todo, 0);
assert.equal(validation.packageMetadataSemanticallyIdentical, true);
assert.equal(validation.testFiles.length, 26);
for (const file of validation.testFiles) {
  assert.equal(file.status, 'passed');
  const declared = inventory.files.find(item => item.file === file.file);
  assert.ok(declared && declared.file.startsWith('__tests__/'));
  assert.equal(file.tests.length, declared.expandedCount);
  const expectedNames = declared.tests.flatMap(item => (item.parameters ?? [null]).map(parameter => {
    const title = parameter === null ? item.title : item.title.replace('%s', parameter);
    return [...item.suites, title].join(' ');
  }));
  assert.deepEqual(file.tests.map(item => item.fullName).sort(), expectedNames.sort());
  for (const item of file.tests) assert.equal(item.status, 'passed');
}
for (const name of ['index.js', 'index.d.ts']) {
  const artifact = validation.artifacts[name];
  assert.equal(artifact.byteIdentical, true);
  assert.equal(artifact.rebuiltSHA256, artifact.distributionSHA256);
  assert.equal(artifact.distributionSHA256, manifest.sha256[name]);
  assert.equal(hash(await read(name)), artifact.distributionSHA256);
}
assert.equal(hash(await read('migration-inventory.json')), source.migrationInventorySHA256);
assert.equal(hash(await readFile(path.join(here, 'mappings.json'))), source.migrationMappingsSHA256);
execFileSync(process.execPath, [path.join(here, 'migration-inventory.mjs'), '--verify', '--require-complete'], { stdio: 'inherit' });
console.log('Verified pinned release source, all 489 original Vitest results, exact distribution rebuilds, and complete Swift migration references; 26 benchmarks remain separate.');
