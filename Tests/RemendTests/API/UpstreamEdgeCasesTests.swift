// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamEdgeCasesTests {

    // edge cases — edge-cases.test.ts:5
    @Test("should handle text ending with formatting characters")
    func test001() throws {
        #expect((try remend("Text ending with *")).utf16.elementsEqual("Text ending with *".utf16))
        #expect((try remend("Text ending with **")).utf16.elementsEqual("Text ending with **".utf16))
    }

    // edge cases — edge-cases.test.ts:10
    @Test("should handle empty formatting markers")
    func test002() throws {
        #expect((try remend("****")).utf16.elementsEqual("****".utf16))
        #expect((try remend("``")).utf16.elementsEqual("``".utf16))
    }

    // edge cases — edge-cases.test.ts:15
    @Test("should handle standalone emphasis characters (#90)")
    func test003() throws {
        // Standalone markers should not be auto-closed
        #expect((try remend("**")).utf16.elementsEqual("**".utf16))
        #expect((try remend("__")).utf16.elementsEqual("__".utf16))
        #expect((try remend("***")).utf16.elementsEqual("***".utf16))
        #expect((try remend("*")).utf16.elementsEqual("*".utf16))
        #expect((try remend("_")).utf16.elementsEqual("_".utf16))
        #expect((try remend("~~")).utf16.elementsEqual("~~".utf16))
        #expect((try remend("`")).utf16.elementsEqual("`".utf16))
        // Multiple standalone markers on the same line
        #expect((try remend("** __")).utf16.elementsEqual("** __".utf16))
        #expect((try remend("\n** __\n")).utf16.elementsEqual("\n** __\n".utf16))
        #expect((try remend("* _ ~~ `")).utf16.elementsEqual("* _ ~~ `".utf16))
        // Standalone markers with only whitespace
        #expect((try remend("** ")).utf16.elementsEqual("**".utf16))
        #expect((try remend(" **")).utf16.elementsEqual(" **".utf16))
        #expect((try remend("  **  ")).utf16.elementsEqual("  **  ".utf16))
        // But markers with actual content should still be closed
        #expect((try remend("**text")).utf16.elementsEqual("**text**".utf16))
        #expect((try remend("__text")).utf16.elementsEqual("__text__".utf16))
        #expect((try remend("*text")).utf16.elementsEqual("*text*".utf16))
        #expect((try remend("_text")).utf16.elementsEqual("_text_".utf16))
        #expect((try remend("~~text")).utf16.elementsEqual("~~text~~".utf16))
        #expect((try remend("`text")).utf16.elementsEqual("`text`".utf16))
    }

    // edge cases — edge-cases.test.ts:44
    @Test("should handle very long text")
    func test004() throws {
        let longText = (String(repeating: "a", count: 10000) + " **bold")
        let expected = (String(repeating: "a", count: 10000) + " **bold**")
        #expect((try remend(longText)).utf16.elementsEqual(expected.utf16))
    }

    // edge cases — edge-cases.test.ts:50
    @Test("should handle text with only formatting characters")
    func test005() throws {
        #expect((try remend("*")).utf16.elementsEqual("*".utf16))
        #expect((try remend("**")).utf16.elementsEqual("**".utf16))
        #expect((try remend("`")).utf16.elementsEqual("`".utf16))
    }

    // edge cases — edge-cases.test.ts:56
    @Test("should handle escaped characters")
    func test006() throws {
        let text = "Text with \\* escaped asterisk"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // edge cases — edge-cases.test.ts:61
    @Test("should handle markdown at very end of string")
    func test007() throws {
        #expect((try remend("text**")).utf16.elementsEqual("text**".utf16))
        #expect((try remend("text*")).utf16.elementsEqual("text*".utf16))
        #expect((try remend("text`")).utf16.elementsEqual("text`".utf16))
        #expect((try remend("text$")).utf16.elementsEqual("text$".utf16))
        #expect((try remend("text~~")).utf16.elementsEqual("text~~".utf16))
    }

    // edge cases — edge-cases.test.ts:69
    @Test("should handle whitespace before incomplete markdown")
    func test008() throws {
        #expect((try remend("text **bold")).utf16.elementsEqual("text **bold**".utf16))
        #expect((try remend("text\n**bold")).utf16.elementsEqual("text\n**bold**".utf16))
        #expect((try remend("text\t`code")).utf16.elementsEqual("text\t`code`".utf16))
    }

    // edge cases — edge-cases.test.ts:75
    @Test("should handle unicode characters in incomplete markdown")
    func test009() throws {
        #expect((try remend("**émoji 🎉")).utf16.elementsEqual("**émoji 🎉**".utf16))
        #expect((try remend("`código")).utf16.elementsEqual("`código`".utf16))
    }

    // edge cases — edge-cases.test.ts:80
    @Test("should handle HTML entities in incomplete markdown")
    func test010() throws {
        #expect((try remend("**&lt;tag&gt;")).utf16.elementsEqual("**&lt;tag&gt;**".utf16))
        #expect((try remend("`&amp;")).utf16.elementsEqual("`&amp;`".utf16))
    }

    // edge cases — edge-cases.test.ts:85
    @Test("should not treat asterisks flanked by whitespace as emphasis markers (#370)")
    func test011() throws {
        #expect((try remend("3 + 2 - 5 * 0 = ?")).utf16.elementsEqual("3 + 2 - 5 * 0 = ?".utf16))
        #expect((try remend("5 * 0")).utf16.elementsEqual("5 * 0".utf16))
        #expect((try remend("x * y")).utf16.elementsEqual("x * y".utf16))
        #expect((try remend("a * b = c")).utf16.elementsEqual("a * b = c".utf16))
        // Even count of space-flanked asterisks should also be fine
        #expect((try remend("2 * 3 * 4")).utf16.elementsEqual("2 * 3 * 4".utf16))
        // Mixed: space-flanked operator + real italic should still work
        #expect((try remend("5 * 0 and *italic")).utf16.elementsEqual("5 * 0 and *italic*".utf16))
    }
}
