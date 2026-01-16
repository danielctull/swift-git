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
    .package(url: "https://github.com/danielctull-forks/libgit2.git", branch: "swift")
  ],
  targets: [

    .target(
      name: "Git",
      dependencies: [
        .product(name: "libgit2", package: "libgit2"),
      ]),

    .testTarget(
      name: "GitTests",
      dependencies: [
        "Git",
        .product(name: "libgit2", package: "libgit2"),
      ],
      resources: [
        .copy("Repositories")
      ]),
  ]
)
