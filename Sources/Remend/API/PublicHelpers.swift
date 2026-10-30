/// Whether the input contains a Unicode letter, number, or underscore, matching the upstream helper.
public func isWordChar(_ character: String) -> Bool {
    guard let first = character.utf16.first else { return false }
    if (48 ... 57).contains(first) || (65 ... 90).contains(first) || (97 ... 122).contains(first) || first == 95 { return true }
    return Remend.test(#"[\p{L}\p{N}_]"#, character)
}

/// Whether a UTF-16 position is within a triple-backtick block, matching upstream's exported helper.
/// This utility intentionally differs from the internal scanner: it does not include inline code or process escaped backticks.
public func isWithinCodeBlock(_ source: String, position: Int) -> Bool {
    let text = RemendText(source)
    var fenced = false, index = 0
    while index < min(position, text.count) {
        if text.triple(index) { fenced.toggle(); index += 3 }
        else { index += 1 }
    }
    return fenced
}

/// Whether a UTF-16 position is within dollar or LaTeX-bracket math delimiters.
public func isWithinMathBlock(_ source: String, position: Int) -> Bool {
    Remend.withinMath(RemendText(source), position)
}

/// Whether a UTF-16 position is inside a Markdown link/image URL with a closing parenthesis before a newline.
public func isWithinLinkOrImageUrl(_ source: String, position: Int) -> Bool {
    let text = RemendText(source)
    guard position >= 0, position <= text.count else { return false }
    return Remend.withinURL(text, position)
}
