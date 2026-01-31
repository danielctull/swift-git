// swift-tools-version: 6.1

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
  traits: [
    .default(enabledTraits: []),
    .trait(
      name: "libssh2",
      description:
        "Use libssh2 for SSH transport (enables SSH for iOS, tvOS, watchOS, visionOS, Windows)"
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/danielctull-forks/swift-libgit2.git",
      from: "1.9.2",
      traits: [
        .trait(name: "libssh2", condition: .when(traits: ["libssh2"]))
      ]
    )
  ],
  targets: [

    .target(
      name: "Git",
      dependencies: [
        .product(name: "libgit2", package: "swift-libgit2")
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
