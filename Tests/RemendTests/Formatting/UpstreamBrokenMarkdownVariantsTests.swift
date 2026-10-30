// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamBrokenMarkdownVariantsTests {

    // rapid successive formatting switches — broken-markdown-variants.test.ts:6
    @Test("should close italic and strikethrough but not bold when asterisk in content")
    func test001() throws {
        // Bold pattern can't match when there's a * in content between ** and end
        // Only italic (*) and strikethrough (~~) close
        let result = (try remend("**bold then *italic then ~~strike"))
        #expect(result.utf16.elementsEqual("**bold then *italic then ~~strike*~~".utf16))
    }

    // rapid successive formatting switches — broken-markdown-variants.test.ts:13
    @Test("should close italic and strikethrough when bold pattern blocked")
    func test002() throws {
        // Bold pattern blocked by * in content; italic and strikethrough close
        let result = (try remend("~~strike **bold *italic"))
        #expect(result.utf16.elementsEqual("~~strike **bold *italic*~~".utf16))
    }

    // rapid successive formatting switches — broken-markdown-variants.test.ts:19
    @Test("should close handlers in priority order (bold before strikethrough before code)")
    func test003() throws {
        // Bold can't match (asterisk in content), italic appends *, boldItalic appends ***,
        // then inline code appends `, then strikethrough appends ~~
        let result = (try remend("*italic **bold ~~strike `code"))
        #expect(result.utf16.elementsEqual("*italic **bold ~~strike `code***`~~".utf16))
    }

    // rapid successive formatting switches — broken-markdown-variants.test.ts:26
    @Test("should close bold before strikethrough (priority order)")
    func test004() throws {
        // Bold handler (priority 35) runs before strikethrough (priority 60)
        let result = (try remend("**bold ~~strike"))
        #expect(result.utf16.elementsEqual("**bold ~~strike**~~".utf16))
    }

    // rapid successive formatting switches — broken-markdown-variants.test.ts:32
    @Test("should close italic then bold via bold-italic handler")
    func test005() throws {
        let result = (try remend("*italic **bold"))
        #expect(result.utf16.elementsEqual("*italic **bold***".utf16))
    }

    // formatting cut mid-marker — broken-markdown-variants.test.ts:40
    @Test("should not close single asterisk at end (ambiguous)")
    func test006() throws {
        // Single trailing * could be start of ** - not meaningful content after it
        let result = (try remend("text*"))
        #expect(result.utf16.elementsEqual("text*".utf16))
    }

    // formatting cut mid-marker — broken-markdown-variants.test.ts:46
    @Test("should not close single tilde at end (not a valid marker alone)")
    func test007() throws {
        let result = (try remend("text~"))
        #expect(result.utf16.elementsEqual("text~".utf16))
    }

    // formatting cut mid-marker — broken-markdown-variants.test.ts:51
    @Test("should not close single dollar at end without inlineKatex")
    func test008() throws {
        let result = (try remend("text$"))
        #expect(result.utf16.elementsEqual("text$".utf16))
    }

    // formatting cut mid-marker — broken-markdown-variants.test.ts:56
    @Test("should close single dollar at end with inlineKatex enabled")
    func test009() throws {
        // countSingleDollars sees 1 (odd), appends $
        let result = (try remend("text$", options: RemendOptions(inlineKatex: true)))
        #expect(result.utf16.elementsEqual("text$$".utf16))
    }

    // formatting cut mid-marker — broken-markdown-variants.test.ts:62
    @Test("should handle opening marker + single char of closing")
    func test010() throws {
        // **bold* is a half-complete bold closing
        #expect((try remend("**bold*")).utf16.elementsEqual("**bold**".utf16))
        // ~~strike~ is a half-complete strikethrough closing
        #expect((try remend("~~strike~")).utf16.elementsEqual("~~strike~~".utf16))
        // $$formula$ is a half-complete block katex closing
        #expect((try remend("$$formula$")).utf16.elementsEqual("$$formula$$".utf16))
    }

    // backslash escapes with incomplete formatting — broken-markdown-variants.test.ts:74
    @Test("should not close escaped asterisks")
    func test011() throws {
        // \\* means escaped backslash + real asterisk
        let result = (try remend("\\*not italic"))
        #expect(result.utf16.elementsEqual("\\*not italic".utf16))
    }

    // backslash escapes with incomplete formatting — broken-markdown-variants.test.ts:80
    @Test("should not close double-escaped backslash before asterisk")
    func test012() throws {
        // remend sees the char before * as \ (the second backslash) and treats it as escaped
        let result = (try remend("\\\\*actually italic"))
        #expect(result.utf16.elementsEqual("\\\\*actually italic".utf16))
    }

    // backslash escapes with incomplete formatting — broken-markdown-variants.test.ts:86
    @Test("should close escaped double asterisks (remend does not track escape depth)")
    func test013() throws {
        // remend doesn't understand that \** has the first * escaped;
        // it sees ** and closes bold
        let result = (try remend("\\**not bold"))
        #expect(result.utf16.elementsEqual("\\**not bold**".utf16))
    }

    // backslash escapes with incomplete formatting — broken-markdown-variants.test.ts:93
    @Test("should handle mixed escaped and real formatting")
    func test014() throws {
        // \\* is escaped, but the later *real* is valid
        let result = (try remend("\\*escaped\\* but *real italic"))
        #expect(result.utf16.elementsEqual("\\*escaped\\* but *real italic*".utf16))
    }

    // multiple incomplete links — broken-markdown-variants.test.ts:102
    @Test("should handle two incomplete links")
    func test015() throws {
        let result = (try remend("[link1 and [link2"))
        #expect(result.utf16.elementsEqual("[link1 and [link2](streamdown:incomplete-link)".utf16))
    }

    // multiple incomplete links — broken-markdown-variants.test.ts:107
    @Test("should handle one complete and one incomplete link")
    func test016() throws {
        let result = (try remend("[first](url1) and [second"))
        #expect(result.utf16.elementsEqual("[first](url1) and [second](streamdown:incomplete-link)".utf16))
    }

    // multiple incomplete links — broken-markdown-variants.test.ts:114
    @Test("should handle nested incomplete brackets")
    func test017() throws {
        let result = (try remend("[outer [inner]"))
        // [inner] is complete, [outer has no closing ]
        #expect(result.utf16.elementsEqual("[outer [inner]](streamdown:incomplete-link)".utf16))
    }

    // multiple incomplete links — broken-markdown-variants.test.ts:120
    @Test("should handle incomplete link in text-only mode")
    func test018() throws {
        let result = (try remend("[incomplete link", options: RemendOptions(linkMode: .textOnly)))
        #expect(result.utf16.elementsEqual("incomplete link".utf16))
    }

    // multiple incomplete links — broken-markdown-variants.test.ts:125
    @Test("should handle two incomplete links in text-only mode")
    func test019() throws {
        let result = (try remend("[link1 and [link2", options: RemendOptions(linkMode: .textOnly)))
        #expect(result.utf16.elementsEqual("link1 and [link2".utf16))
    }

    // link text with formatting markers — broken-markdown-variants.test.ts:133
    @Test("should handle bold inside incomplete link URL")
    func test020() throws {
        let result = (try remend("[**bold link**](incomplete-url"))
        #expect(result.utf16.elementsEqual("[**bold link**](streamdown:incomplete-link)".utf16))
    }

    // link text with formatting markers — broken-markdown-variants.test.ts:138
    @Test("should handle italic inside incomplete link URL")
    func test021() throws {
        let result = (try remend("[*italic link*](incomplete"))
        #expect(result.utf16.elementsEqual("[*italic link*](streamdown:incomplete-link)".utf16))
    }

    // link text with formatting markers — broken-markdown-variants.test.ts:143
    @Test("should handle code inside incomplete link URL")
    func test022() throws {
        let result = (try remend("[`code link`](incomplete"))
        #expect(result.utf16.elementsEqual("[`code link`](streamdown:incomplete-link)".utf16))
    }

    // link text with formatting markers — broken-markdown-variants.test.ts:148
    @Test("should handle incomplete formatting inside incomplete link text")
    func test023() throws {
        // Link handler runs first (priority 20), early returns
        let result = (try remend("[**bold link"))
        #expect(result.utf16.elementsEqual("[**bold link](streamdown:incomplete-link)".utf16))
    }

    // nested blockquotes with formatting — broken-markdown-variants.test.ts:157
    @Test("should close bold in deeply nested blockquote")
    func test024() throws {
        #expect((try remend("> > **deeply nested bold")).utf16.elementsEqual("> > **deeply nested bold**".utf16))
    }

    // nested blockquotes with formatting — broken-markdown-variants.test.ts:163
    @Test("should close bold in blockquote with list")
    func test025() throws {
        #expect((try remend("> * list with **bold")).utf16.elementsEqual("> * list with **bold**".utf16))
    }

    // nested blockquotes with formatting — broken-markdown-variants.test.ts:167
    @Test("should close italic in triple nested blockquote")
    func test026() throws {
        #expect((try remend("> > > triple nested *italic")).utf16.elementsEqual("> > > triple nested *italic*".utf16))
    }

    // nested blockquotes with formatting — broken-markdown-variants.test.ts:173
    @Test("should close strikethrough in blockquote")
    func test027() throws {
        #expect((try remend("> ~~struck text")).utf16.elementsEqual("> ~~struck text~~".utf16))
    }

    // task lists with formatting — broken-markdown-variants.test.ts:180
    @Test("should close bold in unchecked task")
    func test028() throws {
        #expect((try remend("- [ ] **bold task")).utf16.elementsEqual("- [ ] **bold task**".utf16))
    }

    // task lists with formatting — broken-markdown-variants.test.ts:184
    @Test("should keep complete strikethrough in checked task")
    func test029() throws {
        #expect((try remend("- [x] completed ~~struck~~")).utf16.elementsEqual("- [x] completed ~~struck~~".utf16))
    }

    // task lists with formatting — broken-markdown-variants.test.ts:190
    @Test("should close italic in unchecked task")
    func test030() throws {
        #expect((try remend("- [ ] *italic task")).utf16.elementsEqual("- [ ] *italic task*".utf16))
    }

    // task lists with formatting — broken-markdown-variants.test.ts:194
    @Test("should close inline code in task")
    func test031() throws {
        #expect((try remend("- [ ] `code task")).utf16.elementsEqual("- [ ] `code task`".utf16))
    }

    // formatting inside table cells — broken-markdown-variants.test.ts:201
    @Test("should close bold that appears to span cell boundary")
    func test032() throws {
        // The ** has content after it, so it should be closed
        #expect((try remend("| **bold | next |")).utf16.elementsEqual("| **bold | next |**".utf16))
    }

    // formatting inside table cells — broken-markdown-variants.test.ts:206
    @Test("should close inline code that spans cell boundary")
    func test033() throws {
        #expect((try remend("| `code | next |")).utf16.elementsEqual("| `code | next |`".utf16))
    }

    // formatting inside table cells — broken-markdown-variants.test.ts:210
    @Test("should handle complete formatting in table cell")
    func test034() throws {
        let text = "| **bold** | next |"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // HTML comments and special HTML — broken-markdown-variants.test.ts:218
    @Test("should not strip HTML comment (pattern requires <[a-zA-Z/])")
    func test035() throws {
        // <!-- starts with <! which doesn't match the handler's /^<[a-zA-Z/]/ pattern
        #expect((try remend("text <!-- incomplete comment")).utf16.elementsEqual("text <!-- incomplete comment".utf16))
    }

    // HTML comments and special HTML — broken-markdown-variants.test.ts:225
    @Test("should not strip complete script tag with trailing text")
    func test036() throws {
        // <script> is a complete tag (has >), so the handler doesn't strip it
        #expect((try remend("text <script>alert('")).utf16.elementsEqual("text <script>alert('".utf16))
    }

    // HTML comments and special HTML — broken-markdown-variants.test.ts:230
    @Test("should strip incomplete div with attributes")
    func test037() throws {
        #expect((try remend("text <div class=\"test")).utf16.elementsEqual("text".utf16))
    }

    // HTML comments and special HTML — broken-markdown-variants.test.ts:234
    @Test("should keep complete HTML tags")
    func test038() throws {
        #expect((try remend("text <br>")).utf16.elementsEqual("text <br>".utf16))
    }

    // HTML comments and special HTML — broken-markdown-variants.test.ts:238
    @Test("should keep complete HTML comments")
    func test039() throws {
        #expect((try remend("text <!-- comment -->")).utf16.elementsEqual("text <!-- comment -->".utf16))
    }

    // KaTeX with complex content — broken-markdown-variants.test.ts:245
    @Test("should close block katex with braces inside")
    func test040() throws {
        // remend just appends $$, it doesn't complete LaTeX braces
        #expect((try remend("$$\\frac{x}{y")).utf16.elementsEqual("$$\\frac{x}{y$$".utf16))
    }

    // KaTeX with complex content — broken-markdown-variants.test.ts:250
    @Test("should close block katex with latex environments")
    func test041() throws {
        #expect((try remend("$$\\begin{matrix} a")).utf16.elementsEqual("$$\\begin{matrix} a$$".utf16))
    }

    // KaTeX with complex content — broken-markdown-variants.test.ts:254
    @Test("should close inline katex when enabled")
    func test042() throws {
        #expect((try remend("$x^2 + y^2", options: RemendOptions(inlineKatex: true))).utf16.elementsEqual("$x^2 + y^2$".utf16))
    }

    // KaTeX with complex content — broken-markdown-variants.test.ts:258
    @Test("should not treat currency as katex without inlineKatex")
    func test043() throws {
        let text = "The price is $50 and $100"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // KaTeX with complex content — broken-markdown-variants.test.ts:263
    @Test("should close odd inline katex with currency-like text")
    func test044() throws {
        // With inlineKatex enabled, $50 and $100 look like two single $ signs (even count)
        let result = (try remend("The price is $50 and $100", options: RemendOptions(inlineKatex: true)))
        #expect(result.utf16.elementsEqual("The price is $50 and $100".utf16))
    }

    // KaTeX with complex content — broken-markdown-variants.test.ts:269
    @Test("should close multiline block katex with complex content")
    func test045() throws {
        #expect((try remend("$$\n\\sum_{i=0}^{n} x_i")).utf16.elementsEqual("$$\n\\sum_{i=0}^{n} x_i\n$$".utf16))
    }

    // consecutive completed + incomplete formatting — broken-markdown-variants.test.ts:278
    @Test("should close second bold after complete bold")
    func test046() throws {
        #expect((try remend("**bold** then **more")).utf16.elementsEqual("**bold** then **more**".utf16))
    }

    // consecutive completed + incomplete formatting — broken-markdown-variants.test.ts:282
    @Test("should close second inline code after complete code")
    func test047() throws {
        #expect((try remend("`code` then `more")).utf16.elementsEqual("`code` then `more`".utf16))
    }

    // consecutive completed + incomplete formatting — broken-markdown-variants.test.ts:286
    @Test("should close second strikethrough after complete strikethrough")
    func test048() throws {
        #expect((try remend("~~done~~ and ~~undone")).utf16.elementsEqual("~~done~~ and ~~undone~~".utf16))
    }

    // consecutive completed + incomplete formatting — broken-markdown-variants.test.ts:290
    @Test("should close second italic after complete italic")
    func test049() throws {
        #expect((try remend("*first* and *second")).utf16.elementsEqual("*first* and *second*".utf16))
    }

    // consecutive completed + incomplete formatting — broken-markdown-variants.test.ts:294
    @Test("should close second bold-italic after complete bold-italic")
    func test050() throws {
        #expect((try remend("***first*** and ***second")).utf16.elementsEqual("***first*** and ***second***".utf16))
    }

    // formatting at paragraph boundaries — broken-markdown-variants.test.ts:303
    @Test("should close bold after paragraph break")
    func test051() throws {
        #expect((try remend("paragraph1\n\n**bold")).utf16.elementsEqual("paragraph1\n\n**bold**".utf16))
    }

    // formatting at paragraph boundaries — broken-markdown-variants.test.ts:307
    @Test("should close italic after paragraph break")
    func test052() throws {
        #expect((try remend("line1\n\n*italic text")).utf16.elementsEqual("line1\n\n*italic text*".utf16))
    }

    // formatting at paragraph boundaries — broken-markdown-variants.test.ts:311
    @Test("should close formatting after multiple newlines")
    func test053() throws {
        #expect((try remend("text\n\n\n**bold")).utf16.elementsEqual("text\n\n\n**bold**".utf16))
    }

    // formatting at paragraph boundaries — broken-markdown-variants.test.ts:315
    @Test("should close inline code across paragraph")
    func test054() throws {
        #expect((try remend("text\n\n`code")).utf16.elementsEqual("text\n\n`code`".utf16))
    }

    // deeply nested formatting — broken-markdown-variants.test.ts:322
    @Test("should close handlers in priority order with deeply nested formatting")
    func test055() throws {
        // Bold can't match (asterisk in content), italic appends *,
        // inline code appends `, strikethrough appends ~~
        let result = (try remend("**bold *italic ~~strike `code"))
        #expect(result.utf16.elementsEqual("**bold *italic ~~strike `code*`~~".utf16))
    }

    // deeply nested formatting — broken-markdown-variants.test.ts:329
    @Test("should close bold-italic then code then strikethrough")
    func test056() throws {
        // BoldItalic (priority 30) appends ***, then inline code (50) appends `,
        // then strikethrough (60) appends ~~
        let result = (try remend("***bold-italic ~~strike `code"))
        #expect(result.utf16.elementsEqual("***bold-italic ~~strike `code***`~~".utf16))
    }

    // deeply nested formatting — broken-markdown-variants.test.ts:336
    @Test("should close italic but not bold when asterisk blocks bold pattern")
    func test057() throws {
        // Bold handler can't match when * appears in content after **
        // Italic handler closes the *, leaving ** unclosed
        let result = (try remend("**bold and *italic"))
        #expect(result.utf16.elementsEqual("**bold and *italic*".utf16))
    }

    // CJK and Unicode with formatting — broken-markdown-variants.test.ts:346
    @Test("should close bold with Chinese text")
    func test058() throws {
        #expect((try remend("**中文粗体")).utf16.elementsEqual("**中文粗体**".utf16))
    }

    // CJK and Unicode with formatting — broken-markdown-variants.test.ts:350
    @Test("should close italic with Japanese text")
    func test059() throws {
        #expect((try remend("*日本語")).utf16.elementsEqual("*日本語*".utf16))
    }

    // CJK and Unicode with formatting — broken-markdown-variants.test.ts:354
    @Test("should close inline code with Korean text")
    func test060() throws {
        #expect((try remend("`한국어 코드")).utf16.elementsEqual("`한국어 코드`".utf16))
    }

    // CJK and Unicode with formatting — broken-markdown-variants.test.ts:358
    @Test("should close strikethrough with emoji content")
    func test061() throws {
        #expect((try remend("~~🎉 celebration")).utf16.elementsEqual("~~🎉 celebration~~".utf16))
    }

    // CJK and Unicode with formatting — broken-markdown-variants.test.ts:362
    @Test("should close bold with mixed CJK and Latin")
    func test062() throws {
        #expect((try remend("**Hello 世界")).utf16.elementsEqual("**Hello 世界**".utf16))
    }

    // formatting after structural elements — broken-markdown-variants.test.ts:369
    @Test("should close bold after horizontal rule")
    func test063() throws {
        #expect((try remend("---\n**bold after rule")).utf16.elementsEqual("---\n**bold after rule**".utf16))
    }

    // formatting after structural elements — broken-markdown-variants.test.ts:373
    @Test("should close bold after heading")
    func test064() throws {
        #expect((try remend("# Heading\n**bold")).utf16.elementsEqual("# Heading\n**bold**".utf16))
    }

    // formatting after structural elements — broken-markdown-variants.test.ts:377
    @Test("should close bold after blockquote")
    func test065() throws {
        #expect((try remend("> quote\n**bold")).utf16.elementsEqual("> quote\n**bold**".utf16))
    }

    // formatting after structural elements — broken-markdown-variants.test.ts:381
    @Test("should close italic after code block")
    func test066() throws {
        #expect((try remend("```\ncode\n```\n*italic")).utf16.elementsEqual("```\ncode\n```\n*italic*".utf16))
    }

    // reference-style links and footnotes — broken-markdown-variants.test.ts:388
    @Test("should handle reference-style link with complete brackets")
    func test067() throws {
        let text = "[text][ref]"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // reference-style links and footnotes — broken-markdown-variants.test.ts:393
    @Test("should handle footnote reference")
    func test068() throws {
        let text = "[^1]"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // reference-style links and footnotes — broken-markdown-variants.test.ts:398
    @Test("should handle incomplete reference link")
    func test069() throws {
        let result = (try remend("[text]["))
        #expect(result.utf16.elementsEqual("[text][](streamdown:incomplete-link)".utf16))
    }

    // reference-style links and footnotes — broken-markdown-variants.test.ts:403
    @Test("should keep complete footnote definition")
    func test070() throws {
        let text = "[^1]: footnote text"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // indented code blocks — broken-markdown-variants.test.ts:411
    @Test("should still close asterisks in indented text (not fenced)")
    func test071() throws {
        // remend only tracks fenced code blocks, so indented code is treated as normal text
        #expect((try remend("    *asterisks in indented")).utf16.elementsEqual("    *asterisks in indented*".utf16))
    }

    // indented code blocks — broken-markdown-variants.test.ts:418
    @Test("should close bold in indented text")
    func test072() throws {
        #expect((try remend("    **bold in indented")).utf16.elementsEqual("    **bold in indented**".utf16))
    }

    // back-to-back code blocks — broken-markdown-variants.test.ts:425
    @Test("should handle formatting after closed code block")
    func test073() throws {
        #expect((try remend("```\ncode\n```\n**bold")).utf16.elementsEqual("```\ncode\n```\n**bold**".utf16))
    }

    // back-to-back code blocks — broken-markdown-variants.test.ts:429
    @Test("should not close formatting inside open code block")
    func test074() throws {
        // Second ``` opens a new code block that isn't closed
        let text = "```\ncode\n```\n```\nmore"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // back-to-back code blocks — broken-markdown-variants.test.ts:435
    @Test("should handle inline code after code block")
    func test075() throws {
        #expect((try remend("```\nblock\n```\n`inline")).utf16.elementsEqual("```\nblock\n```\n`inline`".utf16))
    }

    // confusing asterisk sequences — broken-markdown-variants.test.ts:444
    @Test("should handle four asterisks (bold-italic handler appends ***)")
    func test076() throws {
        // BoldItalic sees odd triple-asterisk count and markers not balanced, appends ***
        let result = (try remend("****text"))
        #expect(result.utf16.elementsEqual("****text***".utf16))
    }

    // confusing asterisk sequences — broken-markdown-variants.test.ts:450
    @Test("should handle five asterisks (bold-italic handler appends ***)")
    func test077() throws {
        let result = (try remend("*****text"))
        #expect(result.utf16.elementsEqual("*****text***".utf16))
    }

    // confusing asterisk sequences — broken-markdown-variants.test.ts:455
    @Test("should handle mixed asterisk counts")
    func test078() throws {
        // *a**b: single * then ** - each handler works independently
        let result = (try remend("*a**b"))
        #expect(result.utf16.elementsEqual("*a**b***".utf16))
    }

    // whitespace edge cases — broken-markdown-variants.test.ts:464
    @Test("should close bold with tabs in content")
    func test079() throws {
        #expect((try remend("**bold\twith\ttabs")).utf16.elementsEqual("**bold\twith\ttabs**".utf16))
    }

    // whitespace edge cases — broken-markdown-variants.test.ts:468
    @Test("should close bold with CRLF")
    func test080() throws {
        #expect((try remend("**bold\r\nwith CRLF")).utf16.elementsEqual("**bold\r\nwith CRLF**".utf16))
    }

    // whitespace edge cases — broken-markdown-variants.test.ts:472
    @Test("should close bold after many leading newlines")
    func test081() throws {
        #expect((try remend("\n\n\n**bold")).utf16.elementsEqual("\n\n\n**bold**".utf16))
    }

    // whitespace edge cases — broken-markdown-variants.test.ts:476
    @Test("should trim trailing single space")
    func test082() throws {
        #expect((try remend("text ")).utf16.elementsEqual("text".utf16))
    }

    // whitespace edge cases — broken-markdown-variants.test.ts:480
    @Test("should preserve trailing double space")
    func test083() throws {
        #expect((try remend("text  ")).utf16.elementsEqual("text  ".utf16))
    }

    // whitespace edge cases — broken-markdown-variants.test.ts:484
    @Test("should close bold and trim trailing space")
    func test084() throws {
        #expect((try remend("**bold ")).utf16.elementsEqual("**bold**".utf16))
    }

    // disabled handlers via options — broken-markdown-variants.test.ts:491
    @Test("should not close bold when bold is disabled")
    func test085() throws {
        #expect((try remend("**bold text", options: RemendOptions(bold: false))).utf16.elementsEqual("**bold text".utf16))
    }

    // disabled handlers via options — broken-markdown-variants.test.ts:495
    @Test("should close italic even when bold is disabled")
    func test086() throws {
        #expect((try remend("**bold *italic", options: RemendOptions(bold: false))).utf16.elementsEqual("**bold *italic*".utf16))
    }

    // disabled handlers via options — broken-markdown-variants.test.ts:499
    @Test("should not close anything when all are disabled")
    func test087() throws {
        let result = (try remend("**bold *italic `code ~~strike", options: RemendOptions(bold: false, boldItalic: false, inlineCode: false, italic: false, strikethrough: false)))
        #expect(result.utf16.elementsEqual("**bold *italic `code ~~strike".utf16))
    }

    // disabled handlers via options — broken-markdown-variants.test.ts:510
    @Test("should not close bold when asterisk in content blocks pattern (italic disabled)")
    func test088() throws {
        // Bold pattern can't match when * appears in content; italic is disabled
        // So nothing closes
        #expect((try remend("**bold *italic", options: RemendOptions(italic: false))).utf16.elementsEqual("**bold *italic".utf16))
    }

    // disabled handlers via options — broken-markdown-variants.test.ts:516
    @Test("should close strikethrough but not bold when bold is disabled")
    func test089() throws {
        #expect((try remend("**bold ~~strike", options: RemendOptions(bold: false))).utf16.elementsEqual("**bold ~~strike~~".utf16))
    }

    // disabled handlers via options — broken-markdown-variants.test.ts:522
    @Test("should still close links when only links disabled (images defaults to true)")
    func test090() throws {
        // The links handler is enabled when EITHER links or images option is true
        // Since images defaults to true, disabling only links doesn't disable the handler
        #expect((try remend("[link text", options: RemendOptions(links: false))).utf16.elementsEqual("[link text](streamdown:incomplete-link)".utf16))
    }

    // disabled handlers via options — broken-markdown-variants.test.ts:530
    @Test("should not close links when both links and images disabled")
    func test091() throws {
        #expect((try remend("[link text", options: RemendOptions(images: false, links: false))).utf16.elementsEqual("[link text".utf16))
    }

    // disabled handlers via options — broken-markdown-variants.test.ts:536
    @Test("should not close katex when katex disabled")
    func test092() throws {
        #expect((try remend("$$formula", options: RemendOptions(katex: false))).utf16.elementsEqual("$$formula".utf16))
    }

    // real-world AI streaming patterns — broken-markdown-variants.test.ts:543
    @Test("should handle code explanation with incomplete code block")
    func test093() throws {
        let text = "Here's how to use it:\n\n```typescript\nconst x = 1"
        // Inside an incomplete fenced code block - should not modify
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // real-world AI streaming patterns — broken-markdown-variants.test.ts:549
    @Test("should handle markdown list being built with bold")
    func test094() throws {
        #expect((try remend("1. First\n2. **Second item with bold")).utf16.elementsEqual("1. First\n2. **Second item with bold**".utf16))
    }

    // real-world AI streaming patterns — broken-markdown-variants.test.ts:555
    @Test("should handle mixed inline code and bold")
    func test095() throws {
        #expect((try remend("The function `getData` returns a **Promise")).utf16.elementsEqual("The function `getData` returns a **Promise**".utf16))
    }

    // real-world AI streaming patterns — broken-markdown-variants.test.ts:561
    @Test("should handle incomplete link in explanation")
    func test096() throws {
        #expect((try remend("Check the [documentation")).utf16.elementsEqual("Check the [documentation](streamdown:incomplete-link)".utf16))
    }

    // real-world AI streaming patterns — broken-markdown-variants.test.ts:567
    @Test("should handle code block followed by explanation")
    func test097() throws {
        #expect((try remend("```js\nconst x = 1;\n```\n\nThis creates a **variable")).utf16.elementsEqual("```js\nconst x = 1;\n```\n\nThis creates a **variable**".utf16))
    }

    // real-world AI streaming patterns — broken-markdown-variants.test.ts:573
    @Test("should handle bullet list with inline code")
    func test098() throws {
        #expect((try remend("- Use `map` to transform\n- Use `filter")).utf16.elementsEqual("- Use `map` to transform\n- Use `filter`".utf16))
    }

    // real-world AI streaming patterns — broken-markdown-variants.test.ts:579
    @Test("should handle heading with incomplete italic")
    func test099() throws {
        #expect((try remend("## Important *note")).utf16.elementsEqual("## Important *note*".utf16))
    }

    // real-world AI streaming patterns — broken-markdown-variants.test.ts:583
    @Test("should handle incomplete image (preserves newlines before removed image)")
    func test100() throws {
        #expect((try remend("Here's the diagram:\n\n![architecture")).utf16.elementsEqual("Here's the diagram:\n\n".utf16))
    }

    // real-world AI streaming patterns — broken-markdown-variants.test.ts:589
    @Test("should handle incomplete image with partial URL (preserves trailing space)")
    func test101() throws {
        // Image is removed, leaving "See " - the trailing space remains
        // because remend only trims single trailing space at the very start
        // before handlers run, and the handler produces new trailing space
        #expect((try remend("See ![diagram](http://example.com/img")).utf16.elementsEqual("See ".utf16))
    }

    // real-world AI streaming patterns — broken-markdown-variants.test.ts:596
    @Test("should handle link with incomplete formatting after it")
    func test102() throws {
        #expect((try remend("[click here](https://example.com) for **more")).utf16.elementsEqual("[click here](https://example.com) for **more**".utf16))
    }
}
