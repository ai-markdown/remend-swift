// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamBoldTests {

    // bold formatting (**) — bold.test.ts:5
    @Test("should complete incomplete bold formatting")
    func test001() throws {
        #expect((try remend("Text with **bold")).utf16.elementsEqual("Text with **bold**".utf16))
        #expect((try remend("**incomplete")).utf16.elementsEqual("**incomplete**".utf16))
    }

    // bold formatting (**) — bold.test.ts:10
    @Test("should keep complete bold formatting unchanged")
    func test002() throws {
        let text = "Text with **bold text**"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // bold formatting (**) — bold.test.ts:15
    @Test("should handle multiple bold sections")
    func test003() throws {
        let text = "**bold1** and **bold2**"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // bold formatting (**) — bold.test.ts:20
    @Test("should complete odd number of bold markers")
    func test004() throws {
        #expect((try remend("**first** and **second")).utf16.elementsEqual("**first** and **second**".utf16))
    }

    // bold formatting (**) — bold.test.ts:24
    @Test("should handle partial bold text at chunk boundary")
    func test005() throws {
        #expect((try remend("Here is some **bold tex")).utf16.elementsEqual("Here is some **bold tex**".utf16))
    }

    // bold formatting (**) — bold.test.ts:28
    @Test("should complete half-complete bold closing marker (#313)")
    func test006() throws {
        // When streaming **bold**, the closing marker arrives char by char
        // **bold text* is a half-complete closing marker, not bold+asterisk
        #expect((try remend("**xxx*")).utf16.elementsEqual("**xxx**".utf16))
        #expect((try remend("**bold text*")).utf16.elementsEqual("**bold text**".utf16))
        #expect((try remend("Text with **bold*")).utf16.elementsEqual("Text with **bold**".utf16))
        #expect((try remend("This is **bold text*")).utf16.elementsEqual("This is **bold text**".utf16))
    }
}
