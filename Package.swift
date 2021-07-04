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
        .package(url: "https://github.com/sharplet/swift-cgit2", from: "1.1.0"),
    ],
    targets: [

        .target(
            name: "Git",
            dependencies: [
                .product(name: "Cgit2", package: "swift-cgit2"),
            ]),

        .testTarget(
            name: "GitTests",
            dependencies: ["Git"],
            resources: [
                .copy("Repositories"),
            ]
        ),
    ]
)
