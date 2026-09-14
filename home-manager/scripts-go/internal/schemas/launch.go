// Package schemas generates personal JSON schemas from pinned upstream metadata.
package schemas

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"

	"github.com/google/jsonschema-go/jsonschema"
)

const adapterType = "stlinkgdbtarget"

type manifest struct {
	Publisher   string `json:"publisher"`
	Name        string `json:"name"`
	Version     string `json:"version"`
	Contributes struct {
		Debuggers []debugger `json:"debuggers"`
	} `json:"contributes"`
}

type debugger struct {
	Type                    string                     `json:"type"`
	ConfigurationAttributes map[string]json.RawMessage `json:"configurationAttributes"`
}

// requestSchema describes only the fields the generator needs to modify.
type requestSchema struct {
	Properties schemaObject `json:"properties"`
	Required   []*string    `json:"required"`
}

func commonProperties() map[string]*jsonschema.Schema {
	return map[string]*jsonschema.Schema{
		"name":    {Type: "string"},
		"type":    {Type: "string"},
		"request": {Type: "string"},
		"dap-compilation": {
			Type: "string", Description: "Command to run before starting the debug session.",
		},
		"dap-compilation-dir": {
			Type: "string", Description: "Working directory for the compilation command.",
		},
	}
}

// configurationSchema merges known fields while preserving arbitrary schema keywords.
func configurationSchema(data json.RawMessage, request string) (schemaObject, error) {
	var source schemaObject
	if err := json.Unmarshal(data, &source); err != nil {
		return nil, fmt.Errorf("decode %s schema: %w", request, err)
	}
	var fields requestSchema
	if err := json.Unmarshal(data, &fields); err != nil {
		return nil, fmt.Errorf("decode %s fields: %w", request, err)
	}
	if fields.Properties == nil {
		return nil, fmt.Errorf("missing %s properties", request)
	}
	for key, value := range commonProperties() {
		fields.Properties[key] = raw(value)
	}
	fields.Properties["type"] = raw(constant(adapterType))
	fields.Properties["request"] = raw(constant(request))
	required := []string{"name", "type", "request"}
	seen := map[string]bool{"name": true, "type": true, "request": true}
	for _, entry := range fields.Required {
		if entry == nil {
			return nil, fmt.Errorf("null required entry for %s", request)
		}
		key := *entry
		if !seen[key] {
			required = append(required, key)
			seen[key] = true
		}
	}
	source["type"] = raw("object")
	source["properties"] = raw(fields.Properties)
	source["required"] = raw(required)
	return source, nil
}

// GenerateLaunch uses typed decoding for the manifest and lossless JSON for schema contents.
func GenerateLaunch(manifestData, translationData []byte, warnings io.Writer) ([]byte, error) {
	var metadata manifest
	if err := json.Unmarshal(manifestData, &metadata); err != nil {
		return nil, fmt.Errorf("decode manifest: %w", err)
	}
	if metadata.Publisher == "" || metadata.Name == "" || metadata.Version == "" {
		return nil, fmt.Errorf("manifest requires publisher, name, and version")
	}
	var translations map[string]translation
	if err := json.Unmarshal(translationData, &translations); err != nil {
		return nil, fmt.Errorf("decode package.nls.json: %w", err)
	}
	if translations == nil {
		return nil, fmt.Errorf("package.nls.json must be an object")
	}
	var matches []debugger
	for _, candidate := range metadata.Contributes.Debuggers {
		if candidate.Type == adapterType {
			matches = append(matches, candidate)
		}
	}
	if len(matches) != 1 {
		return nil, fmt.Errorf("expected exactly one %s debugger", adapterType)
	}
	// Localize upstream attributes before adding our own schema fields.
	var attributes any
	decoder := json.NewDecoder(bytes.NewReader(raw(matches[0].ConfigurationAttributes)))
	decoder.UseNumber() // Avoid rounding large integer constraints through float64.
	if err := decoder.Decode(&attributes); err != nil {
		return nil, err
	}
	var localized map[string]json.RawMessage
	if err := json.Unmarshal(raw(localize(attributes, translations, warnings)), &localized); err != nil {
		return nil, err
	}
	requests := make([]schemaObject, 0, 2)
	for _, request := range []string{"launch", "attach"} {
		schema, err := configurationSchema(localized[request], request)
		if err != nil {
			return nil, err
		}
		requests = append(requests, schema)
	}
	// The output envelope is deliberately permissive for other adapter types.
	schema := jsonschema.Schema{
		Schema:  "http://json-schema.org/draft-07/schema#",
		Title:   fmt.Sprintf("Emacs launch.json — %s %s", metadata.Name, metadata.Version),
		Comment: fmt.Sprintf("Generated from %s.%s@%s", metadata.Publisher, metadata.Name, metadata.Version),
		Type:    "object",
		Properties: map[string]*jsonschema.Schema{
			"version": {Type: "string", Default: raw("0.2.0")},
			"configurations": {
				Type: "array",
				Items: &jsonschema.Schema{
					Type: "object", Properties: commonProperties(),
					Required: []string{"name", "type", "request"},
					If: &jsonschema.Schema{
						Properties: map[string]*jsonschema.Schema{"type": constant(adapterType)},
						Required:   []string{"type"},
					},
				},
			},
		},
	}
	data, err := json.Marshal(schema)
	if err != nil {
		return nil, err
	}
	// Keep imported request schemas verbatim: Schema.Extra only accepts unknown
	// keywords, and decoding known keywords can normalize their values.
	data, err = insertRaw(data, []string{"properties", "configurations", "items", "then"},
		raw(map[string]any{"oneOf": requests}))
	if err != nil {
		return nil, err
	}
	var output bytes.Buffer
	if err := json.Indent(&output, data, "", "  "); err != nil {
		return nil, err
	}
	return append(output.Bytes(), '\n'), nil
}
