// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "GitKit",
    platforms: [
      .macOS(.v12),
      .iOS(.v15),
    ],
    products: [
        .library(
            name: "GitKit",
            targets: ["GitKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.7.0"),
    ],
    targets: [

        .target(
            name: "GitKit",
            dependencies: [
                "Clibgit2",
                .product(name: "Tagged", package: "swift-tagged"),
            ]),

        .testTarget(
            name: "GitKitTests",
            dependencies: ["GitKit"],
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
