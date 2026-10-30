// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamBoldItalicTests {

    // bold-italic formatting (***) — bold-italic.test.ts:5
    @Test("should complete incomplete bold-italic formatting")
    func test001() throws {
        #expect((try remend("Text with ***bold-italic")).utf16.elementsEqual("Text with ***bold-italic***".utf16))
        #expect((try remend("***incomplete")).utf16.elementsEqual("***incomplete***".utf16))
    }

    // bold-italic formatting (***) — bold-italic.test.ts:12
    @Test("should keep complete bold-italic formatting unchanged")
    func test002() throws {
        let text = "Text with ***bold and italic text***"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // bold-italic formatting (***) — bold-italic.test.ts:17
    @Test("should handle multiple bold-italic sections")
    func test003() throws {
        let text = "***first*** and ***second***"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // bold-italic formatting (***) — bold-italic.test.ts:22
    @Test("should complete odd number of triple asterisk markers")
    func test004() throws {
        #expect((try remend("***first*** and ***second")).utf16.elementsEqual("***first*** and ***second***".utf16))
    }

    // bold-italic formatting (***) — bold-italic.test.ts:28
    @Test("should not confuse triple asterisks with single or double")
    func test005() throws {
        #expect((try remend("*italic* **bold** ***both")).utf16.elementsEqual("*italic* **bold** ***both***".utf16))
    }

    // bold-italic formatting (***) — bold-italic.test.ts:34
    @Test("should handle triple asterisks at start of text")
    func test006() throws {
        #expect((try remend("***Starting bold-italic")).utf16.elementsEqual("***Starting bold-italic***".utf16))
    }

    // bold-italic formatting (***) — bold-italic.test.ts:40
    @Test("should handle nested formatting with triple asterisks")
    func test007() throws {
        #expect((try remend("***bold-italic with `code")).utf16.elementsEqual("***bold-italic with `code***`".utf16))
    }

    // bold-italic formatting (***) — bold-italic.test.ts:46
    @Test("should handle bold-italic chunks")
    func test008() throws {
        let chunks = [
            "This is",
            "This is ***very",
            "This is ***very important",
            "This is ***very important***",
            "This is ***very important*** to know",
        ]
        #expect((try remend(chunks[0])).utf16.elementsEqual("This is".utf16))
        #expect((try remend(chunks[1])).utf16.elementsEqual("This is ***very***".utf16))
        #expect((try remend(chunks[2])).utf16.elementsEqual("This is ***very important***".utf16))
        #expect((try remend(chunks[3])).utf16.elementsEqual(chunks[3].utf16))
        #expect((try remend(chunks[4])).utf16.elementsEqual(chunks[4].utf16))
    }

    // bold-italic formatting (***) — bold-italic.test.ts:62
    @Test("should handle text ending with multiple consecutive asterisks")
    func test009() throws {
        // Test the case where text ends with trailing asterisks (>= 3)
        #expect((try remend("text ***")).utf16.elementsEqual("text ***".utf16))
        #expect((try remend("text ****")).utf16.elementsEqual("text ****".utf16))
        #expect((try remend("text *****")).utf16.elementsEqual("text *****".utf16))
        #expect((try remend("text ******")).utf16.elementsEqual("text ******".utf16))
        // Test text that ends without any space (lines 136-138 in emphasis-handlers.ts)
        #expect((try remend("text***")).utf16.elementsEqual("text***".utf16))
        #expect((try remend("word****")).utf16.elementsEqual("word****".utf16))
        #expect((try remend("end******")).utf16.elementsEqual("end******".utf16))
        // Test cases where countTripleAsterisks is called with trailing asterisks
        #expect((try remend("***start***end***")).utf16.elementsEqual("***start***end***".utf16))
        // 6 asterisks at end = 2 sets of ***, total 3 sets (odd), but this might not close
        // Let me test with different patterns
        #expect((try remend("***text***")).utf16.elementsEqual("***text***".utf16))
        #expect((try remend("***incomplete")).utf16.elementsEqual("***incomplete***".utf16))
        // Test lines 137-138: text that ends with >= 3 asterisks (but not 4+ consecutive)
        #expect((try remend("***word text***")).utf16.elementsEqual("***word text***".utf16))
    }

    // bold-italic formatting (***) — bold-italic.test.ts:85
    @Test("should not add closing markers to overlapping bold and italic (#302)")
    func test010() throws {
        // When we have **bold and *italic***, the *** is closing both ** and *
        // It's not a bold-italic marker, so we shouldn't add closing ***
        #expect((try remend("Combined **bold and *italic*** text")).utf16.elementsEqual("Combined **bold and *italic*** text".utf16))
        #expect((try remend("**bold and *italic*** more text")).utf16.elementsEqual("**bold and *italic*** more text".utf16))
        #expect((try remend("test **bold and *italic*** end")).utf16.elementsEqual("test **bold and *italic*** end".utf16))
        #expect((try remend("- Combined **bold and *italic*** text")).utf16.elementsEqual("- Combined **bold and *italic*** text".utf16))
    }
}
