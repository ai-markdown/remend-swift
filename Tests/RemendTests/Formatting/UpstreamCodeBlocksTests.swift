// Direct port of remend@1.3.1 upstream tests (Apache-2.0).
// Original test names, literals, assertions, and iteration structure are preserved.
import Foundation
import Remend
import Testing

struct UpstreamCodeBlocksTests {
    // Top-level regex for performance (used in multiple tests)
    private let trailingDoubleUnderscorePattern = "__$"
    // code block handling — code-blocks.test.ts:8
    @Test("should handle incomplete multiline code blocks")
    func test001() throws {
        #expect((try remend("```javascript\nconst x = 5;")).utf16.elementsEqual("```javascript\nconst x = 5;".utf16))
        #expect((try remend("```\ncode here")).utf16.elementsEqual("```\ncode here".utf16))
    }

    // code block handling — code-blocks.test.ts:15
    @Test("should handle complete multiline code blocks")
    func test002() throws {
        let text = "```javascript\nconst x = 5;\n```"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // code block handling — code-blocks.test.ts:20
    @Test("should handle code blocks with language and incomplete content")
    func test003() throws {
        #expect((try remend("```python\ndef hello():")).utf16.elementsEqual("```python\ndef hello():".utf16))
    }

    // code block handling — code-blocks.test.ts:24
    @Test("should handle nested backticks inside code blocks")
    func test004() throws {
        let text = "```\nconst str = `template`;\n```"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // code block handling — code-blocks.test.ts:29
    @Test("should handle incomplete code blocks at end of chunked response")
    func test005() throws {
        #expect((try remend("Some text\n```js\nconsole.log")).utf16.elementsEqual("Some text\n```js\nconsole.log".utf16))
    }

    // code block handling — code-blocks.test.ts:35
    @Test("should handle code blocks with trailing content")
    func test006() throws {
        let text = "```\ncode\n```\nMore text"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // code block handling — code-blocks.test.ts:40
    @Test("should handle complete code blocks ending with triple backticks on newline")
    func test007() throws {
        let text = "```python\ndef greet(name):\n    return f\"Hello, {name}!\"\n```"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // code block handling — code-blocks.test.ts:46
    @Test("should handle complete code blocks with trailing newline after closing backticks")
    func test008() throws {
        let text = "```python\ndef greet(name):\n    return f\"Hello, {name}!\"\n```\n"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // code block handling — code-blocks.test.ts:52
    @Test("should not add extra characters to complete simple code block")
    func test009() throws {
        // Bug report: This was being rendered with extra characters at the end
        let text = "```\nSimple code block\nwith multiple lines\nand some special characters: !@#$%^&*()\n```"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // code block handling — code-blocks.test.ts:59
    @Test("should not add extra characters to complete Python code block with underscores and asterisks")
    func test010() throws {
        // Bug report: This was being rendered with **_ appended
        let text = """
        ```python
        def hello_world():
            \"\"\"A simple function\"\"\"
            name = \"World\"
            print(f\"Hello, {name}!\")
        \u{20}\u{20}\u{20}\u{20}
            # List comprehension
            numbers = [x**2 for x in range(10) if x % 2 == 0]
            return numbers

        class TestClass:
            def __init__(self, value):
                self.value = value
        ```
        """
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // code block handling — code-blocks.test.ts:66
    @Test("should not add backticks when code block ends properly")
    func test011() throws {
        // This is the exact case from Grok
        let grokOutput = "```python def greet(name): return f\"Hello, {name}!\"\n```"
        #expect((try remend(grokOutput)).utf16.elementsEqual(grokOutput.utf16))
    }

    // code block handling — code-blocks.test.ts:73
    @Test("should handle multiple complete code blocks with newlines")
    func test012() throws {
        let text = "```js\ncode1\n```\n\n```python\ncode2\n```"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
    }

    // code block handling — code-blocks.test.ts:78
    @Test("should correctly handle code on same line as opening backticks with closing on newline")
    func test013() throws {
        // This was causing issues - being treated as inline when it should be multiline
        let text = "```python def greet(name): return f\"Hello, {name}!\"\n```"
        #expect((try remend(text)).utf16.elementsEqual(text.utf16))
        // Should NOT be treated as inline triple backticks
        let result = (try remend(text))
        #expect(!(result).contains("````"))
    }

    // code block handling — code-blocks.test.ts:88
    @Test("should only treat truly inline triple backticks as inline")
    func test014() throws {
        // This SHOULD be treated as inline (no newlines)
        let inline = "```python code```"
        #expect((try remend(inline)).utf16.elementsEqual(inline.utf16))
        // This should NOT be treated as inline (has newline)
        let multiline = "```python code\n```"
        #expect((try remend(multiline)).utf16.elementsEqual(multiline.utf16))
    }

    // code block handling — code-blocks.test.ts:98
    @Test("should not treat brackets inside complete code blocks as incomplete links")
    func test015() throws {
        let text = "Here's some code:\n```javascript\nconst arr = [1, 2, 3];\nconsole.log(arr[0]);\n```\nDone with code block."
        let result = (try remend(text))
        #expect(!(result).contains("streamdown:incomplete-link"))
        #expect(result.utf16.elementsEqual(text.utf16))
    }

    // code block handling — code-blocks.test.ts:111
    @Test("should still detect actual incomplete links outside of code blocks")
    func test016() throws {
        let text = "Here's a code block:\n```bash\necho \"test\"\n```\nAnd here's an [incomplete link"
        let result = (try remend(text))
        #expect((result).contains("streamdown:incomplete-link"))
        #expect(result.utf16.elementsEqual("Here's a code block:\n```bash\necho \"test\"\n```\nAnd here's an [incomplete link](streamdown:incomplete-link)".utf16))
    }

    // code block handling — code-blocks.test.ts:127
    @Test("should not add incomplete-link marker after complete code blocks - #227")
    func test017() throws {
        let text_content = """
        Precisely.

        When full-screen TUI applications like **Vim**, **less**, or **htop** start, they switch the terminal into what's called the **alternate screen buffer**—a second, temporary display area separate from the main scrollback buffer.

        ### How it works
        They send ANSI escape sequences such as:
        ```bash
        # Enter alternate screen buffer
        echo -e \"\\\\e[?1049h\"

        # Exit (back to normal buffer)
        echo -e \"\\\\e[?1049l\"
        ```

        - `\\\\e[?1049h` — activates the alternate screen.
        - `\\\\e[?1049l` — deactivates it and restores the previous view.

        While in this mode:
        - The \"scrollback\" (your regular terminal history) is hidden.
        - The program gets a fresh, empty screen to draw on.
        - When the program exits, the screen restores exactly as it was before.

        ### tmux behavior
        `tmux` respects these escape sequences by default. When apps use the alternate buffer, tmux holds that screen separately from the main one. That's why, when you scroll in tmux during Vim, you don't see your shell history—you have to leave Vim first.

        If someone wants to **disable** this behavior (so the app draws on the main screen and you can scroll back freely), they can set:
        ```bash
        set -g terminal-overrides 'xterm*:smcup@:rmcup@'
        ```
        in their `~/.tmux.conf`, which disables use of the alternate buffer entirely.

        Would you like me to show how to conditionally toggle that behavior per app or session?
        """
        let result = (try remend(text_content))
        // Should NOT contain incomplete-link marker
        #expect(!(result).contains("streamdown:incomplete-link"))
        // Should preserve original content
        #expect(result.utf16.elementsEqual(text_content.utf16))
    }

    // code block handling — code-blocks.test.ts:169
    @Test("should not add extra __ after code block with underscores followed by bullet list (#300)")
    func test018() throws {
        let input = """
        ```css
        /* Commentary */

        [class*=\"WidgetTitle__Header\"] {
          font-size: 18px !important;
        }
        ```

        Notes and tips:
        * Use !important only where necessary in CSS.
        """
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual(input.utf16))
        #expect((result).range(of: trailingDoubleUnderscorePattern, options: .regularExpression) == nil)
    }

    // code block handling — code-blocks.test.ts:186
    @Test("should handle complete code blocks with underscores followed by asterisk list (#300)")
    func test019() throws {
        let input = "```python\ndef __init__(self):\n    pass\n```\n\n* List item"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual(input.utf16))
        #expect((result).range(of: trailingDoubleUnderscorePattern, options: .regularExpression) == nil)
    }

    // code block handling — code-blocks.test.ts:199
    @Test("should handle code blocks with underscores and following text with asterisks (#300)")
    func test020() throws {
        let input = "Here's some code:\n```javascript\nconst my__variable = \"test\";\nconst another_var = 5;\n```\n\nSome notes:\n* First note\n* Second note"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual(input.utf16))
        #expect((result).range(of: trailingDoubleUnderscorePattern, options: .regularExpression) == nil)
    }

    // code block handling — code-blocks.test.ts:215
    @Test("should not add stray * from [*] in mermaid code blocks")
    func test021() throws {
        let input = """
        Here's a state diagram:

        ```mermaid
        stateDiagram-v2
            [*] --> Idle
            Idle --> Loading: fetch()
            Loading --> Success: 200 OK
            Loading --> Error: 4xx/5xx
            Error --> Loading: retry()
            Success --> Idle: reset()
        ```
        """
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual(input.utf16))
    }

    // code block handling — code-blocks.test.ts:232
    @Test("should not add stray * from [*] in incomplete mermaid code blocks (streaming)")
    func test022() throws {
        let input = "Here's a state diagram:\n\n```mermaid\nstateDiagram-v2\n    [*] --> Idle\n    Idle --> Loading: fetch()"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual(input.utf16))
    }

    // code block handling — code-blocks.test.ts:244
    @Test("should not add stray * when emphasis exists outside code block with [*] inside")
    func test023() throws {
        let input = "*Note:* Here's a state diagram:\n\n```mermaid\nstateDiagram-v2\n    [*] --> Idle\n```"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual(input.utf16))
    }

    // code block handling — code-blocks.test.ts:256
    @Test("should still complete emphasis when * is only outside code blocks")
    func test024() throws {
        let input = "```mermaid\nstateDiagram-v2\n    [*] --> Idle\n```\n\nHere is *incomplete italic"
        let result = (try remend(input))
        #expect(result.utf16.elementsEqual("```mermaid\nstateDiagram-v2\n    [*] --> Idle\n```\n\nHere is *incomplete italic*".utf16))
    }

    // code block handling — code-blocks.test.ts:273
    @Test("should handle incomplete markdown after code block (#302)")
    func test025() throws {
        let text = "```css\ncode here\n```\n\n**incomplete bold"
        #expect((try remend(text)).utf16.elementsEqual("```css\ncode here\n```\n\n**incomplete bold**".utf16))
    }
}
