/// Math tail completion ported from remend 1.3.1. Copyright 2023 Vercel, Inc. Apache-2.0.
extension Remend {
    private static func tripleBacktickPart(_ text: RemendText, _ position: Int) -> Bool {
        (position >= 2 && text.triple(position - 2)) ||
            (position >= 1 && text.triple(position - 1)) || text.triple(position)
    }

    static func blockMath(_ source: String) -> String {
        let text = RemendText(source)
        var pairs = 0, inlineCode = false, index = 0
        while index + 1 < text.count {
            if text[index] == 96, !tripleBacktickPart(text, index) { inlineCode.toggle() }
            if !inlineCode, text[index] == 36, text[index + 1] == 36 { pairs += 1; index += 1 }
            index += 1
        }
        guard !pairs.isMultiple(of: 2) else { return source }
        if Remend.endsWith(source, "$"), !Remend.endsWith(source, "$$") { return source + "$" }
        if let first = text.first("$$"), text.first("\n", from: first) != nil, !Remend.endsWith(source, "\n") { return source + "\n$$" }
        return source + "$$"
    }

    static func inlineMath(_ source: String) -> String {
        let text = RemendText(source)
        var singles = 0, inlineCode = false, index = 0
        while index < text.count {
            if text[index] == 92 { index += 2; continue }
            if text[index] == 96, !tripleBacktickPart(text, index) { inlineCode.toggle(); index += 1; continue }
            if !inlineCode, text[index] == 36 {
                if text[index + 1] == 36 { index += 1 }
                else { singles += 1 }
            }
            index += 1
        }
        return singles.isMultiple(of: 2) ? source : source + "$"
    }
}
