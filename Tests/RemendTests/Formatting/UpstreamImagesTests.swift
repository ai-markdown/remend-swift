// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamImagesTests {

    // image handling — images.test.ts:5
    @Test("should remove incomplete images")
    func test001() throws {
        #expect((try remend("Text with ![incomplete image")).utf16.elementsEqual("Text with ".utf16))
        #expect((try remend("![partial")).utf16.elementsEqual("".utf16))
    }

    // image handling — images.test.ts:10
    @Test("should keep complete images unchanged")
    func test002() throws {
        let text = "Text with ![alt text](image.png)"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // image handling — images.test.ts:15
    @Test("should handle partial image at chunk boundary")
    func test003() throws {
        #expect((try remend("See ![the diag")).utf16.elementsEqual("See ".utf16))
        // Images with partial URLs should be removed (images can't show skeleton)
        #expect((try remend("![logo](./assets/log")).utf16.elementsEqual("".utf16))
    }

    // image handling — images.test.ts:21
    @Test("should handle nested brackets in incomplete images")
    func test004() throws {
        // When findMatchingClosingBracket returns -1 for an image (lines 74-79)
        // For this to happen, we need an opening bracket with a ] but no proper matching
        #expect((try remend("Text ![outer [inner]")).utf16.elementsEqual("Text ".utf16))
        #expect((try remend("![nested [brackets] text")).utf16.elementsEqual("".utf16))
        #expect((try remend("Start ![foo [bar] baz")).utf16.elementsEqual("Start ".utf16))
    }

    // image handling — images.test.ts:29
    @Test("should not add trailing underscore for images with underscores in URL (#284)")
    func test005() throws {
        let markdown = "textContent ![image](https://img.alicdn.com/imgextra/i4/6000000003603/O1CN01ApW8bQ1cUE8LduPra_!!6000000003603-2-skyky.png)"
        #expect((try remend(markdown)).utf16.elementsEqual(markdown.utf16))
        // Should also work with links containing underscores
        let linkMarkdown = "textContent [link](https://example.com/path_name!!test)"
        #expect((try remend(linkMarkdown)).utf16.elementsEqual(linkMarkdown.utf16))
        // Multiple images should also work
        let multipleImages = "textContent ![image1](https://example.com/path_1!!test.png) ![image2](https://example.com/path_2!!test.png)"
        #expect((try remend(multipleImages)).utf16.elementsEqual(multipleImages.utf16))
    }
}
