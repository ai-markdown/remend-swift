// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamLinksTests {

    // link handling — links.test.ts:5
    @Test("should preserve incomplete links with special marker")
    func test001() throws {
        #expect((try remend("Text with [incomplete link")).utf16.elementsEqual("Text with [incomplete link](streamdown:incomplete-link)".utf16))
        #expect((try remend("Text [partial")).utf16.elementsEqual("Text [partial](streamdown:incomplete-link)".utf16))
    }

    // link handling — links.test.ts:14
    @Test("should keep complete links unchanged")
    func test002() throws {
        let text = "Text with [complete link](url)"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // link handling — links.test.ts:19
    @Test("should handle multiple complete links")
    func test003() throws {
        let text = "[link1](url1) and [link2](url2)"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // link handling — links.test.ts:24
    @Test("should handle nested brackets in incomplete links")
    func test004() throws {
        // Test case for nested brackets - this would have caught the bracketDepth bug
        #expect((try remend("[outer [nested] text](incomplete")).utf16.elementsEqual("[outer [nested] text](streamdown:incomplete-link)".utf16))
        #expect((try remend("[link with [inner] content](http://incomplete")).utf16.elementsEqual("[link with [inner] content](streamdown:incomplete-link)".utf16))
        #expect((try remend("Text [foo [bar] baz](")).utf16.elementsEqual("Text [foo [bar] baz](streamdown:incomplete-link)".utf16))
    }

    // link handling — links.test.ts:39
    @Test("should handle nested brackets in complete links")
    func test005() throws {
        let text = "[link with [brackets] inside](https://example.com)"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // link handling — links.test.ts:44
    @Test("should handle partial link at chunk boundary - #165")
    func test006() throws {
        #expect((try remend("Check out [this lin")).utf16.elementsEqual("Check out [this lin](streamdown:incomplete-link)".utf16))
        // Links with partial URLs should now be completed with placeholder
        #expect((try remend("Visit [our site](https://exa")).utf16.elementsEqual("Visit [our site](streamdown:incomplete-link)".utf16))
    }

    // link handling — links.test.ts:54
    @Test("should handle nested brackets without matching closing bracket")
    func test007() throws {
        // Case where there's an opening bracket with nested structure but no proper closing
        #expect((try remend("Text [outer [inner")).utf16.elementsEqual("Text [outer [inner](streamdown:incomplete-link)".utf16))
        #expect((try remend("[foo [bar [baz")).utf16.elementsEqual("[foo [bar [baz](streamdown:incomplete-link)".utf16))
        // Test lines 82-83: link (not image) where findMatchingClosingBracket returns -1
        // This happens when there's a [ with ] in text but improper nesting
        #expect((try remend("Text [outer [inner]")).utf16.elementsEqual("Text [outer [inner]](streamdown:incomplete-link)".utf16))
        #expect((try remend("[link [nested] text")).utf16.elementsEqual("[link [nested] text](streamdown:incomplete-link)".utf16))
    }

    // link handling with linkMode: text-only — links.test.ts:77
    @Test("should show plain text for incomplete links")
    func test008() throws {
        let textOnlyOptions = RemendOptions(linkMode: .textOnly)
        #expect((try remend("Text with [incomplete link", options: textOnlyOptions)).utf16.elementsEqual("Text with incomplete link".utf16))
        #expect((try remend("Text [partial", options: textOnlyOptions)).utf16.elementsEqual("Text partial".utf16))
    }

    // link handling with linkMode: text-only — links.test.ts:84
    @Test("should keep complete links unchanged")
    func test009() throws {
        let textOnlyOptions = RemendOptions(linkMode: .textOnly)
        let text = "Text with [complete link](url)"
        #expect((try remend(text, options: textOnlyOptions)).utf16.elementsEqual(text.utf16))
    }

    // link handling with linkMode: text-only — links.test.ts:89
    @Test("should handle multiple complete links")
    func test010() throws {
        let textOnlyOptions = RemendOptions(linkMode: .textOnly)
        let text = "[link1](url1) and [link2](url2)"
        #expect((try remend(text, options: textOnlyOptions)).utf16.elementsEqual(text.utf16))
    }

    // link handling with linkMode: text-only — links.test.ts:94
    @Test("should handle nested brackets in incomplete links")
    func test011() throws {
        let textOnlyOptions = RemendOptions(linkMode: .textOnly)
        #expect((try remend("[outer [nested] text](incomplete", options: textOnlyOptions)).utf16.elementsEqual("outer [nested] text".utf16))
        #expect((try remend("[link with [inner] content](http://incomplete", options: textOnlyOptions)).utf16.elementsEqual("link with [inner] content".utf16))
        #expect((try remend("Text [foo [bar] baz](", options: textOnlyOptions)).utf16.elementsEqual("Text foo [bar] baz".utf16))
    }

    // link handling with linkMode: text-only — links.test.ts:108
    @Test("should handle partial link at chunk boundary")
    func test012() throws {
        let textOnlyOptions = RemendOptions(linkMode: .textOnly)
        #expect((try remend("Check out [this lin", options: textOnlyOptions)).utf16.elementsEqual("Check out this lin".utf16))
        #expect((try remend("Visit [our site](https://exa", options: textOnlyOptions)).utf16.elementsEqual("Visit our site".utf16))
    }

    // link handling with linkMode: text-only — links.test.ts:117
    @Test("should handle nested brackets without matching closing bracket")
    func test013() throws {
        let textOnlyOptions = RemendOptions(linkMode: .textOnly)
        #expect((try remend("Text [outer [inner", options: textOnlyOptions)).utf16.elementsEqual("Text outer [inner".utf16))
        #expect((try remend("[foo [bar [baz", options: textOnlyOptions)).utf16.elementsEqual("foo [bar [baz".utf16))
        #expect((try remend("Text [outer [inner]", options: textOnlyOptions)).utf16.elementsEqual("Text outer [inner]".utf16))
        #expect((try remend("[link [nested] text", options: textOnlyOptions)).utf16.elementsEqual("link [nested] text".utf16))
    }

    // link handling with linkMode: text-only — links.test.ts:130
    @Test("should still remove incomplete images")
    func test014() throws {
        let textOnlyOptions = RemendOptions(linkMode: .textOnly)
        // Images should still be removed entirely, regardless of linkMode
        // Note: the space before the image is preserved
        #expect((try remend("Text ![incomplete image", options: textOnlyOptions)).utf16.elementsEqual("Text ".utf16))
        #expect((try remend("Text ![alt](http://partial", options: textOnlyOptions)).utf16.elementsEqual("Text ".utf16))
    }
}
