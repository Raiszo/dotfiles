package schemas

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"regexp"
)

// translation accepts both string messages and VS Code's message objects.
type translation string

func (t *translation) UnmarshalJSON(data []byte) error {
	var message string
	if err := json.Unmarshal(data, &message); err == nil && !bytes.Equal(bytes.TrimSpace(data), []byte("null")) {
		*t = translation(message)
		return nil
	}
	var entry struct {
		Message *string `json:"message"`
	}
	if err := json.Unmarshal(data, &entry); err != nil {
		return fmt.Errorf("decode translation: %w", err)
	}
	if entry.Message == nil {
		return fmt.Errorf("translation must be a string or an object with a string message")
	}
	*t = translation(*entry.Message)
	return nil
}

var placeholder = regexp.MustCompile(`^%([^%]+)%$`)

// localize replaces whole-string placeholders without interpreting replacement text.
// Walking generic JSON here preserves false, null, empty arrays, and unknown keywords.
func localize(value any, translations map[string]translation, warnings io.Writer) any {
	switch value := value.(type) {
	case string:
		match := placeholder.FindStringSubmatch(value)
		if match == nil {
			return value
		}
		if message, ok := translations[match[1]]; ok {
			return string(message)
		}
		fmt.Fprintf(warnings, "Missing translation (preserved): %s\n", value)
	case []any:
		for i, item := range value {
			value[i] = localize(item, translations, warnings)
		}
	case map[string]any:
		for key, item := range value {
			value[key] = localize(item, translations, warnings)
		}
	}
	return value
}
