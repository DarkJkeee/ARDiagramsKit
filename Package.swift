// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARDiagramsKit",
    platforms: [.iOS(.v13)],
    products: [
      .library(name: "Charts", targets: ["Charts"]),
      .library(name: "Parser", targets: ["Parser"]),
    ],
    dependencies: [
      .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.9")),
      .package(url: "https://github.com/yahoojapan/SwiftyXMLParser.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
      .target(name: "Charts"),
      .target(name: "Parser", dependencies: ["ZIPFoundation", "SwiftyXMLParser"]),
    ]
)
