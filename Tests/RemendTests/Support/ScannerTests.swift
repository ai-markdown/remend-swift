import Remend
import Testing

struct ScannerTests {
    @Test func delimitersWithinGraphemeClustersUseCodeUnitSemantics() throws {
        #expect(try remend("x\u{0600} ") == "x\u{0600}")
        #expect(try remend("$$\r\nx\r\n") == "$$\r\nx\r\n$$")
        #expect(try remend("$$x\u{0600}$") == "$$x\u{0600}$$")
        #expect(try remend("**a\u{0600}*") == "**a\u{0600}**")
        #expect(try remend("[x](url\u{0600})") == "[x](url\u{0600})")
        #expect(try remend("[x\u{0600}](url") == "[x\u{0600}](streamdown:incomplete-link)")
    }

    @Test func manyReplacementsRespectCodeRegionsWithoutRepeatedPrefixScans() throws {
        let source = String(repeating: "a~b `c~d`\n", count: 10000) + "end"
        let expected = String(repeating: "a\\~b `c~d`\n", count: 10000) + "end"
        #expect(try remend(source) == expected)
    }
}
