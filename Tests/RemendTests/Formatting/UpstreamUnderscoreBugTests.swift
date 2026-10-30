// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamUnderscoreBugTests {

    private let HELLO_WORLD_UNDERSCORE_REGEX = "hello_world_"

    private let TRAILING_UNDERSCORE_REGEX = "_$"
    // word-internal underscores > underscores as word separators — underscore-bug.test.tsx:9
    @Test("should handle single underscore between words")
    func test001() throws {
        let input = "hello_world"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("hello_world".utf16))
    }

    // word-internal underscores > underscores as word separators — underscore-bug.test.tsx:15
    @Test("should handle multiple underscores between words")
    func test002() throws {
        let input = "hello_world_test"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("hello_world_test".utf16))
    }

    // word-internal underscores > underscores as word separators — underscore-bug.test.tsx:21
    @Test("should handle CONSTANT_CASE")
    func test003() throws {
        let input = "MAX_VALUE"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("MAX_VALUE".utf16))
    }

    // word-internal underscores > underscores as word separators — underscore-bug.test.tsx:27
    @Test("should handle multiple snake_case words in text")
    func test004() throws {
        let input = "The user_name and user_email are required"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("The user_name and user_email are required".utf16))
    }

    // word-internal underscores > underscores as word separators — underscore-bug.test.tsx:33
    @Test("should handle underscore in URLs")
    func test005() throws {
        let input = "Visit https://example.com/path_with_underscore"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("Visit https://example.com/path_with_underscore".utf16))
    }

    // word-internal underscores > underscores as word separators — underscore-bug.test.tsx:39
    @Test("should handle numbers with underscores")
    func test006() throws {
        let input = "The value is 1_000_000"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("The value is 1_000_000".utf16))
    }

    // word-internal underscores > incomplete italic formatting — underscore-bug.test.tsx:47
    @Test("should complete italic at word boundary")
    func test007() throws {
        let input = "_italic text"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("_italic text_".utf16))
    }

    // word-internal underscores > incomplete italic formatting — underscore-bug.test.tsx:53
    @Test("should complete italic with punctuation")
    func test008() throws {
        let input = "This is _italic"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("This is _italic_".utf16))
    }

    // word-internal underscores > incomplete italic formatting — underscore-bug.test.tsx:59
    @Test("should complete italic before newline")
    func test009() throws {
        let input = "_italic\n"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("_italic_\n".utf16))
    }

    // word-internal underscores > edge cases — underscore-bug.test.tsx:67
    @Test("should handle underscore at end of word (ambiguous case)")
    func test010() throws {
        let input = "word_"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("word_".utf16))
    }

    // word-internal underscores > edge cases — underscore-bug.test.tsx:73
    @Test("should handle leading underscore in identifier")
    func test011() throws {
        let input = "_privateVariable"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("_privateVariable_".utf16))
    }

    // word-internal underscores > edge cases — underscore-bug.test.tsx:79
    @Test("should handle code with underscores in markdown")
    func test012() throws {
        let input = "Use `variable_name` in your code"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("Use `variable_name` in your code".utf16))
    }

    // word-internal underscores > edge cases — underscore-bug.test.tsx:85
    @Test("should handle mixed snake_case and italic")
    func test013() throws {
        let input = "The variable_name is _important"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("The variable_name is _important_".utf16))
    }

    // word-internal underscores > edge cases — underscore-bug.test.tsx:91
    @Test("should not modify complete italic pairs")
    func test014() throws {
        let input = "_complete italic_ and some_other_text"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("_complete italic_ and some_other_text".utf16))
    }

    // word-internal underscores > edge cases — underscore-bug.test.tsx:97
    @Test("should handle underscore in code blocks")
    func test015() throws {
        let input = "```\nfunction_name()\n```"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("```\nfunction_name()\n```".utf16))
    }

    // word-internal underscores > edge cases — underscore-bug.test.tsx:103
    @Test("should handle HTML attributes with underscores")
    func test016() throws {
        let input = "<div data_attribute=\"value\">"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("<div data_attribute=\"value\">".utf16))
    }

    // word-internal underscores > real-world scenarios — underscore-bug.test.tsx:111
    @Test("should handle Python-style names")
    func test017() throws {
        let input = "__init__ and __main__ are special"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("__init__ and __main__ are special".utf16))
    }

    // word-internal underscores > real-world scenarios — underscore-bug.test.tsx:117
    @Test("should handle markdown in sentences with snake_case")
    func test018() throws {
        let input = "The user_id field stores the _unique identifier"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("The user_id field stores the _unique identifier_".utf16))
    }

    // word-internal underscores > real-world scenarios — underscore-bug.test.tsx:123
    @Test("should handle the original bug report case")
    func test019() throws {
        let input = "hello_world\n\n<a href=\"example_link\"/>"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual(input.utf16))
        #expect((result).range(of: HELLO_WORLD_UNDERSCORE_REGEX, options: .regularExpression) == nil)
        #expect((result).range(of: TRAILING_UNDERSCORE_REGEX, options: .regularExpression) == nil)
    }
}
