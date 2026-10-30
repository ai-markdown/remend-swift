// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamMixedFormattingTests {

    // mixed formatting — mixed-formatting.test.ts:5
    @Test("should handle multiple formatting types")
    func test001() throws {
        let text = "**bold** and *italic* and `code` and ~~strike~~"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:10
    @Test("should complete multiple incomplete formats")
    func test002() throws {
        #expect((try remend("**bold and *italic")).utf16.elementsEqual("**bold and *italic*".utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:14
    @Test("should handle nested formatting")
    func test003() throws {
        let text = "**bold with *italic* inside**"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:19
    @Test("should prioritize link/image preservation over formatting completion")
    func test004() throws {
        #expect((try remend("Text with [link and **bold")).utf16.elementsEqual("Text with [link and **bold](streamdown:incomplete-link)".utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:25
    @Test("should handle complex real-world markdown")
    func test005() throws {
        let text = "# Heading\n\n**Bold text** with *italic* and `code`.\n\n- List item\n- Another item with ~~strike~~"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:31
    @Test("should handle bold inside italic")
    func test006() throws {
        #expect((try remend("*italic with **bold")).utf16.elementsEqual("*italic with **bold***".utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:35
    @Test("should handle code inside bold")
    func test007() throws {
        // Bold gets closed first, then code
        #expect((try remend("**bold with `code")).utf16.elementsEqual("**bold with `code**`".utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:40
    @Test("should handle strikethrough with other formatting")
    func test008() throws {
        // Both formats get closed
        #expect((try remend("~~strike with **bold")).utf16.elementsEqual("~~strike with **bold**~~".utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:45
    @Test("should handle dollar sign inside other formatting")
    func test009() throws {
        // Bold gets closed, dollar sign stays as-is (likely currency)
        #expect((try remend("**bold with $x^2")).utf16.elementsEqual("**bold with $x^2**".utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:50
    @Test("should handle deeply nested incomplete formatting")
    func test010() throws {
        // Formats are closed in the order they're processed.
        // The ~~ isn't closed because it ends up inside the completed inline code span (`code ~~strike`),
        // so remend correctly leaves it alone.
        #expect((try remend("**bold *italic `code ~~strike")).utf16.elementsEqual("**bold *italic `code ~~strike*`".utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:59
    @Test("should preserve complete nested formatting")
    func test011() throws {
        let text = "**bold *italic* text** and `code`"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:64
    @Test("should handle mixed bold-italic formatting (#265)")
    func test012() throws {
        #expect((try remend("**bold and *bold-italic***")).utf16.elementsEqual("**bold and *bold-italic***".utf16))
    }

    // mixed formatting — mixed-formatting.test.ts:70
    @Test("should close nested underscore italic before bold (#302)")
    func test013() throws {
        // When _ opens after **, the _ should close before ** (proper nesting)
        #expect((try remend("combined **_bold and italic")).utf16.elementsEqual("combined **_bold and italic_**".utf16))
        #expect((try remend("**_text")).utf16.elementsEqual("**_text_**".utf16))
        // When _ opens before **, the ** should close first (it's nested inside)
        #expect((try remend("_italic and **bold")).utf16.elementsEqual("_italic and **bold**_".utf16))
    }
}
