import Foundation
import JSONSchema
import XCTest
@testable import JSONSchemas

final class LaunchTests: XCTestCase {
    private let fixture = #"""
    {
      "publisher":"STMicroelectronics","name":"test-adapter","version":"1.4.0",
      "contributes":{"debuggers":[{"type":"stlinkgdbtarget","configurationAttributes":{
        "launch":{"required":["program","name"],"additionalProperties":false,
          "x-future-keyword":{"minimum":9007199254740993},
          "properties":{
            "program":{"type":"string","description":"%program%"},
            "enabled":{"default":false},"commands":{"default":[]},
            "optional":{"default":null},"mode":{"enum":["%mode%"],"default":"%mode%"}
          }},
        "attach":{"properties":{}}
      }}]}
    }
    """#

    func testPreservesAndLocalizesSchemas() throws {
        var warnings: [String] = []
        let data = try generateLaunch(
            manifestData: Data(fixture.utf8),
            translationData: Data(#"{"program":"Executable","mode":{"message":"auto"}}"#.utf8),
            warn: { warnings.append($0) }
        )
        XCTAssertTrue(warnings.isEmpty)
        let document = try JSONDecoder().decode([String: JSONValue].self, from: data)
        var node = JSONValue.object(.init(uniqueKeysWithValues: document))
        for key in ["properties", "configurations", "items", "then"] {
            node = try XCTUnwrap(node.decoded(as: [String: JSONValue].self)[key])
        }
        let alternatives = try XCTUnwrap(node.decoded(as: [String: JSONValue].self)["oneOf"])
            .decoded(as: [[String: JSONValue]].self)
        let launch = try XCTUnwrap(alternatives.first)
        let properties = try XCTUnwrap(launch["properties"]).decoded(as: [String: JSONValue].self)
        XCTAssertEqual(properties["program"], .object(["type": .string("string"), "description": .string("Executable")]))
        XCTAssertEqual(properties["enabled"], .object(["default": .boolean(false)]))
        XCTAssertEqual(properties["commands"], .object(["default": .array([])]))
        XCTAssertEqual(properties["optional"], .object(["default": .null]))
        XCTAssertEqual(properties["mode"], .object(["enum": .array([.string("auto")]), "default": .string("auto")]))
        XCTAssertEqual(launch["x-future-keyword"], .object(["minimum": .integer(9007199254740993)]))
        XCTAssertEqual(launch["required"], .array(["name", "type", "request", "program"].map(JSONValue.string)))
        XCTAssertEqual(launch["additionalProperties"], .boolean(false))
        XCTAssertNotNil(properties["dap-compilation"])
        XCTAssertEqual(document["$comment"], .string("Generated from STMicroelectronics.test-adapter@1.4.0"))
    }

    func testMissingTranslationIsPreservedAndReported() throws {
        var warnings: [String] = []
        let data = try generateLaunch(
            manifestData: Data(fixture.utf8), translationData: Data(#"{"mode":"auto"}"#.utf8),
            warn: { warnings.append($0) })
        XCTAssertTrue(String(decoding: data, as: UTF8.self).contains("%program%"))
        XCTAssertEqual(warnings, ["Missing translation (preserved): %program%"])
    }

    func testRejectsInvalidManifestFields() {
        for (before, after) in [
            (#""version":"1.4.0""#, #""version":null"#),
            (#""version":"1.4.0""#, #""version":123"#),
            (#""attach":"#, #""other":"#),
            (#"["program","name"]"#, "[null]"),
        ] {
            let input = fixture.replacingOccurrences(of: before, with: after)
            XCTAssertThrowsError(try generateLaunch(
                manifestData: Data(input.utf8), translationData: Data("{}".utf8)))
        }
    }

    func testLocalizationDoesNotReinterpretMessages() throws {
        let translations = try JSONDecoder().decode(
            [String: Translation].self, from: Data(#"{"first":"%second%","second":"expanded"}"#.utf8))
        XCTAssertEqual(localize(.string("%first%"), using: translations, warn: { _ in }), .string("%second%"))
    }
}
