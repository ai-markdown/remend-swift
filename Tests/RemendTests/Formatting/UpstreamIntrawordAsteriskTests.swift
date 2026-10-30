// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamIntrawordAsteriskTests {

    // intraword asterisk emphasis — intraword-asterisk.test.ts:5
    @Test("keeps complete emphasis unchanged: %s", arguments: [
        "*foo*bar",
        "this is *real*ly good",
        "이것은 *기울임*으로 표시",
        "5*6*78",
        "*foo*bar*",
        "a *b*c*",
        "a *b*c* d",
        "*b*c*",
        "*a* b*",
        "a *b* c*",
        "*a*b*c*d",
        "x *y*z w",
        "before *a*b after *c*",
    ])
    func test001(text: String) throws {
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // intraword asterisk emphasis — intraword-asterisk.test.ts:24
    @Test("leaves a lone intraword asterisk literal")
    func test002() throws {
        #expect((try remend("foo*bar")).utf16.elementsEqual("foo*bar".utf16))
        #expect((try remend("hello*world")).utf16.elementsEqual("hello*world".utf16))
        #expect((try remend("test*123*test")).utf16.elementsEqual("test*123*test".utf16))
    }

    // intraword asterisk emphasis — intraword-asterisk.test.ts:30
    @Test("continues an active intraword emphasis chain")
    func test003() throws {
        #expect((try remend("*foo*bar*baz")).utf16.elementsEqual("*foo*bar*baz*".utf16))
        #expect((try remend("*file*name*ext")).utf16.elementsEqual("*file*name*ext*".utf16))
    }

    // intraword asterisk emphasis — intraword-asterisk.test.ts:35
    @Test("completes a later incomplete run after a closed intraword pair")
    func test004() throws {
        #expect((try remend("before *a*b after *c")).utf16.elementsEqual("before *a*b after *c*".utf16))
        #expect((try remend("*기울임*으로 *another")).utf16.elementsEqual("*기울임*으로 *another*".utf16))
    }

    // intraword asterisk emphasis — intraword-asterisk.test.ts:40
    @Test("does not reopen after whitespace following a closed intraword pair")
    func test005() throws {
        #expect((try remend("*foo* bar*baz")).utf16.elementsEqual("*foo* bar*baz".utf16))
    }
}
