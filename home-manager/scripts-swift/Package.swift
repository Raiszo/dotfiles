// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "PersonalScripts",
    products: [
        .executable(name: "generate-json-schemas", targets: ["GenerateJsonSchemas"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ajevans99/swift-json-schema", from: "0.13.2"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.0"),
    ],
    targets: [
        .executableTarget(name: "GenerateJsonSchemas", dependencies: [
            .product(name: "JSONSchema", package: "swift-json-schema"),
            .product(name: "JSONSchemaBuilder", package: "swift-json-schema"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .testTarget(name: "GenerateJsonSchemasTests", dependencies: [
            "GenerateJsonSchemas",
            .product(name: "JSONSchema", package: "swift-json-schema"),
        ], resources: [.copy("Fixtures")]),
    ]
)
