import ArgumentParser
import Foundation

@main
struct GenerateJsonSchemas: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "generate-json-schemas",
        abstract: "Generate personal JSON schemas",
        subcommands: [Launch.self]
    )
}

extension GenerateJsonSchemas {
    struct Launch: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Generate my JSON schemas"
        )

        @Option(name: .long, help: "STM32Cube Debug STLink GDB Server extension directory", completion: .directory)
        var stlinkExtensionDir: String

        @Option(name: .long, help: "Destination JSON schema file", completion: .file())
        var output: String

        mutating func validate() throws {
            guard !stlinkExtensionDir.isEmpty, !output.isEmpty else {
                throw ValidationError("Paths must not be empty.")
            }
        }

        func run() throws {
            let directory = URL(fileURLWithPath: stlinkExtensionDir, isDirectory: true)
            let schema = try generateLaunch(
                manifestData: Data(contentsOf: directory.appendingPathComponent("package.json")),
                translationData: Data(contentsOf: directory.appendingPathComponent("package.nls.json")),
                warn: { FileHandle.standardError.write(Data("\($0)\n".utf8)) }
            )
            try schema.write(to: URL(fileURLWithPath: output), options: .atomic)
        }
    }
}
