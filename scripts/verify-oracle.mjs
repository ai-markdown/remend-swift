#!/usr/bin/env node
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const upstream = path.join(root, 'upstream/remend-1.3.1');
const fixture = path.join(root, 'Tests/RemendTests/Fixtures');
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const baselineBytes = await readFile(path.join(upstream, 'manifest.json'));
const baseline = JSON.parse(baselineBytes);
for (const [name, expected] of Object.entries(baseline.sha256)) {
  if (hash(await readFile(path.join(upstream, name))) !== expected) throw new Error(`Upstream hash mismatch: ${name}`);
}
const manifest = JSON.parse(await readFile(path.join(fixture, 'manifest.json')));
if (hash(baselineBytes) !== manifest.upstreamManifestSHA256) throw new Error('Baseline manifest changed');
if (hash(await readFile(path.join(root, 'scripts/generate-oracle.mjs'))) !== manifest.generatorSHA256) throw new Error('Generator changed; regenerate evidence');
const bytes = await readFile(path.join(fixture, 'results.json'));
if (hash(bytes) !== manifest.resultsSHA256) throw new Error('Oracle results changed');
const result = JSON.parse(bytes);
if (result.cases.length !== manifest.caseCount || result.helperCases.length !== manifest.helperCount || result.wordCases.length !== manifest.wordCount) throw new Error('Oracle counts differ from manifest');
console.log(`Verified remend ${baseline.upstreamVersion}: ${manifest.caseCount} repairs, ${manifest.helperCount} positions, ${manifest.wordCount} word cases`);

execFileSync(process.execPath, [path.join(root, 'scripts/upstream-tests/verify.mjs')], { stdio: 'inherit' });
if (process.argv.includes('--with-swift-contract')) {
  execFileSync('bash', [path.join(root, 'scripts/upstream-tests/verify-string-input-contract.sh')], { stdio: 'inherit' });
}
