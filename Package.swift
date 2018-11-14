// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sip",
    products: [
        .library(
            name: "Sip",
            targets: ["Sip"]),
        .executable(
            name: "SipGen",
            targets: ["SipGen"])
    ],
    targets: [
        .target(
            name: "Sip",
            dependencies: []),
        .target(
            name: "SipGen",
            dependencies: []),
        .testTarget(
            name: "SipTests",
            dependencies: ["Sip"])
    ]
)
