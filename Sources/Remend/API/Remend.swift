/// Complete unfinished Markdown constructs using the remend 1.3.1 rules.
/// Handlers execute synchronously in priority order; a thrown error stops the chain and propagates to the caller.
/// Calls share no mutable scanner state and may run concurrently when custom handlers are safe to do so.
public func remend(_ text: String, options: RemendOptions = .init()) throws -> String {
    guard !text.isEmpty else { return text }
    var output = Remend.endsWith(text, " ") && !Remend.endsWith(text, "  ") ? String(decoding: text.utf16.dropLast(), as: UTF16.self) : text
    for item in Remend.handlers(options) {
        output = try item.handler.handle(output)
        if item.earlyReturn, Remend.endsWith(output, "](streamdown:incomplete-link)") { return output }
    }
    return output
}

/// Ported from remend 1.3.1/dist/index.js. Copyright 2023 Vercel, Inc. Licensed under Apache-2.0.
/// Preserve built-in priorities, the shared links/images switch, protocol early return, and stable ordering.
enum Remend {
    struct Item: Sendable {
        let handler: RemendHandler
        var earlyReturn = false
    }

    static func handlers(_ options: RemendOptions) -> [Item] {
        var result: [Item] = []
        func add(_ enabled: Bool, _ name: String, _ priority: Double, _ body: @escaping @Sendable (String) -> String, early: Bool = false) {
            if enabled { result.append(Item(handler: .init(name: name, priority: priority, handle: body), earlyReturn: early)) }
        }
        add(options.singleTilde, "singleTilde", 0, singleTilde)
        add(options.comparisonOperators, "comparisonOperators", 5, comparisonOperators)
        add(options.htmlTags, "htmlTags", 10, htmlTags)
        add(options.setextHeadings, "setextHeadings", 15, setextHeadings)
        add(options.links || options.images, "links", 20, { links($0, mode: options.linkMode) }, early: options.linkMode == .protocol)
        add(options.boldItalic, "boldItalic", 30, boldItalic)
        add(options.bold, "bold", 35, bold)
        add(options.italic, "italicDoubleUnderscore", 40, doubleUnderscore)
        add(options.italic, "italicSingleAsterisk", 41, singleAsterisk)
        add(options.italic, "italicSingleUnderscore", 42, singleUnderscore)
        add(options.inlineCode, "inlineCode", 50, inlineCode)
        add(options.strikethrough, "strikethrough", 60, strikethrough)
        add(options.katex, "katex", 70, blockMath)
        add(options.inlineKatex, "inlineKatex", 75, inlineMath)
        result += options.handlers.map { Item(handler: $0) }
        return result.enumerated().sorted {
            let delta = $0.element.handler.priority - $1.element.handler.priority
            return delta.isNaN || delta == 0 ? $0.offset < $1.offset : delta < 0
        }.map(\.element)
    }
}
