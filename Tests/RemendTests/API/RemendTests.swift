import Foundation
import Remend
import Testing

private final class CallTrace: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String] = []
    func append(_ value: String) { lock.withLock { storage.append(value) } }
    var calls: [String] { lock.withLock { storage } }
}

struct RemendTests {
    private func customOnly(_ handlers: [RemendHandler]) -> RemendOptions {
        .init(bold: false, boldItalic: false, comparisonOperators: false, handlers: handlers, htmlTags: false, images: false,
              inlineCode: false, inlineKatex: false, italic: false, katex: false, links: false, setextHeadings: false,
              singleTilde: false, strikethrough: false)
    }

    @Test func upstreamDefaultsIncludeBlockMathAndProtocolLinks() throws {
        #expect(try remend("bold **text") == "bold **text**")
        #expect(try remend("$$x") == "$$x$$")
        #expect(try remend("$x") == "$x")
        #expect(try remend("[label](url") == "[label](streamdown:incomplete-link)")
        #expect(try remend("[label](url", options: .init(linkMode: .textOnly)) == "label")
    }

    @Test func finitePrioritiesPreserveStableOrderAndErrorsStopTheChain() throws {
        for (priorities, expected): ([Double], String) in [([100, 0.5, -1], "x210"), ([1, 1, 0], "x201"), ([0, 0, 0], "x012")] {
            let handlers = priorities.enumerated().map { index, priority in
                RemendHandler(name: String(index), priority: priority) { $0 + String(index) }
            }
            #expect(try remend("x", options: customOnly(handlers)) == expected)
        }
        enum Failure: Error { case expected }
        let trace = CallTrace()
        let first = RemendHandler(name: "first", priority: -1) { source in trace.append("first"); return source }
        let throwing = RemendHandler(name: "throwing", priority: 0) { _ in trace.append("throwing"); throw Failure.expected }
        let later = RemendHandler(name: "later", priority: 1) { source in trace.append("later"); return source }
        #expect(throws: Failure.self) { try remend("content", options: customOnly([later, throwing, first])) }
        #expect(trace.calls == ["first", "throwing"])
    }

    @Test func nonTotalPriorityInputsStillExecuteEveryHandlerWithoutTrapping() throws {
        // NaN makes upstream's subtracting comparator non-total. Do not freeze a V8-specific order.
        for priorities: [Double] in [[100, .nan, 0], [.nan, 100, 0], [.infinity, -.infinity, .nan, 10]] {
            let handlers = priorities.enumerated().map { index, priority in RemendHandler(name: String(index), priority: priority) { $0 + String(index) } }
            let actual = try remend("x", options: customOnly(handlers))
            #expect(actual.sorted() == ("x" + priorities.indices.map(String.init).joined()).sorted())
        }
    }

    @Test func protocolEarlyReturnSkipsLaterHandlersAndEmptyInputSkipsAll() throws {
        let trace = CallTrace()
        let handler = RemendHandler(name: "later") { source in trace.append(source); return source + "tail" }
        #expect(try remend("", options: .init(handlers: [handler])) == "")
        #expect(try remend("[link", options: .init(handlers: [handler])) == "[link](streamdown:incomplete-link)")
        #expect(trace.calls.isEmpty)
        #expect(try remend("[link", options: .init(handlers: [handler], linkMode: .textOnly)) == "linktail")
        #expect(trace.calls == ["link"])
    }

    @Test func independentCallsDoNotShareMutableScannerState() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0 ..< 16 {
                group.addTask { () async throws -> Void in
                    let source = index.isMultiple(of: 2) ? "`literal **open`" : "plain **open"
                    let expected = index.isMultiple(of: 2) ? source : source + "**"
                    #expect(try remend(source) == expected)
                }
            }
            try await group.waitForAll()
        }
    }
}
