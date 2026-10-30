/// The incomplete-link rendering strategy used by remend 1.3.1.
public enum RemendLinkMode: String, Sendable {
    case `protocol`
    case textOnly = "text-only"
}

/// A synchronous custom handler. Equal priorities preserve declaration order; the default priority is 100.
/// Use finite priorities. NaN breaks the comparator's total ordering, so order is not guaranteed across JavaScript engines and Swift.
public struct RemendHandler: Sendable {
    public let name: String
    public let priority: Double
    public let handle: @Sendable (String) throws -> String

    public init(name: String, priority: Double = 100, handle: @escaping @Sendable (String) throws -> String) {
        self.name = name
        self.priority = priority
        self.handle = handle
    }
}

/// Options matching remend 1.3.1, including its original math and link defaults.
public struct RemendOptions: Sendable {
    public var bold: Bool
    public var boldItalic: Bool
    public var comparisonOperators: Bool
    public var handlers: [RemendHandler]
    public var htmlTags: Bool
    public var images: Bool
    public var inlineCode: Bool
    /// Single-dollar math completion is opt-in because a dollar sign can indicate currency.
    public var inlineKatex: Bool
    public var italic: Bool
    /// Double-dollar math completion is enabled by default, as in upstream remend.
    public var katex: Bool
    public var linkMode: RemendLinkMode
    public var links: Bool
    public var setextHeadings: Bool
    public var singleTilde: Bool
    public var strikethrough: Bool

    public init(bold: Bool = true, boldItalic: Bool = true, comparisonOperators: Bool = true,
                handlers: [RemendHandler] = [], htmlTags: Bool = true, images: Bool = true,
                inlineCode: Bool = true, inlineKatex: Bool = false, italic: Bool = true,
                katex: Bool = true, linkMode: RemendLinkMode = .protocol, links: Bool = true,
                setextHeadings: Bool = true, singleTilde: Bool = true, strikethrough: Bool = true) {
        self.bold = bold
        self.boldItalic = boldItalic
        self.comparisonOperators = comparisonOperators
        self.handlers = handlers
        self.htmlTags = htmlTags
        self.images = images
        self.inlineCode = inlineCode
        self.inlineKatex = inlineKatex
        self.italic = italic
        self.katex = katex
        self.linkMode = linkMode
        self.links = links
        self.setextHeadings = setextHeadings
        self.singleTilde = singleTilde
        self.strikethrough = strikethrough
    }
}
