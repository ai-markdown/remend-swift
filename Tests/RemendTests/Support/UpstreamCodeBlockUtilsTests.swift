@testable import Remend
import Foundation
import Testing

/// Direct port of upstream code-block-utils.test.ts at remend@1.3.1 (8a2ac221).
struct UpstreamCodeBlockUtilsTests {

    private func reference(_ source: String, _ position: Int) -> Bool {
        let units = Array(source.utf16)
        // Independent translation of the original scan. Out-of-range JS reads cannot equal an ASCII delimiter.
        func unit(_ index: Int) -> UInt16 { units.indices.contains(index) ? units[index] : 0 }
        var inline = false, fence = false, index = 0
        while index < position {
            if unit(index) == 92, index + 1 < units.count, unit(index + 1) == 96 { index += 2; continue }
            if unit(index) == 96, unit(index + 1) == 96, unit(index + 2) == 96 { fence.toggle(); index += 3; continue }
            if !fence, unit(index) == 96 { inline.toggle() }
            index += 1
        }
        return inline || fence
    }
    private func parityMismatches(_ source: String) -> [Int] {
        (0 ... source.utf16.count + 1).filter { Remend.withinCode(RemendText(source), $0) != reference(source, $0) }
    }
    // isInsideCodeBlock
    @Test("reports positions inside a fenced code block") func test001() throws {
        let text = "before ```js\nconst x = arr[0];\n``` after"
        #expect(Remend.withinCode(RemendText(text), (RemendText(text).first("arr") ?? -1)) == true)
        #expect(Remend.withinCode(RemendText(text), (RemendText(text).first("before") ?? -1)) == false)
        #expect(Remend.withinCode(RemendText(text), (RemendText(text).first("after") ?? -1)) == false)
    }

    // isInsideCodeBlock
    @Test("reports positions inside inline code") func test002() throws {
        let text = "use `map[key]` here"
        #expect(Remend.withinCode(RemendText(text), (RemendText(text).first("key") ?? -1)) == true)
        #expect(Remend.withinCode(RemendText(text), (RemendText(text).first("here") ?? -1)) == false)
    }

    // isInsideCodeBlock
    @Test("ignores escaped backticks") func test003() throws {
        let text = "not code \\` still [not] code"
        #expect(Remend.withinCode(RemendText(text), (RemendText(text).first("[not]") ?? -1)) == false)
    }

    // isInsideCodeBlock
    @Test("treats an unclosed fence as extending to the end") func test004() throws {
        let text = "```python\nvalues[0] = 1"
        #expect(Remend.withinCode(RemendText(text), (RemendText(text).first("values") ?? -1)) == true)
        #expect(Remend.withinCode(RemendText(text), text.utf16.count) == true)
    }

    // isInsideCodeBlock
    @Test("matches the per-call scan at every position on mixed input") func test005() throws {
        let cases = ["a `b` c ```\nd [e] `f`\n``` g \\` h ``` i", "``````", "\\`", "`unclosed inline [x]", "text \\``real` code"]
        for text in cases {
            #expect(parityMismatches(text) == [])
        }
    }

    // isInsideCodeBlock
    @Test("stays correct when queried texts alternate") func test006() throws {
        let inCode = "```\n[x]"
        let inProse = "plain [x]"
        for _ in 0 ..< 3 {
            #expect(Remend.withinCode(RemendText(inCode), (RemendText(inCode).first("[x]") ?? -1)) == true)
            #expect(Remend.withinCode(RemendText(inProse), (RemendText(inProse).first("[x]") ?? -1)) == false)
        }
    }
}
