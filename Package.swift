// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "CollisionShapes",
    products: [
        .library(
            name: "CollisionShapes",
            targets: ["CollisionShapes"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CooperCorona/CoronaMath.git", .branch("Number"))
    ],
    targets: [
        .target(
            name: "CollisionShapes",
            dependencies: [
                "CoronaMath"
            ]),
        .testTarget(
            name: "CollisionShapesTests",
            dependencies: ["CollisionShapes"],
            path: "Tests"),
    ]
)
