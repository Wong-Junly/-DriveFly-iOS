// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DriveFlyCore",
    products: [.library(name: "DriveFly", targets: ["DriveFly"])],
    targets: [
        .target(name: "DriveFly", path: "DriveFly",
                exclude: ["ControllerModel.swift", "ContentView.swift", "DriveFlyApp.swift",
                          "Info.plist", "PrivacyInfo.xcprivacy"],
                sources: ["ControlCore.swift"]),
        .testTarget(name: "DriveFlyTests", dependencies: ["DriveFly"], path: "DriveFlyTests")
    ]
)
