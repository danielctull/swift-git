// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "GitKit",
    platforms: [
      .macOS(.v10_13),
      .iOS(.v11),
    ],
    products: [
        .library(
            name: "GitKit",
            targets: ["GitKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sharplet/swift-cgit2", from: "1.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.5.0"),
    ],
    targets: [

        .target(
            name: "GitKit",
            dependencies: [
                .product(name: "Cgit2", package: "swift-cgit2"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]),

        .testTarget(
            name: "GitKitTests",
            dependencies: ["GitKit"],
            resources: [
                .copy("Repositories"),
            ]
        ),
    ]
)
