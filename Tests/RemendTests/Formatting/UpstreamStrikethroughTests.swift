// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamStrikethroughTests {

    // strikethrough formatting (~~) — strikethrough.test.ts:5
    @Test("should complete incomplete strikethrough")
    func test001() throws {
        #expect((try remend("Text with ~~strike")).utf16.elementsEqual("Text with ~~strike~~".utf16))
        #expect((try remend("~~incomplete")).utf16.elementsEqual("~~incomplete~~".utf16))
    }

    // strikethrough formatting (~~) — strikethrough.test.ts:10
    @Test("should keep complete strikethrough unchanged")
    func test002() throws {
        let text = "Text with ~~strikethrough text~~"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // strikethrough formatting (~~) — strikethrough.test.ts:15
    @Test("should handle multiple strikethrough sections")
    func test003() throws {
        let text = "~~strike1~~ and ~~strike2~~"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // strikethrough formatting (~~) — strikethrough.test.ts:20
    @Test("should complete odd number of strikethrough markers")
    func test004() throws {
        #expect((try remend("~~first~~ and ~~second")).utf16.elementsEqual("~~first~~ and ~~second~~".utf16))
    }

    // strikethrough formatting (~~) — strikethrough.test.ts:24
    @Test("should complete half-complete ~~ closing marker (#313)")
    func test005() throws {
        // When streaming ~~strike~~, the closing marker arrives char by char
        // ~~strike~ is a half-complete closing marker
        #expect((try remend("~~xxx~")).utf16.elementsEqual("~~xxx~~".utf16))
        #expect((try remend("~~strike text~")).utf16.elementsEqual("~~strike text~~".utf16))
        #expect((try remend("Text with ~~strike~")).utf16.elementsEqual("Text with ~~strike~~".utf16))
        #expect((try remend("This is ~~strikethrough~")).utf16.elementsEqual("This is ~~strikethrough~~".utf16))
    }
}
