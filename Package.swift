// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "GitKit",
    products: [
        .library(
            name: "GitKit",
            targets: ["GitKit"]),
    ],
    targets: [

        .target(
            name: "GitKit",
            dependencies: ["Clibgit2"]),

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
