// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FhirQuestionnairesOnSwiftUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FhirQuestionnairesOnSwiftUI",
            targets: ["FhirQuestionnairesOnSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/FHIRModels", .upToNextMajor(from: "0.5.0")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", .upToNextMajor(from: "4.2.2")),
    ],
    targets: [
        .target(
            name: "FhirQuestionnairesOnSwiftUI",
            dependencies: [ 
                .product(name: "ModelsR5", package: "FHIRModels"),
                .product(name: "KeychainAccess", package: "KeychainAccess")
            ],
            resources: [
                .process("resources")
            ]
        ),
        .testTarget(
            name: "FhirQuestionnairesOnSwiftUITests",
            dependencies: ["FhirQuestionnairesOnSwiftUI"]),
    ]
)
