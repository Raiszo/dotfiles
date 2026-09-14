// Command generate-json-schemas generates personal JSON schemas.
package main

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"dotfiles/scripts-go/internal/schemas"
)

func run(args []string, diagnostics io.Writer) error {
	if len(args) == 0 {
		return fmt.Errorf("usage: generate-json-schemas launch --extension-dir DIR --output FILE")
	}
	if args[0] == "-h" || args[0] == "--help" {
		fmt.Fprintln(diagnostics, "Usage: generate-json-schemas launch --extension-dir DIR --output FILE")
		return nil
	}
	if args[0] != "launch" {
		return fmt.Errorf("unknown schema %q; available schemas: launch", args[0])
	}
	flags := flag.NewFlagSet("launch", flag.ContinueOnError)
	flags.SetOutput(diagnostics)
	extensionDir := flags.String("extension-dir", "", "ST adapter extension directory")
	output := flags.String("output", "", "Destination JSON schema file")
	if err := flags.Parse(args[1:]); err != nil {
		if errors.Is(err, flag.ErrHelp) {
			return nil
		}
		return err
	}
	if *extensionDir == "" || *output == "" || flags.NArg() != 0 {
		return fmt.Errorf("launch requires --extension-dir DIR and --output FILE, with no positional arguments")
	}
	manifest, err := os.ReadFile(filepath.Join(*extensionDir, "package.json"))
	if err != nil {
		return err
	}
	translations, err := os.ReadFile(filepath.Join(*extensionDir, "package.nls.json"))
	if err != nil {
		return err
	}
	schema, err := schemas.GenerateLaunch(manifest, translations, diagnostics)
	if err != nil {
		return err
	}
	return os.WriteFile(*output, schema, 0o644)
}

func main() {
	if err := run(os.Args[1:], os.Stderr); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
