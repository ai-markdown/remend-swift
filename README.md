# Remend Swift

A native Swift port of **remend 1.3.1**, the Markdown tail-repair utility from Vercel's Streamdown. The package uses Foundation and the Swift standard library. Building, testing, and running it do not require AI Markdown, a workspace checkout, JavaScript, or WebKit.

## Use

Add the `Remend` product from `https://github.com/ai-markdown/remend-swift` to a SwiftPM target, pinning the published commit required by your application. The package uses Swift 6 and declares iOS 15, macOS 12, tvOS 15, and watchOS 8 minimums. Its Foundation-only implementation also has Linux CI coverage configured.

```swift
import Remend

let repaired = try remend("Streaming **bold")
// "Streaming **bold**"

let math = try remend("$$x")
// "$$x$$"

let textOnly = try remend("[docs](https://exa", options: .init(linkMode: .textOnly))
// "docs"
```

The public API consists of:

- `remend(_:options:) throws -> String`
- `RemendOptions`, `RemendHandler`, and `RemendLinkMode`
- `isWordChar(_:)`
- `isWithinCodeBlock(_:position:)`, `isWithinMathBlock(_:position:)`, and `isWithinLinkOrImageUrl(_:position:)`

Helper positions use UTF-16 code units, as upstream JavaScript does. The exported code-block helper recognizes triple-backtick blocks; it intentionally differs from the internal scanner that also tracks inline code. Strings preserve exact Unicode input rather than applying canonical normalization.

## Options and handlers

All repair switches default to `true` except `inlineKatex`, which defaults to `false`. `linkMode` defaults to `.protocol`, producing `streamdown:incomplete-link` for unfinished links. These are the original remend defaults, not AI Markdown's wrapper defaults.

`RemendOptions` supports `bold`, `boldItalic`, `comparisonOperators`, `htmlTags`, `images`, `inlineCode`, `inlineKatex`, `italic`, `katex`, `links`, `setextHeadings`, `singleTilde`, `strikethrough`, `linkMode`, and `handlers`. As upstream does, `links` and `images` share a handler: disabling only one does not disable that handler.

Custom handlers are synchronous, `@Sendable`, and may throw. They run in ascending priority order; equal finite priorities preserve declaration order. A thrown error stops the chain. Protocol-link repair returns early before subsequent handlers. Empty input skips the entire chain.

```swift
let handler = RemendHandler(name: "custom", priority: 100) { source in
    source.replacingOccurrences(of: "[answer]", with: "Answer")
}
let result = try remend("[answer] **ready", options: .init(handlers: [handler]))
```

Use finite priorities. NaN makes upstream's subtracting comparator non-total, so the execution order of such inputs is not guaranteed to match V8, other JavaScript engines, or Swift. Such values do not trigger a Swift-only precondition failure; tests verify that each handler still executes when early return is disabled.

Applications with their own LaTeX preprocessing can explicitly select `katex: false`, `inlineKatex: false`, and `linkMode: .textOnly`. That integration policy belongs in the application adapter and is not the default behavior of this package.

## Source and maintenance

The `upstream` branch records an **import of the published npm remend 1.3.1 distribution**, not the complete `vercel/streamdown` Git history. The `ai-markdown` branch maintains the native Swift implementation on that auditable baseline. The original distribution, declarations, package metadata, license notice, and exact SHA-256 hashes are stored under `upstream/remend-1.3.1/`.

The runtime has one Swift implementation. The frozen JavaScript file is test provenance and an optional oracle-generation input; it is not compiled into or invoked by the library.

Source and test directories mirror responsibilities under `API`, `Formatting`, and `Support`; frozen inputs are kept in `Tests/RemendTests/Fixtures`.

## Validation

From a standalone clone:

```bash
swift build
swift test
node scripts/verify-oracle.mjs
```

Node is only needed to verify or regenerate frozen evidence, not to build or run Swift tests. To regenerate the oracle against the already-frozen upstream distribution:

```bash
node scripts/generate-oracle.mjs
node scripts/verify-oracle.mjs
```

The Swift suite checks **16,913 exact repair outputs**, **1,524 helper-position cases**, and **16 word-character cases** from the real remend 1.3.1 runtime. Cases cover all supported switches, both math handlers and their ordering, partial delimiters, escaped/code-contained math, default protocol versus text-only links, custom-handler priorities, Unicode/CRLF/grapheme-boundary differences, and deterministic mixed-input fuzzing. Additional focused tests cover throwing handlers, concurrency, non-total priority inputs, and 10,000 replacements with code-region exclusions.

Per-input immutable scanner indexes and ordered replacement assembly avoid quadratic costs introduced by repeatedly scanning prefixes or moving mutable buffer tails. This is not a linear-time guarantee for every upstream repair rule or a formal performance acceptance result.

Local macOS build and tests have passed. Linux and hosted CI are configured but were not run in the local macOS environment. Standalone style checks can use SwiftFormat 0.64.4 and SwiftLint 0.65.1 with this repository's `.swiftformat` and `.swiftlint.yml`.

## License

Apache License 2.0. See `LICENSE`, `NOTICE`, and the unchanged upstream notice in `upstream/remend-1.3.1/LICENSE`.
