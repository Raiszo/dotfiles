import Testing
@testable import GenerateJsonSchemas

struct ArgumentTests {
    @Test
    func testLaunchOptions() throws {
        let command = try GenerateJsonSchemas.parseAsRoot([
            "launch", "--stlink-extension-dir", "/tmp/adapter", "--output=/tmp/schema.json",
        ])
        let launch = try #require(command as? GenerateJsonSchemas.Launch)
        #expect(launch.stlinkExtensionDir == "/tmp/adapter")
        #expect(launch.output == "/tmp/schema.json")
    }

    @Test
    func testInvalidOptions() {
        for arguments in [
            ["launch"],
            ["launch", "--stlink-extension-dir", "/tmp/adapter"],
            ["launch", "--stlink-extension-dir", "", "--output", "/tmp/schema.json"],
            ["launch", "--stlink-extension-dir", "/tmp/adapter", "--output", "/tmp/schema.json", "--typo"],
            ["unknown"],
        ] {
            #expect(throws: (any Error).self) {
                try GenerateJsonSchemas.parseAsRoot(arguments)
            }
        }
    }
}
