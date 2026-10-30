import Foundation

/// UTF-16 scanning semantics from remend 1.3.1; ASCII delimiter slicing preserves source bytes.
/// Copyright 2023 Vercel, Inc. Licensed under Apache-2.0. Native Swift port.
struct RemendText {
    let source: String
    let units: [UInt16]
    /// Per-input immutable position index: bit 0 is code, bit 1 is math. No shared mutable cache.
    private let contexts: [UInt8]
    init(_ source: String) {
        self.source = source
        units = Array(source.utf16)
        contexts = Self.contexts(units)
    }
    func withinCode(_ position: Int) -> Bool { contexts[max(0, min(position, count))] & 1 != 0 }
    func withinMath(_ position: Int) -> Bool { contexts[max(0, min(position, count))] & 2 != 0 }

    private static func contexts(_ units: [UInt16]) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: units.count + 1)
        func at(_ index: Int) -> UInt16 { units.indices.contains(index) ? units[index] : 0 }
        var inline = false, fence = false, index = 0
        while index < units.count {
            let advance: Int
            if at(index) == 92, at(index + 1) == 96 { advance = 2 }
            else if at(index) == 96, at(index + 1) == 96, at(index + 2) == 96 { fence.toggle(); advance = 3 }
            else {
                if !fence, at(index) == 96 { inline.toggle() }
                advance = 1
            }
            if inline || fence {
                for position in (index + 1) ... min(index + advance, units.count) { result[position] |= 1 }
            }
            index += advance
        }
        enum MathState { case none, inlineLatex, blockLatex, inlineDollar, blockDollar }
        var state = MathState.none
        index = 0
        while index < units.count {
            let unit = at(index), next = at(index + 1)
            var advance = 1
            if unit == 92, next == 36 { advance = 2 }
            else if unit == 92, next == 91, state == .none { state = .blockLatex; advance = 2 }
            else if unit == 92, next == 93, state == .blockLatex { state = .none; advance = 2 }
            else if unit == 92, next == 40, state == .none { state = .inlineLatex; advance = 2 }
            else if unit == 92, next == 41, state == .inlineLatex { state = .none; advance = 2 }
            else if unit == 36, state != .inlineLatex, state != .blockLatex {
                if next == 36 { state = state == .blockDollar ? .none : .blockDollar; advance = 2 }
                else if state != .blockDollar { state = state == .inlineDollar ? .none : .inlineDollar }
            }
            if state != .none {
                for position in (index + 1) ... min(index + advance, units.count) { result[position] |= 2 }
            }
            index += advance
        }
        return result
    }
    var count: Int { units.count }
    subscript(_ index: Int) -> UInt16 { units.indices.contains(index) ? units[index] : 0 }
    func slice(_ start: Int, _ end: Int? = nil) -> String {
        String(decoding: units[max(0, min(start, count)) ..< max(0, min(end ?? count, count))], as: UTF16.self)
    }
    func triple(_ index: Int) -> Bool { self[index] == 96 && self[index + 1] == 96 && self[index + 2] == 96 }
    func first(_ needle: String, from start: Int = 0) -> Int? {
        let range = (source as NSString).range(of: needle, options: .literal, range: NSRange(location: max(0, start), length: max(0, count - start)))
        return range.location == NSNotFound ? nil : range.location
    }
    func last(_ needle: String) -> Int? {
        let range = (source as NSString).range(of: needle, options: [.backwards, .literal])
        return range.location == NSNotFound ? nil : range.location
    }
}

extension Remend {
    /// JavaScript searches code units, including delimiters inside a Swift grapheme cluster.
    static func endsWith(_ source: String, _ suffix: String) -> Bool {
        source.utf16.suffix(suffix.utf16.count).elementsEqual(suffix.utf16)
    }
    static func contains(_ source: String, _ needle: String) -> Bool {
        (source as NSString).range(of: needle, options: .literal).location != NSNotFound
    }

    struct Match {
        let index: Int
        let range: NSRange
        let groups: [String]
        subscript(_ index: Int) -> String { groups[index] }
    }
    // ECMAScript \s includes FEFF; use its exact set instead of the Foundation whitespace set.
    static let whitespace = #"[\u0009-\u000D\u0020\u00A0\u1680\u2000-\u200A\u2028\u2029\u202F\u205F\u3000\uFEFF]"#
    static func expression(_ pattern: String, multiline: Bool = false) -> NSRegularExpression? {
        // Non-multiline JS $ matches only the actual end; ICU $ also accepts a final line terminator.
        let anchored = multiline ? pattern.replacingOccurrences(of: "^", with: #"(?:\A|(?<=[\r\n\u2028\u2029]))"#) : pattern.replacingOccurrences(of: "$", with: #"\z"#)
        return try? NSRegularExpression(pattern: anchored.replacingOccurrences(of: #"\s"#, with: whitespace).replacingOccurrences(of: #"\d"#, with: "[0-9]"), options: [])
    }
    static func matches(_ pattern: String, _ source: String, multiline: Bool = false) -> [Match] {
        guard let regex = expression(pattern, multiline: multiline) else { return [] }
        let text = source as NSString
        return regex.matches(in: source, range: NSRange(location: 0, length: text.length)).map { match in
            Match(index: match.range.location, range: match.range, groups: (0 ..< match.numberOfRanges).map { index in
                let range = match.range(at: index)
                return range.location == NSNotFound ? "" : text.substring(with: range)
            })
        }
    }
    static func match(_ pattern: String, _ source: String) -> Match? { matches(pattern, source).first }
    static func test(_ pattern: String, _ source: String) -> Bool { match(pattern, source) != nil }
    static func replacing(_ pattern: String, _ source: String, multiline: Bool = false, _ body: (Match) -> String) -> String {
        let input = source as NSString
        var result = "", cursor = 0
        result.reserveCapacity(source.utf8.count)
        // Append pieces in order instead of repeatedly moving a mutable UTF-16 buffer tail.
        for item in matches(pattern, source, multiline: multiline) {
            result += input.substring(with: NSRange(location: cursor, length: item.range.location - cursor))
            result += body(item)
            cursor = item.range.location + item.range.length
        }
        result += input.substring(from: cursor)
        return result
    }
    static func trimEnd(_ source: String) -> String { replacing(#"\s+$"#, source) { _ in "" } }
    static func trim(_ source: String) -> String { replacing(#"^\s+|\s+$"#, source) { _ in "" } }
    static func word(_ unit: UInt16) -> Bool {
        if (48 ... 57).contains(unit) || (65 ... 90).contains(unit) || (97 ... 122).contains(unit) || unit == 95 { return true }
        if unit < 128 || (0xD800 ... 0xDFFF).contains(unit) { return false }
        return test(#"[\p{L}\p{N}_]"#, String(decoding: [unit], as: UTF16.self))
    }
    static func space(_ unit: UInt16) -> Bool { unit == 32 || unit == 9 || unit == 10 }
    static func onlyMarkers(_ source: String) -> Bool { test(#"^[\s_~*`]*$"#, source) }

    static func withinCode(_ text: RemendText, _ position: Int) -> Bool { text.withinCode(position) }
    static func withinClosedInlineCode(_ text: RemendText, _ position: Int) -> Bool {
        var inline = false, fence = false, opening = -1, index = 0
        while index < text.count {
            if text[index] == 92, text[index + 1] == 96 { index += 2; continue }
            if text.triple(index) { fence.toggle(); index += 3; continue }
            if !fence, text[index] == 96 {
                if inline {
                    if opening < position, position < index { return true }
                    inline = false; opening = -1
                } else { inline = true; opening = index }
            }
            index += 1
        }
        return false
    }
    static func withinMath(_ text: RemendText, _ position: Int) -> Bool { text.withinMath(position) }
    static func withinURL(_ text: RemendText, _ position: Int) -> Bool {
        guard position > 0 else { return false }
        for index in stride(from: position - 1, through: 0, by: -1) {
            if text[index] == 41 || text[index] == 10 { return false }
            if text[index] == 40 {
                guard text[index - 1] == 93 else { return false }
                for end in position ..< text.count {
                    if text[end] == 41 { return true }
                    if text[end] == 10 { return false }
                }
                return false
            }
        }
        return false
    }
    static func withinHTML(_ text: RemendText, _ position: Int) -> Bool {
        guard position > 0 else { return false }
        for index in stride(from: position - 1, through: 0, by: -1) {
            if text[index] == 62 || text[index] == 10 { return false }
            if text[index] == 60 { return (65 ... 90).contains(text[index + 1]) || (97 ... 122).contains(text[index + 1]) || text[index + 1] == 47 }
        }
        return false
    }
    static func horizontalRule(_ text: RemendText, _ position: Int, _ marker: UInt16) -> Bool {
        var start = position, end = position
        while start > 0, text[start - 1] != 10 { start -= 1 }
        while end < text.count, text[end] != 10 { end += 1 }
        var count = 0
        for index in start ..< end {
            if text[index] == marker { count += 1 }
            else if text[index] != 32, text[index] != 9 { return false }
        }
        return count >= 3
    }
    static func closingBracket(_ text: RemendText, _ start: Int) -> Int? {
        var depth = 1
        for index in (start + 1) ..< text.count {
            if text[index] == 91 { depth += 1 }
            else if text[index] == 93 { depth -= 1; if depth == 0 { return index } }
        }
        return nil
    }
    static func openingBracket(_ text: RemendText, _ end: Int) -> Int? {
        guard end > 0 else { return nil }
        var depth = 1
        for index in stride(from: end - 1, through: 0, by: -1) {
            if text[index] == 93 { depth += 1 }
            else if text[index] == 91 { depth -= 1; if depth == 0 { return index } }
        }
        return nil
    }
}
