# Upstream test provenance

The baseline is `vercel/streamdown` tag `remend@1.3.1`, commit `8a2ac221a878a0fc5839f2035c1e16575cfa3440`. This is not a newer upstream version. The source snapshot contains all 46 files in `packages/remend` and five root build/license files. Original source and test files are unchanged.

The AST inventory records 26 functional test files, 477 declarations and 489 expanded cases, with no skipped or pending cases. One `it.each` declaration expands to 13 cases. The 26 declarations in the separate benchmark file are inventoried but not migrated or counted as functional tests.

`mappings.json` is the single migration mapping source. Every original declaration maps to a Swift function, except `basic-input.test.ts:5`: JavaScript's invalid-input behavior is represented by Swift's static `String` parameter. The compiler contract script verifies that valid input compiles and that `nil`, `Optional<String>`, and integer arguments do not. Thus the original 489 cases map to 488 expanded runtime cases and one compile-time adaptation, rather than an omitted or skipped test.

## Verify a standalone checkout

```bash
swift test
node scripts/verify-oracle.mjs --with-swift-contract
```

The Node verifier needs no npm dependencies or network. It checks the complete hash chain, the pinned GitHub tag response, original Vitest results, byte-identical build evidence, and every migration target. The optional flag also runs the actual Swift compiler contract; CI runs that contract explicitly on both Swift platforms.

## Reproduce the original upstream run

These commands require Node, pnpm, GitHub CLI access, and network access. Run from the repository root. Use a fresh `.build/upstream-source` directory so unrelated files cannot enter the snapshot.

```bash
mkdir -p .build/upstream-source
gh api repos/vercel/streamdown/git/ref/tags/remend%401.3.1 > .build/upstream-source/source-ref.json
gh api repos/vercel/streamdown/tarball/8a2ac221a878a0fc5839f2035c1e16575cfa3440 > .build/upstream-source/source.tar.gz
tar -xzf .build/upstream-source/source.tar.gz -C .build/upstream-source --strip-components=1
pnpm --dir .build/upstream-source --filter remend install --frozen-lockfile --ignore-scripts
pnpm --dir .build/upstream-source/packages/remend exec vitest run --reporter=json --outputFile="$PWD/.build/upstream-vitest.json"
pnpm --dir .build/upstream-source/packages/remend build
node scripts/upstream-tests/freeze-source.mjs
node scripts/upstream-tests/inventory.mjs
node scripts/upstream-tests/migration-inventory.mjs --require-complete
node scripts/upstream-tests/record-validation.mjs
node scripts/generate-oracle.mjs
node scripts/verify-oracle.mjs --with-swift-contract
```

The original root package selects pnpm 10.30.3. Its frozen lock selects Vitest 4.1.10, tsup 8.5.1, and TypeScript 5.9.3. The recorded original run passed all 489 cases. Both regenerated `index.js` and `index.d.ts` were byte-identical to the published npm artifacts. Node's actual version is recorded in `upstream-validation.json`; regenerating on another toolchain may change validation metadata and must be reviewed.

`source-manifest.json` hashes all frozen source files, the declaration inventory, original validation evidence, and final migration mapping/inventory. The primary npm manifest hashes that source manifest. The additional differential-oracle fixture manifest then hashes the primary manifest. Regenerate the records in the order above after intentional evidence changes.

The inventory verifies coverage and target existence; it does not prove arbitrary translations semantically equivalent. The direct Swift assertions, separately executed original tests, and additional real-runtime differential corpus provide behavioral evidence. Benchmarks remain a separate future task rather than a claim of equivalent cross-platform performance.
