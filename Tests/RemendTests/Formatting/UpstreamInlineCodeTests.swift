// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamInlineCodeTests {

    // inline code formatting (`) — inline-code.test.ts:5
    @Test("should complete incomplete inline code")
    func test001() throws {
        #expect((try remend("Text with `code")).utf16.elementsEqual("Text with `code`".utf16))
        #expect((try remend("`incomplete")).utf16.elementsEqual("`incomplete`".utf16))
    }

    // inline code formatting (`) — inline-code.test.ts:10
    @Test("should keep complete inline code unchanged")
    func test002() throws {
        let text = "Text with `inline code`"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // inline code formatting (`) — inline-code.test.ts:15
    @Test("should handle multiple inline code sections")
    func test003() throws {
        let text = "`code1` and `code2`"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // inline code formatting (`) — inline-code.test.ts:20
    @Test("should not complete backticks inside code blocks")
    func test004() throws {
        let text = "```\ncode block with `backtick\n```"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // inline code formatting (`) — inline-code.test.ts:25
    @Test("should handle incomplete code blocks correctly")
    func test005() throws {
        let text = "```javascript\nconst x = `template"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // inline code formatting (`) — inline-code.test.ts:30
    @Test("should handle inline triple backticks correctly")
    func test006() throws {
        let text = "```python print(\"Hello, Sunnyvale!\")```"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // inline code formatting (`) — inline-code.test.ts:35
    @Test("should handle incomplete inline triple backticks")
    func test007() throws {
        let text = "```python print(\"Hello, Sunnyvale!\")``"
        #expect((try remend(text)).utf16.elementsEqual("```python print(\"Hello, Sunnyvale!\")```".utf16))
    }

    // inline code formatting (`) — inline-code.test.ts:40
    @Test("should not modify text with complete triple backticks at the end")
    func test008() throws {
        let text = "```code```"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
        let text2 = "```code```\n"
        #expect((try remend(text2)).utf16.elementsEqual(text2.utf16))
        // Even number of triple backticks with newlines are complete
        let text3 = "```\ncode\n```"
        #expect((try remend(text3)).utf16.elementsEqual(text3.utf16))
        // Test the special case (lines 41-47) where text ends with ``` and has even count
        // This case is for inline triple backticks without newlines
        let text4 = "``````"
        #expect((try remend(text4)).utf16.elementsEqual(text4.utf16))
        let text5 = "text``````"
        #expect((try remend(text5)).utf16.elementsEqual(text5.utf16))
    }

    // inline code formatting (`) — inline-code.test.ts:60
    @Test("should handle code block with incomplete inline code after (#302)")
    func test009() throws {
        #expect((try remend("```\nblock\n```\n`inline")).utf16.elementsEqual("```\nblock\n```\n`inline`".utf16))
    }

    // escaped backticks in inline code — inline-code.test.ts:68
    @Test("should not treat escaped backticks as code delimiters")
    func test010() throws {
        // \` is not a real backtick delimiter, so **bold should still be completed
        #expect((try remend("\\`not code\\` **bold")).utf16.elementsEqual("\\`not code\\` **bold**".utf16))
    }

    // escaped backticks in inline code — inline-code.test.ts:73
    @Test("should complete emphasis when only escaped backticks are present")
    func test011() throws {
        #expect((try remend("\\` *italic")).utf16.elementsEqual("\\` *italic*".utf16))
    }

    // emphasis markers inside inline code spans should not leak — inline-code.test.ts:79
    @Test("should not complete bold/italic/strikethrough if they are inside inline code")
    func test012() throws {
        #expect((try remend("`**bold`")).utf16.elementsEqual("`**bold`".utf16))
        #expect((try remend("`*italic`")).utf16.elementsEqual("`*italic`".utf16))
        #expect((try remend("`~~strikethrough`")).utf16.elementsEqual("`~~strikethrough`".utf16))
    }

    // emphasis markers inside inline code spans should not leak — inline-code.test.ts:85
    @Test("should still complete emphasis markers outside inline code")
    func test013() throws {
        #expect((try remend("**bold")).utf16.elementsEqual("**bold**".utf16))
        #expect((try remend("*italic")).utf16.elementsEqual("*italic*".utf16))
        #expect((try remend("~~strike")).utf16.elementsEqual("~~strike~~".utf16))
    }

    // emphasis markers inside inline code spans should not leak — inline-code.test.ts:91
    @Test("should complete emphasis after a closed inline code span")
    func test014() throws {
        #expect((try remend("`code` **bold")).utf16.elementsEqual("`code` **bold**".utf16))
    }
}
