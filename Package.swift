// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Finanzas",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Finanzas",
            targets: ["Finanzas"]
        )
    ],
    targets: [
        .target(
            name: "Finanzas",
            path: "Sources/Finanzas"
        )
    ]
)
