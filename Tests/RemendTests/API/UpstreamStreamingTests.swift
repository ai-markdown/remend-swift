// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamStreamingTests {

    // chunked streaming scenarios — streaming.test.ts:5
    @Test("should handle nested formatting cut mid-stream")
    func test001() throws {
        #expect((try remend("This is **bold with *ital")).utf16.elementsEqual("This is **bold with *ital*".utf16))
        // When underscore opens after bold, underscore should close before bold (proper nesting)
        #expect((try remend("**bold _und")).utf16.elementsEqual("**bold _und_**".utf16))
    }

    // chunked streaming scenarios — streaming.test.ts:13
    @Test("should handle headings with incomplete formatting")
    func test002() throws {
        #expect((try remend("# Main Title\n## Subtitle with **emph")).utf16.elementsEqual("# Main Title\n## Subtitle with **emph**".utf16))
    }

    // chunked streaming scenarios — streaming.test.ts:19
    @Test("should handle blockquotes with incomplete formatting")
    func test003() throws {
        #expect((try remend("> Quote with **bold")).utf16.elementsEqual("> Quote with **bold**".utf16))
    }

    // chunked streaming scenarios — streaming.test.ts:23
    @Test("should handle tables with incomplete formatting")
    func test004() throws {
        #expect((try remend("| Col1 | Col2 |\n|------|------|\n| **dat")).utf16.elementsEqual("| Col1 | Col2 |\n|------|------|\n| **dat**".utf16))
    }

    // chunked streaming scenarios — streaming.test.ts:29
    @Test("should handle complex nested structures from chunks")
    func test005() throws {
        // Backticks spanning multiple lines need special handling
        #expect((try remend("1. First item\n   - Nested with `code\n2. Second")).utf16.elementsEqual("1. First item\n   - Nested with `code\n2. Second`".utf16))
    }

    // chunked streaming scenarios — streaming.test.ts:36
    @Test("should handle multiple incomplete formats in one chunk")
    func test006() throws {
        // Formats are closed in order they're processed
        #expect((try remend("Text **bold `code")).utf16.elementsEqual("Text **bold `code**`".utf16))
    }

    // real-world streaming chunks — streaming.test.ts:43
    @Test("should handle typical GPT response chunks")
    func test007() throws {
        let chunks = [
            "Here is",
            "Here is a **bold",
            "Here is a **bold statement",
            "Here is a **bold statement** about",
            "Here is a **bold statement** about `code",
            "Here is a **bold statement** about `code`.",
        ]
        #expect((try remend(chunks[0])).utf16.elementsEqual("Here is".utf16))
        #expect((try remend(chunks[1])).utf16.elementsEqual("Here is a **bold**".utf16))
        #expect((try remend(chunks[2])).utf16.elementsEqual("Here is a **bold statement**".utf16))
        #expect((try remend(chunks[3])).utf16.elementsEqual("Here is a **bold statement** about".utf16))
        #expect((try remend(chunks[4])).utf16.elementsEqual("Here is a **bold statement** about `code`".utf16))
        #expect((try remend(chunks[5])).utf16.elementsEqual(chunks[5].utf16))
    }

    // real-world streaming chunks — streaming.test.ts:61
    @Test("should handle code explanation chunks")
    func test008() throws {
        let chunks = [
            "To use this function",
            "To use this function, call `getData(",
            "To use this function, call `getData()` with",
        ]
        #expect((try remend(chunks[0])).utf16.elementsEqual(chunks[0].utf16))
        #expect((try remend(chunks[1])).utf16.elementsEqual("To use this function, call `getData(`".utf16))
        #expect((try remend(chunks[2])).utf16.elementsEqual(chunks[2].utf16))
    }
}
