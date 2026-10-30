// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamHtmlTagsTests {

    // incomplete HTML tag stripping — html-tags.test.ts:5
    @Test("should strip incomplete opening tags at end")
    func test001() throws {
        #expect((try remend("Hello <div")).utf16.elementsEqual("Hello".utf16))
        #expect((try remend("Hello <custom")).utf16.elementsEqual("Hello".utf16))
        #expect((try remend("Hello <casecard")).utf16.elementsEqual("Hello".utf16))
        #expect((try remend("Text <MyComponent")).utf16.elementsEqual("Text".utf16))
    }

    // incomplete HTML tag stripping — html-tags.test.ts:12
    @Test("should strip incomplete closing tags at end")
    func test002() throws {
        #expect((try remend("Hello </div")).utf16.elementsEqual("Hello".utf16))
        #expect((try remend("Hello </custom")).utf16.elementsEqual("Hello".utf16))
        #expect((try remend("<div>content</di")).utf16.elementsEqual("<div>content".utf16))
    }

    // incomplete HTML tag stripping — html-tags.test.ts:18
    @Test("should strip incomplete tags with partial attributes")
    func test003() throws {
        #expect((try remend("Hello <div class=\"foo")).utf16.elementsEqual("Hello".utf16))
        #expect((try remend("Hello <div class=")).utf16.elementsEqual("Hello".utf16))
        #expect((try remend("Hello <a href=\"https://example.com")).utf16.elementsEqual("Hello".utf16))
        #expect((try remend("<custom data-id")).utf16.elementsEqual("".utf16))
    }

    // incomplete HTML tag stripping — html-tags.test.ts:25
    @Test("should keep complete tags unchanged")
    func test004() throws {
        #expect((try remend("Hello <div>")).utf16.elementsEqual("Hello <div>".utf16))
        #expect((try remend("<div>content</div>")).utf16.elementsEqual("<div>content</div>".utf16))
        #expect((try remend("<br/>")).utf16.elementsEqual("<br/>".utf16))
        #expect((try remend("<img src='test'>")).utf16.elementsEqual("<img src='test'>".utf16))
    }

    // incomplete HTML tag stripping — html-tags.test.ts:32
    @Test("should not strip < followed by space or number")
    func test005() throws {
        #expect((try remend("3 < 5")).utf16.elementsEqual("3 < 5".utf16))
        #expect((try remend("x < y")).utf16.elementsEqual("x < y".utf16))
        #expect((try remend("if a <")).utf16.elementsEqual("if a <".utf16))
        #expect((try remend("value <1")).utf16.elementsEqual("value <1".utf16))
    }

    // incomplete HTML tag stripping — html-tags.test.ts:39
    @Test("should not strip inside code blocks")
    func test006() throws {
        #expect((try remend("```\n<div\n```")).utf16.elementsEqual("```\n<div\n```".utf16))
        #expect((try remend("```html\n<custom")).utf16.elementsEqual("```html\n<custom".utf16))
    }

    // incomplete HTML tag stripping — html-tags.test.ts:44
    @Test("should not strip inside inline code")
    func test007() throws {
        #expect((try remend("`<div`")).utf16.elementsEqual("`<div`".utf16))
    }

    // incomplete HTML tag stripping — html-tags.test.ts:48
    @Test("should handle tag at start of text")
    func test008() throws {
        #expect((try remend("<div")).utf16.elementsEqual("".utf16))
        #expect((try remend("<custom")).utf16.elementsEqual("".utf16))
        #expect((try remend("</div")).utf16.elementsEqual("".utf16))
    }

    // incomplete HTML tag stripping — html-tags.test.ts:54
    @Test("should strip only the incomplete tag, preserving prior content")
    func test009() throws {
        #expect((try remend("Some text here\n\n<casecard")).utf16.elementsEqual("Some text here".utf16))
        #expect((try remend("# Heading\n\nParagraph <custom")).utf16.elementsEqual("# Heading\n\nParagraph".utf16))
    }

    // incomplete HTML tag stripping — html-tags.test.ts:61
    @Test("should handle complete tag followed by incomplete tag")
    func test010() throws {
        #expect((try remend("<div>Hello</div> <span")).utf16.elementsEqual("<div>Hello</div>".utf16))
    }

    // incomplete HTML tag stripping — html-tags.test.ts:65
    @Test("should not add trailing underscore for HTML attributes with underscores")
    func test011() throws {
        #expect((try remend("<a target=\"_blank\" href=\"https://link.com\">word</a>")).utf16.elementsEqual("<a target=\"_blank\" href=\"https://link.com\">word</a>".utf16))
        #expect((try remend("<a target=\"_blank\">link</a>")).utf16.elementsEqual("<a target=\"_blank\">link</a>".utf16))
        #expect((try remend("<iframe src=\"x\" sandbox=\"allow_scripts\">")).utf16.elementsEqual("<iframe src=\"x\" sandbox=\"allow_scripts\">".utf16))
    }

    // incomplete HTML tag stripping — html-tags.test.ts:77
    @Test("should be disabled when htmlTags option is false")
    func test012() throws {
        #expect((try remend("Hello <div", options: RemendOptions(htmlTags: false))).utf16.elementsEqual("Hello <div".utf16))
    }
}
