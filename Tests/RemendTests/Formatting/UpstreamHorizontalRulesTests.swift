// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamHorizontalRulesTests {

    // horizontal rule handling — horizontal-rules.test.ts:5
    @Test("should preserve complete horizontal rules with hyphens")
    func test001() throws {
        #expect((try remend("---")).utf16.elementsEqual("---".utf16))
        #expect((try remend("----")).utf16.elementsEqual("----".utf16))
        #expect((try remend("-----")).utf16.elementsEqual("-----".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:11
    @Test("should preserve complete horizontal rules with asterisks")
    func test002() throws {
        #expect((try remend("***")).utf16.elementsEqual("***".utf16))
        #expect((try remend("****")).utf16.elementsEqual("****".utf16))
        #expect((try remend("*****")).utf16.elementsEqual("*****".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:17
    @Test("should preserve complete horizontal rules with underscores")
    func test003() throws {
        #expect((try remend("___")).utf16.elementsEqual("___".utf16))
        #expect((try remend("____")).utf16.elementsEqual("____".utf16))
        #expect((try remend("_____")).utf16.elementsEqual("_____".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:23
    @Test("should preserve horizontal rules with spaces")
    func test004() throws {
        #expect((try remend("- - -")).utf16.elementsEqual("- - -".utf16))
        #expect((try remend("* * *")).utf16.elementsEqual("* * *".utf16))
        #expect((try remend("_ _ _")).utf16.elementsEqual("_ _ _".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:29
    @Test("should preserve horizontal rules with mixed spacing")
    func test005() throws {
        #expect((try remend("-  -  -")).utf16.elementsEqual("-  -  -".utf16))
        #expect((try remend("*   *   *")).utf16.elementsEqual("*   *   *".utf16))
        #expect((try remend("_    _    _")).utf16.elementsEqual("_    _    _".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:35
    @Test("should not confuse horizontal rules with emphasis")
    func test006() throws {
        // *** on its own line should be recognized as a horizontal rule
        #expect((try remend("Text before\n***\nText after")).utf16.elementsEqual("Text before\n***\nText after".utf16))
        // Three underscores on own line = horizontal rule, not italic
        #expect((try remend("Text before\n___\nText after")).utf16.elementsEqual("Text before\n___\nText after".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:47
    @Test("should handle horizontal rules at the end of text")
    func test007() throws {
        #expect((try remend("Some text\n\n---")).utf16.elementsEqual("Some text\n\n---".utf16))
        #expect((try remend("Some text\n\n***")).utf16.elementsEqual("Some text\n\n***".utf16))
        #expect((try remend("Some text\n\n___")).utf16.elementsEqual("Some text\n\n___".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:53
    @Test("should handle horizontal rules at the start of text")
    func test008() throws {
        #expect((try remend("---\n\nSome text")).utf16.elementsEqual("---\n\nSome text".utf16))
        // *** on its own line should be recognized as a horizontal rule
        #expect((try remend("***\n\nSome text")).utf16.elementsEqual("***\n\nSome text".utf16))
        // ___ on its own line should be recognized as a horizontal rule
        #expect((try remend("___\n\nSome text")).utf16.elementsEqual("___\n\nSome text".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:61
    @Test("should handle multiple horizontal rules")
    func test009() throws {
        #expect((try remend("Section 1\n\n---\n\nSection 2\n\n---\n\nSection 3")).utf16.elementsEqual("Section 1\n\n---\n\nSection 2\n\n---\n\nSection 3".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:67
    @Test("should not confuse two asterisks with horizontal rule start")
    func test010() throws {
        // ** is bold, not a horizontal rule
        #expect((try remend("Text with **bold")).utf16.elementsEqual("Text with **bold**".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:72
    @Test("should not confuse two hyphens with horizontal rule")
    func test011() throws {
        // -- is not a valid horizontal rule (needs 3+)
        #expect((try remend("Text with --")).utf16.elementsEqual("Text with --".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:77
    @Test("should handle horizontal rules after lists")
    func test012() throws {
        let text = "- Item 1\n- Item 2\n\n---\n\nNew section"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:82
    @Test("should handle horizontal rules before headings")
    func test013() throws {
        let text = "---\n\n# Heading"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:87
    @Test("should handle partial horizontal rules during streaming")
    func test014() throws {
        // Two characters - not yet a valid horizontal rule
        #expect((try remend("--")).utf16.elementsEqual("--".utf16))
        #expect((try remend("**")).utf16.elementsEqual("**".utf16))
        #expect((try remend("__")).utf16.elementsEqual("__".utf16))
        // With context showing it's meant to be a rule
        #expect((try remend("Text\n\n--")).utf16.elementsEqual("Text\n\n--".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:97
    @Test("should not add closing markers to standalone asterisk sequences that could be rules")
    func test015() throws {
        // 4+ asterisks should not be completed as bold-italic
        #expect((try remend("****")).utf16.elementsEqual("****".utf16))
        #expect((try remend("*****")).utf16.elementsEqual("*****".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:103
    @Test("should handle horizontal rules with leading whitespace")
    func test016() throws {
        // Up to 3 spaces before a horizontal rule is valid
        #expect((try remend("   ---")).utf16.elementsEqual("   ---".utf16))
        #expect((try remend("  ***")).utf16.elementsEqual("  ***".utf16))
        #expect((try remend(" ___")).utf16.elementsEqual(" ___".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:110
    @Test("should handle horizontal rule-like patterns in text")
    func test017() throws {
        // Horizontal rules need to be on their own line
        // When --- appears inline, it's treated as text, not a horizontal rule
        #expect((try remend("This is not a --- horizontal rule")).utf16.elementsEqual("This is not a --- horizontal rule".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:118
    @Test("should not complete emphasis when asterisks form potential horizontal rule")
    func test018() throws {
        // Text ending with newline then *** should not add closing ***
        #expect((try remend("Text\n***")).utf16.elementsEqual("Text\n***".utf16))
    }

    // horizontal rule handling — horizontal-rules.test.ts:123
    @Test("should handle horizontal rules in complex markdown")
    func test019() throws {
        let text = "# Title\n\nSome content with **bold** text.\n\n---\n\n## Section 2\n\nMore content."
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }
}
