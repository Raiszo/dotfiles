import JSONSchema
import JSONSchemaBuilder

func launchDocument(
    name: String, publisher: String, version: String, launchRequest: JSONValue, attachRequest: JSONValue
) -> JSONValue {
    let conditions: [JSONValue] = [("launch", launchRequest), ("attach", attachRequest)].map { request, schema in
        [
            "title": .string("stlinkgdbtarget — \(name) \(version)"),
            "$comment": .string("Generated from \(publisher).\(name)@\(version)"),
            "if": [
                "properties": [
                    "type": ["const": "stlinkgdbtarget"],
                    "request": ["const": .string(request)],
                ],
                "required": ["type", "request"],
            ],
            "then": schema,
        ]
    }

    // Used for schema emission only; JSONAnyValue does not validate instances.
    var configuration = JSONAnyValue()
    configuration.schemaValue = [
        "type": "object",
        "properties": [
            "name": ["type": "string"],
            "type": ["type": "string"],
            // There are only two requests
            // https://code.visualstudio.com/docs/debugtest/debugging-configuration#_launch-versus-attach-configurations
            "request": ["type": "string", "enum": ["launch", "attach"]],
            "dap-compilation": [
                "type": "string",
                "description": "Command to run before starting the debug session.",
            ],
            "dap-compilation-dir": [
                "type": "string",
                "description": "Working directory for the compilation command.",
            ],
        ],
        "required": ["name", "type", "request"],
        "allOf": .array(conditions),
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
