import Foundation
import JSONSchema

/// A translation entry in VS Code's extension-manifest localization format.
///
/// The installed ST adapter 1.4.0 uses strings exclusively across its 15
/// package.nls*.json files (1,140 entries). Object decoding supports the broader
/// VS Code format, not a format observed in those ST files.
/// VS Code's ITranslations accepts strings or { message: string, comment: string[] };
/// its manifest localizer reads the string or the object's message field.
/// Source: https://github.com/microsoft/vscode/blob/main/src/vs/platform/extensionManagement/common/extensionNls.ts
/// Example: welcome.publishFolder in VS Code's GitHub extension uses a message object.
/// https://github.com/microsoft/vscode/blob/main/extensions/github/package.nls.json
enum Translation: Decodable {
    case text(String)
    case annotated(Entry)

    struct Entry: Decodable {
        let message: String
        // Translator guidance is retained but is not used for substitution.
        let comment: [String]?
    }

    var message: String {
        switch self {
        case .text(let text):
            return text
        case .annotated(let entry):
            return entry.message
        }
    }

    // VS Code's JSON has no enum-case wrapper; select the case from its shape.
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            self = .text(text)
        } else {
            self = .annotated(try container.decode(Entry.self))
        }
    }
}

/// Replace whole-string placeholders once, leaving replacement messages literal.
func localize(_ value: JSONValue, using translations: [String: Translation], warn: (String) -> Void) -> JSONValue {
    switch value {
    case .string(let text):
        guard text.count > 2, text.first == "%", text.last == "%" else { return value }
        let key = String(text.dropFirst().dropLast())
        guard !key.contains("%") else { return value }
        guard let translation = translations[key] else {
            warn("Missing translation (preserved): \(text)")
            return value
        }
        return .string(translation.message)
    case .array(let values):
        return .array(values.map { localize($0, using: translations, warn: warn) })
    case .object(let values):
        return .object(values.mapValues { localize($0, using: translations, warn: warn) })
    default:
        return value
    }
}
