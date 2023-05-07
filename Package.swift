// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARDiagramsKit",
    platforms: [.iOS(.v15)],
    products: [
      .library(name: "Charts", targets: ["Charts"]),
      .library(name: "Parser", targets: ["Parser"]),
      .library(name: "Models", targets: ["Models"]),
    ],
    dependencies: [
      .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.9")),
      .package(url: "https://github.com/yahoojapan/SwiftyXMLParser.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
      .target(name: "Charts", dependencies: ["Models"]),
      .target(name: "Parser", dependencies: ["ZIPFoundation", "SwiftyXMLParser", "Models"]),
      .target(name: "Models"),
    ]
)
