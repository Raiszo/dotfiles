import XCTest
@testable import GenerateJSONSchemas

final class ArgumentTests: XCTestCase {
    func testLaunchOptions() throws {
        let command = try GenerateJSONSchemas.parseAsRoot([
            "launch", "--extension-dir", "/tmp/adapter", "--output=/tmp/schema.json",
        ])
        let launch = try XCTUnwrap(command as? GenerateJSONSchemas.Launch)
        XCTAssertEqual(launch.extensionDir, "/tmp/adapter")
        XCTAssertEqual(launch.output, "/tmp/schema.json")
    }

    func testInvalidOptions() {
        for arguments in [
            ["launch"],
            ["launch", "--extension-dir", "/tmp/adapter"],
            ["launch", "--extension-dir", "", "--output", "/tmp/schema.json"],
            ["launch", "--extension-dir", "/tmp/adapter", "--output", "/tmp/schema.json", "--typo"],
            ["unknown"],
        ] {
            XCTAssertThrowsError(try GenerateJSONSchemas.parseAsRoot(arguments))
        }
    }
}
