@testable import Remend
import Foundation
import Testing

/// Direct port of upstream katex.test.ts at remend@1.3.1 (8a2ac221).
struct UpstreamKatexTests {
    // KaTeX block formatting ($$)
    @Test("should complete incomplete block KaTeX") func test001() throws {
        #expect((try remend("Text with $$formula")).utf16.elementsEqual(("Text with $$formula$$").utf16))
        #expect((try remend("$$incomplete")).utf16.elementsEqual(("$$incomplete$$").utf16))
    }

    // KaTeX block formatting ($$)
    @Test("should keep complete block KaTeX unchanged") func test002() throws {
        let text = "Text with $$E = mc^2$$"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // KaTeX block formatting ($$)
    @Test("should handle multiple block KaTeX sections") func test003() throws {
        let text = "$$formula1$$ and $$formula2$$"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // KaTeX block formatting ($$)
    @Test("should complete odd number of block KaTeX markers") func test004() throws {
        #expect((try remend("$$first$$ and $$second")).utf16.elementsEqual(("$$first$$ and $$second$$").utf16))
    }

    // KaTeX block formatting ($$)
    @Test("should handle block KaTeX at start of text") func test005() throws {
        #expect((try remend("$$x + y = z")).utf16.elementsEqual(("$$x + y = z$$").utf16))
    }

    // KaTeX block formatting ($$)
    @Test("should complete partial closing $ without duplicating it") func test006() throws {
        #expect((try remend("$$formula$")).utf16.elementsEqual(("$$formula$$").utf16))
        #expect((try remend("$$x = y$")).utf16.elementsEqual(("$$x = y$$").utf16))
    }

    // KaTeX block formatting ($$)
    @Test("should handle multiline block KaTeX") func test007() throws {
        #expect((try remend("$$\nx = 1\ny = 2")).utf16.elementsEqual(("$$\nx = 1\ny = 2\n$$").utf16))
    }

    // KaTeX inline formatting ($)
    @Test("should NOT complete single dollar signs (likely currency)") func test008() throws {
        #expect((try remend("Text with $formula")).utf16.elementsEqual(("Text with $formula").utf16))
        #expect((try remend("$incomplete")).utf16.elementsEqual(("$incomplete").utf16))
    }

    // KaTeX inline formatting ($)
    @Test("should keep text with paired dollar signs unchanged") func test009() throws {
        let text = "Text with $x^2 + y^2 = z^2$"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // KaTeX inline formatting ($)
    @Test("should handle multiple inline KaTeX sections") func test010() throws {
        let text = "$a = 1$ and $b = 2$"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // KaTeX inline formatting ($)
    @Test("should NOT complete odd number of dollar signs") func test011() throws {
        #expect((try remend("$first$ and $second")).utf16.elementsEqual(("$first$ and $second").utf16))
    }

    // KaTeX inline formatting ($)
    @Test("should not complete single $ but should complete block $$") func test012() throws {
        #expect((try remend("$$block$$ and $inline")).utf16.elementsEqual(("$$block$$ and $inline").utf16))
    }

    // KaTeX inline formatting ($)
    @Test("should NOT complete dollar sign at start of text") func test013() throws {
        #expect((try remend("$x + y = z")).utf16.elementsEqual(("$x + y = z").utf16))
    }

    // KaTeX inline formatting ($)
    @Test("should handle escaped dollar signs") func test014() throws {
        let text = "Price is \\$100"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // KaTeX inline formatting ($)
    @Test("should handle multiple consecutive dollar signs correctly") func test015() throws {
        #expect((try remend("$$$")).utf16.elementsEqual(("$$$$$").utf16))
        #expect((try remend("$$$$")).utf16.elementsEqual(("$$$$").utf16))
    }

    // KaTeX inline formatting ($)
    @Test("should handle mathematical expression chunks") func test016() throws {
        let chunks = ["The formula", "The formula $E", "The formula $E = mc", "The formula $E = mc^2", "The formula $E = mc^2$ shows"]
        #expect((try remend(chunks[0])).utf16.elementsEqual((chunks[0]).utf16))
        #expect((try remend(chunks[1])).utf16.elementsEqual(("The formula $E").utf16))
        #expect((try remend(chunks[2])).utf16.elementsEqual(("The formula $E = mc").utf16))
        #expect((try remend(chunks[3])).utf16.elementsEqual(("The formula $E = mc^2").utf16))
        #expect((try remend(chunks[4])).utf16.elementsEqual((chunks[4]).utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should complete incomplete inline math") func test017() throws {
        let opts = RemendOptions(inlineKatex: true)
        #expect((try remend("Text with $formula", options: opts)).utf16.elementsEqual(("Text with $formula$").utf16))
        #expect((try remend("$incomplete", options: opts)).utf16.elementsEqual(("$incomplete$").utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should keep already-complete inline math unchanged") func test018() throws {
        let opts = RemendOptions(inlineKatex: true)
        let text = "Text with $x^2 + y^2 = z^2$"
        #expect((try remend(text, options: opts)).utf16.elementsEqual((text).utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should complete the third unpaired dollar sign") func test019() throws {
        let opts = RemendOptions(inlineKatex: true)
        #expect((try remend("$first$ and $second", options: opts)).utf16.elementsEqual(("$first$ and $second$").utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should complete inline $ but not affect complete block $$") func test020() throws {
        let opts = RemendOptions(inlineKatex: true)
        #expect((try remend("$$block$$ and $inline", options: opts)).utf16.elementsEqual(("$$block$$ and $inline$").utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should handle streaming chunks of inline math") func test021() throws {
        let opts = RemendOptions(inlineKatex: true)
        let chunks = ["The formula", "The formula $E", "The formula $E = mc", "The formula $E = mc^2", "The formula $E = mc^2$ shows"]
        #expect((try remend(chunks[0], options: opts)).utf16.elementsEqual((chunks[0]).utf16))
        #expect((try remend(chunks[1], options: opts)).utf16.elementsEqual(("The formula $E$").utf16))
        #expect((try remend(chunks[2], options: opts)).utf16.elementsEqual(("The formula $E = mc$").utf16))
        #expect((try remend(chunks[3], options: opts)).utf16.elementsEqual(("The formula $E = mc^2$").utf16))
        #expect((try remend(chunks[4], options: opts)).utf16.elementsEqual((chunks[4]).utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should not complete escaped dollar signs") func test022() throws {
        let opts = RemendOptions(inlineKatex: true)
        let text = "Price is \\$100"
        #expect((try remend(text, options: opts)).utf16.elementsEqual((text).utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should not complete $ inside inline code") func test023() throws {
        let opts = RemendOptions(inlineKatex: true)
        let text = "Use `$var` for variables and $formula"
        #expect((try remend(text, options: opts)).utf16.elementsEqual(("Use `$var` for variables and $formula$").utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should handle multiple complete inline math expressions") func test024() throws {
        let opts = RemendOptions(inlineKatex: true)
        let text = "$a = 1$ and $b = 2$"
        #expect((try remend(text, options: opts)).utf16.elementsEqual((text).utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should handle mixed inline and block math") func test025() throws {
        let opts = RemendOptions(inlineKatex: true)
        let text = "Inline $x$ and block $$y$$"
        #expect((try remend(text, options: opts)).utf16.elementsEqual((text).utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should not complete $ inside a complete block math expression") func test026() throws {
        let opts = RemendOptions(inlineKatex: true)
        let text = "$$x_1 + y_2 = z_3$$"
        #expect((try remend(text, options: opts)).utf16.elementsEqual((text).utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should handle $$ followed by an unmatched $") func test027() throws {
        let opts = RemendOptions(inlineKatex: true)
        #expect((try remend("$$block$$ then $x + y", options: opts)).utf16.elementsEqual(("$$block$$ then $x + y$").utf16))
    }

    // KaTeX inline formatting ($) — opt-in via inlineKatex: true
    @Test("should not produce extra $ when block katex and inline katex both run") func test028() throws {
        let opts = RemendOptions(inlineKatex: true)
        #expect((try remend("$$formula$", options: opts)).utf16.elementsEqual(("$$formula$$").utf16))
        #expect((try remend("$$x = y$", options: opts)).utf16.elementsEqual(("$$x = y$$").utf16))
    }

    // math blocks with underscores
    @Test("should not complete underscores within inline math blocks") func test029() throws {
        let text = "The variable $x_1$ represents the first element"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
        let text2 = "Formula: $a_b + c_d = e_f$"
        #expect((try remend(text2)).utf16.elementsEqual((text2).utf16))
    }

    // math blocks with underscores
    @Test("should not complete underscores within block math") func test030() throws {
        let text = "$$x_1 + y_2 = z_3$$"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
        let text2 = "$$\na_1 + b_2\nc_3 + d_4\n$$"
        #expect((try remend(text2)).utf16.elementsEqual((text2).utf16))
    }

    // math blocks with underscores
    @Test("should not add underscore when math block has incomplete underscore") func test031() throws {
        let text = "Math expression $x_"
        #expect((try remend(text)).utf16.elementsEqual(("Math expression $x_").utf16))
        let text2 = "$$formula_"
        #expect((try remend(text2)).utf16.elementsEqual(("$$formula_$$").utf16))
    }

    // math blocks with underscores
    @Test("should handle underscores outside math blocks normally") func test032() throws {
        let text = "Text with _italic_ and math $x_1$"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
        let text2 = "_italic text_ followed by $a_b$"
        #expect((try remend(text2)).utf16.elementsEqual((text2).utf16))
    }

    // math blocks with underscores
    @Test("should complete italic underscore outside math but not inside") func test033() throws {
        let text = "Start _italic with $x_1$"
        #expect((try remend(text)).utf16.elementsEqual(("Start _italic with $x_1$_").utf16))
    }

    // math blocks with underscores
    @Test("should handle complex math expressions with multiple underscores") func test034() throws {
        let text = "$x_1 + x_2 + x_3 = y_1$"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
        let text2 = "$$\\sum_{i=1}^{n} x_i = \\prod_{j=1}^{m} y_j$$"
        #expect((try remend(text2)).utf16.elementsEqual((text2).utf16))
    }

    // math blocks with underscores
    @Test("should handle escaped dollar signs correctly") func test035() throws {
        let text = "Price is \\$50 and _this is italic_"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
        let text2 = "Cost \\$100 with _incomplete"
        #expect((try remend(text2)).utf16.elementsEqual(("Cost \\$100 with _incomplete_").utf16))
    }

    // math blocks with underscores
    @Test("should handle mixed inline and block math") func test036() throws {
        let text = "Inline $x_1$ and block $$y_2$$ math"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // math blocks with underscores
    @Test("should not interfere with complete math blocks when adding underscores outside") func test037() throws {
        let text = "_italic start $x_1$ italic end_"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // math blocks with underscores
    @Test("should not complete dollar signs in inline code blocks (#296)") func test038() throws {
        let str = "Streamdown uses double dollar signs (`$$`) to delimit mathematical expressions."
        #expect((try remend(str)).utf16.elementsEqual((str).utf16))
    }

    // math blocks with underscores
    @Test("should handle multiple inline code blocks with $$ correctly (#296)") func test039() throws {
        let str = "Use `$$` for math blocks and `$$formula$$` for inline."
        #expect((try remend(str)).utf16.elementsEqual((str).utf16))
    }

    // math blocks with underscores
    @Test("should complete $$ outside inline code but not inside (#296)") func test040() throws {
        let str = "Math: $$x+y and code: `$$`"
        #expect((try remend(str)).utf16.elementsEqual(("Math: $$x+y and code: `$$`$$").utf16))
    }

    // math blocks with underscores
    @Test("should handle mixed $$ inside and outside code blocks (#296)") func test041() throws {
        let str = "$$formula$$ and code `$$` and $$incomplete"
        #expect((try remend(str)).utf16.elementsEqual(("$$formula$$ and code `$$` and $$incomplete$$").utf16))
    }

    // math blocks with asterisks
    @Test("should not complete asterisks within block math") func test042() throws {
        let text = "$$\\mathbf{w}^{*}$$"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // math blocks with asterisks
    @Test("should not complete asterisks in complex math expressions") func test043() throws {
        let text = "$$\n\\mathbf{w}^{*} = \\underset{\\|\\mathbf{w}\\|=1}{\\arg\\max} \\;\\; \\mathbf{w}^T S \\mathbf{w}\n$$"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // math blocks with asterisks
    @Test("should handle asterisks outside math blocks normally") func test044() throws {
        let text = "Text with *italic* and math $$x^{*}$$"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // math blocks with asterisks
    @Test("should complete italic asterisk outside math but not inside") func test045() throws {
        let text = "Start *italic with $$x^{*}$$"
        #expect((try remend(text)).utf16.elementsEqual(("Start *italic with $$x^{*}$$*").utf16))
    }

    // LaTeX delimited math with emphasis markers
    @Test("should not complete underscores within paren-style inline math") func test046() throws {
        let text = "\\(P(x_{t+1})\\)\n\nplain trailing text."
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // LaTeX delimited math with emphasis markers
    @Test("should not complete underscores within bracket-style display math") func test047() throws {
        let text = "\\[\nP(x_{t+1} | x_t)\n\\]"
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // LaTeX delimited math with emphasis markers
    @Test("should not complete asterisks within paren-style inline math") func test048() throws {
        let text = "\\(w^{*}\\)\n\nplain trailing text."
        #expect((try remend(text)).utf16.elementsEqual((text).utf16))
    }

    // LaTeX delimited math with emphasis markers
    @Test("should complete bold after LaTeX inline math without leaking subscripts") func test049() throws {
        let text = ["> Given tokens \\(x_1, ..., x_t\\), maximize \\(P(x_{t+1} | x_1, ..., x_t)\\)", "", "**2. Instruction Tuning (SFT)**", "- Dataset size is much smaller than pre-training"].joined(separator: "\n")
        let partial = RemendText(text).slice(0, (RemendText(text).first("(SFT)") ?? -1) + "(SFT".utf16.count)
        #expect((try remend(partial)).utf16.elementsEqual((partial + "**").utf16))
    }

    // LaTeX delimited math with emphasis markers
    @Test("should complete ordinary underscore emphasis outside LaTeX math") func test050() throws {
        let text = "Inline math \\(x_1\\) and _ordinary italic"
        #expect((try remend(text)).utf16.elementsEqual(("Inline math \\(x_1\\) and _ordinary italic_").utf16))
    }
}
