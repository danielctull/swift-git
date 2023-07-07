// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "GitKit",
    platforms: [
      .macOS(.v13),
      .iOS(.v15),
    ],
    products: [
        .library(
            name: "Git",
            targets: ["Git"]),
        .executable(
            name: "git2",
            targets: ["GitTool"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
    ],
    targets: [

        .target(
            name: "Git",
            dependencies: [
                "Clibgit2",
                .product(name: "Tagged", package: "swift-tagged"),
            ]),

        .testTarget(
            name: "GitTests",
            dependencies: ["Git"],
            resources: [
                .copy("Repositories"),
            ]),

        .executableTarget(
            name: "GitTool",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Git",
            ]
        ),

        .systemLibrary(
            name: "Clibgit2",
            pkgConfig: "libgit2",
            providers: [
                .brew(["libgit2"]),
                .apt(["libgit2-dev"])
            ]
        ),
    ]
)
