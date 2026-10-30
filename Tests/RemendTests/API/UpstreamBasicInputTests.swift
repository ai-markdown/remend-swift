@testable import Remend
import Foundation
import Testing

/// Direct port of upstream basic-input.test.ts at remend@1.3.1 (8a2ac221).
struct UpstreamBasicInputTests {
    // Original test: "should return non-string inputs unchanged" (basic-input.test.ts:5).
    // Swift String excludes null/undefined-style absence and numeric inputs. The compile-negative
    // evidence is scripts/upstream-tests/verify-string-input-contract.sh; this is not a skipped runtime test.

    // basic input handling
    @Test("should return empty string unchanged") func test002() throws {
        #expect((try remend("")).utf16.elementsEqual(("").utf16))
    }

    // basic input handling
    @Test("should return regular text unchanged") func test003() throws {
        let text = "This is plain text without any markdown"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }
}
