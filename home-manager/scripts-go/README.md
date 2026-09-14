# Personal Go tools

This directory is one Go module. Each executable lives in `cmd/<tool>/`;
supporting packages live in `internal/`. Add future tools under `cmd/` without
creating another `go.mod`.

From this directory:

```sh
go test ./...
go run ./cmd/generate-json-schemas launch \
  --extension-dir /path/to/st-extension \
  --output /tmp/launch.schema.json
```

`generate-json-schemas` generates personal JSON schemas. Its first subcommand,
`launch`, combines ST's adapter metadata with Emacs-specific properties. Add
future schema generators to `internal/schemas/` and register their subcommands
in `cmd/generate-json-schemas/main.go`.

`github.com/google/jsonschema-go/jsonschema` supplies the generated schema types.
`internal/schemas/schema.go` contains helpers for constants and preservation of
upstream schema fields;
`launch.go` handles launch configurations, and `localization.go` resolves ST's
translation placeholders. The previous JavaScript implementation and its tests
remain together in `legacy/`.

Nix builds this command through `../packages/json-schemas.nix`, selecting
`cmd/generate-json-schemas` with `subPackages`. Other tools can have their own
Nix packages pointing to the same module with different `subPackages`.

The Google library is pinned in `go.mod` and `go.sum`. Upstream schemas are
inserted as raw JSON after serializing the generated envelope, preserving unknown
keywords, explicit false/null values, and numeric precision. The fields we add
use the library's typed `Schema` API; the custom schema structs have been removed.
