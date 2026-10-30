@testable import Remend
import Foundation
import Testing

/// A locked equivalent of the original tests' mutable arrays, captured by Swift @Sendable handlers.
private final class UpstreamHandlerTrace: @unchecked Sendable {
    private let lock = NSLock()
    private var values: [String] = []
    func append(_ value: String) { lock.withLock { values.append(value) } }
    var result: [String] { lock.withLock { values } }
}

/// Direct port of upstream custom-handlers.test.ts at remend@1.3.1 (8a2ac221).
struct UpstreamCustomHandlerTests {
    @Test("should execute custom handlers") func test001() throws {
        let handler = RemendHandler(name: "test") { $0.replacingOccurrences(of: "foo", with: "bar") }
        #expect((try remend("foo", options: .init(handlers: [handler]))).utf16.elementsEqual(("bar").utf16))
    }

    @Test("should execute custom handlers after built-in handlers by default") func test002() throws {
        let handler = RemendHandler(name: "test") { $0 + "!" }
        #expect((try remend("**bold", options: .init(handlers: [handler]))).utf16.elementsEqual(("**bold**!").utf16))
    }

    @Test("should respect custom handler priority") func test003() throws {
        let results = UpstreamHandlerTrace()
        let lowPriority = RemendHandler(name: "low", priority: 200) { text in results.append("low"); return text }
        let highPriority = RemendHandler(name: "high", priority: 5) { text in results.append("high"); return text }
        _ = try remend("test", options: .init(handlers: [lowPriority, highPriority]))
        #expect(results.result == ["high", "low"])
    }

    @Test("should allow custom handlers to run before built-ins") func test004() throws {
        let results = UpstreamHandlerTrace()
        let beforeSetext = RemendHandler(name: "beforeSetext", priority: -1) { text in results.append("custom"); return text }
        _ = try remend("test\n-", options: .init(handlers: [beforeSetext]))
        #expect(results.result[0] == "custom")
    }

    @Test("should handle multiple custom handlers") func test005() throws {
        let handler1 = RemendHandler(name: "replace-a") { $0.replacingOccurrences(of: "a", with: "b") }
        let handler2 = RemendHandler(name: "replace-b") { $0.replacingOccurrences(of: "b", with: "c") }
        #expect((try remend("aaa", options: .init(handlers: [handler1, handler2]))).utf16.elementsEqual(("ccc").utf16))
    }

    @Test("should handle custom handlers with same priority in order") func test006() throws {
        let results = UpstreamHandlerTrace()
        let first = RemendHandler(name: "first", priority: 100) { text in results.append("first"); return text }
        let second = RemendHandler(name: "second", priority: 100) { text in results.append("second"); return text }
        _ = try remend("test", options: .init(handlers: [first, second]))
        #expect(results.result == ["first", "second"])
    }

    @Test("should work with disabled built-in handlers") func test007() throws {
        let handler = RemendHandler(name: "test") { $0 + "!" }
        #expect((try remend("**bold", options: .init(bold: false, handlers: [handler]))).utf16.elementsEqual(("**bold!").utf16))
    }

    @Test("should work with no built-in handlers enabled") func test008() throws {
        let handler = RemendHandler(name: "uppercase") { $0.uppercased() }
        #expect((try remend("hello", options: .init(bold: false, boldItalic: false, handlers: [handler], images: false,
                                                    inlineCode: false, italic: false, katex: false, links: false,
                                                    setextHeadings: false, strikethrough: false))).utf16.elementsEqual(("HELLO").utf16))
    }

    @Test("should handle empty handlers array") func test009() throws {
        #expect((try remend("**bold", options: .init(handlers: []))).utf16.elementsEqual(("**bold**").utf16))
    }

    @Test("should detect position inside code block") func test010() throws {
        let text = "```\ncode\n```"
        #expect(isWithinCodeBlock(text, position: 5) == true)
    }

    @Test("should detect position outside code block") func test011() throws {
        let text = "before ```code``` after"
        #expect(isWithinCodeBlock(text, position: 2) == false)
    }

    @Test("should detect position inside block math") func test012() throws {
        let text = "$$x^2$$"
        #expect(isWithinMathBlock(text, position: 3) == true)
    }

    @Test("should detect position outside math") func test013() throws {
        let text = "before $x$ after"
        #expect(isWithinMathBlock(text, position: 14) == false)
    }

    @Test("should detect position inside link URL") func test014() throws {
        let text = "[text](http://example.com)"
        #expect(isWithinLinkOrImageUrl(text, position: 10) == true)
    }

    @Test("should detect position outside link") func test015() throws {
        let text = "before [text](url) after"
        #expect(isWithinLinkOrImageUrl(text, position: 2) == false)
    }

    @Test("should identify word characters") func test016() throws {
        #expect(isWordChar("a") == true)
        #expect(isWordChar("Z") == true)
        #expect(isWordChar("5") == true)
        #expect(isWordChar("_") == true)
    }

    @Test("should identify non-word characters") func test017() throws {
        #expect(isWordChar(" ") == false)
        #expect(isWordChar("*") == false)
        #expect(isWordChar("") == false)
    }

    @Test("should complete joke markers") func test018() throws {
        let jokeHandler = RemendHandler(name: "joke", priority: 80) { text in
            let match = Remend.match("<<<JOKE>>>([^<]*)$", text)
            if match != nil, !Remend.endsWith(text, "<<</JOKE>>>") { return text + "<<</JOKE>>>" }
            return text
        }
        #expect((try remend("<<<JOKE>>>Why did the chicken", options: .init(handlers: [jokeHandler]))).utf16.elementsEqual(("<<<JOKE>>>Why did the chicken<<</JOKE>>>").utf16))
    }

    @Test("should not double-complete joke markers") func test019() throws {
        let jokeHandler = RemendHandler(name: "joke", priority: 80) { text in
            let match = Remend.match("<<<JOKE>>>([^<]*)$", text)
            if match != nil, !Remend.endsWith(text, "<<</JOKE>>>") { return text + "<<</JOKE>>>" }
            return text
        }
        #expect((try remend("<<<JOKE>>>complete<<</JOKE>>>", options: .init(handlers: [jokeHandler]))).utf16.elementsEqual(("<<<JOKE>>>complete<<</JOKE>>>").utf16))
    }
}
