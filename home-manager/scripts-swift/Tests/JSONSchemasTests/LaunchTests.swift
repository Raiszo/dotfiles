import Foundation
import JSONSchema
import Testing
@testable import JSONSchemas

struct LaunchTests {
    private let fixture = #"""
    {
      "publisher":"STMicroelectronics",
      "name":"test-adapter",
      "version":"1.4.0",
      "contributes":{"debuggers":[{"type":"stlinkgdbtarget","configurationAttributes":{
        "launch":{
          "required":["program","name"],
          "x-future-keyword":{"minimum":9007199254740993},
          "properties":{
            "program":{"type":"string","description":"%program%"},
            "enabled":{"default":false},
            "commands":{"default":[]},
            "optional":{"default":null},
            "mode":{"enum":["%mode%"],"default":"%mode%"}
          }},
        "attach":{"properties":{}}
      }}]}
    }
    """#

    @Test("correctly generates schema using correct translations")
    func generateSchemaWithTranslations() throws {
        var warnings: [String] = []
        let data = try generateLaunch(
            manifestData: Data(fixture.utf8),
            translationData: Data(#"{"program":"Executable","mode":{"message":"auto"}}"#.utf8),
            warn: { warnings.append($0) }
        )
        #expect(warnings.isEmpty)
        let expectedURL = try #require(Bundle.module.url(
            forResource: "expected-launch.schema", withExtension: "json", subdirectory: "Fixtures"
        ))
        let decoder = JSONDecoder()
        let actual = try decoder.decode(JSONValue.self, from: data)
        let expected = try decoder.decode(JSONValue.self, from: Data(contentsOf: expectedURL))
        // Object key order is ignored; array order remains significant.
        #expect(actual == expected)
    }

    @Test
    func testMissingTranslationIsPreservedAndReported() throws {
        var warnings: [String] = []
        let data = try generateLaunch(
            manifestData: Data(fixture.utf8), translationData: Data(#"{"mode":"auto"}"#.utf8),
            warn: { warnings.append($0) })
        #expect(String(decoding: data, as: UTF8.self).contains("%program%"))
        #expect(warnings == ["Missing translation (preserved): %program%"])
    }

    @Test
    func testRejectsInvalidManifestFields() {
        for (before, after) in [
            (#""version":"1.4.0""#, #""version":null"#),
            (#""version":"1.4.0""#, #""version":123"#),
            (#""attach":"#, #""other":"#),
            (#"["program","name"]"#, "[null]"),
        ] {
            let input = fixture.replacingOccurrences(of: before, with: after)
            #expect(throws: (any Error).self) {
                try generateLaunch(
                    manifestData: Data(input.utf8), translationData: Data("{}".utf8))
            }
        }
    }

    @Test
    func testLocalizationDoesNotReinterpretMessages() throws {
        let translations = try JSONDecoder().decode(
            [String: Translation].self, from: Data(#"{"first":"%second%","second":"expanded"}"#.utf8))
        #expect(localize(.string("%first%"), using: translations, warn: { _ in }) == .string("%second%"))
    }
}
