// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AlbumPhotoCore",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .library(name: "AlbumPhotoCore", targets: ["AlbumPhotoCore"])
    ],
    targets: [
        .target(
            name: "AlbumPhotoCore",
            path: "Albumzh.swiftpm/Sources/AlbumPhotoCore"
        ),
        .testTarget(
            name: "AlbumPhotoCoreTests",
            dependencies: ["AlbumPhotoCore"]
        )
    ]
)
