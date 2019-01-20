// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GambrinusCheck",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "git@github.com:coodly/TalkToCloud.git", from: "0.8.0"),
        .package(url: "https://github.com/coodly/swlogger.git", from: "0.3.4"),
        .package(url: "git@github.com:coodly/BloggerAPI.git", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GambrinusCheck",
            dependencies: ["TalkToCloud", "SWLogger", "BloggerAPI"]),
        .testTarget(
            name: "GambrinusCheckTests",
            dependencies: ["GambrinusCheck"]),
    ]
)
