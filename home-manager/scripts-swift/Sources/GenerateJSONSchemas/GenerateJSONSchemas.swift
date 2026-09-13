import ArgumentParser
import Foundation
import JSONSchemas

@main
struct GenerateJSONSchemas: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "generate-json-schemas",
        abstract: "Generate personal JSON schemas.",
        subcommands: [Launch.self]
    )
}

extension GenerateJSONSchemas {
    struct Launch: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Generate an Emacs launch.json schema from an ST adapter extension."
        )

        @Option(name: .long, help: "ST adapter extension directory.", completion: .directory)
        var extensionDir: String

        @Option(name: .long, help: "Destination JSON schema file.", completion: .file())
        var output: String

        mutating func validate() throws {
            guard !extensionDir.isEmpty, !output.isEmpty else {
                throw ValidationError("Paths must not be empty.")
            }
        }

        func run() throws {
            let directory = URL(fileURLWithPath: extensionDir, isDirectory: true)
            let schema = try generateLaunch(
                manifestData: Data(contentsOf: directory.appendingPathComponent("package.json")),
                translationData: Data(contentsOf: directory.appendingPathComponent("package.nls.json")),
                warn: { FileHandle.standardError.write(Data("\($0)\n".utf8)) }
            )
            try schema.write(to: URL(fileURLWithPath: output), options: .atomic)
        }
    }
}
