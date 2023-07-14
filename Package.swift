// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "swift-git",
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
    ],
    targets: [

        .target(
            name: "Git",
            dependencies: [
                "Clibgit2",
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
