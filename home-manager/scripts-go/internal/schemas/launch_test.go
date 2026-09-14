package schemas

import (
	"bytes"
	"encoding/json"
	"io"
	"strings"
	"testing"
)

const fixture = `{
  "publisher":"STMicroelectronics", "name":"test-adapter", "version":"1.4.0",
  "contributes":{"debuggers":[{
    "type":"stlinkgdbtarget",
    "configurationAttributes":{
      "launch":{
        "required":["program","name"], "additionalProperties":false,
        "x-future-keyword":{"minimum":9007199254740993},
        "properties":{
          "program":{"type":"string","description":"%program%"},
          "enabled":{"type":"boolean","default":false},
          "commands":{"type":"array","default":[]},
          "optional":{"default":null},
          "mode":{"enum":["%mode%"],"default":"%mode%"}
        }
      },
      "attach":{"properties":{"port":{"type":"number"}}}
    }
  }]}
}`

func TestGenerateSchema(t *testing.T) {
	var warnings bytes.Buffer
	data, err := GenerateLaunch([]byte(fixture), []byte(`{"program":"Executable","mode":{"message":"auto"}}`), &warnings)
	if err != nil {
		t.Fatal(err)
	}
	if warnings.Len() != 0 {
		t.Fatal(warnings.String())
	}
	// Compact output for assertions without depending on indentation or key order.
	var compact bytes.Buffer
	if err := json.Compact(&compact, data); err != nil {
		t.Fatal(err)
	}
	for _, fragment := range []string{
		`"description":"Executable"`, `"enum":["auto"]`, `"default":"auto"`,
		`"default":false`, `"default":null`, `"default":[]`,
		`"x-future-keyword":{"minimum":9007199254740993}`,
		`"required":["name","type","request","program"]`,
		`"additionalProperties":false`, `"dap-compilation":`,
		`test-adapter@1.4.0`, `"const":"attach"`, `"const":"launch"`,
	} {
		if !strings.Contains(compact.String(), fragment) {
			t.Errorf("missing preserved/generated fragment: %s", fragment)
		}
	}
}

func TestMissingTranslation(t *testing.T) {
	var warnings bytes.Buffer
	data, err := GenerateLaunch([]byte(fixture), []byte(`{"mode":"auto"}`), &warnings)
	if err != nil {
		t.Fatal(err)
	}
	if !bytes.Contains(data, []byte(`%program%`)) || !strings.Contains(warnings.String(), "%program%") {
		t.Fatal("missing translation must be preserved and reported")
	}
}

func TestInvalidManifest(t *testing.T) {
	for name, input := range map[string]string{
		"wrong metadata type": strings.Replace(fixture, `"version":"1.4.0"`, `"version":123`, 1),
		"missing metadata":    strings.Replace(fixture, `"version":"1.4.0"`, `"version":null`, 1),
		"missing adapter":     strings.Replace(fixture, `"stlinkgdbtarget"`, `"other"`, 1),
		"missing attach":      strings.Replace(fixture, `"attach":`, `"other":`, 1),
		"null properties":     strings.Replace(fixture, `{"port":{"type":"number"}}`, `null`, 1),
		"invalid required":    strings.Replace(fixture, `["program","name"]`, `[1]`, 1),
		"null required entry": strings.Replace(fixture, `["program","name"]`, `[null]`, 1),
	} {
		t.Run(name, func(t *testing.T) {
			if _, err := GenerateLaunch([]byte(input), []byte(`{"program":"Executable","mode":"auto"}`), io.Discard); err == nil {
				t.Fatal("expected decoding or validation failure")
			}
		})
	}
}

func TestLocalizationIsLiteral(t *testing.T) {
	translations := map[string]translation{"first": "%second%", "second": "expanded"}
	if got := localize("%first%", translations, io.Discard); got != "%second%" {
		t.Fatalf("replacement was interpreted recursively: %v", got)
	}
}
