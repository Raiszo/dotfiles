package schemas

import (
	"encoding/json"
	"github.com/google/jsonschema-go/jsonschema"
)

// schemaObject retains every upstream keyword, including ones we do not inspect.
type schemaObject map[string]json.RawMessage

// insertRaw adds an upstream schema fragment after typed schema serialization.
// This avoids normalizing imported JSON through the library's numeric/boolean fields.
func insertRaw(data json.RawMessage, path []string, value json.RawMessage) (json.RawMessage, error) {
	if len(path) == 0 {
		return value, nil
	}
	var object schemaObject
	if err := json.Unmarshal(data, &object); err != nil {
		return nil, err
	}
	child, err := insertRaw(object[path[0]], path[1:], value)
	if err != nil {
		return nil, err
	}
	object[path[0]] = child
	return json.Marshal(object)
}

// constant represents JSON const, including null, using the library's pointer API.
func constant(value any) *jsonschema.Schema {
	return &jsonschema.Schema{Const: &value}
}

// raw encodes internally constructed JSON values; these never contain unsupported types.
func raw(value any) json.RawMessage {
	data, err := json.Marshal(value)
	if err != nil {
		panic(err)
	}
	return data
}
