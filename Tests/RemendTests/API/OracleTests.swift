import Foundation
import Remend
import Testing

struct OracleTests {
    private struct Fixture: Decodable {
        let profiles: [Profile]
        let cases: [RepairCase]
        let helperCases: [HelperCase]
        let wordCases: [WordCase]
    }
    private struct RepairCase: Decodable {
        let id: String, profile: String, input: String, expected: String
    }
    private struct HelperCase: Decodable {
        let input: String
        let position: Int
        let code: Bool, math: Bool, url: Bool
    }
    private struct WordCase: Decodable {
        let input: String
        let expected: Bool
    }
    private struct Handler: Decodable {
        let name: String
        let priority: Double?
        let kind: String
        let value: String
        var handler: RemendHandler {
            RemendHandler(name: name, priority: priority ?? 100) { source in kind == "prefix" ? value + source : source + value }
        }
    }
    private struct Options: Decodable {
        let bold: Bool?, boldItalic: Bool?, comparisonOperators: Bool?, htmlTags: Bool?, images: Bool?
        let inlineCode: Bool?, inlineKatex: Bool?, italic: Bool?, katex: Bool?, linkMode: String?
        let links: Bool?, setextHeadings: Bool?, singleTilde: Bool?, strikethrough: Bool?
    }
    private struct Profile: Decodable {
        let id: String
        let options: Options
        let handlers: [Handler]?
        var configuration: RemendOptions {
            .init(bold: options.bold ?? true, boldItalic: options.boldItalic ?? true, comparisonOperators: options.comparisonOperators ?? true,
                  handlers: handlers?.map(\.handler) ?? [], htmlTags: options.htmlTags ?? true, images: options.images ?? true,
                  inlineCode: options.inlineCode ?? true, inlineKatex: options.inlineKatex ?? false, italic: options.italic ?? true,
                  katex: options.katex ?? true, linkMode: options.linkMode == "text-only" ? .textOnly : .protocol,
                  links: options.links ?? true, setextHeadings: options.setextHeadings ?? true, singleTilde: options.singleTilde ?? true,
                  strikethrough: options.strikethrough ?? true)
        }
    }

    @Test func matchesFrozenUpstreamRepairAndHelperOutputs() throws {
        let url = try #require(Bundle.module.url(forResource: "results", withExtension: "json", subdirectory: "Fixtures"))
        let fixture = try JSONDecoder().decode(Fixture.self, from: Data(contentsOf: url))
        let profiles = Dictionary(uniqueKeysWithValues: fixture.profiles.map { ($0.id, $0.configuration) })
        var differences = 0
        for sample in fixture.cases {
            let options = try #require(profiles[sample.profile])
            let actual = try remend(sample.input, options: options)
            if !actual.utf8.elementsEqual(sample.expected.utf8) {
                differences += 1
                if differences <= 20 { Issue.record("\(sample.id): input=\(sample.input.debugDescription) expected=\(sample.expected.debugDescription) actual=\(actual.debugDescription)") }
            }
        }
        for sample in fixture.helperCases {
            #expect(isWithinCodeBlock(sample.input, position: sample.position) == sample.code, "code: \(sample.input.debugDescription) @ \(sample.position)")
            #expect(isWithinMathBlock(sample.input, position: sample.position) == sample.math, "math: \(sample.input.debugDescription) @ \(sample.position)")
            #expect(isWithinLinkOrImageUrl(sample.input, position: sample.position) == sample.url, "url: \(sample.input.debugDescription) @ \(sample.position)")
        }
        for sample in fixture.wordCases { #expect(isWordChar(sample.input) == sample.expected, "word: \(sample.input.debugDescription)") }
        #expect(fixture.cases.count == 16913)
        #expect(fixture.helperCases.count == 1524)
        #expect(fixture.wordCases.count == 16)
        #expect(differences == 0)
    }
}
