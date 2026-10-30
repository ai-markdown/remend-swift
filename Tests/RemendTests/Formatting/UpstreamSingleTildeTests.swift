// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamSingleTildeTests {

    // single tilde escape (#445) — single-tilde.test.ts:5
    @Test("should escape single ~ between numbers")
    func test001() throws {
        #expect((try remend("20~25°C")).utf16.elementsEqual("20\\~25°C".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:9
    @Test("should escape multiple single tildes between numbers")
    func test002() throws {
        #expect((try remend("20~25°C。20~25°C")).utf16.elementsEqual("20\\~25°C。20\\~25°C".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:13
    @Test("should escape single ~ between letters")
    func test003() throws {
        #expect((try remend("foo~bar")).utf16.elementsEqual("foo\\~bar".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:17
    @Test("should not escape ~~ (double tilde strikethrough)")
    func test004() throws {
        #expect((try remend("~~strikethrough~~")).utf16.elementsEqual("~~strikethrough~~".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:21
    @Test("should not escape ~ at start or end of text")
    func test005() throws {
        #expect((try remend("~hello")).utf16.elementsEqual("~hello".utf16))
        #expect((try remend("hello~")).utf16.elementsEqual("hello~".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:26
    @Test("should not escape ~ surrounded by spaces")
    func test006() throws {
        #expect((try remend("hello ~ world")).utf16.elementsEqual("hello ~ world".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:30
    @Test("should not escape ~ inside code blocks")
    func test007() throws {
        #expect((try remend("```\n20~25\n```")).utf16.elementsEqual("```\n20~25\n```".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:34
    @Test("should not escape ~ inside inline code")
    func test008() throws {
        #expect((try remend("`20~25`")).utf16.elementsEqual("`20~25`".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:38
    @Test("should handle incomplete strikethrough separately from single tilde")
    func test009() throws {
        #expect((try remend("20~25 and ~~strike")).utf16.elementsEqual("20\\~25 and ~~strike~~".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:42
    @Test("can be disabled via options")
    func test010() throws {
        #expect((try remend("20~25°C", options: RemendOptions(singleTilde: false))).utf16.elementsEqual("20~25°C".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:46
    @Test("should preserve Unicode letters around single ~")
    func test011() throws {
        #expect((try remend("日本~語")).utf16.elementsEqual("日本\\~語".utf16))
        #expect((try remend("α~β")).utf16.elementsEqual("α\\~β".utf16))
        #expect((try remend("é~x")).utf16.elementsEqual("é\\~x".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:52
    @Test("should preserve supplementary-plane Unicode letters around single ~")
    func test012() throws {
        #expect((try remend("𐐀~a")).utf16.elementsEqual("𐐀\\~a".utf16))
    }

    // single tilde escape (#445) — single-tilde.test.ts:56
    @Test("should escape multiple single tildes between letters")
    func test013() throws {
        #expect((try remend("foo~bar~baz")).utf16.elementsEqual("foo\\~bar\\~baz".utf16))
    }
}
