# Personal Swift tools

```sh
swift test
swift run generate-json-schemas --help
swift run generate-json-schemas launch --help
swift run generate-json-schemas launch \
  --stlink-extension-dir /path/to/st-extension \
  --output /tmp/launch-swift.schema.json
```

For a compiled executable, run `swift build -c release`; the command is then
available at `.build/release/generate-json-schemas`.

## Adding tools

Create `Sources/YourTool/`, then add an executable product and target in
`Package.swift`. Model its CLI as a `ParsableCommand`, with nested command types
for subcommands. Keep each tool's implementation in its own target folder;
extract a library target if multiple tools need to share code.
Add future schemas to `GenerateJsonSchemas` and register another subcommand
alongside `GenerateJsonSchemas.Launch`. Put each tool's tests in
`Tests/YourToolTests/` and declare a matching test target.
