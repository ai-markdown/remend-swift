@testable import Remend
import Foundation
import Testing

/// Direct port of upstream coverage-gaps.test.ts at remend@1.3.1 (8a2ac221).
struct UpstreamCoverageGapTests {
    // empty string through handler pipeline
    @Test("should handle single space input") func test001() throws {
        #expect((try remend(" ")).utf16.elementsEqual(("").utf16))
    }

    // half-complete double underscore closing
    @Test("should complete __content_ to __content__") func test002() throws {
        #expect((try remend("__content_")).utf16.elementsEqual(("__content__").utf16))
    }

    // underscore with trailing double asterisks
    @Test("should close underscore when trailing ** is unrelated") func test003() throws {
        #expect((try remend("_text**")).utf16.elementsEqual(("_text**_").utf16))
    }

    // bold-italic inside code block
    @Test("should not complete *** markers inside code blocks") func test004() throws {
        #expect((try remend("```\n***bold")).utf16.elementsEqual(("```\n***bold").utf16))
    }

    // bold-italic inside code block
    @Test("should complete *** outside code block with *** inside") func test005() throws {
        #expect((try remend("```\n***\n```\n***text")).utf16.elementsEqual(("```\n***\n```\n***text***").utf16))
    }

    // countTripleAsterisks
    @Test("should count trailing *** at end of text") func test006() throws {
        #expect(Remend.tripleStarCount(RemendText("text***")) == 1)
    }

    // countTripleAsterisks
    @Test("should skip *** inside code blocks") func test007() throws {
        #expect(Remend.tripleStarCount(RemendText("```\n***\n```")) == 0)
    }

    // countTripleAsterisks
    @Test("should count *** outside but not inside code blocks") func test008() throws {
        #expect(Remend.tripleStarCount(RemendText("```\n***\n```\n***")) == 1)
    }

    // countTripleAsterisks
    @Test("should flush pending asterisks before code block toggle") func test009() throws {
        #expect(Remend.tripleStarCount(RemendText("***```code```")) == 1)
    }

    // single underscore counting with code blocks
    @Test("should skip _ inside fenced code blocks") func test010() throws {
        #expect((try remend("```\n_code\n```\n_text")).utf16.elementsEqual(("```\n_code\n```\n_text_").utf16))
    }

    // setext heading with equals sign edge cases
    @Test("should not modify equals when previous line is empty") func test011() throws {
        #expect((try remend("\n=")).utf16.elementsEqual(("\n=").utf16))
    }

    // setext heading with equals sign edge cases
    @Test("should not modify double equals when previous line is empty") func test012() throws {
        #expect((try remend("\n==")).utf16.elementsEqual(("\n==").utf16))
    }

    // strikethrough even tilde pairs
    @Test("should not close when tilde pairs are balanced") func test013() throws {
        #expect((try remend("a~~b~~text")).utf16.elementsEqual(("a~~b~~text").utf16))
    }

    // strikethrough even tilde pairs
    @Test("should not close half-complete tilde when pairs are balanced") func test014() throws {
        #expect((try remend("a~~b~~c~")).utf16.elementsEqual(("a~~b~~c~").utf16))
    }

    // double underscore counting with code blocks
    @Test("should skip __ inside fenced code blocks") func test015() throws {
        #expect((try remend("```\n__code\n```\n__text")).utf16.elementsEqual(("```\n__code\n```\n__text__").utf16))
    }

    // link handler edge cases
    @Test("should handle ]( without matching opening bracket") func test016() throws {
        #expect((try remend("](partial")).utf16.elementsEqual(("](partial").utf16))
    }

    // link handler edge cases
    @Test("should skip image brackets in text-only mode") func test017() throws {
        #expect((try remend("![img [text", options: RemendOptions(linkMode: .textOnly))).utf16.elementsEqual(("![img text").utf16))
    }

    // link handler edge cases
    @Test("should skip complete links in text-only mode") func test018() throws {
        #expect((try remend("[link](url) [incomplete", options: RemendOptions(linkMode: .textOnly))).utf16.elementsEqual(("[link](url) incomplete").utf16))
    }

    // link handler edge cases
    @Test("should handle complete bracket pair without link in text-only mode") func test019() throws {
        #expect((try remend("[text] [incomplete", options: RemendOptions(linkMode: .textOnly))).utf16.elementsEqual(("[text] incomplete").utf16))
    }

    // isBeforeClosingParen edge cases
    @Test("should return false when newline found before )") func test020() throws {
        #expect(isWithinLinkOrImageUrl("[t](_\nmore)", position: 4) == false)
    }

    // isBeforeClosingParen edge cases
    @Test("should return false when text ends without ) or newline") func test021() throws {
        #expect(isWithinLinkOrImageUrl("[t](_noclose", position: 4) == false)
    }

    // isWithinLinkOrImageUrl — ) found before (
    @Test("should return false when ) precedes the position") func test022() throws {
        #expect(isWithinLinkOrImageUrl("[text](url) _after", position: 12) == false)
    }

    // isWithinLinkOrImageUrl — ) found before (
    @Test("should handle underscore after complete link") func test023() throws {
        #expect((try remend("[link](url) _word")).utf16.elementsEqual(("[link](url) _word_").utf16))
    }

    // isWithinLinkOrImageUrl edge cases
    @Test("should return false for bare ( not preceded by ]") func test024() throws {
        #expect(isWithinLinkOrImageUrl("func(arg)", position: 5) == false)
    }

    // isWithinLinkOrImageUrl edge cases
    @Test("should handle underscore after bare parenthesis") func test025() throws {
        #expect((try remend("func(_arg")).utf16.elementsEqual(("func(_arg_").utf16))
    }

    // isWithinHtmlTag edge cases
    @Test("should return false when > is found first") func test026() throws {
        #expect(Remend.withinHTML(RemendText("div>text"), 5) == false)
    }

    // isWithinHtmlTag edge cases
    @Test("should return false for invalid tag start after <") func test027() throws {
        #expect(Remend.withinHTML(RemendText("3<5 text"), 4) == false)
    }

    // isWithinHtmlTag edge cases
    @Test("should return false when newline found before < or >") func test028() throws {
        #expect(Remend.withinHTML(RemendText("<div\ntext"), 6) == false)
    }

    // isWithinHtmlTag edge cases
    @Test("should handle underscore after > character") func test029() throws {
        #expect((try remend("div> _text")).utf16.elementsEqual(("div> _text_").utf16))
    }

    // isWithinHtmlTag edge cases
    @Test("should handle underscore near < with invalid tag start") func test030() throws {
        #expect((try remend("3<5 _text")).utf16.elementsEqual(("3<5 _text_").utf16))
    }

    // isWithinHtmlTag edge cases
    @Test("should handle underscore on new line after HTML element") func test031() throws {
        #expect((try remend("<div>\n_text")).utf16.elementsEqual(("<div>\n_text_").utf16))
    }

    // isWithinHtmlTag edge cases
    @Test("should return true for uppercase tag") func test032() throws {
        #expect(Remend.withinHTML(RemendText("<DIV class='_test'>"), 13) == true)
    }

    // isWithinHtmlTag edge cases
    @Test("should return true for closing tag with /") func test033() throws {
        #expect(Remend.withinHTML(RemendText("</div _attr>"), 6) == true)
    }

    // isWithinHtmlTag edge cases
    @Test("should return false when < is at end of text") func test034() throws {
        #expect(Remend.withinHTML(RemendText("text<"), 5) == false)
    }

    // underscore inside link URL
    @Test("should not close underscore that is part of a link URL") func test035() throws {
        #expect((try remend("[link](a_b) _word")).utf16.elementsEqual(("[link](a_b) _word_").utf16))
    }

    // isWithinMathBlock branch coverage
    @Test("should ignore single $ inside block math") func test036() throws {
        #expect(isWithinMathBlock("$$x$y$$z", position: 5) == true)
    }

    // double underscore half-complete in code block
    @Test("should not complete __content_ inside code block") func test037() throws {
        #expect((try remend("```\n__content_")).utf16.elementsEqual(("```\n__content_").utf16))
    }

    // double underscore half-complete with even pairs
    @Test("should not complete when __ pairs are balanced") func test038() throws {
        #expect((try remend("__a__ __b__content_")).utf16.elementsEqual(("__a__ __b__content_").utf16))
    }

    // findFirstIncompleteBracket with incomplete URL
    @Test("should handle [text]( without ) before incomplete bracket") func test039() throws {
        #expect((try remend("[a]( b](c [incomplete", options: RemendOptions(linkMode: .textOnly))).utf16.elementsEqual(("[a]( b](c incomplete").utf16))
    }

    // isHorizontalRule branch coverage
    @Test("should detect horizontal rule with spaces between markers") func test040() throws {
        #expect(Remend.horizontalRule(RemendText("* * *"), 0, 42) == true)
    }

    // isHorizontalRule branch coverage
    @Test("should detect horizontal rule with tabs between markers") func test041() throws {
        #expect(Remend.horizontalRule(RemendText("*\t*\t*"), 0, 42) == true)
    }
}
