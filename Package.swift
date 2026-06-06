// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PureLogicsMac",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PureLogicsMac", targets: ["PureLogicsMac"])
    ],
    dependencies: [
        .package(path: "Vendor/GRDB.swift")
    ],
    targets: [
        .executableTarget(
            name: "PureLogicsMac",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "PureLogicsMac"
        )
    ]
)
