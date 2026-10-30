// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamListsTests {

    // list handling — lists.test.ts:5
    @Test("should not add asterisk to lists using asterisk markers")
    func test001() throws {
        let text = "* Item 1\n* Item 2\n* Item 3"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // list handling — lists.test.ts:10
    @Test("should not add asterisk to single list item")
    func test002() throws {
        let text = "* Single item"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // list handling — lists.test.ts:15
    @Test("should not add asterisk to nested lists")
    func test003() throws {
        let text = "* Parent item\n  * Nested item 1\n  * Nested item 2"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // list handling — lists.test.ts:20
    @Test("should handle lists with italic text correctly")
    func test004() throws {
        let text = "* Item with *italic* text\n* Another item"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // list handling — lists.test.ts:25
    @Test("should complete incomplete italic even in list items")
    func test005() throws {
        // List markers are not counted, but incomplete italic formatting is still completed
        let text = "* Item with *incomplete italic\n* Another item"
        // The function adds an asterisk to complete the italic, though at the end of text
        // This is not ideal but matches current behavior
        #expect((try remend(text)).utf16.elementsEqual("* Item with *incomplete italic\n* Another item*".utf16))
    }

    // list handling — lists.test.ts:35
    @Test("should handle mixed list markers and italic formatting")
    func test006() throws {
        let text = "* First item\n* Second *italic* item\n* Third item"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // list handling — lists.test.ts:40
    @Test("should handle lists with tabs for indentation")
    func test007() throws {
        let text = "*\tItem with tab\n*\tAnother item"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // list handling — lists.test.ts:45
    @Test("should not interfere with dash lists")
    func test008() throws {
        let text = "- Item 1\n- Item 2 with *italic*\n- Item 3"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // list handling — lists.test.ts:50
    @Test("should handle the Gemini response example from issue")
    func test009() throws {
        let geminiResponse = "* user123\n* user456\n* user789"
        #expect((try remend(geminiResponse)).utf16.elementsEqual(geminiResponse.utf16))
    }

    // list handling — lists.test.ts:55
    @Test("should handle lists with incomplete formatting")
    func test010() throws {
        #expect((try remend("- Item 1\n- Item 2 with **bol")).utf16.elementsEqual("- Item 1\n- Item 2 with **bol**".utf16))
    }

    // list handling — lists.test.ts:61
    @Test("should handle lists with emphasis character blocks (#97)")
    func test011() throws {
        // Lists with just emphasis markers should not be auto-completed
        #expect((try remend("- __")).utf16.elementsEqual("- __".utf16))
        #expect((try remend("- **")).utf16.elementsEqual("- **".utf16))
        #expect((try remend("- __\n- **")).utf16.elementsEqual("- __\n- **".utf16))
        #expect((try remend("\n- __\n- **")).utf16.elementsEqual("\n- __\n- **".utf16))
        // Multiple list items with emphasis markers
        #expect((try remend("* __\n* **")).utf16.elementsEqual("* __\n* **".utf16))
        #expect((try remend("+ __\n+ **")).utf16.elementsEqual("+ __\n+ **".utf16))
        // List items with emphasis markers and text should still complete
        #expect((try remend("- __ text after")).utf16.elementsEqual("- __ text after__".utf16))
        #expect((try remend("- ** text after")).utf16.elementsEqual("- ** text after**".utf16))
        // Mixed list items
        #expect((try remend("- __\n- Normal item\n- **")).utf16.elementsEqual("- __\n- Normal item\n- **".utf16))
        // Lists with other emphasis markers
        #expect((try remend("- ***")).utf16.elementsEqual("- ***".utf16))
        #expect((try remend("- *")).utf16.elementsEqual("- *".utf16))
        #expect((try remend("- _")).utf16.elementsEqual("- _".utf16))
        #expect((try remend("- ~~")).utf16.elementsEqual("- ~~".utf16))
        #expect((try remend("- `")).utf16.elementsEqual("- `".utf16))
    }

    // list handling — lists.test.ts:89
    @Test("should not complete list items with emphasis markers spanning multiple lines")
    func test012() throws {
        // When a list item starts with ** followed by content with newline, don't complete
        #expect((try remend("- **text\nmore text")).utf16.elementsEqual("- **text\nmore text".utf16))
        #expect((try remend("* **content\n* Another item")).utf16.elementsEqual("* **content\n* Another item".utf16))
    }
}
