# Personal Swift tools

A Swift 6.1+ package alongside the shared Go module in `../scripts-go`.
The current Nix schema build continues to use Go.

```text
Package.swift
Package.resolved
Sources/
  GenerateJSONSchemas/GenerateJSONSchemas.swift   ArgumentParser commands
  JSONSchemas/
    JSONValue+Decoding.swift       Typed decoding helper for library JSONValue
    Schema.swift                   JSONSchemaBuilder DSL
    Launch.swift                   ST launch/attach schema generation
    Localization.swift             package.nls.json decoding and replacement
Tests/
  JSONSchemasTests/
  CommandTests/
```

From this directory:

```sh
swift test
swift run generate-json-schemas --help
swift run generate-json-schemas launch --help
swift run generate-json-schemas launch \
  --extension-dir /path/to/st-extension \
  --output /tmp/launch-swift.schema.json
```

For a compiled executable, run `swift build -c release`; the command is then
available at `.build/release/generate-json-schemas`.

## Libraries

- [Swift JSON Schema](https://github.com/ajevans99/swift-json-schema) provides
  `JSONSchemaBuilder`: `JSONObject`, `JSONProperty`, `JSONString`, and `JSONArray`
  define the fields and envelope we generate.
- [Swift ArgumentParser](https://github.com/apple/swift-argument-parser) provides
  `ParsableCommand` and `@Option`: subcommands, required options, help, diagnostics,
  and shell completion metadata are handled by the library.

`Package.resolved` records the selected releases and transitive dependencies.
The schema builder includes macro infrastructure, so its first build also
compiles SwiftSyntax even though this command uses the DSL without macros.

The input manifest uses `Decodable` structs. The library's `JSONValue` represents
upstream schema fragments and generated schemas throughout, preserving unknown
keywords, nulls, booleans, and empty arrays. Its numeric cases use `Int` and
`Double`; the generator no longer has a custom JSON value implementation.
The pinned ST schema produces the same JSON as the Go version.

This command emits draft-07 to match the existing Go schema; it uses the library
for construction, not its draft-2020-12 validator. Missing translation keys warn
and retain their placeholders. Output key order and formatting may differ from Go.

## Adding tools

Create `Sources/YourTool/`, then add an executable product and target in
`Package.swift`. Model its CLI as a `ParsableCommand`, with nested command types
for subcommands. Shared code belongs in library targets such as `JSONSchemas`.
Add future schemas to that target and register another subcommand alongside
`GenerateJSONSchemas.Launch`.
