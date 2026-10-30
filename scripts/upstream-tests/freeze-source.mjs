#!/usr/bin/env node
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { readdir, readFile, mkdir, copyFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const checkout = path.resolve(process.argv[2] ?? path.join(root, '.build/upstream-source'));
const target = path.join(root, 'upstream/remend-1.3.1/repository');
const commit = '8a2ac221a878a0fc5839f2035c1e16575cfa3440';
const hash = data => createHash('sha256').update(data).digest('hex');
const packagePath = 'packages/remend';
const metadata = JSON.parse(await readFile(path.join(checkout, packagePath, 'package.json')));
if (metadata.version !== '1.3.1') throw new Error('Expected remend source version 1.3.1');
const refBytes = await readFile(path.join(checkout, 'source-ref.json'));
const ref = JSON.parse(refBytes);
if (ref.ref !== 'refs/tags/remend@1.3.1' || ref.object.type !== 'commit' || ref.object.sha !== commit) {
  throw new Error('Release tag does not resolve to the pinned commit');
}
const archiveRoot = execFileSync('tar', ['-tzf', path.join(checkout, 'source.tar.gz')], { encoding: 'utf8' }).split('/')[0];
if (!archiveRoot.endsWith(commit.slice(0, 7))) throw new Error('Archive root does not match the pinned commit');
const files = [];
async function list(relative) {
  for (const entry of await readdir(path.join(checkout, relative), { withFileTypes: true })) {
    if (['node_modules', 'dist', '.vitest', 'coverage'].includes(entry.name)) continue;
    const name = path.posix.join(relative, entry.name);
    if (entry.isDirectory()) await list(name);
    else if (entry.isFile()) files.push(name);
    else throw new Error(`Unexpected source entry: ${name}`);
  }
}
await list(packagePath);
files.push('LICENSE', 'package.json', 'pnpm-lock.yaml', 'pnpm-workspace.yaml', 'tsconfig.json');
const hashes = {};
for (const file of files.sort()) {
  const destination = path.join(target, file);
  await mkdir(path.dirname(destination), { recursive: true });
  await copyFile(path.join(checkout, file), destination);
  hashes[file] = hash(await readFile(destination));
}
const manifest = {
  schemaVersion: 1, upstreamRepository: 'https://github.com/vercel/streamdown',
  upstreamTag: 'remend@1.3.1', upstreamCommit: commit,
  packageVersion: metadata.version,
  sourceArchiveURL: `https://api.github.com/repos/vercel/streamdown/tarball/${commit}`,
  sourceArchiveSHA256: hash(await readFile(path.join(checkout, 'source.tar.gz'))),
  releaseRefSHA256: hash(refBytes),
  generatorSHA256: hash(await readFile(fileURLToPath(import.meta.url))),
  description: 'Unmodified package source, all original tests and benchmarks, and root tooling context at the release tag. Runtime distribution is frozen separately.',
  sourceFiles: hashes,
};
await writeFile(path.join(root, 'upstream/remend-1.3.1/release-ref.json'), refBytes);
await writeFile(path.join(root, 'upstream/remend-1.3.1/source-manifest.json'), JSON.stringify(manifest, null, 2) + '\n');
console.log(`Frozen ${files.length} source/context files from ${commit}`);
