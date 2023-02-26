// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AnimateNumberText",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8)
  ],
  products: [
    .library(
      name: "AnimateNumberText",
      targets: ["AnimateNumberText"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "AnimateNumberText",
      dependencies: []),
    .testTarget(
      name: "AnimateNumberTextTests",
      dependencies: ["AnimateNumberText"]),
  ]
)
