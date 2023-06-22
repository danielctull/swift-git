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
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
    ],
    targets: [

        .target(
            name: "Git",
            dependencies: [
                "Clibgit2",
                .product(name: "Tagged", package: "swift-tagged"),
            ],
        swiftSettings: [
            .unsafeFlags(["-enable-experimental-feature", "VariadicGenerics"]),
        ]),

        .testTarget(
            name: "GitTests",
            dependencies: ["Git"],
            resources: [
                .copy("Repositories"),
            ]),

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
