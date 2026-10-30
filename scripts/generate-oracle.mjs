#!/usr/bin/env node
import { createHash } from 'node:crypto';
import { readFile, mkdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');
const upstream = path.join(root, 'upstream/remend-1.3.1');
const output = path.join(root, 'Tests/RemendTests/Fixtures');
const hash = value => createHash('sha256').update(value).digest('hex');
const sourceManifest = await readFile(path.join(upstream, 'manifest.json'));
const baseline = JSON.parse(sourceManifest);
if (baseline.upstreamVersion !== '1.3.1') throw new Error('Expected frozen remend 1.3.1');
for (const [name, expected] of Object.entries(baseline.sha256)) {
  if (hash(await readFile(path.join(upstream, name))) !== expected) throw new Error(`Upstream hash mismatch: ${name}`);
}
const runtime = await import(pathToFileURL(path.join(upstream, 'index.js')));
const allDisabled = Object.fromEntries(['bold', 'boldItalic', 'comparisonOperators', 'htmlTags', 'images', 'inlineCode', 'italic', 'links', 'setextHeadings', 'singleTilde', 'strikethrough', 'katex', 'inlineKatex'].map(key => [key, false]));
const profiles = [
  { id: 'default', options: {} },
  { id: 'text-only', options: { linkMode: 'text-only' } },
  ...['bold', 'boldItalic', 'comparisonOperators', 'htmlTags', 'images', 'inlineCode', 'italic', 'links', 'setextHeadings', 'singleTilde', 'strikethrough', 'katex'].map(key => ({ id: `without-${key}`, options: { [key]: false } })),
  { id: 'without-links-or-images', options: { links: false, images: false } },
  { id: 'all-disabled', options: allDisabled },
  { id: 'inline-only', options: { katex: false, inlineKatex: true } },
  { id: 'both-math', options: { katex: true, inlineKatex: true } },
  { id: 'block-math-only-handler', options: { ...allDisabled, katex: true } },
  { id: 'inline-math-only-handler', options: { ...allDisabled, inlineKatex: true } },
  { id: 'web-adapter', options: { linkMode: 'text-only', katex: false, inlineKatex: false } },
  { id: 'custom-default', options: {}, handlers: [{ name: 'last', kind: 'suffix', value: '**tail' }] },
  { id: 'custom-order', options: {}, handlers: [{ name: 'late', priority: 100, kind: 'suffix', value: 'L' }, { name: 'first', priority: -1, kind: 'prefix', value: '**' }, { name: 'middle', priority: 34.5, kind: 'suffix', value: '**' }, { name: 'late', priority: 100, kind: 'suffix', value: 'R' }] },
  { id: 'protocol-early-return', options: { linkMode: 'protocol' }, handlers: [{ name: 'before', priority: 19, kind: 'prefix', value: 'PRE ' }, { name: 'after', priority: 21, kind: 'suffix', value: ' POST' }] },
  { id: 'custom-math-order', options: { inlineKatex: true }, handlers: [{ name: 'before-math', priority: 69, kind: 'suffix', value: '$$x' }, { name: 'before-inline', priority: 74.5, kind: 'suffix', value: '$y' }, { name: 'after-math', priority: 76, kind: 'suffix', value: ' END' }] },
];
const stems = [
  '', ' ', '  ', '**bold', '**bold*', '***bold italic', '****', '**_nested', '**_nested**', '__bold', '__bold_', '_italic\n\n', '*italic', '~~strike', '~~strike~', '`inline code', '\\`escaped',
  '```js\nconst s = "**literal";\n```', '```js\n**literal', '```js``', '```js```', 'prefix ```x``` **bold', '~~**_x', '*a*b*c', 'a*b*c', 'a_b_c', 'a*bc',
  '[$x_y$](a_b)', '[nested [label](https://exa', '[outer [inner]', '![image](url', '![alt', '[[link', 'See [link](https://a(b', '[one](a) [two',
  '20~25', '中~文', '𐐀~𝟘', 'e\u0301~e', '- > 25', '1. >= $10', '* >20', 'body\n-', 'body\n--', 'body\n==', 'body\n- ',
  'text <custom', 'text <a href="x_y', 'text </tag', '`<custom`', 'text\uFEFF<incomplete', '**white\uFEFF', '**line\r\n',
  'a\u0085- > 1', 'a\u2028- > 1', 'a\u2029- > 1', 'a\r- > 1', 'a\r\n- > 1', '- > ١', '١. > 2', '**x*\r\n',
  '$$x', '$$x$', '$$x$$', '$$x\n y', '$$x\n', '`$$x`', '```math\n$$x\n```', '$x', '\\$x', '\\\\$x', '`$x`', '$x $$y', '\\`$x', '$$$', '\\$$x',
  '$math_*_a', '$$math_*_a', '\\(math_*_a', '\\[math_*_a', '\\$ **bold', '**☕é e\u0301 中😀',
];
// Grapheme-cluster boundaries must not hide ASCII delimiters from UTF-16 operations.
for (const prepend of ['\u0600', '\u06DD', '\u070F', '\u08E2', '\u0D4E', '\u{110BD}']) {
  stems.push(`x${prepend} `, `$$x${prepend}$`, `**a${prepend}*`, `[x](url${prepend})`, `[x${prepend}](url`, `label${prepend}](streamdown:incomplete-link)`, `**a${prepend}**`);
}
stems.push('$$\r\nx\r\n', '**a*\r\n', '- **a\r\nb', '![a](url\u0600)', '[a\u0600]');
let state = 0x12345678;
const random = () => { state ^= state << 13; state ^= state >>> 17; state ^= state << 5; return (state >>> 0) / 0x100000000; };
const atoms = ['a', 'b', ' ', '\n', '\r', '\t', '*', '**', '***', '_', '__', '~', '~~', '`', '```', '\\', '$', '$$', '[', ']', '(', ')', '!', '<', '>', '/', '中', 'é', 'e\u0301', '😀', '\uFEFF', '\u2028', '𐐀'];
const inputs = new Set(stems);
for (const stem of stems) {
  const units = Array.from(stem);
  for (let index = 0; index <= units.length; index++) inputs.add(units.slice(0, index).join(''));
}
for (let sample = 0; sample < 1500; sample++) {
  let text = '';
  for (let index = 0, count = Math.floor(random() * 30); index < count; index++) text += atoms[Math.floor(random() * atoms.length)];
  inputs.add(text);
}

const cases = [];
for (const [profileIndex, profile] of profiles.entries()) {
  const handlers = (profile.handlers ?? []).map(spec => ({ name: spec.name, priority: spec.priority, handle: source => spec.kind === 'prefix' ? spec.value + source : source + spec.value }));
  for (const [index, input] of [...inputs].entries()) {
    if (profileIndex > 1 && index >= stems.length && index % 5 !== profileIndex % 5) continue;
    cases.push({ id: `${profile.id}-${index}`, profile: profile.id, input, expected: runtime.default(input, { ...profile.options, handlers }) });
  }
}
const helperCases = [];
for (const input of stems) {
  for (let position = -1; position <= input.length + 1; position++) {
    helperCases.push({ input, position, code: runtime.isWithinCodeBlock(input, position), math: runtime.isWithinMathBlock(input, position), url: runtime.isWithinLinkOrImageUrl(input, position) });
  }
}
const wordCases = ['', 'a', '9', '_', '!', 'é', '中', '𐐀', '𝟘', '😀', '\u0301', 'e\u0301', '!a', '!中', '\uFEFF', '١'].map(input => ({ input, expected: runtime.isWordChar(input) }));
const body = JSON.stringify({ profiles, cases, helperCases, wordCases }) + '\n';
await mkdir(output, { recursive: true });
await writeFile(path.join(output, 'results.json'), body);
await writeFile(path.join(output, 'manifest.json'), JSON.stringify({ schemaVersion: 1, upstreamVersion: baseline.upstreamVersion, upstreamManifestSHA256: hash(sourceManifest), generatorSHA256: hash(await readFile(fileURLToPath(import.meta.url))), resultsSHA256: hash(body), caseCount: cases.length, helperCount: helperCases.length, wordCount: wordCases.length, seed: '0x12345678' }, null, 2) + '\n');
console.log(`Generated ${cases.length} repairs, ${helperCases.length} positions, and ${wordCases.length} word cases from remend 1.3.1`);
