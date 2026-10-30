import Remend
import Testing

struct MathTests {
    @Test func mathOptionsAndPartialClosers() throws {
        #expect(try remend("$$x$", options: .init(katex: true)) == "$$x$$")
        #expect(try remend("$$x\ny", options: .init(katex: true)) == "$$x\ny\n$$")
        #expect(try remend("$$x\n", options: .init(katex: true)) == "$$x\n$$")
        #expect(try remend("$$x", options: .init(katex: false)) == "$$x")
        #expect(try remend("$x", options: .init(inlineKatex: true)) == "$x$")
        #expect(try remend("\\$x", options: .init(inlineKatex: true)) == "\\$x")
        #expect(try remend("`$x`", options: .init(inlineKatex: true)) == "`$x`")
        #expect(try remend("$x", options: .init(inlineKatex: false)) == "$x")
    }
}
