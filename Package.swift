// swift-tools-version:5.2

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
            dependencies: ["GitKit"]),

        .systemLibrary(
            name: "Clibgit2",
            providers: [
                .brew(["libgit2"]),
                .apt(["libgit2-dev"])
            ]
        ),
    ]
)
