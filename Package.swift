// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "TJStoreReviewController",
    platforms: [.iOS(.v10), .macCatalyst(.v13)],
    products: [
        .library(
            name: "TJStoreReviewController",
            targets: ["TJStoreReviewController"]
        )
    ],
    targets: [
        .target(
            name: "TJStoreReviewController",
            path: ".",
            publicHeadersPath: "."
        )
    ]
)
