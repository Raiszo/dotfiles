import JSONSchemaBuilder
import JSONSchema

/// The common configuration fields, expressed using the library's schema DSL.
func commonConfiguration() -> some JSONSchemaComponent {
    JSONObject {
        JSONProperty(key: "name") { JSONString() }.required()
        JSONProperty(key: "type") { JSONString() }.required()
        JSONProperty(key: "request") { JSONString() }.required()
        JSONProperty(key: "dap-compilation") {
            JSONString().description("Command to run before starting the debug session.")
        }
        JSONProperty(key: "dap-compilation-dir") {
            JSONString().description("Working directory for the compilation command.")
        }
    }
}

/// Compose the generated envelope and upstream fragments using the library's JSONValue.
func launchDocument(
    name: String, publisher: String, version: String, requests: [JSONValue]
) -> JSONValue {
    var configuration = commonConfiguration()
    configuration.schemaValue["if"] = [
        "properties": ["type": ["const": "stlinkgdbtarget"]],
        "required": ["type"],
    ]
    configuration.schemaValue["then"] = ["oneOf": .array(requests)]
    let document = JSONObject {
        JSONProperty(key: "version") { JSONString().default("0.2.0") }
        JSONProperty(key: "configurations") {
            JSONArray { configuration }
        }
    }
    .schema("http://json-schema.org/draft-07/schema#")
    .title("Emacs launch.json — \(name) \(version)")
    .comment("Generated from \(publisher).\(name)@\(version)")

    return document.schemaValue.value
}
