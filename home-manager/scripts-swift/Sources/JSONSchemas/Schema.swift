import JSONSchemaBuilder
import JSONSchema

// Optional fields may be omitted, but must remain strings when present.
@Schemable(optionalNulls: false)
struct DebugConfiguration {
    let name: String
    let type: String
    let request: String

    /// Command to run before starting the debug session.
    let dapCompilation: String?

    /// Working directory for the compilation command.
    let dapCompilationDir: String?

    enum CodingKeys: String, CodingKey {
        case name, type, request
        case dapCompilation = "dap-compilation"
        case dapCompilationDir = "dap-compilation-dir"
    }
}

/// Compose the generated envelope and upstream fragments using the library's JSONValue.
func launchDocument(
    name: String, publisher: String, version: String, requests: [JSONValue]
) -> JSONValue {
    var configuration = DebugConfiguration.schema
    // Add another conditional here when supporting another adapter's schema.
    configuration.schemaValue["allOf"] = [
        [
            "title": .string("stlinkgdbtarget — \(name) \(version)"),
            "$comment": .string("Generated from \(publisher).\(name)@\(version)"),
            "if": [
                "properties": ["type": ["const": "stlinkgdbtarget"]],
                "required": ["type"],
            ],
            "then": ["oneOf": .array(requests)],
        ],
    ]
    let document = JSONObject {
        JSONProperty(key: "version") { JSONString().default("0.2.0") }
        JSONProperty(key: "configurations") {
            JSONArray { configuration }
        }
    }
    .schema("http://json-schema.org/draft-07/schema#")
    .title("Emacs launch.json")

    return document.schemaValue.value
}
