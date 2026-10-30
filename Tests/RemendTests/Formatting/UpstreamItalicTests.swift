// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamItalicTests {

    // italic formatting with underscores (__) — italic.test.ts:5
    @Test("should complete incomplete italic formatting with double underscores")
    func test001() throws {
        #expect((try remend("Text with __italic")).utf16.elementsEqual("Text with __italic__".utf16))
        #expect((try remend("__incomplete")).utf16.elementsEqual("__incomplete__".utf16))
    }

    // italic formatting with underscores (__) — italic.test.ts:10
    @Test("should keep complete italic formatting unchanged")
    func test002() throws {
        let text = "Text with __italic text__"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // italic formatting with underscores (__) — italic.test.ts:15
    @Test("should handle odd number of double underscore pairs")
    func test003() throws {
        #expect((try remend("__first__ and __second")).utf16.elementsEqual("__first__ and __second__".utf16))
    }

    // italic formatting with underscores (__) — italic.test.ts:19
    @Test("should complete half-complete __ closing marker (#313)")
    func test004() throws {
        // When streaming __bold__, the closing marker arrives char by char
        // __bold text_ is a half-complete closing marker
        #expect((try remend("__xxx_")).utf16.elementsEqual("__xxx__".utf16))
        #expect((try remend("__bold text_")).utf16.elementsEqual("__bold text__".utf16))
        #expect((try remend("Text with __bold_")).utf16.elementsEqual("Text with __bold__".utf16))
        #expect((try remend("This is __bold text_")).utf16.elementsEqual("This is __bold text__".utf16))
    }

    // italic formatting with asterisks (*) — italic.test.ts:30
    @Test("should complete incomplete italic formatting with single asterisks")
    func test005() throws {
        #expect((try remend("Text with *italic")).utf16.elementsEqual("Text with *italic*".utf16))
        #expect((try remend("*incomplete")).utf16.elementsEqual("*incomplete*".utf16))
    }

    // italic formatting with asterisks (*) — italic.test.ts:35
    @Test("should keep complete italic formatting unchanged")
    func test006() throws {
        let text = "Text with *italic text*"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // italic formatting with asterisks (*) — italic.test.ts:40
    @Test("should not confuse single asterisks with bold markers")
    func test007() throws {
        #expect((try remend("**bold** and *italic")).utf16.elementsEqual("**bold** and *italic*".utf16))
    }

    // italic formatting with asterisks (*) — italic.test.ts:44
    @Test("should not treat asterisks in the middle of words as italic markers - #189")
    func test008() throws {
        #expect((try remend("234234*123")).utf16.elementsEqual("234234*123".utf16))
        #expect((try remend("hello*world")).utf16.elementsEqual("hello*world".utf16))
        #expect((try remend("test*123*test")).utf16.elementsEqual("test*123*test".utf16))
        // Test with mix of word-internal and formatting asterisks (lines 39-41)
        #expect((try remend("*italic with some*var*name inside")).utf16.elementsEqual("*italic with some*var*name inside*".utf16))
        #expect((try remend("test*var and *incomplete italic")).utf16.elementsEqual("test*var and *incomplete italic*".utf16))
    }

    // italic formatting with asterisks (*) — italic.test.ts:58
    @Test("should handle escaped asterisks correctly in countSingleAsterisks")
    func test009() throws {
        // Test lines 29-31: escaped asterisks should be skipped
        #expect((try remend("\\*escaped asterisk and *italic")).utf16.elementsEqual("\\*escaped asterisk and *italic*".utf16))
        #expect((try remend("*start \\* middle \\* end")).utf16.elementsEqual("*start \\* middle \\* end*".utf16))
    }

    // italic formatting with asterisks (*) — italic.test.ts:68
    @Test("should handle asterisks between letters and numbers")
    func test010() throws {
        #expect((try remend("abc*123")).utf16.elementsEqual("abc*123".utf16))
        #expect((try remend("123*abc")).utf16.elementsEqual("123*abc".utf16))
    }

    // italic formatting with asterisks (*) — italic.test.ts:73
    @Test("should still complete italic formatting with asterisks when not word-internal")
    func test011() throws {
        #expect((try remend("This is *italic")).utf16.elementsEqual("This is *italic*".utf16))
        #expect((try remend("*word* and more text")).utf16.elementsEqual("*word* and more text".utf16))
    }

    // italic formatting with single underscores (_) — italic.test.ts:80
    @Test("should complete incomplete italic formatting with single underscores")
    func test012() throws {
        #expect((try remend("Text with _italic")).utf16.elementsEqual("Text with _italic_".utf16))
        #expect((try remend("_incomplete")).utf16.elementsEqual("_incomplete_".utf16))
    }

    // italic formatting with single underscores (_) — italic.test.ts:85
    @Test("should keep complete italic formatting unchanged")
    func test013() throws {
        let text = "Text with _italic text_"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // italic formatting with single underscores (_) — italic.test.ts:90
    @Test("should not confuse single underscores with double underscore markers")
    func test014() throws {
        #expect((try remend("__bold__ and _italic")).utf16.elementsEqual("__bold__ and _italic_".utf16))
    }

    // italic formatting with single underscores (_) — italic.test.ts:94
    @Test("should handle escaped single underscores")
    func test015() throws {
        let text = "Text with \\_escaped underscore"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
        let text2 = "some\\_text_with_underscores"
        #expect((try remend(text2)).utf16.elementsEqual("some\\_text_with_underscores".utf16))
    }

    // italic formatting with single underscores (_) — italic.test.ts:102
    @Test("should handle mixed escaped and unescaped underscores correctly")
    func test016() throws {
        #expect((try remend("\\_escaped\\_ and _unescaped")).utf16.elementsEqual("\\_escaped\\_ and _unescaped_".utf16))
        #expect((try remend("Start \\_escaped\\_ middle _incomplete")).utf16.elementsEqual("Start \\_escaped\\_ middle _incomplete_".utf16))
        #expect((try remend("\\_fully\\_escaped\\_")).utf16.elementsEqual("\\_fully\\_escaped\\_".utf16))
        #expect((try remend("\\_escaped\\_ _complete_ pair")).utf16.elementsEqual("\\_escaped\\_ _complete_ pair".utf16))
    }

    // italic formatting with single underscores (_) — italic.test.ts:118
    @Test("should handle underscores with unicode word characters")
    func test017() throws {
        #expect((try remend("café_price")).utf16.elementsEqual("café_price".utf16))
        #expect((try remend("naïve_approach")).utf16.elementsEqual("naïve_approach".utf16))
    }

    // italic formatting with single underscores (_) — italic.test.ts:123
    @Test("should not count word-internal single underscores in countSingleUnderscores")
    func test018() throws {
        // This tests the path where underscore is between word characters (lines 106-108)
        #expect((try remend("some_variable_name")).utf16.elementsEqual("some_variable_name".utf16))
        #expect((try remend("test_123_value")).utf16.elementsEqual("test_123_value".utf16))
        #expect((try remend("_start with underscore")).utf16.elementsEqual("_start with underscore_".utf16))
        // Test with mix of word-internal and formatting underscores
        #expect((try remend("_italic with some_var_name inside")).utf16.elementsEqual("_italic with some_var_name inside_".utf16))
        #expect((try remend("test_var and _incomplete italic")).utf16.elementsEqual("test_var and _incomplete italic_".utf16))
    }

    // italic formatting with single underscores (_) — italic.test.ts:138
    @Test("should handle incomplete single underscore with trailing newlines")
    func test019() throws {
        #expect((try remend("Text with _italic\n")).utf16.elementsEqual("Text with _italic_\n".utf16))
        #expect((try remend("_incomplete\n\n")).utf16.elementsEqual("_incomplete_\n\n".utf16))
        #expect((try remend("Start _text\n")).utf16.elementsEqual("Start _text_\n".utf16))
    }
}
