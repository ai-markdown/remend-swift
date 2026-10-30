/// Markdown delimiter repairs ported from remend 1.3.1.
/// Copyright 2023 Vercel, Inc. Licensed under Apache-2.0.
extension Remend {
    static func pairCount(_ text: RemendText, marker: UInt16) -> Int {
        var count = 0, fence = false, index = 0
        while index < text.count {
            if text.triple(index) { fence.toggle(); index += 3; continue }
            if !fence, text[index] == marker, text[index + 1] == marker { count += 1; index += 1 }
            index += 1
        }
        return count
    }
    static func tripleStarCount(_ text: RemendText) -> Int {
        var count = 0, run = 0, fence = false, index = 0
        while index < text.count {
            if text.triple(index) {
                count += run / 3; run = 0; fence.toggle(); index += 3; continue
            }
            if !fence {
                if text[index] == 42 { run += 1 }
                else { count += run / 3; run = 0 }
            }
            index += 1
        }
        return count + run / 3
    }
    static func singleStarCount(_ text: RemendText) -> Int {
        var count = 0, fence = false, inWordChain = false, index = 0
        while index < text.count {
            defer { index += 1 }
            if text.triple(index) { fence.toggle(); index += 2; continue }
            if fence { continue }
            if text[index] != 42 { if !word(text[index]) { inWordChain = false }; continue }
            let before = text[index - 1], after = text[index + 1]
            if before == 92 || withinMath(text, index) { continue }
            if before != 42, after == 42 {
                if text[index + 2] != 42 { continue }
            } else if before == 42 || (before == 0 || space(before)) && (after == 0 || space(after)) { continue }
            let inWord = before != 0 && after != 0 && word(before) && word(after)
            if inWord, count % 2 == 0, !inWordChain { continue }
            let right = after != 0 && !space(after), left = before != 0 && !space(before)
            if left && count % 2 == 1 || right { count += 1; inWordChain = inWord }
        }
        return count
    }
    static func singleUnderscoreCount(_ text: RemendText) -> Int {
        var count = 0, fence = false, index = 0
        while index < text.count {
            defer { index += 1 }
            if text.triple(index) { fence.toggle(); index += 2; continue }
            if fence || text[index] != 95 { continue }
            let before = text[index - 1], after = text[index + 1]
            if before == 92 || withinMath(text, index) || withinURL(text, index) || withinHTML(text, index) || before == 95 || after == 95 { continue }
            if before != 0, after != 0, word(before), word(after) { continue }
            count += 1
        }
        return count
    }
    static func skipPair(_ text: RemendText, body: String, position: Int, marker: UInt16) -> Bool {
        if body.isEmpty || onlyMarkers(body) { return true }
        let prefix = RemendText(text.slice(0, position))
        let line = prefix.slice((prefix.last("\n") ?? -1) + 1)
        if test(#"^[\s]*[-*+][\s]+$"#, line), Remend.contains(body, "\n") { return true }
        return horizontalRule(text, position, marker)
    }
    static func bold(_ source: String) -> String {
        guard let found = match(#"(\*\*)([^*]*\*?)$"#, source) else { return source }
        let text = RemendText(source), body = found[2]
        guard let position = text.last(found[1]) else { return source }
        if withinCode(text, position) || withinClosedInlineCode(text, position) || skipPair(text, body: body, position: position, marker: 42) { return source }
        return pairCount(text, marker: 42) % 2 == 1 ? source + (Remend.endsWith(body, "*") ? "*" : "**") : source
    }
    static func doubleUnderscore(_ source: String) -> String {
        let text = RemendText(source)
        guard let found = match(#"(__)([^_]*?)$"#, source) else {
            if let partial = match(#"(__)([^_]+)_$"#, source), let position = text.last(partial[1]),
               !withinCode(text, position), !withinClosedInlineCode(text, position), pairCount(text, marker: 95) % 2 == 1 { return source + "_" }
            return source
        }
        guard let position = text.last(found[1]) else { return source }
        if withinCode(text, position) || withinClosedInlineCode(text, position) || skipPair(text, body: found[2], position: position, marker: 95) { return source }
        return pairCount(text, marker: 95) % 2 == 1 ? source + "__" : source
    }
    static func firstSingleOpener(_ text: RemendText, marker: UInt16) -> Int? {
        var fence = false, index = 0
        while index < text.count {
            defer { index += 1 }
            if text.triple(index) { fence.toggle(); index += 2; continue }
            let before = text[index - 1], after = text[index + 1]
            guard !fence, text[index] == marker, before != marker, after != marker, before != 92, !withinMath(text, index) else { continue }
            if marker == 95, withinURL(text, index) { continue }
            if before != 0, after != 0, word(before), word(after) { continue }
            if marker == 42 {
                let leftSpace = before == 0 || space(before), rightSpace = after == 0 || space(after)
                if leftSpace && rightSpace || rightSpace { continue }
            }
            return index
        }
        return nil
    }
    static func singleAsterisk(_ source: String) -> String {
        guard match(#"(\*)([^*]*?)$"#, source) != nil else { return source }
        let text = RemendText(source)
        guard let position = firstSingleOpener(text, marker: 42), !withinCode(text, position), !withinClosedInlineCode(text, position) else { return source }
        let body = text.slice(position + 1)
        if body.isEmpty || onlyMarkers(body) { return source }
        return singleStarCount(text) % 2 == 1 ? source + "*" : source
    }
    static func singleUnderscore(_ source: String) -> String {
        guard match(#"(_)([^_]*?)$"#, source) != nil else { return source }
        let text = RemendText(source)
        guard let position = firstSingleOpener(text, marker: 95) else { return source }
        let body = text.slice(position + 1)
        if body.isEmpty || onlyMarkers(body) || withinCode(text, position) || withinClosedInlineCode(text, position) { return source }
        guard singleUnderscoreCount(text) % 2 == 1 else { return source }
        if Remend.endsWith(source, "**") {
            let prefix = RemendText(text.slice(0, text.count - 2))
            if pairCount(prefix, marker: 42) % 2 == 1, let bold = prefix.first("**"),
               let italic = firstSingleOpener(prefix, marker: 95), bold < italic { return prefix.source + "_**" }
        }
        var end = text.count
        while end > 0, text[end - 1] == 10 { end -= 1 }
        return text.slice(0, end) + "_" + text.slice(end)
    }
    static func boldItalic(_ source: String) -> String {
        if test(#"^\*{4,}$"#, source) { return source }
        guard let found = match(#"(\*\*\*)([^*]*?)$"#, source) else { return source }
        let text = RemendText(source)
        guard let position = text.last(found[1]) else { return source }
        if found[2].isEmpty || onlyMarkers(found[2]) || withinCode(text, position) || withinClosedInlineCode(text, position) || horizontalRule(text, position, 42) { return source }
        guard tripleStarCount(text) % 2 == 1 else { return source }
        return pairCount(text, marker: 42) % 2 == 0 && singleStarCount(text) % 2 == 0 ? source : source + "***"
    }
    static func inlineCode(_ source: String) -> String {
        if test(#"^```[^`\n]*```?$"#, source), !Remend.contains(source, "\n") {
            return Remend.endsWith(source, "``") && !Remend.endsWith(source, "```") ? source + "`" : source
        }
        guard let found = match(#"(`)([^`]*?)$"#, source), matches("```", source).count % 2 == 0 else { return source }
        if found[2].isEmpty || onlyMarkers(found[2]) { return source }
        let text = RemendText(source)
        var count = 0, index = 0
        while index < text.count {
            defer { index += 1 }
            if text[index] == 92, text[index + 1] == 96 { index += 1; continue }
            if text[index] == 96, !text.triple(index), !(index > 0 && text.triple(index - 1)), !(index > 1 && text.triple(index - 2)) { count += 1 }
        }
        return count % 2 == 1 ? source + "`" : source
    }
    static func strikethrough(_ source: String) -> String {
        let text = RemendText(source)
        if let found = match(#"(~~)([^~]*?)$"#, source) {
            if found[2].isEmpty || onlyMarkers(found[2]) { return source }
            if let position = text.last(found[1]), !withinCode(text, position), !withinClosedInlineCode(text, position), matches("~~", source).count % 2 == 1 { return source + "~~" }
        } else if let found = match(#"(~~)([^~]+)~$"#, source), let position = text.last(String(found[0].prefix(2))),
                  !withinCode(text, position), !withinClosedInlineCode(text, position), matches("~~", source).count % 2 == 1 { return source + "~" }
        return source
    }
}
