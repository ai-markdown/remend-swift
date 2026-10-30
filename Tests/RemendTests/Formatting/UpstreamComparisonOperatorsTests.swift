// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamComparisonOperatorsTests {

    // comparison operators in list items (#376) — comparison-operators.test.ts:5
    @Test("should escape > followed by a digit in dash list items")
    func test001() throws {
        #expect((try remend("- > 25: rich")).utf16.elementsEqual("- \\> 25: rich".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:9
    @Test("should escape > followed by a digit in asterisk list items")
    func test002() throws {
        #expect((try remend("* > 25: rich")).utf16.elementsEqual("* \\> 25: rich".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:13
    @Test("should escape > followed by a digit in plus list items")
    func test003() throws {
        #expect((try remend("+ > 25: rich")).utf16.elementsEqual("+ \\> 25: rich".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:17
    @Test("should escape > in ordered list items")
    func test004() throws {
        #expect((try remend("1. > 25: rich")).utf16.elementsEqual("1. \\> 25: rich".utf16))
        #expect((try remend("2) > 10: high")).utf16.elementsEqual("2) \\> 10: high".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:22
    @Test("should escape > in indented (nested) list items")
    func test005() throws {
        #expect((try remend("  - > 25: rich")).utf16.elementsEqual("  - \\> 25: rich".utf16))
        #expect((try remend("    - > 5: expensive")).utf16.elementsEqual("    - \\> 5: expensive".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:27
    @Test("should escape >= comparison operators")
    func test006() throws {
        #expect((try remend("- >= 10: high")).utf16.elementsEqual("- \\>= 10: high".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:31
    @Test("should escape > before dollar amounts")
    func test007() throws {
        #expect((try remend("- > $100: expensive")).utf16.elementsEqual("- \\> $100: expensive".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:35
    @Test("should handle the issue example correctly")
    func test008() throws {
        let input = [
            "- < 10: potentially cheap.",
            "- 10–20: reasonable/normal zone.",
            "- > 25–30: rich; you need strong growth + quality to justify.",
        ].joined(separator: "\n")
        let expected = [
            "- < 10: potentially cheap.",
            "- 10–20: reasonable/normal zone.",
            "- \\> 25–30: rich; you need strong growth + quality to justify.",
        ].joined(separator: "\n")
        #expect((try remend(input)).utf16.elementsEqual(expected.utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:51
    @Test("should handle multiple comparison operators in a list")
    func test009() throws {
        let input = [
            "- > 5: expensive",
            "- > 25: very expensive",
        ].joined(separator: "\n")
        let expected = [
            "- \\> 5: expensive",
            "- \\> 25: very expensive",
        ].joined(separator: "\n")
        #expect((try remend(input)).utf16.elementsEqual(expected.utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:61
    @Test("should not escape > in actual blockquotes (no list marker)")
    func test010() throws {
        #expect((try remend("> Some blockquote")).utf16.elementsEqual("> Some blockquote".utf16))
        #expect((try remend("> 25 is a number")).utf16.elementsEqual("> 25 is a number".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:66
    @Test("should not escape > when followed by non-digit text")
    func test011() throws {
        #expect((try remend("- > Some quoted text")).utf16.elementsEqual("- > Some quoted text".utf16))
        #expect((try remend("- > Read more about this")).utf16.elementsEqual("- > Read more about this".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:71
    @Test("should not escape > without a space before digit (no list marker)")
    func test012() throws {
        #expect((try remend(">25")).utf16.elementsEqual(">25".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:75
    @Test("should not escape > inside code blocks")
    func test013() throws {
        let input = "```\n- > 25: in code\n```"
        #expect((try remend(input)).utf16.elementsEqual(input.utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:80
    @Test("should handle > with no space before digit in list items")
    func test014() throws {
        #expect((try remend("- >25: rich")).utf16.elementsEqual("- \\>25: rich".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:84
    @Test("should be disabled when comparisonOperators option is false")
    func test015() throws {
        #expect((try remend("- > 25: rich", options: RemendOptions(comparisonOperators: false))).utf16.elementsEqual("- > 25: rich".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:90
    @Test("should work alongside other remend handlers")
    func test016() throws {
        let input = "- > 25: **bold"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("- \\> 25: **bold**".utf16))
    }

    // comparison operators in list items (#376) — comparison-operators.test.ts:96
    @Test("should handle the full issue example with nested lists")
    func test017() throws {
        let input = [
            "*P/E*",
            "  - < 10: potentially cheap.",
            "  - 10–20: reasonable/normal zone.",
            "  - > 25–30: rich; you need strong growth.",
            "",
            "*P/S*",
            "  - < 1: often cheap for mature businesses.",
            "  - 1–3: okay range.",
            "  - > 5: expensive unless high-margin.",
        ].joined(separator: "\n")
        let expected = [
            "*P/E*",
            "  - < 10: potentially cheap.",
            "  - 10–20: reasonable/normal zone.",
            "  - \\> 25–30: rich; you need strong growth.",
            "",
            "*P/S*",
            "  - < 1: often cheap for mature businesses.",
            "  - 1–3: okay range.",
            "  - \\> 5: expensive unless high-margin.",
        ].joined(separator: "\n")
        #expect((try remend(input)).utf16.elementsEqual(expected.utf16))
    }
}
