package main

import (
	"encoding/json"
	"io"
	"os"
	"path/filepath"
	"testing"
)

func TestLaunchCommand(t *testing.T) {
	dir := t.TempDir()
	for name, content := range map[string]string{
		"package.json":     `{"publisher":"ST","name":"adapter","version":"1.4.0","contributes":{"debuggers":[{"type":"stlinkgdbtarget","configurationAttributes":{"launch":{"properties":{}},"attach":{"properties":{}}}}]}}`,
		"package.nls.json": `{}`,
	} {
		if err := os.WriteFile(filepath.Join(dir, name), []byte(content), 0o600); err != nil {
			t.Fatal(err)
		}
	}
	output := filepath.Join(dir, "launch.schema.json")
	if err := run([]string{"launch", "--extension-dir", dir, "--output", output}, io.Discard); err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(output)
	if err != nil {
		t.Fatal(err)
	}
	if !json.Valid(data) {
		t.Fatal("output is not JSON")
	}
}

func TestArguments(t *testing.T) {
	for _, args := range [][]string{nil, {"unknown"}, {"launch"}, {"launch", "--typo"}} {
		if err := run(args, io.Discard); err == nil {
			t.Errorf("expected error for %v", args)
		}
	}
	for _, args := range [][]string{{"--help"}, {"launch", "--help"}} {
		if err := run(args, io.Discard); err != nil {
			t.Errorf("help failed: %v", err)
		}
	}
}
