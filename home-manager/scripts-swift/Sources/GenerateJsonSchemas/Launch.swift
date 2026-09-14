import Foundation
import JSONSchema

private let adapterType = "stlinkgdbtarget"

private struct Manifest: Decodable {
    let publisher: String
    let name: String
    let version: String
    let contributes: Contributions
}

private struct Contributions: Decodable {
    let debuggers: [Debugger]
}

private struct Debugger: Decodable {
    let type: String
    let configurationAttributes: ConfigurationAttributes?
}

private struct ConfigurationAttributes: Decodable {
    let launch: JSONValue
    let attach: JSONValue
}

private struct RequestFields: Decodable {
    var properties: [String: JSONValue]
    // Validate upstream required entries while preserving the original array.
    let required: [String]?
}

private struct SchemaError: Error, CustomStringConvertible {
    let description: String
}

private func configurationSchema(_ value: JSONValue, request: String) throws -> JSONValue {
    var source = try value.decoded(as: [String: JSONValue].self)
    var fields = try value.decoded(as: RequestFields.self)
    fields.properties["request"] = .object(["const": .string(request)])
    // source["properties"] = .object(.init(uniqueKeysWithValues: fields.properties.sorted { $0.key < $1.key }))
    // return .object(.init(uniqueKeysWithValues: source.sorted { $0.key < $1.key }))
    source["properties"] = .object(.init(uniqueKeysWithValues: fields.properties ))
    return .object(.init(uniqueKeysWithValues: source))
}

/// Generate a personal launch.json schema from the exact adapter manifest and default translations.
/// Unknown upstream schema keywords are preserved; missing translations are reported and retained.
public func generateLaunch(
    manifestData: Data, translationData: Data, warn: (String) -> Void = { _ in }
) throws -> Data {
    let decoder = JSONDecoder()
    let manifest = try decoder.decode(Manifest.self, from: manifestData)
    guard !manifest.publisher.isEmpty, !manifest.name.isEmpty, !manifest.version.isEmpty else {
        throw SchemaError(description: "Manifest requires publisher, name, and version")
    }
    let translations = try decoder.decode([String: Translation].self, from: translationData)
    let matches = manifest.contributes.debuggers.filter { $0.type == adapterType }
    guard matches.count == 1, let attributes = matches[0].configurationAttributes else {
        throw SchemaError(description: "Expected exactly one \(adapterType) debugger with configurationAttributes")
    }
    let requests = try [
        configurationSchema(localize(attributes.launch, using: translations, warn: warn), request: "launch"),
        configurationSchema(localize(attributes.attach, using: translations, warn: warn), request: "attach"),
    ]
    let document = launchDocument(
        name: manifest.name, publisher: manifest.publisher,
        version: manifest.version, requests: requests
    )
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
    var output = try encoder.encode(document)
    output.append(0x0A)
    return output
}
