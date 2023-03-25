// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARDiagramsKit",
    platforms: [.iOS(.v13)],
    products: [
      .library(name: "Charts", targets: ["Charts"]),
      .library(name: "XMLSParser", targets: ["XMLSParser"]),
    ],
    dependencies: [],
    targets: [
      .target(name: "Charts"),
      .target(name: "XMLSParser"),
    ]
)
