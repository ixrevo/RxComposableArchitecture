// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RxComposableArchitecture",
  platforms: [
    .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v3)
  ],
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "RxComposableArchitecture",
      targets: ["RxComposableArchitecture"]),
    .library(
      name: "RxComposableArchitecture-dynamic",
      type: .dynamic,
      targets: ["RxComposableArchitecture"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(
      name: "CasePaths",
      url: "https://github.com/pointfreeco/swift-case-paths.git",
      from: "0.1.0"),
    .package(
      url: "https://github.com/ReactiveX/RxSwift.git",
      from: "5.0.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "RxComposableArchitecture",
      dependencies: [
        "CasePaths",
        "RxSwift",
        .product(name: "RxRelay", package: "RxSwift")
    ]),
    .testTarget(
      name: "RxComposableArchitectureTests",
      dependencies: ["RxComposableArchitecture"]),
  ],
  swiftLanguageVersions: [.v5]
)
