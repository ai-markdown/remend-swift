#!/usr/bin/env node
import { createHash } from 'node:crypto';
import { readdir, readFile, writeFile } from 'node:fs/promises';
import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const baseline = path.join(root, 'upstream/remend-1.3.1');
const source = path.join(baseline, 'repository/packages/remend');
const require = createRequire(path.resolve(process.argv[2] ?? path.join(root, '.build/upstream-source/package.json')));
const ts = require('typescript');
const hash = value => createHash('sha256').update(value).digest('hex');
const files = [];
for (const directory of ['__tests__', '__benchmarks__']) {
  for (const name of (await readdir(path.join(source, directory))).sort()) {
    const file = `${directory}/${name}`;
    const text = await readFile(path.join(source, file), 'utf8');
    const ast = ts.createSourceFile(file, text, ts.ScriptTarget.Latest, true, name.endsWith('.tsx') ? ts.ScriptKind.TSX : ts.ScriptKind.TS);
    const tests = [], imports = [];
    const titleOf = node => node && (ts.isStringLiteral(node) || ts.isNoSubstitutionTemplateLiteral(node)) ? node.text : null;
    function walk(node, suites = [], inheritedMode = 'run') {
      if (ts.isImportDeclaration(node)) imports.push(node.moduleSpecifier.text);
      if (ts.isCallExpression(node)) {
        const expression = node.expression.getText(ast);
        const title = titleOf(node.arguments[0]);
        if (/^describe(?:\.|$)/.test(expression) && title !== null) {
          const callback = [...node.arguments].find(arg => ts.isArrowFunction(arg) || ts.isFunctionExpression(arg));
          const mode = /\.skip\b/.test(expression) ? 'skip' : /\.todo\b/.test(expression) ? 'todo' : inheritedMode;
          if (callback) walk(callback.body, [...suites, title], mode);
          return;
        }
        if (/^(it|test|bench)(?:\.|\(|$)/.test(expression) && title !== null) {
          const line = ast.getLineAndCharacterOfPosition(node.getStart(ast)).line + 1;
          let parameterCount = 1, parameters = null;
          if (ts.isCallExpression(node.expression) && /\.each$/.test(node.expression.expression.getText(ast))) {
            const table = node.expression.arguments[0];
            if (!table || !ts.isArrayLiteralExpression(table)) throw new Error(`Unsupported parameter table: ${file}:${line}`);
            parameters = table.elements.map(element => titleOf(element) ?? { expression: element.getText(ast) });
            parameterCount = parameters.length;
          }
          let assertionDeclarations = 0;
          function countAssertions(child) {
            if (ts.isCallExpression(child) && child.expression.getText(ast) === 'expect') assertionDeclarations++;
            ts.forEachChild(child, countAssertions);
          }
          countAssertions(node);
          const mode = /^(?:it|test|bench)\.skip\b/.test(expression) ? 'skip' :
            /^(?:it|test|bench)\.todo\b/.test(expression) ? 'todo' : inheritedMode;
          tests.push({ id: `${file}:${line}`, file, line, title, suites,
            fullTitle: [...suites, title].join(' > '),
            kind: expression.startsWith('bench') ? 'benchmark' : parameters ? 'parameterized' : 'test',
            mode, parameterCount, parameters, assertionDeclarations });
          return;
        }
      }
      ts.forEachChild(node, child => walk(child, suites, inheritedMode));
    }
    walk(ast);
    files.push({ file, sha256: hash(text), imports, declarationCount: tests.length,
      expandedCount: tests.reduce((sum, item) => sum + item.parameterCount, 0), tests });
  }
}
const tests = files.flatMap(file => file.tests);
const functional = tests.filter(test => test.kind !== 'benchmark');
const inventory = { schemaVersion: 1, upstreamVersion: '1.3.1',
  upstreamCommit: '8a2ac221a878a0fc5839f2035c1e16575cfa3440', typescriptVersion: ts.version,
  testFileCount: files.filter(file => file.file.startsWith('__tests__/')).length,
  testDeclarationCount: functional.length,
  expandedTestCount: functional.reduce((sum, test) => sum + test.parameterCount, 0),
  skippedDeclarations: functional.filter(test => test.mode === 'skip').length,
  todoDeclarations: functional.filter(test => test.mode === 'todo').length,
  benchmarkFileCount: files.filter(file => file.file.startsWith('__benchmarks__/')).length,
  benchmarkDeclarationCount: tests.filter(test => test.kind === 'benchmark').length,
  generatorSHA256: hash(await readFile(fileURLToPath(import.meta.url))), files };
const body = JSON.stringify(inventory, null, 2) + '\n';
await writeFile(path.join(baseline, 'test-inventory.json'), body);
const manifestPath = path.join(baseline, 'source-manifest.json');
const manifest = JSON.parse(await readFile(manifestPath));
manifest.testInventorySHA256 = hash(body);
await writeFile(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
console.log(`Upstream tests: ${inventory.testFileCount} files, ${inventory.testDeclarationCount} declarations, ${inventory.expandedTestCount} expanded tests, ${inventory.skippedDeclarations} skipped, ${inventory.todoDeclarations} todo; ${inventory.benchmarkDeclarationCount} separate benchmarks`);
