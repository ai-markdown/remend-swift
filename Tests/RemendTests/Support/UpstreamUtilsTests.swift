@testable import Remend
import Foundation
import Testing

/// Direct port of upstream utils.test.ts at remend@1.3.1 (8a2ac221).
struct UpstreamUtilsTests {
    // isWordChar
    @Test("should return false for empty string") func test001() throws {
        #expect(isWordChar("") == false)
    }

    // isWordChar
    @Test("should return true for ASCII word characters") func test002() throws {
        #expect(isWordChar("a") == true)
        #expect(isWordChar("Z") == true)
        #expect(isWordChar("5") == true)
        #expect(isWordChar("_") == true)
    }

    // isWordChar
    @Test("should return false for non-word characters") func test003() throws {
        #expect(isWordChar(" ") == false)
        #expect(isWordChar("*") == false)
        #expect(isWordChar("-") == false)
    }

    // isWordChar
    @Test("should handle unicode word characters") func test004() throws {
        #expect(isWordChar("\u{e9}") == true)
        #expect(isWordChar("\u{f1}") == true)
    }

    // findMatchingOpeningBracket
    @Test("should return -1 when no matching opening bracket exists") func test005() throws {
        let text = "some text]"
        #expect((Remend.openingBracket(RemendText(text), 9) ?? -1) == -1)
    }

    // findMatchingOpeningBracket
    @Test("should find matching opening bracket for simple case") func test006() throws {
        let text = "[text]"
        #expect((Remend.openingBracket(RemendText(text), 5) ?? -1) == 0)
    }

    // findMatchingOpeningBracket
    @Test("should handle nested brackets") func test007() throws {
        let text = "[outer [inner] text]"
        #expect((Remend.openingBracket(RemendText(text), 19) ?? -1) == 0)
        #expect((Remend.openingBracket(RemendText(text), 13) ?? -1) == 7)
    }

    // findMatchingClosingBracket
    @Test("should return -1 when no matching closing bracket exists") func test008() throws {
        let text = "[some text"
        #expect((Remend.closingBracket(RemendText(text), 0) ?? -1) == -1)
    }

    // findMatchingClosingBracket
    @Test("should find matching closing bracket for simple case") func test009() throws {
        let text = "[text]"
        #expect((Remend.closingBracket(RemendText(text), 0) ?? -1) == 5)
    }

    // findMatchingClosingBracket
    @Test("should handle nested brackets") func test010() throws {
        let text = "[outer [inner] text]"
        #expect((Remend.closingBracket(RemendText(text), 0) ?? -1) == 19)
        #expect((Remend.closingBracket(RemendText(text), 7) ?? -1) == 13)
    }
}
