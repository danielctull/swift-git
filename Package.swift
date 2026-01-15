// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-git",
  platforms: [
    .macOS(.v13),
    .iOS(.v15),
  ],
  products: [
    .library(name: "Git", targets: ["Git"])
  ],
  dependencies: [
    .package(url: "https://github.com/danielctull-forks/swift-libgit2.git", from: "1.9.2"),
  ],
  targets: [

    .target(
      name: "Git",
      dependencies: [
        .product(name: "libgit2", package: "swift-libgit2"),
      ]
    ),

    .testTarget(
      name: "GitTests",
      dependencies: ["Git"],
      resources: [
        .copy("Repositories")
      ]
    ),
  ]
)
