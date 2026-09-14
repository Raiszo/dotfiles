import Testing
@testable import GenerateJSONSchemas

struct ArgumentTests {
    @Test
    func testLaunchOptions() throws {
        let command = try GenerateJSONSchemas.parseAsRoot([
            "launch", "--extension-dir", "/tmp/adapter", "--output=/tmp/schema.json",
        ])
        let launch = try #require(command as? GenerateJSONSchemas.Launch)
        #expect(launch.extensionDir == "/tmp/adapter")
        #expect(launch.output == "/tmp/schema.json")
    }

    @Test
    func testInvalidOptions() {
        for arguments in [
            ["launch"],
            ["launch", "--extension-dir", "/tmp/adapter"],
            ["launch", "--extension-dir", "", "--output", "/tmp/schema.json"],
            ["launch", "--extension-dir", "/tmp/adapter", "--output", "/tmp/schema.json", "--typo"],
            ["unknown"],
        ] {
            #expect(throws: (any Error).self) {
                try GenerateJSONSchemas.parseAsRoot(arguments)
            }
        }
    }
}
