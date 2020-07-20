// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "GitKit",
    products: [
        .library(
            name: "GitKit",
            targets: ["GitKit"]),
    ],
    dependencies: [
        .package(name: "Tagged", url: "https://github.com/pointfreeco/swift-tagged", from: "0.5.0"),
    ],
    targets: [

        .target(
            name: "GitKit",
            dependencies: [
                "Clibgit2",
                "Tagged",
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
