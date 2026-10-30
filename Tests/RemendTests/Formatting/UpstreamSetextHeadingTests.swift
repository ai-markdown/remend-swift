// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamSetextHeadingTests {

    // setext heading handling — setext-heading.test.ts:5
    @Test("should prevent partial list items from being interpreted as setext headings")
    func test001() throws {
        // The exact issue reported - single dash after text
        let text = "here is a list\n-"
        let result = (try remend(text))
        // Should add a zero-width space to break the setext heading pattern
        #expect(result.utf16.elementsEqual("here is a list\n-\u{200B}".utf16))
    }

    // setext heading handling — setext-heading.test.ts:13
    @Test("should handle double dash that could be setext heading")
    func test002() throws {
        let text = "Some text\n--"
        let result = (try remend(text))
        #expect(result.utf16.elementsEqual("Some text\n--\u{200B}".utf16))
    }

    // setext heading handling — setext-heading.test.ts:19
    @Test("should handle single equals that could be setext heading")
    func test003() throws {
        let text = "Some text\n="
        let result = (try remend(text))
        #expect(result.utf16.elementsEqual("Some text\n=\u{200B}".utf16))
    }

    // setext heading handling — setext-heading.test.ts:25
    @Test("should handle double equals that could be setext heading")
    func test004() throws {
        let text = "Some text\n=="
        let result = (try remend(text))
        #expect(result.utf16.elementsEqual("Some text\n==\u{200B}".utf16))
    }

    // setext heading handling — setext-heading.test.ts:31
    @Test("should NOT modify valid horizontal rules with three dashes")
    func test005() throws {
        let text = "Some text\n---"
        let result = (try remend(text))
        // Three dashes is a valid horizontal rule, don't modify
        #expect(result.utf16.elementsEqual("Some text\n---".utf16))
    }

    // setext heading handling — setext-heading.test.ts:38
    @Test("should NOT modify valid setext headings with three equals")
    func test006() throws {
        let text = "Heading\n==="
        let result = (try remend(text))
        // Three equals is a valid setext heading, don't modify
        #expect(result.utf16.elementsEqual("Heading\n===".utf16))
    }

    // setext heading handling — setext-heading.test.ts:45
    @Test("should NOT modify when there's no previous content")
    func test007() throws {
        // No previous line means it can't be a setext heading
        let text = "-"
        let result = (try remend(text))
        #expect(result.utf16.elementsEqual("-".utf16))
    }

    // setext heading handling — setext-heading.test.ts:52
    @Test("should NOT modify when previous line is empty")
    func test008() throws {
        let text = "\n-"
        let result = (try remend(text))
        #expect(result.utf16.elementsEqual("\n-".utf16))
    }

    // setext heading handling — setext-heading.test.ts:58
    @Test("should handle the streaming list scenario")
    func test009() throws {
        // Simulate streaming where list items come in one by one
        let scenarios = [
            (input: "here is a list\n-", expected: "here is a list\n-\u{200B}"),
            (input: "here is a list\n- ", expected: "here is a list\n-\u{200B}"),
            (input: "here is a list\n- list item 1", expected: "here is a list\n- list item 1"),
        ]
        for (input, expected) in scenarios {
            #expect((try remend(input)).utf16.elementsEqual(expected.utf16))
        }
    }

    // setext heading handling — setext-heading.test.ts:74
    @Test("should handle multiple lines with potential setext heading at end")
    func test010() throws {
        let text = "Line 1\nLine 2\nLine 3\n-"
        let result = (try remend(text))
        #expect(result.utf16.elementsEqual("Line 1\nLine 2\nLine 3\n-\u{200B}".utf16))
    }

    // setext heading handling — setext-heading.test.ts:80
    @Test("should handle text with whitespace before dash")
    func test011() throws {
        let text = "Some text\n  -"
        let result = (try remend(text))
        // Even with leading whitespace, it could be interpreted as setext heading
        #expect(result.utf16.elementsEqual("Some text\n  -\u{200B}".utf16))
    }

    // setext heading handling — setext-heading.test.ts:87
    @Test("should NOT modify complete list items")
    func test012() throws {
        let text = "Some text\n- Item 1\n- Item 2"
        let result = (try remend(text))
        #expect(result.utf16.elementsEqual(text.utf16))
    }

    // setext heading handling — setext-heading.test.ts:93
    @Test("should NOT modify when last line has other characters")
    func test013() throws {
        let text = "Some text\n-x"
        let result = (try remend(text))
        // Not a setext heading pattern
        #expect(result.utf16.elementsEqual(text.utf16))
    }

    // setext heading handling — setext-heading.test.ts:100
    @Test("should handle four or more dashes (horizontal rule)")
    func test014() throws {
        let text = "Some text\n----"
        let result = (try remend(text))
        // Four dashes is a horizontal rule, don't modify
        #expect(result.utf16.elementsEqual(text.utf16))
    }

    // setext heading handling — setext-heading.test.ts:107
    @Test("should handle mixed whitespace and dashes")
    func test015() throws {
        let text = "Some text\n- "
        let result = (try remend(text))
        // Trailing single space is removed, then zero-width joiner is added to prevent setext heading interpretation
        #expect(result.utf16.elementsEqual("Some text\n-\u{200B}".utf16))
    }

    // setext heading handling — setext-heading.test.ts:114
    @Test("should handle the original issue example precisely")
    func test016() throws {
        // Original issue: "here is a list\n-" gets interpreted as heading
        let streaming1 = (try remend("here is a list"))
        #expect(streaming1.utf16.elementsEqual("here is a list".utf16))
        let streaming2 = (try remend("here is a list\n"))
        #expect(streaming2.utf16.elementsEqual("here is a list\n".utf16))
        let streaming3 = (try remend("here is a list\n-"))
        // This should add a zero-width space to prevent setext heading
        #expect(streaming3.utf16.elementsEqual("here is a list\n-\u{200B}".utf16))
        let streaming4 = (try remend("here is a list\n- list item 1"))
        #expect(streaming4.utf16.elementsEqual("here is a list\n- list item 1".utf16))
    }

    // setext heading handling — setext-heading.test.ts:130
    @Test("should handle setext heading with equals signs during streaming")
    func test017() throws {
        let streaming1 = (try remend("This is a title\n="))
        #expect(streaming1.utf16.elementsEqual("This is a title\n=\u{200B}".utf16))
        let streaming2 = (try remend("This is a title\n=="))
        #expect(streaming2.utf16.elementsEqual("This is a title\n==\u{200B}".utf16))
        let streaming3 = (try remend("This is a title\n==="))
        // Three equals is valid setext heading (H1), don't modify
        #expect(streaming3.utf16.elementsEqual("This is a title\n===".utf16))
    }

    // setext heading handling — setext-heading.test.ts:142
    @Test("should not interfere with other markdown syntax")
    func test018() throws {
        // Make sure we don't break other markdown features
        let text1 = "**bold text**\n-"
        #expect((try remend(text1)).utf16.elementsEqual("**bold text**\n-\u{200B}".utf16))
        let text2 = "*italic text*\n-"
        #expect((try remend(text2)).utf16.elementsEqual("*italic text*\n-\u{200B}".utf16))
        let text3 = "`code`\n-"
        #expect((try remend(text3)).utf16.elementsEqual("`code`\n-\u{200B}".utf16))
    }

    // setext heading handling — setext-heading.test.ts:154
    @Test("should handle multiple potential setext headings in sequence")
    func test019() throws {
        // Only the last line matters for setext heading detection
        let text = "Text 1\n-\nText 2\n-"
        let result = (try remend(text))
        // Only the final "-" should be modified
        #expect(result.utf16.elementsEqual("Text 1\n-\nText 2\n-\u{200B}".utf16))
    }
}
