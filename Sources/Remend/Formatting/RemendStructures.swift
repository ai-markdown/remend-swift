/// Structural repairs ported from remend 1.3.1. Copyright 2023 Vercel, Inc. Apache-2.0.
extension Remend {
    static func singleTilde(_ source: String) -> String {
        guard Remend.contains(source, "~") else { return source }
        let text = RemendText(source)
        return replacing(#"([\p{L}\p{N}_])~(?!~)(?=[\p{L}\p{N}_])"#, source) { found in
            withinCode(text, found.index + found[1].utf16.count) ? found[0] : found[1] + #"\~"#
        }
    }
    static func comparisonOperators(_ source: String) -> String {
        guard Remend.contains(source, ">") else { return source }
        let text = RemendText(source)
        return replacing(#"^(\s*(?:[-*+]|\d+[.)]) +)>(=?\s*[$]?\d)"#, source, multiline: true) { found in
            withinCode(text, found.index) ? found[0] : found[1] + #"\>"# + found[2]
        }
    }
    static func htmlTags(_ source: String) -> String {
        guard let found = match(#"<[a-zA-Z/][^>]*$"#, source), !withinCode(RemendText(source), found.index) else { return source }
        return trimEnd(RemendText(source).slice(0, found.index))
    }
    static func setextHeadings(_ source: String) -> String {
        let text = RemendText(source)
        guard let newline = text.last("\n") else { return source }
        let line = text.slice(newline + 1), prefix = RemendText(text.slice(0, newline))
        let previous = prefix.slice((prefix.last("\n") ?? -1) + 1)
        let trimmed = trim(line)
        if (test(#"^-{1,2}$"#, trimmed) && !test(#"^[\s]*-{1,2}[\s]+$"#, line)) ||
            (test(#"^={1,2}$"#, trimmed) && !test(#"^[\s]*={1,2}[\s]+$"#, line)) {
            if !trim(previous).isEmpty { return source + "\u{200B}" }
        }
        return source
    }
    static func earliestUnclosedLink(_ text: RemendText, before end: Int) -> Int {
        var index = 0
        while index < end {
            defer { index += 1 }
            if text[index] != 91 || withinCode(text, index) || text[index - 1] == 33 { continue }
            guard let closing = closingBracket(text, index) else { return index }
            if text[closing + 1] == 40, let endURL = text.first(")", from: closing + 2) { index = endURL }
        }
        return end
    }
    static func links(_ source: String, mode: RemendLinkMode) -> String {
        let text = RemendText(source)
        if let link = text.last("]("), !withinCode(text, link), !Remend.contains(text.slice(link + 2), ")"),
           let opening = openingBracket(text, link), !withinCode(text, opening) {
            let image = text[opening - 1] == 33
            let prefix = text.slice(0, image ? opening - 1 : opening)
            if image { return prefix }
            let label = text.slice(opening + 1, link)
            return mode == .textOnly ? prefix + label : prefix + "[" + label + "](streamdown:incomplete-link)"
        }
        guard text.count > 0 else { return source }
        for index in stride(from: text.count - 1, through: 0, by: -1) where text[index] == 91 && !withinCode(text, index) {
            if !Remend.contains(text.slice(index + 1), "]") || closingBracket(text, index) == nil {
                if text[index - 1] == 33 { return text.slice(0, index - 1) }
                if mode == .textOnly {
                    let earliest = earliestUnclosedLink(text, before: index)
                    return text.slice(0, earliest) + text.slice(earliest + 1)
                }
                return source + "](streamdown:incomplete-link)"
            }
        }
        return source
    }
}
